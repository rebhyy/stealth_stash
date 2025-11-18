import 'package:blockchain_utils/service/models/params.dart';
import 'package:stealth_stash/wallet/api/provider/networks/substrate.dart';
import 'package:stealth_stash/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:stealth_stash/wallet/api/services/models/models/request_completer.dart';

class SubstrateWebsocketService extends WebSocketService<SubstrateAPIProvider>
    implements MultichainServiceProvider {
  SubstrateWebsocketService(
      {required super.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});

  final Duration defaultTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(BaseServiceRequestParams params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await post(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
