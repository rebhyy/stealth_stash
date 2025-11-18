part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

final class ISubstrateAddress extends ChainAccount<BaseSubstrateAddress,
    SubstrateToken, NFTCore, SubstrateWalletTransaction> {
  ISubstrateAddress._(
      {required super.keyIndex,
      required super.coin,
      required List<int> publicKey,
      required super.address,
      required super.network,
      required super.networkAddress,
      required super.identifier,
      super.accountName})
      : publicKey = publicKey.asImmutableBytes;

  factory ISubstrateAddress._newAccount({
    required List<int> publicKey,
    required WalletSubstrateNetwork network,
    required BaseSubstrateAddress address,
    required CryptoCoins coin,
    required AddressDerivationIndex keyIndex,
    required String identifier,
  }) {
    final balance =
        ChainAccountBalance(address: address.address, network: network);
    return ISubstrateAddress._(
        coin: coin,
        publicKey: publicKey,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        identifier: identifier);
  }
  factory ISubstrateAddress.deserialize(WalletSubstrateNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(
        cborTag.tags, CborTagsConst.substrateMultisigAccount)) {
      return ISubstrateMultiSigAddress.deserialize(network, obj: cborTag);
    }
    final CborListValue values = CborSerializable.cborTagValue(
        object: cborTag, tags: CborTagsConst.substrateAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.elementAsCborTag(1));
    final List<int> publicKey = values.elementAs(2);
    final ChainAccountBalance address = ChainAccountBalance.deserialize(network,
        obj: values.elementAsCborTag(3));
    final BaseSubstrateAddress addr = BaseSubstrateAddress(address.toAddress);
    final int networkId = values.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAs(5);
    final String identifier = values.elementAs(6);
    return ISubstrateAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: addr,
        network: networkId,
        accountName: accountName,
        identifier: identifier);
  }

  @override
  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          coin.toCbor(),
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          identifier,
        ]),
        CborTagsConst.substrateAccount);
  }

  SubstrateKeyAlgorithm get keyScheme {
    if (networkAddress is SubstrateEthereumAddress) {
      return SubstrateKeyAlgorithm.ethereum;
    }
    return switch (keyIndex.currencyCoin.conf.type) {
      EllipticCurveTypes.sr25519 => SubstrateKeyAlgorithm.sr25519,
      EllipticCurveTypes.ed25519 => SubstrateKeyAlgorithm.ed25519,
      EllipticCurveTypes.secp256k1 => SubstrateKeyAlgorithm.ecdsa,
      _ => throw WalletExceptionConst.invalidAccountDeta(
          "Unknow substrate key scheme.")
    };
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  String? get type => null;

  @override
  SubstrateNewAddressParams toAccountParams() {
    return SubstrateNewAddressParams(deriveIndex: keyIndex);
  }
}

final class ISubstrateMultiSigAddress extends ISubstrateAddress
    with SubstrateChainAccountRepository, SubstrateChainAccountController
    implements MultiSigCryptoAccountAddress {
  factory ISubstrateMultiSigAddress._newAccount({
    required WalletSubstrateNetwork network,
    required CryptoCoins coin,
    required String identifier,
    required BaseSubstrateAddress address,
    required SubstrateMultisigAccountInfo multiSignatureAddress,
  }) {
    final balance =
        ChainAccountBalance(address: address.address, network: network);
    return ISubstrateMultiSigAddress._(
        coin: coin,
        address: balance,
        networkAddress: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        identifier: identifier);
  }

  factory ISubstrateMultiSigAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.substrateMultisigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final SubstrateMultisigAccountInfo multiSignatureAddress =
        SubstrateMultisigAccountInfo.deserialize(
            object: values.elementAsCborTag(1));
    final ChainAccountBalance address = ChainAccountBalance.deserialize(network,
        obj: values.elementAsCborTag(2));
    final SubstrateAddress networkAddress = SubstrateAddress(address.address);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? name = values.elementAs(4);
    final String identifier = values.elementAs(5);
    return ISubstrateMultiSigAddress._(
        coin: coin,
        address: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        accountName: name,
        networkAddress: networkAddress,
        identifier: identifier);
  }
  ISubstrateMultiSigAddress._({
    required super.coin,
    required super.address,
    required this.multiSignatureAddress,
    required super.network,
    super.accountName,
    required super.networkAddress,
    required super.identifier,
  }) : super._(publicKey: const [], keyIndex: MultiSigAddressIndex());

  @override
  List<int> get publicKey =>
      throw WalletExceptionConst.featureUnavailableForMultiSignature;

  final SubstrateMultisigAccountInfo multiSignatureAddress;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.substrateMultisigAccount);
  }

  @override
  List get variabels => [multiSignatureAddress];

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return [];
  }

  @override
  SubstrateNewAddressParams toAccountParams() {
    return SubstrateMultiSigNewAddressParams(
        coin: coin,
        multiSignatureAddress: multiSignatureAddress,
        address: networkAddress);
  }

  List<BaseSubstrateAddress> signers() {
    if (networkAddress.type.isSubstrate) {
      return multiSignatureAddress.addresses(
          ss58Format: networkAddress.cast<SubstrateAddress>().ss58Format);
    }
    return multiSignatureAddress.addresses();
  }

  @override
  IAdressType get iAddressType => IAdressType.multisigByPublicKey;
}

base mixin SubstrateChainAccountController
    on
        ChainAccount<BaseSubstrateAddress, SubstrateToken, NFTCore,
            SubstrateWalletTransaction>,
        SubstrateChainAccountRepository {}
base mixin SubstrateChainAccountRepository on ChainAccount<BaseSubstrateAddress,
    SubstrateToken, NFTCore, SubstrateWalletTransaction> {
  Future<List<SubstrateMultisigCall>> _getMultisigs() async {
    final storagekey = SubstrateNetworkStorageId.multisigTransactions;
    final data = await _storage.queriesNetworkStorage(
        address: this, storage: storagekey);
    return data
        .map((e) => SubstrateMultisigCall.deserialize(bytes: e))
        .toList();
  }

  Future<void> _saveMultisig(SubstrateMultisigCall call) async {
    final storagekey = SubstrateNetworkStorageId.multisigTransactions;
    await _storage.insertNetworkStorage(
        address: this,
        storage: storagekey,
        keyA: call.callHashHex,
        value: call);
  }

  Future<void> _cleanAllMultisigs() async {
    final storagekey = SubstrateNetworkStorageId.multisigTransactions;
    await _storage.removeNetworkStorage(storage: storagekey, address: this);
  }

  Future<void> _cleanMultisigs(List<String> callHashes) async {
    if (callHashes.isEmpty) return;
    final storagekey = SubstrateNetworkStorageId.multisigTransactions;
    await Future.wait(callHashes.map((e) => _storage.removeNetworkStorage(
        storage: storagekey,
        address: this,
        keyA: StringUtils.normalizeHex(e))));
  }
}
