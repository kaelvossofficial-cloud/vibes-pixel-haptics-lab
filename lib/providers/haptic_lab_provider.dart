import 'package:flutter/material.dart';
import '../models/waveform_config.dart';
import '../models/preset_item.dart';
import '../core/constants/presets.dart';
import '../services/haptics_service.dart';
import '../services/audio_synth_service.dart';
import '../services/telemetry_service.dart';

class HapticLabProvider extends ChangeNotifier {
  final HapticsService _hapticsService = HapticsService();
  final AudioSynthService _audioSynthService = AudioSynthService();
  final TelemetryService _telemetryService = TelemetryService();

  WaveformConfig _config = const WaveformConfig();
  bool _audioEnabled = true;
  bool _hapticsEnabled = true;
  bool _isPlaying = false;
  PresetItem? _activePreset;
  List<PresetItem> _customPresets = [];

  WaveformConfig get config => _config;
  bool get audioEnabled => _audioEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isPlaying => _isPlaying;
  PresetItem? get activePreset => _activePreset;
  List<PresetItem> get customPresets => _customPresets;
  List<PresetItem> get allVaultPresets => [...VibePresets.curatedVault, ..._customPresets];

  HapticLabProvider() {
    _init();
  }

  Future<void> _init() async {
    await _hapticsService.initialize();
    await _audioSynthService.initialize();
  }

  void updateWaveformType(WaveformType type) {
    _config = _config.copyWith(type: type);
    _hapticsService.playTick();
    notifyListeners();
  }

  void updateFrequency(double freq) {
    _config = _config.copyWith(frequency: freq);
    _hapticsService.playTick();
    notifyListeners();
  }

  void updateAmplitude(double amp) {
    _config = _config.copyWith(amplitude: amp);
    _hapticsService.playTick();
    notifyListeners();
  }

  void updateDutyCycle(double duty) {
    _config = _config.copyWith(dutyCycle: duty);
    _hapticsService.playTick();
    notifyListeners();
  }

  void updateBurstDuration(int durationMs) {
    _config = _config.copyWith(burstDurationMs: durationMs);
    notifyListeners();
  }

  void toggleLooping(bool loop) {
    _config = _config.copyWith(isLooping: loop);
    _hapticsService.playMechanicalClick();
    notifyListeners();
  }

  void toggleAudio(bool enabled) {
    _audioEnabled = enabled;
    _hapticsService.playMechanicalClick();
    if (!_audioEnabled && _isPlaying) {
      _audioSynthService.stop();
    }
    notifyListeners();
  }

  void toggleHaptics(bool enabled) {
    _hapticsEnabled = enabled;
    _hapticsService.playMechanicalClick();
    if (!_hapticsEnabled && _isPlaying) {
      _hapticsService.stop();
    }
    notifyListeners();
  }

  /// Triggers simultaneous audio-haptic synthesis
  Future<void> play() async {
    _isPlaying = true;
    notifyListeners();

    _telemetryService.logEvent(_config);

    final List<Future> futures = [];
    if (_hapticsEnabled) {
      futures.add(_hapticsService.triggerVibration(_config));
    }
    if (_audioEnabled) {
      futures.add(_audioSynthService.playSynthesizedTone(_config));
    }

    if (!_config.isLooping) {
      // Single shot completes after duration
      Future.delayed(Duration(milliseconds: _config.burstDurationMs), () {
        if (!_config.isLooping) {
          _isPlaying = false;
          notifyListeners();
        }
      });
    }

    await Future.wait(futures);
  }

  Future<void> stop() async {
    _isPlaying = false;
    await Future.wait([
      _hapticsService.stop(),
      _audioSynthService.stop(),
    ]);
    notifyListeners();
  }

  void applyPreset(PresetItem preset) {
    _activePreset = preset;
    _config = preset.config;
    _hapticsService.playMechanicalClick();
    notifyListeners();
    play(); // Auto preview preset upon selection
  }

  void saveCurrentAsCustomPreset({
    required String title,
    required String category,
    required String description,
    required String iconEmoji,
  }) {
    final newPreset = PresetItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      description: description,
      config: _config,
      rating: 5.0,
      reviewsCount: 1,
      downloadsCount: 1,
      author: 'Local Crafter',
      iconEmoji: iconEmoji,
    );
    _customPresets.insert(0, newPreset);
    _activePreset = newPreset;
    _hapticsService.playMechanicalClick();
    notifyListeners();
  }

  @override
  void dispose() {
    _hapticsService.stop();
    _audioSynthService.dispose();
    super.dispose();
  }
}
