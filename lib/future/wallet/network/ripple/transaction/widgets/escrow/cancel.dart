import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/operations/escrow/cancel.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/widgets/memo/memo.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';

class RippleTransactionEscrowCancelWidget extends StatelessWidget {
  final RippleTransactionEscrowCancelOperation form;
  const RippleTransactionEscrowCancelWidget({required this.form, super.key});

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
                    "ripple_escrow_cancel_fields".tr,
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
                      label: field.title.tr,
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
      RippleTransactionMemoWidget(controller: form),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
