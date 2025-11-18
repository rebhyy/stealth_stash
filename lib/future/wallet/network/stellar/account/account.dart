import 'package:flutter/material.dart';
import 'package:stealth_stash/future/router/page_router.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/wallet/network/stellar/transaction/controllers/controller.dart';
import 'package:stealth_stash/future/wallet/network/stellar/transaction/widgets/widgets/extensions.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';

class StellarAccountPageView extends StatelessWidget {
  const StellarAccountPageView({required this.chainAccount, super.key});
  final StellarChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _StellarServices(chainAccount),
      AccountTokensView<StellarIssueToken, IStellarAddress>(
          account: chainAccount,
          transferBuilder: (p0) => StellarTransactionStateController(
              walletProvider: context.wallet,
              account: chainAccount,
              address: chainAccount.address,
              token: p0)),
      AccountTransactionActivityView<IStellarAddress, StellarWalletTransaction>(
          account: chainAccount, address: chainAccount.address)
    ]);
  }
}

class _StellarServices extends StatelessWidget {
  final StellarChain account;
  const _StellarServices(this.account);

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverList.separated(
          itemBuilder: (context, index) {
            final element = StellarConst.supportedOperations.elementAt(index);
            return AppListTile(
              title: Text(element.translate.tr),
              onTap: () {
                final operation = StellarTransactionStateController(
                    walletProvider: context.wallet,
                    account: account,
                    address: account.address,
                    operation: element);
                context.to(PageRouter.transaction, argruments: operation);
              },
              subtitle: Text(element.description),
              maxLine: 3,
              trailing: const Icon(Icons.arrow_forward),
            );
          },
          separatorBuilder: (context, index) => WidgetConstant.divider,
          itemCount: StellarConst.supportedOperations.length),
      SliverToBoxAdapter(
        child: Column(
          children: [
            WidgetConstant.divider,
            AppListTile(
              trailing: const Icon(Icons.password),
              title: Text("stellar_key_conversion".tr),
              subtitle: Text("stellar_key_conversion_desc".tr),
              onTap: () {
                context.to(PageRouter.stellarKeyConversion);
              },
            ),
          ],
        ),
      )
    ]);
  }
}
