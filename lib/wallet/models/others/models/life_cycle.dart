import 'dart:async';

import 'package:stealth_stash/app/core.dart';

typedef FuncWalletLockTime = int? Function();

class WalletTimeoutListener {
  WalletTimeoutListener(this._onTimer, this._onLockTime);
  bool get disposed => _timer == null;

  void start() {
    final int? locktime = _onLockTime();
    if (locktime == null) return;
    _setupTimer(locktime);
  }

  StreamSubscription<int>? _timer;
  final DynamicVoid _onTimer;
  final FuncWalletLockTime _onLockTime;
  int _tick = 0;

  int? get remining {
    if (_tick <= 0) return null;
    return _tick;
  }

  void _onListenTimer(int _) {
    _tick--;
    if (_tick <= 0) {
      final lock = _onLockTime();
      if (lock != null) {
        assert(_tick <= 0);
        _onTimer();
      }
    }
  }

  StreamSubscription<int> _buildTimer(int t) {
    return Stream<int>.periodic(
      Duration(seconds: 1),
      (computationCount) => computationCount,
    ).listen(_onListenTimer, onDone: () => dispose());
  }

  void _setupTimer(int lockTime) {
    _tick = lockTime;
    if (_timer != null) return;
    assert(_timer == null);
    _timer = _buildTimer(lockTime);
  }

  void dispose() {
    _timer?.cancel().catchError((_) {});
    _timer = null;
    _tick = 0;
  }
}
