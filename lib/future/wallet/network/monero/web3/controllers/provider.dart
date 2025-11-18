import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/wallet/wallet.dart';

mixin MoneroWeb3TransactionApiController on DisposableMixin {
  MoneroClient get client;
  WalletMoneroNetwork get network;
}
