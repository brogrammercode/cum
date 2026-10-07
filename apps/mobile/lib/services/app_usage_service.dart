import 'package:flutter/services.dart';
import 'dart:io';

import '../core/config.dart';
import '../core/storage/secure_storage.dart';

class InstalledApp {
  const InstalledApp({required this.packageName, required this.label});

  final String packageName;
  final String label;

  factory InstalledApp.fromJson(Map<dynamic, dynamic> json) {
    return InstalledApp(
      packageName: json['packageName']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class AppUsageService {
  static const _channel = MethodChannel('cruz/app_usage');

  AppUsageService({required SecureStorage storage}) : _storage = storage;

  final SecureStorage _storage;

  bool get supportsAutomaticDetection => Platform.isAndroid;

  Future<List<InstalledApp>> getLaunchableApps() async {
    if (!supportsAutomaticDetection) return const [];
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getInstalledApps',
    );
    return (result ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(InstalledApp.fromJson)
        .where((app) => app.packageName.isNotEmpty && app.label.isNotEmpty)
        .toList();
  }

  Future<bool> hasUsageAccess() async {
    if (!supportsAutomaticDetection) return true;
    return await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
  }

  Future<void> openUsageAccessSettings() {
    if (!supportsAutomaticDetection) return Future.value();
    return _channel.invokeMethod<void>('openUsageAccessSettings');
  }

  Future<bool> hasBatteryOptimizationExemption() async {
    if (!supportsAutomaticDetection) return true;
    return await _channel.invokeMethod<bool>(
          'hasBatteryOptimizationExemption',
        ) ??
        false;
  }

  Future<void> openBatteryOptimizationSettings() {
    if (!supportsAutomaticDetection) return Future.value();
    return _channel.invokeMethod<void>('openBatteryOptimizationSettings');
  }

  Future<void> configureMonitoring(List<String> packageNames) async {
    if (!supportsAutomaticDetection) return;
    final token = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();
    await _channel.invokeMethod<void>('configureMonitoring', {
      'packages': packageNames,
      'token': token ?? '',
      'refreshToken': refreshToken ?? '',
      'baseUrl': AppConfig.apiBaseUrl,
    });
  }

  Future<void> startMonitoring() {
    if (!supportsAutomaticDetection) return Future.value();
    return _channel.invokeMethod<void>('startMonitoring');
  }

  Future<void> stopMonitoring() {
    if (!supportsAutomaticDetection) return Future.value();
    return _channel.invokeMethod<void>('stopMonitoring');
  }

  Future<void> clearMonitoring() {
    if (!supportsAutomaticDetection) return Future.value();
    return _channel.invokeMethod<void>('clearMonitoring');
  }
}
