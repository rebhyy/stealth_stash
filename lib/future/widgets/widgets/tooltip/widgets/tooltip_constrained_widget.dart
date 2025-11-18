import 'package:flutter/material.dart';
import 'package:stealth_stash/app/core.dart';

class TooltipConstrainsWidget extends StatelessWidget {
  const TooltipConstrainsWidget({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: APPConst.tooltipConstrainedWidth),
        child: child);
  }
}
