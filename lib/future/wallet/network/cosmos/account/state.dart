import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/wallet/wallet.dart';

abstract class CosmosAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        CosmosAPIProvider,
        CosmosBaseAddress,
        CW20Token,
        NFTCore,
        ICosmosAddress,
        CosmosClient,
        CosmosChain,
        CosmosWalletTransaction> {}
