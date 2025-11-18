import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/create_account.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/wallet/constant/networks/solana.dart';

class SolanaTransactionCreateAccountWidget extends StatelessWidget {
  final SolanaTransactionCreateAccountOperation form;
  const SolanaTransactionCreateAccountWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateProgramId,
          field: form.programId,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateNewAccountAddress,
          field: form.newAccountAddress,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.accountSize,
        builder: (context, field, value) {
          return ContainerWithBorder(
            validate: value != null,
            onRemoveIcon: AddOrEditIconWidget(value != null),
            onRemove: () {
              context
                  .openSliverBottomSheet<BigRational>(
                "account_size".tr,
                child: NumberWriteView(
                  defaultValue: value,
                  allowDecimal: false,
                  max: SolanaConst.maximumAccountSizeBytes,
                  min: BigRational.zero,
                  allowSign: false,
                  title: PageTitleSubtitle(
                      title: "account_size".tr,
                      body: Text("solana_account_size_desc".tr)),
                  buttonText: "setup_account_size".tr,
                  label: "account_size".tr,
                ),
              )
                  .then((v) {
                if (v == null) return;
                form.onUpdateAccountSize(v);
              });
            },
            child: Text(value?.toString().to3Digits ?? "tap_to_input_value".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          );
        },
      ),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.rent,
        builder: (context, field, value) {
          return Shimmer(
              onActive: (enable, context) {
                return ContainerWithBorder(
                  validate: value.hasAmount,
                  validateText: value.error,
                  enableTap: false,
                  onRemoveWidget: ConditionalWidget(
                      onDeactive: (context) {
                        return Row(children: [
                          IconButton(
                              onPressed: form.getRequiredRentData,
                              icon: Icon(Icons.error,
                                  color: context.onPrimaryContainer)),
                          IconButton(
                              onPressed: () {
                                context
                                    .setupAmount(
                                        token: value.value.token,
                                        max: form.getMaxInput())
                                    .then((v) {
                                  if (v == null) return;
                                  form.onUpdateRentAmount(v);
                                });
                              },
                              icon: Icon(Icons.edit,
                                  color: context.onPrimaryContainer)),
                        ]);
                      },
                      enable: !value.status.isError,
                      onActive: (context) => IconButton(
                          onPressed: () {
                            context
                                .setupAmount(
                                    token: value.value.token,
                                    max: form.getMaxInput())
                                .then((v) {
                              if (v == null) return;
                              form.onUpdateRentAmount(v);
                            });
                          },
                          icon: Icon(Icons.edit,
                              color: context.onPrimaryContainer))),
                  onRemove: () {},
                  child: ConditionalWidget(
                      enable: value.hasAmount,
                      onActive: (context) => CoinAndMarketPriceView(
                          balance: value.value,
                          style: context.onPrimaryTextTheme.titleMedium,
                          showTokenImage: true,
                          symbolColor: context.onPrimaryContainer),
                      onDeactive: (context) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("tap_to_enter_amount".tr,
                                  style: context.onPrimaryTextTheme.bodyMedium)
                            ],
                          )),
                );
              },
              enable: !value.status.isPending);
        },
      ),
      WidgetConstant.height20,
      LiveFormWidgetMemo(
        field: form.memo,
        onUpdateMemo: form.onUpdateMemo,
        onRemoveMemo: form.onRemoveMemo,
      ),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
