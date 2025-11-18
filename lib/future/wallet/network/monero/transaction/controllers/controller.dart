import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/pages/transaction.dart';
import 'package:stealth_stash/future/wallet/network/monero/transaction/controllers/utxos.dart';
import 'package:stealth_stash/future/wallet/network/monero/transaction/types/types.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';

import 'fee.dart';
import 'provider.dart';
import 'signer.dart';

abstract class MoneroTransactionStateController
    extends BaseMoneroTransactionController
    with
        MoneroTransactionApiController,
        MoneroTransactionFeeController,
        MoneroTransactionUtxosController,
        MoneroTransactionSignerController {
  Token get transferToken;

  MoneroTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.address});

  @override
  Future<IMoneroTransactionData> simulateTransaction() async {
    final transaction = await buildTransactionData(simulate: true);
    return transaction;
  }

  @override
  Future<IMoneroSignedTransaction> signTransaction(
      IMoneroTransaction transaction,
      {bool fakeSignature = false}) async {
    final signedTx = await signTransactionInternal(transaction);
    return signedTx;
  }

  @override
  Future<IMoneroTransaction> buildTransaction({bool simulate = false}) async {
    final transactionData = await buildTransactionData(simulate: simulate);
    final payments = transactionData.payments
        .map((e) => e.paymet.toLockedPayment())
        .toList();
    final MoneroRingOutput ringOutput = await buildRingOutput(payments);
    final spendablePayment = await generatePaymentOutputsRings(
        payments: payments,
        outKeysRequestOrder: ringOutput.orderedIndexes,
        outKeysRequests: ringOutput.indexes,
        fakeOutsLength: MoneroConst.ringSize - 1);
    return IMoneroTransaction(
        account: address,
        transactionData: transactionData,
        fee: txFee.fee.fee.balance,
        ringOutput: ringOutput,
        spendablePayment: spendablePayment);
  }

  @override
  Future<SubmitTransactionResult> submitTransaction(
      {required IMoneroSignedTransaction signedTransaction}) async {
    final response =
        await client.sendTx(signedTransaction.finalTransactionData.txBytes);
    if (response.isOk) {
      return SubmitTransactionSuccess(
          txId: signedTransaction.finalTransactionData.txData.txID,
          signedTransaction: signedTransaction);
    }
    return SubmitTransactionFailed("transaction_submission_error"
        .tr
        .replaceOne(response.getErrorMessage() ?? ''));
  }

  @override
  Widget onTxCompleteWidget(
      {required MoneroWalletTransaction? transaction,
      required SubmitTransactionSuccess<IMoneroSignedTransaction> txId,
      required MoneroChain account}) {
    return SuccessTransactionTextView(
      txId: txId.txId,
      account: account,
      transaction: transaction,
      additionalWidget: transaction == null
          ? null
          : (context) {
              return FixedElevatedButton(
                  onPressed: () {
                    context.openSliverDialog(
                        widget: (p0) => TransactionModalView(
                              account: account,
                              transaction: transaction,
                              address: address,
                            ),
                        label: "transaction".tr);
                  },
                  child: Text("show_proofs".tr));
            },
    );
  }

  @override
  Future<TransactionStateController> initForm({
    required BuildContext context,
    required MoneroClient client,
    bool updateAccount = true,
    bool updateTokens = false,
  }) async {
    await super.initForm(
        context: context, client: client, updateAccount: updateAccount);
    await initAccountUtxos(account: account, address: address);
    return this;
  }
}
