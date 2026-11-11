package com.pixelhaptics.vibes

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.pixelhaptics.vibes/haptics"

    private fun getVibrator(): Vibrator {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val vibrator = getVibrator()
            when (call.method) {
                "hasVibrator" -> {
                    result.success(vibrator.hasVibrator())
                }
                "hasAmplitudeControl" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        result.success(vibrator.hasAmplitudeControl())
                    } else {
                        result.success(false)
                    }
                }
                "vibrate" -> {
                    val duration = (call.argument<Int>("duration") ?: 400).toLong()
                    val amplitude = call.argument<Int>("amplitude") ?: 255
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        vibrator.vibrate(VibrationEffect.createOneShot(duration, amplitude.coerceIn(1, 255)))
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(duration)
                    }
                    result.success(true)
                }
                "vibratePattern" -> {
                    val timings = call.argument<List<Int>>("timings")?.map { it.toLong() }?.toLongArray()
                    val amplitudes = call.argument<List<Int>>("amplitudes")?.map { it.coerceIn(0, 255) }?.toIntArray()
                    if (timings != null && amplitudes != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
                    } else if (timings != null) {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(timings, -1)
                    }
                    result.success(true)
                }
                "cancel" -> {
                    vibrator.cancel()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
