# flutter_plugin_permission With Android
# 居于Android客户端的扩展
**原作者如下：**
### Base on [Ethras's flutter_simple_permissions](https://github.com/Ethras/flutter_simple_permissions)


A new Flutter Permission request plugin By Android.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

Make sure you add the needed permissions to your Android Manifest Permission and Info.plist.
##注册清单文件Manifest注册需要的权限，如下：
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
## 方法：
```dart
/// 检查是否有权限
static Future<bool> checkPermission(String permission);

/// 申请单个权限
static Future<bool> requestPermission(String permission);

/// 多权限申请
/// Request a List<String> [permissions] and return a [Future] with the result
/// 字符串支持格式 ["RecordAudio", "camera", "WRITE_EXTERNAL_STORAGE"] 或者字符带"android.permission.{XXX}"
static Future<bool> requestPermissions(List<String> permissions);

/// 打开权限设置页面
static Future<bool> openSettings();

/// 获取权限状态
static Future<PermissionStatus> getPermissionStatus(String permission);

```
## 状态
```dart
/// android 主要是2,3,4
/// denied 未授权
/// authorized 授权
/// notShowView 未授权不显提示框
enum PermissionStatus {notDetermined, restricted, denied, authorized, notShowView}
```

### 具体使用请参考Demo


