import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

class CardanoNetworkParams extends NetworkCoinParams {
  final ADANetwork networkType;
  String get chainId {
    return "${networkType.value}-${networkType.protocolMagic}";
  }

  factory CardanoNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.cardanoNetworkParams);

    return CardanoNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(2)),
        chainType: ChainType.fromValue(values.elementAs(4)),
        networkType: ADANetwork.fromProtocolMagic(values.elementAs(5)),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  CardanoNetworkParams(
      {required super.token,
      required super.chainType,
      required this.networkType,
      super.addressExplorer,
      super.transactionExplorer});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborNullValue(),
          chainType.name,
          networkType.protocolMagic,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.cardanoNetworkParams);
  }

  int get identifier => networkType.protocolMagic;

  @override
  NetworkCoinParams updateParams(
      {Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return CardanoNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        chainType: chainType,
        networkType: networkType,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
