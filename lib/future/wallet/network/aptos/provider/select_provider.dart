import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/select_provider.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/types.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class SelectAptosProviderView extends StatefulWidget {
  const SelectAptosProviderView(this.chain, {super.key});
  final AptosChain chain;

  @override
  State<SelectAptosProviderView> createState() =>
      __SelectAptosProviderViewState();
}

class __SelectAptosProviderViewState extends State<SelectAptosProviderView>
    with
        SafeState<SelectAptosProviderView>,
        SelectProviderViewState<SelectAptosProviderView, AptosAPIProvider,
            AptosHTTPService> {
  @override
  APPCHAINPROVIDER<AptosAPIProvider> get chain => widget.chain;
  List<AptosAPIProvider> fullNodeProvers = [];
  List<AptosAPIProvider> graphQlProviders = [];
  @override
  void onTapProvider(AptosAPIProvider provider) {
    AptosProviderIdentifier? identifier;
    switch (provider.type) {
      case AptosAPIProviderType.fullnode:
        final graphQL = graphQlProviders.firstWhereOrNull(
            (e) => e.identifier == service?.graphQlProvider.identifier,
            orElse: () => graphQlProviders.firstOrNull);
        if (graphQL != null) {
          identifier = AptosProviderIdentifier(
              fullNodeIdentifier: provider.identifier,
              graphQlIdentifier: graphQL.identifier);
        }

        break;
      case AptosAPIProviderType.graphQl:
        final fullNode = fullNodeProvers.firstWhereOrNull(
            (e) => e.identifier == service?.provider.identifier,
            orElse: () => fullNodeProvers.firstOrNull);
        if (fullNode != null) {
          identifier = AptosProviderIdentifier(
              fullNodeIdentifier: fullNode.identifier,
              graphQlIdentifier: provider.identifier);
        }
        break;
    }
    if (identifier != null) {
      context.wallet
          .setAccountProvider(provider: identifier, account: widget.chain);
    }
  }

  @override
  Future<void> init() async {
    providers = await chain.getProviders();
    service = chain.service as AptosHTTPService?;
    progressKey.backToIdle();
    fullNodeProvers = providers
        .where((e) => e.type == AptosAPIProviderType.fullnode)
        .toList();
    graphQlProviders =
        providers.where((e) => e.type == AptosAPIProviderType.graphQl).toList();
    service = widget.chain.service as AptosHTTPService?;
  }

  @override
  Widget providerStateBuilder(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("full_node".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ListView.builder(
            physics: WidgetConstant.noScrollPhysics,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final provider = fullNodeProvers.elementAt(index);
              final bool isSelected =
                  service?.provider.identifier == provider.identifier;
              return ProviderInfoWidget(
                  onTapProvider: onTapProvider,
                  provider: provider,
                  connect: chain.serviceStatus.isConnect,
                  isSelected: isSelected,
                  service: service);
            },
            itemCount: fullNodeProvers.length,
          ),
          WidgetConstant.height20,
          Text("graphql".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ListView.builder(
              physics: WidgetConstant.noScrollPhysics,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final provider = graphQlProviders.elementAt(index);
                final bool isSelected =
                    service?.graphQlProvider.identifier == provider.identifier;
                return ProviderInfoWidget(
                    onTapProvider: onTapProvider,
                    provider: provider,
                    connect: chain.serviceStatus.isConnect,
                    isSelected: isSelected,
                    service: service);
              },
              itemCount: graphQlProviders.length),
          if (network.supportCustomNode)
            ContainerWithBorder(
              onRemove: onUpdateProvider,
              onRemoveIcon:
                  Icon(Icons.add_box, color: context.onPrimaryContainer),
              child: Text("network_add_provider".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}
