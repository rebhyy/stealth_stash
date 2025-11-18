import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/wallet/api/provider/networks/aptos.dart';
import 'package:stealth_stash/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/aptos/src/aptos.dart';

class AptosHTTPService extends HTTPService<AptosAPIProvider>
    implements AptosServiceProvider {
  AptosHTTPService(
      {required this.provider,
      required this.isolate,
      required this.graphQlProvider});
  @override
  final AptosAPIProvider provider;
  final AptosAPIProvider graphQlProvider;
  @override
  final APPIsolate isolate;

  @override
  Future<AptosServiceResponse<T>> doRequest<T>(AptosRequestDetails params,
      {Duration? timeout}) async {
    final Uri uri = params.aptosRequestType == AptosRequestType.fullnode
        ? params.toUri(provider.callUrl)
        : params.toUri(graphQlProvider.callUrl);
    final AptosAPIProvider currentProvider =
        params.aptosRequestType == AptosRequestType.fullnode
            ? provider
            : graphQlProvider;
    final result = await serviceRequest<T>(params,
        uri: uri,
        allowStatus: [200, 202, 206],
        timeout: timeout,
        currentProvider: currentProvider);
    return result;
  }
}
