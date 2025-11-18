import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/wallet/web3/core/messages/types/message.dart';
import 'package:stealth_stash/wallet/web3/core/messages/types/message_types.dart';
import 'package:stealth_stash/wallet/web3/core/permission/models/authenticated.dart';

class Web3ChainMessage extends Web3MessageCore {
  @override
  Web3MessageTypes get type => Web3MessageTypes.chains;
  final Web3APPData authenticated;

  Web3ChainMessage({required this.authenticated});
  factory Web3ChainMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.chains.tag);

    return Web3ChainMessage(
        authenticated:
            Web3APPData.deserialize(object: values.elementAsCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([authenticated.toCbor()]), type.tag);
  }
}
