package com.example.analyzer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

object WidgetRenderer {

    fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)

        val smallIds = manager.getAppWidgetIds(
            ComponentName(
                context,
                SmallWidgetProvider::class.java
            )
        )

        val mediumIds = manager.getAppWidgetIds(
            ComponentName(
                context,
                MediumWidgetProvider::class.java
            )
        )

        for (id in smallIds) {
            render(context, manager, id, false)
        }

        for (id in mediumIds) {
            render(context, manager, id, true)
        }
    }

    fun render(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        forceMedium: Boolean
    ) {

        val prefs = context.getSharedPreferences(
            "widget_native",
            Context.MODE_PRIVATE
        )

        val percent = prefs.getInt("percent", 0)
        val completed = prefs.getInt("completed", 0)
        val total = prefs.getInt("total", 0)
        val loggedIn = prefs.getBoolean("logged_in", false)

        val width = manager.getAppWidgetOptions(widgetId)
            .getInt(
                AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
            )

        val isCompact =
            if (forceMedium) false else width < 220

        val layout =
            if (isCompact)
                R.layout.widget_small
            else
                R.layout.widget_medium

        val views =
            RemoteViews(
                context.packageName,
                layout
            )

        // ------------------------
        // LOGGED OUT
        // ------------------------
        if (!loggedIn) {

            views.setTextViewText(
                R.id.tvTitle,
                "No habits found"
            )

            views.setTextViewText(
                R.id.tvPercent,
                "—"
            )

            views.setTextViewText(
                R.id.tvSubtitle,
                "Login to start tracking"
            )

            if (!isCompact) {
                views.setTextViewText(
                    R.id.tvCount,
                    ""
                )
            }

            views.setProgressBar(
                R.id.progressBar,
                100,
                0,
                false
            )
        }

        // ------------------------
        // NO HABITS
        // ------------------------
        else if (total == 0) {

            views.setTextViewText(
                R.id.tvTitle,
                "No habits found"
            )

            views.setTextViewText(
                R.id.tvPercent,
                "—"
            )

            views.setTextViewText(
                R.id.tvSubtitle,
                "Create your first habit"
            )

            if (!isCompact) {
                views.setTextViewText(
                    R.id.tvCount,
                    ""
                )
            }

            views.setProgressBar(
                R.id.progressBar,
                100,
                0,
                false
            )
        }

        // ------------------------
        // NORMAL DATA
        // ------------------------
        else {

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

            views.setProgressBar(
                R.id.progressBar,
                100,
                percent,
                false
            )

            if (isCompact) {

                views.setTextViewText(
                    R.id.tvSubtitle,
                    "$completed of $total habits completed"
                )

            } else {

                views.setTextViewText(
                    R.id.tvCount,
                    "$completed/$total"
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
            }
        }

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