import 'package:flutter/material.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/create_associated_token_account.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';

class SolanaTransactionCreateAssociatedTokenAccountWidget
    extends StatelessWidget {
  final SolanaTransactionCreateAssociatedTokenAccountOperation form;
  const SolanaTransactionCreateAssociatedTokenAccountWidget(
      {required this.form, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateOwnerAddress,
          field: form.ownerAddress,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateTokenProgramAddress,
          field: form.tokenProgram,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: form.onUpdateMintAddress,
          field: form.mintAddress,
          account: form.account),
      WidgetConstant.height20,
      LiveFormWidgetReceiverAddress(
          onUpdateAddress: null,
          visibleOnNull: false,
          field: form.assosicatedAddress,
          account: form.account),
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
