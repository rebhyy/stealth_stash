part of '../scripts.dart';

class ADAPageController extends WalletStandardPageController {
  ADAPageController(super.postMessage);
  late final JSWalletCardanoCIP30Extension _api;
  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    final cardanoExtension = JSWalletCardanoExtension.setup(
        isEnabled: _isEnabled.toJS,
        apiVersion: ADAJSConst.cardanoExtensionVersion.toJS,
        name: JSWalletConstant.name.toJS,
        icon: JSWalletConstant.appPngImage.toJS,
        enable: _enable.toJS);
    if (cardanoNullable == null) {
      cardano = JSWalletCardanoInjected(JSObject());
    }
    cardano.onChain = cardanoExtension.toProxy(debugKey: "cardanoExtension: ");

    feature.cardanoConnect =
        JSStellarWalletStandardConnectFeature.setup(connect: _connect.toJS);

    feature.cardanoSignMessage = JSWalletStandardADASignMessageFeature.setup(
        signMessage: _signMessage.toJS);

    feature.cardanoEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
    feature.cardanoDisconnect = JSWalletStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
    feature.cardanoGetNetworkId = JSWalletStandardADAGetNetworkIdFeature.setup(
        getNetworkId: _wsGetNetworkId.toJS);
    feature.cardanoGetBalance = JSWalletStandardADAGetBalanceFeature.setup(
        getBalance: _wsGetBalance.toJS);
    feature.cardanoGetUtxos =
        JSWalletStandardADAGetUtxosFeature.setup(getUtxos: _wsGetUtxos.toJS);
    feature.cardanoGetAddressUtxos =
        JSWalletStandardADAGetAddressUtxosFeature.setup(
            getAddressUtxos: _wsGetAddressUtxos.toJS);
    feature.cardanoGetCollateral =
        JSWalletStandardADAGetCollateralFeature.setup(
            getCollateral: _wsGetCollateral.toJS);
    feature.cardanoGetUsedAddresses =
        JSWalletStandardADAGetUsedAddressesFeature.setup(
            getUsedAddresses: _wsGetUsedAddresses.toJS);
    feature.cardanoGetUnusedAddresses =
        JSWalletStandardADAGetUnusedAddressesFeature.setup(
            getUnusedAddresses: _wsGetUnusedAddresses.toJS);
    feature.cardanoGetChangeAddress =
        JSWalletStandardADAGetChangeAddressFeature.setup(
            getChangeAddress: _wsGetChangeAddress.toJS);
    feature.cardanoGetRewardAddresses =
        JSWalletStandardADAGetRewardAddressesFeature.setup(
            getRewardAddresses: _wsGetRewardAddresses.toJS);
    feature.cardanoSignTx =
        JSWalletStandardADASignTxFeature.setup(signTx: _wsSignTx.toJS);
    feature.cardanoSignData =
        JSWalletStandardADASignDataFeature.setup(signData: _wsSignData.toJS);
    feature.cardanoSignTransaction =
        JSWalletStandardADASignTransactionFeature.setup(
            signTransaction: _signTransaction.toJS);
    feature.cardanoSignAndTransaction =
        JSWalletStandardADASignAndSendTransactionFeature.setup(
            signAndSendTransaction: _signAndSendTransaction.toJS);
    feature.cardanoGetScript =
        JSWalletStandardADAGetScriptFeature.setup(getScript: _wsGetScript.toJS);
    feature.cardanoIsEnabled =
        JSWalletStandardADAIsEnabledFeature.setup(isEnabled: _isEnabled.toJS);
    feature.cardanoSubmitTx =
        JSWalletStandardADASubmitTxFeature.setup(submitTx: _wsSubmitTx.toJS);
    feature.cardanoSubmitTxs =
        JSWalletStandardADASubmitTxsFeature.setup(submitTxs: _wsSubmitTxs.toJS);
    feature.cardanoSignTxs =
        JSWalletStandardADASignTxsFeature.setup(signTxs: _wsSignTxs.toJS);
    feature.cardanoGetAccountPub =
        JSWalletStandardADAGetAccountPubFeature.setup(
            getAccountPub: _wsGetAccountPub.toJS);
    feature.cardanoGetScriptRequirements =
        JSWalletStandardADAGetScriptRequirementsFeature.setup(
            getScriptRequirements: _wsGetScriptRequirements.toJS);
    feature.cardanoSubmitUnsignedTx =
        JSWalletStandardADASubmitUnsignedTxFeature.setup(
            submitUnsignedTx: _wsSubmitUnsignedTx.toJS);

