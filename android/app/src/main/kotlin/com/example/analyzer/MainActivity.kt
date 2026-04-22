package com.example.analyzer

import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    private val CHANNEL =
        "habit_widget_channel"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(
            flutterEngine
        )

        MidnightScheduler.schedule(this)

        MethodChannel(
            flutterEngine
                .dartExecutor
                .binaryMessenger,
            CHANNEL
        ).setMethodCallHandler {
            call, result ->

            if (call.method ==
                "refreshWidget"
            ) {

                val percent =
                    call.argument<Int>(
                        "percent"
                    ) ?: 0

                val completed =
                    call.argument<Int>(
                        "completed"
                    ) ?: 0

                val total =
                    call.argument<Int>(
                        "total"
                    ) ?: 0

                val loggedIn =
                    call.argument<Boolean>(
                        "loggedIn"
                    ) ?: false

                val itemsJson =
                    call.argument<String>(
                        "itemsJson"
                    ) ?: "[]"

                Log.d(
                    "CHANNEL",
                    "percent=$percent completed=$completed total=$total loggedIn=$loggedIn"
                )

                Log.d(
                    "WIDGET_DEBUG",
                    itemsJson
                )

                val prefs =
                    getSharedPreferences(
                        "widget_native",
                        Context.MODE_PRIVATE
                    )

                prefs.edit()
                    .putInt(
                        "percent",
                        percent
                    )
                    .putInt(
                        "completed",
                        completed
                    )
                    .putInt(
                        "total",
                        total
                    )
                    .putBoolean(
                        "logged_in",
                        loggedIn
                    )
                    .putString(
                        "items_json",
                        itemsJson
                    )
                    .commit()

                WidgetRenderer
                    .refreshAll(this)

                result.success(true)

            } else if (
                call.method ==
                "hasPendingWidgetActions"
            ) {

                val prefs =
                    getSharedPreferences(
                        "widget_native",
                        Context.MODE_PRIVATE
                    )

                val json =
                    prefs.getString(
                        "pending_actions_json",
                        "{}"
                    ) ?: "{}"

                val hasPending =
                    try {
                        JSONObject(json).length() > 0
                    } catch (_: Exception) {
                        try {
                            JSONArray(json).length() > 0
                        } catch (_: Exception) {
                            false
                        }
                    }

                result.success(hasPending)

            } else if (
                call.method ==
                "getPendingWidgetActions"
            ) {

                val prefs =
                    getSharedPreferences(
                        "widget_native",
                        Context.MODE_PRIVATE
                    )

                val json =
                    prefs.getString(
                        "pending_actions_json",
                        "{}"
                    ) ?: "{}"

                val resultList =
                    mutableListOf<Map<String, Any?>>()

                val objects =
                    try {
                        val actionObject = JSONObject(json)
                        val list =
                            mutableListOf<JSONObject>()

                        val keys = actionObject.keys()
                        while (keys.hasNext()) {
                            val key = keys.next()
                            actionObject.optJSONObject(key)
                                ?.let(list::add)
                        }

                        list
                    } catch (_: Exception) {
                        val legacyArray =
                            try {
                                JSONArray(json)
                            } catch (_: Exception) {
                                JSONArray()
                            }

                        val list =
                            mutableListOf<JSONObject>()

                        for (i in 0 until legacyArray.length()) {
                            legacyArray.optJSONObject(i)
                                ?.let(list::add)
                        }

                        list
                    }

                for (item in objects) {
                    resultList.add(
                        mapOf(
                            "parameterId" to item.optString("parameterId"),
                            "type" to item.optString("type"),
                            "done" to item.optBoolean("done"),
                            "value" to if (
                                item.has("value") &&
                                !item.isNull("value")
                            ) {
                                item.optString("value")
                            } else {
                                null
                            }
                        )
                    )
                }

                result.success(resultList)

            } else if (
                call.method ==
                "clearPendingWidgetActions"
            ) {

                val prefs =
                    getSharedPreferences(
                        "widget_native",
                        Context.MODE_PRIVATE
                    )

                prefs.edit()
                    .remove("pending_actions_json")
                    .commit()

                result.success(true)

            } else {
                result.notImplemented()
            }
        }
    }
}
