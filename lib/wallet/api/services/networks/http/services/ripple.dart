import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/isolate/types.dart';
import 'package:stealth_stash/wallet/api/provider/networks/ripple.dart';
import 'package:stealth_stash/wallet/api/services/impl/http/http.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleHTTPService extends HTTPService<RippleAPIProvider>
    implements XRPServiceProvider {
  RippleHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  String get url => provider.callUrl;

  @override
  final RippleAPIProvider provider;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(XRPRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
