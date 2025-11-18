import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/controllers/memo.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/widgets/memo/create_ripple_memo.dart';
import 'package:stealth_stash/future/wallet/transaction/pages/live_form_widget.dart';
import 'package:stealth_stash/future/widgets/widgets/conditional_widget.dart';
import 'package:stealth_stash/future/widgets/widgets/container_with_border.dart';
import 'package:stealth_stash/future/widgets/widgets/text_widget.dart';
import 'package:stealth_stash/future/widgets/widgets/widget_constant.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleTransactionMemoWidget extends StatelessWidget {
  final RippleTransactionMemoController controller;
  const RippleTransactionMemoWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return LiveFormWidgetList(
      field: controller.memo,
      onCreate: (context, field) => ContainerWithBorder(
        onRemoveIcon:
            Icon(Icons.add_box, color: context.colors.onPrimaryContainer),
        child: Text("tap_to_create_memo".tr,
            style: context.onPrimaryTextTheme.bodyMedium),
        onRemove: () {
          context
              .openMaxExtendSliverBottomSheet<XRPLMemo>("create_memo".tr,
                  child: CreateRippleMemoView())
              .then((memo) {
            if (memo == null) return;
            controller.onUpdateMemo(memo);
          });
        },
      ),
      builder: (context, field, value) {
        return RippleMemoView(value,
            onTapMemo: (e) => controller.onRemoveMemo(e));
      },
    );
  }
}

typedef ONTAPRIPPLEMEMO = Function(XRPLMemo);

class RippleMemoView extends StatelessWidget {
  const RippleMemoView(this.memo, {this.onTapMemo, super.key});
  final XRPLMemo memo;
  final ONTAPRIPPLEMEMO? onTapMemo;
  @override
  Widget build(BuildContext context) {
    final bool memoIsEmpty = memo.memoType == null &&
        memo.memoFormat == null &&
        memo.memoData == null;
    return ContainerWithBorder(
        onRemoveIcon:
            Icon(Icons.remove_circle, color: context.colors.onPrimaryContainer),
        onRemove: onTapMemo == null
            ? null
            : () {
                onTapMemo!(memo);
              },
        child: memoIsEmpty
            ? Text("value_is_empty".tr,
                style: context.onPrimaryTextTheme.bodyMedium)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConditionalWidget(
                      enable: memo.memoData != null,
                      onActive: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("memo_data".tr,
                                    style:
                                        context.onPrimaryTextTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  backgroundColor: context.onPrimaryContainer,
                                  child: OneLineTextWidget(memo.memoData!,
                                      style:
                                          context.primaryTextTheme.bodyMedium),
                                ),
                                WidgetConstant.height20,
                              ])),
                  ConditionalWidget(
                      enable: memo.memoFormat != null,
                      onActive: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("memo_format".tr,
                                    style:
                                        context.onPrimaryTextTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  backgroundColor: context.onPrimaryContainer,
                                  child: OneLineTextWidget(memo.memoFormat!,
                                      style:
                                          context.primaryTextTheme.bodyMedium),
                                ),
                                WidgetConstant.height20,
                              ])),
                  ConditionalWidget(
                      enable: memo.memoType != null,
                      onActive: (context) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("memo_type".tr,
                                    style:
                                        context.onPrimaryTextTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  backgroundColor: context.onPrimaryContainer,
                                  child: OneLineTextWidget(memo.memoType!,
                                      style:
                                          context.primaryTextTheme.bodyMedium),
                                ),
                                WidgetConstant.height20,
                              ])),
                ],
              ));
  }
}
