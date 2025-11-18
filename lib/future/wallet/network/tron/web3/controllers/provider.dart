import 'package:blockchain_utils/bip/address/trx_addr.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/crypto/worker.dart';
import 'package:stealth_stash/future/wallet/network/ethereum/web3/controllers/provider.dart';
import 'package:stealth_stash/future/wallet/network/tron/web3/types/types.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/wallet/web3/constant/constant/exception.dart';

mixin TronWeb3TransactionApiController
    on CryptoWokerImpl, DisposableMixin, SolidityWeb3TransactionApiController {
  TronClient get client;
  @override
  EthereumClient get solidityClient => client.solidityProvider;
  Future<Web3TronTransferInfo> _getWeb3TransferContractInfo({
    required TransferContract contract,
    required TronChain chain,
  }) async {
    final destinationAddress = contract.toAddress.toAddress();
    return Web3TronTransferInfo(
        receiptAddress: chain.getReceiptAddress(destinationAddress) ??
            ReceiptAddress(
                view: destinationAddress, networkAddress: contract.toAddress),
        amount: contract.amount,
        network: chain.network);
  }

  Future<Web3TronTransferAssetInfo> _getWeb3TransferAssetContractInfo(
      {required TransferAssetContract contract,
      required TronChain chain}) async {
    final destinationAddress = contract.toAddress.toAddress();
    final TronTRC10Token? token = await client.getIssueById(contract.assestId,
        account: contract.ownerAddress);
    if (token == null) {
      throw Web3RequestExceptionConst.invalidTransaction;
    }
    return Web3TronTransferAssetInfo(
        token: token,
        receiptAddress: chain.getReceiptAddress(destinationAddress) ??
            ReceiptAddress(
                view: destinationAddress, networkAddress: contract.toAddress),
        amount: contract.amount);
  }

  Future<Web3TronTriggerSmartContract> _getWeb3TriggerSmartContract(
      {required TriggerSmartContract contract,
      required TronChain chain}) async {
    Web3TronTransferInfo? transfer;
    Web3TronTransferAssetInfo? transferAssets;
    if (contract.callValue != null) {
      transfer = await _getWeb3TransferContractInfo(
          contract: TransferContract(
              ownerAddress: contract.ownerAddress,
              toAddress: contract.contractAddress,
              amount: contract.callValue!),
          chain: chain);
    }
    if (contract.callTokenValue != null) {
      transferAssets = await _getWeb3TransferAssetContractInfo(
          chain: chain,
          contract: TransferAssetContract(
              assetName: StringUtils.encode(contract.tokenId!.toString()),
              ownerAddress: contract.ownerAddress,
              toAddress: contract.contractAddress,
              amount: contract.callTokenValue!));
    }
    final data = await getTransactionContractInfo(
        account: contract.ownerAddress,
        contractAddress: contract.contractAddress,
        chain: chain,
        data: contract.data ?? []);
    final contractAddress = contract.contractAddress;
    return Web3TronTriggerSmartContract(
        value: transfer,
        callValue: transferAssets,
        contractAddress: chain.getReceiptAddress(contractAddress.toAddress()) ??
            ReceiptAddress(
                view: contractAddress.toAddress(),
                networkAddress: contractAddress),
        dataInfo: data);
  }

  Future<Web3TronCreateContractInfo> _getWeb3CreateSmartContract(
      {required CreateSmartContract contract,
      required TronChain chain,
      required String txId}) async {
    Web3TronTransferInfo? transfer;
    Web3TronTransferAssetInfo? transferAssets;
    if (contract.newContract.callValue != null) {
      transfer = await _getWeb3TransferContractInfo(
          contract: TransferContract(
              ownerAddress: contract.ownerAddress,
              toAddress: contract.newContract.contractAddress ??
                  contract.newContract.originAddress,
              amount: contract.newContract.callValue!),
          chain: chain);
    }
    if (contract.hasTokenTransfer) {
      transferAssets = await _getWeb3TransferAssetContractInfo(
          chain: chain,
          contract: TransferAssetContract(
              assetName: StringUtils.encode(contract.tokenId!.toString()),
              ownerAddress: contract.ownerAddress,
              toAddress: contract.newContract.contractAddress ??
                  contract.newContract.originAddress,
              amount: contract.callTokenValue!));
    }
    final contractAddressHash = await crypto
        .generateHash(type: CryptoRequestHashingType.keccack256, dataBytes: [
      ...BytesUtils.fromHexString(txId),
      ...contract.ownerAddress.toBytes(),
    ]);

    return Web3TronCreateContractInfo(
        value: transfer,
        callValue: transferAssets,
        contractAddress: TronAddress.fromBytes([
          ...TrxAddressUtils.prefix,
          ...contractAddressHash.sublist(0, ETHAddress.lengthInBytes)
        ]));
  }

  Future<Web3TronTransactionInfo> getWeb3TransactionInfo(
      {required TransactionRaw transaction, required TronChain chain}) async {
    final type = transaction.type;
    switch (type) {
      case TransactionContractType.transferContract:
        final contract = transaction.getContract<TransferContract>();
        return _getWeb3TransferContractInfo(contract: contract, chain: chain);
      case TransactionContractType.transferAssetContract:
        final contract = transaction.getContract<TransferAssetContract>();
        return _getWeb3TransferAssetContractInfo(
            contract: contract, chain: chain);
      case TransactionContractType.triggerSmartContract:
        final contract = transaction.getContract<TriggerSmartContract>();
        return _getWeb3TriggerSmartContract(contract: contract, chain: chain);
      case TransactionContractType.createSmartContract:
        final contract = transaction.getContract<CreateSmartContract>();
        return _getWeb3CreateSmartContract(
            contract: contract, chain: chain, txId: transaction.txID);
      case TransactionContractType.freezeBalanceV2Contract:
        final contract = transaction.getContract<FreezeBalanceV2Contract>();
        return Web3TronFreezeBalanceInfo(
            resource: contract.resource ?? ResourceCode.bandWidth,
            amount: contract.frozenBalance,
            network: chain.network);
      default:
        final contract = transaction.getContract();
        final totalTrxAmount = contract.trxAmount == BigInt.zero
            ? null
            : IntegerBalance.token(contract.trxAmount, chain.network.token);
        return Web3TronUnknowContractInfo(
            contractFields: contract.toJson(),
            totalTrxAmount: totalTrxAmount,
            type: contract.contractType);
    }
  }
}
