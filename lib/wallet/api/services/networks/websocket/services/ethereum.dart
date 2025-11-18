import 'package:blockchain_utils/service/models/params.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/app/utils/method/utiils.dart';
import 'package:stealth_stash/wallet/api/provider/networks/ethereum.dart';
import 'package:stealth_stash/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:stealth_stash/wallet/api/services/models/models/request_completer.dart';
import 'package:stealth_stash/wallet/api/services/models/networks/ethereum.dart';

class _EthereumWebsocketServiceConst {
  static const String subscriptionMethodName = "eth_subscription";
  static const String params = "params";
  static const String method = "method";
}

class EthereumWebsocketService extends WebSocketService<EthereumAPIProvider>
    implements MultichainServiceProvider {
  EthereumWebsocketService(
      {required super.provider,
      super.requestTimeout,
      this.defaultTimeOut = const Duration(seconds: 30)});
  final List<ONETHSubsribe> _listeners = [];

  void addSubscriptionListener(ONETHSubsribe listener) {
    _listeners.add(listener);
  }

  void removeSubscriptionListener(ONETHSubsribe listener) {
    _listeners.remove(listener);
  }

  void _emitListeners(EthereumSubscribeResult result) {
    for (final i in [..._listeners]) {
      MethodUtils.nullOnException(() => i(result));
    }
  }

  @override
  Map<String, dynamic>? onMessge(String event) {
    final message = super.onMessge(event);
    if (message != null &&
        message[_EthereumWebsocketServiceConst.method] ==
            _EthereumWebsocketServiceConst.subscriptionMethodName) {
      final result = MethodUtils.nullOnException(() {
        return EthereumSubscribeResult.fromJson(
            message[_EthereumWebsocketServiceConst.params]);
      });
      if (result != null) {
        _emitListeners(result);
      }
    }
    return message;
  }

  final Duration defaultTimeOut;

  @override
  void close() {
    super.close();
    _listeners.clear();
  }

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(BaseServiceRequestParams params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await post(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
