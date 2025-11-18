import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/operations/escrow/finish.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/widgets/memo/memo.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class RippleTransactionEscrowFinishWidget extends StatelessWidget {
  final RippleTransactionEscrowFinishOperation form;
  const RippleTransactionEscrowFinishWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetReceiverAddress(
          field: form.owner,
          account: form.account,
          onUpdateAddress: form.onUpdateOwner),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.offerSequence,
        builder: (context, field, value) {
          return ContainerWithBorder(
            onRemoveIcon: AddOrEditIconWidget(field.hasValue),
            validate: field.complete,
            onRemove: () {
              context
                  .openSliverBottomSheet<BigRational>(
                    "ripple_escrow_finish_fields".tr,
                    child: NumberWriteView(
                      defaultValue: field.value,
                      allowDecimal: false,
                      allowSign: false,
                      title: PageTitleSubtitle(
                          title: field.title,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (field.subtitle != null) Text(field.subtitle!),
                            ],
                          )),
                      buttonText: "setup_input".tr,
                      label: field.title,
                    ),
                  )
                  .then(form.onUpdateOfferSequence);
            },
            child: Text(
                field.value?.toString().to3Digits ?? "tap_to_input_value".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          );
        },
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.condition,
        builder: (context, field, value) {
          return ContainerWithBorder(
              onRemove: () {
                if (value != null) {
                  form.onUpdateCondition(null);
                  return;
                }
                context
                    .openSliverBottomSheet<String>(
                      "ripple_escrow_finish_fields".tr,
                      child: StringWriterView(
                        defaultValue: field.value,
                        title: PageTitleSubtitle(
                            title: field.title,
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (field.subtitle != null)
                                  Text(field.subtitle!),
                              ],
                            )),
                        buttonText: "setup_input".tr,
                        label: field.title,
                      ),
                    )
                    .then(form.onUpdateCondition);
              },
              onRemoveIcon: AddOrRemoveIconWidget(field.hasValue),
              child: APPAnimated(
                  onActive: (context) => FullWidthWrapper(
                      key: ValueKey(value?.length),
                      child: Text(value ?? "tap_to_input_value".tr,
                          maxLines: 3,
                          style: context.onPrimaryTextTheme.bodyMedium))));
        },
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.fulfillment,
        builder: (context, field, value) {
          return ContainerWithBorder(
              onRemove: () {
                if (value != null) {
                  form.onUpdateFulfillment(null);
                  return;
                }
                context
                    .openSliverBottomSheet<String>(
                      "ripple_escrow_finish_fields".tr,
                      child: StringWriterView(
                        defaultValue: field.value,
                        title: PageTitleSubtitle(
                            title: field.title,
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (field.subtitle != null)
                                  Text(field.subtitle!),
                              ],
                            )),
                        buttonText: "setup_input".tr,
                        label: field.title,
                      ),
                    )
                    .then(form.onUpdateFulfillment);
              },
              onRemoveIcon: AddOrRemoveIconWidget(field.hasValue),
              child: APPAnimated(
                  onActive: (context) => FullWidthWrapper(
                      key: ValueKey(value?.length),
                      child: Text(value ?? "tap_to_input_value".tr,
                          maxLines: 3,
                          style: context.onPrimaryTextTheme.bodyMedium))));
        },
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
