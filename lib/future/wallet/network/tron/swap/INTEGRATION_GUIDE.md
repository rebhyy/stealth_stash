# Tron Swap Integration Guide - Complete Plan for Real Transaction Hash

## Current Status ✅

**What's Working:**
- ✅ Quote fetching from SunSwap
- ✅ Parameter validation & building  
- ✅ Beautiful animated UI
- ✅ Transaction data preparation
- ✅ Demo mode with clear indicators

**What's Missing:**
- ❌ Transaction signing integration
- ❌ Blockchain broadcast
- ❌ Real transaction hash
- ❌ Confirmation dialogs

---

## Implementation Plan

### Phase 1: Add SunSwap ABI ✅ (DONE)

**File:** `lib/crypto/utils/solidity/solidity.dart`

Add SunSwap router ABI fragment:

```dart
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
```

**Status:** ✅ Created in `tron_swap_transaction_controller.dart`

---

### Phase 2: Create Transaction Controller ✅ (DONE)

**File:** `lib/future/wallet/network/tron/swap/tron_swap_transaction_controller.dart`

Created `TronSwapTransactionController` extending `BaseTronTransactionController<TriggerSmartContract>`.

**Key Methods:**
- `buildTransactionData()` - Builds TriggerSmartContract with encoded swap call
- `buildWalletTransaction()` - Creates transaction history record

---

### Phase 3: Update Swap Page to Use Controller (TODO)

**File:** `lib/future/wallet/network/tron/swap/tron_swap_page.dart`

**Current Flow:**
```dart
_executeSwap() {
  // Builds parameters but doesn't broadcast
  final txData = await _swapService.buildSwapTransaction(...);
  _showStunningSwapDialog(txData);
}
```

**New Flow:**
```dart
_executeSwap() async {
  // 1. Create controller
  final controller = TronSwapTransactionController(
    walletProvider: walletProvider,
    account: widget.account,
    address: widget.account.addresses.first,
    network: widget.account.network,
    apiProvider: apiProvider,
    params: params,
    quote: _quote!,
    routerAddress: _swapService.routerAddress,
  );

  // 2. Show confirmation dialog with fee estimate
  final confirmed = await _showConfirmationDialog(controller);
  if (!confirmed) return;

  // 3. Build transaction
  setState(() => _status = TronSwapStatus.building);
  final transaction = await controller.buildTransaction();

  // 4. Show signing dialog (if multi-sig or requires password)
  setState(() => _status = TronSwapStatus.signing);
  final signedTx = await controller.signTransaction(transaction);

  // 5. Broadcast to network
  setState(() => _status = TronSwapStatus.broadcasting);
  final result = await controller.sendTransaction(signedTx);

  // 6. Get REAL transaction hash
  final txHash = result.txId;

  // 7. Show success dialog with real tx hash
  setState(() => _status = TronSwapStatus.success);
  await _showStunningSwapDialog(
    txHash: txHash, // REAL hash from blockchain!
    isDemoMode: false, // Turn off demo mode
  );
}
```

---

### Phase 4: Add Confirmation Dialog (TODO)

**New Method:** `_showConfirmationDialog()`

```dart
Future<bool> _showConfirmationDialog(
  TronSwapTransactionController controller,
) async {
  // Estimate fees
  await controller.estimateFee();
  
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Swap'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildConfirmRow('From', 'TRX'),
          _buildConfirmRow('Amount In', '${_quote!.amountIn} SUN'),
          _buildConfirmRow('To', _selectedToken!.symbol),
          _buildConfirmRow('Amount Out (Min)', '${_quote!.minimumAmountOut} SUN'),
          const Divider(),
          _buildConfirmRow('Network Fee', '~${controller.txFee.fee} TRX'),
          _buildConfirmRow('Price Impact', '${_quote!.priceImpact}%'),
          _buildConfirmRow('Slippage', '${_quote!.slippage}%'),
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
```

---

### Phase 5: Integrate with Wallet Provider (TODO)

**Required Integration Points:**

1. **WalletProvider Access**
   ```dart
   // Get from your existing wallet context/provider
   final walletProvider = context.watch<WalletProvider>();
   ```

2. **API Provider Access**
   ```dart
   // Get Tron API client
   final apiProvider = widget.account.client; // or however you access it
   ```

3. **Account Access**
   ```dart
   // Already available as widget.account
   ```

---

### Phase 6: Handle Transaction States (TODO)

Add proper status management:

```dart
enum TronSwapStatus {
  idle,
  fetching,    // Fetching quote
  ready,       // Quote ready, can execute
  building,    // Building transaction
  signing,     // Waiting for signature
  broadcasting,// Broadcasting to network
  confirming,  // Waiting for confirmation
  success,     // Transaction successful
  error,       // Error occurred
}
```

---

### Phase 7: Error Handling (TODO)

Add comprehensive error handling:

```dart
try {
  final result = await controller.sendTransaction(signedTx);
  // Success!
} on TronException catch (e) {
  // Handle Tron-specific errors
  if (e.message.contains('insufficient')) {
    _showError('Insufficient balance for swap + fees');
  } else if (e.message.contains('slippage')) {
    _showError('Price moved too much. Try increasing slippage.');
  } else {
    _showError('Swap failed: ${e.message}');
  }
} catch (e) {
  _showError('Unexpected error: $e');
}
```

---

### Phase 8: Update Success Dialog (TODO)

