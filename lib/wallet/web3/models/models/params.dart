import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';

class ExtentionRequestEvent with CborSerializable {
  final String id;
  final List<int> data;
  final String requestId;
  final String url;
  final int tabId;
  ExtentionRequestEvent({
    required this.id,
    required List<int> data,
    required this.requestId,
    required this.url,
    required this.tabId,
  }) : data = List<int>.unmodifiable(data);
  factory ExtentionRequestEvent.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, hex: hex);
    return ExtentionRequestEvent(
        id: values.elementAs(0),
        data: values.elementAs(1),
        requestId: values.elementAs(2),
        url: values.elementAs(3),
        tabId: values.elementAs(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic(
            [id, CborBytesValue(data), requestId, url, tabId]),
        [1]);
  }
}
