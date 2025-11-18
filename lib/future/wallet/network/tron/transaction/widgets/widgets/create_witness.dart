import 'package:flutter/material.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/future/wallet/network/tron/transaction/operations/vote/create_witness.dart';
import 'package:stealth_stash/future/wallet/network/tron/transaction/operations/vote/update_witness.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'fee.dart';

class TronTransactionWitnessCreateContractWidget extends StatelessWidget {
  final TronTransactionWitnessCreateContractOperation form;
  const TronTransactionWitnessCreateContractWidget(
      {required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetString(
          onUpdateValue: form.onUpdateUrl,
          field: form.url,
          title: PageTitleSubtitle(
              title: "url".tr, body: Text("tron_create_witness_url_desc".tr)),
          fieldName: "create_witness".tr),
      WidgetConstant.height20,
      LiveFormWidgetMemo(field: form.memo, onUpdateMemo: form.onUpdateMemo),
      WidgetConstant.height20,
      TronTransactionFeeDataView(controller: form),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}

class TronTransactionWitnessUpdateContractWidget extends StatelessWidget {
  final TronTransactionWitnessUpdateContractOperation form;
  const TronTransactionWitnessUpdateContractWidget(
      {required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetString(
          onUpdateValue: form.onUpdateUrl,
          field: form.url,
          title: PageTitleSubtitle(
              title: "url".tr, body: Text("tron_create_witness_url_desc".tr)),
          fieldName: "create_witness".tr),
      WidgetConstant.height20,
      LiveFormWidgetMemo(field: form.memo, onUpdateMemo: form.onUpdateMemo),
      WidgetConstant.height20,
      TronTransactionFeeDataView(controller: form),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
