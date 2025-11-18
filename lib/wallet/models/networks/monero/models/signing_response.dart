import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:stealth_stash/app/serialization/cbor/cbor.dart';
import 'package:stealth_stash/crypto/utils/utils.dart';
import 'package:stealth_stash/wallet/wallet.dart';

class MoneroViewTxDestinationWithProof with CborSerializable {
  final MoneroTxDestination destination;
  final String? proof;
  const MoneroViewTxDestinationWithProof(
      {required this.destination, this.proof});
  factory MoneroViewTxDestinationWithProof.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroTxDestinationWithProof);
    return MoneroViewTxDestinationWithProof(
        destination: MoneroTxDestination.deserialize(values.elementAs(0)),
        proof: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic(
            [CborBytesValue(destination.serialize()), proof]),
        CborTagsConst.moneroTxDestinationWithProof);
  }
}

class MoneroSignedTxData with CborSerializable {
  final String txID;
  final List<MoneroPrivateKey> txKeys;
  final List<MoneroAccountIndex> indexes;
  MoneroSignedTxData(
      {required String txID,
      required List<MoneroPrivateKey> txKeys,
      required List<MoneroAccountIndex> indexes})
      : txID = QuickCryptoValidator.asValidHexBytes(txID,
            lengthInBytes: MoneroConst.txHashLength),
        txKeys = txKeys.immutable,
        indexes = indexes.immutable;
  factory MoneroSignedTxData.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroSignedTxData);
    return MoneroSignedTxData(
        txID: String.fromCharCodes(values.elementAs(0)),
        txKeys: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => MoneroPrivateKey.fromBytes(e.value))
            .toList(),
        indexes: values
            .elementAsListOf<CborBytesValue>(2)
            .map((e) => MoneroAccountIndex.deserialize(e.value))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          CborBytesValue(txID.codeUnits),
          CborSerializable.fromDynamic(
              txKeys.map((e) => CborBytesValue(e.key)).toList()),
          CborSerializable.fromDynamic(
              indexes.map((e) => CborBytesValue(e.serialize())).toList()),
        ]),
        CborTagsConst.moneroSignedTxData);
  }
}

class MoneroSigningTxResponse with CborSerializable {
  final MoneroSignedTxData txData;
  final List<MoneroViewTxDestinationWithProof> destinations;
  final String txBytes;
  MoneroSigningTxResponse({
    required this.txData,
    required List<MoneroViewTxDestinationWithProof> destinations,
    required String txHex,
  })  : destinations = destinations.immutable,
        txBytes = QuickCryptoValidator.asValidHexBytes(txHex);
  factory MoneroSigningTxResponse.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroSigningTxResponse);
    return MoneroSigningTxResponse(
        txData: MoneroSignedTxData.deserialize(obj: values.elementAsCborTag(0)),
        destinations: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => MoneroViewTxDestinationWithProof.deserialize(obj: e))
            .toList(),
        txHex: String.fromCharCodes(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          txData.toCbor(),
          CborSerializable.fromDynamic(
              destinations.map((e) => e.toCbor()).toList()),
          CborBytesValue(txBytes.codeUnits)
        ]),
        CborTagsConst.moneroSigningTxResponse);
  }
}
