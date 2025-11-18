import 'dart:async';
import 'dart:io';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:stealth_stash/app/utils/method/utiils.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/core/tracker.dart';
import 'package:stealth_stash/wallet/api/services/impl/socket/core/socket_provider.dart';
import 'package:stealth_stash/wallet/api/services/models/models/protocols.dart';
import 'package:stealth_stash/wallet/api/services/models/models/request_completer.dart';
import 'package:stealth_stash/wallet/api/services/models/models/socket_status.dart';

class TCPService<T extends APIProvider> extends BaseSocketService<T> {
  TCPService({required this.provider});
  @override
  final T provider;
  @override
  final APIServiceTracker tracker = APIServiceTracker();
  final _lock = SafeAtomicLock();
  Socket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<List<int>>? _subscription;
  @override
  bool get isConnected => _status == SocketStatus.connect;
  @override
  void addMessage(SocketRequestCompleter message) {
    _socket?.add(message.params + '\n'.codeUnits);
  }

  void _onClose({SocketStatus status = SocketStatus.disconnect}) {
    _lock.run(() {
      _status = status;
      _socket?.close().catchError((e) => null);
      _subscription?.cancel().catchError((e) {});
      _subscription = null;
      _socket = null;
    });
  }

  List<int> _remainBytes = [];
  void _onMessge(List<int> event) {
    startTimer();
    assert(event.isNotEmpty, "data is empty");
    if (event.isEmpty) return;
    assert(event[0] == 0x7b || _remainBytes.isNotEmpty, "unexpected bytes.");
    if (event[0] != 0x7b && _remainBytes.isEmpty) return;
    List<int> bytes = [];

    if (event.last == 0xa) {
      bytes = [..._remainBytes, ...event.sublist(0, event.length - 1)];
      _remainBytes = [];
    } else {
      _remainBytes = [..._remainBytes, ...event];
      return;
    }
    List<String>? str = StringUtils.tryDecode(bytes)?.split("\n");
    if (str == null) {
      _remainBytes = [];
      assert(false, "unexpected response");
      return;
    }
    for (final i in str) {
      if (i.isEmpty) continue;
      Map<String, dynamic>? decode = StringUtils.tryToJson(i);
      if (decode == null) {
        _remainBytes = [];
        assert(false, "unexpected response");
        return;
      }
      if (decode.containsKey("id")) {
        final int id = int.parse(decode["id"]!.toString());
        final request = getRequest(id);
        request?.completer.complete(decode);
      }
    }
  }

  @override
  Future<void> connect(Duration timeout) async {
    await _lock.run(() async {
      if (_status != SocketStatus.disconnect) return;
      final result = await MethodUtils.call(() async {
        final result = provider.callUrl.split(":");
        final socket = switch (protocol) {
          ServiceProtocol.tcp => await Socket.connect(
              result.first, int.parse(result[1]),
              timeout: timeout),
          _ => await SecureSocket.connect(result.first, int.parse(result[1]),
              onBadCertificate: (certificate) => true,
              context: SecurityContext.defaultContext,
              timeout: timeout)
        };
        return socket;
      });
      if (result.hasResult) {
        _status = SocketStatus.connect;
        _socket = result.result;
        _subscription = _socket?.listen(_onMessge, onDone: _onClose);
      } else {
        _status = SocketStatus.disconnect;
      }
    });
  }

  @override
  ServiceProtocol get protocol => ServiceProtocol.tcp;

  @override
  void close() => _onClose();
  @override
  void dispose() => _onClose(status: SocketStatus.dispose);
}
