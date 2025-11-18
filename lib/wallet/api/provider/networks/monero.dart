import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:stealth_stash/app/serialization/cbor/cbor.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/models/models.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/app/http/models/auth.dart';

class MoneroAPIProvider extends APIProvider {
  const MoneroAPIProvider(
      {super.auth, required super.identifier, required this.httpNodeUri})
      : super(protocol: ServiceProtocol.http);
  final String httpNodeUri;

  @override
  String get callUrl => httpNodeUri;

  factory MoneroAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroApiServiceProvider);
    return MoneroAPIProvider(
        httpNodeUri: values.elementAs(0),
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            1, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([httpNodeUri, auth?.toCbor(), identifier]),
        CborTagsConst.moneroApiServiceProvider);
  }
}
