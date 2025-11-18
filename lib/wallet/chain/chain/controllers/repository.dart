part of 'package:stealth_stash/wallet/chain/chain/chain.dart';

mixin ChainRepository<
    PROVIDER extends APIProvider,
    ADDRESS extends ChainAccount,
    NETWORK extends WalletNetwork,
    CLIENT extends NetworkClient,
    CONFIG extends DefaultNetworkConfig,
    TOKEN extends TokenCore,
    NFT extends NFTCore,
    TRANSACTION extends ChainTransaction,
    CONTACT extends ContactCore,
    ADDRESSPARAM extends NewAccountParams> {
  Future<CLIENT?> clientOrNull();
  NetworkStorageManager get _storage;
  NETWORK get network;
  ADDRESS _deserializeAddress(List<int> adressBytes);
  List<PROVIDER> _providers = [];

  final OnceRunner<List<PROVIDER>> _providersRunnter =
      OnceRunner<List<PROVIDER>>();

  Future<List<CONTACT>> _getContacts() async {
    final storagekey = DefaultNetworkStorageId.contacts;
    final data = await _storage.queriesNetworkStorage(storage: storagekey);
    final contacts = data
        .map((e) => ContactCore.deserialize<CONTACT>(network, bytes: e))
        .toList()
        .whereType<CONTACT>()
        .toList();
    appLogger.debug(
        when: () => contacts.isNotEmpty,
        runtime: runtimeType,
        functionName: "_getContacts ${network.networkName}",
        msg: "${contacts.length} contacts founds.");
    assert(
        contacts.length == data.length, "some contact deserialization failed.");
    return contacts;
  }

  Future<List<PROVIDER>> _getProviders() async {
    final providers = await _providersRunnter.get(
      onFetch: () async {
        final storagekey = DefaultNetworkStorageId.providers;
        final data = await _storage.queriesNetworkStorage(storage: storagekey);
        _providers = data
            .map((e) => APIProvider.deserialize(network, bytes: e))
            .toList()
            .whereType<PROVIDER>()
            .toImutableList;
        appLogger.error(
            when: () => data.length != _providers.length,
            runtime: runtimeType,
            functionName: "_getProviders ${network.networkName}",
            msg: "failed to deserialize providers.");
        return _providers;
      },
      onFetched: () => _providers,
    );

    return providers;
  }

  Future<void> _addNewProvider(PROVIDER provider) async {
    assert(!provider.isDefaultProvider);
    if (provider.isDefaultProvider) return;
    final storageKey = DefaultNetworkStorageId.providers;
    await _storage.insertNetworkStorage(
        storage: storageKey, value: provider, keyA: provider.identifier);
    _providers = [..._providers, provider].toImutableList;
  }

  Future<void> _removeProvider(PROVIDER provider) async {
    assert(!provider.isDefaultProvider);
    if (provider.isDefaultProvider) return;
    final storageKey = DefaultNetworkStorageId.providers;
    await _storage.removeNetworkStorage(
        storage: storageKey, keyA: provider.identifier);
    _providers = _providers.where((e) => e != provider).toImutableList;
  }

  Future<void> _saveContact(CONTACT contact) async {
    final storageKey = DefaultNetworkStorageId.contacts;
    await _storage.insertNetworkStorage(
        storage: storageKey, value: contact, keyA: contact.identifier);
  }

  Future<void> _removeContact(CONTACT contact) async {
    final storageKey = DefaultNetworkStorageId.contacts;
    await _storage.removeNetworkStorage(
        storage: storageKey, keyA: contact.identifier);
  }

  Future<List<ADDRESS>> _getAddresses() async {
    final storagekey = DefaultNetworkStorageId.address;
    final data = await _storage.queriesNetworkStorage(storage: storagekey);
    final addresses = data
        .map((e) => MethodUtils.nullOnException(() => _deserializeAddress(e)))
        .toList()
        .whereType<ADDRESS>()
        .toList();
    appLogger.error(
        when: () => addresses.length != data.length,
        runtime: runtimeType,
        functionName: "_getAddresses ${network.networkName}",
        msg: "failed to deserialize some addresses.");

    return addresses.toImutableList;
  }

  Future<bool> _saveAddresses(List<ADDRESS> addresses) async {
    return _storage.insertNetworkAddresses(
        addresses: addresses, storage: DefaultNetworkStorageId.address);
  }
}
