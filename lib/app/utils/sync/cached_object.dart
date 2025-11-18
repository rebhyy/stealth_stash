import 'dart:async';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:stealth_stash/app/core.dart';

typedef ONFETCHCACHEDOBJECT<T extends Object?> = Future<T> Function();

typedef ONFETCHEDCACHEDOBJECT<T extends Object?> = T Function();

class CachedObject<T extends Object?> with Equality {
  final _lock = SafeAtomicLock();
  final Duration interval;
  T? _value;
  T? get value => _value;
  DateTime? _update;
  CachedObject({this.interval = const Duration(minutes: 10)});

  bool _shouldFetch({Duration? interval}) {
    interval ??= this.interval;
    final update = _update;
    if (update == null) return true;
    final expire = update.add(interval);
    if (expire.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  Future<T> get(
      {required ONFETCHCACHEDOBJECT<T> onFetch, Duration? cachedTimeout}) {
    return _lock.run(() async {
      final fetch = _shouldFetch(interval: cachedTimeout);
      if (!fetch) return _value as T;
      _value = null;
      _value = await onFetch();
      _update = DateTime.now();
      return _value as T;
    });
  }

  @override
  List get variabels => [interval, value];
}

class OnceRunner<T extends Object?> {
  final SafeAtomicLock _lock = SafeAtomicLock();
  bool _isReady = false;
  OnceRunner();

  Future<T> get(
      {required ONFETCHCACHEDOBJECT<T> onFetch,
      required ONFETCHEDCACHEDOBJECT<T> onFetched,
      Duration? cachedTimeout}) async {
    if (_isReady) return onFetched();
    return await _lock.run(() async {
      final fetch = _isReady;
      if (fetch) return onFetched();
      final result = await onFetch();
      _isReady = true;
      return result;
    });
  }

  void reset() => _isReady = false;
}

class PeriodicRunner<T extends Object?>
    with DisposableMixin, StreamStateController {
  final Duration periodic;
  final Cancelable _cancelable = Cancelable();
  late final StreamSubscription<dynamic> _prediocStream;
  PeriodicRunner(
      {required this.onFetch,
      required this.periodic,
      FetchObjectStatus status = FetchObjectStatus.idle})
      : _status = status {
    _prediocStream = Stream.periodic(periodic).listen(_periodic);
  }

  final ONFETCHCACHEDOBJECT<T> onFetch;
  final _lock = SafeAtomicLock();
  T? _value;
  T get value => _value!;

  bool get hasValue => status.isSuccess;
  FetchObjectStatus _status;
  FetchObjectStatus get status => _status;
  Object? _error;
  String? _errorMessage;
  Object? get error => _error;
  String? get errorMessage => _errorMessage;
  Future<void> _periodic(void _) {
    assert(!closed, "stream already closed");
    return _lock.run(() async {
      _status = FetchObjectStatus.pending;
      _error = null;
      _errorMessage = null;
      notify();
      final result = await MethodUtils.call(() async {
        return await onFetch();
      }, cancelable: _cancelable);
      if (result.isCancel) return;
      if (result.hasError) {
        _error = result.exception;
        _errorMessage = result.localizationError;
        _status = FetchObjectStatus.failed;
      } else {
        _value = result.result;
        _status = FetchObjectStatus.success;
      }
      notify();
    });
  }

  Future<T> get({bool silent = true}) {
    return _lock.run(() async {
      if (_status.isSuccess) return _value as T;
      _status = FetchObjectStatus.pending;
      final result = await MethodUtils.call(() async {
        return onFetch();
      });
      try {
        if (result.hasError) {
          _error = result.exception;
          _errorMessage = result.localizationError;
          _status = FetchObjectStatus.failed;
          return result.result;
        } else {
          _value = result.result;
          _status = FetchObjectStatus.success;
          return _value as T;
        }
      } finally {
        if (!silent) notify();
      }
    });
  }

  void update() {
    _periodic(null);
  }

  @override
  void dispose() {
    _cancelable.cancel();
    _prediocStream.cancel();
    _value = null;
    super.dispose();
  }
}
