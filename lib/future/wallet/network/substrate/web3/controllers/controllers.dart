import 'package:stealth_stash/future/wallet/network/substrate/transaction/controllers/fee.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/controllers/provider.dart';
import 'package:stealth_stash/future/wallet/network/substrate/web3/types/types.dart';
import 'package:stealth_stash/wallet/web3/networks/substrate/params/core/request.dart';

abstract class Web3SubstrateTransactionStateController<
        RESPONSE,
        T extends Web3SubstrateRequestParam<RESPONSE>,
        E extends IWeb3SubstrateTransactionData>
    extends BaseWeb3SubstrateTransactionStateController<RESPONSE, T, E>
    with SubstrateTransactionApiController, SubstrateTransactionFeeController {
  Web3SubstrateTransactionStateController(
      {required super.walletProvider, required super.request});
}
