part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

final class TonChain extends Chain<
    TonAPIProvider,
    TonNetworkParams,
    TonAddress,
    TonJettonToken,
    NFTCore,
    ITonAddress,
    WalletTonNetwork,
    TonClient,
    DefaultNetworkConfig,
    TonWalletTransaction,
    TonContact,
    TonNewAddressParams> {
  TonChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.service,
    required super.addresses,
    super.totalBalance,
  }) : super._();
  @override
  TonChain copyWith({
    WalletTonNetwork? network,
    List<ChainAccount>? addresses,
    List<ContactCore<TonAddress>>? contacts,
    int? addressIndex,
    ProviderIdentifier? service,
    String? id,
    DefaultNetworkConfig? config,
    BigInt? totalBalance,
  }) {
    return TonChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<ITonAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? this.totalBalance.value.balance);
  }

  factory TonChain.setup(
      {required WalletTonNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return TonChain._(
        network: network,
        id: id,
        addressIndex: 0,
        service: service,
        addresses: [],
        config: DefaultNetworkConfig.defaultConfig);
  }

  factory TonChain.deserialize(
      {required WalletTonNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<ITonAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ITonAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    DefaultNetworkConfig config =
        DefaultNetworkConfig.deserialize(cborObject: cbor.indexAs(5));
    final ProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    final BigInt? totalBalance = cbor.elementAs<BigInt?>(7);
    return TonChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        service: service,
        id: id,
        totalBalance: totalBalance,
        config: config);
  }

  @override
  Future<void> _updateAddressBalanceInternal(ITonAddress address,
      {bool tokens = true}) async {
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      address._updateAddressBalance(balance);
      if (tokens) {
        final tokens = address.tokens;
        final balances = await Future.wait(tokens.map((e) async {
          try {
            return await client.getJettonWalletData(e.walletAddress);
          } catch (_) {
            return null;
          }
        }));
        for (int i = 0; i < tokens.length; i++) {
          final token = tokens[i];
          final balance = balances[i];
          if (balance == null) continue;
          address._updateTokenBalance(
              token, () => token._updateBalance(balance.balance));
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ITonAddress address,
      required List<TonJettonToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balances = await Future.wait(tokens.map((e) async {
        try {
          return await client.getJettonWalletData(e.walletAddress);
        } catch (_) {
          return null;
        }
      }));
      for (int i = 0; i < tokens.length; i++) {
        final token = tokens[i];
        final balance = balances[i];
        if (balance == null) continue;
        address._updateTokenBalance(
            token, () => token._updateBalance(balance.balance));
      }
    });
  }

  @override
  ITonAddress _deserializeAddress(List<int> adressBytes) {
    return ITonAddress.deserialize(network, bytes: adressBytes);
  }
}
