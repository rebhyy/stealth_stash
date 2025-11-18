import 'package:blockchain_utils/helper/helper.dart';
import 'package:stealth_stash/crypto/keys/keys.dart';

final class CryptoCreateWalletResponse {
  final EncryptedMasterKey masterKey;
  final List<int> checksum;
  CryptoCreateWalletResponse(
      {required this.masterKey, required List<int> checksum})
      : checksum = checksum.asImmutableBytes;
}
