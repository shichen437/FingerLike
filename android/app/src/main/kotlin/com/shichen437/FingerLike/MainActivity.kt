package com.shichen437.FingerLike

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.MotionEvent
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mouse_clicker"
    private val OVERLAY_PERMISSION_REQ_CODE = 1234
    
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
            if (!Settings.canDrawOverlays(this)) {
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                try {
                    startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE)
                    Toast.makeText(this, "请授予悬浮窗权限以确保应用正常工作", Toast.LENGTH_LONG).show()
                } catch (e: Exception) {
                    Toast.makeText(this, "无法自动打开权限设置，请手动授予悬浮窗权限", Toast.LENGTH_LONG).show()
                    e.printStackTrace()
                }
            }
        }
    }

    private fun checkPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                try {
                    Toast.makeText(this, "应用需要悬浮窗权限才能正常工作", Toast.LENGTH_LONG).show()
                    
                    try {
                        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                        intent.data = Uri.parse("package:$packageName")
                        startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                        } catch (e2: Exception) {
                            try {
                                startActivity(Intent(Settings.ACTION_SETTINGS))
                                Toast.makeText(this, "请在设置中找到应用并授予悬浮窗权限", Toast.LENGTH_LONG).show()
                            } catch (e3: Exception) {
                                Toast.makeText(this, "无法打开设置，请手动授予权限", Toast.LENGTH_LONG).show()
                                e3.printStackTrace()
                            }
                        }
                    }
                } catch (e: Exception) {
                    Toast.makeText(this, "权限请求失败: ${e.message}", Toast.LENGTH_LONG).show()
                    e.printStackTrace()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OVERLAY_PERMISSION_REQ_CODE) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!Settings.canDrawOverlays(this)) {
                    Toast.makeText(this, "未获得悬浮窗权限，部分功能可能无法正常使用", Toast.LENGTH_LONG).show()
                } else {
                    Toast.makeText(this, "已获得悬浮窗权限", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentPosition" -> {
                    // 获取当前窗口的尺寸
                    val displayMetrics = resources.displayMetrics
                    val screenWidth = displayMetrics.widthPixels
                    val screenHeight = displayMetrics.heightPixels
                    
                    // 如果没有触摸记录，返回屏幕中心点
                    val x = if (lastTouchX < 0) screenWidth / 2f else lastTouchX
                    val y = if (lastTouchY < 0) screenHeight / 2f else lastTouchY
                    
                    result.success(mapOf(
                        "x" to x.toDouble(),
                        "y" to y.toDouble(),
                        "screenWidth" to screenWidth,
                        "screenHeight" to screenHeight
                    ))
                }
                "click" -> {
                    val count = call.argument<Int>("count") ?: 1
                    try {
                        simulateClick(lastTouchX, lastTouchY, count)
                        result.success(null)
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                            !Settings.canDrawOverlays(this)) {
                            Toast.makeText(this, "需要悬浮窗权限才能在其他应用上点击", Toast.LENGTH_SHORT).show()
                            checkPermissions()
                        }
                    } catch (e: Exception) {
                        result.error("CLICK_ERROR", e.message, null)
                    }
                }
                
                "clickAt" -> {
                    val x = call.argument<Double>("x")?.toFloat() ?: 0f
                    val y = call.argument<Double>("y")?.toFloat() ?: 0f
                    try {
                        simulateClick(x, y, 1)
                        result.success(null)
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                            !Settings.canDrawOverlays(this)) {
                            Toast.makeText(this, "需要悬浮窗权限才能在其他应用上点击", Toast.LENGTH_SHORT).show()
                            checkPermissions()
                        }
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
                
                println("Touch event: action=${event.action}, rawX=${event.rawX}, rawY=${event.rawY}")
            }
        }
        return super.onTouchEvent(event)
    }

    private fun simulateClick(x: Float, y: Float, count: Int) {
        val service = ClickerAccessibilityService.getInstance()
        if (service == null) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
            throw Exception("请开启无障碍服务")
        }

        for (i in 0 until count) {
            service.performClick(x, y) { success ->
                if (!success) {
                    println("Click failed at ($x, $y)")
                }
            }
            if (i < count - 1) {
                Thread.sleep(50)
            }
        }
    }
}
