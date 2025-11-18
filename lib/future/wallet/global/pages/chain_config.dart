import 'package:stealth_stash/crypto/types/networks.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/future/wallet/global/pages/types.dart';
import 'package:stealth_stash/wallet/chain/account.dart';

typedef ONCREATECHAINCONFIG<CONFIG extends ChainConfig> = CONFIG Function();

abstract mixin class ChainConfigStateController<
    T extends Chain,
    CONFIG extends ChainConfig,
    CONTROLLER extends APPCHAINNETWORKCONTROLLERCONFIG<T, CONFIG>> {
  Future<CONFIG> getChainConfig(
      {required WalletProvider walletProvider,
      required NetworkType type,
      required ONCREATECHAINCONFIG<CONFIG> onCreate}) async {
    final controller = walletProvider.wallet.chainController<CONTROLLER>(type);
    final config = await controller?.getConfig();
    return config ?? onCreate();
  }

  Future<void> updateChainConfig({
    required WalletProvider walletProvider,
    required CONFIG config,
    required NetworkType type,
  }) async {
    final controller = walletProvider.wallet.chainController<CONTROLLER>(type);
    assert(controller != null);
    await controller?.updateConfig(config);
  }
}
