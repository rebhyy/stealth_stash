import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

class TonOutputJettonWithBalance {
  final TonJettonToken token;
  final IntegerBalance balance;
  final IntegerBalance forwardBalance;
  BigInt _queryId = BigInt.zero;
  BigInt get queryId => _queryId;
  TonOutputJettonWithBalance._(this.token, this.balance, this.forwardBalance);
  factory TonOutputJettonWithBalance(TonJettonToken token, Token native) {
    return TonOutputJettonWithBalance._(
        token, IntegerBalance.zero(token.token), IntegerBalance.zero(native));
  }

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  void updateForwardAmount(BigInt val) {
    forwardBalance.updateBalance(val);
  }

  void updateQueryId(BigInt val) {
    _queryId = val;
  }
}
