import 'package:on_chain/solana/src/transaction/transaction/transaction.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:stealth_stash/crypto/requets/messages/models/models/signing.dart';
import 'package:stealth_stash/future/wallet/controller/controller.dart';
import 'package:stealth_stash/future/wallet/network/solana/transaction/types/types.dart';

import 'package:stealth_stash/wallet/wallet.dart';

mixin SolanaTransactionSignerController on DisposableMixin {
  WalletSolanaNetwork get network;
  WalletProvider get walletProvider;

  Future<SolanaSignedTransaction> signTransactionInternal(
      {required SolanaTransaction transaction,
      required List<ISolanaAddress> signers}) async {
    final signature = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: signers,
      sign: (generateSignature) async {
        final List<List<int>> signatures = [];
        final digest = List<int>.unmodifiable(transaction.serializeMessage());
        for (int i = 0; i < signers.length; i++) {
          final addr = signers.elementAt(i);
          final Bip32AddressIndex signer = addr.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.solana(digest: digest, index: signer);
          final signature = await generateSignature(signRequest);
          signatures.add(signature.signature);
          transaction.addSignature(addr.networkAddress, signature.signature);
        }
        return SolanaSignedTransaction(
            transaction: transaction, signatures: signatures);
      },
    ));
    return signature.result;
  }
}
