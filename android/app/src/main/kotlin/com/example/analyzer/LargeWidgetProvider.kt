package com.example.analyzer

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

class LargeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            LargeWidgetRenderer.render(
                context,
                manager,
                id,
                WidgetRenderer.readSnapshot(context)
            )
        }
    }
}
