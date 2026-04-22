package com.example.analyzer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.util.Log
import android.widget.RemoteViews

data class WidgetSnapshot(
    val percent: Int,
    val completed: Int,
    val total: Int,
    val loggedIn: Boolean
)

object WidgetRenderer {

    @Synchronized
    fun refreshAll(context: Context) {
        Log.d("WIDGET_DEBUG", "refreshAll called")

    val snapshot = readSnapshot(context)

    val manager =
        AppWidgetManager.getInstance(context)

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

    val largeIds = manager.getAppWidgetIds(
        ComponentName(
            context,
            LargeWidgetProvider::class.java
        )
    )

    for (id in smallIds) {
        render(
            context,
            manager,
            id,
            false,
            snapshot
        )
    }

    for (id in mediumIds) {
        render(
            context,
            manager,
            id,
            true,
            snapshot
        )
    }

    for (id in largeIds) {
        LargeWidgetRenderer.render(
            context,
            manager,
            id,
            snapshot
        )
        Log.d("WIDGET_DEBUG", "Large widget render id=$id")
    }

    // REQUIRED FOR LISTVIEW DATA
    if (largeIds.isNotEmpty()) {
        manager.notifyAppWidgetViewDataChanged(
            largeIds,
            R.id.listHabits
        )
    }
}

    fun render(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        forceMedium: Boolean,
        snapshot: WidgetSnapshot = readSnapshot(context)
    ) {
        val percent = snapshot.percent
        val completed = snapshot.completed
        val total = snapshot.total
        val loggedIn = snapshot.loggedIn

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

    fun readSnapshot(context: Context): WidgetSnapshot {
        val prefs = context.getSharedPreferences(
            "widget_native",
            Context.MODE_PRIVATE
        )

        return WidgetSnapshot(
            percent = prefs.getInt("percent", 0),
            completed = prefs.getInt("completed", 0),
            total = prefs.getInt("total", 0),
            loggedIn = prefs.getBoolean("logged_in", false)
        )
    }
}
