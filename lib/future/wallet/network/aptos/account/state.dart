import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/global/pages/account_state.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';

abstract class AptosAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        AptosAPIProvider,
        AptosAddress,
        AptosFATokens,
        NFTCore,
        IAptosAddress,
        AptosClient,
        AptosChain,
        AptosWalletTransaction> {}
