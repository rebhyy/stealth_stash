part of '../scripts.dart';

class BitcoinCashPageController extends WalletStandardPageController {
  BitcoinCashPageController(super.postMessage);
  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    feature.bitcoinCashConnect =
        JSWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.bitcoinCashSignPersonalMessage =
        JSWalletStandardSignPersonalMessageFeature.setup(
            signPersonalMessage: _bitcoinCashSignPersonalMessage.toJS);
    feature.bitcoinCashSignTransaction =
        JSWalletStandardSignTransactionFeature.setup(
            signTransaction: _bitcoinCashSignTransactions.toJS);

    feature.bitcoinCashGetAccountAddresses =
        JSWalletStandardGetAccountAddressesFeature.setup(
            getAccountAddresses: _getAccountAddress.toJS);
    feature.bitcoinCashSendTransaction =
        JSWalletStandardSendTransactionFeature.setup(
            sendTransaction: _bitcoinCashSendTransaction.toJS);
    feature.bitcoinCashDisconnect = JSWalletStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
    feature.bitcoinCashEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }

  JSPromise<JSWalletStandardConnect> _connect([JSString? chainId]) {
    final network = JsUtils.asJSString(chainId);
    final params = network == null ? null : [network].toJS;
    return waitForSuccessResponsePromise<JSWalletStandardConnect>(
        method: BitcoinCashJSConstant.requestAccountRequestName,
        params: params);
  }

  JSPromise<JSBitcoinCashSignMessageResponse> _bitcoinCashSignPersonalMessage(
      JSBitcoinCashSignMessageParams params) {
    return waitForSuccessResponsePromise<JSBitcoinCashSignMessageResponse>(
        method: BitcoinCashJSConstant.signPersonalMessageRequestName,
        params: [params].toJS);
  }

  JSPromise<JSBitcoinCashSignTransactionResponse> _bitcoinCashSignTransactions(
      JSBitcoinCashSignTransactionResponse params) {
    return waitForSuccessResponsePromise<JSBitcoinCashSignTransactionResponse>(
        method: BitcoinCashJSConstant.signTransactionRequestName,
        params: [params].toJS);
  }

  JSPromise<JSArray<JSBitcoinCashGetAccountAddressResponse>> _getAccountAddress(
      JSBitcoinCashGetAccountAddressParams params) {
    return waitForSuccessResponsePromise<
            JSArray<JSBitcoinCashGetAccountAddressResponse>>(
        method: BitcoinCashJSConstant.getAccountAddresses,
        params: [params].toJS);
  }

  JSPromise<JSBitcoinCashSendTransactionResponse> _bitcoinCashSendTransaction(
      JSArray<JSBitcoinCashSendTransactionParams> params) {
    return waitForSuccessResponsePromise<JSBitcoinCashSendTransactionResponse>(
        method: BitcoinCashJSConstant.sendTransactionRequestName,
        params: JsUtils.asJSArray(params));
  }

  @override
  JSClientType get _client => JSClientType.bitcoinCash;
}
