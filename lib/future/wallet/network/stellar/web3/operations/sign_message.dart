import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/crypto/requets/messages.dart';
import 'package:stealth_stash/future/wallet/network/stellar/web3/types/types.dart';
import 'package:stealth_stash/future/wallet/web3/pages/web3_request_page_builder.dart';
import 'package:stealth_stash/future/wallet/web3/core/state.dart';
import 'package:stealth_stash/wallet/api/api.dart';
import 'package:stealth_stash/wallet/models/signing/signing.dart';
import 'package:stealth_stash/wallet/web3/networks/stellar/params/models/sign_message.dart';

class Web3StellarSignMessageStateController extends Web3StellarStateController<
    Web3StellarSignMessageResponse, StellarClient?, Web3StellarSignMessage> {
  String? get content => params.content;
  String get message => params.challeng;
  late final List<int> payloadMessage =
      BytesUtils.fromHexString(params.challeng).toImutableBytes;

  Web3StellarSignMessageStateController(
      {required super.walletProvider, required super.request});

  @override
  Future<Web3RequestResponseData<Web3StellarSignMessageResponse>>
      getResponse() async {
    final signature = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      addresses: [defaultAccount],
      network: network,
      sign: (generateSignature) async {
        final signRequest = GlobalSignRequest.stellar(
            digest: payloadMessage, index: defaultAccount.keyIndex.cast());
        final response = await generateSignature(signRequest);
        return Web3StellarSignMessageResponse(signature: response.signature);
      },
    ));
    return Web3RequestResponseData(response: signature.result);
  }

  @override
  Widget widgetBuilder(BuildContext context) {
    return Web3StateSignMessageView(
        controller: this,
        message: message,
        content: content,
        isPersonalSign: false);
  }
}
