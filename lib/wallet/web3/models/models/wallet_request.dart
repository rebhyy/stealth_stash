import 'package:stealth_stash/wallet/web3/core/core.dart';

class WalletWeb3Request {
  final Web3RequestParams message;
  final Web3RequestApplicationInformation info;
  final Web3ApplicationAuthentication appAuthenticated;
  WalletWeb3Request(
      {required this.info,
      required this.appAuthenticated,
      required this.message});
}
