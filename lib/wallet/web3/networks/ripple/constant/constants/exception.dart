import 'package:stealth_stash/wallet/web3/constant/constant/exception.dart';
import 'package:stealth_stash/wallet/web3/core/exception/exception.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class Web3XRPExceptionConstant {
  static final Web3RequestException invalidTransaction =
      Web3RequestExceptionConst.invalidParameters(
          'The request must include either transaction (an XRPL transaction in JSON format) or transactionBlob (the transaction encoded as a hex string).');

  static final Web3RequestException accountDoesNotSupportSignMessage =
      Web3RequestExceptionConst.message(
          'The provided address does not support message signing.',
          errorType: Web3ErrorCode.refused);
  static final Web3RequestException insufficientAccountPermissions =
      Web3RequestExceptionConst.message(
          'Signing failed: insufficient account permissions.',
          errorType: Web3ErrorCode.refused);
  static Web3RequestException unSuportedTransactionType(
          SubmittableTransactionType type) =>
      Web3RequestExceptionConst.unsuportedfeatures(
          'Unsupported transaction type: $type.');
  static Web3RequestException get mismatchTransactionAccount =>
      Web3RequestExceptionConst.invalidParameters(
          'Mismatch between account and transaction account parameters. '
          '`xrpl_signAndSendTransaction` only supports transactions from the connected account.');
}
