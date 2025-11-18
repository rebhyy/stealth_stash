import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/serialization/cbor/cbor.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';

class Web3AccountAcitvity with CborSerializable, Equality {
  final String requestId;
  final String method;
  final DateTime date;
  final String? path;
  final String? address;
  final int? id;
  Web3AccountAcitvity({
    required this.method,
    required this.requestId,
    DateTime? date,
    required this.path,
    this.id,
    this.address,
  }) : date = date ?? DateTime.now();
  factory Web3AccountAcitvity.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.permissionActivityTag);
    return Web3AccountAcitvity(
        method: values.valueAs(0),
        requestId: values.valueAs(1),
        date: values.valueAs(2),
        path: values.valueAs(3),
        address: values.valueAs(4),
        id: values.valueAs(5));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic(
            [method, requestId, CborEpochFloatValue(date), path, address, id]),
        CborTagsConst.permissionActivityTag);
  }

  @override
  List get variabels => [method, requestId, date, path, address, id];
}
