import 'package:flutter/material.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/wallet/api/api.dart';
import 'package:stealth_stash/wallet/chain/account.dart';

class ManageSubstrateAccountToken extends StatefulWidget {
  final SubstrateClient client;
  final SubstrateChain account;
  final ISubstrateAddress address;
  const ManageSubstrateAccountToken(
      {super.key,
      required this.client,
      required this.account,
      required this.address});

  @override
  State<ManageSubstrateAccountToken> createState() =>
      _ManageSubstrateAccountTokenState();
}

class _ManageSubstrateAccountTokenState
    extends State<ManageSubstrateAccountToken>
    with
        SafeState<ManageSubstrateAccountToken>,
        ManageAccountTokenState<ManageSubstrateAccountToken, SubstrateClient,
            SubstrateToken, ISubstrateAddress, SubstrateChain> {
  @override
  SubstrateChain get account => widget.account;
  bool disableLocalTransfer = true;

  @override
  SubstrateClient get client => widget.client;
  @override
  void init() {
    if (client.metadata.controller == null) {
      progressKey.errorText("unavailable_token_management_on_this_network".tr,
          backToIdle: false);
      return;
    }
    disableLocalTransfer = !client.metadata.supportTransferLocalToken;
    listener = client.getAccountTokensStream(address.networkAddress).listen(
        onNewToken,
        onError: onError,
        onDone: onDone,
        cancelOnError: true);
    wallet = context.wallet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("manage_tokens".tr)),
      body: StreamPageProgress(
        controller: progressKey,
        initialWidget:
            ProgressWithTextView(text: 'fetching_account_token_please_wait'.tr),
        builder: (context) => ChainStreamBuilder(
          account: account,
          allowNotify: [DefaultChainNotify.token],
          builder: (context, value, _) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ConditionalWidget(
                  enable: disableLocalTransfer,
                  onActive: (context) => AlertTextContainer(
                      message: "local_asset_transfer_disabled_desc".tr),
                ),
              ),
              EmptyItemSliverWidgetView(
                isEmpty: tokens.isEmpty,
                itemBuilder: (context) => SliverConstraintsBoxView(
                  padding: WidgetConstant.paddingHorizontal20,
                  sliver: SliverList.separated(
                      separatorBuilder: (context, index) =>
                          WidgetConstant.divider,
                      itemBuilder: (context, index) {
                        final token = tokens.elementAt(index);
                        final bool exist = address.tokens.contains(token.token);
                        return APPStreamBuilder(
                          value: token.notifier,
                          builder: (context, value) => Shimmer(
                              onActive: (enable, context) =>
                                  AccountTokenDetailsView(
                                      error: token.status.isFailed
                                          ? "update_unknown_token_metadata_desc"
                                              .tr
                                          : null,
                                      onTapError: () {},
                                      onSelect: () {
                                        context.openSliverDialog(
                                            widget: (ctx) => DialogTextView(
                                                buttonWidget:
                                                    AsyncDialogDoubleButtonView(
                                                  firstButtonPressed: () =>
                                                      onTap(token),
                                                ),
                                                text: exist
                                                    ? "remove_token_from_account"
                                                        .tr
                                                    : "add_token_to_your_account"
                                                        .tr),
                                            label: exist
                                                ? "remove_token".tr
                                                : "add_token".tr);
                                      },
                                      onSelectIcon: APPCheckBox(
                                          value: exist,
                                          ignoring: true,
                                          onChanged: (value) {}),
                                      token: token.token),
                              enable: !token.status.isPending),
                        );
                      },
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      itemCount: tokens.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
