import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/wallet.dart';

class MoneroRingOutput with CborSerializable {
  final List<BigInt> orderedIndexes;
  final List<BigInt> indexes;
  MoneroRingOutput(
      {required List<BigInt> orderedIndexes, required List<BigInt> indexes})
      : orderedIndexes = orderedIndexes.immutable,
        indexes = indexes.immutable;
  factory MoneroRingOutput.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.monerogenerateRingOutput);
    return MoneroRingOutput(
        orderedIndexes: values
            .elementAsListOf<CborBigIntValue>(0)
            .map((e) => e.value)
            .toList(),
        indexes: values
            .elementAsListOf<CborBigIntValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.definite([
          CborSerializable.fromDynamic(
              orderedIndexes.map((e) => CborBigIntValue(e)).toList()),
          CborSerializable.fromDynamic(
              indexes.map((e) => CborBigIntValue(e)).toList()),
        ]),
        CborTagsConst.monerogenerateRingOutput);
  }
}

class MoneroSyncAccountRequest {
  final List<IMoneroAddress> addresses;
  final int startHeight;
  final int endHeight;
  final String heightsStr;
  MoneroSyncAccountRequest(
      {required this.addresses,
      required this.startHeight,
      required this.endHeight})
      : heightsStr = "$startHeight/$endHeight";
}
