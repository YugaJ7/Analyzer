package com.example.analyzer

import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

data class WidgetRow(
    val id: String,
    val name: String,
    val type: String,
    val done: Boolean,
    val value: String,
    val options: List<String>,
    val unit: String
)

class LargeWidgetFactory(
    private val context: Context
) : RemoteViewsService.RemoteViewsFactory {

    private val items =
        mutableListOf<WidgetRow>()

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
                if (items.size >= 9) {
                    break
                }

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
                    WidgetRow(
                        id = obj.optString("id"),
                        name = name,
                        type = type,
                        done = done,
                        value = value,
                        options = obj.optJSONArray("options")
                            ?.let(::parseOptions)
                            ?: emptyList(),
                        unit = obj.optString("unit", "")
                    )

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
            buildRowText(items[position])
        )

        val fillInIntent =
            Intent().apply {
                putExtra(
                    WidgetActionReceiver.EXTRA_PARAMETER_ID,
                    items[position].id
                )
                putExtra(
                    WidgetActionReceiver.EXTRA_TYPE,
                    items[position].type
                )
            }

        views.setOnClickFillInIntent(
            R.id.rowRoot,
            fillInIntent
        )

        Log.d(
            "WIDGET_DEBUG",
            "row=$position text=${buildRowText(items[position])}"
        )

        return views
    }

    private fun buildRowText(item: WidgetRow): String {
        return when (item.type) {
            "checklist" ->
                if (item.done) {
                    "☑ ${item.name}"
                } else {
                    "☐ ${item.name}"
                }

            "optionSelector" ->
                if (item.value.isBlank()) {
                    // Blank = unselected; show a dash to indicate nothing chosen
                    "${item.name} • —"
                } else {
                    "${item.name} • ${item.value}"
                }

            else ->
                if (item.value.isBlank()) {
                    "${item.name} • Open app"
                } else if (item.unit.isNotBlank()) {
                    "${item.name} • ${item.value} ${item.unit}"
                } else {
                    "${item.name} • ${item.value}"
                }
        }
    }

    private fun parseOptions(array: JSONArray): List<String> {
        val options = mutableListOf<String>()

        for (index in 0 until array.length()) {
            val option = array.optString(index)
            // Allow empty string (blank sentinel for unselect)
            options.add(option)
        }

        return options
    }
}
