package com.example.analyzer

import android.content.Intent
import android.widget.RemoteViewsService

class LargeWidgetService :
    RemoteViewsService() {

    override fun onGetViewFactory(
        intent: Intent
    ): RemoteViewsFactory {

        return LargeWidgetFactory(
            applicationContext
        )
    }
}