package com.sushant.screen_graveyard

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    private val channel = "com.sushant.screen_graveyard/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isUsageStatsPermissionGranted" ->
                    result.success(isUsageStatsGranted())

                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }

                "getDailySummary" -> {
                    try {
                        result.success(getDailySummary())
                    } catch (e: Exception) {
                        result.error("USAGE_STATS_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // ── Permission check ──────────────────────────────────────────────────────

    private fun isUsageStatsGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    // ── Daily summary ─────────────────────────────────────────────────────────

    private fun getDailySummary(): Map<String, Any> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val (startOfDay, endOfDay) = getTodayRange()

        val appUsageList = getAppUsage(usageStatsManager, startOfDay, endOfDay)
        val unlockCount = getUnlockCount(usageStatsManager, startOfDay, endOfDay)
        val screenOnMillis = getScreenOnTime(usageStatsManager, startOfDay, endOfDay)
        val notificationDismissals = getNotificationDismissals(
            usageStatsManager, startOfDay, endOfDay,
        )

        return mapOf(
            "date" to startOfDay,
            "unlockCount" to unlockCount,
            "screenOnMillis" to screenOnMillis,
            "notificationDismissals" to notificationDismissals,
            "appUsage" to appUsageList,
        )
    }

    // ── App usage (per-app foreground time) ───────────────────────────────────

    private fun getAppUsage(
        manager: UsageStatsManager,
        start: Long,
        end: Long,
    ): List<Map<String, Any>> {
        val stats = manager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, start, end,
        )

        return stats
            .filter { it.totalTimeInForeground > 0 }
            .filter { it.packageName != packageName } // exclude self
            .map { stat ->
                mapOf(
                    "packageName" to stat.packageName,
                    "totalTimeMillis" to stat.totalTimeInForeground,
                    "lastTimeUsed" to stat.lastTimeUsed,
                )
            }
            .sortedByDescending { it["totalTimeMillis"] as Long }
            .take(20) // top 20 apps
    }

    // ── Unlock count via KEYGUARD_HIDDEN events ───────────────────────────────

    private fun getUnlockCount(
        manager: UsageStatsManager,
        start: Long,
        end: Long,
    ): Int {
        val events = manager.queryEvents(start, end)
        val event = UsageEvents.Event()
        var count = 0

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.KEYGUARD_HIDDEN) {
                count++
            }
        }

        return count
    }

    // ── Screen-on time via SCREEN_INTERACTIVE events ──────────────────────────

    private fun getScreenOnTime(
        manager: UsageStatsManager,
        start: Long,
        end: Long,
    ): Long {
        val events = manager.queryEvents(start, end)
        val event = UsageEvents.Event()

        var screenOnMillis = 0L
        var screenOnStart = -1L

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            when (event.eventType) {
                UsageEvents.Event.SCREEN_INTERACTIVE -> {
                    screenOnStart = event.timeStamp
                }
                UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                    if (screenOnStart > 0) {
                        screenOnMillis += event.timeStamp - screenOnStart
                        screenOnStart = -1L
                    }
                }
            }
        }

        // Screen still on at query time
        if (screenOnStart > 0) {
            screenOnMillis += System.currentTimeMillis() - screenOnStart
        }

        return screenOnMillis
    }

    // ── Notification dismissals via NOTIFICATION_INTERRUPTION events ──────────

    private fun getNotificationDismissals(
        manager: UsageStatsManager,
        start: Long,
        end: Long,
    ): Int {
        val events = manager.queryEvents(start, end)
        val event = UsageEvents.Event()
        var count = 0

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            // Event type 12 = NOTIFICATION_INTERRUPTION (notification posted/shown)
            if (event.eventType == 12) {
                count++
            }
        }

        return count
    }

    // ── Date range helpers ────────────────────────────────────────────────────

    private fun getTodayRange(): Pair<Long, Long> {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val start = calendar.timeInMillis
        val end = start + 24 * 60 * 60 * 1000L
        return Pair(start, end)
    }
}
