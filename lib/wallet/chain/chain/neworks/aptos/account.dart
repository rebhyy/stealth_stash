part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

final class AptosChain extends Chain<
    AptosAPIProvider,
    AptosNetworkParams,
    AptosAddress,
    AptosFATokens,
    NFTCore,
    IAptosAddress,
    WalletAptosNetwork,
    AptosClient,
    DefaultNetworkConfig,
    AptosWalletTransaction,
    AptosContact,
    AptosNewAddressParams> {
  AptosChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      DefaultNetworkConfig? config,
      required super.service,
      required super.addresses,
      super.totalBalance})
      : super._(config: config ?? DefaultNetworkConfig.defaultConfig);
  @override
  AptosChain copyWith(
      {WalletAptosNetwork? network,
      List<ChainAccount>? addresses,
      int? addressIndex,
      ProviderIdentifier? service,
      String? id,
      DefaultNetworkConfig? config,
      BigInt? totalBalance}) {
    return AptosChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<IAptosAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? this.totalBalance.value._balance);
  }

  factory AptosChain.setup(
      {required WalletAptosNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return AptosChain._(
        network: network,
        id: id,
        addressIndex: 0,
        service: service,
        addresses: []);
  }

  factory AptosChain.deserialize(
      {required WalletAptosNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<IAptosAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => IAptosAddress.deserialize(network, obj: e))
        .toList();

    int addressIndex = cbor.elementAs(4);
    final AptosProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);
      if (identifier == null) return null;
      return AptosProviderIdentifier.deserialize(cbor: identifier);
    });
    BigInt? totalBalance = cbor.elementAs(7);
    return AptosChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        service: service,
        id: id,
        totalBalance: totalBalance);
  }

  @override
  Future<void> _updateAddressBalanceInternal(IAptosAddress address,
      {bool tokens = true}) async {
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      address._updateAddressBalance(balance);
      if (tokens) {
        final accountTokens = address.tokens;
        final tokenbalances = await client.getAccountTokenBalances(
            address: address.networkAddress,
            assetTypes: accountTokens.map((e) => e.assetType).toList());
        for (final token in accountTokens) {
          final balance = tokenbalances
              .firstWhereOrNull((e) => e.assetType == token.assetType);
          address._updateTokenBalance(token, () {
            bool changed =
                token._updateBalance(balance?.balance ?? BigInt.zero);
            changed |= token.setFreeze(balance?.frozen ?? false);
            return changed;
          });
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required IAptosAddress address,
      required List<AptosFATokens> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final tokenbalances = await client.getAccountTokenBalances(
          address: address.networkAddress,
          assetTypes: tokens.map((e) => e.assetType).toList());
      for (final token in tokens) {
        final balance = tokenbalances
            .firstWhereOrNull((e) => e.assetType == token.assetType);
        address._updateTokenBalance(token, () {
          bool changed = token._updateBalance(balance?.balance ?? BigInt.zero);
          changed |= token.setFreeze(balance?.frozen ?? false);
          return changed;
        });
      }
    });
  }

  @override
  IAptosAddress _deserializeAddress(List<int> adressBytes) {
    return IAptosAddress.deserialize(network, bytes: adressBytes);
  }
}
