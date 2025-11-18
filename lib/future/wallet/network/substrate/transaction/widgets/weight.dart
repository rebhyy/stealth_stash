import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SetupSubstrateWeightView extends StatefulWidget {
  final SubstrateWeightV2? weight;
  const SetupSubstrateWeightView({this.weight, super.key});

  @override
  State<SetupSubstrateWeightView> createState() =>
      _SetupSubstrateWeightViewState();
}

class _SetupSubstrateWeightViewState extends State<SetupSubstrateWeightView>
    with SafeState<SetupSubstrateWeightView> {
  final BigRational max = BigRational(SubstrateConstant.maxWeightRefTime);
  BigRational? reftime;
  BigRational? proofSize;

  bool isReady = false;

  void onStateUpdated() {
    isReady = reftime != null && proofSize != null;
    updateState();
  }

  void onUpdateReftime(BigRational? reftime) {
    if (reftime == null ||
        reftime.isNegative ||
        reftime.isDecimal ||
        reftime > max) {
      return;
    }
    this.reftime = reftime;
    onStateUpdated();
  }

  void onUpdateProofSize(BigRational? proofSize) {
    if (proofSize == null ||
        proofSize.isNegative ||
        proofSize.isDecimal ||
        proofSize > max) {
      return;
    }
    this.proofSize = proofSize;
    onStateUpdated();
  }

  void onSetup() {
    final reftime = this.reftime;
    final proofSize = this.proofSize;
    if (reftime == null || proofSize == null) return;
    final wegith = SubstrateWeightV2(
        refTime: reftime.toBigInt(), proofSize: proofSize.toBigInt());
    context.pop(wegith);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    final weight = widget.weight;
    if (weight != null) {
      proofSize = BigRational(weight.proofSize);
      reftime = BigRational(weight.refTime);
      onStateUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "weight".tr,
            body: Text(
              "transaction_weight_const".tr,
            )),
        WidgetConstant.height20,
        Text("ref_time".tr, style: context.textTheme.titleMedium),
        Text("weight_ref_time_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: reftime != null,
          onRemoveIcon: AddOrEditIconWidget(reftime != null),
          onRemove: () {
            context
                .openMaxExtendSliverBottomSheet<BigRational>(
                  "transaction_weight_const".tr,
                  child: NumberWriteView(
                    defaultValue: reftime ?? BigRational.one,
                    min: BigRational.one,
                    max: max,
                    allowDecimal: false,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: "ref_time".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("weight_ref_time_desc".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "ref_time".tr,
                  ),
                )
                .then(onUpdateReftime);
          },
          child: Text(
            reftime?.toString().to3Digits ?? "tap_to_input_value".tr,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
        ),
        WidgetConstant.height20,
        Text("proof_size".tr, style: context.textTheme.titleMedium),
        Text("weight_proof_size_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: proofSize != null,
          onRemoveIcon: AddOrEditIconWidget(proofSize != null),
          onRemove: () {
            context
                .openMaxExtendSliverBottomSheet<BigRational>(
                  "transaction_weight_const".tr,
                  child: NumberWriteView(
                    defaultValue: proofSize ?? BigRational.one,
                    min: BigRational.one,
                    max: max,
                    allowDecimal: false,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: "proof_size".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("weight_proof_size_desc".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "proof_size".tr,
                  ),
                )
                .then(onUpdateProofSize);
          },
          child: Text(
            proofSize?.toString().to3Digits ?? "tap_to_input_value".tr,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: isReady ? onSetup : null,
                  child: Text("setup_weight".tr),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
