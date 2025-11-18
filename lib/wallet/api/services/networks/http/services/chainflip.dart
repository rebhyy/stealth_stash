import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/app/isolate/types.dart';
import 'package:stealth_stash/wallet/api/provider/networks/custom.dart';
import 'package:stealth_stash/wallet/api/services/impl/http/http.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class ChainFlipHTTPService extends HTTPService<CustomAPIProvider>
    implements CfServiceProvider {
  ChainFlipHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  Future<CfServiceResponse<T>> doRequest<T>(CfRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: [200]);
  }

  @override
  final CustomAPIProvider provider;
}
