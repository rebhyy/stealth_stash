import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/equatable/equatable.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/constant/constant.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateMultisigCall with CborSerializable, Equality {
  final List<int>? callData;
  final List<int> callHash;
  final String callHashHex;
  final String? callDataHex;
  SubstrateMultisigCall({List<int>? callData, required List<int> callHash})
      : callData = callData?.asImmutableBytes,
        callHash = callHash.asImmutableBytes,
        callHashHex = BytesUtils.toHexString(callHash),
        callDataHex = BytesUtils.tryToHexString(callData);
  factory SubstrateMultisigCall.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.substrateMultisigCall);
    return SubstrateMultisigCall(
        callData: values.valueAs(0), callHash: values.valueAs(1));
  }

  @override
  CborTagValue<CborObject> toCbor() {
    return CborTagValue(
        CborListValue.definite(<CborObject>[
          callData == null ? CborNullValue() : CborBytesValue(callData!),
          CborBytesValue(callHash)
        ]),
        CborTagsConst.substrateMultisigCall);
  }

  @override
  List get variabels => [callHash];
}

class SubstrateMultisigCallData {
  final SubstrateMultisigCall call;
  final SubstrateWeightV2? weight;
  final Map<String, dynamic>? content;
  final SubstrateMultisig? multisig;
  SubstrateMultisigCallData copyWith({
    SubstrateMultisigCall? call,
    SubstrateWeightV2? weight,
    Map<String, dynamic>? content,
    SubstrateMultisig? multisig,
  }) {
    return SubstrateMultisigCallData(
        call: call ?? this.call,
        weight: weight ?? this.weight,
        content: content ?? this.content,
        multisig: multisig ?? this.multisig);
  }

  SubstrateMultisigCallData(
      {required this.call,
      this.weight,
      Map<String, dynamic>? content,
      this.multisig})
      : content = content?.immutable;
}
