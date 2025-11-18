import 'package:blockchain_utils/service/models/params.dart';
import 'package:stealth_stash/app/isolate/types.dart';
import 'package:stealth_stash/wallet/api/provider/networks/cardano.dart';
import 'package:stealth_stash/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/ada/src/provider/blockfrost/core/core.dart';
import 'package:on_chain/ada/src/provider/service/service.dart';

class CardanoHTTPService extends HTTPService<CardanoAPIProvider>
    implements BlockFrostServiceProvider {
  CardanoHTTPService(
      {required this.provider, required this.isolate, this.version = "v0"});
  @override
  final APPIsolate isolate;

  final String version;

  String get url => provider.callUrl;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(BlockFrostRequestDetails params,
      {Duration? timeout}) async {
    final result = await serviceRequest<T>(params,
        uri: params.toUri(url, version: version),
        allowStatus: const [200, 400, 403, 404, 418, 425, 429, 500]);
    return result;
  }

  @override
  final CardanoAPIProvider provider;
}
