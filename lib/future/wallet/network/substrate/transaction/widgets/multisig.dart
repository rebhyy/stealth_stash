import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/operations/multisig_operation.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/widgets/call_data.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/widgets/substrate_transaction_fee.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/widgets/weight.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/widgets/widgets/json/json/widgets.dart';
import 'package:stealth_stash/wallet/models/networks/substrate/models/multisig.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateTransactionMultisigOperationWidget extends StatelessWidget {
  final SubstrateTransactionMultisigOperation form;
  const SubstrateTransactionMultisigOperationWidget(
      {required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidget(
        field: form.multisigMethod,
        builder: (context, field, value) {
          if (form.immutable) {
            return ContainerWithBorder(
              child: Text(value.method.camelCase,
                  style: context.onPrimaryTextTheme.bodyMedium),
            );
          }
          return AppDropDownBottom(items: {
            for (final i in form.availableMethods) i: Text(i.name.camelCase)
          }, value: value, onChanged: form.onUpdateTransferMethod);
        },
      ),
      WidgetConstant.height20,
      LiveFormWidgetAccount(
        field: form.multisigAccount,
        account: form.account,
        onFilterAccount: form.validateAccount,
        onUpdateAddress:
            form.immutable ? null : form.onUpdateMultisignatureAccount,
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.callOrHash,
        title: form.title,
        subtitle: form.subtitle,
        builder: (context, field, value) {
          return CustomizedContainer(
            enableTap: !field.hasValue,
            validate: field.complete,
            onStackIcon: Icons.edit,
            onTapStackIcon: form.immutable
                ? null
                : () {
                    context
                        .openSliverBottomSheet<SubstrateMultisigCallData>(
                          form.multisigMethod.value.name.camelCase,
                          child: SubstrateMultisigCallDataField(
                            defaultValue: field.value,
                            api: form.client.api,
                            method: form.multisigMethod.value,
                          ),
                        )
                        .then(form.onUpdateCallOrHash);
                  },
            onRemoveIcon: AddOrEditIconWidget(field.hasValue),
            child: APPAnimated(
                key: ValueKey(value),
                isActive: value == null,
                onDeactive: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            child: LargeTextContainer(
                                text: value?.call.callDataHex ??
                                    value!.call.callHashHex,
                                maxLines: 3,
                                color: context.primaryContainer),
                          ),
                          ConditionalWidget(
                              enable: value?.content != null,
                              onActive: (context) => ContainerWithBorder(
                                  backgroundColor: context.onPrimaryContainer,
                                  onRemoveIcon: Icon(Icons.open_in_full,
                                      color: context.primaryContainer),
                                  onRemove: () {
                                    context.openDialogPage(
                                      '',
                                      child: (context) => JsonView(
                                          text: value!.content!,
                                          title: 'content'.tr),
                                    );
                                  },
                                  child: Text("content".tr,
                                      style:
                                          context.primaryTextTheme.bodyMedium)))
                        ]),
                onActive: (context) => FullWidthWrapper(
                    child: Text("tap_to_input_value".tr,
                        maxLines: 3,
                        style: context.onPrimaryTextTheme.bodyMedium))),
          );
        },
      ),
      APPStreamBuilder(
        value: form.resource.notifier,
        builder: (context, _) {
          final value = form.resource;
          return ConditionalWidget(
            enable: !form.resource.status.isIdle,
            onActive: (context) => Shimmer(
                onActive: (enable, context) {
                  if (!enable) return ShimmerBox();
                  if (value.status.isError) {
                    return ErrorTextContainer(
                        error: value.error, enableTap: false);
                  }
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConditionalWidget(
                          enable: value.value.needWeight,
                          onActive: (context) {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetConstant.height20,
                                  LiveFormWidget(
                                    field: form.weight,
                                    builder: (context, field, value) {
                                      return ContainerWithBorder(
                                          validate: field.hasValue,
                                          onRemove: () {
                                            context
                                                .openSliverBottomSheet<
                                                    SubstrateWeightV2>(
                                                  "transaction_weight".tr,
                                                  child:
                                                      SetupSubstrateWeightView(
                                                          weight: value),
                                                )
                                                .then(form.onUpdateWeight);
                                          },
                                          onRemoveIcon: AddOrEditIconWidget(
                                              field.hasValue),
                                          child: APPAnimated(
                                            key: ValueKey(value),
                                            onActive: (context) =>
                                                ConditionalWidget(
                                              enable: value == null,
                                              onActive: (context) =>
                                                  FullWidthWrapper(
                                                      child: Text(
                                                          "tap_to_input_value"
                                                              .tr,
                                                          maxLines: 3,
                                                          style: context
                                                              .onPrimaryTextTheme
                                                              .bodyMedium)),
                                              onDeactive: (context) =>
                                                  FullWidthWrapper(
                                                      child: Text(
                                                          "${value!.refTime.toString()}/${value.proofSize.toString()}",
                                                          maxLines: 3,
                                                          style: context
                                                              .onPrimaryTextTheme
                                                              .bodyMedium)),
                                            ),
                                          ));
                                    },
                                  ),
                                ]);
                          },
                        ),
                        ConditionalWidget(
                          enable: value.value.needTimepoint &&
                              value.value.callData.multisig?.when != null,
                          onActive: (context) {
                            final timepoint =
                                value.value.callData.multisig!.when;
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetConstant.height20,
                                  Text("timepoint".tr,
                                      style: context.textTheme.titleMedium),
                                  Text("substrate_timepoint_desc".tr),
                                  WidgetConstant.height8,
                                  ContainerWithBorder(
                                    child: FullWidthWrapper(
                                        child: Text(
                                            "${timepoint.height.toString()}/${timepoint.index.toString()}",
                                            maxLines: 3,
                                            style: context.onPrimaryTextTheme
                                                .bodyMedium)),
                                  ),
                                ]);
                          },
                        ),
                        ConditionalWidget(
                            enable: form.supportBatch,
                            onActive:
                                (context) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WidgetConstant.height20,
                                          LiveFormWidgetList(
                                              field: form.memos,
                                              builder: (context, field,
                                                      value) =>
                                                  ContainerWithBorder(
                                                      onRemove: () {
                                                        form.onRemoveMemo(
                                                            value);
                                                      },
                                                      onRemoveIcon: Icon(
                                                          Icons.remove_circle,
                                                          color: context
                                                              .onPrimaryContainer),
                                                      child: Text(value,
                                                          style: context
                                                              .onPrimaryTextTheme
                                                              .bodyMedium)),
                                              onCreate: (context, field) {
                                                return ContainerWithBorder(
                                                    onRemoveIcon: Icon(
                                                        Icons.add_box,
                                                        color: context
                                                            .onPrimaryContainer),
                                                    onRemove: () {
                                                      context
                                                          .openSliverBottomSheet<
                                                              String>(
                                                            "transaction_memo"
                                                                .tr,
                                                            child: StringWriterView(
                                                                title: PageTitleSubtitle(
                                                                    title: "setup_memo".tr,
                                                                    body: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text("memo_desc1"
                                                                            .tr),
                                                                        WidgetConstant
                                                                            .height8,
                                                                        Text("empty_desc"
                                                                            .tr),
                                                                      ],
                                                                    )),
                                                                buttonText: "setup_memo".tr,
                                                                label: "memo".tr),
                                                          )
                                                          .then(form
                                                              .onUpdateMemo);
                                                    },
                                                    child: Text(
                                                        "tap_to_add_memo".tr,
                                                        style: context
                                                            .onPrimaryTextTheme
                                                            .bodyMedium));
                                              }),
                                        ])),
                        ConditionalWidget(
                            enable: value.value.depositAmount != null,
                            onActive: (context) {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WidgetConstant.height20,
                                    Text("deposit".tr,
                                        style: context.textTheme.titleMedium),
                                    Text("substrate_multisig_deposit_desc".tr),
                                    WidgetConstant.height8,
                                    ContainerWithBorder(
                                      child: CoinAndMarketPriceView(
                                        isExpanded: true,
                                        balance: value.value.depositAmount!,
                                        symbolColor: context.onPrimaryContainer,
                                        style: context
                                            .onPrimaryTextTheme.titleMedium,
                                        showTokenImage: true,
                                      ),
                                    )
                                  ]);
                            }),
                        WidgetConstant.height20,
                        APPStreamBuilder(
                          value: form.feeToken.live,
                          builder: (context, v) {
                            return SubstrateTransactionFeeWidget(
                                fee: form.txFee,
                                onSelectToken: form.onUpdateFeeToken,
                                onRetryFeeEstimate: form.estimateFee,
                                feeToken: v,
                                feeTokens: form.feeTokens);
                          },
                        ),
                        TransactionStateSendTransaction(controller: form)
                      ]);
                },
                enable: !form.resource.status.isPending),
          );
        },
      ),
      WidgetConstant.height20,
    ]);
  }
}
