import 'package:flutter/material.dart';
import 'package:stealth_stash/crypto/requets/messages.dart';
import 'package:stealth_stash/future/wallet/network/ton/web3/types/types.dart';
import 'package:stealth_stash/future/wallet/web3/pages/web3_request_page_builder.dart';
import 'package:stealth_stash/future/wallet/web3/core/state.dart';
import 'package:stealth_stash/wallet/api/api.dart';
import 'package:stealth_stash/wallet/models/signing/signing.dart';
import 'package:stealth_stash/wallet/web3/networks/ton/params/models/sign_message.dart';

class Web3TonSignMessageStateController extends Web3TonStateController<
    Web3TonSignMessageResponse, TonClient?, Web3TonSignMessage> {
  String? get content => params.content;
  String get message => params.challeng;
  late final List<int> payloadMessage = params.chalengBytes();

  Web3TonSignMessageStateController(
      {required super.walletProvider, required super.request});

  @override
  Future<Web3RequestResponseData<Web3TonSignMessageResponse>>
      getResponse() async {
    final sign = await walletProvider.wallet.signTransaction(
      request: WalletSigningRequest(
        addresses: [defaultAccount],
        network: network,
        sign: (generateSignature) async {
          final signRequest = GlobalSignRequest.ton(
              digest: payloadMessage, index: defaultAccount.keyIndex.cast());
          final response = await generateSignature(signRequest);
          return Web3TonSignMessageResponse(signature: response.signature);
        },
      ),
    );
    return Web3RequestResponseData<Web3TonSignMessageResponse>(
        response: sign.result);
  }

  @override
  Widget widgetBuilder(BuildContext context) {
    return Web3StateSignMessageView(
        controller: this,
        message: message,
        content: content,
        isPersonalSign: true);
  }
}
