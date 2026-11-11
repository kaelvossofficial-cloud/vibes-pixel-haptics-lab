import 'package:flutter_test/flutter_test.dart';
import 'package:vibes_app/models/waveform_config.dart';
import 'package:vibes_app/models/preset_item.dart';
import 'package:vibes_app/core/constants/presets.dart';

void main() {
  group('WaveformConfig Math & Physics Tests', () {
    test('Sine wave sampling bounds are between -1.0 and 1.0', () {
      const config = WaveformConfig(
        type: WaveformType.sine,
        frequency: 200.0,
        amplitude: 1.0,
      );

      for (double t = 0.0; t <= 0.05; t += 0.001) {
        final sample = config.sampleAt(t);
        expect(sample, greaterThanOrEqualTo(-1.0));
        expect(sample, lessThanOrEqualTo(1.0));
      }
    });

    test('Period calculation matches T = 1000 / f', () {
      const config = WaveformConfig(frequency: 250.0);
      expect(config.periodMs, equals(4.0)); // 1000 / 250 = 4ms
    });

    test('Resonance detection identifies LRA hardware sweet spot (150-250 Hz)', () {
      const resonantConfig = WaveformConfig(frequency: 180.0);
      const lowConfig = WaveformConfig(frequency: 60.0);
      const highConfig = WaveformConfig(frequency: 500.0);

      expect(resonantConfig.isHardwareResonant, isTrue);
      expect(lowConfig.isHardwareResonant, isFalse);
      expect(highConfig.isHardwareResonant, isFalse);
    });

    test('WaveformConfig JSON round-trip serialization maintains data integrity', () {
      const original = WaveformConfig(
        type: WaveformType.sawtooth,
        frequency: 160.0,
        amplitude: 0.95,
        dutyCycle: 0.45,
        burstDurationMs: 400,
        isLooping: true,
      );

      final json = original.toJson();
      final reconstituted = WaveformConfig.fromJson(json);

      expect(reconstituted.type, equals(WaveformType.sawtooth));
      expect(reconstituted.frequency, equals(160.0));
      expect(reconstituted.amplitude, closeTo(0.95, 0.01));
      expect(reconstituted.burstDurationMs, equals(400));
      expect(reconstituted.isLooping, isTrue);
    });

    test('Curated presets are present and contain valid configurations', () {
      expect(VibePresets.curatedVault.isNotEmpty, isTrue);

      final seismic = VibePresets.curatedVault.firstWhere((p) => p.id == 'seismic_shock');
      expect(seismic.title, equals('Seismic Shock'));
      expect(seismic.config.frequency, equals(45.0));

      final redstone = VibePresets.curatedVault.firstWhere((p) => p.id == 'redstone_clock');
      expect(redstone.title, equals('Redstone Clock'));
      expect(redstone.config.type, equals(WaveformType.square));
    });
  });
}
