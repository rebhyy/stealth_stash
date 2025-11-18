import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/swap/tron/tron_swap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stealth_stash/future/router/page_router.dart';
import 'tron_swap_service.dart';
import 'tron_swap_transaction_controller.dart';

class TronSwapPage extends StatefulWidget {
  final TronChain account;

  const TronSwapPage({required this.account, super.key});

  @override
  State<TronSwapPage> createState() => _TronSwapPageState();
}

class _TronSwapPageState extends State<TronSwapPage> {
  late final TronSwapService _swapService;
  TronSwapStatus _status = TronSwapStatus.idle;
  TronSwapQuote? _quote;
  String? _error;

  final TextEditingController _amountController = TextEditingController();
  TronSwapToken? _selectedToken;
  

  @override
  void initState() {
    super.initState();
    _swapService = TronSwapService.forNetwork(widget.account.network.coinParam.token.name);
    _selectedToken = _swapService.getPopularTokens().first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _executeSwap() async {
    if (_quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get a quote first!')),
      );
      return;
    }

    // Execute REAL swap - broadcasts to blockchain!
    try {
      final params = TronSwapParams(
        tokenIn: TronAddress('T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb'),
        tokenOut: _selectedToken!.address,
        amountIn: _quote!.amountIn,
        slippage: TronSwapConstants.defaultSlippage,
        recipient: widget.account.addresses.first.networkAddress,
        deadline: TronSwapConstants.deadline,
      );

      // 1. Create transaction controller
      final controller = TronSwapTransactionController(
        walletProvider: context.wallet,
        account: widget.account,
        address: widget.account.addresses.first,
        params: params,
        quote: _quote!,
        routerAddress: _swapService.routerAddress,
      );

      // 2. Show confirmation dialog
      final confirmed = await _showConfirmationDialog(controller);
      if (!confirmed || !mounted) return;

      // 3. Navigate to transaction page (handles building, signing, broadcasting)
      // This follows the same pattern as other Tron transactions in your app
      context.to(PageRouter.transaction, argruments: controller);

      // Note: The transaction page will handle the rest and return when complete
      // You may want to listen for the result if the transaction page returns it
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = TronSwapStatus.error;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap failed: $e')),
        );
      }
    }
  }

  /// Confirmation dialog before executing swap
  Future<bool> _showConfirmationDialog(TronSwapTransactionController controller) async {
    // Estimate fees
    try {
      await controller.estimateFee();
    } catch (e) {
      // Fee estimation failed, continue anyway
    }

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Swap'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow('From', 'TRX'),
            _buildConfirmRow('Amount In', '${_quote!.amountIn ~/ BigInt.from(1000000)} TRX'),
            const SizedBox(height: 8),
            _buildConfirmRow('To', _selectedToken!.symbol),
            _buildConfirmRow('Min Amount Out', '${_quote!.minimumAmountOut} ${_selectedToken!.symbol}'),
            const Divider(height: 24),
            _buildConfirmRow('Price Impact', '${_quote!.priceImpact.toStringAsFixed(2)}%'),
            _buildConfirmRow('Slippage', '${_quote!.slippage.toStringAsFixed(1)}%'),
            _buildConfirmRow('Network Fee', '~${controller.txFee.fee.toString()} TRX'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will execute a REAL swap on ${widget.account.network.coinParam.token.name}',
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Swap'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _getQuote() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Invalid amount';
      });
      return;
    }

    setState(() {
      _status = TronSwapStatus.fetching;
      _error = null;
    });

    try {
      final amountInSun = BigInt.from((amount * 1000000).toInt());

      final params = TronSwapParams(
        tokenIn: TronAddress('T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb'),
        tokenOut: _selectedToken!.address,
        amountIn: amountInSun,
        slippage: TronSwapConstants.defaultSlippage,
        recipient: widget.account.addresses.first.networkAddress,
        deadline: TronSwapConstants.deadline,
      );

      final quote = await _swapService.getQuote(params);

      setState(() {
        _quote = quote;
        _status = TronSwapStatus.ready;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = TronSwapStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swap Tokens')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Swap TRX to Stablecoins', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Powered by SunSwap V2', style: context.textTheme.bodySmall),
            const SizedBox(height: 20),
            
            Text('Amount (TRX)', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                border: const OutlineInputBorder(),
                suffixIcon: TextButton(
                  onPressed: () => _amountController.text = '100',
                  child: const Text('MAX'),
                ),
              ),
              onChanged: (_) {
                setState(() {
                  _quote = null;
                  _status = TronSwapStatus.idle;
                });
              },
            ),
            const SizedBox(height: 20),
            
            Text('To Token', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<TronSwapToken>(
              value: _selectedToken,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _swapService.getPopularTokens().map((token) {
                return DropdownMenuItem(
                  value: token,
                  child: Text('${token.symbol} (${token.name})'),
                );
              }).toList(),
              onChanged: (token) {
                setState(() {
                  _selectedToken = token;
                  _quote = null;
                });
              },
            ),
            const SizedBox(height: 20),
            
            if (_status != TronSwapStatus.ready)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _status == TronSwapStatus.fetching ? null : _getQuote,
                  child: Text(_status == TronSwapStatus.fetching ? 'Fetching...' : 'Get Quote'),
                ),
              ),
            
            if (_quote != null && _status == TronSwapStatus.ready) ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildRow('You Send', '${(_quote!.amountIn.toDouble() / 1000000).toStringAsFixed(2)} TRX'),
                    _buildRow('You Receive', '${(_quote!.amountOut.toDouble() / 1000000).toStringAsFixed(2)} ${_selectedToken!.symbol}'),
                    _buildRow('Min Received', '${(_quote!.minimumAmountOut.toDouble() / 1000000).toStringAsFixed(2)} ${_selectedToken!.symbol}'),
                    _buildRow('Rate', '1 TRX ≈ ${_quote!.rate} ${_selectedToken!.symbol}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _status == TronSwapStatus.swapping ? null : _executeSwap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_status == TronSwapStatus.swapping ? 'Preparing Swap...' : 'Execute Swap 🚀'),
                ),
              ),
            ],
            
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                color: Colors.red.withOpacity(0.1),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 8),
                      Text('SunSwap Integration', style: context.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Using SunSwap V2 DEX\n'
                    '• ${widget.account.network.coinParam.token.name} Network\n'
                    '• Real swaps on blockchain\n'
                    '• Verify on TronScan',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
