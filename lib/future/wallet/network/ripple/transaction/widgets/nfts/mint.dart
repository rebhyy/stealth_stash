import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/operations/nfts/mint_token.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/widgets/memo/memo.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/wallet/constant/networks/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleTransactionNFTokenMintWidget extends StatelessWidget {
  final RippleTransactionNFTokenMintOperation form;
  const RippleTransactionNFTokenMintWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidget(
        field: form.nftokenTaxon,
        builder: (context, field, value) {
          return ContainerWithBorder(
            validate: value != null,
            onRemoveIcon: AddOrEditIconWidget(value != null),
            onRemove: () {
              context
                  .openSliverBottomSheet<BigRational>(
                    "ripple_nfttoken_fields".tr,
                    child: NumberWriteView(
                      defaultValue: value,
                      max: RippleConst.max32UnsignedRational,
                      allowDecimal: false,
                      allowSign: false,
                      title: PageTitleSubtitle(
                          title: form.nftokenTaxon.title.tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (form.nftokenTaxon.subtitle != null)
                                Text(form.nftokenTaxon.subtitle!.tr),
                            ],
                          )),
                      buttonText: "setup_input".tr,
                      label: form.nftokenTaxon.title.tr,
                    ),
                  )
                  .then(form.onUpdateNFTokenTaxon);
            },
            child: Text(
              value?.toString().to3Digits ?? "tap_to_input_value".tr,
              style: context.onPrimaryTextTheme.bodyMedium,
            ),
          );
        },
      ),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
        field: form.issuer,
        account: form.account,
        onUpdateAddress: form.onUpdateIssuer,
        removable: true,
      ),
      WidgetConstant.height20,
      LiveFormWidgetString(
          onUpdateValue: form.onUpdateUri,
          field: form.uri,
          removable: true,
          fieldName: "ripple_nfttoken_fields".tr),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.transferFee,
        builder: (context, field, value) {
          return ContainerWithBorder(
            onRemoveIcon: AddOrRemoveIconWidget(field.hasValue),
            validate: field.complete,
            onRemove: () {
              if (field.hasValue) {
                form.onUpdateTransferFee(null);
                return;
              }
              context
                  .openSliverBottomSheet<BigRational>(
                    "ripple_nfttoken_fields".tr,
                    child: NumberWriteView(
                      defaultValue: field.value,
                      max: RippleConst.maxNftTokenTransferRate,
                      allowDecimal: false,
                      allowSign: false,
                      title: PageTitleSubtitle(
                          title: field.title.tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (field.subtitle != null)
                                Text(field.subtitle!.tr),
                            ],
                          )),
                      buttonText: "setup_input".tr,
                      label: field.title.tr,
                    ),
                  )
                  .then(form.onUpdateTransferFee);
            },
            child: APPAnimated(
                onActive: (context) => FullWidthWrapper(
                    key: ValueKey(value),
                    child: Text(
                        value?.toString().to3Digits ?? "tap_to_input_value".tr,
                        style: context.onPrimaryTextTheme.bodyMedium))),
          );
        },
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.flags,
        builder: (context, field, value) {
          return AppDropDownBottom(
            items: <NFTokenMintFlag, Widget>{
              for (final i in NFTokenMintFlag.values) i: Text(i.name)
            },
            value: field.value,
            key: ValueKey<String>("set_${field.value}"),
            onChanged: form.onUpdateFlag,
            hint: "none".tr,
            icon: field.hasValue
                ? InkWell(
                    onTap: () {
                      form.onUpdateFlag(null);
                    },
                    child: const Icon(Icons.remove_circle))
                : null,
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
