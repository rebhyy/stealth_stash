import 'package:on_chain/on_chain.dart';
import 'package:stealth_stash/future/wallet/network/cardano/transaction/controllers/provider.dart';
import 'package:stealth_stash/future/wallet/network/cardano/transaction/types/types.dart';
import 'package:stealth_stash/future/wallet/network/cardano/web3/types/types.dart';

mixin CardanoWeb3TransactionApiController on ADATransactionApiController {
  List<Web3ADAAssetInputDetails> extractMultiAssetAssets(
      MultiAsset? multiAsset) {
    if (multiAsset == null || multiAsset == MultiAsset.empty) return [];
    Map<PolicyID, Map<AssetName, Web3ADAAssetInputDetails>> remains = {};
    for (final policy in multiAsset.assets.entries) {
      final pAssets = policy.value.assets;
      remains[policy.key] ??= {};
      for (final pAsset in pAssets.entries) {
        remains[policy.key]![pAsset.key] ??= Web3ADAAssetInputDetails.zero(
            ADAAssetToken(id: policy.key, name: pAsset.key));
        final a = remains[policy.key]![pAsset.key]!;
        a.amount.updateBalance(pAsset.value + a.amount.balance);
      }
    }
    return remains.values.expand((e) => e.values).toList();
  }
}
