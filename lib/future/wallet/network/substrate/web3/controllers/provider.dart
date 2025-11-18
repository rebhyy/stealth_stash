import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/wallet/wallet.dart';

mixin SubstrateWeb3TransactionApiController on DisposableMixin {
  SubstrateClient get client;
}
