import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

class TronNetworkParams extends NetworkCoinParams {
  factory TronNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.tvmNetworkParam);

    return TronNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(2)),
        chainType: ChainType.fromValue(values.elementAs(5)),
        addressExplorer: values.elementAs(7),
        transactionExplorer: values.elementAs(8));
  }
  TronNetworkParams(
      {required super.token,
      required super.chainType,
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
          const CborNullValue(),
          chainType.name,
          const CborNullValue(),
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.tvmNetworkParam);
  }

  @override
  NetworkCoinParams updateParams(
      {Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return TronNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        chainType: chainType,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
