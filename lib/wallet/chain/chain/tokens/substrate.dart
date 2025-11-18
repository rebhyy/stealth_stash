part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

class _SubstrateTokenUtils {
  static String generateIdentifier(Object assetIdentifier) {
    if (assetIdentifier is XCMVersionedLocation) {
      return TokenCore.toIdentifier(assetIdentifier.toHex());
    }
    return TokenCore.toIdentifier(assetIdentifier.toString());
  }
}

class SubstrateToken extends TokenCore<IntegerBalance, Token> {
  final Object assetIdentifier;
  // final XCMVersionedLocation? location;
  @override
  final String identifier;

  SubstrateToken._({
    required super.balance,
    required super.token,
    required this.assetIdentifier,
    required super.updated,
    required this.identifier,
  }) : super._();
  factory SubstrateToken.create({
    required BigInt balance,
    required Token token,
    required Object assetIdentifier,
  }) {
    return SubstrateToken._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        assetIdentifier: assetIdentifier,
        updated: DateTime.now(),
        identifier: _SubstrateTokenUtils.generateIdentifier(assetIdentifier));
  }
  factory SubstrateToken.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.substrate.tag);
    final Token token = Token.deserialize(obj: values.elementAsCborTag(0));
    final IntegerBalance balance =
        IntegerBalance.token(values.valueAs(1), token, immutable: true);
    final DateTime updated = values.valueAs(2);
    Object? assetIentifier = values.indexAs<CborObject?>(3)?.getValue();
    final String identifier = values.valueAs(4);
    if (assetIentifier == null) {
      final List<int>? location = values.valueAs(5);
      if (location == null) {
        throw WalletExceptionConst.invalidTokenInformation;
      }
      assetIentifier = XCMVersionedLocation.deserialize(location);
    }
    return SubstrateToken._(
        balance: balance,
        token: token,
        updated: updated,
        assetIdentifier: assetIentifier,
        identifier: identifier);
  }
  @override
  SubstrateToken clone() {
    return SubstrateToken._(
        balance: IntegerBalance.token(balance.balance, token, immutable: true),
        token: token,
        assetIdentifier: assetIdentifier,
        identifier: identifier,
        updated: updated);
  }

  @override
  SubstrateToken updateToken(Token updateToken) {
    return SubstrateToken._(
        balance: balance,
        token: updateToken,
        assetIdentifier: assetIdentifier,
        updated: updated,
        identifier: identifier);
  }

  bool _updateBalance([BigInt? updateBalance]) {
    if (streamBalance.value._internalUpdateBalance(updateBalance)) {
      _updated = DateTime.now().toLocal();
      streamBalance.notify();
      return true;
    }
    return false;
  }

  @override
  CborTagValue toCbor() {
    final assetIdentifier = this.assetIdentifier;
    return CborTagValue(
        CborSerializable.fromDynamic([
          token.toCbor(),
          streamBalance.value.balance,
          CborEpochIntValue(_updated),
          switch (assetIdentifier) {
            final XCMVersionedLocation _ => CborNullValue(),
            _ => assetIdentifier
          },
          identifier,
          switch (assetIdentifier) {
            final XCMVersionedLocation location =>
              CborBytesValue(location.serializeVariant()),
            _ => CborNullValue()
          },
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [assetIdentifier];

  @override
  String? get type => null;

  @override
  TokenCoreType get tokenType => TokenCoreType.substrate;

  @override
  String? get issuer => null;
}
