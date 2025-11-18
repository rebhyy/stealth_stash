import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/models/models.dart';

class Web3ChainNetworkData<NETWORK extends WalletNetwork> {
  final NETWORK network;
  final ProviderIdentifier? serviceIdentifier;
  const Web3ChainNetworkData(
      {required this.network, required this.serviceIdentifier});
}
