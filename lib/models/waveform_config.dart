import 'dart:math' as math;

enum WaveformType {
  sine,
  square,
  triangle,
  sawtooth,
  pulseTrain;

  String get displayName {
    switch (this) {
      case WaveformType.sine:
        return 'SINE';
      case WaveformType.square:
        return 'SQUARE';
      case WaveformType.triangle:
        return 'TRIANGLE';
      case WaveformType.sawtooth:
        return 'SAWTOOTH';
      case WaveformType.pulseTrain:
        return 'PULSE TRAIN';
    }
  }

  String get symbol {
    switch (this) {
      case WaveformType.sine:
        return '∿';
      case WaveformType.square:
        return '⊓';
      case WaveformType.triangle:
        return '△';
      case WaveformType.sawtooth:
        return '⨯';
      case WaveformType.pulseTrain:
        return '|||';
    }
  }
}

class WaveformConfig {
  final WaveformType type;
  final double frequency; // 1.0 Hz - 1000.0 Hz
  final double amplitude; // 0.0 - 1.0 (0% - 100%)
  final double dutyCycle; // 0.05 - 0.95 for pulse trains & square
  final int burstDurationMs; // Duration for single shot (e.g. 500ms)
  final bool isLooping;

  const WaveformConfig({
    this.type = WaveformType.sine,
    this.frequency = 180.0,
    this.amplitude = 0.85,
    this.dutyCycle = 0.5,
    this.burstDurationMs = 600,
    this.isLooping = false,
  });

  /// Period in milliseconds: T = (1 / f) * 1000
  double get periodMs => frequency > 0 ? (1000.0 / frequency) : 0;

  /// Hardware linear resonant actuator (LRA) sweet spot is ~150Hz - 250Hz.
  bool get isHardwareResonant => frequency >= 150.0 && frequency <= 250.0;

  /// Estimated acceleration / G-Force on phone motor
  double get estimatedGForce {
    // Peak mechanical coupling model based on resonance curve
    final double resonanceMultiplier = isHardwareResonant ? 1.45 : 0.85;
    return (amplitude * 1.8 * resonanceMultiplier).clamp(0.0, 3.2);
  }

  /// Calculates value between -1.0 and 1.0 for time t (seconds)
  double sampleAt(double t) {
    final double phase = (t * frequency) % 1.0; // 0.0 to 1.0 normalized phase
    switch (type) {
      case WaveformType.sine:
        return math.sin(2 * math.pi * phase);
      case WaveformType.square:
        return phase < dutyCycle ? 1.0 : -1.0;
      case WaveformType.triangle:
        return phase < 0.5
            ? (4.0 * phase - 1.0)
            : (3.0 - 4.0 * phase);
      case WaveformType.sawtooth:
        return 2.0 * phase - 1.0;
      case WaveformType.pulseTrain:
        // Sharp impulsive bursts
        return phase < (dutyCycle * 0.3) ? 1.0 : 0.0;
    }
  }

  WaveformConfig copyWith({
    WaveformType? type,
    double? frequency,
    double? amplitude,
    double? dutyCycle,
    int? burstDurationMs,
    bool? isLooping,
  }) {
    return WaveformConfig(
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      amplitude: amplitude ?? this.amplitude,
      dutyCycle: dutyCycle ?? this.dutyCycle,
      burstDurationMs: burstDurationMs ?? this.burstDurationMs,
      isLooping: isLooping ?? this.isLooping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'frequency_hz': frequency,
      'amplitude_pct': (amplitude * 100).round(),
      'duty_cycle': dutyCycle,
      'burst_duration_ms': burstDurationMs,
      'is_looping': isLooping,
      'period_ms': periodMs,
      'is_hardware_resonant': isHardwareResonant,
      'estimated_g_force': double.parse(estimatedGForce.toStringAsFixed(2)),
    };
  }

  factory WaveformConfig.fromJson(Map<String, dynamic> json) {
    return WaveformConfig(
      type: WaveformType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WaveformType.sine,
      ),
      frequency: (json['frequency_hz'] as num?)?.toDouble() ?? 180.0,
      amplitude: ((json['amplitude_pct'] as num?)?.toDouble() ?? 85.0) / 100.0,
      dutyCycle: (json['duty_cycle'] as num?)?.toDouble() ?? 0.5,
      burstDurationMs: (json['burst_duration_ms'] as num?)?.toInt() ?? 600,
      isLooping: json['is_looping'] as bool? ?? false,
    );
  }
}
