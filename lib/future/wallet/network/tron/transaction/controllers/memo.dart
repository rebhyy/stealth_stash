import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/tron/transaction/types/types.dart';
import 'package:stealth_stash/future/wallet/transaction/fields/fields.dart';

mixin TronTransactionMemoController<TXDATA extends ITronTransactionData>
    on BaseTronTransactionController<TXDATA> {
  final LiveFormField<String?, String?> memo =
      LiveFormField(title: "setup_memo".tr, value: null, optional: true);
  bool onUpdateMemo(String? memo) {
    if (memo == null) return false;
    this.memo.setValue(memo);
    return true;
  }

  void onRemoveMemo() {
    memo.setValue(null);
  }

  @override
  void dispose() {
    super.dispose();
    memo.dispose();
  }
}
