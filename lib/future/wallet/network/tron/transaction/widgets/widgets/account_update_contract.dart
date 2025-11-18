import 'package:flutter/material.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/future/wallet/network/tron/transaction/operations/account/account_update_contract.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'fee.dart';

class TronTransactionAccountUpdateContractWidget extends StatelessWidget {
  final TronTransactionAccountUpdateContractOperation form;
  const TronTransactionAccountUpdateContractWidget(
      {required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetString(
          onUpdateValue: form.onUpdateAccountName,
          field: form.accountName,
          title: PageTitleSubtitle(
              title: "account_name".tr, body: Text("account_name_desc".tr)),
          fieldName: "update_account".tr),
      WidgetConstant.height20,
      LiveFormWidgetMemo(field: form.memo, onUpdateMemo: form.onUpdateMemo),
      WidgetConstant.height20,
      TronTransactionFeeDataView(controller: form),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
