import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/monero/transaction/controllers/utxos.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class MoneroTransactionSelectUtxos extends StatelessWidget {
  final MoneroTransactionUtxosController form;
  const MoneroTransactionSelectUtxos(this.form, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text("choose_utxos".tr),
          actions: [
            APPStreamBuilder(
              value: form.accountUtxos,
              builder: (context, value) {
                return TextButton.icon(
                  onPressed: () => form.onToggleAllUtxos(
                    () {
                      context.showAlert("transaction_input_exceeds_16_desc".tr);
                    },
                  ),
                  label: Text("choose_all".tr),
                  icon: APPAnimated(
                      isActive: form.allUtxosSelected,
                      onActive: (context) => Icon(Icons.check_box),
                      onDeactive: (context) =>
                          Icon(Icons.check_box_outline_blank_outlined)),
                );
              },
            )
          ],
        ),
        SliverConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            sliver: APPStreamBuilder(
              value: form.accountUtxos,
              builder: (context, addresses) {
                return SliverList.separated(
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemBuilder: (context, index) {
                      final addressUtxos = addresses[index];
                      return APPStreamBuilder(
                        value: addressUtxos.notifier,
                        builder: (context, value) => APPExpansionListTile(
                          title: Row(
                            children: [
                              Expanded(
                                  child: AddressDetailsView(
                                      address: addressUtxos.address)),
                              ConditionalWidget(
                                  enable: addressUtxos.allSelected ||
                                      addressUtxos.totalSelected == 0,
                                  onDeactive: (context) {
                                    return IconButton(
                                        onPressed: () {},
                                        icon: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.check_box_outline_blank),
                                            Text(addressUtxos.totalSelected
                                                .toString()),
                                          ],
                                        ));
                                  },
                                  onActive: (context) {
                                    return APPCheckBox(
                                        onChanged: (v) {
                                          form.onToggleAddressUtxos(
                                              addressUtxos, () {
                                            context.showAlert(
                                                "transaction_input_exceeds_16_desc"
                                                    .tr);
                                          });
                                        },
                                        value: addressUtxos.allSelected,
                                        backgroundColor:
                                            context.colors.onPrimaryContainer,
                                        color: context.colors.primaryContainer);
                                  })
                            ],
                          ),
                          children: [
                            ConditionalWidget(onActive: (context) {
                              final utxoData = addressUtxos.utxos.utxos;
                              return ListView(
                                shrinkWrap: true,
                                physics: WidgetConstant.noScrollPhysics,
                                children: List.generate(utxoData.length, (pos) {
                                  final utxo = utxoData[pos];
                                  final bool canSpent = !utxo.output.needUpdate;
                                  final bool inPool = utxo.output.status.inPool;
                                  return ContainerWithBorder(
                                    validate: canSpent,
                                    validateText: inPool
                                        ? "spent_in_pool".tr
                                        : 'monero_utxo_lake_of_confirmatins_desc'
                                            .tr,
                                    onRemove: canSpent
                                        ? () {
                                            form.onUpdateUtxo(
                                                addressUtxos, utxo, () {
                                              context.showAlert(
                                                  "transaction_input_exceeds_16_desc"
                                                      .tr);
                                            });
                                          }
                                        : null,
                                    onRemoveWidget: APPCheckBox(
                                        value: addressUtxos.isSelected(utxo),
                                        backgroundColor:
                                            context.primaryContainer,
                                        color: context.onPrimaryContainer),
                                    backgroundColor: context.onPrimaryContainer,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        OneLineTextWidget(utxo.output.txId,
                                            style: context
                                                .primaryTextTheme.bodyMedium),
                                        CoinPriceView(
                                            balance: utxo.amount,
                                            style: context
                                                .primaryTextTheme.titleMedium,
                                            symbolColor:
                                                context.primaryContainer)
                                      ],
                                    ),
                                  );
                                }),
                              );
                            })
                          ],
                        ),
                      );
                    },
                    itemCount: addresses.length);
              },
            ))
      ],
    );
  }
}
