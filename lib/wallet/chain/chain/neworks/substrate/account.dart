part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

class SubstrateNetworkStorageId extends DefaultNetworkStorageId {
  static const SubstrateNetworkStorageId multisigTransactions =
      SubstrateNetworkStorageId(11);
  const SubstrateNetworkStorageId(super.storageId);
  static const List<DefaultNetworkStorageId> values = [
    ...DefaultNetworkStorageId.values,
    multisigTransactions,
  ];
}

class SubstrateNetworkConfig
    extends DefaultNetworkConfig<SubstrateNetworkStorageId> {
  @override
  List<DefaultNetworkStorageId> get storageKeys =>
      SubstrateNetworkStorageId.values;

  SubstrateNetworkConfig(
      {super.supportToken = true,
      super.supportNft = false,
      super.supportWeb3 = true,
      super.enableProvider = true});
  factory SubstrateNetworkConfig.deserialize(
      {List<int>? cborBytes, String? cborHex, CborObject? cborObject}) {
    final values = CborSerializable.cborTagValue(
        cborBytes: cborBytes, hex: cborHex, object: cborObject);
    return SubstrateNetworkConfig(
      supportToken: values.valueAs<bool?>(0) ?? true,
      supportNft: values.valueAs<bool?>(1) ?? false,
      supportWeb3: values.valueAs<bool?>(2) ?? true,
      enableProvider: values.valueAs<bool?>(3) ?? true,
    );
  }
  @override
  SubstrateNetworkConfig copyWith(
      {bool? supportToken,
      bool? supportNft,
      bool? supportWeb3,
      bool? enableProvider}) {
    return SubstrateNetworkConfig(
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
        CborTagsConst.substrateChainConfig);
  }
}

final class SubstrateChain extends Chain<
    SubstrateAPIProvider,
    SubstrateNetworkParams,
    BaseSubstrateAddress,
    SubstrateToken,
    NFTCore,
    ISubstrateAddress,
    WalletSubstrateNetwork,
    SubstrateClient,
    SubstrateNetworkConfig,
    SubstrateWalletTransaction,
    SubstrateContact,
    SubstrateNewAddressParams> with SubstrateChainController {
  SubstrateChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      SubstrateNetworkConfig? config,
      required super.service,
      required super.addresses,
      super.totalBalance})
      : super._(config: config ?? SubstrateNetworkConfig());
  @override
  SubstrateChain copyWith(
      {WalletSubstrateNetwork? network,
      List<ChainAccount>? addresses,
      int? addressIndex,
      ProviderIdentifier? service,
      String? id,
      SubstrateNetworkConfig? config,
      BigInt? totalBalance}) {
    return SubstrateChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<ISubstrateAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory SubstrateChain.setup(
      {required WalletSubstrateNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return SubstrateChain._(
        network: network,
        id: id,
        addressIndex: 0,
        service: service,
        addresses: []);
  }

  factory SubstrateChain.deserialize(
      {required WalletSubstrateNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<ISubstrateAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ISubstrateAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    final ProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    final BigInt? totalBalance = cbor.elementAs<BigInt?>(7);
    return SubstrateChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        service: service,
        id: id,
        totalBalance: totalBalance);
  }

  @override
  Future<void> _updateAddressBalanceInternal(ISubstrateAddress address,
      {bool tokens = true}) async {
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      address._updateAddressBalance(balance);
      if (tokens) {
        final balances = await client.getAddressTokensBalances(
            address: address.networkAddress,
            identifiers: address.tokens.map((e) => e.assetIdentifier).toList());
        for (final i in address.tokens) {
          final balance = balances.firstWhereOrNull(
              (e) => e.asset.identifierEqual(i.assetIdentifier));
          address._updateTokenBalance(
              i, () => i._updateBalance(balance?.free ?? BigInt.zero));
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ISubstrateAddress address,
      required List<SubstrateToken> tokens}) async {
    await onClient(onConnect: (client) async {
      final balances = await client.getAddressTokensBalances(
          address: address.networkAddress,
          identifiers: tokens.map((e) => e.assetIdentifier).toList());
      for (final i in tokens) {
        final balance = balances.firstWhereOrNull(
            (e) => e.asset.identifierEqual(i.assetIdentifier));
        assert(balance != null, "token not found.");
        address._updateTokenBalance(
            i, () => i._updateBalance(balance?.free ?? BigInt.zero));
      }
    });
  }

  @override
  ISubstrateAddress _deserializeAddress(List<int> adressBytes) {
    return ISubstrateAddress.deserialize(network, bytes: adressBytes);
  }
}
