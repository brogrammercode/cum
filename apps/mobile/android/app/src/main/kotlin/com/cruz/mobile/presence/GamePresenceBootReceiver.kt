package com.cruz.mobile.presence

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class GamePresenceBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED && intent?.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        val preferences = context.getSharedPreferences(GamePresenceConstants.prefsName, Context.MODE_PRIVATE)
        if (!preferences.getBoolean(GamePresenceConstants.keyEnabled, false)) return
        val serviceIntent = Intent(context, GamePresenceService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
