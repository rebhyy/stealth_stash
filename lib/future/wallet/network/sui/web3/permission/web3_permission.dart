import 'package:flutter/material.dart';
import 'package:stealth_stash/crypto/types/networks.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/web3/pages/chain_permission.dart';
import 'package:stealth_stash/future/wallet/web3/pages/permission_view.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/web3/core/permission/models/authenticated.dart';
import 'package:on_chain/sui/sui.dart';

class SuiWeb3PermissionView extends StatefulWidget {
  const SuiWeb3PermissionView({required this.application, super.key});
  final Web3ApplicationAuthentication application;

  @override
  State<SuiWeb3PermissionView> createState() => _SuiWeb3PermissionViewState();
}

class _SuiWeb3PermissionViewState extends State<SuiWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            SuiWeb3PermissionView,
            SuiAddress,
            SuiChain,
            ISuiAddress,
            Web3InternalDefaultNetworkAccount,
            Web3InternalDefaultNetwork,
            Web3InternalDefaultChain>,
        Web3DefaultPermissionState<ISuiAddress> {
  @override
  Web3ApplicationAuthentication get application => widget.application;

  @override
  NetworkType get type => NetworkType.sui;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<SuiAddress, ISuiAddress, SuiChain>(
        isDefaultAddress: isDefaultAddress,
        chain: chain,
        chains: chains,
        onUpdateState: updateState,
        hasPermission: hasPermission,
        addAccount: addAccount,
        addresses: chain.addresses,
        onChangeChain: onChangeChain,
        onChangeDefaultAccount: onChangeDefaultPermission,
        activities: activities,
        menuItems: menuItems);
  }
}
