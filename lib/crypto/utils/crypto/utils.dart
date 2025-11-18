import 'package:blockchain_utils/crypto/crypto/crypto.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stealth_stash/wallet/constant/tags/constant.dart';

class WorkerCryptoUtils {
  // Adaptive PBKDF2 iterations:
  // Web (browser): 25000 - fast with WebCrypto hardware acceleration
  // Mobile/Desktop: 10000 - optimized for pure Dart on mobile CPUs
  static const int keyItration = kIsWeb ? 25000 : 10000;
  static List<int> generateNonce(List<int> seed) {
    final hasher = SHAKE128();
    final digest = List<int>.unmodifiable(hasher.update(seed).digest(12));
    hasher.clean();
    return digest;
  }

  static List<int> hashKeyOld(
      {required List<int> key, required List<int> checksum}) {
    final List<int> keyBytes = SHA3.hash(List.from([...key, ...checksum]));
    return List<int>.unmodifiable(
        keyBytes.sublist(0, WalletProviderConst.encryptionKeyLength));
  }

  static List<int> hashKeyNew(
      {required List<int> key, required List<int> checksum}) {
    final hash = QuickCrypto.sha256Hash(key);
    return PBKDF2.deriveKey(
        mac: () => HMAC(() => SHA512(), hash),
        salt: checksum,
        iterations: keyItration,
        length: WalletProviderConst.encryptionKeyLength);
  }

  static List<int> encryptChacha(
      {required List<int> key,
      required List<int> nonce,
      required List<int> data}) {
    final chacha = ChaCha20Poly1305(key);
    try {
      return chacha.encrypt(nonce, data);
    } finally {
      chacha.clean();
    }
  }

  static List<int>? decryptChacha({
    required List<int> key,
    required List<int> nonce,
    required List<int> data,
  }) {
    final chacha = ChaCha20Poly1305(key);
    try {
      final decrypt = chacha.decrypt(nonce, data);
      if (decrypt != null) {
        return List<int>.unmodifiable(decrypt);
      }
      return decrypt;
    } finally {
      chacha.clean();
    }
  }

  static List<List<int>> divideRange(
      {required int start, required int end, required int numberOfThreads}) {
    final totalRange = end - start + 1;
    if (totalRange <= 500) {
      return [
        [start, end]
      ];
    }

    // Calculate chunk size based on the range and threads.
    int chunkSize = totalRange ~/ numberOfThreads;

    // Ensure chunk size is at least 500.
    if (chunkSize < 500) {
      chunkSize = 500;
      // Recalculate the number of threads based on 500 per chunk.
      numberOfThreads = totalRange ~/ 500;
    }
    int remainder = totalRange % numberOfThreads;
    final List<List<int>> ranges = [];
    int currentStart = start;

    for (int i = 0; i < numberOfThreads; i++) {
      // For all but the last chunk, subtract 1 to ensure proper chunk size.
      int currentEnd = currentStart + chunkSize - 1;

      // For the last chunk, make sure the end is equal to `end`.
      if (i == numberOfThreads - 1) {
        currentEnd = end;
      } else if (remainder > 0) {
        // Adjust the range if there's a remainder.
        currentEnd++;
        remainder--;
      }

      ranges.add([currentStart, currentEnd]);

      // Update the currentStart for the next range to start from the previous end.
      currentStart = currentEnd;
    }
    return ranges;
  }
}
