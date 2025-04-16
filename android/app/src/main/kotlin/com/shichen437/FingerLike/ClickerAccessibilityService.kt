package com.shichen437.FingerLike

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.view.accessibility.AccessibilityEvent

class ClickerAccessibilityService : AccessibilityService() {
    companion object {
        private var instance: ClickerAccessibilityService? = null
        
        fun getInstance(): ClickerAccessibilityService? = instance
    }

    override fun onServiceConnected() {
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}

    override fun onInterrupt() {}

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    fun performClick(x: Float, y: Float, callback: ((Boolean) -> Unit)? = null) {
        val path = Path()
        path.moveTo(x, y)
        
        val gestureBuilder = GestureDescription.Builder()
        val gesture = gestureBuilder
            .addStroke(GestureDescription.StrokeDescription(path, 0, 100))
            .build()
        
        dispatchGesture(gesture, object : AccessibilityService.GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription) {
                callback?.invoke(true)
            }
            
            override fun onCancelled(gestureDescription: GestureDescription) {
                callback?.invoke(false)
            }
        }, null)
    }
}