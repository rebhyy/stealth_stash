import 'package:on_chain/on_chain.dart';
import 'package:stealth_stash/wallet/models/networks/tron/models/chain_type.dart';

class TronClientUtils {
  static const tronScanMaxTokenLimit = 50;
  static const String tronScanAccountTokenListUrl =
      "https://#api.tronscan.org/api/account/tokens?address=#address&start=#start&limit=#limit&hidden=0&show=0&sortType=0&sortBy=0&token=";
  static String getTronScanNetworkSubdomain(TronChainType chain) {
    switch (chain) {
      case TronChainType.mainnet:
        return "apilist";
      case TronChainType.shasta:
        return "shastapi";
      case TronChainType.nile:
        return "nileapi";
    }
  }

  static String buildTronScanUrl(
      {required TronAddress address,
      required TronChainType chain,
      int limit = tronScanMaxTokenLimit,
      int start = 0}) {
    return tronScanAccountTokenListUrl
        .replaceAll("#api", getTronScanNetworkSubdomain(chain))
        .replaceFirst("#address", address.toAddress())
        .replaceFirst("#limit", limit.toString())
        .replaceFirst("#start", start.toString());
  }
}
