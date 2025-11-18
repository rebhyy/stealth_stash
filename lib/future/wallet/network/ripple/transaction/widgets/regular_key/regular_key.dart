import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/operations/regular_key/regular_key.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/widgets/memo/memo.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class RippleTransactionSetRegularKeyWidget extends StatelessWidget {
  final RippleTransactionSetRegularKeyOperation form;
  const RippleTransactionSetRegularKeyWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetReceiverAddress(
          field: form.regularKey,
          account: form.account,
          removable: true,
          onUpdateAddress: form.onUpdateRegularKey),
      WidgetConstant.height20,
      RippleTransactionMemoWidget(controller: form),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
