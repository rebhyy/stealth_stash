part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

class ADANetworkStorageId extends DefaultNetworkStorageId {
  static const ADANetworkStorageId utxos = ADANetworkStorageId(11);
  const ADANetworkStorageId(super.storageId);
  static const List<DefaultNetworkStorageId> values = [
    ...DefaultNetworkStorageId.values,
    utxos,
  ];
}

class ADANetworkConfig extends DefaultNetworkConfig<ADANetworkStorageId> {
  ADANetworkConfig(
      {super.supportToken = false,
      super.supportNft = false,
      super.supportWeb3 = true,
      super.enableProvider = true});
  factory ADANetworkConfig.deserialize(
      {List<int>? cborBytes, String? cborHex, CborObject? cborObject}) {
    final values = CborSerializable.cborTagValue(
        cborBytes: cborBytes, hex: cborHex, object: cborObject);
    return ADANetworkConfig(
      supportToken: values.valueAs<bool?>(0) ?? false,
      supportNft: values.valueAs<bool?>(1) ?? false,
      supportWeb3: values.valueAs<bool?>(2) ?? true,
      enableProvider: values.valueAs<bool?>(3) ?? true,
    );
  }
  @override
  ADANetworkConfig copyWith(
      {bool? supportToken,
      bool? supportNft,
      bool? supportWeb3,
      bool? enableProvider}) {
    return ADANetworkConfig(
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
        CborTagsConst.cardanoChainConfig);
  }

  @override
  List<DefaultNetworkStorageId> get storageKeys => ADANetworkStorageId.values;
}

final class ADAChain extends Chain<
    CardanoAPIProvider,
    CardanoNetworkParams,
    ADAAddress,
    TokenCore,
    NFTCore,
    ICardanoAddress,
    WalletCardanoNetwork,
    ADAClient,
    ADANetworkConfig,
    ADAWalletTransaction,
    CardanoContact,
    BaseCardanoNewAddressParams> with ADAChainController {
  ADAChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.service,
    required super.addresses,
    super.totalBalance,
  }) : super._();
  @override
  ADAChain copyWith({
    WalletCardanoNetwork? network,
    List<ChainAccount>? addresses,
    int? addressIndex,
    ProviderIdentifier? service,
    String? id,
    ADANetworkConfig? config,
    BigInt? totalBalance,
  }) {
    return ADAChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<ICardanoAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? this.totalBalance._value.balance);
  }

  factory ADAChain.setup(
      {required WalletCardanoNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return ADAChain._(
        network: network,
        addressIndex: 0,
        id: id,
        service: service,
        addresses: [],
        config: ADANetworkConfig());
  }

  factory ADAChain.deserialize(
      {required WalletCardanoNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<ICardanoAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ICardanoAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    final ADANetworkConfig config =
        ADANetworkConfig.deserialize(cborObject: cbor.indexAs(5));
    final ProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    final BigInt? totalBalance = cbor.elementAs<BigInt?>(7);
    return ADAChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        service: service,
        id: id,
        config: config,
        totalBalance: totalBalance);
  }

  @override
  Future<void> updateTokenBalance(
      {required ICardanoAddress address,
      required List<TokenCore<BalanceCore<dynamic, APPToken>, APPToken>>
          tokens}) async {
    throw UnimplementedError();
  }

  @override
  ICardanoAddress _deserializeAddress(List<int> adressBytes) {
    return ICardanoAddress.deserialize(network, bytes: adressBytes);
  }
}
