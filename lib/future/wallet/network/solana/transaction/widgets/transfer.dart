import 'package:flutter/material.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/transfer.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/types/types.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class SolanaTransactionTransferWidget extends StatelessWidget {
  final SolanaTransactionTransferOperation form;
  const SolanaTransactionTransferWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetList(
        field: form.recipients,
        onCreate: (context, field) =>
            LiveWidgetAddNewTransferDetails<SolAddress>(
                onUpdateAddresses: form.onUpdateRecipients,
                account: form.account,
                isReady: field.hasValue,
                onFilterAccount: form.filterAccount,
                multipleSelect: true),
        builder: (context, field, value) =>
            LiveWidgetTransferDetails<SolanaTransferDetails>(
                transfer: value,
                onValidateTransfer: (p0) => !p0.hasError,
                onRemove: form.onRemoveRecipients,
                onUpdateAmount: form.onUpdateAmount,
                onUpdateAmountMax: form.getMaxInput),
      ),
      WidgetConstant.height20,
      LiveFormWidgetMemo(
        field: form.memo,
        onUpdateMemo: form.onUpdateMemo,
        onRemoveMemo: form.onRemoveMemo,
      ),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
