import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/error/exception.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

enum SolanaNetworkType {
  mainnet(
      identifier: 'solana:mainnet',
      value: 0,
      genesis: "5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp"),
  testnet(
      identifier: 'solana:testnet',
      value: 1,
      genesis: "4uhcVJyU9pJkvQyS88uRDiswHXSCkY3z"),

  devnet(
      identifier: 'solana:devnet',
      value: 2,
      genesis: "EtWTRABZaYq6iMfeYKouRu166VU2xqa1");

  final String identifier;
  final int value;
  final String genesis;
  const SolanaNetworkType(
      {required this.identifier, required this.value, required this.genesis});
  static SolanaNetworkType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () =>
            throw AppSerializationException(objectName: "SolanaNetworkType"));
  }
}

class SolanaNetworkParams extends NetworkCoinParams {
  final int chainId;
  final SolanaNetworkType type;

  factory SolanaNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.solNetworkParam);

    return SolanaNetworkParams(
        token: Token.deserialize(obj: values.elementAsCborTag(2)),
        chainType: ChainType.fromValue(values.elementAs(4)),
        chainId: values.elementAs(6),
        type: SolanaNetworkType.fromValue(values.elementAs(7)),
        addressExplorer: values.elementAs(8),
        transactionExplorer: values.elementAs(9));
  }
  SolanaNetworkParams(
      {required super.token,
      required super.chainType,
      required this.chainId,
      required this.type,
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
          const CborNullValue(),
          chainId,
          type.value,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.solNetworkParam);
  }

  @override
  NetworkCoinParams updateParams(
      {Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return SolanaNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        chainType: chainType,
        chainId: chainId,
        type: type,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
