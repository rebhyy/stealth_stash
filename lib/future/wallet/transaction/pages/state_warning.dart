import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/widgets/widgets/alarm.dart';
import 'package:stealth_stash/future/widgets/widgets/dialog_view.dart';
import 'package:stealth_stash/future/widgets/widgets/widget_constant.dart';

class TransactionStateWarningView extends StatelessWidget {
  const TransactionStateWarningView({super.key, required this.warning});
  final String warning;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_state_warning_desc".tr),
        WidgetConstant.height8,
        AlertTextContainer(message: warning, enableTap: false),
        DialogDoubleButtonView()
      ],
    );
  }
}
