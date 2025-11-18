import 'dart:async';

import 'package:blockchain_utils/utils/atomic/atomic.dart';
import 'package:flutter/widgets.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/pages/types.dart';
import 'package:stealth_stash/future/wallet/transaction/fields/fields.dart';
import 'package:stealth_stash/future/wallet/transaction/pages/state_warning.dart';
import 'package:stealth_stash/future/wallet/transaction/types/types.dart';
import 'package:stealth_stash/wallet/wallet.dart';

mixin TransactionStatePageController<
    SUCCESS extends SubmitTransactionSuccess,
    SIGNEDTX,
    CHAINTRANSACTION extends ChainTransaction,
    ACCOUNT extends Chain> on DisposableMixin {
  WalletNetwork get network;
  final StreamPageProgressController pageKey =
      StreamPageProgressController(initialStatus: StreamWidgetStatus.progress);

  void setPageIdle() {
    pageKey.backToIdle();
  }

  void setPageProgress({String? text}) {
    if (text == null) {
      pageKey.progress();
    } else {
      pageKey.progressText(text);
    }
  }

  Widget onTxCompleteWidget({
    required CHAINTRANSACTION? transaction,
    required SUCCESS txId,
    required ACCOUNT account,
  }) {
    return SuccessTransactionTextView(
        txId: txId.txId,
        warning: txId.warning,
        account: account,
        transaction: transaction);
  }

  void setTxComplete({
    required CHAINTRANSACTION? transaction,
    required SUCCESS txId,
    required ACCOUNT account,
  }) {
    pageKey.success(
        progressWidget: onTxCompleteWidget(
            transaction: transaction, txId: txId, account: account),
        backToIdle: false);
    final txUrl = network.getTransactionExplorer(txId.txId);
    appLogger.debug(
        runtime: runtimeType,
        functionName: "setTxComplete",
        msg: "txID: ${txId.txId}. $txUrl");
  }

  void setPageError(String error,
      {bool backToIdle = false, bool showBackButton = true}) {
    pageKey.errorText(error,
        backToIdle: backToIdle, showBackButton: showBackButton);
  }

  @override
  void dispose() {
    pageKey.dispose();
    super.dispose();
    appLogger.debug(functionName: "dispose", runtime: runtimeType, msg: "Page");
  }
}

enum TransactionStateControllerEventType {
  transaction,
  signedTx,
  submitTx,
  walletTxs
}

class TransactionStateControllerEvent<
    ACCOUNT extends ChainAccount,
    TRANSACTIONDATA extends ITransactionData,
    TRANSACTION extends ITransaction<TRANSACTIONDATA, ACCOUNT>,
    SIGNEDTX extends ISignedTransaction<TRANSACTION, Object>,
    T extends ChainTransaction,
    SUCCESS extends SubmitTransactionSuccess<SIGNEDTX>> {
  final TransactionStateControllerEventType type;
  final TRANSACTION? tx;
  final SIGNEDTX? signedTx;
  final SUCCESS? submitTx;
  final List<IWalletTransaction<T, ACCOUNT>>? walletTxs;
  const TransactionStateControllerEvent(
      {required this.type,
      this.tx,
      this.signedTx,
      this.submitTx,
      this.walletTxs});
}

