package com.example.analyzer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.os.Bundle
import android.widget.RemoteViews

class HabitTrackerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, manager, widgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(
            context,
            manager,
            appWidgetId,
            newOptions
        )

        updateWidget(
            context,
            manager,
            appWidgetId
        )
    }

    companion object {

        fun refreshAll(context: Context) {
            val manager =
                AppWidgetManager.getInstance(context)

            val ids =
                manager.getAppWidgetIds(
                    ComponentName(
                        context,
                        HabitTrackerWidgetProvider::class.java
                    )
                )

            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }

        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            widgetId: Int
        ) {

            val prefs =
                context.getSharedPreferences(
                    "widget_native",
                    Context.MODE_PRIVATE
                )

            val percent =
                prefs.getInt("percent", 0)

            val completed =
                prefs.getInt("completed", 0)

            val total =
                prefs.getInt("total", 0)

            val loggedIn =
                prefs.getBoolean("logged_in", false)

            val isCompact =
                manager.getAppWidgetOptions(widgetId)
                    .getInt(
                        AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
                    ) < 180

            val layout =
                if (isCompact)
                    R.layout.widget_small_compact
                else
                    R.layout.widget_small

            val views =
                RemoteViews(
                    context.packageName,
                    layout
                )

            // ---------------------------------
            // 1. LOGGED OUT STATE
            // ---------------------------------
            if (!loggedIn) {

                views.setTextViewText(
                    R.id.tvTitle,
                    "No habits found"
                )

                views.setTextViewText(
                    R.id.tvPercent,
                    "—"
                )

                if (!isCompact) {
                    views.setTextViewText(
                        R.id.tvCount,
                        ""
                    )

                    views.setTextViewText(
                        R.id.tvSubtitle,
                        "Login to start tracking"
                    )
                } else {
                    views.setTextViewText(
                        R.id.tvSubtitle,
                        "Login to start tracking"
                    )
                }

                views.setProgressBar(
                    R.id.progressBar,
                    100,
                    0,
                    false
                )
            }

            // ---------------------------------
            // 2. LOGGED IN BUT NO HABITS
            // ---------------------------------
            else if (total == 0) {

                views.setTextViewText(
                    R.id.tvTitle,
                    "No habits found"
                )

                views.setTextViewText(
                    R.id.tvPercent,
                    "—"
                )

                if (!isCompact) {
                    views.setTextViewText(
                        R.id.tvCount,
                        ""
                    )

                    views.setTextViewText(
                        R.id.tvSubtitle,
                        "Create your first habit"
                    )
                } else {
                    views.setTextViewText(
                        R.id.tvSubtitle,
                        "Create your first habit"
                    )
                }

                views.setProgressBar(
                    R.id.progressBar,
                    100,
                    0,
                    false
                )
            }

            // ---------------------------------
            // 3. COMPACT 2x2
            // ---------------------------------
            else if (isCompact) {

                views.setTextViewText(
                    R.id.tvTitle,
                    if (percent == 100)
                        "Perfect Day"
                    else
                        "Today's Progress"
                )

                views.setTextViewText(
                    R.id.tvPercent,
                    "$percent%"
                )

                views.setTextViewText(
                    R.id.tvSubtitle,
                    "$completed of $total habits completed"
                )

                views.setProgressBar(
                    R.id.progressBar,
                    100,
                    percent,
                    false
                )
            }

            // ---------------------------------
            // 4. NORMAL 4x2
            // ---------------------------------
            else {

                views.setTextViewText(
                    R.id.tvTitle,
                    if (percent == 100)
                        "Perfect Day"
                    else
                        "Today's Progress"
                )

                views.setTextViewText(
                    R.id.tvCount,
                    "$completed/$total"
                )

                views.setTextViewText(
                    R.id.tvPercent,
                    "$percent%"
                )

                views.setTextViewText(
                    R.id.tvSubtitle,
                    when {
                        percent == 100 ->
                            "All habits completed"

                        percent >= 70 ->
                            "Great consistency today"

                        percent >= 40 ->
                            "Keep the momentum going"

                        else ->
                            "$completed of $total habits completed"
                    }
                )

                views.setProgressBar(
                    R.id.progressBar,
                    100,
                    percent,
                    false
                )
            }

            // ---------------------------------
            // OPEN APP ON TAP
            // ---------------------------------
            val launchIntent =
                context.packageManager
                    .getLaunchIntentForPackage(
                        context.packageName
                    )

            val pendingIntent =
                PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                )

            views.setOnClickPendingIntent(
                R.id.widgetRoot,
                pendingIntent
            )

            manager.updateAppWidget(
                widgetId,
                views
            )
        }
    }
}