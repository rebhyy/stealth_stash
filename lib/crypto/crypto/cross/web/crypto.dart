import 'package:stealth_stash/crypto/crypto/core/app_crypto.dart';

AppCrypto getAppCrypto() => AppCryptoWeb._();

class AppCryptoWeb extends AppCrypto {
  const AppCryptoWeb._();

  @override
  void close() {}
}
