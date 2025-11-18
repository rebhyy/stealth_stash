import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/create_account.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/create_associated_token_account.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/initialize_mint.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/mint_to.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/operations/transfer_token.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/future/router/page_router.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';

class SolanaAccountPageView extends StatelessWidget {
  const SolanaAccountPageView({required this.chainAccount, super.key});
  final SolanaChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _SolanaServices(chainAccount),
      AccountTokensView<SolanaSPLToken, ISolanaAddress>(
        account: chainAccount,
        transferBuilder: (p0) => SolanaTransactionTransferTokenOperation(
            walletProvider: context.wallet,
            account: chainAccount,
            address: chainAccount.address,
            token: p0),
      ),
      AccountTransactionActivityView<ISolanaAddress, SolanaWalletTransaction>(
          account: chainAccount, address: chainAccount.address)
    ]);
  }
}

class _SolanaServices extends StatelessWidget {
  final SolanaChain account;
  const _SolanaServices(this.account);

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              title: Text("associated_token_program".tr),
              subtitle: Text("create_associated_token_account".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final operation =
                    SolanaTransactionCreateAssociatedTokenAccountOperation(
                        address: account.address,
                        account: account,
                        walletProvider: context.wallet);
                context.to(PageRouter.transaction, argruments: operation);
              },
            ),
            AppListTile(
              title: Text("create_account".tr),
              subtitle: Text("solana_create_account_desc".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final operation = SolanaTransactionCreateAccountOperation(
                    address: account.address,
                    account: account,
                    walletProvider: context.wallet);
                context.to(PageRouter.transaction, argruments: operation);
              },
            ),
            AppListTile(
              title: Text("initialize_mint".tr),
              subtitle: Text("initiailize_mint_desc".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final operation = SolanaTransactionInitializeMintOperation(
                    address: account.address,
                    account: account,
                    walletProvider: context.wallet);
                context.to(PageRouter.transaction, argruments: operation);
              },
            ),
            AppListTile(
              title: Text("mint_to".tr),
              subtitle: Text("mint_to_desc".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final operation = SolanaTransactionMintToOperation(
                    address: account.address,
                    account: account,
                    walletProvider: context.wallet);
                context.to(PageRouter.transaction, argruments: operation);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text("solana_key_conversion".tr),
              subtitle: Text("solana_key_conversion_desc".tr),
              onTap: () {
                context.to(PageRouter.solanaKeyConversion);
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
