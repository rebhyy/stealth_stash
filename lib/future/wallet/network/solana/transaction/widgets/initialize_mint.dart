import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/initialize_mint.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/wallet/constant/networks/solana.dart';

class SolanaTransactionInitializeMintWidget extends StatelessWidget {
  final SolanaTransactionInitializeMintOperation form;
  const SolanaTransactionInitializeMintWidget({required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateProgramId,
          field: form.programId,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateMint,
          field: form.mint,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateMintAuthority,
          field: form.mintAuthority,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateFreezeAuthority,
          field: form.freezAuthority,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidget(
        field: form.decimals,
        builder: (context, field, value) {
          return ContainerWithBorder(
            validate: value != null,
            onRemoveIcon: AddOrEditIconWidget(value != null),
            onRemove: () {
              context
                  .openSliverBottomSheet<BigRational>(
                "decimals".tr,
                child: NumberWriteView(
                  defaultValue: value,
                  allowDecimal: false,
                  max: SolanaConst.maxSPLTokenDecimalPlaces,
                  min: BigRational.zero,
                  allowSign: false,
                  title: PageTitleSubtitle(
                      title: "decimals".tr,
                      body: Text("solana_mint_decimal_desc".tr)),
                  buttonText: "setup_token_decimal".tr,
                  label: "decimals".tr,
                ),
              )
                  .then(
                (value) {
                  if (value == null) return;
                  form.onUpdateDecimals(value);
                },
              );
            },
            child: Text(
              value?.toString().to3Digits ?? "tap_to_input_value".tr,
              style: context.onPrimaryTextTheme.bodyMedium,
            ),
          );
        },
      ),
      WidgetConstant.height20,
      LiveFormWidgetMemo(field: form.memo, onUpdateMemo: form.onUpdateMemo),
      WidgetConstant.height20,
      TransactionFeeView(
          controller: form, onRetryFeeEstimate: form.estimateFee),
      TransactionStateSendTransaction(controller: form)
    ]);
  }
}
