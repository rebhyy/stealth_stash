import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/crypto/types/networks.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/web3/pages/chain_permission.dart';
import 'package:stealth_stash/future/wallet/web3/pages/permission_view.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/web3/core/permission/models/authenticated.dart';

class BitcoinWeb3PermissionView extends StatefulWidget {
  const BitcoinWeb3PermissionView({required this.application, super.key});
  final Web3ApplicationAuthentication application;

  @override
  State<BitcoinWeb3PermissionView> createState() =>
      _BitcoinWeb3PermissionViewState();
}

class _BitcoinWeb3PermissionViewState extends State<BitcoinWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            BitcoinWeb3PermissionView,
            BitcoinBaseAddress,
            BitcoinChain,
            IBitcoinAddress,
            Web3InternalDefaultNetworkAccount,
            Web3InternalDefaultNetwork,
            Web3InternalDefaultChain>,
        Web3DefaultPermissionState<IBitcoinAddress> {
  @override
  Web3ApplicationAuthentication get application => widget.application;

  @override
  NetworkType get type => NetworkType.bitcoinAndForked;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<BitcoinBaseAddress, IBitcoinAddress,
            BitcoinChain>(
        chain: chain,
        chains: chains,
        isDefaultAddress: isDefaultAddress,
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
