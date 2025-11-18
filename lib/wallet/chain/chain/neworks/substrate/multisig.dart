part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

class SubstrateMultisigAccountInfo with CborSerializable {
  final List<BaseSubstrateAddress> signers;
  final int threshold;
  final BaseSubstrateAddress address;
  SubstrateMultisigAccountInfo._(
      {required List<BaseSubstrateAddress> signers,
      required this.threshold,
      required this.address})
      : signers = signers.immutable;
  factory SubstrateMultisigAccountInfo.create(
      {required List<BaseSubstrateAddress> signers,
      required int threshold,
      required int maxSigntories}) {
    if (threshold <= 0 ||
        signers.length < threshold ||
        signers.length > maxSigntories) {
      throw WalletExceptionConst.invalidAccountDeta(
          "SubstrateMultisigAccountInfo.create");
    }
    final address = BaseSubstrateAddress.createMultiSigAddress(
        addresses: signers,
        threshold: threshold,
        maxSignatories: maxSigntories);
    return SubstrateMultisigAccountInfo._(
        signers: signers, threshold: threshold, address: address);
  }
  factory SubstrateMultisigAccountInfo.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.suiMultisigAccountInfo);
    return SubstrateMultisigAccountInfo._(
        signers: values
            .elementAsListOf<CborBytesValue>(0)
            .map((e) => BaseSubstrateAddress.fromBytes(e.value))
            .toList(),
        threshold: values.valueAs(1),
        address: BaseSubstrateAddress.fromBytes(values.valueAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue<CborObject>.definite([
          CborSerializable.fromDynamic(
              signers.map((e) => CborBytesValue(e.toBytes())).toList()),
          CborIntValue(threshold),
          CborBytesValue(address.toBytes())
        ]),
        CborTagsConst.suiMultisigAccountInfo);
  }

  List<BaseSubstrateAddress> addresses(
      {int ss58Format = SS58Const.genericSubstrate}) {
    return signers.map((e) {
      if (e.type.isSubstrate) {
        return e.cast<SubstrateAddress>().toSS58(ss58Format);
      }
      return e;
    }).toList();
  }

  BaseSubstrateAddress toAddress(
      {int ss58Format = SS58Const.genericSubstrate}) {
    final address = this.address;
    if (address.type.isSubstrate) {
      return address.cast<SubstrateAddress>().toSS58(ss58Format);
    }
    return address;
  }
}
