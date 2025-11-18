import 'package:monero_dart/monero_dart.dart';
import 'package:stealth_stash/crypto/crypto/core/app_crypto.dart';
import 'package:stealth_stash/crypto/crypto/cross/io/native/native_crypto.dart';
import 'package:stealth_stash/crypto/crypto/types/types.dart';

AppCrypto getAppCrypto() => AppCryptoIo._();

class AppCryptoIo extends AppCrypto {
  AppCryptoIo._();

  AppCryptoNative? _lib = AppCryptoNative.findLiberary();

  @override
  List<MoneroCryptoUnlockOutput> moneroUnlockOutput(
      {required List<MoneroAccountKeys> accounts,
      required MoneroTransaction transaction}) {
    final lib = _lib;
    if (lib != null) {
      return lib.moneroUnlockOutput(
          accounts: accounts, transaction: transaction);
    }
    return super
        .moneroUnlockOutput(accounts: accounts, transaction: transaction);
  }

  @override
  void close() {
    final lib = _lib;
    _lib = null;
    lib?.close();
  }
}
