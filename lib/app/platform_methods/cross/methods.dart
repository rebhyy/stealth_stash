import 'package:on_chain_bridge/exception/exception.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:stealth_stash/app/error/exception/wallet_ex.dart';
import 'cross_platform.dart'
    if (dart.library.js_interop) 'web.dart'
    if (dart.library.io) 'io.dart';

class PlatformMethods {
  static Future<String> writeString(String data, String fileName,
      {bool validate = true}) async {
    return await writeTOFile(data, fileName, validate: validate);
  }

  static Future<String> writeBytes(
      {required List<int> bytes,
      required String fileName,
      bool validate = true}) async {
    return await bytesToFile(
        bytes: bytes, fileName: fileName, validate: validate);
  }

  static Future<List<int>> loadAssets(String assetPath,
      {String? package}) async {
    return await loadAssetBuffer(assetPath, package: package);
  }

  static Future<String> loadAssetsText(String assetPath,
      {String? package}) async {
    return await loadAssetText(assetPath, package: package);
  }

  static String assetPath(String assetPath, {String? package}) {
    return toAssetPath(assetPath, package: package);
  }

  static Future<bool> writeClipboard(String text) async {
    return await PlatformInterface.instance.writeClipboard(text);
  }

  static Future<String?> readClipboard() {
    return PlatformInterface.instance.readClipboard();
  }

  static Future<PickedFileContent?> pickFile(
      {PickFileContentEncoding encoding = PickFileContentEncoding.utf8}) async {
    try {
      final file = await PlatformInterface.instance
          .pickAndReadFileContent(encoding: encoding);
      return file;
    } catch (e) {
      if (e == OnChainBridgeException.invalidFileData) {
        throw AppExceptionConst.invalidFileFormat;
      }
      throw AppExceptionConst.failedToReadFileContent;
    }
  }

  static Future<void> saveFile({required String filePath}) async {
    try {
      final file = await PlatformInterface.instance
          .saveFile(filePath: filePath, fileName: filePath.split("/").last);
      if (file == true) return;
    } catch (_) {}
    throw AppExceptionConst.fileSaveFailed;
  }
}
