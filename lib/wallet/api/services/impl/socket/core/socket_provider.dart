import 'dart:async';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/app/live_listener/timout.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/core/base_service.dart';
import 'package:stealth_stash/wallet/api/services/models/models.dart';

abstract class BaseSocketService<T extends APIProvider>
    extends NetworkServiceProtocol<T> with TimerEvent {
  Future<void> connect(Duration timeout);
  bool get isConnected;
  Duration? get requestTimeout => null;
  final _lock = SafeAtomicLock();
  @override
  Duration get timeoutDuration => const Duration(minutes: 3);
  @override
  APPIsolate get isolate => APPIsolate.current;

  Future<Map<String, dynamic>> providerCaller(
      {required Future<Map<String, dynamic>> Function() t,
      required SocketRequestCompleter param,
      required Duration timeout}) async {
    Map<String, dynamic>? response;
    try {
      response = await () async {
        if (requestTimeout == null) {
          return await _onException(t: t, timeout: timeout);
        }
        await _lock.run(() async {
          await Future.delayed(requestTimeout!);
        });
        return await _onException(t: t, timeout: timeout);
      }();
      return response;
    } on ApiProviderException catch (e) {
      tracker.addRequest(ApiRequest(
          error: e, identifier: provider.identifier, uri: provider.callUrl));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(
            ApiRequest(identifier: provider.identifier, uri: provider.callUrl));
      }
    }
  }

  Future<Map<String, dynamic>> post(
      SocketRequestCompleter message, Duration timeout) async {
    try {
      return providerCaller(
          t: () async {
            _requests[message.id] = message;
            addMessage(message);
            final result = await message.completer.future.timeout(timeout);
            return result;
          },
          param: message,
          timeout: timeout);
    } finally {
      _requests.remove(message.id);
    }
  }

  Future<Map<String, dynamic>> _onException(
      {required Future<Map<String, dynamic>> Function() t,
      required Duration timeout}) async {
    try {
      await connect(timeout);
      if (!isConnected) {
        throw ApiProviderExceptionConst.socketConnectingFailed;
      }
      startTimer();
      final response = await t();
      return response;
    } catch (e) {
      throw ApiProviderException.fromException(message: e);
    }
  }

  final Map<int, SocketRequestCompleter> _requests = {};

  SocketRequestCompleter? getRequest(int id) {
    return _requests.remove(id);
  }

  void addMessage(SocketRequestCompleter message);

  @override
  void onTimerEvent() {
    super.onTimerEvent();
    close();
  }
}
