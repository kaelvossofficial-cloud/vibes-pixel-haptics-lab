import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/waveform_config.dart';

class TelemetryRecord {
  final DateTime timestamp;
  final WaveformConfig config;

  const TelemetryRecord({
    required this.timestamp,
    required this.config,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'frequency_hz': config.frequency,
      'amplitude_pct': (config.amplitude * 100).round(),
      'waveform_type': config.type.name,
      'period_ms': double.parse(config.periodMs.toStringAsFixed(2)),
      'estimated_g_force': double.parse(config.estimatedGForce.toStringAsFixed(2)),
      'duty_cycle': config.dutyCycle,
      'is_hardware_resonant': config.isHardwareResonant,
    };
  }
}

class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  final List<TelemetryRecord> _records = [];

  List<TelemetryRecord> get records => List.unmodifiable(_records);

  void logEvent(WaveformConfig config) {
    _records.insert(0, TelemetryRecord(timestamp: DateTime.now(), config: config));
    if (_records.length > 100) {
      _records.removeLast();
    }
  }

  void clearLogs() {
    _records.clear();
  }

  /// Exports current vibration profile and log history as JSON formatted string
  String generateJsonExport(WaveformConfig activeConfig) {
    final Map<String, dynamic> exportData = {
      'app': 'VIBES: The Pixel Haptics Lab',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'active_profile': activeConfig.toJson(),
      'pulse_sequence_sample': _generatePulseSequence(activeConfig),
      'telemetry_history': _records.map((r) => r.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Generates millisecond pulse sequence preview array
  List<Map<String, dynamic>> _generatePulseSequence(WaveformConfig config) {
    final List<Map<String, dynamic>> sequence = [];
    final int samplePoints = 20;
    final double step = (config.burstDurationMs / samplePoints);

    for (int i = 0; i < samplePoints; i++) {
      final double timeMs = i * step;
      final double t = timeMs / 1000.0;
      final double amplitude = (config.sampleAt(t).abs() * config.amplitude * 255.0);
      sequence.add({
        'time_ms': timeMs.round(),
        'intensity_byte': amplitude.round().clamp(0, 255),
      });
    }
    return sequence;
  }

  /// Exports telemetry history as CSV string
  String generateCsvExport(WaveformConfig activeConfig) {
    final StringBuffer csv = StringBuffer();
    csv.writeln('timestamp,waveform_type,frequency_hz,amplitude_pct,period_ms,estimated_g_force,is_resonant');

    // Include current profile
    final now = DateTime.now().toIso8601String();
    csv.writeln(
      '$now,${activeConfig.type.name},${activeConfig.frequency.toStringAsFixed(1)},${(activeConfig.amplitude * 100).round()},${activeConfig.periodMs.toStringAsFixed(2)},${activeConfig.estimatedGForce.toStringAsFixed(2)},${activeConfig.isHardwareResonant}',
    );

    // Include recorded history
    for (final r in _records) {
      csv.writeln(
        '${r.timestamp.toIso8601String()},${r.config.type.name},${r.config.frequency.toStringAsFixed(1)},${(r.config.amplitude * 100).round()},${r.config.periodMs.toStringAsFixed(2)},${r.config.estimatedGForce.toStringAsFixed(2)},${r.config.isHardwareResonant}',
      );
    }

    return csv.toString();
  }

  /// Writes export file to device and triggers the OS share sheet
  Future<void> shareTelemetryFile({
    required WaveformConfig activeConfig,
    required bool isJson,
  }) async {
    final String content = isJson
        ? generateJsonExport(activeConfig)
        : generateCsvExport(activeConfig);

    final String extension = isJson ? 'json' : 'csv';
    final String timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = 'vibes_profile_$timestampStr.$extension';

    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'VIBES Profile Export ($fileName)',
      text: 'Exported haptic profile from VIBES: The Pixel Haptics Lab',
    );
  }
}
