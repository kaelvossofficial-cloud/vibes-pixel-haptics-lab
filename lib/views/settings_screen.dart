import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';
import '../widgets/pixel_card.dart';
import '../widgets/pixel_badge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibesTheme.deepVoid,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM CONFIG',
                    style: VibesTheme.pixelHeadline(
                      fontSize: 16,
                      color: VibesTheme.pixelWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'HARDWARE DIAGNOSTICS & SPECS',
                    style: VibesTheme.monoLabel(
                      fontSize: 10,
                      color: VibesTheme.mutedStone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Diagnostics
              PixelCard(
                title: 'ACTUATOR DIAGNOSTICS',
                child: Column(
                  children: [
                    _buildDiagRow('ACTUATOR TYPE', 'Linear Resonant (LRA)', VibesTheme.emeraldXP),
                    _buildDivider(),
                    _buildDiagRow('NATIVE CHANNELS', 'VibrationEffect API', VibesTheme.diamondCyan),
                    _buildDivider(),
                    _buildDiagRow('AUDIO BUFFER', '16-Bit PCM / 22.05 kHz', VibesTheme.pixelWhite),
                    _buildDivider(),
                    _buildDiagRow('RESONANCE WINDOW', '150 Hz - 250 Hz', VibesTheme.goldNugget),
                    _buildDivider(),
                    _buildDiagRow('LATENCY PROFILE', '< 12 ms Low-Latency', VibesTheme.emeraldXP),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Acoustic & Haptic Guide
              PixelCard(
                title: 'PHYSICS TESTER HANDBOOK',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOW MOTOR RESONANCE WORKS:',
                      style: VibesTheme.pixelHeadline(fontSize: 11, color: VibesTheme.diamondCyan),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Smartphone haptic engines rely on spring-mass mechanical systems. When driven at their natural resonant frequency (typically 170-230 Hz), output acceleration spikes by up to 240% with minimal power consumption.',
                      style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.pixelWhite.withOpacity(0.85)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'WAVEFORM CHARACTERISTICS:',
                      style: VibesTheme.pixelHeadline(fontSize: 11, color: VibesTheme.goldNugget),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• SINE: Smooth harmonic vibration, minimal mechanical buzzing.\n'
                      '• SQUARE: High odd harmonic content; creates sharp industrial buzz.\n'
                      '• SAWTOOTH: Directional kinetic sensation with steep jerk (da/dt).\n'
                      '• PULSE TRAIN: Emulates Geiger counters, mechanical switches, and clicks.',
                      style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.pixelWhite.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Build & Version Info
              PixelCard(
                title: 'ABOUT VIBES',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('APP VERSION', style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone)),
                        const PixelBadge(text: 'v1.0.0-RELEASE', color: VibesTheme.emeraldXP),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('BUILD TARGET', style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone)),
                        Text('Flutter 3.x / Android 34 / iOS 17', style: VibesTheme.monoNumeric(fontSize: 11, color: VibesTheme.pixelWhite)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AESTHETIC', style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone)),
                        Text('16-Bit Retro Pixel Sandbox', style: VibesTheme.monoNumeric(fontSize: 11, color: VibesTheme.goldNugget)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone)),
          Text(value, style: VibesTheme.monoNumeric(fontSize: 11, color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: VibesTheme.surfaceBorder,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
