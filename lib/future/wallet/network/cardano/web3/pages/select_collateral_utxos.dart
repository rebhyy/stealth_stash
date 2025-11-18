import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/wallet/network/cardano/transaction/controllers/utxos.dart';
import 'package:stealth_stash/future/wallet/network/cardano/transaction/types/types.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/constant/networks/cardano.dart';

class ADASelectCollateralUtxos extends StatelessWidget {
  final ADATransactionUtxosController form;
  const ADASelectCollateralUtxos(this.form, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text("choose_utxos".tr),
        ),
        SliverConstraintsBoxView(
          padding: WidgetConstant.padding20,
          sliver: APPStreamBuilder(
            value: form.accountUtxos,
            builder: (context, addresses) {
              return MultiSliver(
                children: [
                  SliverToBoxAdapter(
                      child: AlertTextContainer(
                          message: "select_collateral_utxos_desc".tr)),
                  SliverList.separated(
                      separatorBuilder: (context, index) =>
                          WidgetConstant.divider,
                      itemBuilder: (context, index) {
                        final addressUtxos = addresses[index];
                        return APPStreamBuilder(
                          value: addressUtxos.notifier,
                          builder: (context, value) => Shimmer(
                              onActive:
                                  (enable, context) => APPExpansionListTile(
                                        trailing: switch (addressUtxos.status) {
                                          ADAAccountUtxosStatus.success ||
                                          ADAAccountUtxosStatus.pending =>
                                            null,
                                          ADAAccountUtxosStatus.failed =>
                                            IconButton(
                                                onPressed: () {
                                                  form.getAccountsUtxos(
                                                      accountUtxos: [
                                                        addressUtxos
                                                      ]);
                                                },
                                                icon: Icon(Icons.error)),
                                        },
                                        title: Row(
                                          children: [
                                            Expanded(
                                                child: AddressDetailsView(
                                                    address:
                                                        addressUtxos.address,
                                                    showBalance: true)),
                                            ConditionalWidget(
                                              enable: addressUtxos.isSuccess,
                                              onActive: (context) =>
                                                  ConditionalWidget(
                                                      enable: addressUtxos
                                                              .allSelected ||
                                                          addressUtxos
                                                                  .totalSelected ==
                                                              0,
                                                      onDeactive: (context) {
                                                        return IconButton(
                                                            onPressed: () {},
                                                            icon: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Icon(Icons
                                                                    .check_box_outline_blank),
                                                                Text(addressUtxos
                                                                    .totalSelected
                                                                    .toString()),
                                                              ],
                                                            ));
                                                      },
                                                      onActive: (context) =>
                                                          WidgetConstant
                                                              .sizedBox),
                                            )
                                          ],
                                        ),
                                        children: [
                                          ConditionalWidget(
                                              enable: addressUtxos.isSuccess,
                                              onActive: (context) {
                                                final utxoData =
                                                    addressUtxos.utxos!;
                                                return ListView(
                                                  shrinkWrap: true,
                                                  physics: WidgetConstant
                                                      .noScrollPhysics,
                                                  children: List.generate(
                                                      utxoData.length, (pos) {
                                                    final utxo = utxoData[pos];
                                                    final bool
                                                        isToHighForCollateral =
                                                        utxo.utxoBalance
                                                                .balance >
                                                            CardanoConst
                                                                .maxCollateralLoveLace;
                                                    return IgnorePointer(
                                                      ignoring: utxo.haveAssets,
                                                      child:
                                                          ContainerWithBorder(
                                                        validate:
                                                            !utxo.haveAssets,
                                                        validateText: utxo
                                                                .haveAssets
                                                            ? "ada_multi_asset_utxo_not_allowed_for_collateral"
                                                                .tr
                                                            : "ada_min_collateral_amount_desc"
                                                                .tr,
                                                        onRemove: () {
                                                          form.onUpdateUtxo(
                                                              addressUtxos,
                                                              utxo);
                                                        },
                                                        onRemoveWidget:
                                                            APPCheckBox(
                                                          value: addressUtxos
                                                              .isSelected(utxo),
                                                          backgroundColor: context
                                                              .primaryContainer,
                                                          color: context
                                                              .onPrimaryContainer,
                                                        ),
                                                        backgroundColor: context
                                                            .onPrimaryContainer,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            OneLineTextWidget(
                                                                utxo.utxo.input
                                                                    .txIdHex,
                                                                style: context
                                                                    .primaryTextTheme
                                                                    .bodyMedium),
                                                            CoinPriceView(
                                                                balance: utxo
                                                                    .utxoBalance,
                                                                style: context
                                                                    .primaryTextTheme
                                                                    .titleMedium,
                                                                symbolColor: context
                                                                    .primaryContainer),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  ConditionalWidget(
                                                                      enable: utxo
                                                                          .haveAssets,
                                                                      onActive: (context) => TappedTooltipView(
                                                                          tooltipWidget: ToolTipView(
                                                                              message: 'assets'.tr,
                                                                              child: Icon(Icons.token, color: context.primaryContainer)))),
                                                                  ConditionalWidget(
                                                                      enable: utxo
                                                                          .hasScript,
                                                                      onActive: (context) => TappedTooltipView(
                                                                          tooltipWidget: ToolTipView(
                                                                              message: 'script'.tr,
                                                                              child: Icon(Icons.code, color: context.primaryContainer)))),
                                                                  ConditionalWidget(
                                                                      enable: utxo
                                                                          .hasReferenceScript,
                                                                      onActive: (context) => TappedTooltipView(
                                                                          tooltipWidget: ToolTipView(
                                                                              message: 'reference_script'.tr,
                                                                              child: Icon(Icons.code, color: context.primaryContainer)))),
                                                                ]),
                                                            AlertTextContainer(
                                                                message:
                                                                    isToHighForCollateral
                                                                        ? "ada_max_collateral_amount_desc"
                                                                            .tr
                                                                        : null)
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                );
                                              })
                                        ],
                                      ),
                              enable: !addressUtxos.isPending),
                        );
                      },
                      itemCount: addresses.length),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
