part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

final class MoneroChain extends Chain<
    MoneroAPIProvider,
    MoneroNetworkParams,
    MoneroAddress,
    TokenCore,
    NFTCore,
    IMoneroAddress,
    WalletMoneroNetwork,
    MoneroClient,
    MoneroNetworkConfig,
    MoneroWalletTransaction,
    MoneroContact,
    MoneroNewAddressParams> with MoneroChainRepository, MoneroChainController {
  MoneroChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.service,
      required super.addresses,
      super.totalBalance})
      : super._();
  @override
  MoneroChain copyWith({
    WalletMoneroNetwork? network,
    List<ChainAccount>? addresses,
    int? addressIndex,
    ProviderIdentifier? service,
    String? id,
    MoneroNetworkConfig? config,
    BigInt? totalBalance,
  }) {
    return MoneroChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<IMoneroAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? this.totalBalance._value.balance);
  }

  factory MoneroChain.setup(
      {required WalletMoneroNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return MoneroChain._(
        network: network,
        addressIndex: 0,
        id: id,
        service: service,
        config: MoneroNetworkConfig(),
        addresses: []);
  }

  factory MoneroChain.deserialize(
      {required WalletMoneroNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<IMoneroAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => IMoneroAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    final config = MoneroNetworkConfig.deserialize(
        object: cbor.elementAs<CborTagValue>(5));
    final ProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    final BigInt? totalBalance = cbor.elementAs<BigInt?>(7);
    return MoneroChain._(
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
      {required IMoneroAddress address,
      required List<TokenCore<BalanceCore<dynamic, APPToken>, APPToken>>
          tokens}) async {}

  @override
  IMoneroAddress _deserializeAddress(List<int> adressBytes) {
    return IMoneroAddress.deserialize(network, bytes: adressBytes);
  }
}
