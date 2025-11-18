import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/future/wallet/account/pages/account_controller.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/future/router/page_router.dart';

class TonSettingsView extends StatelessWidget {
  const TonSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<TonClient?, ITonAddress?, TonChain>(
      title: "settings".tr,
      addressRequired: false,
      clientRequired: false,
      childBulder: (wallet, account, client, address, onAccountChanged) {
        return ConstraintsBoxView(
            child: Column(
          children: [
            AppListTile(
              leading: const Icon(Icons.password),
              title: Text("ton_mnemonic".tr),
              subtitle: Text("generate_ton_private_key".tr),
              onTap: () {
                context.to(PageRouter.tonMnemonic);
              },
            ),
          ],
        ));
      },
    );
  }
}
