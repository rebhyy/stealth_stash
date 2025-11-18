import 'package:on_chain/ada/src/models/metadata/metadata.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/network/cardano/transaction/types/types.dart';
import 'package:stealth_stash/future/wallet/transaction/fields/fields.dart';

mixin ADATransactionMemoController on BaseADATransactionController {
  final LiveFormFields<ADATransactionMemo> memos =
      LiveFormFields(title: "setup_memo".tr, subtitle: "memo_desc2".tr);

  bool onUpdateMemo(ADATransactionMemo? memo) {
    if (memo == null || memos.value.any((e) => e.tag == memo.tag)) {
      return false;
    }
    memos.addValue(memo);
    return true;
  }

  void onRemoveMemo(ADATransactionMemo memo) {
    memos.removeValue(memo);
  }

  GeneralTransactionMetadata? buildTransactionMemo() {
    final memos = this.memos.value;
    if (memos.isEmpty) return null;
    return GeneralTransactionMetadata(metadata: {
      for (final i in memos) i.tag: TransactionMetadataText(value: i.text)
    });
  }

  @override
  void dispose() {
    super.dispose();
    memos.clear();
    memos.dispose();
  }
}
