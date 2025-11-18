import 'package:flutter/services.dart';

typedef OnVolumePattern = Future<bool> Function();

class VolumePanicListener {
  static const List<LogicalKeyboardKey> _pattern = [
    LogicalKeyboardKey.audioVolumeUp,
    LogicalKeyboardKey.audioVolumeDown,
    LogicalKeyboardKey.audioVolumeUp
  ];
  int _index = 0;
  DateTime? _lastKey;
  final Duration window;
  final OnVolumePattern onMatch;
  VolumePanicListener({required this.onMatch, this.window = const Duration(seconds: 5)});

  Future<void> handle(RawKeyEvent event) async {
    if (event is! RawKeyDownEvent) return;
    final now = DateTime.now();
    if (_lastKey != null && now.difference(_lastKey!) > window) {
      _index = 0;
    }
    _lastKey = now;
    final key = event.logicalKey;
    if (key == _pattern[_index]) {
      _index += 1;
      if (_index == _pattern.length) {
        _index = 0;
        final reset = await onMatch();
        if (reset) {
          _lastKey = null;
        }
      }
    } else {
      _index = 0;
    }
  }
}
