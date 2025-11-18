import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/future/wallet/account/pages/account_controller.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/future/router/page_router.dart';

class SuiFeaturePageView extends StatelessWidget {
  const SuiFeaturePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SuiClient?, ISuiAddress?, SuiChain>(
      title: "settings".tr,
      addressRequired: false,
      clientRequired: false,
      childBulder: (wallet, account, client, address, onAccountChanged) {
        return ConstraintsBoxView(
            child: Column(
          children: [
            AppListTile(
              leading: const Icon(Icons.password),
              title: Text("sui_key_conversion".tr),
              subtitle: Text("sui_key_conversion_desc".tr),
              onTap: () {
                context.to(PageRouter.suiKeyConversion);
              },
            ),
          ],
        ));
      },
    );
  }
}
