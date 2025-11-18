part of 'package:stealth_stash/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class MoneroPublicKeyData extends CryptoPublicKeyData {
  final MoneroPublicKey spendPublicKey;
  final MoneroPublicKey viewPublicKey;
  final MoneroPrivateKey viewPrivateKey;
  @override
  final String keyName;

  @override
  PublicKeysView get toViewKey => MoneroPublicKeysView._(
      extendKey: extendedKey,
      comprossed: comprossed,
      uncomprossed: uncomprossed,
      chainCode: chainCode,
      spendPublicKey: spendPublicKey.toHex(),
      viewPublicKey: viewPublicKey.toHex(),
      keyName: keyName,
      keyType: type);

  MoneroPublicKeyData.__(
      {required super.extendedKey,
      required this.keyName,
      required this.spendPublicKey,
      required this.viewPublicKey,
      required this.viewPrivateKey,
      required super.chainCode,
      required super.comprossed})
      : super._(
            type: CryptoPublicKeyDataType.monero,
            uncomprossed: null,
            curve: EllipticCurveTypes.ed25519Monero);
  factory MoneroPublicKeyData._fromBip32(
      {required Bip32Base account, required String keyName}) {
    final moneroAccount =
        MoneroAccount.fromBip44PrivateKey(account.privateKey.raw);
    // account.curveType;
    return MoneroPublicKeyData.__(
        extendedKey: account.publicKey.toExtended,
        keyName: keyName,
        chainCode: account.chainCode.toHex(),
        spendPublicKey: moneroAccount.publicSpendKey,
        viewPrivateKey: moneroAccount.privateViewKey,
        viewPublicKey: moneroAccount.publicViewKey,
        comprossed: account.publicKey.toHex());
  }
  factory MoneroPublicKeyData._(
      {required MoneroPrivateKey privateKey, required String keyName}) {
    final moneroAccount = MoneroAccount.fromPrivateSpendKey(privateKey.key);
    return MoneroPublicKeyData.__(
        extendedKey: null,
        keyName: keyName,
        chainCode: null,
        spendPublicKey: moneroAccount.publicSpendKey,
        viewPrivateKey: moneroAccount.privateViewKey,
        viewPublicKey: moneroAccount.publicViewKey,
        comprossed: moneroAccount.publicSpendKey.toHex());
  }
  factory MoneroPublicKeyData.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessMoneroPublicKeyResponse);
    return MoneroPublicKeyData.__(
        extendedKey: values.valueAs(0),
        keyName: values.valueAs(1),
        chainCode: values.valueAs(2),
        spendPublicKey: MoneroPublicKey.fromBytes(values.valueAs(3)),
        viewPrivateKey: MoneroPrivateKey.fromBytes(values.valueAs(4)),
        viewPublicKey: MoneroPublicKey.fromBytes(values.valueAs(5)),
        comprossed: values.valueAs(6));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          extendedKey,
          keyName,
          chainCode,
          CborBytesValue(spendPublicKey.key),
          CborBytesValue(viewPrivateKey.key),
          CborBytesValue(viewPublicKey.key),
          comprossed
        ]),
        type.tag);
  }

  @override
  CryptoPublicKeyDataType get type => CryptoPublicKeyDataType.monero;
}
