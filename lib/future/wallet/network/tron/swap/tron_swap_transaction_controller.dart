import 'package:flutter/material.dart';
import 'package:on_chain/solidity/contract/fragments.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:stealth_stash/future/wallet/network/tron/transaction/controllers/controller.dart';
import 'package:stealth_stash/future/wallet/network/tron/transaction/types/types.dart';
import 'package:stealth_stash/future/wallet/network/tron/transaction/widgets/widgets/swap.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/wallet/wallet.dart';
import 'package:stealth_stash/wallet/models/swap/tron/tron_swap.dart';

/// SunSwap V2 Router ABI Fragments
class SunSwapABI {
  /// function swapExactTokensForTokens(
  ///   uint amountIn,
  ///   uint amountOutMin,
  ///   address[] calldata path,
  ///   address to,
  ///   uint deadline
  /// ) external returns (uint[] memory amounts)
  static final AbiFunctionFragment swapExactTokensForTokens =
      AbiFunctionFragment.fromJson(const {
    "inputs": [
      {"internalType": "uint256", "name": "amountIn", "type": "uint256"},
      {"internalType": "uint256", "name": "amountOutMin", "type": "uint256"},
      {"internalType": "address[]", "name": "path", "type": "address[]"},
      {"internalType": "address", "name": "to", "type": "address"},
      {"internalType": "uint256", "name": "deadline", "type": "uint256"}
    ],
    "name": "swapExactTokensForTokens",
    "outputs": [
      {"internalType": "uint256[]", "name": "amounts", "type": "uint256[]"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  });

  /// Encode swap function call
  static List<int> encodeSwap({
    required BigInt amountIn,
    required BigInt amountOutMin,
    required List<TronAddress> path,
    required TronAddress recipient,
    required int deadline,
  }) {
    return swapExactTokensForTokens.encode([
      amountIn,
      amountOutMin,
      path.map((addr) => addr.toAddress()).toList(),
      recipient.toAddress(),
      BigInt.from(deadline),
    ]);
  }
}

/// Transaction controller for SunSwap swaps
/// 
/// Usage Example:
/// ```dart
/// final controller = TronSwapTransactionController(
///   walletProvider: walletProvider,
///   account: account,
///   address: address,
///   network: network,
///   apiProvider: apiProvider,
///   params: swapParams,
///   quote: swapQuote,
///   routerAddress: routerAddress,
/// );
/// 
/// // Build and sign transaction
/// final transaction = await controller.buildTransaction();
/// final signedTx = await controller.signTransaction(transaction);
/// 
/// // Broadcast to network
/// final result = await controller.sendTransaction(signedTx);
/// 
/// // Get transaction hash
/// final txHash = result.txId;
/// ```
class TronSwapTransactionController
    extends TronTransactionStateController2<TriggerSmartContract> {
  final TronSwapParams params;
  final TronSwapQuote quote;
  final TronAddress routerAddress;

  TronSwapTransactionController({
    required super.walletProvider,
    required super.account,
    required super.address,
    required this.params,
    required this.quote,
    required this.routerAddress,
  });

  @override
  TransactionContractType get transactionType {
    return TransactionContractType.triggerSmartContract;
  }

  @override
  TransactionStateController cloneController(ITronAddress address) {
    return TronSwapTransactionController(
      walletProvider: walletProvider,
      account: account,
      address: address,
      params: params,
      quote: quote,
      routerAddress: routerAddress,
    );
  }

  @override
  List<LiveFormField<Object?, Object>> get fields => [];

  @override
  TransactionStateStatus getStateStatus() {
    // Check if user has enough balance for swap amount + fees
    final status = super.getStateStatus();
    if (!status.isReady) {
      return status;
    }
    
    // Check if user has enough TRX for the swap amount + fees
    final totalNeeded = params.amountIn + txFee.fee.fee.balance;
    final available = address.address.currencyBalance;
    
    if (totalNeeded > available) {
      final deficit = IntegerBalance.zero(network.token);
      deficit.updateBalance(totalNeeded - available);
      return TransactionStateStatus.insufficient(deficit);
    }
    
    return TransactionStateStatus.ready();
  }

  @override
  Widget widgetBuilder(BuildContext context) {
    return TronSwapTransactionWidget(controller: this);
  }

  @override
  Future<ITronTransactionData<TriggerSmartContract>> buildTransactionData({
    bool simulate = false,
  }) async {
    final blockData = await transactionBlockRequirment(simulate: simulate);

    // Encode the swap function call
    final encodedData = SunSwapABI.encodeSwap(
      amountIn: params.amountIn,
      amountOutMin: quote.minimumAmountOut,
      path: [params.tokenIn, params.tokenOut],
      recipient: params.recipient,
      deadline: params.deadline,
    );

    // Build TriggerSmartContract
    final contract = TriggerSmartContract(
      ownerAddress: address.networkAddress,
      contractAddress: routerAddress,
      data: encodedData,
    );

    return ITronTransactionData(
      fee: txFee.fee,
      blockData: blockData,
      memo: 'SunSwap V2: Swap Tokens',
      feeLimit: BigInt.from(100000000), // 100 TRX energy fee limit for swap
      contract: contract,
    );
  }

  @override
  Future<List<IWalletTransaction<TronWalletTransaction, ITronAddress>>>
      buildWalletTransaction({
    required ITronSignedTransaction<ITronTransactionData<TriggerSmartContract>>
        signedTx,
    required SubmitTransactionSuccess txId,
  }) async {
    // Build wallet transaction record for history
    // This is called after successful broadcast
    // For now return empty, can be enhanced to create proper swap transaction record
    return [];
  }
}
