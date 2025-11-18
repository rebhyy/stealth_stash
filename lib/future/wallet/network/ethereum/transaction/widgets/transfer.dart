import 'package:flutter/material.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/ethereum/transaction/operations/transfer.dart';
import 'package:stealth_stash/future/wallet/network/ethereum/transaction/widgets/select_fee.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';

class EthereumTransactionTransferWidget extends StatelessWidget {
  final EthereumTransactionTransferOperation form;
  const EthereumTransactionTransferWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateAddress,
          field: form.receipt,
          onFilterAccount: form.filterAccount,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetAmount(
          field: form.amount,
          onUpdateAmount: form.onUpdateAmount,
          onUpdateAmountMax: () => form.getMaxInput()),
      WidgetConstant.height20,
      LiveFormWidgetMemo(
          field: form.memo,
          onUpdateMemo: form.onUpdateMemo,
          onRemoveMemo: form.onRemoveMemo),
      WidgetConstant.height20,
      TransactionFeeView(
          onTapManual: () {
            context.openSliverBottomSheet("transaction_fee".tr,
                child: EthereumGasOptionsView(fee: form.txFee));
          },
          onRetryFeeEstimate: form.estimateFee,
          controller: form),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
