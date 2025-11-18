import 'package:stealth_stash/future/wallet/network/cardano/transaction/controllers/provider.dart';
import 'package:stealth_stash/future/wallet/network/cardano/web3/types/types.dart';
import 'package:stealth_stash/wallet/web3/networks/cardano/params/core/request.dart';

import 'provider.dart';

abstract class Web3CardanoTransactionStateController<RESPONSE,
        T extends Web3ADARequestParam<RESPONSE>>
    extends BaseWeb3CardanoTransactionStateController<RESPONSE, T>
    with ADATransactionApiController, CardanoWeb3TransactionApiController {
  Web3CardanoTransactionStateController(
      {required super.walletProvider, required super.request});
}
