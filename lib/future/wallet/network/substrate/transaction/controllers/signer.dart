import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/crypto/requets/messages/models/models/signing.dart';
import 'package:stealth_stash/crypto/utils/substrate/substrate.dart';
import 'package:stealth_stash/future/wallet/controller/controller.dart';
import 'package:stealth_stash/future/wallet/network/substrate/transaction/types/types.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/network/core/network/network.dart';
import 'package:stealth_stash/wallet/models/signing/signing.dart';

mixin SubstrateTransactionSignerController on DisposableMixin {
  WalletProvider get walletProvider;
  WalletSubstrateNetwork get network;
  Future<SubstrateSignedTransaction> signTransactionInternal({
    required List<int> payloadBytes,
    required ISubstrateAddress signer,
    bool fakeSignature = false,
  }) async {
    List<int> signature;
    if (fakeSignature) {
      signature = SubstrateUtils.createFakeSignature(signer.coin.conf.type);
    } else {
      final sig = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest<List<int>>(
        addresses: [signer],
        network: network,
        sign: (generateSignature) async {
          final signature = await generateSignature(GlobalSignRequest.substrate(
              digest: payloadBytes, index: signer.keyIndex));
          return signature.signature;
        },
      ));
      signature = sig.result;
    }
    return SubstrateSignedTransaction(
        signatures: [signature], payload: payloadBytes);
  }
}
