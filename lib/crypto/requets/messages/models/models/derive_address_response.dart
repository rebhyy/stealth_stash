import 'package:stealth_stash/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:stealth_stash/wallet/chain/account.dart';

final class CryptoDeriveAddressResponse {
  final NewAccountParams accountParams;
  final CryptoPublicKeyData publicKey;

  CryptoDeriveAddressResponse(
      {required this.accountParams, required this.publicKey});
}
