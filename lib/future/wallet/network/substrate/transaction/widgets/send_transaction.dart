import 'package:flutter/material.dart';
import 'package:stealth_stash/future/router/page_router.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/substrate/multisig/pending_multisig_txes.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/controllers/controller.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/types/types.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/models/models.dart';

class SubstrateTransactionStateSendTransaction<
    T extends ISubstrateTransactionData> extends StatelessWidget {
  final SubstrateTransactionStateController<T> controller;
  final BuildContext mainContext;
  const SubstrateTransactionStateSendTransaction(
      {super.key, required this.controller, required this.mainContext});

  @override
  Widget build(BuildContext context) {
    return APPStreamBuilder(
        value: controller.stateStatus,
        builder: (context, value) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ErrorTextContainer(error: value.error, enableTap: false),
                AlertTextContainer(message: value.warning, enableTap: false),
                Padding(
                  padding: WidgetConstant.paddingVertical40,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FixedElevatedButton(
                            onPressed: () => controller.signAndSendTransaction(
                                  context: context,
                                  onTransactionCreated: (tranasction) async {
                                    if (tranasction.account.multiSigAccount) {
                                      mainContext.to(
                                          PageRouter
                                              .substrateMultisigTransaction,
                                          argruments:
                                              SubstrateMultisigAddressTxesRouteArgument(
                                                  account: controller.account,
                                                  address: controller
                                                      .address
                                                      .cast(),
                                                  controller: controller
                                                      .pageKey,
                                                  call: SubstrateMultisigCall(
                                                      callHash: tranasction
                                                          .payload.callHash,
                                                      callData: tranasction
                                                          .payload
                                                          .methodBytes)));

                                      return null;
                                    }
                                    return tranasction;
                                  },
                                  onTransactionSigned: (tranasction) async {
                                    return tranasction;
                                  },
                                ),
                            activePress: value.isReady,
                            child: ConditionalWidget(
                              enable: controller.address.multiSigAccount,
                              onDeactive: (context) =>
                                  Text("send_transaction".tr),
                              onActive: (context) =>
                                  Text("aprrove_transaction".tr),
                            ))
                      ]),
                )
              ]);
        });
  }
}
