import 'package:blockchain_utils/utils/equatable/equatable.dart';
import 'package:stealth_stash/wallet/chain/account.dart';
import 'package:stealth_stash/wallet/models/contact/core/contract_core.dart';

class ReceiptAddress<NETWORKADDRESS> with Equality {
  ReceiptAddress(
      {required this.view,
      this.type,
      this.contact,
      this.account,
      required this.networkAddress});
  final ContactCore<NETWORKADDRESS>? contact;
  final NETWORKCHAINACCOUNT<NETWORKADDRESS>? account;
  final NETWORKADDRESS networkAddress;
  final String view;
  final String? type;
  bool get hasContact => contact != null;
  bool get isAccount => account != null;

  @override
  List get variabels => [view];

  @override
  String toString() {
    return view;
  }
}
