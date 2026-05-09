import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      return _requestAndroidPermission();
    }

    if (Platform.isIOS) {
      return _requestIOSPermission();
    }

    return true;
  }

  Future<bool> _requestAndroidPermission() async {
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted) return true;

    if (audioStatus.isDenied) {
      final result = await Permission.audio.request();
      if (result.isGranted) return true;
    }

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    if (storageStatus.isDenied) {
      final result = await Permission.storage.request();
      if (result.isGranted) return true;
    }

    final isPermanentlyDenied =
        await Permission.audio.isPermanentlyDenied ||
            await Permission.storage.isPermanentlyDenied;

    if (isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  Future<bool> _requestIOSPermission() async {
    final status = await Permission.mediaLibrary.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.mediaLibrary.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  Future<bool> hasStoragePermission() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final hasAudio = await Permission.audio.isGranted;
      final hasStorage = await Permission.storage.isGranted;
      return hasAudio || hasStorage;
    }

    if (Platform.isIOS) {
      return Permission.mediaLibrary.isGranted;
    }

    return true;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}