import 'package:flutter/material.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/future/wallet/network/ethereum/network/import/controller/controller.dart';
import 'package:stealth_stash/future/wallet/network/ethereum/web3/pages/import_network.dart';
import 'package:stealth_stash/future/wallet/network/ethereum/web3/types/types.dart';
import 'package:stealth_stash/future/wallet/web3/core/state.dart';
import 'package:stealth_stash/wallet/api/api.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/network/core/network/network.dart';
import 'package:stealth_stash/wallet/web3/networks/ethereum/params/models/add_eth_chain.dart';

class Web3EthereumImportNetworkStateController
    extends Web3EthereumStateController<String, EthereumClient?,
        Web3EthereumAddNewChain> {
  final form = EthereumAddNewChainFrom();
  Web3EthereumImportNetworkStateController(
      {required super.walletProvider, required super.request});

  void importNetwork({BuildContext? context}) {
    final ready = form.isReady();
    if (!ready) return;
    acceptRequest(context: context);
  }

  @override
  Future<Web3RequestResponseData<String>> getResponse() async {
    final result = await MethodUtils.call(() async {
      final params = await form.buildNetwork();
      final newNetwork = WalletEthereumNetwork(-1, params!.$1);
      await walletProvider.wallet
          .importNewNetwork(network: newNetwork, providers: [params.$2]);
      return Web3RequestResponseData<String>(
          response: newNetwork.coinParam.chainId.toRadix16);
    });
    if (result.hasError) {
      throw AppException(result.message!);
    }
    return result.result;
  }

  @override
  Future<void> initForm(EthereumClient? client) async {
    await super.initForm(client);
    final ethChains = walletProvider.wallet.getChains<EthereumChain>();
    final existsChainIds = ethChains.map((e) => e.chainId).toList();
    form.initForm(
        existsChainIds: existsChainIds,
        chainId: params.newChainId,
        blockExplorerUrls: params.blockExplorerUrls,
        iconUrls: params.iconUrls,
        name: params.name,
        networkName: params.chainName,
        rpcUrls: params.rpcUrls,
        symbol: params.symbol);
  }

  @override
  Widget widgetBuilder(BuildContext context) {
    return Web3EthereumImportNetworkStateView(this);
  }

  @override
  void dispose() {
    super.dispose();
    form.dispose();
  }
}
