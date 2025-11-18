import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/error/exception/wallet_ex.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateNetworkParams extends NetworkCoinParams {
  final int ss58Format;
  final int specVersion;
  final String? gnesisBlock;
  final SubstrateChainType substrateChainType;
  final List<SubstrateKeyAlgorithm> keyAlgorithms;
  final SubstrateRelaySystem? relaySystem;
  final SubstrateConsensusRole? consensusRole;
  final BigInt? evmChainId;
  bool get assetTransferEnabled => true;
  bool get xcmTransferEnabled => relaySystem != null && consensusRole != null;
  bool get allowMultisig => true;
  factory SubstrateNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.substrateNetworkParams);

    return SubstrateNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(2)),
        chainType: ChainType.fromValue(values.valueAs(4)),
        ss58Format: values.valueAs(5),
        substrateChainType: SubstrateChainType.fromValue(values.valueAs(8)),
        gnesisBlock: values.valueAs(9),
        bip32CoinType: values.valueAs(10),
        addressExplorer: values.valueAs(11),
        transactionExplorer: values.valueAs(12),
        keyAlgorithms: values
            .elementAsListOf<CborIntValue>(13)
            .map((e) => SubstrateKeyAlgorithm.fromValue(e.value))
            .toList(),
        specVersion: values.valueAs(14),
        relaySystem: values.elemetMybeAs<SubstrateRelaySystem, CborIntValue>(
            15, (value) => SubstrateRelaySystem.fromValue(value.value)),
        consensusRole:
            values.elemetMybeAs<SubstrateConsensusRole, CborIntValue>(
                16, (value) => SubstrateConsensusRole.fromValue(value.value)),
        evmChainId: values.valueAs(17));
  }
  SubstrateNetworkParams(
      {required super.token,
      required super.chainType,
      required this.ss58Format,
      required this.specVersion,
      required this.relaySystem,
      required this.consensusRole,
      this.evmChainId,
      this.gnesisBlock,
      required this.substrateChainType,
      super.bip32CoinType,
      super.addressExplorer,
      super.transactionExplorer,
      this.keyAlgorithms = const [
        SubstrateKeyAlgorithm.ecdsa,
        SubstrateKeyAlgorithm.sr25519,
        SubstrateKeyAlgorithm.ed25519
      ]});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborNullValue(),
          chainType.name,
          ss58Format,
          const CborNullValue(),
          const CborNullValue(),
          substrateChainType.value,
          gnesisBlock,
          bip32CoinType,
          addressExplorer,
          transactionExplorer,
          CborSerializable.fromDynamic(
              keyAlgorithms.map((e) => e.value).toList()),
          specVersion,
          relaySystem?.value,
          consensusRole?.value,
          evmChainId
        ]),
        CborTagsConst.substrateNetworkParams);
  }

  @override
  NetworkCoinParams updateParams(
      {Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return SubstrateNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer,
        chainType: chainType,
        ss58Format: ss58Format,
        gnesisBlock: gnesisBlock,
        substrateChainType: substrateChainType,
        bip32CoinType: bip32CoinType,
        keyAlgorithms: keyAlgorithms,
        specVersion: specVersion,
        consensusRole: consensusRole,
        relaySystem: relaySystem,
        evmChainId: evmChainId);
  }

  SubstrateNetworkParams updateSpecVersion(int specVersion) {
    if (specVersion.isNegative || specVersion < this.specVersion) {
      throw WalletException.error("invalid_spec_version");
    }
    return SubstrateNetworkParams(
        token: token,
        chainType: chainType,
        ss58Format: ss58Format,
        specVersion: specVersion,
        substrateChainType: substrateChainType,
        addressExplorer: addressExplorer,
        bip32CoinType: bip32CoinType,
        gnesisBlock: gnesisBlock,
        keyAlgorithms: keyAlgorithms,
        transactionExplorer: transactionExplorer,
        relaySystem: relaySystem,
        consensusRole: consensusRole);
  }
}
