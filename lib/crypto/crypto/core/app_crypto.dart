import 'package:monero_dart/monero_dart.dart';
import 'package:stealth_stash/crypto/crypto/types/types.dart';

import '../cross/cross.dart'
    if (dart.library.js_interop) '../cross/web/crypto.dart'
    if (dart.library.io) '../cross/io/crypto.dart';

abstract class AppCrypto {
  const AppCrypto();
  factory AppCrypto.instance() {
    return getAppCrypto();
  }
  List<MoneroCryptoUnlockOutput> moneroUnlockOutput(
      {required List<MoneroAccountKeys> accounts,
      required MoneroTransaction transaction}) {
    List<MoneroCryptoUnlockOutput> outputs = [];
    for (int realIndex = 0; realIndex < transaction.vout.length; realIndex++) {
      for (int a = 0; a < accounts.length; a++) {
        final account = accounts[a];
        final unlock = MoneroTransactionHelper.getLockedOutputs(
            realIndex: realIndex, tx: transaction, account: account);
        if (unlock != null) {
          outputs
              .add(MoneroCryptoUnlockOutput(account: account, output: unlock));
        }
      }
    }
    return outputs;
  }

  void close();
}
