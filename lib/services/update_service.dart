import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';

class ReleaseInfo {
  final String tagName;
  final String htmlUrl;
  final String body;
  final List<dynamic> assets;

  ReleaseInfo({
    required this.tagName,
    required this.htmlUrl,
    required this.body,
    required this.assets,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) {
    return ReleaseInfo(
      tagName: json['tag_name'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      body: json['body'] as String? ?? '',
      assets: json['assets'] as List<dynamic>? ?? [],
    );
  }
}

class UpdateService {
  static const String githubApiUrl =
      'https://api.github.com/repos/potatosserver/WalkGo/releases/latest';
  String? _apkPath;

  Future<ReleaseInfo?> getLatestRelease() async {
    try {
      final options = BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      );
      final response = await Dio(options).get(githubApiUrl);
      if (response.statusCode == 200) {
        return ReleaseInfo.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.error is SocketException) {
        throw Exception('Network error while checking for updates.');
      }
      return null;
    }
  }

  Future<ReleaseInfo?> checkForUpdate() async {
    try {
      final latestRelease = await getLatestRelease();
      if (latestRelease != null) {
        final String latestVersion = latestRelease.tagName.replaceAll('v', '');
        final packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        if (Version.parse(latestVersion) > Version.parse(currentVersion)) {
          return latestRelease;
        }
      }
      await cleanupOldApk();
    } catch (e) {
      rethrow;
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

  Future<String> downloadApk(ReleaseInfo release, String arch,
      {Function(double)? onProgress,
      Function(String)? onStatus}) async {
    final assets = release.assets;
    final apkName = 'app-$arch-release.apk';
    final sha1Name = '$apkName.sha1';

    final apkAsset =
        assets.firstWhere((a) => a['name'] == apkName, orElse: () => null);
    final sha1Asset = assets.firstWhere((a) => a['name'] == sha1Name,
        orElse: () => null);

    if (apkAsset == null) {
      throw Exception('APK not found for $arch');
    }

    final tempDir = await getTemporaryDirectory();
    _apkPath = '${tempDir.path}/$apkName';
    final sha1Path = '${tempDir.path}/$sha1Name';

    onStatus?.call('Downloading APK...');
    await Dio().download(
      apkAsset['browser_download_url'],
      _apkPath,
      onReceiveProgress: (count, total) {
        if (total > 0) {
          onProgress?.call(count / total);
        }
      },
    );

    if (sha1Asset != null) {
      onStatus?.call('Verifying integrity...');
      await Dio().download(sha1Asset['browser_download_url'], sha1Path);
      final expectedHash =
          (await File(sha1Path).readAsString()).trim().split(' ').first;
      final actualHash = await _calculateSHA1(_apkPath!);

      if (actualHash != expectedHash) {
        throw Exception('Hash mismatch');
      }
    }
    return _apkPath!;
  }

  Future<void> installApk(String apkPath) async {
    final result = await OpenFilex.open(apkPath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open installer: ${result.message}');
    }
  }

  Future<void> deleteApk() async {
    if (_apkPath != null && await File(_apkPath!).exists()) {
      await File(_apkPath!).delete();
      _apkPath = null;
    }
  }

  Future<void> cleanupOldApk() async {
    final tempDir = await getTemporaryDirectory();
    final directory = Directory(tempDir.path);
    if (await directory.exists()) {
      final files = await directory.list().toList();
      for (final file in files) {
        if (file.path.endsWith('.apk') || file.path.endsWith('.sha1')) {
          try {
            await file.delete();
          } catch (e) {
            // ignore
          }
        }
      }
    }
  }

  Future<String> _calculateSHA1(String filePath) async {
    final file = File(filePath);
    final hash = await sha1.bind(file.openRead()).first;
    return hash.toString();
  }
}
