import 'package:on_chain/aptos/src/account/authenticator/authenticator.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';
import 'package:on_chain/aptos/src/provider/models/fullnode/types.dart';
import 'package:on_chain/aptos/src/transaction/types/types.dart';
import 'package:stealth_stash/app/live_listener/live.dart';
import 'package:stealth_stash/app/utils/sync/cached_object.dart';
import 'package:stealth_stash/wallet/api/client/networks/aptos/aptos.dart';

mixin AptosTransactionApiController on DisposableMixin {
  int? _chainId;
  final CachedObject<BigInt> _accountSequenceNumber = CachedObject();
  final CachedObject<BigInt> _gasUnitPrice = CachedObject();
  AptosClient get client;

  Future<BigInt> getAccountSequenceNumber(AptosAddress address,
      {bool cache = false}) async {
    return _accountSequenceNumber.get(
        onFetch: () async => await client.getAccountSequence(address));
  }

  Future<AptosApiUserTransaction> simulate(
      {required AptosRawTransaction rawTransaction,
      AptosAddress? feePayer,
      List<AptosAddress>? secondarySignerAddresses}) async {
    final authenticator = _buildSimulateAuthenticator(
        feePayer: feePayer, secondarySignerAddresses: secondarySignerAddresses);
    return client.simulateTransaction(
        rawTransaction: rawTransaction,
        feePayer: feePayer,
        secondarySignerAddresses: secondarySignerAddresses,
        authenticator: authenticator);
  }

  Future<int> getChainId() async {
    return (_chainId ??= await client.getCurrenctChainId());
  }

  Future<BigInt> getGasPrice() async {
    return _gasUnitPrice.get(
        onFetch: () async => await client.getGasUnitPrice());
  }

  AptosTransactionAuthenticator _buildSimulateAuthenticator({
    AptosAddress? feePayer,
    List<AptosAddress>? secondarySignerAddresses,
  }) {
    if (feePayer == null && secondarySignerAddresses == null) {
      return AptosTransactionAuthenticatorSignleSender(
          AptosAccountAuthenticatorNoAccountAuthenticator());
    } else if (feePayer != null) {
      return AptosTransactionAuthenticatorFeePayer(
          sender: AptosAccountAuthenticatorNoAccountAuthenticator(),
          feePayerAddress: feePayer,
          feePayerAuthenticator:
              AptosAccountAuthenticatorNoAccountAuthenticator(),
          secondarySignerAddressess: secondarySignerAddresses ?? [],
          secondarySigner: secondarySignerAddresses
                  ?.map(
                      (e) => AptosAccountAuthenticatorNoAccountAuthenticator())
                  .toList() ??
              []);
    }
    return AptosTransactionAuthenticatorMultiAgent(
        sender: AptosAccountAuthenticatorNoAccountAuthenticator(),
        secondarySignerAddressess: secondarySignerAddresses ?? [],
        secondarySigner: secondarySignerAddresses
                ?.map((e) => AptosAccountAuthenticatorNoAccountAuthenticator())
                .toList() ??
            []);
  }
}
