import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/wallet/network/ton/transaction/operations/transfer.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/future/router/page_router.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';

class TonAccountPageView extends StatelessWidget {
  const TonAccountPageView({required this.account, super.key});
  final TonChain account;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _TonServices(account),
      AccountTokensView<TonJettonToken, ITonAddress>(
        account: account,
        transferBuilder: (p0) {
          return TonTransactionTransferOperation(
              walletProvider: context.wallet,
              account: account,
              address: account.address);
        },
      ),
      AccountTransactionActivityView<ITonAddress, TonWalletTransaction>(
          account: account, address: account.address)
    ]);
  }
}

class _TonServices extends StatelessWidget {
  const _TonServices(this.account);
  final TonChain account;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text("ton_mnemonic".tr),
              subtitle: Text("generate_ton_private_key".tr),
              onTap: () {
                context.to(PageRouter.tonMnemonic);
              },
            ),
            AppListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text("ton_mnemonic".tr),
              subtitle: Text("generate_ton_private_key".tr),
              onTap: () {
                context.to(PageRouter.tonMnemonic);
              },
            ),
          ],
        ),
      )
    ]);
  }
}
