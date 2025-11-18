import 'package:flutter/material.dart';
import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/transaction/types/types.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class TransactionStateAlert extends StatelessWidget {
  final StreamValue<TransactionStateStatus?> status;
  const TransactionStateAlert({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return APPStreamBuilder(
        value: status,
        builder: (context, value) => ErrorTextContainer(error: value?.error));
  }
}
