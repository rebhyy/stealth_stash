import 'dart:async';
import 'dart:io';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:stealth_stash/app/error/exception/exception.dart';
import 'package:stealth_stash/app/websocket/core/core.dart';

Future<PlatformWebScoket> connectSoc(
        {required String url,
        required Duration timeout,
        List<String>? protocols}) async =>
    await WebsocketIO.connect(url: url, timeout: timeout);

class WebsocketIO implements PlatformWebScoket {
  final WebSocket _socket;
  late StreamController<String>? _streamController = StreamController<String>()
    ..onCancel = _onCloseStream;
  void _onCloseStream() {
    _socket.close(1000, "closed by client.");
  }

  @override
  bool get isConnected => _socket.readyState == WebSocket.open;
  WebsocketIO._(this._socket) {
    _socket.listen(
      (dynamic data) {
        final String? result = switch (data) {
          final String r => r,
          final List<int> r => StringUtils.tryDecode(r),
          _ => null
        };
        assert(result != null,
            "unexpected web socket response ${data.runtimeType}");
        if (result == null) return;
        _streamController?.add(result);
      },
      onDone: () {
        close();
      },
      onError: (dynamic error) {
        _streamController?.addError(error);
      },
    );
  }

  @override
  void close() {
    _streamController?.close();
    _streamController = null;
  }

  @override
  Stream<String> get stream {
    final stream = _streamController?.stream;
    if (stream == null) {
      throw ApiProviderExceptionConst.connectionClosed;
    }
    return stream;
  }

  static Future<WebsocketIO> connect(
      {required String url,
      required Duration timeout,
      List<String>? protocols}) async {
    try {
      final socket =
          await WebSocket.connect(url, protocols: protocols).timeout(timeout);
      return WebsocketIO._(socket);
    } catch (e) {
      throw ApiProviderException.fromException(message: e);
    }
  }

  @override
  void sink(List<int> message) {
    _socket.add(message);
  }

  @override
  int? get closeCode => _socket.closeCode;

  @override
  String? get closeReason => _socket.closeReason;
}
