import 'package:blockchain_utils/service/service.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/app/isolate/types.dart';
import 'package:stealth_stash/wallet/api/services/impl/http/http.dart';
import 'package:stealth_stash/wallet/api/provider/networks/cosmos.dart';

class TendermintHTTPService extends HTTPService<CosmosAPIProvider>
    implements TendermintServiceProvider {
  TendermintHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TendermintRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl), allowStatus: [200]);
  }

  @override
  final CosmosAPIProvider provider;
}
