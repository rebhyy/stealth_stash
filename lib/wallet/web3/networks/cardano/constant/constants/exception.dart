import 'package:stealth_stash/wallet/web3/constant/constant/exception.dart';
import 'package:stealth_stash/wallet/web3/core/exception/exception.dart';

// enum APIErrorCode {
// 	InvalidRequest: -1,
// 	InternalError: -2,
// 	Refused: -3,
// 	AccountChange: -4,
// }
class Web3ADAExceptionConstant {
  static Web3RequestException get invalidWsTransactionParams =>
      Web3RequestExceptionConst.invalidParameters(
          "Required: 'account' or 'accounts' (for multi-address transfers), and 'transaction' CBOR-encoded transaction represented as a hex string or a Uint8Array");
  static Web3RequestException get invalidRequestAccounts =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid request accounts: All accounts must belong to the same network.");
  static final Web3RequestException invalidTransaction =
      Web3RequestExceptionConst.invalidParameters(
          'Invalid transaction: must be a CBOR-encoded transaction represented as a hex string or a Uint8Array.');
  static final Web3RequestException invalidBatchTransaction =
      Web3RequestExceptionConst.invalidParameters(
          'Invalid batch transaction: each object must be contains "cbor" a CBOR-encoded transaction represented as a hex string or a Uint8Array.');
  // Invalid batch transaction. "cbor" must be a transaction CBOR encoded as hex.

  static final Web3RequestException invalidPaginated =
      Web3RequestExceptionConst.invalidParameters(
          'Invalid pagination. Must include both "page" (>= 0) and "limit" (> 0).');

  static Web3RequestException invalidCborParameters(String name) =>
      Web3RequestExceptionConst.invalidParameters(
          'Invalid CBOR: unable to parse "$name" as CBOR.');
  static Web3RequestException paginateReached(int maxSize) =>
      Web3RequestExceptionConst.message(
          'Pagination limit reached. Maximum available items: $maxSize.',
          data: maxSize.toString(),
          errorType: Web3ErrorCode.invalidParams);

  // static final Web3RequestException noChangeAddress =
  //     Web3RequestExceptionConst.message('No change address selected.',
  //         errorType: Web3ErrorCode.refused);

  static final Web3RequestException unsuportedSigningMessageAccount =
      Web3RequestExceptionConst.message(
          "The address does not support message signing.",
          errorType: Web3ErrorCode.refused);

  static final Web3RequestException unableToAccessBip32PublicKey =
      Web3RequestExceptionConst.message(
          "Cannot access BIP32 public key: account is script or wallet-controlled.",
          errorType: Web3ErrorCode.refused);

  static final Web3RequestException walletNotConnectedToScript =
      Web3RequestExceptionConst.message(
          "No script account connected to the wallet.",
          errorType: Web3ErrorCode.refused);

  static final Web3RequestException unableToSignTransactionAsNonPartial =
      Web3RequestExceptionConst.message(
          "Unable to fully sign transaction: required account keys are not available in this wallet.",
          errorType: Web3ErrorCode.refused);

  static final Web3RequestException transactionNotFound =
      Web3RequestExceptionConst.message("Transaction not found.",
          errorType: Web3ErrorCode.refused);
}
