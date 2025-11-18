import 'package:flutter/material.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class RippleAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        RippleAPIProvider,
        XRPAddress,
        RippleIssueToken,
        RippleNFToken,
        IXRPAddress,
        XRPClient,
        XRPChain,
        XRPWalletTransaction> {}
