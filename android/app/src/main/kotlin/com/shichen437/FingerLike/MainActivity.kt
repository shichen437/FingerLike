package com.shichen437.fingerlike

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.MotionEvent
import android.view.View
import android.app.AppOpsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mouse_clicker"
    
    private var lastTouchX: Float = -1f
    private var lastTouchY: Float = -1f

    @SuppressLint("ClickableViewAccessibility")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val rootView = findViewById<View>(android.R.id.content)
        rootView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE, MotionEvent.ACTION_UP -> {
                    lastTouchX = event.rawX
                    lastTouchY = event.rawY
                    println("Touch captured: x=${event.rawX}, y=${event.rawY}")
                }
            }
            false
        }
        
        // 首次启动时检查并申请权限
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            checkAccessibilityService()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentPosition" -> {
                    val displayMetrics = resources.displayMetrics
                    val screenWidth = displayMetrics.widthPixels
                    val screenHeight = displayMetrics.heightPixels

                    val x = if (lastTouchX < 0) screenWidth / 2f else lastTouchX
                    val y = if (lastTouchY < 0) screenHeight / 2f else lastTouchY

                    result.success(mapOf(
                        "x" to x.toDouble(),
                        "y" to y.toDouble(),
                        "screenWidth" to screenWidth,
                        "screenHeight" to screenHeight
                    ))
                }
                "selectCoordinates" -> {
                    runOnUiThread {
                        val dialog = CoordinateSelectorDialog(this) { x, y, confirmed ->
                            if (confirmed) {
                                lastTouchX = x
                                lastTouchY = y
                                result.success(mapOf(
                                    "x" to x.toDouble(),
                                    "y" to y.toDouble(),
                                    "confirmed" to true
                                ))
                            } else {
                                result.success(mapOf(
                                    "confirmed" to false
                                ))
                            }
                        }
                        dialog.show()
                    }
                }
                
                "clickAt" -> {
                    val x = call.argument<Double>("x")?.toFloat() ?: 0f
                    val y = call.argument<Double>("y")?.toFloat() ?: 0f
                    try {
                        simulateClick(x, y)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("CLICK_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE, MotionEvent.ACTION_UP -> {
                lastTouchX = event.rawX
                lastTouchY = event.rawY
            }
        }
        return super.onTouchEvent(event)
    }

    private fun simulateClick(x: Float, y: Float) {
        val service = ClickerAccessibilityService.getInstance()
        if (service == null) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
            throw Exception("请开启无障碍服务")
        }

        service.performClick(x, y) { success ->
            if (!success) {
                println("Click failed at ($x, $y)")
            }
        }
    }

    private fun checkAccessibilityService() {
        val accessibilityEnabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED,
            0
        ) == 1
    
        if (!accessibilityEnabled) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
            val message = if (Locale.getDefault().language == "zh") {
                "请开启无障碍服务"
            } else {
                "Please enable accessibility service"
            }
            Toast.makeText(this, message, Toast.LENGTH_LONG).show()
        }
    }
    
}