abstract class TransactionStateController<
        TOKEN extends TokenCore,
        ACCOUNT extends ChainAccount<dynamic, TOKEN, NFTCore, ChainTransaction>,
        CLIENT extends NetworkClient,
        NETWORK extends WalletNetwork,
        C extends APPCHAINTOKENACCOUNTCLIENTNETWORK<TOKEN, ACCOUNT, CLIENT,
            NETWORK>,
        TRANSACTIONDATA extends ITransactionData,
        TRANSACTION extends ITransaction<TRANSACTIONDATA, ACCOUNT>,
        SIGNEDTX extends ISignedTransaction<TRANSACTION, Object>,
        T extends ChainTransaction,
        SUCCESS extends SubmitTransactionSuccess<SIGNEDTX>,
        FEE extends TransactionFeeData>
    with
        DisposableMixin,
        StreamStateController,
        TransactionStatePageController<SUCCESS, SIGNEDTX, T, C> {
  final lock = SafeAtomicLock();
  StreamSubscription<void>? _feeListener;
  StreamSubscription<IntegerBalance>? _accountListener;
  final StreamValue<TransactionStateStatus> stateStatus =
      StreamValue(TransactionStateStatus.error());
  final StreamController<
      TransactionStateControllerEvent<ACCOUNT, TRANSACTIONDATA, TRANSACTION,
          SIGNEDTX, T, SUCCESS>> _event = StreamController.broadcast();
  Stream<
      TransactionStateControllerEvent<
          ACCOUNT,
          TRANSACTIONDATA,
          TRANSACTION,
          SIGNEDTX,
          T,
          SUCCESS>> onStateEvent({TransactionStateControllerEventType? type}) {
    if (type == null) return _event.stream;
    return _event.stream.where((e) => e.type == type);
  }

  FEE get txFee;
  TransactionOperations get operation;
  final ACCOUNT _address;
  ACCOUNT get address => _address;
  late CLIENT _client;
  CLIENT get client => _client;
  final WalletProvider walletProvider;
  final C account;
  @override
  final NETWORK network;
  bool get swtichAddressEnabled => true;
  TransactionStateController(
      {required this.walletProvider,
      required this.account,
      required ACCOUNT address})
      : network = account.network,
        _address = address;
  TransactionStateController cloneController(ACCOUNT address);
  Widget widgetBuilder(BuildContext context);
  Future<TRANSACTION> buildTransaction({bool simulate = false});
  Future<SIGNEDTX> signTransaction(TRANSACTION transaction,
      {bool fakeSignature = false});
  Future<SubmitTransactionResult> submitTransaction(
      {required SIGNEDTX signedTransaction});
  Future<List<IWalletTransaction<T, ACCOUNT>>> buildWalletTransaction(
      {required SIGNEDTX signedTx, required SUCCESS txId});
  Future<TRANSACTIONDATA> buildTransactionData({bool simulate = false});
  Future<void> estimateFee();
  BigInt getMaxFeeInput() {
    return address.address.currencyBalance;
  }

  void onFeeUpdated(void _) {
    onStateUpdated();
  }

  void onAccountUpdated() {
    onStateUpdated();
  }

  TransactionStateStatus getStateStatus() {
    if (!fieldsFiled) {
      return TransactionStateStatus.error();
    }
    if (!txFee.fee.isManual && txFee.isPending) {
      return TransactionStateStatus.error();
    }

    final fieldsError = this.fieldsError;
    if (fieldsError != null) {
      return TransactionStateStatus.error();
    }
    if (txFee.feeMode.isDynamicFee && !txFee.hasFee) {
      return TransactionStateStatus.error(error: "fee_zero_validator_desc".tr);
    }
    return TransactionStateStatus.ready();
  }

  Future<TransactionStateController> initForm({
    required BuildContext context,
    required CLIENT client,
    bool updateAccount = true,
    bool updateTokens = false,
  }) async {
    _feeListener = txFee.stream.listen(onFeeUpdated);
    _accountListener = account.address.address.balance.stream
        .listen((_) => onAccountUpdated());
    if (updateAccount || updateTokens) {
      account.updateAddressBalance(address, tokens: updateTokens);
    }
    return this;
  }

  Future<List<IWalletTransaction<T, ACCOUNT>>> _buildWalletTransaction(
      {required TRANSACTION transaction,
      required SIGNEDTX signedTx,
      required SUCCESS txId}) async {
    final txes = await buildWalletTransaction(signedTx: signedTx, txId: txId);
    for (final i in txes) {
      await account.saveTransaction(
          address: i.account, transaction: i.transaction);
    }

    return txes;
  }

  Future<void> signAndSendTransaction({
    BuildContext? context,
    Future<TRANSACTION?> Function(TRANSACTION)? onTransactionCreated,
    Future<SIGNEDTX?> Function(SIGNEDTX)? onTransactionSigned,
  }) async {
    stateStatus.value = getStateStatus();
    if (stateStatus.value.status.hasError) return;
    final warning = stateStatus.value.warning;
    if (context != null && warning != null) {
      final accept = await context.openSliverDialog(
          widget: (context) => TransactionStateWarningView(warning: warning));
      if (accept != true) return;
    }
    setPageProgress(text: "creating_transaction".tr);
    final result = await MethodUtils.call(() async {
      TRANSACTION? transaction = await buildTransaction();
      if (onTransactionCreated != null) {
        transaction = await onTransactionCreated(transaction);
      }
      if (transaction == null) return null;
      _event.add(TransactionStateControllerEvent(
          type: TransactionStateControllerEventType.transaction,
          tx: transaction));
      setPageProgress(text: "signing_transaction_please_wait".tr);
      SIGNEDTX? signedTransaction = await signTransaction(transaction);
      if (onTransactionSigned != null) {
        signedTransaction = await onTransactionSigned(signedTransaction);
      }
      if (signedTransaction == null) return null;
      _event.add(TransactionStateControllerEvent(
          type: TransactionStateControllerEventType.signedTx,
          signedTx: signedTransaction));
      setPageProgress(text: "broadcast_to_the_network_please_wait".tr);
      SubmitTransactionResult result =
          await submitTransaction(signedTransaction: signedTransaction);
      return (transaction, signedTransaction, result);
    }, delay: APPConst.animationDuraion);
    if (result.hasError) {
      appLogger.error(
          runtime: runtimeType,
          functionName: "signAndSendTransaction",
          msg: result.localizationError);

      if (result.exception == WalletExceptionConst.rejectSigning) {
        setPageIdle();
      } else {
        setPageError(result.localizationError);
      }
      return;
    }
    final txResult = result.result;
    if (txResult == null) {
      if (pageKey.status.inProgress) setPageIdle();
      return;
    }
    final submittionResult = txResult.$3;
    if (submittionResult.status.isFailed) {
      final error = (submittionResult as SubmitTransactionFailed).error;
      appLogger.error(
          runtime: runtimeType,
          functionName: "signAndSendTransaction",
          msg: error);
      setPageError(error.tr);
      return;
    }
    final successResult = submittionResult as SUCCESS;
    _event.add(TransactionStateControllerEvent(
        type: TransactionStateControllerEventType.submitTx,
        submitTx: successResult));
    final walletTxs = await _buildWalletTransaction(
        transaction: txResult.$1, signedTx: txResult.$2, txId: successResult);
    IWalletTransaction<T, ACCOUNT>? currentTx;
    if (walletTxs.isNotEmpty) {
      currentTx = walletTxs.firstWhere((e) => e.account == address,
          orElse: () => walletTxs.first);
      _event.add(TransactionStateControllerEvent(
          type: TransactionStateControllerEventType.walletTxs,
          walletTxs: walletTxs));
    }

    setTxComplete(
        transaction: currentTx?.transaction,
        txId: successResult,
        account: account);
  }

  void onStateUpdated() {
    final status = getStateStatus();
    stateStatus.value = status;
  }

  Widget onPageBuilder(BuildContext context) {
    return APPStreamBuilder(
        value: notifier, builder: (_, value) => widgetBuilder(context));
  }

  Future<TransactionStateController> init(BuildContext context) async {
    final init = await MethodUtils.call(() async {
      _client = await account.client();
      final controller = await initForm(client: _client, context: context);
      onStateUpdated();
      estimateFee();
      return controller;
    });
    if (init.hasError) {
      appLogger.error(
          runtime: runtimeType,
          functionName: "init",
          msg: init.localizationError,
          trace: init.trace);
      setPageError(init.localizationError,
          backToIdle: false, showBackButton: false);
      return this;
    }
    setPageIdle();
    return init.result;
  }

  bool get fieldsReady => fieldsError == null;
  String? get fieldsError {
    for (final i in fields) {
      final fieldError = i.validate;
      if (fieldError != null) return fieldError;
    }
    return null;
  }

  bool get fieldsFiled {
    for (final i in fields) {
      final filed = i.complete;
      if (!filed) return false;
    }
    return true;
  }

  List<LiveFormField> get fields;
  @override
  void dispose() {
    super.dispose();
    _event.close();
    _accountListener?.cancel();
    _feeListener?.cancel();
    for (final i in fields) {
      i.dispose();
    }
    appLogger.debug(
        functionName: "dispose",
        runtime: runtimeType,
        msg: "TransactionStateController");
  }
}
