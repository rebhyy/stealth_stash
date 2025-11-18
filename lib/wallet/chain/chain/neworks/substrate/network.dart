part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

class SubstrateChainConfig extends ChainConfig {
  final bool acceptMultisigTerm;
  final bool acceptXcmTransferTerm;
  const SubstrateChainConfig(
      {this.acceptMultisigTerm = false, this.acceptXcmTransferTerm = false});
  factory SubstrateChainConfig.deserialize(
      {List<int>? cborBytes, String? cborHex, CborObject? cborObject}) {
    final values = CborSerializable.cborTagValue(
        cborBytes: cborBytes,
        hex: cborHex,
        object: cborObject,
        tags: NetworkType.substrate.tag);
    return SubstrateChainConfig(
      acceptMultisigTerm: values.valueAs(0),
      acceptXcmTransferTerm: values.valueAs(1),
    );
  }
  SubstrateChainConfig copyWith(
      {bool? acceptMultisigTerm, bool? acceptXcmTransferTerm}) {
    return SubstrateChainConfig(
        acceptMultisigTerm: acceptMultisigTerm ?? this.acceptMultisigTerm,
        acceptXcmTransferTerm:
            acceptXcmTransferTerm ?? this.acceptXcmTransferTerm);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.definite([
          CborBoleanValue(acceptMultisigTerm),
          CborBoleanValue(acceptXcmTransferTerm),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.substrate;
}

class SubstrateNetworkController extends NetworkController<
    ISubstrateAddress,
    SubstrateChain,
    Web3SubstrateChainAccount,
    Web3InternalDefaultChain,
    SubstrateChainConfig> {
  SubstrateNetworkController({
    super.networks,
    required super.id,
  }) : super(type: NetworkType.substrate);

  @override
  Future<Web3SubstrateChainAuthenticated> createWeb3ChainAuthenticated(
    Web3ApplicationAuthentication app,
  ) async {
    final internalNetwork = await _getWeb3InternalChainAuthenticated(app);
    final web3Networks = _networks.values
        .map((e) => Web3SubstrateChainIdnetifier(
            genesisHash: e.network.genesisBlock,
            specVersion: e.network.coinParam.specVersion,
            id: e.network.value,
            wsIdentifier: e.network.wsIdentifier,
            caip2: e.network.caip,
            type: e.network.coinParam.substrateChainType,
            ss58Fromat: e.network.coinParam.ss58Format))
        .toList();
    List<Web3SubstrateChainAccount> web3Accounts = [];
    for (final i in internalNetwork.networks) {
      final network = _networks[i.networkId];
      if (network == null) continue;
      final networkAddresses = await network.getAccountAddresses();
      final List<ISubstrateAddress> addresses = [];
      for (final a in i.accounts) {
        final address = networkAddresses.firstWhereOrNull(
            (e) => e.identifier == a.identifier && e.keyIndex == a.keyIndex);
        if (address == null) continue;
        addresses.add(address);
      }
      final defaultAddress = addresses.firstWhereOrNull((e) =>
              e.identifier == i.defaultAccount?.identifier &&
              e.keyIndex == i.defaultAccount?.keyIndex) ??
          addresses.firstOrNull;
      web3Accounts.addAll(addresses.map((e) =>
          Web3SubstrateChainAccount.fromChainAccount(
              address: e, isDefault: e == defaultAddress, id: e.network)));
    }
    return Web3SubstrateChainAuthenticated(
        accounts: web3Accounts,
        currentNetwork: web3Networks
            .firstWhere((e) => e.id == internalNetwork.defaultChain),
        networks: web3Networks);
  }
}
