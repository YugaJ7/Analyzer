package com.example.analyzer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MidnightResetReceiver : BroadcastReceiver() {

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        WidgetRenderer.refreshAll(context)
        MidnightScheduler.schedule(context)
    }
}