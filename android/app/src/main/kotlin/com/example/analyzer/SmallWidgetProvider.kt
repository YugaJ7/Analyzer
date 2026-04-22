package com.example.analyzer

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Bundle

class SmallWidgetProvider :
    AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray
    ) {
        for (id in ids) {
            WidgetRenderer.render(
                context,
                manager,
                id,
                false,
                WidgetRenderer.readSnapshot(context)
            )
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        newOptions: Bundle
    ) {
        WidgetRenderer.render(
            context,
            manager,
            widgetId,
            false,
            WidgetRenderer.readSnapshot(context)
        )
    }

    companion object {
        fun refreshAll(context: Context) {
            WidgetRenderer.refreshAll(context)
        }
    }
}
