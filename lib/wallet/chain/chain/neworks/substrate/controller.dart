part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

base mixin SubstrateChainController on Chain<
    SubstrateAPIProvider,
    SubstrateNetworkParams,
    BaseSubstrateAddress,
    SubstrateToken,
    NFTCore,
    ISubstrateAddress,
    WalletSubstrateNetwork,
    SubstrateClient,
    SubstrateNetworkConfig,
    SubstrateWalletTransaction,
    SubstrateContact,
    SubstrateNewAddressParams> {
  @override
  ISubstrateAddress? getAddress(String address) {
    return _addresses.firstWhereOrNull((element) =>
        element.viewAddress == address ||
        element.networkAddress.rawAddress == address);
  }

  @override
  ISubstrateAddress? fromNetworkAddress(BaseSubstrateAddress address) {
    return addresses.firstWhereNullable(
        (e) => e.networkAddress.rawAddress == address.rawAddress);
  }

  Future<List<SubstrateMultisigCallData>> getMultisigs(
      ISubstrateMultiSigAddress address,
      {SubstrateMultisigCall? newRequest}) async {
    _isAccountAddress(address);
    return await onClient(onConnect: (client) async {
      final multisigs = await client.getMultisigs(address.networkAddress);
      return await _callSynchronized(
          t: () async {
            if (multisigs.isEmpty) {
              await address._cleanAllMultisigs();
              if (newRequest == null) return [];
            }
            if (newRequest != null) {
              assert(newRequest.callData != null);
              await address._saveMultisig(newRequest);
            }

            final fetchedTxes = [
              ...multisigs.map((e) => e.callHashHex),
              if (newRequest != null) newRequest.callHashHex
            ];
            final accountMultisigs = [
              ...await address._getMultisigs(),
              if (newRequest != null) newRequest
            ];
            final txes = {for (final i in accountMultisigs) i.callHashHex: i};
            final junkTxes =
                txes.keys.where((e) => !fetchedTxes.contains(e)).toList();
            address._cleanMultisigs(junkTxes);
            final addNewReuqest = newRequest == null
                ? false
                : !multisigs
                    .any((e) => e.callHashHex == newRequest.callHashHex);
            return [
              if (addNewReuqest)
                SubstrateMultisigCallData(
                    call: newRequest,
                    content: () {
                      if (newRequest.callData == null) return null;
                      return client.api
                          .decodeCall(newRequest.callData!)
                          .toJson();
                    }(),
                    multisig: null),
              ...multisigs.map((e) {
                final callData = txes[e.callHashHex] ??
                    SubstrateMultisigCall(callData: null, callHash: e.callHash);
                return SubstrateMultisigCallData(
                    call: callData,
                    content: () {
                      if (callData.callData == null) return null;
                      return client.api.decodeCall(callData.callData!).toJson();
                    }(),
                    multisig: e.multisig);
              })
            ];
          },
          notifyComplete: false);
    });
  }

  Future<void> saveMultisig(
      {required ISubstrateMultiSigAddress address,
      required SubstrateMultisigCall call}) async {
    await _callSynchronized(
        t: () => address._saveMultisig(call), notifyComplete: false);
  }
}
