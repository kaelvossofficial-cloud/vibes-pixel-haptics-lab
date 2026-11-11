import 'dart:async';
import 'package:flutter/services.dart';
import '../models/waveform_config.dart';

class HapticsService {
  static final HapticsService _instance = HapticsService._internal();
  factory HapticsService() => _instance;
  HapticsService._internal();

  static const MethodChannel _channel = MethodChannel('com.pixelhaptics.vibes/haptics');

  bool _hasCustomVibrations = false;
  bool _hasAmplitudeControl = false;
  bool _isPlaying = false;
  Timer? _loopTimer;

  bool get isPlaying => _isPlaying;

  Future<void> initialize() async {
    try {
      final bool? hasVib = await _channel.invokeMethod<bool>('hasVibrator');
      if (hasVib == true) {
        _hasAmplitudeControl = (await _channel.invokeMethod<bool>('hasAmplitudeControl')) ?? false;
        _hasCustomVibrations = true;
      }
    } catch (e) {
      // Graceful fallback for iOS or web
      _hasCustomVibrations = false;
      _hasAmplitudeControl = false;
    }
  }

  /// Tactile micro-tick when dragging stepped sliders or tapping pixel keys
  Future<void> playTick() async {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Tactile mechanical bump for toggling switches or selecting buttons
  Future<void> playMechanicalClick() async {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Synthesizes and plays vibration profile matching the WaveformConfig
  Future<void> triggerVibration(WaveformConfig config) async {
    await stop();
    _isPlaying = true;

    if (config.isLooping) {
      _startLoop(config);
    } else {
      await _executeBurst(config);
      _isPlaying = false;
    }
  }

  void _startLoop(WaveformConfig config) {
    _executeBurst(config);
    final int intervalMs = config.burstDurationMs > 50 ? config.burstDurationMs : 100;
    _loopTimer = Timer.periodic(Duration(milliseconds: intervalMs + 20), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _executeBurst(config);
    });
  }

  Future<void> _executeBurst(WaveformConfig config) async {
    try {
      final int duration = config.burstDurationMs;
      final int amplitudeInt = (config.amplitude * 255).clamp(1, 255).toInt();

      if (_hasAmplitudeControl) {
        // High-fidelity native Android VibrationEffect pattern with amplitude envelope
        final List<int> timings = [];
        final List<int> amplitudes = [];

        final int stepPeriod = mathMax(8, (config.periodMs).round());
        final int steps = (duration / stepPeriod).clamp(1, 30).toInt();

        for (int i = 0; i < steps; i++) {
          final double t = (i * stepPeriod) / 1000.0;
          final double sample = config.sampleAt(t).abs();
          timings.add(stepPeriod ~/ 2); // active pulse
          amplitudes.add((sample * amplitudeInt).clamp(1, 255).toInt());
          timings.add(stepPeriod ~/ 2); // rest interval
          amplitudes.add(0);
        }

        await _channel.invokeMethod('vibratePattern', {
          'timings': timings,
          'amplitudes': amplitudes,
        });
      } else if (_hasCustomVibrations) {
        await _channel.invokeMethod('vibrate', {
          'duration': duration,
          'amplitude': amplitudeInt,
        });
      } else {
        // Fallback standard platform haptics
        if (config.amplitude > 0.6) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      }
    } catch (e) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _loopTimer?.cancel();
    _loopTimer = null;
    try {
      await _channel.invokeMethod('cancel');
    } catch (_) {
      // Ignore
    }
  }

  int mathMax(int a, int b) => a > b ? a : b;
}
