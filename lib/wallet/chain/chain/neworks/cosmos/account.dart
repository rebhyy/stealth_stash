part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

class CosmosNetowkStorageId extends DefaultNetworkStorageId {
  static const CosmosNetowkStorageId channelIds = CosmosNetowkStorageId(11);
  const CosmosNetowkStorageId(super.storageId);
  static const List<DefaultNetworkStorageId> values = [
    ...DefaultNetworkStorageId.values,
    channelIds
  ];
}

class CosmosNetworkConfig extends DefaultNetworkConfig<CosmosNetowkStorageId> {
  CosmosNetworkConfig(
      {super.supportToken = true,
      super.supportNft = false,
      super.supportWeb3 = true,
      super.enableProvider = true});
  factory CosmosNetworkConfig.deserialize(
      {List<int>? cborBytes, String? cborHex, CborObject? cborObject}) {
    final values = CborSerializable.cborTagValue(
        cborBytes: cborBytes, hex: cborHex, object: cborObject);
    return CosmosNetworkConfig(
      supportToken: values.valueAs<bool?>(0) ?? true,
      supportNft: values.valueAs<bool?>(1) ?? false,
      supportWeb3: values.valueAs<bool?>(2) ?? true,
      enableProvider: values.valueAs<bool?>(3) ?? true,
    );
  }
  @override
  CosmosNetworkConfig copyWith(
      {bool? supportToken,
      bool? supportNft,
      bool? supportWeb3,
      bool? enableProvider}) {
    return CosmosNetworkConfig(
        supportToken: supportToken ?? this.supportToken,
        supportNft: supportNft ?? this.supportNft,
        supportWeb3: supportWeb3 ?? this.supportWeb3,
        enableProvider: enableProvider ?? this.enableProvider);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          supportToken,
          supportNft,
          supportWeb3,
          enableProvider,
        ]),
        CborTagsConst.cosmosChainConfig);
  }

  @override
  List<DefaultNetworkStorageId> get storageKeys => CosmosNetowkStorageId.values;
}

final class CosmosChain extends Chain<
    CosmosAPIProvider,
    CosmosNetworkParams,
    CosmosBaseAddress,
    CW20Token,
    NFTCore,
    ICosmosAddress,
    WalletCosmosNetwork,
    CosmosClient,
    CosmosNetworkConfig,
    CosmosWalletTransaction,
    CosmosContact,
    CosmosNewAddressParams> with CosmosChainRepository {
  CosmosChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.service,
      required super.addresses,
      super.totalBalance})
      : super._();
  @override
  CosmosChain copyWith(
      {WalletCosmosNetwork? network,
      List<ChainAccount>? addresses,
      int? addressIndex,
      ProviderIdentifier? service,
      String? id,
      CosmosNetworkConfig? config,
      BigInt? totalBalance}) {
    return CosmosChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<ICosmosAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? this.totalBalance._value.balance);
  }

  factory CosmosChain.setup(
      {required WalletCosmosNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return CosmosChain._(
        network: network,
        id: id,
        addressIndex: 0,
        service: service,
        addresses: [],
        config: CosmosNetworkConfig());
  }
  factory CosmosChain.deserialize(
      {required WalletCosmosNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<ICosmosAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ICosmosAddress.deserialize(network, obj: e))
        .toList();
    int addressIndex = cbor.elementAs(4);
    final config = CosmosNetworkConfig.deserialize(cborObject: cbor.indexAs(5));
    final ProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    BigInt? totalBalance = cbor.elementAs<BigInt?>(7);
    return CosmosChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        service: service,
        id: id,
        config: config,
        totalBalance: totalBalance);
  }

  @override
  Future<void> _updateAddressBalanceInternal(ICosmosAddress address,
      {bool tokens = true}) async {
    await onClient(onConnect: (client) async {
      final balances = await client.getAddressCoins(address.networkAddress);
      final nativeToken =
          balances.firstWhereOrNull((e) => e.denom == network.coinParam.denom);
      address._updateAddressBalance(nativeToken?.amount ?? BigInt.zero);
      for (final i in address.tokens) {
        final balance = balances.firstWhereOrNull((e) => e.denom == i.denom);
        await address._updateTokenBalance(
            i, () => i._updateBalance(balance?.amount ?? BigInt.zero));
      }
    });
  }

  Future<void> saveChannelId(CosmosIBCChannelId channel) async {
    await _callSynchronized(t: () async {
      await _saveChannelId(channel);
    });
  }

  @override
  Future<void> _initInternal({bool client = true}) async {
    await super._initInternal(client: client);
    _loadChannelIds();
  }

  @override
  Future<void> updateTokenBalance(
      {required ICosmosAddress address,
      required List<CW20Token> tokens}) async {
    await onClient(onConnect: (client) async {
      final balances = await client.getAddressCoins(address.networkAddress);
      final nativeToken =
          balances.firstWhereOrNull((e) => e.denom == network.coinParam.denom);
      address._updateAddressBalance(nativeToken?.amount ?? BigInt.zero);
      for (final i in tokens) {
        final balance = balances.firstWhereOrNull((e) => e.denom == i.denom);
        address._updateTokenBalance(
            i, () => i._updateBalance(balance?.amount ?? BigInt.zero));
      }
    });
  }

  @override
  ICosmosAddress _deserializeAddress(List<int> adressBytes) {
    return ICosmosAddress.deserialize(network, bytes: adressBytes);
  }
}
