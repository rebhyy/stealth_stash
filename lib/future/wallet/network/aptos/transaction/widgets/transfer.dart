import 'package:flutter/material.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/wallet/models/networks/aptos/aptos.dart';

class AptosTransactionTransferWidget extends StatelessWidget {
  final AptosTransactionTransferOperation form;
  const AptosTransactionTransferWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetList(
        field: form.recipients,
        onCreate: (context, field) =>
            LiveWidgetAddNewTransferDetails<AptosAddress>(
                onUpdateAddresses: form.onUpdateRecipients,
                account: form.account,
                isReady: field.hasValue,
                onFilterAccount: form.filterAccount,
                multipleSelect: true),
        builder: (context, field, value) {
          return LiveWidgetTransferDetails<AptosTransferDetails>(
              transfer: value,
              onRemove: form.onRemoveRecipient,
              onUpdateAmount: form.onUpdateAmount,
              onUpdateAmountMax: form.getMaxInput);
        },
      ),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
