import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/constant/global/serialization.dart';
import 'package:blockchain_utils/utils/equatable/equatable.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/app/utils/string/utils.dart';
import 'content_type.dart';

// import 'package:stealth_stash/app/core.dart';
typedef OnLoadUrl = Future<String> Function();
typedef OnLoadCacheKey = Future<String> Function();

abstract class APPImageInfo with Equality {
  abstract final OnLoadUrl loadUrl;
  abstract final ContentType type;
}

class LazyAPPImage with Equality implements APPImageInfo {
  final String identifier;
  @override
  final ContentType type = ContentType.lazy;
  const LazyAPPImage({required this.loadUrl, required this.identifier});
  @override
  final OnLoadUrl loadUrl;

  @override
  List get variabels => [identifier];
}

class APPImage with CborSerializable, Equality implements APPImageInfo {
  @override
  final ContentType type;
  final String uri;
  const APPImage._({required this.type, required this.uri});
  APPImage.local(this.uri) : type = ContentType.local;
  factory APPImage.hex({required String hexData}) {
    return APPImage._(type: ContentType.hex, uri: hexData);
  }
  factory APPImage.base64({required String hexData}) {
    return APPImage._(type: ContentType.base64, uri: hexData);
  }
  static APPImage? network(String? imageUrl) {
    final validateUrl = StrUtils.validateUri(imageUrl);
    if (validateUrl == null) return null;
    return APPImage._(type: ContentType.network, uri: imageUrl!);
  }

  factory APPImage.faviIcon(String websiteUrl) {
    final host = Uri.tryParse(websiteUrl);
    String cacheKey = host?.host ?? "";
    if (cacheKey.isEmpty) {
      cacheKey = websiteUrl;
    }
    return APPImage._(type: ContentType.favIcon, uri: websiteUrl);
  }

  factory APPImage.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: APPSerializationConst.imageTag);
    final String uri = cbor.elementAs(1);
    return APPImage._(type: ContentType.fromValue(cbor.elementAs(0)), uri: uri);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([type.value, CborStringValue(uri)]),
        APPSerializationConst.imageTag);
  }

  @override
  List get variabels => [type, uri];

  @override
  OnLoadUrl get loadUrl => () async => uri;
}
