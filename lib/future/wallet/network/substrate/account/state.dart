import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/global/pages/account_state.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class SubstrateAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        SubstrateAPIProvider,
        BaseSubstrateAddress,
        TokenCore,
        NFTCore,
        ISubstrateAddress,
        SubstrateClient,
        SubstrateChain,
        SubstrateWalletTransaction> {}
