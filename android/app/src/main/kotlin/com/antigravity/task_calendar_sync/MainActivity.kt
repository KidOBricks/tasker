package com.antigravity.task_calendar_sync

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "tasker/notifications"
    private var pendingPermResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        TaskerNotificationHelper.ensureChannel(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                        ) {
                            pendingPermResult = result
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001)
                        } else {
                            result.success(true)
                        }
                    }
                    "show" -> {
                        val id = (call.argument<Number>("id")?.toInt()) ?: 1
                        val title = call.argument<String>("title") ?: "Tasker"
                        val body = call.argument<String>("body") ?: ""
                        TaskerNotificationHelper.show(this, id, title, body)
                        result.success(null)
                    }
                    "syncSchedule" -> {
                        @Suppress("UNCHECKED_CAST")
                        val alarms = call.argument<List<Map<String, Any?>>>("alarms") ?: emptyList()
                        val knownIds = call.argument<List<String>>("knownTaskIds") ?: emptyList()
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val userId = call.argument<String>("userId") ?: ""
                        val serverUrl = call.argument<String>("serverUrl") ?: ""
                        TaskerNotificationHelper.syncSchedule(
                            this,
                            alarms,
                            knownIds,
                            enabled,
                            userId,
                            serverUrl
                        )
                        result.success(null)
                    }
                    "clearSchedule" -> {
                        TaskerNotificationHelper.clearSchedule(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermResult?.success(granted)
            pendingPermResult = null
        }
    }
}
