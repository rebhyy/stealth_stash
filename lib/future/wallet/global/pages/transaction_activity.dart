import 'package:flutter/material.dart';
import 'package:stealth_stash/future/future.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/pages/types.dart';
import 'package:stealth_stash/wallet/wallet.dart';

class AccountTransactionActivityView<CHAINACCOUNT extends ChainAccount,
    TRANSACTION extends ChainTransaction> extends StatefulWidget {
  final APPCHAINACCOUNTTX<CHAINACCOUNT, TRANSACTION> account;
  final CHAINACCOUNT address;
  const AccountTransactionActivityView(
      {required this.account, required this.address, super.key});

  @override
  State<AccountTransactionActivityView> createState() =>
      _AccountTransactionActivityViewState<ChainAccount, TRANSACTION>();
}

class _AccountTransactionActivityViewState<CHAINACCOUNT extends ChainAccount,
        TRANSACTION extends ChainTransaction>
    extends State<AccountTransactionActivityView<CHAINACCOUNT, TRANSACTION>>
    with SafeState<AccountTransactionActivityView<CHAINACCOUNT, TRANSACTION>> {
  APPCHAINACCOUNTTX<CHAINACCOUNT, TRANSACTION> get account => widget.account;
  @override
  Widget build(BuildContext context) {
    return ChainStreamBuilder(
        allowNotify: [DefaultChainNotify.transaction],
        builder: (context, chain, lastNotify) {
          final transaction = account.address.transactions.cast<TRANSACTION>();
          return AccountTabbarScrollWidget(slivers: [
            EmptyItemSliverWidgetView(
              isEmpty: transaction.isEmpty,
              itemBuilder: (context) {
                return SliverList.separated(
                    itemBuilder: (context, index) {
                      return TransactionView<CHAINACCOUNT, TRANSACTION>(
                        transaction: transaction[index],
                        account: account,
                        address: widget.address,
                      );
                    },
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemCount: transaction.length);
              },
            )
          ]);
        },
        account: account);
  }
}
