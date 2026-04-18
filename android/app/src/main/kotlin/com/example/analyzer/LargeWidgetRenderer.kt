package com.example.analyzer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.net.Uri

object LargeWidgetRenderer {

    fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)

        val ids = manager.getAppWidgetIds(
            ComponentName(
                context,
                LargeWidgetProvider::class.java
            )
        )

        for (id in ids) {
            render(context, manager, id)
        }
    }

    fun render(
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

        val views =
            RemoteViews(
                context.packageName,
                R.layout.widget_large
            )

        // -------------------------
        // TOP SUMMARY
        // -------------------------
        if (!loggedIn) {

            views.setTextViewText(
                R.id.tvTitle,
                "No habits found"
            )

            views.setTextViewText(
                R.id.tvCount,
                ""
            )

            views.setTextViewText(
                R.id.tvPercent,
                "—"
            )

            views.setTextViewText(
                R.id.tvSubtitle,
                "Login to start tracking"
            )

            views.setProgressBar(
                R.id.progressBar,
                100,
                0,
                false
            )

        } else if (total == 0) {

            views.setTextViewText(
                R.id.tvTitle,
                "No habits found"
            )

            views.setTextViewText(
                R.id.tvCount,
                ""
            )

            views.setTextViewText(
                R.id.tvPercent,
                "—"
            )

            views.setTextViewText(
                R.id.tvSubtitle,
                "Create your first habit"
            )

            views.setProgressBar(
                R.id.progressBar,
                100,
                0,
                false
            )

        } else {

            views.setTextViewText(
                R.id.tvTitle,
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
                "$completed of $total habits completed"
            )

            views.setProgressBar(
                R.id.progressBar,
                100,
                percent,
                false
            )
        }

        // -------------------------
        // LIST VIEW
        // -------------------------
        val serviceIntent =
    Intent(
        context,
        LargeWidgetService::class.java
    ).apply {

        putExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            widgetId
        )

        data = android.net.Uri.parse(
            toUri(Intent.URI_INTENT_SCHEME)
        )
    }

views.setRemoteAdapter(
    R.id.listHabits,
    serviceIntent
)

        views.setEmptyView(
            R.id.listHabits,
            R.id.emptyView
        )

        // -------------------------
        // OPEN APP
        // -------------------------
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

        manager.notifyAppWidgetViewDataChanged(
            widgetId,
            R.id.listHabits
        )
    }
}