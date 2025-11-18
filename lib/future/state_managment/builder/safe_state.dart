part of 'package:stealth_stash/future/state_managment/state_managment.dart';

mixin SafeState<T extends StatefulWidget> on State<T> {
  bool _closed = false;
  bool _builded = false;
  bool get closed => _closed;
  @override
  bool get mounted => !_closed && _builded && super.mounted;

  void onInitOnce() {}

  void safeDispose() {}

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    _closed = true;
    try {
      safeDispose();
    } catch (e, s) {
      appLogger.error(
          functionName: "safeDispose", runtime: runtimeType, msg: e, trace: s);
    }
    super.dispose();
  }

  GlobalKey<NavigatorState>? navigatorKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigatorKey ??= context.navigatorKey;
    if (!_builded) onInitOnce();
    _builded = true;
  }

  void updateState([VoidCallback? fn]) {
    setState(fn ?? () {});
  }
}

mixin ProgressMixin<T extends StatefulWidget> on SafeState<T> {
  final StreamPageProgressController progressKey =
      StreamPageProgressController();
  @override
  void safeDispose() {
    super.safeDispose();
    progressKey.dispose();
  }
}
