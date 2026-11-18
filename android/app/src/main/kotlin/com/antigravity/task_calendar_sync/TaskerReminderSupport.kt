package com.antigravity.task_calendar_sync

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

internal object TaskerNotificationHelper {
    const val CHANNEL_ID = "tasker_reminders"
    private const val PREFS_NAME = "tasker_native_prefs"
    private const val KEY_ALARMS_JSON = "alarms_json"
    private const val KEY_BG_ENABLED = "bg_enabled"
    private const val KEY_BG_USER_ID = "bg_user_id"
    private const val KEY_BG_SERVER_URL = "bg_server_url"
    private const val KEY_KNOWN_TASK_IDS = "known_task_ids"
    private const val BG_JOB_ID = 7401
    private const val BG_POLL_ALARM_ID = 7402
    private const val BG_POLL_INTERVAL_MS = 15 * 60 * 1000L

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (mgr.getNotificationChannel(CHANNEL_ID) == null) {
                val ch = NotificationChannel(
                    CHANNEL_ID,
                    "Task Reminders",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Upcoming task deadlines, overdue alerts, and shared task notifications"
                }
                mgr.createNotificationChannel(ch)
            }
        }
    }

    fun show(context: Context, id: Int, title: String, body: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        ensureChannel(context)
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        val contentIntent = PendingIntent.getActivity(
            context,
            id,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val notification = builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .build()
        val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mgr.notify(id, notification)
    }

    fun syncSchedule(
        context: Context,
        alarms: List<Map<String, Any?>>,
        knownTaskIds: List<String>,
        enabled: Boolean,
        userId: String,
        serverUrl: String,
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val previousRaw = prefs.getString(KEY_ALARMS_JSON, "[]") ?: "[]"
        cancelAlarmsFromJson(context, previousRaw)

        val nextArray = JSONArray()
        if (enabled) {
            val nowMs = System.currentTimeMillis()
            for (item in alarms) {
                val triggerAtMs = (item["triggerAtMs"] as? Number)?.toLong() ?: continue
                if (triggerAtMs <= nowMs) continue
                val id = (item["id"] as? Number)?.toInt() ?: continue
                val title = item["title"]?.toString() ?: "Tasker"
                val body = item["body"]?.toString() ?: ""
                nextArray.put(JSONObject().apply {
                    put("id", id)
                    put("triggerAtMs", triggerAtMs)
                    put("title", title)
                    put("body", body)
                })
            }
        }

        val knownSet = (prefs.getStringSet(KEY_KNOWN_TASK_IDS, emptySet()) ?: emptySet()).toMutableSet()
        knownSet.addAll(knownTaskIds)

        prefs.edit()
            .putString(KEY_ALARMS_JSON, nextArray.toString())
            .putBoolean(KEY_BG_ENABLED, enabled)
            .putString(KEY_BG_USER_ID, userId)
            .putString(KEY_BG_SERVER_URL, serverUrl.trimEnd('/'))
            .putStringSet(KEY_KNOWN_TASK_IDS, knownSet)
            .apply()

        if (enabled) {
            scheduleAlarmsFromJson(context, nextArray.toString())
            ensureBackgroundJob(context, userId, serverUrl)
        } else {
            cancelBackgroundJob(context)
        }
    }

    fun clearSchedule(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        cancelAlarmsFromJson(context, prefs.getString(KEY_ALARMS_JSON, "[]") ?: "[]")
        prefs.edit()
            .putString(KEY_ALARMS_JSON, "[]")
            .putBoolean(KEY_BG_ENABLED, false)
            .remove(KEY_BG_USER_ID)
            .remove(KEY_BG_SERVER_URL)
            .remove(KEY_KNOWN_TASK_IDS)
            .apply()
        cancelBackgroundJob(context)
    }

    fun rescheduleSavedAlarms(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.getBoolean(KEY_BG_ENABLED, false)) return
        scheduleAlarmsFromJson(context, prefs.getString(KEY_ALARMS_JSON, "[]") ?: "[]")
        val uid = prefs.getString(KEY_BG_USER_ID, "") ?: ""
        val url = prefs.getString(KEY_BG_SERVER_URL, "") ?: ""
        if (uid.isNotEmpty() && url.isNotEmpty()) {
            ensureBackgroundJob(context, uid, url)
        }
    }

    private fun scheduleAlarmsFromJson(context: Context, jsonStr: String) {
        val alarmMgr = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val nowMs = System.currentTimeMillis()
        val arr = try { JSONArray(jsonStr) } catch (_: Exception) { JSONArray() }
        for (i in 0 until arr.length()) {
            val obj = arr.optJSONObject(i) ?: continue
            val triggerAtMs = obj.optLong("triggerAtMs", 0L)
            if (triggerAtMs <= nowMs) continue
            val id = obj.optInt("id", i + 1)
            val title = obj.optString("title", "Tasker")
            val body = obj.optString("body", "")
            val pi = alarmPendingIntent(context, id, title, body, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                ?: continue
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmMgr.canScheduleExactAlarms()) {
                    alarmMgr.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pi)
                } else {
                    alarmMgr.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pi)
                }
            } catch (_: SecurityException) {
                alarmMgr.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pi)
            }
        }
    }

    private fun cancelAlarmsFromJson(context: Context, jsonStr: String) {
        val alarmMgr = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val arr = try { JSONArray(jsonStr) } catch (_: Exception) { return }
        for (i in 0 until arr.length()) {
            val obj = arr.optJSONObject(i) ?: continue
            val id = obj.optInt("id", i + 1)
            val pi = alarmPendingIntent(
                context,
                id,
                obj.optString("title", ""),
                obj.optString("body", ""),
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            if (pi != null) {
                alarmMgr.cancel(pi)
                pi.cancel()
            }
        }
    }

    private fun alarmPendingIntent(
        context: Context,
        id: Int,
        title: String,
        body: String,
        flags: Int,
    ): PendingIntent? {
        val intent = Intent(context, TaskerAlarmReceiver::class.java).apply {
            putExtra("alarm_id", id)
            putExtra("alarm_title", title)
            putExtra("alarm_body", body)
        }
        return PendingIntent.getBroadcast(context, id, intent, flags)
    }

    private fun ensureBackgroundJob(context: Context, userId: String, serverUrl: String) {
        if (userId.isEmpty() || serverUrl.isEmpty()) return
        scheduleNextPollAlarm(context)
        val scheduler = context.getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
        if (scheduler.getPendingJob(BG_JOB_ID) != null) return
        val info = JobInfo.Builder(
            BG_JOB_ID,
            ComponentName(context, TaskerBackgroundSyncJobService::class.java)
        )
            .setPeriodic(BG_POLL_INTERVAL_MS)
            .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
            .setPersisted(true)
            .build()
        scheduler.schedule(info)
    }

    private fun cancelBackgroundJob(context: Context) {
        val scheduler = context.getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
        scheduler.cancel(BG_JOB_ID)
        val alarmMgr = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, TaskerPollReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context,
            BG_POLL_ALARM_ID,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        if (pi != null) {
            alarmMgr.cancel(pi)
            pi.cancel()
        }
    }

    internal fun scheduleNextPollAlarm(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.getBoolean(KEY_BG_ENABLED, false)) return
        val alarmMgr = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, TaskerPollReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context,
            BG_POLL_ALARM_ID,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val triggerAt = System.currentTimeMillis() + BG_POLL_INTERVAL_MS
        alarmMgr.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pi)
    }

    internal fun pollRemoteGivenTasks(context: Context) {
        val nativePrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!nativePrefs.getBoolean(KEY_BG_ENABLED, false)) return
        val userId = nativePrefs.getString(KEY_BG_USER_ID, "") ?: ""
        val serverUrl = nativePrefs.getString(KEY_BG_SERVER_URL, "") ?: ""
        if (userId.isEmpty() || serverUrl.isEmpty()) return

        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val authRaw = flutterPrefs.getString("flutter.pb_auth_v1", null) ?: return
        val token = try {
            JSONObject(authRaw).optString("token", "")
        } catch (_: Exception) {
            ""
        }
        if (token.isEmpty()) return

        val filter = URLEncoder.encode("user = \"$userId\" && deletedAt = \"\"", "UTF-8")
        val endpoint = "$serverUrl/api/collections/tasks/records?page=1&perPage=200&skipTotal=true&filter=$filter"
        val conn = (URL(endpoint).openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            connectTimeout = 8000
            readTimeout = 8000
            setRequestProperty("Authorization", "Bearer $token")
        }
        try {
            if (conn.responseCode !in 200..299) return
            val bodyStr = conn.inputStream.bufferedReader().use { it.readText() }
            val items = JSONObject(bodyStr).optJSONArray("items") ?: return
            val knownSet = (nativePrefs.getStringSet(KEY_KNOWN_TASK_IDS, emptySet()) ?: emptySet()).toMutableSet()
            var changed = false

            for (i in 0 until items.length()) {
                val rec = items.optJSONObject(i) ?: continue
                val clientId = rec.optString("clientId", rec.optString("id", ""))
                val status = rec.optString("status", "pending")
                val givenById = rec.optString("givenById", "")
                val givenByName = rec.optString("givenByName", "Trusted taskgiver")
                val title = rec.optString("title", "New task")

                if (clientId.isNotEmpty() && !knownSet.contains(clientId)) {
                    knownSet.add(clientId)
                    changed = true
                    if (givenById.isNotEmpty() && status == "pending") {
                        show(
                            context,
                            ("given:$clientId").hashCode() and 0x7FFFFFFF,
                            "New task from $givenByName",
                            title
                        )
                    }
                }
            }
            if (changed) {
                nativePrefs.edit().putStringSet(KEY_KNOWN_TASK_IDS, knownSet).apply()
            }
        } finally {
            conn.disconnect()
        }
    }
}

class TaskerAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("alarm_id", 100)
        val title = intent.getStringExtra("alarm_title") ?: "Tasker Reminder"
        val body = intent.getStringExtra("alarm_body") ?: ""
        TaskerNotificationHelper.show(context, id, title, body)
    }
}

class TaskerBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            TaskerNotificationHelper.rescheduleSavedAlarms(context)
        }
    }
}

class TaskerPollReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        Thread {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            val wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "tasker:bg_poll")
            try {
                wl.acquire(15_000L)
                TaskerNotificationHelper.pollRemoteGivenTasks(context)
                TaskerNotificationHelper.scheduleNextPollAlarm(context)
            } catch (_: Exception) {
            } finally {
                if (wl.isHeld) wl.release()
                pending.finish()
            }
        }.start()
    }
}

class TaskerBackgroundSyncJobService : JobService() {
    @Volatile
    private var worker: Thread? = null

    override fun onStartJob(params: JobParameters?): Boolean {
        worker = Thread {
            try {
                TaskerNotificationHelper.pollRemoteGivenTasks(applicationContext)
            } catch (_: Exception) {
            } finally {
                jobFinished(params, false)
            }
        }.apply { start() }
        return true
    }

    override fun onStopJob(params: JobParameters?): Boolean {
        worker?.interrupt()
        return true
    }
}
