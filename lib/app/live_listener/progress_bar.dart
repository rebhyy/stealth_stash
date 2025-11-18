import 'package:stealth_stash/app/live_listener/live.dart';

class LivePercentProgressBar {
  int _total = 0;
  int get total => _total;

  int _counter = 0;

  final StreamValue<double> percent = StreamValue(0);
  // double get percent => _percent;

  void counter() {
    _counter++;
    percent.value = _counter / total;
  }

  void init(int total) {
    _total = total;
    _counter = 0;
    percent.value = 0;
  }

  void dispose() {
    init(0);
    percent.dispose();
  }
}
