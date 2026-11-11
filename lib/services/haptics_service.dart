import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../models/waveform_config.dart';

class HapticsService {
  static final HapticsService _instance = HapticsService._internal();
  factory HapticsService() => _instance;
  HapticsService._internal();

  bool _hasCustomVibrations = false;
  bool _hasAmplitudeControl = false;
  bool _isPlaying = false;
  Timer? _loopTimer;

  bool get isPlaying => _isPlaying;

  Future<void> initialize() async {
    try {
      final bool? hasVib = await Vibration.hasVibrator();
      if (hasVib == true) {
        _hasCustomVibrations = (await Vibration.hasCustomVibrationsSupport()) ?? false;
        _hasAmplitudeControl = (await Vibration.hasAmplitudeControl()) ?? false;
      }
    } catch (e) {
      // Graceful fallback for web/desktop/unsupported platforms
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
        // High fidelity platform vibration effect with amplitude control
        // Generate stepped pulse slice pattern based on waveform
        final List<int> pattern = [];
        final List<int> intensities = [];

        final int stepPeriod = mathMax(8, (config.periodMs).round());
        final int steps = (duration / stepPeriod).clamp(1, 30).toInt();

        for (int i = 0; i < steps; i++) {
          final double t = (i * stepPeriod) / 1000.0;
          final double sample = config.sampleAt(t).abs();
          pattern.add(stepPeriod ~/ 2); // active pulse
          intensities.add((sample * amplitudeInt).clamp(1, 255).toInt());
          pattern.add(stepPeriod ~/ 2); // rest interval
          intensities.add(0);
        }

        await Vibration.vibrate(
          pattern: pattern,
          intensities: intensities,
        );
      } else if (_hasCustomVibrations) {
        // Fallback for custom pattern without continuous amplitude
        await Vibration.vibrate(
          duration: duration,
          amplitude: amplitudeInt,
        );
      } else {
        // Fallback standard system haptics
        if (config.amplitude > 0.6) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      }
    } catch (e) {
      // Fallback to basic HapticFeedback if Vibration plugin fails
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _loopTimer?.cancel();
    _loopTimer = null;
    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  int mathMax(int a, int b) => a > b ? a : b;
}
