part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

final class SuiChain extends Chain<
    SuiAPIProvider,
    SuiNetworkParams,
    SuiAddress,
    SuiToken,
    NFTCore,
    ISuiAddress,
    WalletSuiNetwork,
    SuiClient,
    DefaultNetworkConfig,
    SuiWalletTransaction,
    SuiContact,
    SuiNewAddressParams> {
  SuiChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.service,
    required super.addresses,
    super.totalBalance,
  }) : super._();
  @override
  SuiChain copyWith(
      {WalletSuiNetwork? network,
      List<ChainAccount>? addresses,
      int? addressIndex,
      ProviderIdentifier? service,
      String? id,
      DefaultNetworkConfig? config,
      BigInt? totalBalance}) {
    return SuiChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<ISuiAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? totalBalance);
  }

  factory SuiChain.setup(
      {required WalletSuiNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return SuiChain._(
        network: network,
        id: id,
        addressIndex: 0,
        service: service,
        addresses: [],
        config: DefaultNetworkConfig.defaultConfig);
  }

  factory SuiChain.deserialize(
      {required WalletSuiNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<ISuiAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ISuiAddress.deserialize(network, obj: e))
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
    return SuiChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        service: service,
        id: id,
        config: config,
        totalBalance: totalBalance);
  }

  @override
  Future<void> _updateAddressBalanceInternal(ISuiAddress address,
      {bool tokens = true}) async {
    await onClient(onConnect: (client) async {
      final balance = await client.getAcountBalances(address.networkAddress);
      final native = balance.firstWhereOrNull(
          (e) => e.coinType == SuiTransactionConst.suiTypeArgs);
      address._updateAddressBalance(native?.totalBalance ?? BigInt.zero);
      for (final token in address.tokens) {
        final asset =
            balance.firstWhereOrNull((e) => e.coinType == token.assetType);
        address._updateTokenBalance(token,
            () => token._updateBalance(asset?.totalBalance ?? BigInt.zero));
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ISuiAddress address, required List<SuiToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAcountBalances(address.networkAddress);
      final native = balance.firstWhereOrNull(
          (e) => e.coinType == SuiTransactionConst.suiTypeArgs);
      address._updateAddressBalance(native?.totalBalance ?? BigInt.zero);
      for (final token in tokens) {
        final asset =
            balance.firstWhereOrNull((e) => e.coinType == token.assetType);
        address._updateTokenBalance(token,
            () => token._updateBalance(asset?.totalBalance ?? BigInt.zero));
      }
    });
  }

  @override
  ISuiAddress _deserializeAddress(List<int> adressBytes) {
    return ISuiAddress.deserialize(network, bytes: adressBytes);
  }
}
