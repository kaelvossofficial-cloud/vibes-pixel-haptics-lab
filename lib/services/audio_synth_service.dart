import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import '../models/waveform_config.dart';

class AudioSynthService {
  static final AudioSynthService _instance = AudioSynthService._internal();
  factory AudioSynthService() => _instance;
  AudioSynthService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Timer? _loopTimer;

  bool get isPlaying => _isPlaying;

  Future<void> initialize() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Synthesizes and plays a pure tone audio buffer synchronized with the waveform
  Future<void> playSynthesizedTone(WaveformConfig config) async {
    await stop();
    _isPlaying = true;

    final Uint8List wavBytes = generateWavBuffer(
      config: config,
      sampleRate: 22050, // Lightweight retro sample rate
    );

    try {
      if (config.isLooping) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      }

      await _audioPlayer.play(BytesSource(wavBytes));
    } catch (e) {
      // In testing environments or when audio sink is unavailable
      print('Audio playback notice: $e');
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _loopTimer?.cancel();
    _loopTimer = null;
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  /// Synthesizes 16-bit Mono PCM WAV in memory
  Uint8List generateWavBuffer({
    required WaveformConfig config,
    int sampleRate = 22050,
  }) {
    // Generate duration based on config
    final double durationSeconds = (config.burstDurationMs / 1000.0).clamp(0.1, 2.0);
    final int numSamples = (durationSeconds * sampleRate).toInt();
    final int byteRate = sampleRate * 1 * 2; // sampleRate * channels * (bitsPerSample/8)
    final int blockAlign = 1 * 2; // channels * (bitsPerSample/8)
    final int subChunk2Size = numSamples * 2;
    final int chunkSize = 36 + subChunk2Size;

    final ByteData byteData = ByteData(44 + subChunk2Size);

    // RIFF chunk descriptor
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // "fmt " sub-chunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16-bit)

    // "data" sub-chunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, subChunk2Size, Endian.little);

    // Write PCM samples with smooth attack & decay envelope to prevent audio pops
    final double maxAmplitude16Bit = 32767.0 * config.amplitude.clamp(0.0, 1.0);
    final int attackSamples = (sampleRate * 0.015).toInt(); // 15ms attack
    final int decaySamples = (sampleRate * 0.025).toInt();  // 25ms decay

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double rawSample = config.sampleAt(t);

      // Amplitude envelope
      double envelope = 1.0;
      if (i < attackSamples) {
        envelope = i / attackSamples;
      } else if (i > numSamples - decaySamples) {
        envelope = (numSamples - i) / decaySamples;
      }

      final int sampleValue = (rawSample * maxAmplitude16Bit * envelope).clamp(-32768.0, 32767.0).toInt();
      byteData.setInt16(44 + (i * 2), sampleValue, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
