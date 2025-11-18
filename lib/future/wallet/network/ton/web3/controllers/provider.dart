import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/app/utils/utils.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';

mixin TonWeb3TransactionApiController on DisposableMixin {
  TonClient get client;

  Future<TonWeb3TransactionMessageInfo> getWeb3TransactionMessageInfo(
      {required ITonAddress address,
      required TonChain account,
      required Web3TonTransactionMessage message}) async {
    final destination =
        account.getReceiptAddress(message.address.toFriendlyAddress()) ??
            ReceiptAddress<TonAddress>(
                view: message.address.toFriendlyAddress(),
                networkAddress: message.address);
    final StateInit? init = message.stateInit == null
        ? null
        : StateInit.deserialize(message.stateInit!.beginParse());
    if (message.payload == null) {
      return TonWeb3TransactionMessageInfo(
          amount: message.amount,
          destination: destination,
          initState: init,
          network: account.network);
    }
    final info = TonWeb3TransactionPayload.fromPayload(
        payload: message.payload!, destination: message.address);
    switch (info.type) {
      case TonWeb3TransactionPayloadType.transfer:
      case TonWeb3TransactionPayloadType.jetton:
        break;
      default:
        return TonWeb3TransactionMessageInfo(
            amount: message.amount,
            destination: destination,
            payload: info,
            initState: init,
            network: account.network);
    }

    final jettonInfo = await MethodUtils.call(() async {
      final tokenInfo = await client.getJettonWalletData(message.address);

      TonJettonToken? jetton = address.tokens
          .firstWhereOrNull((e) => e.walletAddress == message.address);

      bool? isAccountJetton = jetton == null ? null : true;
      if (jetton == null) {
        final balance = await MethodUtils.call(
            () async => await client.getJettonBalance(message.address));
        jetton = await client.getJettonInfo(TonAccountJettonResponse(
            tokenAddress: tokenInfo.minterAddress,
            balance: balance.resultOrNull ?? BigInt.zero,
            owner: address.networkAddress,
            jettonWalletAddress: message.address));
        final jettonWalletAddress = await MethodUtils.call(() async =>
            await client.getJettonWalletAddress(
                minterAddress: jetton!.minterAddress,
                owner: address.networkAddress));
        if (jettonWalletAddress.hasResult &&
            jettonWalletAddress.result == message.address) {
          isAccountJetton = true;
        }
      }
      // updateJettonBalance(jetton);
      return (jetton, isAccountJetton);
    });
    if (jettonInfo.hasError) {
      return TonWeb3TransactionMessageInfo(
          amount: message.amount,
          destination: destination,
          initState: init,
          payload: info,
          network: account.network);
    }
    final contractInfo = info as ContractTonTransactionPayload;
    BigInt? transfer;
    if (info.type == TonWeb3TransactionPayloadType.transfer) {
      transfer = info.jettonAmount;
    }
    final TonWeb3TransactionPayload payload =
        JettonContractTonTransactionPayload(
            payload: info.payload,
            content: contractInfo.contentJson,
            token: jettonInfo.result.$1,
            isAccountJetton: jettonInfo.result.$2,
            transferAmount: transfer,
            type: transfer != null
                ? TonWeb3TransactionPayloadType.transfer
                : TonWeb3TransactionPayloadType.jetton,
            operation: info.operation,
            tonAmount: info.tonAmount);
    return TonWeb3TransactionMessageInfo(
        amount: message.amount,
        destination: destination,
        initState: init,
        payload: payload,
        network: account.network);
  }
}
