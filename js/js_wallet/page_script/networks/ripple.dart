part of '../scripts.dart';

class RipplePageController extends WalletStandardPageController {
  RipplePageController(super.postMessage);
  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    feature.rippleSignAndSendTransaction =
        RippleWalletAdapterRippleSignAndSendTransactionFeature.setup(
            signAndSendTransaction: _sendTransaction.toJS);
    feature.rippleSignTransaction =
        RippleWalletAdapterRippleSignTransactionFeature.setup(
            signTransaction: _signTransaction.toJS);
    feature.rippleSignMessage =
        RippleWalletAdapterRippleSignMessageFeature.setup(
            signMessage: _signMessage.toJS);
    feature.rippleConnect =
        JSRippleWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.rippleEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);

    feature.rippleDisconnect = JSWalletStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
  }

  JSPromise<JSRippleWalletStandardConnect> _connect([JSString? chainId]) {
    final network = JsUtils.asJSString(chainId);
    final params = network == null ? null : [network].toJS;
    return waitForSuccessResponsePromise<JSRippleWalletStandardConnect>(
        method: RippleJSConst.requestAccounts, params: params);
  }

  JSPromise<JSRippleSignTransactionResponse> _signTransaction(
      JSRippleSendOrSignTransactionParams params) {
    return waitForSuccessResponsePromise<JSRippleSignTransactionResponse>(
        method: RippleJSConst.signTransaction, params: [params].toJS);
  }

  JSPromise<JSRippleSendTransactionResponse> _sendTransaction(
      JSRippleSendOrSignTransactionParams params) {
    return waitForSuccessResponsePromise<JSRippleSendTransactionResponse>(
        method: RippleJSConst.sendTransaction, params: [params].toJS);
  }

  JSPromise<JSRippleSignMessageResponse> _signMessage(
      JSRippleSignMessageParams params) {
    return waitForSuccessResponsePromise<JSRippleSignMessageResponse>(
        method: RippleJSConst.signMessage, params: [params].toJS);
  }

  @override
  JSClientType get _client => JSClientType.xrpl;
}
