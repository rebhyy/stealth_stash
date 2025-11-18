import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:stealth_stash/crypto/types/networks.dart';
import 'package:stealth_stash/wallet/api/client/client.dart';
import 'package:stealth_stash/wallet/api/constant/constant.dart';
import 'package:stealth_stash/wallet/api/provider/provider.dart';
import 'package:stealth_stash/wallet/api/services/service.dart';
import 'package:stealth_stash/wallet/models/models.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class APIUtils {
  static BitcoinExplorerApiProvider _buildBlockCypherOrMempolProvider({
    required WalletBitcoinNetwork network,
    required BitcoinExplorerAPIProvider provider,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    final btcNetwork = network.coinParam.transacationNetwork;
    final api = ApiProvider(
        api: provider.config(btcNetwork),
        service: BitcoinHTTPService(provider: provider, isolate: isolate));
    return BitcoinExplorerApiProvider(provider: api, network: network);
  }

  static String getProviderIdentifier() {
    return CryptoKeyUtils.generateRandomString(8);
  }

  static BitcoinElectrumClient buildBitcoinElectrumProvider({
    required ElectrumAPIProvider provider,
    required WalletBitcoinNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return BitcoinElectrumClient(
        provider: ElectrumProvider(ElectrumService.fromProvider(provider)),
        network: network);
  }

  static EthereumProvider buildEthereumRPC({
    required EthereumAPIProvider provider,
    APPIsolate isolate = APPIsolate.separate,
    Duration? requestTimeout,
  }) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return EthereumProvider(EthereumWebsocketService(
          provider: provider, requestTimeout: requestTimeout));
    }
    return EthereumProvider(EthereumHTTPService(
        provider: provider, isolate: isolate, requestTimeout: requestTimeout));
  }

  static XRPServiceProvider _buildRippleProvider({
    required RippleAPIProvider provider,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return RippleWebsocketService(provider: provider);
    }
    return RippleHTTPService(provider: provider, isolate: isolate);
  }

  static BitcoinClient buildBitcoinApiPorivder({
    required APIProvider provider,
    required WalletBitcoinNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    if (provider is ElectrumAPIProvider) {
      return buildBitcoinElectrumProvider(
          provider: provider, network: network, isolate: isolate);
    }
    return _buildBlockCypherOrMempolProvider(
        network: network,
        provider: provider as BitcoinExplorerAPIProvider,
        isolate: isolate);
  }

  static EthereumClient buildEthereumProvider(
      {required EthereumAPIProvider provider,
      WalletNetwork? network,
      APPIsolate isolate = APPIsolate.separate,
      Duration? requestTimeout}) {
    return EthereumClient(
        provider: buildEthereumRPC(
            provider: provider,
            isolate: isolate,
            requestTimeout: requestTimeout),
        network: network);
  }

  static XRPClient buildRippleProvider({
    required RippleAPIProvider provider,
    required WalletXRPNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return XRPClient(
        provider: XRPProvider(
            _buildRippleProvider(provider: provider, isolate: isolate)),
        network: network);
  }

  static ADAClient buildCardanoProvider({
    required CardanoAPIProvider provider,
    required WalletCardanoNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return ADAClient(
        provider: BlockFrostProvider(
            CardanoHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static CosmosClient buildTendermintProvider({
    required CosmosAPIProvider provider,
    required WalletCosmosNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return CosmosClient(
        provider: TendermintProvider(
            TendermintHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static TonClient buildTonApiProvider({
    required TonAPIProvider provider,
    required WalletTonNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return TonClient(
        provider:
            TonProvider(TonHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static SubstrateClient buildsubstrateClient(
      {required SubstrateAPIProvider provider,
      WalletSubstrateNetwork? network,
      APPIsolate isolate = APPIsolate.separate}) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return SubstrateClient(
          provider:
              SubstrateProvider(SubstrateWebsocketService(provider: provider)),
          network: network);
    }
    return SubstrateClient(
        provider: SubstrateProvider(
            SubstrateHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static MoneroClient buildMoneroClient(
      {required MoneroAPIProvider provider,
      required WalletMoneroNetwork? network,
      APPIsolate isolate = APPIsolate.separate}) {
    return MoneroClient(
      provider: MoneroProvider(MoneroHTTPService(provider, isolate: isolate)),
      network: network,
    );
  }

  static SolanaClient buildSoalanaProvider(
      {required SolanaAPIProvider provider,
      required WalletSolanaNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    return SolanaClient(
        provider: SolanaProvider(
            SolanaHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static SuiClient buildSuiProvider(
      {required SuiAPIProvider provider,
      required WalletSuiNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    return SuiClient(
        provider:
            SuiProvider(SuiHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static AptosClient buildAptosProvider(
      {required List<AptosAPIProvider> provider,
      required WalletAptosNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    final graphQl =
        provider.firstWhere((e) => e.type == AptosAPIProviderType.graphQl);
    final fullNode =
        provider.firstWhere((e) => e.type == AptosAPIProviderType.fullnode);
    return AptosClient(
        provider: AptosProvider(AptosHTTPService(
            provider: fullNode, isolate: isolate, graphQlProvider: graphQl)),
        network: network);
  }

  static StellarClient buildStellarClient(
      {required StellarAPIProvider provider,
      required WalletStellarNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    return StellarClient(
        provider: StellarProvider(
            StellarHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static TronClient buildTronProvider(
      {required TronAPIProvider httpProviderService,
      required WalletTronNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    final httpNode = TronProvider(
        TronHTTPService(provider: httpProviderService, isolate: isolate));
    return TronClient(
        provider: httpNode,
        solidityProvider: buildEthereumProvider(
            provider: httpProviderService.solidityProvider,
            network: network,
            isolate: isolate),
        network: network);
  }

  static List<APIProvider>? _findProviders(
      {required ProviderIdentifier identifier,
      required List<APIProvider> providers,
      required NetworkType type}) {
    if (providers.isEmpty) return null;
    switch (type) {
      case NetworkType.aptos:
        final aptosProviders = providers.cast<AptosAPIProvider>();
        final AptosProviderIdentifier aptosProviderIdentifier =
            identifier.cast<AptosProviderIdentifier>();
        final grapQl = aptosProviders
            .where((e) => e.type == AptosAPIProviderType.graphQl)
            .firstWhereOrNull((e) =>
                e.identifier == aptosProviderIdentifier.graphQlIdentifier);
        final fullnode = aptosProviders
            .where((e) => e.type == AptosAPIProviderType.fullnode)
            .firstWhereOrNull((e) =>
                e.identifier == aptosProviderIdentifier.fullNodeIdentifier);
        if (fullnode == null || grapQl == null) return null;
        return [fullnode, grapQl];
      default:
        final defaultIdentifier = identifier.cast<DefaultProviderIdentifier>();
        final provider = providers.firstWhereOrNull(
            (e) => e.identifier == defaultIdentifier.identifier);
        if (provider == null) return null;
        return [provider];
    }
  }

  static List<List<T>>? _getProviders<T extends APIProvider>(
      {required List<T> providers, required NetworkType type}) {
    if (providers.isEmpty) return null;
    switch (type) {
      case NetworkType.aptos:
        final aptosProviders = providers.cast<AptosAPIProvider>();
        final grapQl = aptosProviders
            .where((e) => e.type == AptosAPIProviderType.graphQl)
            .toList();
        final fullnode = aptosProviders
            .where((e) => e.type == AptosAPIProviderType.fullnode)
            .toList();
        if (grapQl.isEmpty || fullnode.isEmpty) return null;
        return ListUtils.combineLists<T>(fullnode.cast<T>(), grapQl.cast<T>());
      default:
        return providers.map((e) => <T>[e]).toList();
    }
  }

  static T? findClient<T extends NetworkClient>(
      {required WalletNetwork network,
      required List<APIProvider> providers,
      required ProviderIdentifier identifier,
      Duration? requestTimeut,
      bool allowInWeb3 = false,
      APPIsolate isolate = APPIsolate.separate}) {
    final defaultProviders = ProvidersConst.getDefaultProvider(network);
    List<APIProvider> allProviders = [...providers, ...defaultProviders]
        .where(
            (e) => e.protocol.platforms.contains(PlatformInterface.appPlatform))
        .toList();
    if (allowInWeb3) {
      allProviders = allProviders.where((e) => e.allowInWeb3).toList();
    }
    List<APIProvider>? serviceProvider = _findProviders(
        identifier: identifier, providers: allProviders, type: network.type);
    if (serviceProvider == null) return null;
    return createClient<T>(
        network: network,
        providers: serviceProvider,
        requestTimeut: requestTimeut,
        isolate: isolate);
  }

  static T createClient<T extends NetworkClient>(
      {required WalletNetwork network,
      required List<APIProvider> providers,
      Duration? requestTimeut,
      APPIsolate isolate = APPIsolate.separate}) {
    NetworkClient? client;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        client = buildBitcoinApiPorivder(
            provider: providers.first,
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.cardano:
        client = buildCardanoProvider(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.cosmos:
        client = buildTendermintProvider(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.ethereum:
        client = buildEthereumProvider(
            provider: providers.first.cast(),
            network: network,
            requestTimeout: requestTimeut,
            isolate: isolate);
        break;
      case NetworkType.xrpl:
        client = buildRippleProvider(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.solana:
        client = buildSoalanaProvider(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.stellar:
        client = buildStellarClient(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.tron:
        client = buildTronProvider(
            httpProviderService: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.ton:
        client = buildTonApiProvider(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.monero:
        client = buildMoneroClient(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.substrate:
        client = buildsubstrateClient(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.sui:
        client = buildSuiProvider(
            provider: providers.first.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.aptos:
        client = buildAptosProvider(
            provider: providers.cast(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      default:
        throw WalletExceptionConst.internalError("createClient");
    }

    if (client is! T) {
      throw WalletExceptionConst.internalError("createClient");
    }
    return client;
  }

  static List<T>? getClients<T extends NetworkClient>(
      {required WalletNetwork network,
      required List<APIProvider> providers,
      Duration? requestTimeut,
      bool allowInWeb3 = false,
      APPIsolate isolate = APPIsolate.separate}) {
    final defaultProviders = ProvidersConst.getDefaultProvider(network);
    List<APIProvider> allProviders = [...providers, ...defaultProviders]
        .where(
            (e) => e.protocol.platforms.contains(PlatformInterface.appPlatform))
        .toList();
    if (allowInWeb3) {
      allProviders = allProviders.where((e) => e.allowInWeb3).toList();
    }

    List<List<APIProvider>>? serviceProvider =
        _getProviders(providers: allProviders, type: network.type);
    if (serviceProvider == null) return null;
    return serviceProvider
        .map((e) => createClient<T>(
            network: network,
            providers: e,
            isolate: isolate,
            requestTimeut: requestTimeut))
        .toList();
  }

  static List<T>? findProvider<T extends APIProvider>({
    required WalletNetwork network,
    required List<T> providers,
    ProviderIdentifier? identifier,
    bool allowInWeb3 = false,
  }) {
    final defaultProviders = ProvidersConst.getDefaultProvider<T>(network);
    List<T> allProviders = [...providers, ...defaultProviders]
        .where(
            (e) => e.protocol.platforms.contains(PlatformInterface.appPlatform))
        .toList();
    if (allowInWeb3) {
      allProviders = allProviders.where((e) => e.allowInWeb3).toList();
    }

    if (identifier != null) {
      final providers = _findProviders(
          identifier: identifier, providers: allProviders, type: network.type);
      if (providers != null) return providers.cast<T>();
    }

    List<List<T>>? serviceProvider =
        _getProviders<T>(providers: allProviders, type: network.type);
    return serviceProvider?.firstOrNull;
  }

  static List<T> getAllProviders<T extends APIProvider>(
      {required WalletNetwork network,
      required List<T> providers,
      bool allowInWeb3 = false}) {
    final defaultProviders = ProvidersConst.getDefaultProvider<T>(network);
    List<T> allProviders = [...providers, ...defaultProviders]
        .where(
            (e) => e.protocol.platforms.contains(PlatformInterface.appPlatform))
        .toList();
    if (allowInWeb3) {
      allProviders = allProviders.where((e) => e.allowInWeb3).toList();
    }
    return allProviders;
  }
}
