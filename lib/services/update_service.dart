import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:walkgo/l10n/app_localizations.dart';

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
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String?> getArchitecture() async {
    if (!Platform.isAndroid) {
      return null;
    }

    const availableApkAbis = {
      'arm64-v8a',
      'armeabi-v7a',
      'x86_64',
    };

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final supportedAbis = androidInfo.supportedAbis;

      developer.log(
        'Device supported ABIs (ordered by preference): $supportedAbis',
        name: 'walkgo.updateservice',
      );
      developer.log(
        'APKs available for ABIs: $availableApkAbis',
        name: 'walkgo.updateservice',
      );

      for (final String abi in supportedAbis) {
        if (availableApkAbis.contains(abi)) {
          developer.log('Found best matching ABI: $abi', name: 'walkgo.updateservice');
          return abi;
        }
      }

      developer.log(
        'This device does not support any of the available APK ABIs.',
        name: 'walkgo.updateservice',
      );
      return null;
    } catch (e, s) {
      developer.log(
        'Failed to get device architecture',
        name: 'walkgo.updateservice',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  Future<void> installFromPath(String apkPath) async {
    final result = await OpenFilex.open(apkPath);
    developer.log(
      'OpenFilex result: ${result.type} - ${result.message}',
      name: 'walkgo.updateservice',
    );
  }

  Future<String?> downloadUpdate(ReleaseInfo release, String arch, AppLocalizations l10n, {
    Function(double)? onProgress,
    Function(String)? onError,
    Function(String)? onStatus,
  }) async {
    try {
      final assets = release.assets;
      final apkName = 'app-$arch-release.apk';
      final sha1Name = '$apkName.sha1';

      final apkAsset = assets.firstWhere((a) => a['name'] == apkName, orElse: () => null);
      final sha1Asset = assets.firstWhere((a) => a['name'] == sha1Name, orElse: () => null);

      if (apkAsset == null) {
        final errorMessage = l10n.invalid_architecture;
        onError?.call(errorMessage);
        developer.log(errorMessage, name: 'walkgo.updateservice', level: 1000);
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final apkPath = '${tempDir.path}/$apkName';
      final sha1Path = '${tempDir.path}/$sha1Name';

      onStatus?.call(l10n.downloading_apk(apkName));
      await Dio().download(
        apkAsset['browser_download_url'],
        apkPath,
        onReceiveProgress: (count, total) {
          if (total > 0) {
            onProgress?.call(count / total);
          }
        },
      );

      if (sha1Asset != null) {
        onStatus?.call(l10n.verifying_integrity);
        await Dio().download(sha1Asset['browser_download_url'], sha1Path);
        final expectedHash = (await File(sha1Path).readAsString()).trim().split(' ').first;
        final actualHash = await _calculateSHA1(apkPath);

        if (actualHash != expectedHash) {
          final errorMessage = l10n.hash_mismatch;
          onError?.call(errorMessage);
          developer.log(errorMessage, name: 'walkgo.updateservice', level: 1000);
          return null;
        }
      }

      onStatus?.call(l10n.update_ready_to_install);
      onStatus?.call(l10n.starting_installation);
      await installFromPath(apkPath);
      return apkPath;
    } on DioException catch (e) {
      final errorMessage = l10n.update_check_failed;
      onError?.call(errorMessage);
      developer.log(errorMessage, name: 'walkgo.updateservice', error: e, level: 1000);
      return null;
    } catch (e, s) {
      final errorMessage = l10n.unknown_error;
      onError?.call(errorMessage);
      developer.log(errorMessage, name: 'walkgo.updateservice', error: e, stackTrace: s, level: 1000);
      return null;
    }
  }

  Future<String> _calculateSHA1(String filePath) async {
    final file = File(filePath);
    final hash = await sha1.bind(file.openRead()).first;
    return hash.toString();
  }
}
