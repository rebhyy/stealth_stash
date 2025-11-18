import 'package:on_chain/tron/tron.dart';
import 'package:stealth_stash/wallet/models/swap/tron/tron_swap.dart';

/// Minimal SunSwap V2 service for TRX/TRC20 swaps
/// For demo: Shows swap UI and calculates quotes
/// Full implementation: Transaction building + execution
class TronSwapService {
  final TronAddress routerAddress;
  final bool isTestnet;

  TronSwapService({
    required this.routerAddress,
    this.isTestnet = false,
  });

  factory TronSwapService.forNetwork(String networkName) {
    final isTest = networkName.toLowerCase().contains('test') ||
        networkName.toLowerCase().contains('shasta') ||
        networkName.toLowerCase().contains('nile');

    return TronSwapService(
      routerAddress: TronAddress(
        isTest
            ? TronSwapConstants.routerShasta
            : TronSwapConstants.routerMainnet,
      ),
      isTestnet: isTest,
    );
  }

  /// Get swap quote (simplified - real implementation would query router)
  Future<TronSwapQuote> getQuote(TronSwapParams params) async {
    // Demo implementation: Simple calculation
    // Real implementation would call router.getAmountsOut()
    
    final amountIn = params.amountIn;
    
    // Simulate 0.3% fee (typical DEX fee)
    final amountAfterFee = amountIn * BigInt.from(997) ~/ BigInt.from(1000);
    
    // Simulate price (1 TRX = 0.15 USDT for demo)
    // Real implementation gets from liquidity pools
    final amountOut = amountAfterFee * BigInt.from(15) ~/ BigInt.from(100);
    
    // Calculate minimum with slippage
    final slippageMultiplier = BigInt.from(
      ((1 - params.slippage / 100) * 10000).toInt(),
    );
    final minimumOut = amountOut * slippageMultiplier ~/ BigInt.from(10000);
    
    return TronSwapQuote(
      amountIn: amountIn,
      amountOut: amountOut,
      minimumAmountOut: minimumOut,
      priceImpact: 0.1, // Demo value
      path: [params.tokenIn, params.tokenOut],
      slippage: params.slippage,
    );
  }

  /// Build swap transaction (placeholder for demo)
  /// Real implementation would build TriggerSmartContract for router
  Future<Map<String, dynamic>> buildSwapTransaction({
    required TronSwapParams params,
    required TronSwapQuote quote,
  }) async {
    // This would build the actual contract call:
    // router.swapExactTokensForTokens(
    //   amountIn,
    //   amountOutMin,
    //   path,
    //   to,
    //   deadline
    // )
    
    return {
      'router': routerAddress.toAddress(),
      'amountIn': params.amountIn.toString(),
      'amountOutMin': quote.minimumAmountOut.toString(),
      'path': [params.tokenIn.toAddress(), params.tokenOut.toAddress()],
      'to': params.recipient.toAddress(),
      'deadline': params.deadline,
    };
  }

  /// Get popular token addresses for testnet
  List<TronSwapToken> getPopularTokens() {
    if (!isTestnet) {
      return [
        TronSwapToken(
          address: TronAddress(TronSwapConstants.usdtMainnet),
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
        ),
        TronSwapToken(
          address: TronAddress(TronSwapConstants.usdcMainnet),
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
      ];
    }

    return [
      TronSwapToken(
        address: TronAddress(TronSwapConstants.usdtNile),
        symbol: 'USDT',
        name: 'Tether USD (Testnet)',
        decimals: 6,
      ),
      TronSwapToken(
        address: TronAddress(TronSwapConstants.usdjNile),
        symbol: 'USDJ',
        name: 'USDJ (Testnet)',
        decimals: 18,
      ),
    ];
  }
}

/// Token info for swap UI
class TronSwapToken {
  final TronAddress address;
  final String symbol;
  final String name;
  final int decimals;

  TronSwapToken({
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
  });

  bool get isTRX => address.toAddress() == 'T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb';
}
