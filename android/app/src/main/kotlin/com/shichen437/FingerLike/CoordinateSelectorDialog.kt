package com.shichen437.fingerlike

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.view.ViewGroup

class CoordinateSelectorDialog(
    context: Context,
    private val onResult: (Float, Float, Boolean) -> Unit
) : Dialog(context, android.R.style.Theme_Black_NoTitleBar_Fullscreen) {

    private var currentX: Float = 0f
    private var currentY: Float = 0f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        window?.setBackgroundDrawableResource(android.R.color.transparent)
        window?.setDimAmount(0.3f)
        
        setContentView(R.layout.coordinate_selector)
        setCanceledOnTouchOutside(false)
    
        val targetImageView = findViewById<ImageView>(R.id.targetImageView)
        val coordinatesTextView = findViewById<TextView>(R.id.coordinatesTextView)
        val confirmButton = findViewById<Button>(R.id.confirmButton)
        val cancelButton = findViewById<Button>(R.id.cancelButton)
        val rootView = findViewById<View>(android.R.id.content)

        // 初始化坐标为屏幕中心
        val displayMetrics = context.resources.displayMetrics
        currentX = displayMetrics.widthPixels / 2f
        currentY = displayMetrics.heightPixels / 2f
        updateTargetPosition(targetImageView, currentX, currentY)
        coordinatesTextView?.text = "X: ${currentX.toInt()}, Y: ${currentY.toInt()}"

        // 监听整个Dialog区域的触摸事件
        rootView?.setOnTouchListener { _, event ->
            val x = event.rawX
            val y = event.rawY
            when (event.action) {
                MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
                    currentX = x
                    currentY = y
                    updateTargetPosition(targetImageView, x, y)
                    coordinatesTextView?.text = "X: ${x.toInt()}, Y: ${y.toInt()}"
                }
            }
            true
        }

        confirmButton?.setOnClickListener {
            onResult(currentX, currentY, true)
            dismiss()
        }
        cancelButton?.setOnClickListener {
            onResult(0f, 0f, false)
            dismiss()
        }
    }

    private fun updateTargetPosition(targetImageView: ImageView?, x: Float, y: Float) {
        targetImageView?.let {
            val params = it.layoutParams as? ViewGroup.MarginLayoutParams
            if (params != null) {
                params.leftMargin = (x - it.width / 2).toInt()
                params.topMargin = (y - it.height / 2).toInt()
                it.layoutParams = params
            }
        }
    }
}