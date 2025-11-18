part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

final class SolanaChain extends Chain<
    SolanaAPIProvider,
    SolanaNetworkParams,
    SolAddress,
    SolanaSPLToken,
    NFTCore,
    ISolanaAddress,
    WalletSolanaNetwork,
    SolanaClient,
    DefaultNetworkConfig,
    SolanaWalletTransaction,
    SolanaContact,
    SolanaNewAddressParams> {
  SolanaChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.service,
      required super.addresses,
      super.totalBalance})
      : super._();
  @override
  SolanaChain copyWith(
      {WalletSolanaNetwork? network,
      List<ChainAccount>? addresses,
      int? addressIndex,
      ProviderIdentifier? service,
      String? id,
      DefaultNetworkConfig? config,
      BigInt? totalBalance}) {
    return SolanaChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<ISolanaAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? this.totalBalance._value.balance);
  }

  factory SolanaChain.setup(
      {required WalletSolanaNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return SolanaChain._(
        network: network,
        id: id,
        addressIndex: 0,
        service: service,
        addresses: [],
        config: DefaultNetworkConfig.defaultConfig);
  }

  factory SolanaChain.deserialize(
      {required WalletSolanaNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<ISolanaAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ISolanaAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    final DefaultNetworkConfig config =
        DefaultNetworkConfig.deserialize(cborObject: cbor.indexAs(5));
    final ProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    final BigInt? totalBalance = cbor.elementAs<BigInt?>(7);
    return SolanaChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        service: service,
        id: id,
        totalBalance: totalBalance,
        config: config);
  }

  @override
  Future<void> _updateAddressBalanceInternal(ISolanaAddress address,
      {bool tokens = true}) async {
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      address._updateAddressBalance(balance);
      if (tokens) {
        final tokens = address.tokens;
        final balances = await Future.wait(tokens.map((e) async {
          try {
            return await client.getTokenAddressBalance(e.tokenAccount);
          } catch (_) {
            return null;
          }
        }));
        for (int i = 0; i < tokens.length; i++) {
          final token = tokens[i];
          final balance = balances[i];
          if (balance == null) continue;
          address._updateTokenBalance(
              token, () => token._updateBalance(balance));
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ISolanaAddress address,
      required List<SolanaSPLToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balances = await Future.wait(tokens.map((e) async {
        try {
          return await client.getTokenAddressBalance(e.tokenAccount);
        } catch (_) {
          return null;
        }
      }));
      for (int i = 0; i < tokens.length; i++) {
        final token = tokens[i];
        final balance = balances[i];
        if (balance == null) continue;
        address._updateTokenBalance(token, () => token._updateBalance(balance));
      }
    });
  }

  @override
  ISolanaAddress _deserializeAddress(List<int> adressBytes) {
    return ISolanaAddress.deserialize(network, bytes: adressBytes);
  }
}
