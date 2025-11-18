import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/app/models/models/typedef.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/wallet/wallet.dart';

enum MoneroTransactionOperations implements TransactionOperations {
  transfer("transfer"),
  tokenTransfer("transfer_token");

  @override
  final String value;
  const MoneroTransactionOperations(this.value);
}

class MoneroTransactionFee extends TransactionFee {
  MoneroTransactionFee({required super.type, required super.fee, super.error});
}

class MoneroTransactionFeeData
    extends TransactionDynamicFeeData<MoneroTransactionFee> {
  MoneroTransactionFeeData({required super.select, required super.feeToken});

  @override
  MoneroTransactionFee createManualFee(BigInt amount) {
    return MoneroTransactionFee(
        type: TxFeeTypes.manually, fee: IntegerBalance.token(amount, feeToken));
  }
}

abstract class BaseMoneroTransactionController
    extends TransactionStateController<
        TokenCore,
        IMoneroAddress,
        MoneroClient,
        WalletMoneroNetwork,
        MoneroChain,
        IMoneroTransactionData,
        IMoneroTransaction,
        IMoneroSignedTransaction,
        MoneroWalletTransaction,
        SubmitTransactionSuccess<IMoneroSignedTransaction>,
        MoneroTransactionFeeData> {
  BaseMoneroTransactionController(
      {required super.walletProvider,
      required super.account,
      required super.address});
}

class MoneroAccountFetchedUtxos
    with DisposableMixin, Equality, StreamStateController {
  final IMoneroAddress address;
  MoneroAccountFetchedUtxos({required this.address, required this.utxos});
  final MoneroAccountWithUtxo utxos;

  List<MoneroViewOutputDetails> _selectedUtxos = [];
  List<MoneroViewOutputDetails> get selectedUtxos => _selectedUtxos;
  bool get hasUtxos => utxos.utxos.isNotEmpty;
  bool _allSelected = false;
  int _totalSelected = 0;
  bool get allSelected => _allSelected;
  int get totalSelected => _totalSelected;
  BigInt _totalUtxo = BigInt.zero;
  BigInt get totalUtxo => _totalUtxo;
  bool isSelected(MoneroViewOutputDetails utxo) {
    return _selectedUtxos.contains(utxo);
  }

  void _update() {
    _totalSelected = _selectedUtxos.length;
    _allSelected = _selectedUtxos.length == utxos.utxos.length;
    _totalUtxo = _selectedUtxos.fold<BigInt>(
        BigInt.zero, (p, c) => p + c.amount.balance);
    notify();
  }

  void addUtxo(
      MoneroViewOutputDetails utxo, int totalSelected, DynamicVoid onMaxInput) {
    if (!_selectedUtxos.remove(utxo)) {
      if (totalSelected >= MoneroConst.ringSize) {
        onMaxInput();
        return;
      }
      _selectedUtxos.add(utxo);
    }
    _totalSelected = _selectedUtxos.length;
    _allSelected = _selectedUtxos.length == utxos.utxos.length;
    _update();
  }

  void selectAll(int totalSelected, DynamicVoid onMaxInput,
      {bool select = false}) {
    if (select) {
      final remain =
          MoneroConst.ringSize - totalSelected + _selectedUtxos.length;
      _selectedUtxos =
          utxos.utxos.where((e) => !e.output.needUpdate).take(remain).toList();
      if (_selectedUtxos.length != utxos.utxos.length) {
        onMaxInput();
      }
    } else {
      _selectedUtxos = [];
    }
    _update();
  }

  void toggleAll(int totalSelected, DynamicVoid onMaxInput) {
    if (allSelected) {
      _selectedUtxos = [];
    } else {
      final remain =
          MoneroConst.ringSize - totalSelected + _selectedUtxos.length;
      _selectedUtxos =
          utxos.utxos.where((e) => !e.output.needUpdate).take(remain).toList();
      if (_selectedUtxos.length != utxos.utxos.length) {
        onMaxInput();
      }
    }
    _update();
  }

  @override
  List get variabels => [address];
}

class MoneroTransferDetails extends TransferOutputDetails<MoneroAddress> {
  final bool allowNegativeAmount;
  MoneroTransferDetails({
    required super.recipient,
    required Token token,
    super.recipientUpdateble = false,
    this.allowNegativeAmount = false,
  }) : super(
            amount:
                IntegerBalance.zero(token, allowNegative: allowNegativeAmount));

  @override
  void updateBalance(BigInt amount) {
    assert(allowNegativeAmount || !amount.isNegative, "invalid amount.");
    if (amount.isNegative && !allowNegativeAmount) return;
    this.amount.updateBalance(amount);
    notify();
  }

  @override
  List get variabels => [recipient];

  IMoneroTransactionDataTransfer toMoneroDestination() {
    return IMoneroTransactionDataTransfer(
        amount: amount.clone(immutable: true, allowNegative: false),
        recipient: recipient);
  }
}

class MoneroOutputDetailsWithAddress {
  final MoneroOutputDetails paymet;
  final IMoneroAddress address;
  const MoneroOutputDetailsWithAddress(
      {required this.paymet, required this.address});
}

class IMoneroTransactionData extends ITransactionData {
  final List<MoneroOutputDetailsWithAddress> payments;
  final MoneroTxDestination? change;
  final List<IMoneroTransactionDataTransfer> destinations;
  IMoneroTransactionData(
      {required this.change,
      required List<MoneroOutputDetailsWithAddress> payments,
      required List<IMoneroTransactionDataTransfer> destinations})
      : destinations = destinations.immutable,
        payments = payments.immutable;
}

class IMoneroTransactionDataTransfer {
  final ReceiptAddress<MoneroAddress> recipient;
  final IntegerBalance amount;
  IMoneroTransactionDataTransfer(
      {required this.recipient, required this.amount});
}

class IMoneroTransaction
    extends ITransaction<IMoneroTransactionData, IMoneroAddress> {
  final MoneroRingOutput ringOutput;
  final List<SpendablePayment<MoneroLockedPayment>> spendablePayment;
  final BigInt fee;
  IMoneroTransaction({
    required super.account,
    required super.transactionData,
    required this.ringOutput,
    required List<SpendablePayment<MoneroLockedPayment>> spendablePayment,
    required this.fee,
  }) : spendablePayment = spendablePayment.immutable;
}

class IMoneroSignedTransaction
    extends ISignedTransaction<IMoneroTransaction, MoneroSigningTxResponse> {
  IMoneroSignedTransaction(
      {required super.transaction,
      required super.signatures,
      required super.finalTransactionData});
}
