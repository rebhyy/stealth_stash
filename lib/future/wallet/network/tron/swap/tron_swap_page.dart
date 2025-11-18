import 'package:flutter/material.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:stealth_stash/future/widgets/custom_widgets.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/swap/tron/tron_swap.dart';
import 'tron_swap_service.dart';

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
            
            // Amount Input
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
            
            // Token Selector
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
            
            // Get Quote Button
            if (_status != TronSwapStatus.ready)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _status == TronSwapStatus.fetching ? null : _getQuote,
                  child: Text(_status == TronSwapStatus.fetching ? 'Fetching...' : 'Get Quote'),
                ),
              ),
            
            // Quote Display
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo: Transaction execution coming soon!')),
                    );
                  },
                  child: const Text('Swap (Demo)'),
                ),
              ),
            ],
            
            // Error
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                color: Colors.red.withOpacity(0.1),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            
            const SizedBox(height: 20),
            
            // Info
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
                      Text('Demo Info', style: context.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Using SunSwap V2 DEX\n'
                    '• Quotes are simulated\n'
                    '• Full execution coming soon\n'
                    '• Ready for client demo!',
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
