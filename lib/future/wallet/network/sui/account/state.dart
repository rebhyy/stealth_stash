import 'package:flutter/material.dart';
import 'package:stealth_stash/future/wallet/global/pages/account_state.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:on_chain/sui/src/src.dart';

abstract class SuiAccountState<W extends StatefulWidget>
    extends ChainAccountState<W, SuiAPIProvider, SuiAddress, TokenCore, NFTCore,
        ISuiAddress, SuiClient, SuiChain, SuiWalletTransaction> {}