**File:** `lib/future/wallet/network/tron/swap/tron_swap_page.dart`

Remove demo mode logic when real hash is available:

```dart
Future<void> _showStunningSwapDialog({
  required String txHash,
  bool isDemoMode = false,
}) async {
  final isTestnet = widget.account.network.coinParam.token.name
      .toLowerCase().contains('nile');
  
  final scanUrl = isTestnet 
      ? 'https://nile.tronscan.org/#/transaction/$txHash'
      : 'https://tronscan.org/#/transaction/$txHash';

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _SwapSuccessDialog(
      txData: {...}, // Transaction data
      txHash: txHash, // REAL hash!
      scanUrl: scanUrl, // Real TronScan link!
      quote: _quote!,
      tokenSymbol: _selectedToken!.symbol,
      isDemoMode: isDemoMode, // false for real swaps
    ),
  );
}
```

---

### Phase 9: Testing Checklist (TODO)

**Testnet Testing:**
- [ ] Connect to Tron Nile testnet
- [ ] Get testnet TRX from faucet
- [ ] Execute small swap (e.g., 1 TRX → USDT)
- [ ] Verify transaction appears on TronScan
- [ ] Check transaction history in wallet
- [ ] Test error cases (insufficient balance, etc.)

**Mainnet Testing:**
- [ ] Start with VERY small amounts
- [ ] Double-check router addresses
- [ ] Verify slippage settings
- [ ] Test on multiple tokens
- [ ] Monitor gas fees

---

## File Structure

```
lib/future/wallet/network/tron/swap/
├── tron_swap_page.dart                    # UI (needs update)
├── tron_swap_service.dart                  # Quote fetching (keep as is)
├── tron_swap_transaction_controller.dart   # ✅ NEW - Transaction handling
└── INTEGRATION_GUIDE.md                    # This file

lib/crypto/utils/solidity/
└── solidity.dart                           # Add SunSwap ABI here (or use controller's version)

lib/wallet/models/swap/tron/
├── tron_swap.dart                          # Models
├── tron_swap_constants.dart                # Constants
└── tron_swap_models.dart                   # Model definitions
```

---

## Quick Start Integration

### Minimal Changes to Get Real TX Hash:

1. **Import controller:**
   ```dart
   import 'tron_swap_transaction_controller.dart';
   ```

2. **Replace `_executeSwap()` in `tron_swap_page.dart`:**
   ```dart
   Future<void> _executeSwap() async {
     try {
       // Create controller
       final controller = TronSwapTransactionController(
         walletProvider: widget.account.wallet, // Adjust based on your structure
         account: widget.account,
         address: widget.account.addresses.first,
         network: widget.account.network,
         apiProvider: widget.account.client, // Your Tron API client
         params: TronSwapParams(
           tokenIn: TronAddress('T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb'),
           tokenOut: _selectedToken!.address,
           amountIn: _quote!.amountIn,
           slippage: TronSwapConstants.defaultSlippage,
           recipient: widget.account.addresses.first.networkAddress,
           deadline: TronSwapConstants.deadline,
         ),
         quote: _quote!,
         routerAddress: _swapService.routerAddress,
       );

       // Build, sign, and broadcast
       final transaction = await controller.buildTransaction();
       final signedTx = await controller.signTransaction(transaction);
       final result = await controller.sendTransaction(signedTx);

       // Show success with REAL tx hash!
       if (mounted) {
         await _showStunningSwapDialog(
           txHash: result.txId,
           isDemoMode: false, // Real transaction!
         );
       }

       setState(() => _status = TronSwapStatus.success);
     } catch (e) {
       setState(() {
         _error = e.toString();
         _status = TronSwapStatus.error;
       });
     }
   }
   ```

3. **Test on testnet first!**

---

## Expected Behavior After Integration

### Before (Demo Mode):
1. User clicks "Execute Swap"
2. Shows dialog with "Demo Mode Active" banner
3. TronScan button shows fake transaction
4. No blockchain interaction

### After (Real Mode):
1. User clicks "Execute Swap"
2. Shows confirmation dialog with fees
3. User confirms
4. Transaction builds → signs → broadcasts
5. Shows success dialog with **REAL tx hash**
6. TronScan button opens **ACTUAL transaction**
7. Swap is **REAL** on blockchain! 🚀

---

## Need Help?

**Common Issues:**

1. **"walletProvider not found"**
   - Check how your app accesses the wallet
   - Look at existing transaction pages (e.g., TRC20 transfer)
   - Copy the pattern they use

2. **"apiProvider not found"**
   - Find how other transaction pages get the Tron client
   - Usually something like `widget.account.client` or `context.read<TronClient>()`

3. **"Permission errors during signing"**
   - May need to show password dialog first
   - Check how other transactions handle multi-sig accounts

4. **"Transaction fails on testnet"**
   - Verify you have enough TRX for fees
   - Check router address is correct for testnet (Nile/Shasta)
   - Enable energy/bandwidth if needed

---

## Summary

✅ **Foundation Complete:**
- Quote system works
- UI is stunning
- Parameters build correctly
- Transaction controller ready

🔨 **Next Steps:**
1. Update `_executeSwap()` to use controller
2. Add confirmation dialog
3. Test on testnet
4. Deploy to mainnet

**Estimated Time:** 2-4 hours for a developer familiar with the codebase.

The hard part is DONE! Just need to wire up the controller to your existing wallet infrastructure. 🎉
