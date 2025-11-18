import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:stealth_stash/app/serialization/cbor/cbor.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/models/models.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/app/http/models/auth.dart';

class StellarAPIProvider extends APIProvider {
  const StellarAPIProvider({
    super.auth,
    required super.identifier,
    required this.horizonUrl,
    required this.sorobanUrl,
  }) : super(protocol: ServiceProtocol.http);
  final String horizonUrl;
  final String sorobanUrl;

  @override
  String get callUrl => horizonUrl;

  factory StellarAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.stellarApiProvider);
    return StellarAPIProvider(
      horizonUrl: values.elementAs(0),
      sorobanUrl: values.elementAs(1),
      auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
          2, (e) => ProviderAuthenticated.deserialize(obj: e)),
      identifier: values.elementAs(3),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          horizonUrl,
          sorobanUrl,
          auth?.toCbor(),
          identifier,
        ]),
        CborTagsConst.stellarApiProvider);
  }

  @override
  List get variabels => [horizonUrl, sorobanUrl, protocol];
}
