package cn.trycat.flutterpluginpermission;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPluginPermissionPlugin
 * @author trycat
 */
public class FlutterPluginPermissionPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {

  private Registrar registrar;
  private Result result;

  private List<String> permissions;
  private List<String> mPermissionList = new ArrayList<>();

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_plugin_permission");
    FlutterPluginPermissionPlugin flutterPluginPermissionPlugin = new FlutterPluginPermissionPlugin(registrar);
    channel.setMethodCallHandler(flutterPluginPermissionPlugin);
    registrar.addRequestPermissionsResultListener(flutterPluginPermissionPlugin);
  }

  private FlutterPluginPermissionPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    String permission;
    switch (method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "getPermissionStatus":
        permission = call.argument("permission");
        result.success(getPermissionStatus(permission));
        break;
      case "checkPermission":
        permission = call.argument("permission");
        result.success(checkPermission(permission));
        break;
      case "requestPermission":
        permission = call.argument("permission");
        this.result = result;
        requestPermission(permission);
        break;
      case "requestPermissions":
        permissions = call.argument("permissions");
        this.result = result;
        requestPermissions(permissions);
        break;
      case "openSettings":
        openSettings();
        result.success(true);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void openSettings() {
    Activity activity = registrar.activity();
    Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + activity.getPackageName()));
    intent.addCategory(Intent.CATEGORY_DEFAULT);
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    activity.startActivity(intent);
  }

  private String getManifestPermission(String permission) {
    if(permission.contains("android.permission.")) {
      return permission;
    } else {
      return "android.permission." + permission.toUpperCase();
    }
  }

  private void requestPermission(String permission) {
    Activity activity = registrar.activity();
    permission = getManifestPermission(permission);
    Log.i("SimplePermission", "Requesting permission : " + permission);
    String[] perm = {permission};
    ActivityCompat.requestPermissions(activity, perm, 0);
  }

  private void requestPermissions(List<String> permissions) {
    for (int i=0; i<permissions.size(); i++) {
      this.permissions.set(i, getManifestPermission(permissions.get(i)));
    }
    checkPermissions();
  }

  private int getPermissionStatus(String permission) {
    Activity activity = registrar.activity();
    permission = getManifestPermission(permission);
    Log.i("SimplePermission", "getPermissionStatus permission : " + permission);
    if(PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(activity, permission)) {
      return 3;
    }
    if(!isAppFirstRun(activity)) {
      boolean showRequestPermission = ActivityCompat.shouldShowRequestPermissionRationale(activity, permission);
      if(!showRequestPermission) {
        return 4;
      }
    }
    return 2;
  }

  private boolean checkPermission(String permission) {
      Activity activity = registrar.activity();
      permission = getManifestPermission(permission);
      Log.i("SimplePermission", "Checking permission : " + permission);
      return PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(activity, permission);
  }

  private void checkPermissions() {
    Activity activity = registrar.activity();
    if(!mPermissionList.isEmpty()) {
      mPermissionList.clear();
    }
    /**
     * 判断哪些权限未授予
     * 以便必要的时候重新申请
     */
    Log.i("SimplePermission", "Checking permissions : " + permissions.toString());
    for (String permission : permissions) {
      if (ContextCompat.checkSelfPermission(activity, permission) != PackageManager.PERMISSION_GRANTED) {
        mPermissionList.add(permission);
      }
    }
    /**
     * 判断存储委授予权限的集合是否为空
     */
    if (!mPermissionList.isEmpty()) {
      String[] perm = new String[mPermissionList.size()];
      perm = mPermissionList.toArray(perm);
      ActivityCompat.requestPermissions(activity, perm, 1);
    } else {//未授予的权限为空，表示都授予了
      result.success(true);
    }
  }

  public static boolean isAppFirstRun(Activity activity) {
    SharedPreferences sp = activity.getSharedPreferences("FlutterPluginPermissionPluginConfig", Context.MODE_PRIVATE);
    SharedPreferences.Editor editor = sp.edit();
    if (sp.getBoolean("firstRun", true)) {
        editor.putBoolean("firstRun", false);
        editor.commit();
        return true;
    } else {
        editor.putBoolean("firstRun", false);
        editor.commit();
        return false;
    }
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] strings, int[] grantResults) {
    boolean res = false;
    if (requestCode == 0 && grantResults.length > 0) {
      res = grantResults[0] == PackageManager.PERMISSION_GRANTED;
      Log.i("SimplePermission", "Requesting permission result : " + res);
      result.success(res);
    }
    if (requestCode == 1) {
      res = true;
      result.success(true);
//      for (int i = 0; i < grantResults.length; i++) {
//        if (grantResults[i] != PackageManager.PERMISSION_GRANTED) {
//          boolean showRequestPermission = ActivityCompat.shouldShowRequestPermissionRationale(activity, permissions.get(i));
//          if (showRequestPermission) {
//            // 后续操作...
//          } else {
//            // 后续操作...
//          }
//        }
//      }
    }
    return res;
  }

}
