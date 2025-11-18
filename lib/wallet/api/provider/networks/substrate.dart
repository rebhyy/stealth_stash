import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/service.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/app/http/models/auth.dart';

class SubstrateAPIProvider extends APIProvider {
  const SubstrateAPIProvider._(
      {required super.protocol,
      required super.auth,
      required super.identifier,
      required this.uri});
  factory SubstrateAPIProvider(
      {required String uri,
      required String identifier,
      ProviderAuthenticated? auth}) {
    return SubstrateAPIProvider._(
        protocol: ServiceProtocol.fromURI(uri),
        uri: uri,
        auth: auth,
        identifier: identifier);
  }
  final String uri;
  @override
  String get callUrl => uri;

  factory SubstrateAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.substrateApiServiceProvider);
    final int? protocolId = values.elementAs(1);
    return SubstrateAPIProvider._(
        uri: values.elementAs(0),
        protocol: ServiceProtocol.fromID(protocolId ?? 0),
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            2, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic(
            [uri, protocol.id, auth?.toCbor(), identifier]),
        CborTagsConst.substrateApiServiceProvider);
  }

  @override
  List get variabels => [uri, protocol];
}
