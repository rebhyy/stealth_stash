import 'package:flutter/material.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/wallet/transaction/transaction.dart';
import 'package:stealth_stash/future/wallet/network/tron/swap/tron_swap_transaction_controller.dart';
import 'fee.dart';

class TronSwapTransactionWidget extends StatelessWidget {
  final TronSwapTransactionController controller;
  
  const TronSwapTransactionWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SunSwap V2 Token Swap", style: context.textTheme.titleLarge),
          WidgetConstant.height8,
          Text("Swap tokens on SunSwap DEX", style: context.textTheme.bodySmall),
          WidgetConstant.height20,
        ],
      ),
      
      // Swap Details Card
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.secondary.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildSwapRow(
                context,
                'From',
                'TRX',
                '${controller.params.amountIn ~/ BigInt.from(1000000)} TRX',
              ),
              const SizedBox(height: 12),
              const Icon(Icons.arrow_downward, size: 32),
              const SizedBox(height: 12),
              _buildSwapRow(
                context,
                'To (Minimum)',
                controller.params.tokenOut.toAddress().substring(0, 10),
                '${controller.quote.minimumAmountOut} tokens',
              ),
              const Divider(height: 24),
              _buildInfoRow(context, 'Price Impact', '${controller.quote.priceImpact.toStringAsFixed(2)}%'),
              _buildInfoRow(context, 'Slippage Tolerance', '${controller.quote.slippage.toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ),
      
      WidgetConstant.height20,
      
      // Router Info
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SunSwap V2 Router',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.routerAddress.toAddress(),
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      WidgetConstant.height20,
      TronTransactionFeeDataView(controller: controller),
      TransactionStateSendTransaction(controller: controller),
    ]);
  }

  Widget _buildSwapRow(BuildContext context, String label, String symbol, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(symbol, style: context.textTheme.titleMedium),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
