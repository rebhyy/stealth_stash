part of '../scripts.dart';

class MoneroPageController extends WalletStandardPageController {
  MoneroPageController(super.postMessage);
  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    feature.moneroSignAndSendTransaction =
        MoneroWalletAdapterMoneroSignAndSendTransactionFeature.setup(
            signAndSendTransaction: _sendTransaction.toJS);
    feature.moneroSignMessage =
        MoneroWalletAdapterMoneroSignMessageFeature.setup(
            signMessage: _signMessage.toJS);
    feature.moneroConnect =
        JSMoneroWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.moneroEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);

    feature.moneroDisconnect = JSWalletStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
  }

  JSPromise<JSMoneroWalletStandardConnect> _connect([JSString? chainId]) {
    final network = JsUtils.asJSString(chainId);
    final params = network == null ? null : [network].toJS;
    return waitForSuccessResponsePromise<JSMoneroWalletStandardConnect>(
        method: MoneroJSConst.requestAccounts, params: params);
  }

  JSPromise<JSMoneroSendTransactionResponse> _sendTransaction(
      JSMoneroSendOrSignTransactionParams params) {
    return waitForSuccessResponsePromise<JSMoneroSendTransactionResponse>(
        method: MoneroJSConst.sendTransaction, params: [params].toJS);
  }

  JSPromise<JSMoneroSignMessageResponse> _signMessage(
      JSMoneroSignMessageParams params) {
    return waitForSuccessResponsePromise<JSMoneroSignMessageResponse>(
        method: MoneroJSConst.signMessage, params: [params].toJS);
  }

  @override
  JSClientType get _client => JSClientType.monero;
}
