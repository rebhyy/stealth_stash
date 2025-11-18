part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

final class SubstrateNewAddressParams
    extends NewAccountParams<ISubstrateAddress> {
  @override
  bool get isMultiSig => false;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;

  @override
  final AddressDerivationIndex deriveIndex;

  const SubstrateNewAddressParams._({required this.deriveIndex}) : super._();
  factory SubstrateNewAddressParams(
      {required AddressDerivationIndex deriveIndex}) {
    return SubstrateNewAddressParams._(deriveIndex: deriveIndex);
  }

  factory SubstrateNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.substrateNewAddressParams.tag);
    return SubstrateNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.elementAsCborTag(0)),
    );
  }

  @override
  ISubstrateAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletSubstrateNetwork) {
      throw WalletExceptionConst.invalidAccountDeta(
          "SubstrateNewAddressParams.toAccount");
    }
    final keyBytes = publicKey.normalizedComprossedBytes.asImmutableBytes;
    final address = SubstrateUtils.toAddress(
        publicKey: keyBytes,
        ss58Format: network.coinParam.ss58Format,
        curve: coin.conf.type,
        isEthereum: network.coinParam.substrateChainType.isEthereum);
    return ISubstrateAddress._newAccount(
        publicKey: keyBytes,
        network: network,
        address: address,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        keyIndex: deriveIndex);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([deriveIndex.toCbor()]), type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.substrateNewAddressParams;
}

final class SubstrateMultiSigNewAddressParams
    implements SubstrateNewAddressParams {
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;
  @override
  final CryptoCoins coin;
  final SubstrateMultisigAccountInfo multiSignatureAddress;
  final BaseSubstrateAddress address;

  SubstrateMultiSigNewAddressParams._({
    required this.multiSignatureAddress,
    required this.coin,
    required this.address,
  }) : deriveIndex = MultiSigAddressIndex();

  factory SubstrateMultiSigNewAddressParams(
      {required SubstrateMultisigAccountInfo multiSignatureAddress,
      required CryptoCoins coin,
      required BaseSubstrateAddress address}) {
    return SubstrateMultiSigNewAddressParams._(
        multiSignatureAddress: multiSignatureAddress,
        coin: coin,
        address: address);
  }

  factory SubstrateMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.substrateMultisigNewAddressParams.tag);
    return SubstrateMultiSigNewAddressParams(
        coin: CustomCoins.getSerializationCoin(values.elementAs(0)),
        multiSignatureAddress: SubstrateMultisigAccountInfo.deserialize(
            object: values.elementAs(1)),
        address: BaseSubstrateAddress(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue<CborObject>.definite([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          CborStringValue(address.address),
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.substrateMultisigNewAddressParams;

  @override
  ISubstrateAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (network is! WalletSubstrateNetwork ||
        network.coinParam.substrateChainType.isEthereum) {
      throw WalletExceptionConst.invalidAccountDeta(
          "SubstrateNewAddressParams.toAccount");
    }

    return ISubstrateMultiSigAddress._newAccount(
        network: network,
        address: address.type.isSubstrate
            ? address
                .cast<SubstrateAddress>()
                .toSS58(network.coinParam.ss58Format)
            : address,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        multiSignatureAddress: multiSignatureAddress);
  }
}
