import 'package:on_chain/tron/tron.dart';

class TronSwapQuote {
  final BigInt amountIn;
  final BigInt amountOut;
  final BigInt minimumAmountOut;
  final double priceImpact;
  final List<TronAddress> path;
  final double slippage;
  
  TronSwapQuote({
    required this.amountIn,
    required this.amountOut,
    required this.minimumAmountOut,
    required this.priceImpact,
    required this.path,
    required this.slippage,
  });
  
  String get rate {
    if (amountIn == BigInt.zero) return '0';
    final rate = amountOut.toDouble() / amountIn.toDouble();
    return rate.toStringAsFixed(6);
  }
}

class TronSwapParams {
  final TronAddress tokenIn;
  final TronAddress tokenOut;
  final BigInt amountIn;
  final double slippage;
  final TronAddress recipient;
  final int deadline;
  
  TronSwapParams({
    required this.tokenIn,
    required this.tokenOut,
    required this.amountIn,
    required this.slippage,
    required this.recipient,
    required this.deadline,
  });
}

class TronSwapResult {
  final String txId;
  final BigInt amountIn;
  final BigInt amountOut;
  final List<TronAddress> path;
  
  TronSwapResult({
    required this.txId,
    required this.amountIn,
    required this.amountOut,
    required this.path,
  });
}

enum TronSwapStatus {
  idle,
  fetching,
  ready,
  swapping,
  success,
  error,
}
