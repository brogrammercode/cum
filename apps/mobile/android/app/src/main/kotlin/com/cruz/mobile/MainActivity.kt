package com.cruz.mobile

import android.app.AppOpsManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull
import com.cruz.mobile.presence.GamePresenceConstants
import com.cruz.mobile.presence.GamePresenceService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "cruz/app_usage"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createMessageNotificationChannel()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> result.success(launchableApps())
                "hasUsageAccess" -> result.success(hasUsageAccess())
                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }
                "hasBatteryOptimizationExemption" -> result.success(hasBatteryOptimizationExemption())
                "openBatteryOptimizationSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        startActivity(
                            Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                            },
                        )
                    }
                    result.success(null)
                }
                "configureMonitoring" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    val token = call.argument<String>("token") ?: ""
                    val refreshToken = call.argument<String>("refreshToken") ?: ""
                    val baseUrl = call.argument<String>("baseUrl") ?: ""
                    getSharedPreferences(GamePresenceConstants.prefsName, Context.MODE_PRIVATE)
                        .edit()
                        .putString(GamePresenceConstants.keyPackages, packages.joinToString(GamePresenceConstants.packageSeparator))
                        .putString(GamePresenceConstants.keyToken, token)
                        .putString(GamePresenceConstants.keyRefreshToken, refreshToken)
                        .putString(GamePresenceConstants.keyBaseUrl, baseUrl)
                        .putBoolean(GamePresenceConstants.keyEnabled, packages.isNotEmpty())
                        .apply()
                    result.success(null)
                }
                "startMonitoring" -> {
                    getSharedPreferences(GamePresenceConstants.prefsName, Context.MODE_PRIVATE)
                        .edit()
                        .putBoolean(GamePresenceConstants.keyEnabled, true)
                        .apply()
                    startPresenceService()
                    result.success(null)
                }
                "stopMonitoring" -> {
                    stopService(Intent(this, GamePresenceService::class.java))
                    getSharedPreferences(GamePresenceConstants.prefsName, Context.MODE_PRIVATE)
                        .edit()
                        .putBoolean(GamePresenceConstants.keyEnabled, false)
                        .apply()
                    result.success(null)
                }
                "clearMonitoring" -> {
                    stopService(Intent(this, GamePresenceService::class.java))
                    getSharedPreferences(GamePresenceConstants.prefsName, Context.MODE_PRIVATE)
                        .edit()
                        .clear()
                        .apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun launchableApps(): List<Map<String, String>> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
            .asSequence()
            .filter { it.activityInfo.packageName != packageName }
            .map {
                mapOf(
                    "packageName" to it.activityInfo.packageName,
                    "label" to it.loadLabel(packageManager).toString(),
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { it["label"]?.lowercase() }
            .toList()
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, applicationInfo.uid, packageName)
        } else {
            AppOpsManager.MODE_ALLOWED
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun hasBatteryOptimizationExemption(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        return power.isIgnoringBatteryOptimizations(packageName)
    }

    private fun startPresenceService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(arrayOf("android.permission.POST_NOTIFICATIONS"), 9001)
        }
        val intent = Intent(this, GamePresenceService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun createMessageNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            GamePresenceConstants.messageNotificationChannelId,
            "Cruz messages and activity",
            NotificationManager.IMPORTANCE_DEFAULT,
        )
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .createNotificationChannel(channel)
    }
}
