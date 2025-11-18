import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:stealth_stash/future/state_managment/extension/extension.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/swap/tron/tron_swap.dart';
import 'package:url_launcher/url_launcher.dart';
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
        await _showStunningSwapDialog(txData);
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

  Future<void> _showStunningSwapDialog(Map<String, dynamic> txData) async {
    // DEMO MODE: Transaction is built but not broadcasted yet
    // For full swap execution, needs integration with wallet's TransactionController
    // to sign and broadcast the transaction
    
    const demoTxHash = 'DEMO_MODE_TX_NOT_BROADCASTED_YET';
    final isTestnet = widget.account.network.coinParam.token.name.toLowerCase().contains('nile');
    
    // This URL won't work because tx doesn't exist yet
    // Once integrated with signing/broadcast, this will show real transaction
    final scanUrl = isTestnet 
        ? 'https://nile.tronscan.org/#/transaction/$demoTxHash'
        : 'https://tronscan.org/#/transaction/$demoTxHash';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SwapSuccessDialog(
        txData: txData,
        txHash: demoTxHash,
        scanUrl: scanUrl,
        quote: _quote!,
        tokenSymbol: _selectedToken!.symbol,
        isDemoMode: true,
      ),
    );
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

// Stunning animated swap success dialog
class _SwapSuccessDialog extends StatefulWidget {
  final Map<String, dynamic> txData;
  final String txHash;
  final String scanUrl;
  final TronSwapQuote quote;
  final String tokenSymbol;
  final bool isDemoMode;

  const _SwapSuccessDialog({
    required this.txData,
    required this.txHash,
    required this.scanUrl,
    required this.quote,
    required this.tokenSymbol,
    this.isDemoMode = false,
  });

  @override
  State<_SwapSuccessDialog> createState() => _SwapSuccessDialogState();
}

class _SwapSuccessDialogState extends State<_SwapSuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    _controller.forward();
    _animateSteps();
  }

  void _animateSteps() async {
    for (int i = 0; i <= 3; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _currentStep = i);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with animated success icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.teal.shade400],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Transform.rotate(
                              angle: value * 2 * 3.14159,
                              child: const Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Swap Transaction Ready! 🚀',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Transaction steps with animation (scrollable)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      _buildAnimatedStep(0, Icons.sync_alt, 'Building Swap', 'Parameters configured'),
                      _buildAnimatedStep(1, Icons.route, 'Route Found', 'TRX → ${widget.tokenSymbol}'),
                      _buildAnimatedStep(2, Icons.calculate, 'Amount Calculated', '${widget.quote.amountOut} ${widget.tokenSymbol}'),
                      _buildAnimatedStep(3, Icons.done_all, 'Ready to Sign', 'Transaction prepared'),
                      
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),

                      // Demo mode notice
                      if (widget.isDemoMode)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🎯 Demo Mode Active',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Transaction parameters built & ready! To execute real swap: integrate with wallet signing system.',
                                      style: TextStyle(
                                        color: Colors.orange.shade200,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (widget.isDemoMode) const SizedBox(height: 16),

                      // Transaction hash with copy (only for real transactions)
                      if (!widget.isDemoMode)
                        _buildCopyableField(
                          'Transaction Hash',
                          widget.txHash,
                          Icons.tag,
                        ),
                      
                      if (!widget.isDemoMode) const SizedBox(height: 12),

                      // Router address with copy
                      _buildCopyableField(
                        'Router Contract',
                        widget.txData['router'].toString(),
                        Icons.account_balance,
                      ),

                      const SizedBox(height: 20),

                      // View on TronScan button with gradient
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.purple.shade600],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final uri = Uri.parse(widget.scanUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Cannot open URL: ${widget.scanUrl}'),
                                      action: SnackBarAction(
                                        label: 'Copy',
                                        onPressed: () => _copyToClipboard(widget.scanUrl, 'TronScan URL'),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.open_in_new, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    'View on TronScan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Close', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStep(int index, IconData icon, String title, String subtitle) {
    final isActive = _currentStep >= index;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.3 + (value * 0.7),
          child: Transform.translate(
            offset: Offset((1 - value) * 20, 0),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? Colors.green.withOpacity(0.3) : Colors.white10,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    const Icon(Icons.check, color: Colors.green, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCopyableField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${value.substring(0, 20)}...${value.substring(value.length - 10)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => _copyToClipboard(value, label),
                color: Colors.blue.shade300,
                tooltip: 'Copy',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
