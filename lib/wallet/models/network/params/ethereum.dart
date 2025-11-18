import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/error/exception/wallet_ex.dart';
import 'package:stealth_stash/app/serialization/serialization.dart';
import 'package:stealth_stash/crypto/utils/ethereum/utils.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/constant/tags/constant.dart';
import 'package:stealth_stash/wallet/models/network/core/params/params.dart';
import 'package:stealth_stash/wallet/models/token/token/token.dart';

class EthereumNetworkParams extends NetworkCoinParams {
  final BigInt chainId;
  final bool supportEIP1559;
  final bool defaultNetwork;

  @override
  bool get isTestNet => defaultNetwork && !mainnet;
  EthereumNetworkParams._(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required this.chainId,
      required this.supportEIP1559,
      required super.chainType,
      super.bip32CoinType,
      this.defaultNetwork = true});
  factory EthereumNetworkParams(
      {String? transactionExplorer,
      String? addressExplorer,
      required Token token,
      required BigInt chainId,
      required bool supportEIP1559,
      required ChainType chainType,
      bool defaultNetwork = true,
      int? bip32CoinType}) {
    if (chainId.isNegative || token.decimal != EthereumUtils.decimal) {
      throw const WalletException.error("invalid_network_information");
    }
    return EthereumNetworkParams._(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        chainId: chainId,
        supportEIP1559: supportEIP1559,
        chainType: chainType,
        bip32CoinType: bip32CoinType,
        defaultNetwork: defaultNetwork);
  }
  EthereumNetworkParams copyWith(
      {String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      BigInt? chainId,
      bool? supportEIP1559,
      ChainType? chainType,
      bool? defaultNetwork,
      int? bip32CoinType}) {
    return EthereumNetworkParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        chainId: chainId ?? this.chainId,
        supportEIP1559: supportEIP1559 ?? this.supportEIP1559,
        chainType: chainType ?? this.chainType,
        defaultNetwork: defaultNetwork ?? this.defaultNetwork,
        bip32CoinType: bip32CoinType ?? this.bip32CoinType);
  }

  factory EthereumNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.evmNetworkParam);
    final bool? defaultNetwork = cbor.elementAs(7);
    return EthereumNetworkParams(
      chainId: cbor.elementAs(0),
      supportEIP1559: cbor.elementAs(1),
      chainType: ChainType.fromValue(cbor.elementAs(2)),
      token: Token.deserialize(obj: cbor.elementAsCborTag(5)),
      defaultNetwork: defaultNetwork ?? true,
      bip32CoinType: cbor.elementAs(8),
      transactionExplorer: cbor.elementAs(9),
      addressExplorer: cbor.elementAs(10),
    );
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          chainId,
          supportEIP1559,
          chainType.name,
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborNullValue(),
          defaultNetwork,
          bip32CoinType,
          transactionExplorer,
          addressExplorer,
        ]),
        CborTagsConst.evmNetworkParam);
  }

  BigInt get identifier => chainId;

  @override
  EthereumNetworkParams updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return EthereumNetworkParams(
      transactionExplorer: transactionExplorer,
      addressExplorer: addressExplorer,
      token: NetworkCoinParams.validateUpdateParams(
          token: this.token, updateToken: token),
      chainId: chainId,
      supportEIP1559: supportEIP1559,
      chainType: chainType,
      defaultNetwork: defaultNetwork,
      bip32CoinType: bip32CoinType,
    );
  }
}
