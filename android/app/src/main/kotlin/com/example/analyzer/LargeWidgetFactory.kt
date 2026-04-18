package com.example.analyzer

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

class LargeWidgetFactory(
    private val context: Context
) : RemoteViewsService.RemoteViewsFactory {

    private val items =
        mutableListOf<String>()

    override fun onCreate() {}

    override fun onDestroy() {
        items.clear()
    }

    override fun getCount(): Int {
        Log.d("WIDGET_DEBUG", "getCount=${items.size}")
        return items.size
    }

    override fun getViewTypeCount(): Int = 1

    override fun getLoadingView(): RemoteViews? = null

    override fun getItemId(position: Int): Long =
        position.toLong()

    override fun hasStableIds(): Boolean = true

    override fun onDataSetChanged() {

        items.clear()

        try {

            val prefs =
                context.getSharedPreferences(
                    "widget_native",
                    Context.MODE_PRIVATE
                )

            val json =
                prefs.getString(
                    "items_json",
                    "[]"
                ) ?: "[]"

            Log.d("WIDGET_DEBUG", "Factory json=$json")

            val array = JSONArray(json)

            for (i in 0 until array.length()) {

                val obj =
                    array.getJSONObject(i)

                val name =
                    obj.optString("name")

                val type =
                    obj.optString("type")

                val done =
                    obj.optBoolean("done")

                val value =
                    obj.optString("value")

                val row =
                    when (type) {

                        "checklist" ->
                            if (done)
                                "☑ $name"
                            else
                                "☐ $name"

                        "optionSelector" ->
                            "$name • $value"

                        else ->
                            "$name • $value"
                    }

                items.add(row)
            }

            Log.d("WIDGET_DEBUG", "Loaded rows=${items.size}")

        } catch (e: Exception) {

            Log.e(
                "WIDGET_DEBUG",
                "Parse fail",
                e
            )
        }
    }

    override fun getViewAt(
        position: Int
    ): RemoteViews {

        val views =
            RemoteViews(
                context.packageName,
                R.layout.widget_large_row
            )

        if (position >= items.size) {
            return views
        }

        views.setTextViewText(
            R.id.tvRow,
            items[position]
        )

        views.setViewVisibility(
            R.id.tvRow,
            View.VISIBLE
        )

        Log.d(
            "WIDGET_DEBUG",
            "row=$position text=${items[position]}"
        )

        return views
    }
}