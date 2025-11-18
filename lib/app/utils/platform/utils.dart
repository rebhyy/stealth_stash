import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_bridge/models/files/picked_file_data.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:stealth_stash/app/platform_methods/cross/methods.dart';

class PlatformUtils {
  static Future<String> writeString(String data, String fileName,
      {bool validate = true}) async {
    return await PlatformMethods.writeString(data, fileName,
        validate: validate);
  }

  static Future<String> writeBytes(
      {required List<int> bytes,
      required String fileName,
      bool validate = true}) async {
    return await PlatformMethods.writeBytes(
        bytes: bytes, fileName: fileName, validate: validate);
  }

  static Future<List<int>> loadAssets(String assetPath,
      {String? package}) async {
    return await PlatformMethods.loadAssets(assetPath, package: package);
  }

  static Future<String> loadAssetText(String assetPath,
      {String? package}) async {
    return await PlatformMethods.loadAssetsText(assetPath, package: package);
  }

  static Future<T> loadJson<T>(String assetPath, {String? package}) async {
    final data =
        await PlatformMethods.loadAssetsText(assetPath, package: package);
    return StringUtils.toJson<T>(data);
  }

  static String assetPath(String assetPath) {
    return PlatformMethods.assetPath(assetPath);
  }

  static Future<bool> writeClipboard(String text) async {
    return await PlatformMethods.writeClipboard(text);
  }

  static Future<String?> readClipboard() {
    return PlatformMethods.readClipboard();
  }

  static Future<PickedFileContent?> pickFile(
      {PickFileContentEncoding encoding = PickFileContentEncoding.utf8}) async {
    final file = await PlatformMethods.pickFile(encoding: encoding);
    return file;
  }

  static Future<void> saveFile({required String filePath}) async {
    return await PlatformMethods.saveFile(filePath: filePath);
  }

  static Future<String> writeAssetToSupport({required String assetPath}) async {
    final data = await loadAssetText(assetPath);
    // final directory =
    //     await PlatformInterface.instance.path(APPConst.applicationId);
    return await writeString(data, assetPath.split("/").last, validate: false);
  }
}
