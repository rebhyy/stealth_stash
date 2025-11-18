import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/operations/account_set/account_set.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/widgets/memo/memo.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/constant/networks/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleTransactionAccountSetWidget extends StatelessWidget {
  final RippleTransactionAccountSetOperation form;
  const RippleTransactionAccountSetWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidget(
        field: form.domain,
        builder: (context, field, value) => ContainerWithBorder(
          onRemove: () {
            if (value != null) {
              form.onUpdateDomain(null);
              return;
            }
            context
                .openSliverBottomSheet<String>(
                  "account_set_fields".tr,
                  child: StringWriterView(
                    defaultValue: value,
                    maxLength: RippleConst.maxDomainLength,
                    title: PageTitleSubtitle(
                        title: "domain".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("domain_desc".tr),
                            WidgetConstant.height8,
                            Text("hex_desc".tr),
                            WidgetConstant.height8,
                            Text(
                              "character_length_validator_desc"
                                  .tr
                                  .replaceOne("domain".tr)
                                  .replaceTwo(
                                      RippleConst.maxDomainLength.toString())
                                  .replaceThere(
                                      (RippleConst.maxDomainLength ~/ 2)
                                          .toString()),
                            ),
                            WidgetConstant.height8,
                            Text("empty_desc".tr)
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "domain".tr,
                  ),
                )
                .then(form.onUpdateDomain);
          },
          onRemoveIcon: AddOrRemoveIconWidget(value != null),
          child: APPAnimated(
              isActive: true,
              onActive: (context) => FullWidthWrapper(
                    key: ValueKey(value?.length),
                    child: Text(value?.orEmpty ?? "tap_to_input_value".tr,
                        maxLines: 3,
                        style: context.onPrimaryTextTheme.bodyMedium),
                  )),
        ),
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.email,
        builder: (context, field, value) => ContainerWithBorder(
          onRemove: () {
            if (value != null) {
              form.onUpdateEmail(null);
              return;
            }
            context
                .openSliverBottomSheet<String>(
                  "account_set_fields".tr,
                  child: StringWriterView(
                    defaultValue: value,
                    maxLength: RippleConst.maxEmailHashLength,
                    title: PageTitleSubtitle(
                        title: "email_hash".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ripple_email_hash_desc".tr),
                            WidgetConstant.height8,
                            Text("hex_desc".tr),
                            WidgetConstant.height8,
                            Text(
                              "character_length_validator_desc"
                                  .tr
                                  .replaceOne("email_hash".tr)
                                  .replaceTwo(
                                      RippleConst.maxEmailHashLength.toString())
                                  .replaceThere(
                                      (RippleConst.maxEmailHashLength ~/ 2)
                                          .toString()),
                            ),
                            WidgetConstant.height8,
                            Text("empty_desc".tr)
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "email_hash".tr,
                  ),
                )
                .then(form.onUpdateEmail);
          },
          onRemoveIcon: AddOrRemoveIconWidget(value != null),
          child: APPAnimated(
              isActive: true,
              onActive: (context) => FullWidthWrapper(
                    key: ValueKey(value?.length),
                    child: Text(value?.orEmpty ?? "tap_to_input_value".tr,
                        maxLines: 3,
                        style: context.onPrimaryTextTheme.bodyMedium),
                  )),
        ),
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.messageKey,
        builder: (context, field, value) => ContainerWithBorder(
          onRemove: () {
            if (value != null) {
              form.onUpdateMessageKey(null);
              return;
            }
            context
                .openSliverBottomSheet<String>(
                  "account_set_fields".tr,
                  child: StringWriterView(
                    defaultValue: value,
                    customForm: form.validateMessageKey,
                    maxLength: RippleConst.maxEmailHashLength,
                    title: PageTitleSubtitle(
                        title: "ripple_message_key".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ripple_message_key_desc".tr),
                            WidgetConstant.height8,
                            Text("ripple_message_key_desc2".tr),
                            WidgetConstant.height8,
                            Text("empty_desc".tr)
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "ripple_message_key".tr,
                  ),
                )
                .then(form.onUpdateMessageKey);
          },
          onRemoveIcon: AddOrRemoveIconWidget(value != null),
          child: APPAnimated(
              isActive: true,
              onActive: (context) => FullWidthWrapper(
                  key: ValueKey(value?.length),
                  child: Text(value?.orEmpty ?? "tap_to_input_value".tr,
                      maxLines: 3,
                      style: context.onPrimaryTextTheme.bodyMedium))),
        ),
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.transferRate,
        builder: (context, field, value) => ContainerWithBorder(
          onRemoveIcon: AddOrRemoveIconWidget(value != null),
          onRemove: () {
            if (value != null) {
              form.onUpdateTransferRate(null);
              return;
            }
            context
                .openSliverBottomSheet<BigRational>(
                  "account_set_fields".tr,
                  child: NumberWriteView(
                    defaultValue: value,
                    allowDecimal: false,
                    customForm: form.validateTransferRate,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: "ripple_transfer_rate".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ripple_transfer_rate_desc".tr),
                            WidgetConstant.height8,
                            Text("ripple_transfer_rate_desc2".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "ripple_transfer_rate".tr,
                  ),
                )
                .then(form.onUpdateTransferRate);
          },
          child: APPAnimated(
              isActive: true,
              onActive: (context) => FullWidthWrapper(
                    key: ValueKey(value),
                    child: FullWidthWrapper(
                      child: Text(
                          value?.toString().to3Digits ??
                              "tap_to_input_value".tr,
                          maxLines: 3,
                          style: context.onPrimaryTextTheme.bodyMedium),
                    ),
                  )),
        ),
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.tickSize,
        builder: (context, field, value) => ContainerWithBorder(
          onRemoveIcon: AddOrRemoveIconWidget(value != null),
          onRemove: () {
            if (value != null) {
              form.onUpdateTickSize(null);
              return;
            }
            context
                .openSliverBottomSheet<BigRational>(
                  "account_set_fields".tr,
                  child: NumberWriteView(
                    defaultValue: value,
                    allowDecimal: false,
                    customForm: form.validateTickSize,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: "ripple_tick_size".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ripple_tick_size_desc".tr),
                            WidgetConstant.height8,
                            Text("ripple_tick_size_desc2".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "ripple_tick_size".tr,
                  ),
                )
                .then(form.onUpdateTickSize);
          },
          child: APPAnimated(
              onActive: (context) => FullWidthWrapper(
                    key: ValueKey(value),
                    child: Text(
                      value?.toString().to3Digits ?? "tap_to_input_value".tr,
                      style: context.onPrimaryTextTheme.bodyMedium,
                    ),
                  )),
        ),
      ),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          field: form.nftokenMinter,
          account: form.account,
          removable: true,
          onUpdateAddress: (address) => form.onUpdateNFTokenMinter(address)),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.setFlag,
        builder: (context, field, value) => AppDropDownBottom(
            items: <AccountSetAsfFlag, Widget>{
              for (final i in AccountSetAsfFlag.values) i: Text(i.name)
            },
            value: value,
            key: ValueKey<String>("set_$value"),
            onChanged: (value) {
              form.onUpdateSetFlag(value);
            },
            hint: "none".tr,
            icon: value != null
                ? InkWell(
                    onTap: () {
                      form.onUpdateSetFlag(null);
                    },
                    child: const Icon(Icons.remove_circle))
                : null),
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.clearFlag,
        builder: (context, field, value) => AppDropDownBottom(
            items: <AccountSetAsfFlag, Widget>{
              for (final i in AccountSetAsfFlag.values) i: Text(i.name)
            },
            value: value,
            key: ValueKey<String>("clear_$value"),
            onChanged: (value) {
              form.onUpdateClearFlag(value);
            },
            hint: "none".tr,
            icon: value != null
                ? InkWell(
                    onTap: () {
                      form.onUpdateClearFlag(null);
                    },
                    child: const Icon(Icons.remove_circle))
                : null),
      ),
      WidgetConstant.height20,
      RippleTransactionMemoWidget(controller: form),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
