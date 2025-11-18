import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';
import 'package:ton_dart/ton_dart.dart' as ton;

class TonNetworkParams extends NetworkCoinParams {
  final int workchain;
  ton.TonChainId get chain => ton.TonChainId.fromWorkchain(workchain);
  String get tonChainIdentifier {
    switch (chain) {
      case ton.TonChainId.testnet:
        return "ton:testnet";
      case ton.TonChainId.mainnet:
        return "ton:mainnet";
      default:
        throw UnimplementedError("Invalid ton network.");
    }
  }

  TonNetworkParams(
      {required super.token,
      required this.workchain,
      required super.chainType,
      super.addressExplorer,
      super.transactionExplorer});

  factory TonNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.tonNetworkParam);
    return TonNetworkParams(
        workchain: values.elementAs(0),
        chainType: ChainType.fromValue(values.elementAs(1)),
        token: Token.deserialize(obj: values.elementAsCborTag(4)),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          workchain,
          chainType.name,
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborNullValue(),
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.tonNetworkParam);
  }

  int get identifier => workchain;

  @override
  NetworkCoinParams updateParams(
      {Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return TonNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        workchain: workchain,
        chainType: chainType,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
