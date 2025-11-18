import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/error/exception/app_exception.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

enum AptosChainType {
  devnet(null),
  testnet(2),
  mainnet(1);

  const AptosChainType(this.id);
  final int? id;
  bool get isDevnet => this == devnet;
  String get identifier => "aptos:$name";
  static AptosChainType fromValue(int? value) {
    if (value == null || value > 170) return AptosChainType.devnet;
    return values.firstWhere(
      (e) => e.id == value,
      orElse: () =>
          throw AppSerializationException(objectName: "AptosChainType"),
    );
  }
}

class AptosNetworkParams extends NetworkCoinParams {
  final AptosChainType aptosChainType;

  factory AptosNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.aptosNetworkParams);

    return AptosNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(0)),
        aptosChainType: AptosChainType.fromValue(values.elementAs(2)),
        chainType: ChainType.fromValue(values.elementAs(3)),
        addressExplorer: values.elementAs(4),
        transactionExplorer: values.elementAs(5),
        bip32CoinType: values.elementAs(6));
  }
  AptosNetworkParams(
      {required super.token,
      required super.chainType,
      required this.aptosChainType,
      super.addressExplorer,
      super.transactionExplorer,
      super.bip32CoinType});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          token.toCbor(),
          CborNullValue(),
          aptosChainType.id,
          chainType.name,
          addressExplorer,
          transactionExplorer,
          bip32CoinType
        ]),
        CborTagsConst.aptosNetworkParams);
  }

  @override
  NetworkCoinParams updateParams(
      {Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return AptosNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        chainType: chainType,
        aptosChainType: aptosChainType,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer,
        bip32CoinType: bip32CoinType ?? this.bip32CoinType);
  }
}
