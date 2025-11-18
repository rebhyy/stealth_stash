import 'package:flutter/material.dart';
import 'package:on_chain/on_chain.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/mint_to.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class SolanaTransactionMintToWidget extends StatelessWidget {
  final SolanaTransactionMintToOperation form;
  const SolanaTransactionMintToWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateProgramId,
          field: form.programId,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.mint,
        builder: (context, field, value) {
          return Shimmer(
              onActive: (_, context) {
                return ContainerWithBorder(
                  validate: value != null && value.status.isSuccess,
                  validateText: value?.error,
                  enableTap: false,
                  onRemoveWidget: Row(children: [
                    if (value?.status.isError ?? false)
                      IconButton(
                          onPressed: form.getMintTokenData,
                          icon: Icon(Icons.refresh,
                              color: context.onPrimaryContainer)),
                    IconButton(
                        onPressed: () {
                          context
                              .selectAccount<SolAddress>(account: form.account)
                              .then(
                            (value) {
                              final address = value?.firstOrNull;
                              if (address == null) return;
                              form.onUpdateMint(address);
                            },
                          );
                        },
                        icon: Icon(Icons.edit,
                            color: context.onPrimaryContainer)),
                  ]),
                  onRemove: () {},
                  child: ConditionalWidget(
                      enable: value != null,
                      onDeactive: (context) => Text("tap_to_choose_address".tr,
                          style: context.onPrimaryTextTheme.bodyMedium),
                      onActive: (context) => Row(
                            children: [
                              Expanded(
                                  child: ReceiptAddressDetailsView(
                                address: value!.value,
                                color: context.onPrimaryContainer,
                              )),
                              CopyTextIcon(
                                  dataToCopy: value.value.view,
                                  color: context.onPrimaryContainer,
                                  isSensitive: false)
                            ],
                          )),
                );
              },
              enable: !(value?.status.isPending ?? false));
        },
      ),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateAuthority,
          field: form.authority,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateDestination,
          field: form.destination,
          account: form.account),
      APPStreamBuilder(
          value: form.mint.live,
          builder: (context, value) => APPAnimated(
              onActive: (context) => ConditionalWidget(
                  key: ValueKey(value),
                  enable: value?.token != null,
                  onActive: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetConstant.height20,
                          LiveFormWidgetAmount(
                              onUpdateAmount: (amount, max) =>
                                  form.onUpdateAmount(amount),
                              onTap: () {
                                final token = value?.token;
                                if (token == null) {
                                  context
                                      .showAlert("mint_account_not_found".tr);
                                  return;
                                }
                                context.setupAmount(token: token).then((v) {
                                  if (v == null) return;
                                  form.onUpdateAmount(v);
                                });
                              },
                              field: form.amount),
                        ],
                      )))),
      WidgetConstant.height20,
      LiveFormWidgetMemo(field: form.memo, onUpdateMemo: form.onUpdateMemo),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
