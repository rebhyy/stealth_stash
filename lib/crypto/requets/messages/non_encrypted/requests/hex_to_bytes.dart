import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/crypto/requets/argruments/argruments.dart';
import 'package:stealth_stash/crypto/requets/messages/core/message.dart';

final class NoneEncryptedRequestHexToBytes<T>
    extends NoneEncryptedCryptoRequest<List<int>, MessageArgsOneBytes> {
  final String hex;
  NoneEncryptedRequestHexToBytes({required this.hex});
  factory NoneEncryptedRequestHexToBytes.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.hexToBytes.tag);
    return NoneEncryptedRequestHexToBytes(
        hex: String.fromCharCodes(values.elementAs(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([CborBytesValue(hex.codeUnits)]),
        method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.hexToBytes;

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    return MessageArgsOneBytes(keyOne: BytesUtils.fromHexString(hex));
  }

  @override
  List<int> parsResult(MessageArgsOneBytes result) {
    return result.keyOne;
  }

  @override
  Future<List<int>> result({List<int>? encryptedPart}) async {
    return BytesUtils.fromHexString(hex);
  }
}
