package com.example.screen_time_app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.screen_time_app/usage_stats"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    result.success(requestUsageStatsPermission())
                }
                "getAppUsageStats" -> {
                    val currentAppPackageName = call.argument<String>("packageName") ?: ""
                    result.success(getAppUsageStats(currentAppPackageName))
                }
                "getAllInstalledApps" -> {
                    result.success(getAllInstalledApps())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    // Returns usage time of all apps except blocked ones, with full app names if possible
    private fun getAppUsageStats(currentAppPackageName: String): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) return emptyList()

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val appUsageMap = mutableMapOf<String, Long>()
        val lastForegroundEventMap = mutableMapOf<String, Long>()
        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        val event = UsageEvents.Event()

        // Blocklist: Do not track or display these apps
        val blockedApps = setOf(
            "com.android.chrome",
            "com.google.android.googlequicksearchbox",
            "com.samsung.android.app.contacts",
            "com.sec.android.app.launcher",
            "com.samsung.android.forest"
        )

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)

            if (event.packageName == currentAppPackageName) continue
            if (blockedApps.contains(event.packageName)) continue

            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    lastForegroundEventMap[event.packageName] = event.timeStamp
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                    val lastTime = lastForegroundEventMap[event.packageName]
                    if (lastTime != null) {
                        val duration = event.timeStamp - lastTime
                        if (duration > 0) {
                            appUsageMap[event.packageName] =
                                appUsageMap.getOrDefault(event.packageName, 0L) + duration
                        }
                        lastForegroundEventMap.remove(event.packageName)
                    }
                }
            }
        }

        // Handle apps still in foreground
        for ((pkgName, foregroundTime) in lastForegroundEventMap) {
            if (blockedApps.contains(pkgName)) continue
            val duration = endTime - foregroundTime
            if (duration > 0) {
                appUsageMap[pkgName] =
                    appUsageMap.getOrDefault(pkgName, 0L) + duration
            }
        }

        val resultList = mutableListOf<Map<String, Any>>()
        val packageManager = applicationContext.packageManager

        // Build a cache of all installed apps' names
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        val packageNameToAppName = installedApps.associate {
            it.packageName to packageManager.getApplicationLabel(it).toString()
        }

        for ((packageName, totalTimeInForeground) in appUsageMap) {
            val appName = packageNameToAppName[packageName] ?: packageName
            resultList.add(
                mapOf(
                    "packageName" to packageName,
                    "appName" to appName,
                    "totalTimeInForeground" to totalTimeInForeground
                )
            )
        }

        return resultList
    }

    // Returns all installed apps with their app names
    private fun getAllInstalledApps(): List<Map<String, String>> {
        val packageManager = applicationContext.packageManager
        val appsList = mutableListOf<Map<String, String>>()
        val apps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        for (appInfo in apps) {
            val appName = packageManager.getApplicationLabel(appInfo).toString()
            val packageName = appInfo.packageName
            appsList.add(
                mapOf(
                    "appName" to appName,
                    "packageName" to packageName
                )
            )
        }
        return appsList
    }
}
