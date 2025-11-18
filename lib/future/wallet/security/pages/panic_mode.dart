import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/security/widgets/volume_panic_listener.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:flutter/services.dart';

class PanicModeView extends StatefulWidget {
  const PanicModeView({super.key});

  @override
  State<PanicModeView> createState() => _PanicModeViewState();
}

class _PanicModeViewState extends State<PanicModeView>
    with SafeState<PanicModeView>, ProgressMixin<PanicModeView> {
  WalletProvider get wallet => context.wallet;
  late final FocusNode _focusNode;
  late final VolumePanicListener _volumeListener;

  Future<void> triggerSoftPanic() async {
    final confirm = await context.openSliverDialog<bool>(
        widget: (ctx) => DialogTextView(
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("panic_soft_title".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  Text("panic_soft_desc".tr),
                  WidgetConstant.height8,
                  AlertTextContainer(
                      message: "panic_soft_warning".tr, enableTap: false),
                ],
              ),
              buttonWidget: const DialogDoubleButtonView(),
            ),
        label: "panic_mode".tr);
    if (confirm != true) return;
    progressKey.progressText("processing".tr);
    final result = await wallet.softPanic();
    if (result.hasError) {
      progressKey.errorText(result.localizationError, backToIdle: false);
    } else {
      progressKey.successText("panic_soft_done".tr, backToIdle: false);
      await MethodUtils.wait();
      navigatorKey?.currentContext?.popToHome();
    }
  }

  void togglePanicGesture() {
    wallet.togglePanicTap();
    updateState();
  }

  void togglePanicVolume() {
    wallet.togglePanicVolume();
    updateState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    _focusNode = FocusNode();
    _volumeListener =
        VolumePanicListener(onMatch: () async => (await wallet.softPanic()).hasError == false);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panicVolumeEnabled =
        wallet.appSetting.walletSetting.enablePanicVolume;
    return ScaffoldPageView(
        appBar: AppBar(title: Text("panic_mode".tr)),
        child: RawKeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKey: (event) {
            if (!panicVolumeEnabled) return;
            if (event is RawKeyDownEvent) {
              _volumeListener.handle(event);
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverConstraintsBoxView(
                  padding: WidgetConstant.paddingHorizontal20,
                  sliver: SliverToBoxAdapter(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetConstant.height20,
                      PageTitleSubtitle(
                          title: "panic_mode_desc".tr,
                          body: Text("panic_mode_body".tr)),
                      WidgetConstant.height20,
                      ContainerWithBorder(
                          padding: WidgetConstant.padding10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("panic_trigger_volume".tr,
                                          style:
                                              context.textTheme.titleMedium),
                                      Text("panic_trigger_volume_desc".tr,
                                          style: context.textTheme.bodySmall),
                                    ],
                                  )),
                                  Switch(
                                      value: panicVolumeEnabled,
                                      onChanged: (_) => togglePanicVolume())
                                ],
                              ),
                              if (panicVolumeEnabled)
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 4),
                                    child: Text("panic_trigger_volume_hint".tr,
                                        style: context.textTheme.bodySmall))
                            ],
                          )),
                      WidgetConstant.height20,
                      FixedElevatedButton(
                          padding: WidgetConstant.paddingVertical20,
                          onPressed: triggerSoftPanic,
                          child: Text("trigger_soft_panic_now".tr)),
                      WidgetConstant.height20,
                      AlertTextContainer(
                          message: "panic_hard_placeholder_tron".tr,
                          icon: Icons.info_outline)
                    ],
                  ))),
            ],
          ),
        ));
  }
}
