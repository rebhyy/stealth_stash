import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/app/utils/list/extension.dart';
import 'package:stealth_stash/crypto/utils/ripple/ripple.dart';
import 'package:stealth_stash/future/wallet/network/ripple/transaction/types/types.dart';
import 'package:stealth_stash/future/wallet/network/ripple/web3/types/types.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/wallet/web3/constant/constant.dart';
import 'package:stealth_stash/wallet/web3/networks/ripple/methods/methods.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

mixin XRPWeb3TransactionApiController on DisposableMixin {
  XRPClient get client;

  Future<XRPAccountInfo> getWeb3TransactionAccountInfo(
      ReceiptAddress<XRPAddress> address) async {
    final info = await client.getAccountInfo(address.networkAddress.address);
    if (info == null) {
      throw Web3RequestExceptionConst.inactiveAccount;
    }

    final accountSigners =
        await client.getAccountSignerList(address.networkAddress.address);
    final String? regularKey = info.accountData.regularKey;
    return XRPAccountInfo(
        enableMasterKey: !(info.accountFlags?.disableMasterKey ?? false),
        regularKey: regularKey == null ? null : XRPAddress(regularKey),
        accountSigners: accountSigners,
        owner: address);
  }

  XRPWeb3SigningMode? canSignTransaction({
    required XRPAccountInfo owner,
    required IXRPAddress address,
    required Web3XRPRequestMethods method,
  }) {
    if (owner.owner.networkAddress.address == address.networkAddress.address) {
      if (owner.enableMasterKey) return XRPWeb3SigningMode.full;
      if (!address.multiSigAccount) return null;
      final msig = (address as IXRPMultisigAddress).multiSignatureAccount;
      final List<XRPAddress> addressSigners = msig.signers
          .map((e) => RippleUtils.strPublicKeyToRippleAddress(e.publicKey))
          .toList();
      if (msig.isRegular) {
        if (owner.regularKey == addressSigners.firstOrNull) {
          return XRPWeb3SigningMode.full;
        }
        return null;
      }
      final accountSigners = owner.accountSigners;
      if (accountSigners == null) return null;
      int threshHold = 0;
      for (final i in addressSigners) {
        final inSignerList = accountSigners.signerEntries
            .firstWhereOrNull((element) => element.account == i.address);
        if (inSignerList == null) continue;
        threshHold += inSignerList.signerWeight;
      }
      if (threshHold >= accountSigners.signerQuorum) {
        return XRPWeb3SigningMode.full;
      }

      return null;
    }

    if (method == Web3XRPRequestMethods.sendTransaction) {
      return null;
    }
    if (address.multiSigAccount) return null;
    return XRPWeb3SigningMode.part;
  }

  Future<XRPWeb3TransactionInfoPayment?> _getWeb3TransactionPaymentInfo({
    required Payment paymet,
    required XRPChain account,
    required IXRPAddress address,
  }) async {
    final recipient = account.getReceiptAddress(paymet.destination) ??
        ReceiptAddress(
            view: paymet.destination,
            networkAddress: XRPAddress(paymet.destination));
    switch (paymet.amount.type) {
      case AmountType.native:
        return XRPWeb3TransactionInfoPayment(
            recipient: recipient,
            amount: IntegerBalance.token(
                (paymet.amount as XRPAmount).value, account.network.token));
      case AmountType.issue:
        final amount = paymet.amount as IssuedCurrencyAmount;
        NonDecimalToken? token = address.tokens
            .firstWhereOrNull(
              (e) =>
                  e.assetCode == amount.currency && e.issuer == amount.issuer,
            )
            ?.token;
        token ??=
            NonDecimalToken(name: amount.currency, symbol: amount.currency);
        return XRPWeb3TransactionInfoPayment(
            recipient: recipient,
            amount: DecimalBalance.fromRational(token, amount.rational));
      default:
    }
    return null;
  }

  Future<XRPWeb3TransactionInfo?> getWeb3TransactionInfo({
    required SubmittableTransaction transaction,
    required XRPChain account,
    required IXRPAddress address,
  }) async {
    switch (transaction.transactionType) {
      case SubmittableTransactionType.payment:
        return _getWeb3TransactionPaymentInfo(
            paymet: transaction as Payment, account: account, address: address);
      default:
        return null;
    }
  }
}
