import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/controller/wallet/ui_wallet.dart';
import 'package:stealth_stash/wallet/models/others/models/wallet.dart';

UIWallet uiWallet(GlobalKey<NavigatorState> navigatorKey, int storageVersion) =>
    Wallet(navigatorKey: navigatorKey, storageVersion: storageVersion);

class Wallet extends UIWallet {
  Wallet({required super.navigatorKey, required super.storageVersion});

  @override
  Future<void> onWalletEvent(WalletActionEvent status) async {}
}
