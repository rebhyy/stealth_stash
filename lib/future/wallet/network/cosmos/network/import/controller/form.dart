import 'package:blockchain_utils/bip/bip/bip32/bip32_key_data.dart';
import 'package:blockchain_utils/bip/bip/conf/core/coin_conf.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/future/state_managment/state_managment.dart';
import 'package:stealth_stash/future/wallet/global/pages/http_authenticated.dart';
import 'package:stealth_stash/future/widgets/widgets/text_field.dart';
import 'package:stealth_stash/wallet/wallet.dart';

typedef ONADDORUPDATECOSMOSTOKEN = Future<CosmosFeeToken?> Function(
    CosmosFeeToken? token);

class CosmosAddNewChainFrom
    with DisposableMixin, HttpImpl, CosmosCustomRequest, StreamStateController {
  CosmosAddNewChainFrom();
  final GlobalKey<AppTextFieldState> explorerFieldKey = GlobalKey();
  final GlobalKey<AppTextFieldState> transactionFieldKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey();

  String explorerAddressLink = "";
  String explorerTransaction = "";
  String? networkName;
  String hrp = '';
  String chainId = '';
  RPCURL? rpcUrl;
  int slip44 = CosmosConst.defaultSlip44;
  List<CosmosFeeToken> feeTokens = [];
  CosmosFeeToken? nativeToken;
  List<CosmosKeysAlg> _supportedAlgs = [];
  List<CosmosKeysAlg> get supportedAlgs => _supportedAlgs;
  Map<CosmosKeysAlg, Widget> keyAlgos = {};
  ChainType? _chainType;

  // bool imutableKeyAlg = false;
  bool unknowKeyAlg = false;
  bool supportedKeyAlg = false;
  CosmosKeysAlg? _selectedAlg;
  CosmosKeysAlg? get selectedAlg => _selectedAlg;
  CosmosKeysAlg? keyAlg;
  final GlobalKey<HTTPServiceProviderFieldsState> serviceProviderStateKey =
      GlobalKey(
          debugLabel: "_MoneroSyncOptionsViewState_serviceProviderStateKey");

  void setNativeToken(CosmosFeeToken token) {
    nativeToken = token;
  }

  void setFeeTokens(List<CosmosFeeToken> feeTokens) {
    this.feeTokens = feeTokens;
  }

  void setChainId(String chainId) {
    this.chainId = chainId;
  }

  void setRpcUrl(String url) {
    rpcUrl = RPCURL(url: url);
  }

  Map<CosmosKeysAlg, Widget> buildKeyAlgos() {
    return {for (final i in _supportedAlgs) i: Text(i.alg)};
  }

  CosmosSdkChainChains? _chains;
  CosmosSdkChainChains? get chains => _chains;
  void buildFromWeb3Request(
      {required String chainId,
      required String rpc,
      String? name,
      String? hrp,
      List<String>? keyAlogrithm,
      CosmosFeeToken? nativeToken,
      List<CosmosFeeToken>? feeTokens,
      ChainType? chainType}) {
    final chains = _chains;

    CosmosSdkChain? chain;
    switch (chainType) {
      case ChainType.testnet:
        chain = chains?.testnet.firstWhereOrNull((e) => e.chainId == chainId);
        break;
      case ChainType.mainnet:
        chain = chains?.mainnet.firstWhereOrNull((e) => e.chainId == chainId);
        break;
      default:
        chain = chains?.mainnet.firstWhereOrNull((e) => e.chainId == chainId);
        chain ??= chains?.testnet.firstWhereOrNull((e) => e.chainId == chainId);
        break;
    }
    buildFrom(chain);
    if (chainType != null) {
      _chainType = chainType;
    }
    _buildRpc(rpc);
    if (keyAlogrithm != null) {
      _buildAlgo(keyAlogrithm);
    }
    if (name != null) {
      networkName = name;
    }
    if (hrp != null) {
      this.hrp = hrp;
    }
    if (nativeToken != null) {
      this.nativeToken = nativeToken;
    }
    if (feeTokens != null && feeTokens.isNotEmpty) {
      this.feeTokens = feeTokens;
    }
  }

  void buildFrom(CosmosSdkChain? chain) {
    networkName = chain?.path;
    explorerAddressLink = chain?.explorers.accountPage ?? '';
    explorerTransaction = chain?.explorers.txPage ?? '';
    hrp = chain?.bech32Prefix ?? '';
    slip44 = chain?.slip44 ?? CosmosConst.defaultSlip44;
    _chainType = chain?.type;
    if (chain == null) {
      nativeToken = null;
      feeTokens = [];
    } else {
      nativeToken = CosmosFeeToken(
          token: Token(
            name: chain.native.name,
            symbol: chain.native.symbol,
            decimal: chain.native.decimals,
            assetLogo: APPImage.network(chain.native.imagePng),
            market: chain.native.coingeckoId == null
                ? null
                : CoingeckoCoin(apiId: chain.native.coingeckoId!),
          ),
          denom: chain.native.denom,
          lowGasPrice: BigRational.tryParseDecimaal(
                  chain.native.highGasPrice.toString()) ??
              CosmosConst.lowGasPrice,
          highGasPrice: BigRational.tryParseDecimaal(
                  chain.native.highGasPrice.toString()) ??
              CosmosConst.highGasPrice,
          averageGasPrice: BigRational.tryParseDecimaal(
                  chain.native.averageGasPrice.toString()) ??
              CosmosConst.avarageGasPrice);

      feeTokens = chain.fees.map((e) {
        return CosmosFeeToken(
            token: Token(
              name: e.name,
              symbol: e.symbol,
              decimal: e.decimals,
              assetLogo: APPImage.network(e.imagePng),
              market: e.coingeckoId == null
                  ? null
                  : CoingeckoCoin(apiId: e.coingeckoId!),
            ),
            denom: e.denom,
            lowGasPrice:
                BigRational.tryParseDecimaal(e.lowGasPrice.toString()) ??
                    CosmosConst.lowGasPrice,
            highGasPrice:
                BigRational.tryParseDecimaal(e.highGasPrice.toString()) ??
                    CosmosConst.highGasPrice,
            averageGasPrice:
                BigRational.tryParseDecimaal(e.averageGasPrice.toString()) ??
                    CosmosConst.avarageGasPrice);
      }).toList();
    }
    _buildAlgo(chain?.algo ?? []);
    final rpc = chain?.bestApis.rpc.firstOrNull;
    _buildRpc(rpc?.address);
  }

  void _buildRpc(String? url) {
    if (url != null) {
      rpcUrl = RPCURL(url: url);
    } else {
      rpcUrl = null;
    }
  }

  void _buildAlgo(List<String> chainAlg) {
    if (chainAlg.isEmpty) {
      unknowKeyAlg = true;
      supportedKeyAlg = true;
      _supportedAlgs = CosmosKeysAlgs.supportedAlgs
          .map((e) => CosmosKeysAlg._(alg: e.name.camelCase, key: e))
          .toList();
    } else {
      unknowKeyAlg = false;
      _supportedAlgs = chainAlg.map((e) => CosmosKeysAlg(e)).toList();
      supportedKeyAlg = _supportedAlgs.any((e) => e.supported);
    }
    keyAlgos = buildKeyAlgos();
  }

  Future<CosmosSdkChainChains> loadChains() async {
    try {
      final json = await PlatformUtils.loadJson<Map<String, dynamic>>(
          APPConst.cosmosChains.url,
          package: APPConst.cosmosChains.package);
      return CosmosSdkChainChains.fromJson(json);
    } catch (_) {
      return CosmosSdkChainChains(mainnet: [], testnet: []);
    }
  }

  Future<void> onUpdateNativeToken(ONADDORUPDATECOSMOSTOKEN onTap) async {
    final t = await onTap(nativeToken);
    if (t == null) return;
    nativeToken = t;
    notify();
  }

  Future<void> onRemoveFeeToken(
      CosmosFeeToken token, FuncFutureNullableBoold onRemove) async {
    final r = await onRemove();
    if (!(r ?? false)) return;
    feeTokens.remove(token);
    notify();
  }

  Future<void> onAddNewToken(
      ONADDORUPDATECOSMOSTOKEN onTap, DynamicVoid onTokenExists) async {
    final t = await onTap(null);
    if (t == null) return;
    if (feeTokens.any((e) => e.denom == t.denom)) {
      onTokenExists();

      return;
    }
    feeTokens.add(t);
    notify();
  }

  void onChangeKeyAlgs(CosmosKeysAlg? alg) {
    if (alg == null) return;
    keyAlg = alg;
    notify();
  }

  void onChangeCoinType(int v) {
    slip44 = v;
  }

  String? validateCoinType(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final parse = int.tryParse(v ?? "");
    if (parse == null ||
        parse < 0 ||
        parse > Bip32KeyDataConst.keyIndexMaxVal) {
      return "slip_44_desc".tr;
    }
    return null;
  }

  String? onValidateKeyAlgorithm(CosmosKeysAlg? alg) {
    if (alg == null) return "select_key_algorithm_desc".tr;
    return null;
  }

  void onChangeHrp(String v) {
    hrp = v;
  }

  void onChangeExplorerAddress(String v) {
    explorerAddressLink = v;
  }

  void onChangeExplorerTransaction(String v) {
    explorerTransaction = v;
  }

  String? validateAddressLink(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final link = StrUtils.validateUri(v);
    if (link == null) return "validate_link_desc".tr;
    return null;
  }

  String? onValidateHrp(String? v) {
    if (v?.isEmpty ?? true) return null;
    if (APPConst.hrpRegex.hasMatch(v!)) return null;
    return "enter_network_hrp_validator".tr;
  }

  Future<void> initForm() async {
    _chains = await loadChains();
  }

  Future<List<CosmosKeysAlgs>?> _validateKeyAlgorithm(
      {required TendermintProvider provider,
      required List<CosmosKeysAlgs> selected,
      bool isUnknownKeyAlgorithm = false}) async {
    List<CosmosKeysAlgs> currentAlgs = selected.clone();
    if (selected.contains(CosmosKeysAlgs.ethsecp256k1) ||
        selected.contains(CosmosKeysAlgs.comosEthsecp256k1) ||
        selected.contains(CosmosKeysAlgs.injectiveEthsecp256k1)) {
      currentAlgs = [
        ...selected,
        CosmosKeysAlgs.ethsecp256k1,
        CosmosKeysAlgs.comosEthsecp256k1,
        CosmosKeysAlgs.injectiveEthsecp256k1
      ];
    }
    // try {
    Set<CosmosKeysAlgs> supported = {};
    int retry = 0;
    List<int>? latestKey;
    while (retry <= 5) {
      retry++;
      final result = await MethodUtils.call(() async => await provider.request(
          TendermintRequestAbciQuery(
              request: QueryTryAccountsRequest(
                  pagination:
                      PageRequest(limit: BigInt.from(50), key: latestKey)))));
      if (result.hasError) continue;
      final accounts = result.resultOrNull?.accounts ?? [];
      final types = accounts
          .map((e) => e.baseAccount.pubKey?.typeUrl.typeUrl)
          .whereType<String>();
      if (isUnknownKeyAlgorithm && types.isEmpty && accounts.isNotEmpty) {
        return selected.nullOnEmoty;
      }
      final algs = types
          .map((e) => CosmosKeysAlgs.fromTypeUrl(e))
          .whereType<CosmosKeysAlgs>()
          .toList();
      supported.addAll(algs);
      latestKey = result.result.pagination?.nextKey;
    }

    return currentAlgs.where((e) => supported.contains(e)).toList().nullOnEmoty;
  }

  (CosmosNetworkParams, CosmosAPIProvider, bool)? _buildCoinParams(
      ChainType chainType) {
    final rpc = rpcUrl;
    if (nativeToken == null || feeTokens.isEmpty || rpc == null) return null;
    List<CosmosKeysAlgs> supportedAlgs = [];
    if (unknowKeyAlg) {
      final key = keyAlg?.key;
      if (key != null) {
        supportedAlgs.add(key);
      }
    } else {
      supportedAlgs = this
          .supportedAlgs
          .where((e) => e.supported)
          .map((e) => e.key)
          .toList()
          .cast();
    }
    if (supportedAlgs.isEmpty) return null;

    final network = CosmosNetworkParams(
        token: nativeToken!.token,
        // providers: [

        // ],
        chainType: chainType,
        hrp: hrp,
        denom: nativeToken!.denom,
        feeTokens: feeTokens,
        networkType: CosmosNetworkTypes.forked,
        chainId: chainId,
        keysAlgs: supportedAlgs,
        bip32CoinType: slip44,
        addressExplorer: StrUtils.isDomain(explorerAddressLink)
            ? explorerAddressLink.nullOnEmpty
            : null,
        transactionExplorer: StrUtils.isDomain(explorerTransaction)
            ? explorerTransaction.nullOnEmpty
            : null,
        chainRegisteryName: networkName);
    final provider = CosmosAPIProvider(
        uri: rpc.url,
        identifier: APIUtils.getProviderIdentifier(),
        auth: rpc.auth);
    return (network, provider, unknowKeyAlg);
  }

  RPCURL? getRpcUrl() {
    rpcUrl = serviceProviderStateKey.currentState?.getEndpoint();
    if (rpcUrl == null) return null;
    return rpcUrl;
  }

  Future<(CosmosNetworkParams, CosmosAPIProvider)> _buildNetwork(
      {required CosmosAPIProvider provider,
      required CosmosNetworkParams param,
      required bool unKnownKeyAlgorithm}) async {
    final service = CosmosClient(
        provider: TendermintProvider(TendermintHTTPService(
            provider: provider, isolate: APPIsolate.separate)),
        network: WalletCosmosNetwork(-1, param));
    String hrp = param.hrp;
    final bech32 = await MethodUtils.call(() => service.networkBech32());
    if (bech32.hasError) {
      if (hrp.isEmpty) {
        throw AppException("unable_to_retrieve_hrp");
      }
    } else {
      if (hrp.isNotEmpty && hrp != bech32.result) {
        throw AppException("different_network_hrp");
      }
      hrp = bech32.result;
    }

    final nativeToken = await MethodUtils.call(() => service.provider.request(
        TendermintRequestAbciQuery(
            request: QueryDenomMetadataRequest(denom: param.denom))));
    if (!nativeToken.hasResult) {
      await service.totalSupply(param.denom);
    }
    await service.totalSupply(param.denom);
    for (final i in param.feeTokens) {
      if (i.denom == param.denom) continue;
      await service.totalSupply(i.denom);
    }
    final chainId = await service.chainId();
    CosmosNetworkTypes networkTypes = param.networkType;
    final isEthermint = await service.isEthermint();
    if (isEthermint) {
      networkTypes = CosmosNetworkTypes.ethermint;
    }
    final keyAlgorithms = await _validateKeyAlgorithm(
        provider: service.provider,
        selected: param.keysAlgs,
        isUnknownKeyAlgorithm: unKnownKeyAlgorithm);
    if (keyAlgorithms == null || keyAlgorithms.isEmpty) {
      throw AppException("unsupported_network_key_alg");
    }
    param = param.copyWith(
        chainId: chainId,
        hrp: hrp,
        networkType: networkTypes,
        keysAlgs: keyAlgorithms);
    return (param, provider);
  }

  Future<(CosmosNetworkParams, CosmosAPIProvider)?> createNetwork(
      {ChainType? chainType}) async {
    final param =
        _buildCoinParams(chainType ?? _chainType ?? ChainType.mainnet);
    if (param == null) return null;

    return await _buildNetwork(
        provider: param.$2, param: param.$1, unKnownKeyAlgorithm: param.$3);
  }
}

class CosmosKeysAlg {
  final String alg;
  final CosmosKeysAlgs? key;
  bool get supported => key != null;
  const CosmosKeysAlg._({required this.alg, required this.key});
  factory CosmosKeysAlg(String alg) {
    CosmosKeysAlgs? key;
    try {
      key = CosmosKeysAlgs.fromSupportedAlgs(alg);
    } catch (_) {}
    return CosmosKeysAlg._(alg: alg.camelCase, key: key);
  }
}
