import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/operations/nfts/cancel_offer.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/widgets/memo/memo.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/constant/networks/ripple.dart';

/// 00000000CAEC86DA62241D461CB7903710FC94DBC751342E742354D1002A6942
class RippleTransactionNFTokenCancelOfferWidget extends StatelessWidget {
  final RippleTransactionNFTokenCancelOfferOperation form;
  const RippleTransactionNFTokenCancelOfferWidget(
      {required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetList(
        field: form.nftokenOffers,
        onCreate: (context, field) {
          return ContainerWithBorder(
            validate: field.hasValue,
            onRemoveIcon:
                Icon(Icons.add_box, color: context.onPrimaryContainer),
            onRemove: () {
              context
                  .openSliverBottomSheet<String>(
                    "ripple_nftoken_cancel_offer_fields".tr,
                    child: StringWriterView(
                      maxLength: RippleConst.rippleTranactionHashLength,
                      minLength: RippleConst.rippleTranactionHashLength,
                      title: PageTitleSubtitle(
                          title: form.nftokenOffers.title.tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (form.nftokenOffers.subtitle != null)
                                Text(form.nftokenOffers.subtitle!.tr),
                            ],
                          )),
                      buttonText: "setup_input".tr,
                      label: form.nftokenOffers.title.tr,
                    ),
                  )
                  .then(form.onUpdateNFTokenOffsers);
            },
            child: Text("tap_to_input_value".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          );
        },
        builder: (context, field, value) {
          return ContainerWithBorder(
            onRemove: () {
              form.onRemoveNFTokenOffsers(value);
            },
            onRemoveIcon: Icon(Icons.remove_circle,
                color: context.colors.onPrimaryContainer),
            child: Text(value,
                maxLines: 3, style: context.onPrimaryTextTheme.bodyMedium),
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
