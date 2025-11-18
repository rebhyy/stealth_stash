import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/cardano/web3/operations/get_collateral.dart';
import 'package:stealth_stash/future/wallet/network/cardano/web3/pages/select_collateral_utxos.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/wallet/web3/pages/web3_request_page_builder.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class Web3CardanoGetCollateralStateView extends StatelessWidget {
  final Web3ADGetCollateralStateController form;
  const Web3CardanoGetCollateralStateView({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidget(
        field: form.totalUtxos,
        builder: (context, field, value) {
          return ContainerWithBorder(
            onRemove: () {
              context.openDialogPage(
                  child: (context) => ADASelectCollateralUtxos(form), "");
            },
            onRemoveIcon: AddOrEditIconWidget(form.hasUtxos),
            validate: form.hasUtxos,
            child: ConditionalWidget(
              onDeactive: (context) => Text("tap_to_choose_utxos".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
              enable: form.hasUtxos,
              onActive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CoinAndMarketPriceView(
                        balance: form.totalUtxos.value,
                        symbolColor: context.onPrimaryContainer,
                        showTokenImage: true,
                        style: context.onPrimaryTextTheme.titleMedium)
                  ]),
            ),
          );
        },
      ),
      Web3StateAcceptRequestView(controller: form, title: "submit".tr),
    ]);
  }
}
