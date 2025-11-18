import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/app/utils/list/extension.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/wallet/web3/networks/ethereum/constant/exception.dart';
import 'package:stealth_stash/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:stealth_stash/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:stealth_stash/wallet/web3/core/core.dart';
import 'package:stealth_stash/wallet/web3/networks/ethereum/permission/models/account.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthreumTransactionAccessList with CborSerializable {
  final ETHAddress address;
  final List<List<int>> storageKeys;
  Web3EthreumTransactionAccessList(
      {required this.address, required List<List<int>> storageKeys})
      : storageKeys = storageKeys.map((e) => e.asImmutableBytes).toImutableList;
  factory Web3EthreumTransactionAccessList.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.web3EthereumTransactionAccessList);
    return Web3EthreumTransactionAccessList(
        address: ETHAddress(values.elementAs(0)),
        storageKeys: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          address.address,
          CborSerializable.fromDynamic(
              storageKeys.map((e) => CborBytesValue(e)).toList())
        ]),
        CborTagsConst.web3EthereumTransactionAccessList);
  }
}

class Web3EthreumSendTransaction extends Web3EthereumRequestParam<String> {
  final Web3EthereumChainAccount accessAccount;
  final List<Web3EthreumTransactionAccessList>? accessList;
  final ETHAddress? to;
  final int? gas;
  final BigInt? chainId;
  final BigInt? gasPrice;
  final BigInt? maxFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  final BigInt value;
  final List<int> data;
  final ETHTransactionType? transactionType;

  bool get isEip1559Metrics => maxFeePerGas != null;
  bool get isLegacyFeeMetrics => gasPrice != null;
  bool get hasFee => isEip1559Metrics || isLegacyFeeMetrics || gas != null;

  Web3EthreumSendTransaction._(
      {required this.accessAccount,
      required this.to,
      List<Web3EthreumTransactionAccessList>? accessList,
      this.gas,
      this.gasPrice,
      required this.value,
      required List<int> data,
      this.maxFeePerGas,
      this.maxPriorityFeePerGas,
      this.chainId,
      this.transactionType})
      : accessList = accessList?.immutable,
        data = data.asImmutableBytes;

  factory Web3EthreumSendTransaction(
      {required Web3EthereumChainAccount account,
      required ETHAddress? to,
      required BigInt value,
      required int? gas,
      required List<int>? data,
      required BigInt? chainId,
      required BigInt? gasPrice,
      required BigInt? maxPriorityFeePerGas,
      required BigInt? maxFeePerGas,
      List<Web3EthreumTransactionAccessList>? accessList,
      int? transactionType}) {
    if (accessList?.isEmpty ?? false) {
      accessList = null;
    }
    if (gasPrice != null &&
        (maxFeePerGas != null || maxPriorityFeePerGas != null)) {
      throw Web3EthereumExceptionConst.invalidGasArg;
    }

    if ((maxFeePerGas != null && maxPriorityFeePerGas == null) ||
        (maxFeePerGas == null && maxPriorityFeePerGas != null)) {
      throw Web3EthereumExceptionConst.invalidEIP1559GasArg;
    }
    ETHTransactionType? ethTransactionType = ETHTransactionType.values
        .firstWhereOrNull((e) => e.prefix == transactionType);
    if (transactionType != null && ethTransactionType == null) {
      throw Web3EthereumExceptionConst.invalidTransactionType;
    }
    if (ethTransactionType != null) {
      if (maxFeePerGas != null) {
        if (ethTransactionType != ETHTransactionType.eip1559) {
          throw Web3EthereumExceptionConst.invalidTransactionTypeOrGas;
        }
      }
      if (gasPrice != null) {
        if (ethTransactionType == ETHTransactionType.eip1559) {
          throw Web3EthereumExceptionConst.invalidTransactionTypeOrGas;
        }
      }
      if (accessList != null) {
        if (ethTransactionType == ETHTransactionType.legacy) {
          throw Web3EthereumExceptionConst.invalidTransactionAccessList;
        }
      }
    } else {
      if (maxFeePerGas != null) {
        ethTransactionType = ETHTransactionType.eip1559;
      } else if (accessList != null) {
        ethTransactionType = ETHTransactionType.eip2930;
      } else if (gasPrice != null) {
        ethTransactionType = ETHTransactionType.legacy;
      }
    }
    return Web3EthreumSendTransaction._(
        accessAccount: account,
        to: to,
        value: value,
        gas: gas,
        gasPrice: gasPrice,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        data: data ?? const [],
        chainId: chainId,
        transactionType: ethTransactionType);
  }

  factory Web3EthreumSendTransaction.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final String? to = values.elementAs(2);
    final int? trType = values.elementAs(10);
    return Web3EthreumSendTransaction._(
        accessAccount: Web3EthereumChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        to: to == null ? null : ETHAddress(to),
        gas: values.elementAs(3),
        gasPrice: values.elementAs(4),
        maxFeePerGas: values.elementAs(5),
        maxPriorityFeePerGas: values.elementAs(6),
        value: values.elementAs(7),
        data: values.elementAs(8),
        chainId: values.elementAs(9),
        transactionType:
            trType == null ? null : ETHTransactionType.fromPrefix(trType));
  }

  @override
  Web3EthereumRequestMethods get method =>
      Web3EthereumRequestMethods.sendTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          method.tag,
          accessAccount.toCbor(),
          to?.address,
          gas,
          gasPrice,
          maxFeePerGas,
          maxPriorityFeePerGas,
          value,
          CborBytesValue(data),
          chainId,
          transactionType?.prefix
        ]),
        type.tag);
  }

  @override
  Future<Web3EthereumRequest<String, Web3EthreumSendTransaction>> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required WEB3REQUESTNETWORKCONTROLLER<IEthAddress, EthereumChain,
              Web3EthereumChainAccount>
          chainController}) async {
    final chain = await super.findRequestChain(
        request: request,
        authenticated: authenticated,
        chainController: chainController);
    return Web3EthereumRequest<String, Web3EthreumSendTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3EthereumChainAccount> get requiredAccounts => [accessAccount];
}
