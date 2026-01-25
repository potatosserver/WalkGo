import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';

class UpdateService {
  static const String githubApiUrl =
      'https://api.github.com/repos/potatosserver/WalkGo/releases/latest';

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final response = await Dio().get(githubApiUrl);
      if (response.statusCode == 200) {
        final latestRelease = response.data;
        final String latestVersion =
            latestRelease['tag_name'].replaceAll('v', '');

        final packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        if (Version.parse(latestVersion) > Version.parse(currentVersion)) {
          return latestRelease;
        }
      }
    } catch (e) {
      // Check update failed
    }
    return null;
  }

  Future<String?> getArchitecture() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final abis = androidInfo.supportedAbis;

      if (abis.contains('arm64-v8a')) return 'arm64-v8a';
      if (abis.contains('armeabi-v7a')) return 'armeabi-v7a';
      if (abis.contains('x86_64')) return 'x86_64';
    }
    return null;
  }

  Future<void> downloadAndInstall(Map<String, dynamic> release, String arch,
      {Function(double)? onProgress,
      Function(String)? onError,
      Function(String)? onStatus}) async {
    try {
      final assets = release['assets'] as List;
      final apkName = 'app-$arch-release.apk';
      final sha1Name = '$apkName.sha1';

      final apkAsset =
          assets.firstWhere((a) => a['name'] == apkName, orElse: () => null);
      final sha1Asset =
          assets.firstWhere((a) => a['name'] == sha1Name, orElse: () => null);

      if (apkAsset == null) {
        onError?.call('APK not found for $arch');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final apkPath = '${tempDir.path}/$apkName';
      final sha1Path = '${tempDir.path}/$sha1Name';

      // Download APK
      onStatus?.call('Downloading APK...');
      await Dio().download(
        apkAsset['browser_download_url'],
        apkPath,
        onReceiveProgress: (count, total) {
          if (total > 0) {
            onProgress?.call(count / total);
          }
        },
      );

      // Verify SHA1
      if (sha1Asset != null) {
        onStatus?.call('Verifying integrity...');
        await Dio().download(sha1Asset['browser_download_url'], sha1Path);
        final expectedHash =
            (await File(sha1Path).readAsString()).trim().split(' ').first;
        final actualHash = await _calculateSHA1(apkPath);

        if (actualHash != expectedHash) {
          onError?.call('Hash mismatch');
          return;
        }
      }

      onStatus?.call('Installing...');
      await OpenFilex.open(apkPath);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<String> _calculateSHA1(String filePath) async {
    final file = File(filePath);
    final hash = await sha1.bind(file.openRead()).first;
    return hash.toString();
  }
}
