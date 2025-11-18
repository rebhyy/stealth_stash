part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

class XRPChainConfig extends DefaultNetworkConfig {
  XRPChainConfig(
      {super.supportToken = true,
      super.supportNft = true,
      super.supportWeb3 = true,
      super.enableProvider = true});
  factory XRPChainConfig.deserialize(
      {List<int>? cborBytes, String? cborHex, CborObject? cborObject}) {
    final values = CborSerializable.cborTagValue(
        cborBytes: cborBytes,
        hex: cborHex,
        object: cborObject,
        tags: CborTagsConst.defaultNetworkConfig);
    return XRPChainConfig(
      supportToken:
          values.indexMaybeAs<bool, CborBoleanValue>(0, (e) => e.value) ?? true,
      supportNft:
          values.indexMaybeAs<bool, CborBoleanValue>(1, (e) => e.value) ?? true,
      supportWeb3:
          values.indexMaybeAs<bool, CborBoleanValue>(2, (e) => e.value) ?? true,
      enableProvider:
          values.indexMaybeAs<bool, CborBoleanValue>(3, (e) => e.value) ?? true,
    );
  }
  @override
  XRPChainConfig copyWith(
      {bool? supportToken,
      bool? supportNft,
      bool? supportWeb3,
      bool? enableProvider}) {
    return XRPChainConfig(
        supportToken: supportToken ?? this.supportToken,
        supportNft: supportNft ?? this.supportNft,
        supportWeb3: supportWeb3 ?? this.supportWeb3,
        enableProvider: enableProvider ?? this.enableProvider);
  }
}

final class XRPChain extends Chain<
    RippleAPIProvider,
    RippleNetworkParams,
    XRPAddress,
    RippleIssueToken,
    RippleNFToken,
    IXRPAddress,
    WalletXRPNetwork,
    XRPClient,
    XRPChainConfig,
    XRPWalletTransaction,
    RippleContact,
    RippleNewAddressParams> with XRPChainController {
  XRPChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.service,
    required super.addresses,
    super.totalBalance,
  }) : super._();
  @override
  XRPChain copyWith({
    WalletXRPNetwork? network,
    List<ChainAccount>? addresses,
    List<ContactCore<XRPAddress>>? contacts,
    int? addressIndex,
    ProviderIdentifier? service,
    String? id,
    XRPChainConfig? config,
    BigInt? totalBalance,
  }) {
    return XRPChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses?.cast<IXRPAddress>() ?? _addresses,
        service: service ?? _serviceIdentifier,
        id: id ?? this.id,
        config: config ?? this.config,
        totalBalance: totalBalance ?? this.totalBalance.value.balance);
  }

  factory XRPChain.setup(
      {required WalletXRPNetwork network,
      required String id,
      ProviderIdentifier? service}) {
    return XRPChain._(
        network: network,
        id: id,
        addressIndex: 0,
        service: service,
        addresses: [],
        config: XRPChainConfig());
  }

  factory XRPChain.deserialize(
      {required WalletXRPNetwork network, required CborListValue cbor}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAs<String>(2);
    final List<IXRPAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => IXRPAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    XRPChainConfig config =
        XRPChainConfig.deserialize(cborObject: cbor.indexAs(5));
    final ProviderIdentifier? service = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = cbor.elementAs(6);

      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });

    final BigInt? totalBalance = cbor.elementAs<BigInt?>(7);
    return XRPChain._(
        network: network,
        addresses: accounts,
        config: config,
        addressIndex: addressIndex < 0 ? 0 : addressIndex,
        service: service,
        id: id,
        totalBalance: totalBalance);
  }

  @override
  IXRPAddress? getAddress(String address) {
    return super.getAddress(address) ??
        _addresses
            .firstWhereOrNull((element) => element.baseAddress == address);
  }

  @override
  Future<void> _updateAddressBalanceInternal(IXRPAddress address,
      {bool tokens = true}) async {
    bool balanceChanged = false;
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      balanceChanged |= await address._updateAddressBalance(balance);
      if (tokens) {
        final tokens = address.tokens;
        if (tokens.isEmpty) return;
        final balances = await client.getAccountTokens(address.networkAddress);
        for (final i in tokens) {
          final currentUpdate = balances.firstWhereOrNull((element) =>
              element.issuer.address == i.issuer &&
              element.currency == i.assetCode);
          balanceChanged |= await address._updateTokenBalance(
              i,
              () => i._updateBalance(
                  BigRational.parseDecimal(currentUpdate?.balance ?? "0")));
        }
      }
    });
    if (balanceChanged || true) _getAccountTxes(address);
  }

  @override
  Future<void> updateTokenBalance(
      {required IXRPAddress address,
      required List<RippleIssueToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      if (tokens.isEmpty) return;
      final balances = await client.getAccountTokens(address.networkAddress);
      for (final i in tokens) {
        final currentUpdate = balances.firstWhereOrNull((element) =>
            element.issuer.address == i.issuer &&
            element.currency == i.assetCode);
        address._updateTokenBalance(
            i,
            () => i._updateBalance(
                BigRational.parseDecimal(currentUpdate?.balance ?? "0")));
      }
    });
  }

  @override
  IXRPAddress _deserializeAddress(List<int> adressBytes) {
    return IXRPAddress.deserialize(network, bytes: adressBytes);
  }
}
