package com.toolhub.app

import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "toolhub/flashlight"
    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        cameraId = cameraManager?.cameraIdList?.firstOrNull { id ->
            cameraManager?.getCameraCharacteristics(id)
                ?.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "turnOn" -> {
                    try {
                        cameraId?.let { cameraManager?.setTorchMode(it, true) }
                        result.success(null)
                    } catch (e: Exception) { result.error("ERROR", e.message, null) }
                }
                "turnOff" -> {
                    try {
                        cameraId?.let { cameraManager?.setTorchMode(it, false) }
                        result.success(null)
                    } catch (e: Exception) { result.error("ERROR", e.message, null) }
                }
                else -> result.notImplemented()
            }
        }
    }
}