    /// _wsGetScriptRequirements

    final cip103 = JSWalletCardanoCIP103Extension.setup(
        signTxs: _signTxs.toJS, submitTxs: _submitTxes.toJS);
    final cip104 = JSWalletCardanoCIP104Extension.setup(
        getAccountPub: _getAccountPub.toJS);
    final cip106 = JSWalletCardanoCIP106Extension.setup(
        getScriptRequirements: _getScriptRequirements.toJS,
        getScript: _getScript.toJS,
        submitUnsignedTx: _submitUnsignedTx.toJS,
        getCompletedTx: _getCompletedTx.toJS,
        getCollateral: _getCollateral.toJS);
    _api = JSWalletCardanoCIP30Extension.setup(
        cip103: cip103,
        cip106: cip106,
        cip104: cip104,
        getBalance: _getBalance.toJS,
        getChangeAddress: _getChangeAddress.toJS,
        getCollateral: _getCollateral.toJS,
        getExtensions: _getExtension.toJS,
        getNetworkId: _getNetworkId.toJS,
        getRewardAddresses: _getRewardAddresses.toJS,
        getUnusedAddresses: _getUnusedAddresses.toJS,
        getUsedAddresses: _getUsedAddresses.toJS,
        getUtxos: _getUtxos.toJS,
        signData: _signData.toJS,
        signTx: _signTx.toJS,
        submitTx: _submitTx.toJS);
  }

  JSPromise<JSArray<JSADAScriptRequirement>> _wsGetScriptRequirements(
      [JSADAGetScriptParams? params]) {
    return waitForSuccessResponsePromise<JSArray<JSADAScriptRequirement>>(
        method: ADAJSConst.getScriptRequirements,
        params: JsUtils.asJSArray(params));
  }

  JSPromise<JSArray<JSADAScriptRequirement>> _getScriptRequirements(
      [JSString? address]) {
    return waitForSuccessResponsePromise<JSArray<JSADAScriptRequirement>>(
        method: ADAJSConst.getScriptRequirements,
        params: JsUtils.asJSArray(address),
        provider: PageRequestType.cardano);
  }

  JSPromise<JSArray<JSAny>> _getCompletedTx(JSString hash32) {
    return waitForSuccessResponsePromise<JSArray<JSAny>>(
        method: ADAJSConst.getCompletedTx,
        params: [hash32].toJS,
        provider: PageRequestType.cardano);
  }

  JSPromise<JSString> _submitUnsignedTx(JSString unsignedTransaction) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.submitUnsignedTx,
        params: [unsignedTransaction].toJS,
        provider: PageRequestType.cardano);
  }

  JSPromise<JSString> _wsSubmitUnsignedTx(JSString unsignedTransaction) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.submitUnsignedTx,
        params: [unsignedTransaction].toJS);
  }

  JSPromise<JSString> _getScript([JSADAGetScriptParams? params]) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.getScript,
        params: JsUtils.asJSArray(params),
        provider: PageRequestType.cardano);
  }

  JSPromise<JSString> _wsGetScript([JSADAGetScriptParams? params]) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.getScript, params: JsUtils.asJSArray(params));
  }

  JSPromise<JSAny> _signTx(JSString transaction, [JSBoolean? partialSign]) {
    return waitForSuccessResponsePromise<JSAny>(
        method: ADAJSConst.signTx,
        params: [
          transaction,
          JsUtils.undefinedAsNull(partialSign) ?? false.toJS
        ].toJS,
        provider: PageRequestType.cardano);
  }

  JSPromise<JSString> _wsGetAccountPub([JSADAGetAccountPubParams? address]) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.getAccountPub, params: JsUtils.asJSArray(address));
  }

  JSPromise<JSString> _getAccountPub([JSADAGetAccountPubParams? address]) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.getAccountPub,
        params: JsUtils.asJSArray(address),
        provider: PageRequestType.cardano);
  }

  JSPromise<JSStellarWalletStandardConnect> _connect([JSString? chainId]) {
    final network = JsUtils.asJSString(chainId);
    final params = network == null ? null : [network].toJS;
    return waitForSuccessResponsePromise<JSStellarWalletStandardConnect>(
        method: ADAJSConst.requestAccounts, params: params);
  }

  JSPromise<Proxy<JSWalletCardanoCIP30Extension>> _enable([JSString? chainId]) {
    final network = JsUtils.asJSString(chainId);
    final params = network == null ? null : [network].toJS;
    return waitForSuccessResponse<JSStellarWalletStandardConnect>(
            method: ADAJSConst.requestAccounts, params: params)
        .then((e) => _api.toProxy(debugKey: "api: "))
        .toPromise;
  }

  JSPromise<JSBoolean> _isEnabled() {
    return waitForSuccessResponsePromise<JSBoolean>(
        method: ADAJSConst.isEnabled);
  }

  JSPromise<JSBoolean> _wsGetNetworkId() {
    return waitForSuccessResponsePromise<JSBoolean>(
        method: ADAJSConst.getNetworkId);
  }

  JSPromise<JSNumber> _getNetworkId() {
    return waitForSuccessResponsePromise<JSNumber>(
        method: ADAJSConst.getNetworkId, provider: PageRequestType.cardano);
  }

  JSPromise<JSArray<JSString>> _getUtxos(
      [JSString? amount, JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
      method: ADAJSConst.getUtxos,
      params: [
        JsUtils.undefinedAsNull(amount),
        JsUtils.undefinedAsNull(paginate)
      ].toJS,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSArray<JSString>> _wsGetAddressUtxos(
      JSADAGetAddressUtxosParams params) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: ADAJSConst.getAddressUtxos, params: JsUtils.asJSArray(params));
  }

  JSPromise<JSArray<JSString>> _wsGetUtxos(
      [JSString? amount, JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: ADAJSConst.getUtxos,
        params: [
          JsUtils.undefinedAsNull(amount),
          JsUtils.undefinedAsNull(paginate)
        ].toJS);
  }

  JSPromise<JSString> _wsGetBalance() {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.getBalance);
  }

  JSPromise<JSString> _getBalance() {
    return waitForSuccessResponsePromise<JSString>(
      method: ADAJSConst.getBalance,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSArray<JSString>> _wsGetUsedAddresses([JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: ADAJSConst.getUsedAddresses,
        params: [JsUtils.undefinedAsNull(paginate)].toJS);
  }

  JSPromise<JSArray<JSString>> _getUsedAddresses([JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
      method: ADAJSConst.getUsedAddresses,
      params: [JsUtils.undefinedAsNull(paginate)].toJS,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSArray<JSString>> _getUnusedAddresses([JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
      method: ADAJSConst.getUnusedAddresses,
      params: [JsUtils.undefinedAsNull(paginate)].toJS,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSArray<JSString>> _wsGetUnusedAddresses(
      [JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: ADAJSConst.getUnusedAddresses,
        params: [JsUtils.undefinedAsNull(paginate)].toJS);
  }

  JSPromise<JSArray<JSString>> _wsGetRewardAddresses(
      [JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: ADAJSConst.getRewardAddresses,
        params: [JsUtils.undefinedAsNull(paginate)].toJS);
  }

  JSPromise<JSArray<JSString>> _getRewardAddresses([JSADAPaginate? paginate]) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
      method: ADAJSConst.getRewardAddresses,
      params: [JsUtils.undefinedAsNull(paginate)].toJS,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSArray<JSString>?> _wsGetCollateral(
      [JSADAGetCollateralParams? params]) {
    return waitForSuccessResponsePromise<JSArray<JSString>?>(
        method: ADAJSConst.getCollateral,
        params: [JsUtils.undefinedAsNull(params)].toJS);
  }

  JSPromise<JSArray<JSString>?> _getCollateral(
      [JSADAGetCollateralParams? params]) {
    return waitForSuccessResponsePromise<JSArray<JSString>?>(
      method: ADAJSConst.getCollateral,
      params: [JsUtils.undefinedAsNull(params)].toJS,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSAny> _wsSignTx(JSString transaction, [JSBoolean? partialSign]) {
    return waitForSuccessResponsePromise<JSAny>(
        method: ADAJSConst.signTx,
        params: [
          transaction,
          JsUtils.undefinedAsNull(partialSign) ?? false.toJS
        ].toJS);
  }

  JSPromise<JSAny> _signTxs(JSArray<JSADASignOrSubmitTxesParams> params) {
    return waitForSuccessResponsePromise<JSAny>(
      method: ADAJSConst.signTxs,
      params: JsUtils.asJSArray(params),
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSAny> _submitTxes(JSArray<JSADASignOrSubmitTxesParams> params) {
    return waitForSuccessResponsePromise<JSAny>(
      method: ADAJSConst.submitTxs,
      params: JsUtils.asJSArray(params),
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSAny> _wsSignTxs(JSArray<JSADASignOrSubmitTxesParams> params) {
    return waitForSuccessResponsePromise<JSAny>(
        method: ADAJSConst.signTxs, params: JsUtils.asJSArray(params));
  }

  JSPromise<JSAny> _wsSubmitTxs(JSArray<JSADASignOrSubmitTxesParams> params) {
    return waitForSuccessResponsePromise<JSAny>(
        method: ADAJSConst.submitTxs, params: JsUtils.asJSArray(params));
  }

  JSPromise<JSADASignDataResponse> _wsSignData(JSAny addr, JSAny payload) {
    return waitForSuccessResponsePromise<JSADASignDataResponse>(
        method: ADAJSConst.signData, params: [addr, payload].toJS);
  }

  JSPromise<JSADASignDataResponse> _signData(JSString addr, JSAny payload) {
    return waitForSuccessResponsePromise<JSADASignDataResponse>(
      method: ADAJSConst.signData,
      params: [addr, payload].toJS,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSString> _wsGetChangeAddress() {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.getChangeAddress);
  }

  JSPromise<JSString> _getChangeAddress() {
    return waitForSuccessResponsePromise<JSString>(
      method: ADAJSConst.getChangeAddress,
      provider: PageRequestType.cardano,
    );
  }

  JSPromise<JSArray<JSString>> _signTransaction(JSAny params) {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: ADAJSConst.signTransaction, params: JsUtils.asJSArray(params));
  }

  JSPromise<JSArray<JSAny>> _signAndSendTransaction(JSAny params) {
    return waitForSuccessResponsePromise<JSArray<JSAny>>(
        method: ADAJSConst.signAndSendTransaction,
        params: JsUtils.asJSArray(params));
  }

  JSPromise<JSADASignMessageResponse> _signMessage(
      JSStellarSignMessageParams params) {
    return waitForSuccessResponsePromise<JSADASignMessageResponse>(
        method: ADAJSConst.signMessage, params: [params].toJS);
  }

  JSPromise<JSArray<JSADAExtension>> _getExtension() {
    return waitForSuccessResponsePromise<JSArray<JSADAExtension>>(
        method: ADAJSConst.getExtensions, provider: PageRequestType.cardano);
  }

  JSPromise<JSString> _submitTx(JSString transaction) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.submitTx,
        params: [transaction].toJS,
        provider: PageRequestType.cardano);
  }

  JSPromise<JSString> _wsSubmitTx(JSString transaction) {
    return waitForSuccessResponsePromise<JSString>(
        method: ADAJSConst.submitTx, params: [transaction].toJS);
  }

  @override
  JSClientType get _client => JSClientType.cardano;
}
