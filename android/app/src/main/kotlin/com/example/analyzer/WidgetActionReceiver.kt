package com.example.analyzer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.max
import kotlin.math.min

class WidgetActionReceiver : BroadcastReceiver() {

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        if (intent.action != ACTION_HANDLE_WIDGET_CLICK) {
            return
        }

        val parameterId =
            intent.getStringExtra(EXTRA_PARAMETER_ID)
                ?: return

        val type =
            intent.getStringExtra(EXTRA_TYPE)
                ?: return

        if (type == "checklist") {
            toggleChecklistLocally(
                context,
                parameterId,
                type
            )
            return
        }

        if (type == "optionSelector") {
            cycleOptionLocally(
                context,
                parameterId,
                type
            )
            return
        }

        openApp(context)
    }

    private fun toggleChecklistLocally(
        context: Context,
        parameterId: String,
        type: String
    ) {
        val prefs =
            context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

        val array =
            JSONArray(
                prefs.getString(
                    KEY_ITEMS_JSON,
                    "[]"
                ) ?: "[]"
            )

        var newDone: Boolean? = null

        for (i in 0 until array.length()) {
            val item = array.getJSONObject(i)
            if (item.optString("id") == parameterId) {
                newDone = !item.optBoolean("done")
                item.put("done", newDone)
                if (!newDone) {
                    item.put("value", "")
                } else {
                    item.put("value", "true")
                }
                break
            }
        }

        if (newDone == null) {
            return
        }

        val total =
            prefs.getInt("total", 0)

        val currentCompleted =
            prefs.getInt("completed", 0)

        val completed =
            if (newDone == true) {
                min(total, currentCompleted + 1)
            } else {
                max(0, currentCompleted - 1)
            }

        val percent =
            if (total <= 0) {
                0
            } else {
                ((completed * 100f) / total).toInt()
            }

        val pendingActions =
            getPendingActionsObject(prefs)

        pendingActions.put(
            parameterId,
            JSONObject().apply {
                put("parameterId", parameterId)
                put("type", type)
                put("done", newDone)
                put("value", JSONObject.NULL)
            }
        )

        prefs.edit()
            .putString(
                KEY_ITEMS_JSON,
                array.toString()
            )
            .putInt(
                "completed",
                completed
            )
            .putInt(
                "percent",
                percent
            )
            .putString(
                KEY_PENDING_ACTIONS_JSON,
                pendingActions.toString()
            )
            .apply()

        WidgetRenderer.refreshAll(context)
    }

    private fun cycleOptionLocally(
        context: Context,
        parameterId: String,
        type: String
    ) {
        val prefs =
            context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

        val array =
            JSONArray(
                prefs.getString(
                    KEY_ITEMS_JSON,
                    "[]"
                ) ?: "[]"
            )

        var newValue: String? = null
        var wasDone = false
        var isDone = false

        for (i in 0 until array.length()) {
            val item = array.getJSONObject(i)
            if (item.optString("id") != parameterId) {
                continue
            }

            val options =
                item.optJSONArray("options")
                    ?: JSONArray()

            if (options.length() == 0) {
                return
            }

            wasDone = item.optBoolean("done")

            val currentValue =
                item.optString("value")

            val nextValue =
                nextOptionValue(
                    currentValue,
                    options
                )

            item.put("value", nextValue)
            item.put("done", true)

            newValue = nextValue
            isDone = true
            break
        }

        if (newValue == null) {
            return
        }

        val total =
            prefs.getInt("total", 0)

        val currentCompleted =
            prefs.getInt("completed", 0)

        val completed =
            when {
                !wasDone && isDone ->
                    min(total, currentCompleted + 1)

                wasDone && !isDone ->
                    max(0, currentCompleted - 1)

                else ->
                    currentCompleted
            }

        val percent =
            if (total <= 0) {
                0
            } else {
                ((completed * 100f) / total).toInt()
            }

        val pendingActions =
            getPendingActionsObject(prefs)

        pendingActions.put(
            parameterId,
            JSONObject().apply {
                put("parameterId", parameterId)
                put("type", type)
                put("done", true)
                put("value", newValue)
            }
        )

        prefs.edit()
            .putString(
                KEY_ITEMS_JSON,
                array.toString()
            )
            .putInt(
                "completed",
                completed
            )
            .putInt(
                "percent",
                percent
            )
            .putString(
                KEY_PENDING_ACTIONS_JSON,
                pendingActions.toString()
            )
            .apply()

        WidgetRenderer.refreshAll(context)
    }

    private fun nextOptionValue(
        currentValue: String,
        options: JSONArray
    ): String {
        if (options.length() == 0) {
            return currentValue
        }

        val normalizedCurrent =
            currentValue.trim()

        var currentIndex = -1

        for (index in 0 until options.length()) {
            if (options.optString(index) == normalizedCurrent) {
                currentIndex = index
                break
            }
        }

        val nextIndex =
            if (currentIndex == -1) {
                0
            } else {
                (currentIndex + 1) % options.length()
            }

        return options.optString(nextIndex)
    }

    private fun getPendingActionsObject(
        prefs: android.content.SharedPreferences
    ): JSONObject {
        val raw =
            prefs.getString(
                KEY_PENDING_ACTIONS_JSON,
                "{}"
            ) ?: "{}"

        return try {
            JSONObject(raw)
        } catch (_: Exception) {
            val array =
                try {
                    JSONArray(raw)
                } catch (_: Exception) {
                    JSONArray()
                }

            val migrated = JSONObject()

            for (index in 0 until array.length()) {
                val item = array.optJSONObject(index)
                    ?: continue

                val parameterId =
                    item.optString("parameterId")

                if (parameterId.isNotBlank()) {
                    migrated.put(
                        parameterId,
                        item
                    )
                }
            }

            migrated
        }
    }

    private fun openApp(context: Context) {
        val launchIntent =
            context.packageManager
                .getLaunchIntentForPackage(
                    context.packageName
                )
                ?.apply {
                    addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP
                    )
                }
                ?: return

        context.startActivity(launchIntent)
    }

    companion object {
        const val ACTION_HANDLE_WIDGET_CLICK =
            "com.example.analyzer.HANDLE_WIDGET_CLICK"
        const val EXTRA_PARAMETER_ID =
            "extra_parameter_id"
        const val EXTRA_TYPE =
            "extra_type"
        private const val PREFS_NAME =
            "widget_native"
        private const val KEY_ITEMS_JSON =
            "items_json"
        private const val KEY_PENDING_ACTIONS_JSON =
            "pending_actions_json"
    }
}
