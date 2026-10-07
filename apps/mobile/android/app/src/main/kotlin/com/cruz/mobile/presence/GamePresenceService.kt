package com.cruz.mobile.presence

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.AppOpsManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.app.KeyguardManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.cruz.mobile.MainActivity
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

class GamePresenceService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()
    private var lastPackage = ""
    private var lastHeartbeat = 0L
    private val poller = object : Runnable {
        override fun run() {
            poll()
            handler.postDelayed(this, 5000L)
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        lastPackage = preferences().getString(GamePresenceConstants.keyActivePackage, "") ?: ""
        startForeground(GamePresenceConstants.notificationId, notification())
        handler.post(poller)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == GamePresenceConstants.actionStop) stopTracking()
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(poller)
        executor.shutdownNow()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun poll() {
        val preferences = preferences()
        if (!preferences.getBoolean(GamePresenceConstants.keyEnabled, false)) {
            stopTracking()
            return
        }
        val packages = (preferences.getString(GamePresenceConstants.keyPackages, "") ?: "")
            .split(GamePresenceConstants.packageSeparator)
            .filter { it.isNotBlank() }
            .toSet()
        val accessAvailable = hasUsageAccess()
        val current = if (accessAvailable) currentForegroundPackage() else null
        val selected = current != null && packages.contains(current)
        val activePackage = if (selected) current!! else ""
        if (activePackage != lastPackage) {
            if (lastPackage.isNotBlank()) postPresence("/presence/sessions/stop", lastPackage)
            if (activePackage.isNotBlank()) postPresence("/presence/sessions/start", activePackage)
            lastPackage = activePackage
            preferences.edit().putString(GamePresenceConstants.keyActivePackage, activePackage).apply()
        } else if (activePackage.isNotBlank() && System.currentTimeMillis() - lastHeartbeat > 30000L) {
            postPresence("/presence/sessions/heartbeat", activePackage)
        }
        refreshNotification(activePackage, accessAvailable)
    }

    private fun currentForegroundPackage(): String? {
        val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (keyguard.isKeyguardLocked) return null
        val usage = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = try {
            usage.queryEvents(now - 24L * 60L * 60L * 1000L, now)
        } catch (_: SecurityException) {
            return null
        }
        val event = UsageEvents.Event()
        var latest: String? = null
        var latestTime = 0L
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val isForeground = event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
            if (isForeground && event.timeStamp >= latestTime) {
                latest = event.packageName
                latestTime = event.timeStamp
            }
        }
        return latest
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                applicationInfo.uid,
                packageName,
            )
        } else {
            AppOpsManager.MODE_ALLOWED
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun postPresence(path: String, packageName: String) {
        executor.execute {
            flushQueuedEvents()
            if (sendPresence(path, packageName)) {
                lastHeartbeat = System.currentTimeMillis()
            } else {
                enqueueEvent(path, packageName)
            }
        }
    }

    private fun sendPresence(path: String, packageName: String): Boolean {
        val preferences = preferences()
        val baseUrl = preferences.getString(GamePresenceConstants.keyBaseUrl, "") ?: ""
        val token = preferences.getString(GamePresenceConstants.keyToken, "") ?: ""
        if (baseUrl.isBlank() || token.isBlank()) return false
        return try {
            val connection = URL(baseUrl.trimEnd('/') + path).openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.connectTimeout = 10000
            connection.readTimeout = 10000
            connection.doOutput = true
            connection.setRequestProperty("Authorization", "Bearer $token")
            connection.setRequestProperty("Content-Type", "application/json")
            val body = JSONObject().put("package_name", packageName).toString()
            connection.outputStream.use { it.write(body.toByteArray()) }
            val code = connection.responseCode
            connection.disconnect()
            if (code == HttpURLConnection.HTTP_UNAUTHORIZED && refreshAccessToken()) {
                return sendPresence(path, packageName)
            }
            code in 200..299
        } catch (_: Exception) {
            false
        }
    }

    private fun enqueueEvent(path: String, packageName: String) {
        val preferences = preferences()
        val queue = try {
            org.json.JSONArray(
                preferences.getString(GamePresenceConstants.keyEventQueue, "[]") ?: "[]",
            )
        } catch (_: Exception) {
            org.json.JSONArray()
        }
        queue.put(JSONObject().put("path", path).put("package", packageName))
        while (queue.length() > 50) queue.remove(0)
        preferences.edit().putString(GamePresenceConstants.keyEventQueue, queue.toString()).apply()
    }

    private fun flushQueuedEvents() {
        val preferences = preferences()
        val queue = try {
            org.json.JSONArray(
                preferences.getString(GamePresenceConstants.keyEventQueue, "[]") ?: "[]",
            )
        } catch (_: Exception) {
            org.json.JSONArray()
        }
        while (queue.length() > 0) {
            val event = queue.optJSONObject(0)
            if (event == null) {
                queue.remove(0)
                continue
            }
            if (!sendPresence(event.optString("path"), event.optString("package"))) break
            queue.remove(0)
            preferences.edit().putString(GamePresenceConstants.keyEventQueue, queue.toString()).apply()
        }
    }

    private fun refreshAccessToken(): Boolean {
        val preferences = preferences()
        val baseUrl = preferences.getString(GamePresenceConstants.keyBaseUrl, "") ?: ""
        val refreshToken = preferences.getString(GamePresenceConstants.keyRefreshToken, "") ?: ""
        if (baseUrl.isBlank() || refreshToken.isBlank()) return false
        try {
            val connection = URL(baseUrl.trimEnd('/') + "/auth/refresh").openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.connectTimeout = 10000
            connection.readTimeout = 10000
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", "application/json")
            val body = JSONObject().put("refreshToken", refreshToken).toString()
            connection.outputStream.use { it.write(body.toByteArray()) }
            if (connection.responseCode == HttpURLConnection.HTTP_OK) {
                val response = BufferedReader(InputStreamReader(connection.inputStream)).use { it.readText() }
                val json = JSONObject(response)
                preferences.edit()
                    .putString(GamePresenceConstants.keyToken, json.optString("accessToken", ""))
                    .putString(GamePresenceConstants.keyRefreshToken, json.optString("refreshToken", refreshToken))
                    .apply()
                connection.disconnect()
                return true
            }
            connection.disconnect()
        } catch (_: Exception) {
            return false
        }
        return false
    }

    private fun stopTracking() {
        if (lastPackage.isNotBlank()) {
            val packageToStop = lastPackage
            enqueueEvent("/presence/sessions/stop", packageToStop)
            postPresence("/presence/sessions/stop", packageToStop)
        }
        lastPackage = ""
        preferences().edit().putString(GamePresenceConstants.keyActivePackage, "").apply()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun notification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pending = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        return NotificationCompat.Builder(this, GamePresenceConstants.notificationChannelId)
            .setSmallIcon(com.cruz.mobile.R.mipmap.launcher_icon)
            .setContentTitle("Cruz is watching your games")
            .setContentText("Game activity sharing is active")
            .setOngoing(true)
            .setContentIntent(pending)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun refreshNotification(activePackage: String, accessAvailable: Boolean) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val text = when {
            !accessAvailable -> "Usage Access is required to detect games"
            activePackage.isBlank() -> "Waiting for a selected game"
            else -> "Playing detected game"
        }
        manager.notify(
            GamePresenceConstants.notificationId,
            NotificationCompat.Builder(this, GamePresenceConstants.notificationChannelId)
                .setSmallIcon(com.cruz.mobile.R.mipmap.launcher_icon)
                .setContentTitle("Cruz game detection active")
                .setContentText(text)
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build(),
        )
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            GamePresenceConstants.notificationChannelId,
            "Game activity detection",
            NotificationManager.IMPORTANCE_LOW,
        )
        channel.setShowBadge(false)
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
    }

    private fun preferences() = getSharedPreferences(GamePresenceConstants.prefsName, Context.MODE_PRIVATE)
}
