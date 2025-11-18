import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/cardano/web3/operations/get_account_pub.dart';
import 'package:stealth_stash/future/wallet/web3/pages/web3_request_page_builder.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class Web3CardanoGetAccoutPubKeyStateView extends StatelessWidget {
  final Web3ADAGetAccountPubKeyStateController form;
  const Web3CardanoGetAccoutPubKeyStateView({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      AlertTextContainer(
          message: "web3_ada_bip32_public_key_request_desc".tr,
          enableTap: false),
      Web3StateAcceptRequestView(controller: form, title: "submit".tr),
    ]);
  }
}
