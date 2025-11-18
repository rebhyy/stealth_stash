import 'package:flutter/material.dart';
import 'package:on_chain/tron/tron.dart';
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

  Future<void> _executeSwap() async {
    if (_quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get a quote first!')),
      );
      return;
    }

    setState(() {
      _status = TronSwapStatus.swapping;
    });

    try {
      final params = TronSwapParams(
        tokenIn: TronAddress('T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb'),
        tokenOut: _selectedToken!.address,
        amountIn: _quote!.amountIn,
        slippage: TronSwapConstants.defaultSlippage,
        recipient: widget.account.addresses.first.networkAddress,
        deadline: TronSwapConstants.deadline,
      );

      final txData = await _swapService.buildSwapTransaction(
        params: params,
        quote: _quote!,
      );

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Swap Transaction Ready! 🚀'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Transaction Parameters:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTxDetail('Router', txData['router']!.toString().substring(0, 20) + '...'),
                  _buildTxDetail('Amount In', '${txData['amountIn']} SUN'),
                  _buildTxDetail('Min Out', '${txData['amountOutMin']} SUN'),
                  const SizedBox(height: 8),
                  const Text('Path:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...(txData['path'] as List).map((p) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('→ ${p.toString().substring(0, 10)}...'),
                  )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✅ Swap configured!\n\n'
                      'Transaction will call SunSwap router:\n'
                      'swapExactTokensForTokens()\n\n'
                      'Ready for signing & broadcast!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ],
          ),
        );
      }

      setState(() {
        _status = TronSwapStatus.success;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = TronSwapStatus.error;
      });
    }
  }

  Widget _buildTxDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
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
                  child: Text(_status == TronSwapStatus.swapping ? 'Building Transaction...' : 'Execute Swap 🚀'),
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
                      Text('Testnet Swap', style: context.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Using SunSwap V2 DEX\n'
                    '• ${widget.account.network.coinParam.token.name} Network\n'
                    '• Transaction builder ready\n'
                    '• Click Execute to test!',
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
