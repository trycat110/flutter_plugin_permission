import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPluginPermission {
  static const MethodChannel _channel =
      const MethodChannel('flutter_plugin_permission');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  /// Check a [permission] and return a [Future] with the result
  static Future<bool> checkPermission(String permission) async {
    final bool isGranted = await _channel.invokeMethod(
        "checkPermission", {"permission": permission});
    return isGranted;
  }

  /// Request a [permission] and return a [Future] with the result
  static Future<bool> requestPermission(String permission) async {
    final bool isGranted = await _channel.invokeMethod(
        "requestPermission", {"permission": permission});
    return isGranted;
  }

  /// Request a List<String> [permissions] and return a [Future] with the result
  /// param format ["RecordAudio", "Camera", "WRITE_EXTERNAL_STORAGE"] or start with "android.permission.{XXX}"
  ///
  static Future<bool> requestPermissions(List<String> permissions) async {
    final bool isGranted = await _channel.invokeMethod(
        "requestPermissions", {"permissions": permissions});
    return isGranted;
  }

  /// Open app settings on Android and iOs
  static Future<bool> openSettings() async {
    final bool isOpen = await _channel.invokeMethod("openSettings");
    return isOpen;
  }

  static Future<PermissionStatus> getPermissionStatus(
      String permission) async {
    final int status = await _channel.invokeMethod("getPermissionStatus", {"permission": permission});
    switch (status) {
      case 0:
        return PermissionStatus.notDetermined;
      case 1:
        return PermissionStatus.restricted;
      case 2:
        return PermissionStatus.denied;
      case 3:
        return PermissionStatus.authorized;
      case 4:
        return PermissionStatus.notShowView; // 未授权，不显提示框
      default:
        return PermissionStatus.notDetermined;
    }
  }
}

/// Permissions status enum
enum PermissionStatus { notDetermined, restricted, denied, authorized, notShowView}

enum Permission {
  RecordAudio,
  Camera,
  WriteExternalStorage,
  ReadExternalStorage,
  AccessCoarseLocation,
  AccessFineLocation,
  WhenInUseLocation,
  AlwaysLocation,
  ReadContacts,
  Vibrate,
  WriteContacts
}

String getPermissionString(Permission permission) {
  String res;
  switch (permission) {
    case Permission.Camera:
      res = "CAMERA";
      break;
    case Permission.RecordAudio:
      res = "RECORD_AUDIO";
      break;
    case Permission.WriteExternalStorage:
      res = "WRITE_EXTERNAL_STORAGE";
      break;
    case Permission.ReadExternalStorage:
      res = "READ_EXTERNAL_STORAGE";
      break;
    case Permission.AccessFineLocation:
      res = "ACCESS_FINE_LOCATION";
      break;
    case Permission.AccessCoarseLocation:
      res = "ACCESS_COARSE_LOCATION";
      break;
    case Permission.WhenInUseLocation:
      res = "WHEN_IN_USE_LOCATION";
      break;
    case Permission.AlwaysLocation:
      res = "ALWAYS_LOCATION";
      break;
    case Permission.ReadContacts:
      res = "READ_CONTACTS";
      break;
    case Permission.Vibrate:
      res = "VIBRATE";
      break;
    case Permission.WriteContacts:
      res = "WRITE_CONTACTS";
      break;
  }
  return res;
}

