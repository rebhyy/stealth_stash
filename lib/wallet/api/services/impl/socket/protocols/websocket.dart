import 'dart:async';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/core/tracker.dart';
import 'package:stealth_stash/wallet/api/services/impl/socket/core/socket_provider.dart';
import 'package:stealth_stash/wallet/api/services/models/models/protocols.dart';
import 'package:stealth_stash/wallet/api/services/models/models/request_completer.dart';
import 'package:stealth_stash/wallet/api/services/models/models/socket_status.dart';

class WebSocketService<T extends APIProvider> extends BaseSocketService<T> {
  WebSocketService({required this.provider, this.requestTimeout});
  @override
  final T provider;
  @override
  final Duration? requestTimeout;
  String get url => provider.callUrl;
  @override
  final APIServiceTracker tracker = APIServiceTracker();

  final _lock = SafeAtomicLock();
  PlatformWebScoket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<String>? _subscription;
  @override
  bool get isConnected => _status == SocketStatus.connect;

  void _onClose({SocketStatus status = SocketStatus.disconnect}) {
    _lock.run(() {
      _status = status;
      _subscription?.cancel().catchError((e) {});
      _socket?.close();
      _subscription = null;
      _socket = null;
    });
  }

  Map<String, dynamic>? onMessge(String event) {
    startTimer();
    final Map<String, dynamic> decode = StringUtils.toJson(event);
    if (decode.containsKey("id")) {
      final int id = int.parse(decode["id"]!.toString());
      final request = getRequest(id);
      request?.completer.complete(decode);
      if (request != null) {
        return null;
      }
    }
    return decode;
  }

  @override
  Future<void> connect(Duration timeout) async {
    await _lock.run(() async {
      if (_status != SocketStatus.disconnect) return;
      final result = await MethodUtils.call(() async {
        final socket = await PlatformWebScoket.connect(
            url: provider.callUrl, timeout: timeout);
        return socket;
      });
      if (result.hasResult) {
        _status = SocketStatus.connect;
        _socket = result.result;
        _subscription =
            _socket?.stream.cast<String>().listen(onMessge, onDone: _onClose);
      } else {
        _status = SocketStatus.disconnect;
        throw ApiProviderExceptionConst.socketConnectingFailed;
      }
    });
  }

  @override
  ServiceProtocol get protocol => ServiceProtocol.websocket;

  @override
  void close() => _onClose();
  @override
  void dispose() => _onClose(status: SocketStatus.dispose);

  @override
  void addMessage(SocketRequestCompleter message) {
    _socket?.sink(message.params);
  }
}
