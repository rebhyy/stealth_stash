import 'package:flutter/material.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/cosmos/web3/operations/import_network.dart';

class Web3CosmosImportNetworkStateView extends StatelessWidget {
  final Web3CosmosImportNetworkStateController controller;
  const Web3CosmosImportNetworkStateView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      APPStreamBuilder(
          value: controller.form.notifier,
          builder: (context, value) =>
              CosmosImportNetworkFieldsView(form: controller.form)),
      Web3StateAcceptRequestView(
          controller: controller, title: "import_network".tr),
    ]);
  }
}
