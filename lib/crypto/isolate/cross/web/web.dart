library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:blockchain_utils/crypto/crypto/chacha20poly1305/chacha20poly1305.dart';
import 'package:blockchain_utils/crypto/crypto/x25519/x25519.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_bridge/web/api/window/window.dart';
import 'package:stealth_stash/app/core.dart';
import 'package:stealth_stash/crypto/isolate/core/worker.dart';
import 'package:stealth_stash/crypto/isolate/controller/message_controller.dart';
import 'package:stealth_stash/crypto/isolate/types/types.dart';
import 'package:stealth_stash/crypto/requets/argruments/argruments.dart';
import 'package:stealth_stash/crypto/requets/completer/completer.dart';
import 'package:stealth_stash/crypto/requets/messages/models/models.dart';
import 'package:on_chain_bridge/web/web.dart' as web;
import '../exception.dart';
part 'browser.dart';

IsolateCryptoWoker getCryptoWorker() {
  return BrowserCryptoWorker._();
}
