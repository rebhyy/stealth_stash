import 'package:blockchain_utils/service/models/params.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/app/isolate/types.dart';
import 'package:stealth_stash/wallet/api/provider/networks/ethereum.dart';
import 'package:stealth_stash/wallet/api/services/impl/http/http.dart';

class EthereumHTTPService extends HTTPService<EthereumAPIProvider>
    implements MultichainServiceProvider {
  EthereumHTTPService({
    required this.provider,
    this.isolate = APPIsolate.current,
    this.requestTimeout,
  });
  @override
  final APPIsolate isolate;

  @override
  final EthereumAPIProvider provider;

  @override
  final Duration? requestTimeout;
  @override
  Future<BaseServiceResponse<T>> doRequest<T>(BaseServiceRequestParams params,
      {Duration? timeout}) async {
    final r = await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
    return r;
  }
}
