import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:stealth_stash/app/serialization/cbor/cbor.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/models/models.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/app/http/models/auth.dart';

class CustomAPIProvider extends APIProvider {
  const CustomAPIProvider({
    super.auth,
    required super.identifier,
    required this.url,
  }) : super(protocol: ServiceProtocol.http);
  final String url;

  @override
  String get callUrl => url;

  factory CustomAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.customApiProvider);
    return CustomAPIProvider(
        url: values.elementAs(0),
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            1, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([url, auth?.toCbor(), identifier]),
        CborTagsConst.customApiProvider);
  }
}
