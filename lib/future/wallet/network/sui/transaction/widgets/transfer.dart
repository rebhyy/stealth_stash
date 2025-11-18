import 'package:flutter/material.dart';
import 'package:on_chain/sui/sui.dart';
import 'package:stealth_stash/future/wallet/network/sui/transaction/operations/transfer.dart';
import 'package:stealth_stash/future/wallet/network/sui/web3/types/types.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class SuiTransactionTransferWidget extends StatelessWidget {
  final SuiTransactionTransferOperation form;
  const SuiTransactionTransferWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetList(
        field: form.recipients,
        onCreate: (context, field) =>
            LiveWidgetAddNewTransferDetails<SuiAddress>(
                onUpdateAddresses: form.onUpdateRecipients,
                account: form.account,
                isReady: field.hasValue,
                onFilterAccount: form.filterAccount,
                multipleSelect: true),
        builder: (context, field, value) =>
            LiveWidgetTransferDetails<SuiTransferDetails>(
                transfer: value,
                onRemove: form.onRemoveRecipient,
                onUpdateAmount: form.onUpdateAmount,
                onUpdateAmountMax: form.getMaxInput),
      ),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
