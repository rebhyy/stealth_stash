part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

enum MoneroChainStatus {
  none(value: 0, height: 0),
  outputReceived(value: 1, height: 70);

  const MoneroChainStatus({required this.value, required this.height});
  final int value;
  final double height;
  static MoneroChainStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () =>
            throw AppSerializationException(objectName: "MoneroChainStatus"));
  }
}

enum MoneroChainNotify implements ChainNotify {
  trackerUpdated(0);

  @override
  final int value;
  const MoneroChainNotify(this.value);
}

class MoneroSyncChain with CborSerializable, Equality {
  final int value;
  final ChainType? chain;
  const MoneroSyncChain._(this.value, this.chain);
  static const MoneroSyncChain none = MoneroSyncChain._(0, null);
  static const MoneroSyncChain mainnet =
      MoneroSyncChain._(1, ChainType.mainnet);
  static const MoneroSyncChain testnet =
      MoneroSyncChain._(2, ChainType.testnet);

  factory MoneroSyncChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.moneroSyncChain);
    final int value = values.elementAs(0);
    return switch (value) {
      0 => MoneroSyncChain.none,
      1 => MoneroSyncChain.mainnet,
      2 => MoneroSyncChain.testnet,
      _ => throw AppSerializationException(objectName: "MoneroSyncChain")
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([value]), CborTagsConst.moneroSyncChain);
  }

  @override
  List get variabels => [value];
}

class MoneroNetworkStorageId extends DefaultNetworkStorageId {
  static const MoneroNetworkStorageId defaultTracker =
      MoneroNetworkStorageId(11);
  static const MoneroNetworkStorageId walletRPC = MoneroNetworkStorageId(13);
  static const MoneroNetworkStorageId addressUtxos = MoneroNetworkStorageId(14);
  // static const MoneroNetworkStorageId syncChain =
  //     MoneroNetworkStorageId(101, isSharedStorage: true);
  const MoneroNetworkStorageId(super.storageId);
  static const List<DefaultNetworkStorageId> values = [
    ...DefaultNetworkStorageId.values,
    defaultTracker,
    walletRPC,
    addressUtxos,
    // syncChain
  ];
}

class MoneroChainStorageId extends DefaultChainStorageId {
  static const MoneroChainStorageId syncChain = MoneroChainStorageId(101);
  const MoneroChainStorageId(super.storageId);
  static const List<DefaultChainStorageId> values = [
    ...DefaultChainStorageId.values,
    syncChain
  ];
}

class MoneroNetworkConfig extends DefaultNetworkConfig<MoneroNetworkStorageId> {
  MoneroNetworkConfig(
      {MoneroChainStatus status = MoneroChainStatus.none,
      bool showInitializeAlert = true,
      super.supportToken = false,
      super.supportNft = false,
      super.supportWeb3 = true,
      super.enableProvider = true})
      : _status = status,
        _showInitializeAlert = showInitializeAlert;
  factory MoneroNetworkConfig.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.moneroChainConfig);
    return MoneroNetworkConfig(
      status: MoneroChainStatus.fromValue(values.elementAs(0)),
      showInitializeAlert: values.elementAs<bool?>(1) ?? true,
      supportToken: values.valueAs<bool?>(2) ?? true,
      supportNft: values.valueAs<bool?>(3) ?? false,
      supportWeb3: values.valueAs<bool?>(4) ?? true,
      enableProvider: values.valueAs<bool?>(5) ?? true,
    );
  }
  MoneroChainStatus _status;

  MoneroChainStatus get status => _status;

  @override
  MoneroNetworkConfig copyWith(
      {MoneroChainStatus? status,
      bool? showInitializeAlert,
      bool? supportToken,
      bool? supportNft,
      bool? supportWeb3,
      bool? enableProvider}) {
    return MoneroNetworkConfig(
        showInitializeAlert: showInitializeAlert ?? this.showInitializeAlert,
        status: status ?? this.status,
        supportToken: supportToken ?? this.supportToken,
        supportNft: supportNft ?? this.supportNft,
        supportWeb3: supportWeb3 ?? this.supportWeb3,
        enableProvider: enableProvider ?? this.enableProvider);
  }

  @override
  double get appbarHeight => _status.height;

  @override
  bool get hasAction => _status != MoneroChainStatus.none;
  bool _showInitializeAlert;
  bool get showInitializeAlert => _showInitializeAlert;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          _status.value,
          _showInitializeAlert,
          supportToken,
          supportNft,
          supportWeb3,
          enableProvider,
        ]),
        CborTagsConst.moneroChainConfig);
  }

  @override
  List<DefaultNetworkStorageId> get storageKeys =>
      MoneroNetworkStorageId.values;

  @override
  String toString() {
    return _status.name;
  }

  @override
  List get variabels => [storageKeys, hasAction, _status, showInitializeAlert];
}
