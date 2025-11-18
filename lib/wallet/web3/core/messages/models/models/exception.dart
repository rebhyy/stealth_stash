import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/wallet/web3/core/exception/exception.dart';
import 'package:stealth_stash/wallet/web3/core/messages/types/message.dart';
import 'package:stealth_stash/wallet/web3/core/messages/types/message_types.dart';
import 'package:stealth_stash/wallet/web3/core/permission/models/authenticated.dart';

class Web3ExceptionMessage extends Web3MessageCore {
  final String message;
  final int code;
  final Web3ErrorCode errorType;
  final String? data;
  final String? customError;
  final Web3APPData? authenticated;
  // final Web3ErrorCode type;

  Web3ExceptionMessage(
      {required this.message,
      required this.code,
      required this.errorType,
      this.customError,
      this.data,
      this.authenticated});

  factory Web3ExceptionMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3MessageTypes.error.tag);
    return Web3ExceptionMessage(
        message: values.valueAs(0),
        code: values.valueAs(1),
        errorType: Web3ErrorCode.fromWalletCode(values.valueAs(2)),
        data: values.valueAs(3),
        authenticated: values.indexMaybeAs<Web3APPData, CborTagValue>(4, (p0) {
          return Web3APPData.deserialize(object: p0);
        }),
        customError: values.valueAs(5));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborSerializable.fromDynamic([
          message,
          code,
          errorType.walletCode,
          data,
          authenticated?.toCbor(),
          customError
        ]),
        type.tag);
  }

  @override
  Web3MessageTypes get type => Web3MessageTypes.error;

  Web3RequestException toException() {
    return Web3RequestException(
        message: message, errorCode: code, type: errorType, data: data);
  }
}
