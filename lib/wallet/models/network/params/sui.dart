import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/error/exception.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/api/provider/provider.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

enum SuiChainType {
  devnet(0),
  testnet(1),
  mainnet(2);

  const SuiChainType(this.value);
  final int value;
  String get identifier => "sui:$name";
  static SuiChainType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw AppSerializationException(objectName: "SuiChainType"),
    );
  }
}

class SuiNetworkParams extends NetworkCoinParams {
  final String identifier;
  final SuiChainType suiChain;

  factory SuiNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.suiNetworkParams);

    return SuiNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(0)),
        chainType: ChainType.fromValue(values.elementAs(2)),
        identifier: values.elementAs(3),
        addressExplorer: values.elementAs(4),
        transactionExplorer: values.elementAs(5),
        bip32CoinType: values.elementAs(6),
        suiChain: SuiChainType.fromValue(values.elementAs(7)));
  }
  SuiNetworkParams(
      {required super.token,
      required super.chainType,
      required this.identifier,
      required this.suiChain,
      super.addressExplorer,
      super.transactionExplorer,
      super.bip32CoinType});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          token.toCbor(),
          chainType.name,
          identifier,
          addressExplorer,
          transactionExplorer,
          bip32CoinType,
          suiChain.value
        ]),
        CborTagsConst.suiNetworkParams);
  }

  @override
  NetworkCoinParams updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return SuiNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        chainType: chainType,
        identifier: identifier,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer,
        bip32CoinType: bip32CoinType ?? this.bip32CoinType,
        suiChain: suiChain);
  }
}
