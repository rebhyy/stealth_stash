import 'package:flutter/material.dart';
import 'package:stealth_stash/app/error/exception/app_exception.dart';
import 'package:stealth_stash/future/wallet/network/cosmos/network/import/controller/form.dart';
import 'package:stealth_stash/future/wallet/network/cosmos/web3/pages/import_network.dart';
import 'package:stealth_stash/future/wallet/network/cosmos/web3/types/types.dart';
import 'package:stealth_stash/future/wallet/web3/core/state.dart';
import 'package:stealth_stash/wallet/api/api.dart';
import 'package:stealth_stash/wallet/models/network/core/network/network.dart';
import 'package:stealth_stash/wallet/web3/networks/cosmos/params/models/add_new_chain.dart';

class Web3CosmosImportNetworkStateController extends Web3CosmosStateController<
    bool, CosmosClient?, Web3CosmosAddNewChain> {
  final form = CosmosAddNewChainFrom();
  Web3CosmosImportNetworkStateController(
      {required super.walletProvider, required super.request});

  @override
  Future<Web3RequestResponseData<bool>> getResponse() async {
    final networkParams = await form.createNetwork();
    if (networkParams == null) {
      throw AppException("some_required_field_not_filled");
    }
    final newNetwork = WalletCosmosNetwork(-1, networkParams.$1);
    await walletProvider.wallet
        .importNewNetwork(network: newNetwork, providers: [networkParams.$2]);
    return Web3RequestResponseData(response: true);
  }

  @override
  Widget widgetBuilder(BuildContext context) {
    return Web3CosmosImportNetworkStateView(this);
  }

  @override
  Future<void> initForm(CosmosClient? client) async {
    await super.initForm(client);
    await form.initForm();
    form.buildFromWeb3Request(
        chainId: params.chainId,
        rpc: params.rpc,
        feeTokens: params.feeTokens,
        nativeToken: params.nativeToken,
        name: params.name);
  }

  @override
  void dispose() {
    super.dispose();
    form.dispose();
  }
}
