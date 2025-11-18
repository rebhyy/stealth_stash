import 'package:stealth_stash/app/isolate/types.dart';
import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/core/tracker.dart';
import 'package:stealth_stash/wallet/api/services/models/models/protocols.dart';

abstract class BaseServiceProtocol<T extends APIProvider> {
  // void disposeService();
  ServiceProtocol get protocol;
  APPIsolate get isolate;
  void close();
  void dispose();
}

abstract class NetworkServiceProtocol<T extends APIProvider>
    extends BaseServiceProtocol {
  T get provider;
  abstract final APIServiceTracker tracker;
}
