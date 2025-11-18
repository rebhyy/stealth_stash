import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/core.dart';

import 'package:stealth_stash/wallet/models/contact/core/contract_core.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateContact extends ContactCore<BaseSubstrateAddress> {
  SubstrateContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory SubstrateContact.newContact(
      {required BaseSubstrateAddress address, required String name}) {
    return SubstrateContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory SubstrateContact.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.substrateContact);
    final String address = cbor.elementAs(0);
    final DateTime created = cbor.elementAs(1);
    final String name = cbor.elementAs(2);
    final BaseSubstrateAddress cardanoAddr = BaseSubstrateAddress(address);
    return SubstrateContact._(
        addressObject: cardanoAddr, created: created, name: name);
  }

  @override
  String get address => addressObject.address;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic(
            [address, CborEpochIntValue(created), name]),
        CborTagsConst.substrateContact);
  }

  @override
  final String? type = null;
}
