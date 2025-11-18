import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/error/exception/app_exception.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

enum RippleKeyScheme {
  ed25519(value: 0, name: "ED25519"),
  secp256k1(value: 1, name: "Secp256k1");

  final int value;
  final String name;

  const RippleKeyScheme({required this.value, required this.name});
  static RippleKeyScheme fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () =>
            throw AppSerializationException(objectName: "RippleKeyScheme"));
  }

  EllipticCurveTypes get curve {
    return switch (this) {
      RippleKeyScheme.secp256k1 => EllipticCurveTypes.secp256k1,
      _ => EllipticCurveTypes.ed25519
    };
  }
}

class RippleNetworkParams extends NetworkCoinParams {
  final int networkId;

  factory RippleNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.xrpNetworkParam);
    return RippleNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(2)),
        chainType: ChainType.fromValue(values.elementAs(4)),
        networkId: values.elementAs(5),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  RippleNetworkParams(
      {required super.token,
      required super.chainType,
      required this.networkId,
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
          networkId,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.xrpNetworkParam);
  }

  int get identifier => networkId;

  @override
  NetworkCoinParams updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return RippleNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        chainType: chainType,
        networkId: networkId,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
