import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/wallet/network/ethereum/transaction/operations/transfer_token.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/future/router/page_router.dart';

class ETHAccountPageView extends StatelessWidget {
  const ETHAccountPageView({required this.chainAccount, super.key});
  final EthereumChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _EtherumServices(chainAccount),
      AccountTokensView<ETHERC20Token, IEthAddress>(
        account: chainAccount,
        importTokenPage: PageRouter.importERC20Token,
        transferBuilder: (p0) {
          return EthereumTransactionTransferTokenOperation(
              address: chainAccount.address,
              account: chainAccount,
              walletProvider: context.wallet,
              token: p0);
        },
      ),
      AccountTransactionActivityView<IEthAddress, EthWalletTransaction>(
          account: chainAccount, address: chainAccount.address)
    ]);
  }
}

class _EtherumServices extends StatelessWidget {
  final EthereumChain account;
  const _EtherumServices(this.account);

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: AppListTile(
          title: Text("import_erc20_token".tr),
          onTap: () {
            context.to(PageRouter.importERC20Token);
          },
        ),
      ),
    ]);
  }
}
