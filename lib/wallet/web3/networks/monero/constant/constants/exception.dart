import 'package:stealth_stash/wallet/web3/constant/constant/exception.dart';
import 'package:stealth_stash/wallet/web3/core/exception/exception.dart';

class Web3MoneroExceptionConstant {
  static final Web3RequestException accountDoesNotSupportSignMessage =
      Web3RequestExceptionConst.message(
          'The provided address does not support message signing.',
          errorType: Web3ErrorCode.refused);
  static final Web3RequestException noRecipients =
      Web3RequestExceptionConst.invalidParameters(
          'at least one recipients required.');

  static final Web3RequestException mismatchPaymentAddresses =
      Web3RequestExceptionConst.invalidParameters(
          'All recipient addresses must belong to the same monero network.');

  static final Web3RequestException multipleIntegratedAddressNotAllowed =
      Web3RequestExceptionConst.invalidParameters(
          'Multiple integrated addresses are not allowed.');

  static final Web3RequestException invalidTransaction =
      Web3RequestExceptionConst.invalidParameters(
          'The request must include a spender account and a list of recipients with address and amount.');
}
