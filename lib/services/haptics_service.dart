import 'dart:async';
import 'package:flutter/services.dart';
import '../models/waveform_config.dart';

class HapticsService {
  static final HapticsService _instance = HapticsService._internal();
  factory HapticsService() => _instance;
  HapticsService._internal();

  bool _isPlaying = false;
  Timer? _loopTimer;

  bool get isPlaying => _isPlaying;

  Future<void> initialize() async {
    // Native framework haptics ready
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
      if (config.amplitude > 0.7) {
        await HapticFeedback.heavyImpact();
      } else if (config.amplitude > 0.35) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.lightImpact();
      }

      // If burst duration is long, pulse again after period
      if (config.burstDurationMs > 150) {
        final int steps = (config.burstDurationMs / 120).clamp(1, 4).toInt();
        for (int i = 1; i < steps; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!_isPlaying) break;
          if (config.amplitude > 0.5) {
            await HapticFeedback.mediumImpact();
          } else {
            await HapticFeedback.lightImpact();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    _isPlaying = false;
    _loopTimer?.cancel();
    _loopTimer = null;
  }
}
