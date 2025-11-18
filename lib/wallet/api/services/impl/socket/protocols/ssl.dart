import 'package:stealth_stash/wallet/api/provider/core/provider.dart';
import 'package:stealth_stash/wallet/api/services/impl/socket/protocols/tcp.dart';
import 'package:stealth_stash/wallet/api/services/models/models/protocols.dart';

class SSLService<T extends APIProvider> extends TCPService<T> {
  SSLService({required super.provider});

  @override
  ServiceProtocol get protocol => ServiceProtocol.ssl;
}
