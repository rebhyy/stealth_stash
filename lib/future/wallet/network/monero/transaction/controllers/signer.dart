import 'package:stealth_stash/app/live_listener/live.dart';
import 'dart:async';
import 'package:monero_dart/monero_dart.dart';
import 'package:stealth_stash/crypto/requets/messages/models/models/signing.dart';
import 'package:stealth_stash/future/wallet/wallet.dart';
import 'package:stealth_stash/wallet/wallet.dart';

mixin MoneroTransactionSignerController on DisposableMixin {
  WalletProvider get walletProvider;
  WalletMoneroNetwork get network;

  Future<IMoneroSignedTransaction> signTransactionInternal(
      IMoneroTransaction transaction,
      {bool fakeSignature = false,
      bool withProof = false}) async {
    assert(!fakeSignature, "fakeSignature not suported");
    final signedTx = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
          addresses: transaction.transactionData.payments
              .map((e) => e.address)
              .toList(),
          network: network,
          sign: (generateSignature) async {
            final s = MoneroSigningRequest(
                destinations: transaction.transactionData.destinations
                    .map((e) => MoneroTxDestination(
                        amount: e.amount.balance,
                        address: e.recipient.networkAddress))
                    .toList(),
                fee: transaction.fee,
                utxos: transaction.spendablePayment,
                change: transaction.transactionData.change,
                index: transaction.account.keyIndex,
                withProof: withProof);
            final r = await generateSignature(s);
            return MoneroSigningTxResponse.deserialize(bytes: r.signature);
          },
        ),
        timeout: MoneroConst.moneroSigningTimeout);
    return IMoneroSignedTransaction(
        transaction: transaction,
        signatures: [],
        finalTransactionData: signedTx.result);
  }
}
