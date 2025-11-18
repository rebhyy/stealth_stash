import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/api/provider/provider.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

class MoneroNetworkParams extends NetworkCoinParams {
  final MoneroNetwork network;
  final int rctHeight;

  factory MoneroNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.moneroNetworkParams);

    return MoneroNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(2)),
        // providers: values
        //     .elementAsListOf<CborObject>(3)
        //     .map((e) => MoneroAPIProvider.fromCborBytesOrObject(obj: e))
        //     .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        network: MoneroNetwork.fromName(values.elementAs(5)),
        rctHeight: values.elementAs(7),
        addressExplorer: values.elementAs(8),
        transactionExplorer: values.elementAs(9));
  }
  MoneroNetworkParams(
      {required super.token,
      required super.chainType,
      required this.network,
      required this.rctHeight,
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
          network.name,
          const CborNullValue(),
          rctHeight,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.moneroNetworkParams);
  }

  @override
  NetworkCoinParams updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return MoneroNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        chainType: chainType,
        network: network,
        rctHeight: rctHeight,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }

  @override
  int get averageBlockTime => 120;
  @override
  int get maxTxConfirmationBlock => 10;
}
