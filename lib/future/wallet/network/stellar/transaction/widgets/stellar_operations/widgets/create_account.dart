import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/network/stellar/transaction/types/operations.dart';
import 'package:stealth_stash/future/wallet/network/stellar/transaction/widgets/widgets/live_widgets.dart';
import 'package:stealth_stash/future/wallet/transaction/pages/live_form_widget.dart';
import 'package:stealth_stash/future/widgets/widgets/widget_constant.dart';

class StellarTransactionCreateAccountOperationWidget extends StatelessWidget {
  final StellarCreateAccountOperationForm form;
  const StellarTransactionCreateAccountOperationWidget(
      {required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      LiveFormWidgetStellarAddressWithActivity(
        field: form.destination,
        account: form.controller.account,
        onUpdateAddress: form.onUpdateDestination,
      ),
      WidgetConstant.height20,
      LiveFormWidgetAmount(
          onUpdateAmount: (amount, max) => form.onUpdateStartingBalance(amount),
          field: form.startingBalance,
          onUpdateAmountMin: form.getMinInput,
          onUpdateAmountMax: form.getMaxInput),
    ]);
  }
}
