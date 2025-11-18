import 'package:blockchain_utils/bip/bip.dart';
import 'package:stealth_stash/app/error/exception/wallet_ex.dart';
import 'package:stealth_stash/app/models/models/image.dart';
import 'package:stealth_stash/app/serialization/cbor/cbor.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

class NetworkCoinParamsConst {
  static const String txIdArgs = "#txid";
  static const String addrArgs = "#address";
}

abstract class NetworkCoinParams with CborSerializable {
  NetworkCoinParams(
      {required this.token,
      this.chainType = ChainType.mainnet,
      this.bip32CoinType,
      this.transactionExplorer,
      this.addressExplorer});
  static Token validateUpdateParams(
      {required Token token, required Token? updateToken}) {
    if (updateToken == null) return token;
    if (updateToken.decimal != token.decimal ||
        updateToken.name.trim().isEmpty ||
        updateToken.symbol.trim().isEmpty) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
    return updateToken;
  }

  final String? transactionExplorer;
  final String? addressExplorer;
  final Token token;
  // final List<PROVIDER> providers;
  final ChainType chainType;
  bool get mainnet => chainType == ChainType.mainnet;
  bool get isTestNet => chainType == ChainType.testnet;
  int get decimal => token.decimal;
  final int? bip32CoinType;
  APPImage get logo => token.assetLogo!;
  bool get hasMarketUrl => token.market != null;
  int get averageBlockTime => 10;
  int get maxTxConfirmationBlock => 20;

  String? get marketUri {
    return token.marketUri;
  }

  NetworkCoinParams updateParams(
      {Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType});
}
