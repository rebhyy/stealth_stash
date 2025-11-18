import 'package:on_chain/sui/src/keypair/types/types.dart';
import 'package:on_chain/sui/src/keypair/utils/utils.dart';
import 'package:on_chain/sui/src/transaction/types/types.dart';
import 'package:stealth_stash/app/error/exception/app_exception.dart';
import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:stealth_stash/crypto/requets/messages/models/models/signing.dart';
import 'package:stealth_stash/future/wallet/controller/controller.dart';
import 'package:stealth_stash/future/wallet/network/sui/transaction/types/types.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/network/core/network/network.dart';
import 'package:stealth_stash/wallet/models/signing/signing.dart';

mixin SuiTransactionSignerController on DisposableMixin {
  WalletProvider get walletProvider;
  WalletSuiNetwork get network;
  Future<SuiSignedTransaction> signTransactionInternal(
      {required SuiTransactionDataV1 transaction,
      required ISuiAddress signer}) async {
    final transactionDigest = SuiCryptoUtils.generateTransactionDigest(
        txBytes: transaction.serializeSign(), hashDigest: true);
    List<List<int>> signatures = [];
    final genericSignature = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: [signer],
      sign: (generateSignature) async {
        if (signer.multiSigAccount) {
          final multisigAccount = signer as ISuiMultiSigAddress;
          List<SuiGenericSignature> genericSignatures = [];
          int weight = 0;
          for (final i in multisigAccount.multiSignatureAddress.publicKeys) {
            final Bip32AddressIndex signer = i.keyIndex;
            final signRequest =
                GlobalSignRequest.sui(digest: transactionDigest, index: signer);
            final signature = await generateSignature(signRequest);
            signatures.add(signature.signature);
            genericSignatures.add(SuiGenericSignature(
                signature: signature.signature,
                algorithm: i.keyScheme.suiKeyAlgorithm));
            weight += i.weight;
            if (weight >= multisigAccount.multiSignatureAddress.threshold) {
              break;
            }
          }
          if (weight < multisigAccount.multiSignatureAddress.threshold) {
            throw AppException("insufficient_signatures");
          }
          return genericSignatures;
        } else {
          final Bip32AddressIndex keyIndex = signer.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.sui(digest: transactionDigest, index: keyIndex);
          final signature = await generateSignature(signRequest);
          final suiSignature = SuiGenericSignature(
              signature: signature.signature,
              algorithm: signer.keyScheme.suiKeyAlgorithm);
          signatures.add(signature.signature);
          return [suiSignature];
        }
      },
    ));
    final signature =
        signer.createTransactionAuthenticated(genericSignature.result);
    return SuiSignedTransaction(
        suiSignature: signature,
        signatures: signatures,
        transaction: transaction);
  }
}
