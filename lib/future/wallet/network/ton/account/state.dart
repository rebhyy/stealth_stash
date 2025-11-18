import 'package:flutter/material.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:ton_dart/ton_dart.dart';

abstract class TonAccountState<W extends StatefulWidget>
    extends ChainAccountState<W, TonAPIProvider, TonAddress, TonJettonToken,
        NFTCore, ITonAddress, TonClient, TonChain, TonWalletTransaction> {}
