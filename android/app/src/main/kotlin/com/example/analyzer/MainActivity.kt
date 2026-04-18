package com.example.analyzer

import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "habit_widget_channel"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)
        MidnightScheduler.schedule(this)
        Log.d("CHANNEL", "MainActivity loaded")

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "refreshWidget") {

                val percent =
                    call.argument<Int>("percent") ?: 0

                val completed =
                    call.argument<Int>("completed") ?: 0

                val total =
                    call.argument<Int>("total") ?: 0

                val loggedIn =
                    call.argument<Boolean>("loggedIn") ?: false

                Log.d(
                    "CHANNEL",
                    "percent=$percent completed=$completed total=$total loggedIn=$loggedIn"
                )

                val prefs =
                    getSharedPreferences(
                        "widget_native",
                        Context.MODE_PRIVATE
                    )

                prefs.edit()
                    .putInt("percent", percent)
                    .putInt("completed", completed)
                    .putInt("total", total)
                    .putBoolean("logged_in", loggedIn)
                    .apply()

                HabitTrackerWidgetProvider.refreshAll(this)

                result.success(true)

            } else {
                result.notImplemented()
            }
        }
    }
}