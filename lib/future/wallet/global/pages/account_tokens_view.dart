import 'package:flutter/material.dart';
import 'package:stealth_stash/app/constant/global/app.dart';
import 'package:stealth_stash/crypto/types/networks.dart';
import 'package:stealth_stash/future/router/page_router.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/global.dart';
import 'package:stealth_stash/future/wallet/global/pages/types.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';

class AccountTokensView<TOKEN extends TokenCore, ACCOUNT extends ChainAccount>
    extends StatelessWidget {
  const AccountTokensView(
      {super.key,
      required this.account,
      this.importTokenPage,
      required this.transferBuilder});
  final String? importTokenPage;
  final APPCHAINACCOUNT<ACCOUNT> account;
  final TOKENTRANSFERBUILDER<TOKEN> transferBuilder;
  ACCOUNT get address => account.address;

  @override
  Widget build(BuildContext context) {
    return ChainStreamBuilder(
        allowNotify: [DefaultChainNotify.token],
        builder: (context, chain, lastNotify) {
          final tokens = address.tokens.whereType<TOKEN>().toList();
          final isTron = account.network.type == NetworkType.tron;
          tokens.sort((a, b) {
            int score(TokenCore t) {
              final sym = t.token.symbol.toUpperCase();
              return (sym == "USDT" || sym == "USDC") ? 0 : 1;
            }

            final s = score(a).compareTo(score(b));
            if (s != 0) return s;
            return a.token.symbol.compareTo(b.token.symbol);
          });

          return AccountTabbarScrollWidget(slivers: [
            EmptyItemSliverWidgetView(
              isEmpty: tokens.isEmpty,
              onEmpty: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.token, size: APPConst.double80),
                  WidgetConstant.height8,
                  Text("no_tokens_found".tr),
                  WidgetConstant.height20,
                  FilledButton(
                      onPressed: () {
                        context.to(PageRouter.manageTokens);
                      },
                      child: Text("monitor_my_tokens".tr))
                ],
              ),
              itemBuilder: (context) => SliverToBoxAdapter(
                child: AppListTile(
                    leading: const Icon(Icons.token),
                    onTap: () {
                      context.to(PageRouter.manageTokens);
                    },
                    title: Text("manage_tokens".tr),
                    subtitle: Text("add_or_remove_tokens".tr)),
              ),
            ),
            if (isTron)
              SliverToBoxAdapter(
                  child: Padding(
                padding: WidgetConstant.paddingHorizontal20,
                child: AlertTextContainer(
                    message: "tron_fee_tip_desc".tr,
                    icon: Icons.info_outline),
              )),
            SliverList.builder(
                itemBuilder: (context, index) {
                  final token = tokens[index];
                  return AccountTokenDetailsView(
                    token: token,
                    onSelectWidget: WidgetConstant.sizedBox,
                    onSelect: () {
                      context.openDialogPage<TokenAction>("token_info".tr,
                          child: (ctx) => TokenDetailsModalView<TOKEN, ACCOUNT>(
                              token: token,
                              address: address,
                              account: account,
                              transferBuilder: transferBuilder));
                    },
                  );
                },
                itemCount: tokens.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false)
          ]);
        },
        account: account);
  }
}
