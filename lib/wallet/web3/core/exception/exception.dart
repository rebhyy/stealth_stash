import 'package:blockchain_utils/utils/equatable/equatable.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/wallet/web3/core/messages/models/models/exception.dart';
import 'package:stealth_stash/wallet/web3/core/permission/models/authenticated.dart';

enum Web3ErrorCode {
  // General / internal errors
  internalError(-32603, "WALLET-000"),
  walletNotInitialized(-1, "WALLET-001"),

  // User & authentication
  rejectedByUser(4001, "WALLET-002"),
  missingPermission(4100, "WALLET-003"),
  invalidOrDisabledClient(-32001, "WALLET-004"), // subcode to distinguish

  // Request & method errors
  invalidRequest(-32600, "WALLET-005"),
  invalidParams(-32602, "WALLET-006"),
  unknownRequestMethod(4200, "WALLET-007"),
  unsupportedFeature(4903, "WALLET-008"),
  refused(4904, "WALLET-018"),

  // Network / chain
  invalidNetwork(-32000, "WALLET-009"),
  // networkDoesNotExist(-4902, "WALLET-014"),
  // ethereumRpcWrongChainId(-32003, "WALLET-01-"),
  disconnectedProvider(4900, "WALLET-010"),
  disconnectedChain(4901, "WALLET-011"),
  chainNotSupported(-32002, "WALLET-012"),
  invalidHost(-32004, "WALLET-013"),

  // RPC errors
  rpcError(-32005, "WALLET-014");

  // Auth helper
  bool get isAuthError =>
      this == rejectedByUser ||
      this == missingPermission ||
      this == invalidOrDisabledClient;
  bool get isRefused => this == refused;

  const Web3ErrorCode(this.code, this.walletCode);

  final int code;
  final String walletCode;

  static Web3ErrorCode fromWalletCode(String? walletCode) {
    return values.firstWhere(
      (e) => e.walletCode == walletCode,
      orElse: () => Web3ErrorCode.internalError,
    );
  }
}

class Web3RequestException with Equality implements Exception {
  final String message;
  final int? errorCode;
  final String? data;
  final Web3ErrorCode type;
  int get code => errorCode ?? type.code;

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "code": errorCode ?? type.code,
      "walletCode": type.walletCode,
      "data": data
    };
  }

  const Web3RequestException(
      {required this.message, this.errorCode, required this.type, this.data});
  Web3ExceptionMessage toResponseMessage(
      {Map<String, dynamic>? request,
      String? requestId,
      Web3APPData? authenticated}) {
    return Web3ExceptionMessage(
        message: message,
        code: errorCode ?? type.code,
        errorType: type,
        data: data,
        authenticated: authenticated);
  }

  @override
  String toString() {
    return message;
  }

  @override
  List get variabels => [type, errorCode, message];
}

class Web3RequestClosed implements AppException {
  const Web3RequestClosed._();
  static const Web3RequestClosed instance = Web3RequestClosed._();

  @override
  final String message = "web3_request_rejected_desc";
}
