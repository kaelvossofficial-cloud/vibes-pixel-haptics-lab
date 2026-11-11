import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/vibes_theme.dart';
import '../models/waveform_config.dart';
import '../providers/haptic_lab_provider.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_slider.dart';
import '../widgets/pixel_card.dart';
import '../widgets/pixel_switch.dart';
import '../widgets/pixel_oscilloscope.dart';
import '../widgets/pixel_badge.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lab = context.watch<HapticLabProvider>();
    final config = lab.config;

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
              _buildTerminalHeader(context, lab),
              const SizedBox(height: 12),

              // Live Retro Oscilloscope
              PixelOscilloscope(
                config: config,
                isPlaying: lab.isPlaying,
                height: 155,
              ),
              const SizedBox(height: 16),

              // Primary Action Trigger Bar
              _buildPrimaryControls(context, lab),
              const SizedBox(height: 16),

              // Waveform Type Selector
              _buildWaveformSelector(context, lab),
              const SizedBox(height: 16),

              // Frequency & Amplitude Generators
              _buildGeneratorControls(context, lab),
              const SizedBox(height: 16),

              // Pulse & Duration Configuration
              _buildTimingControls(context, lab),
              const SizedBox(height: 16),

              // Audio-Haptic Sync Switches
              _buildSyncSwitches(context, lab),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalHeader(BuildContext context, HapticLabProvider lab) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VIBES // LAB v1.0',
              style: VibesTheme.pixelHeadline(
                fontSize: 16,
                color: VibesTheme.emeraldXP,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'AUDIO-HAPTIC SYNTHESIZER',
              style: VibesTheme.monoLabel(
                fontSize: 10,
                color: VibesTheme.mutedStone,
              ),
            ),
          ],
        ),
        if (lab.config.isHardwareResonant)
          const PixelBadge(
            text: 'LRA RESONANCE ACTIVE',
            color: VibesTheme.goldNugget,
            icon: Icon(Icons.bolt, size: 12, color: VibesTheme.goldNugget),
          )
        else
          PixelBadge(
            text: lab.isPlaying ? 'TRANSMITTING' : 'IDLE',
            color: lab.isPlaying ? VibesTheme.emeraldXP : VibesTheme.mutedStone,
          ),
      ],
    );
  }

  Widget _buildPrimaryControls(BuildContext context, HapticLabProvider lab) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PixelButton(
            label: lab.isPlaying ? 'VIBING...' : 'TRIGGER PULSE',
            icon: Icon(
              lab.isPlaying ? Icons.graphic_eq : Icons.play_arrow,
              color: Colors.black,
              size: 20,
            ),
            backgroundColor: lab.isPlaying ? VibesTheme.goldNugget : VibesTheme.emeraldXP,
            onPressed: () {
              if (lab.isPlaying) {
                lab.stop();
              } else {
                lab.play();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: PixelButton(
            label: 'HALT',
            icon: const Icon(Icons.stop, color: VibesTheme.pixelWhite, size: 18),
            backgroundColor: VibesTheme.redstone,
            textColor: VibesTheme.pixelWhite,
            borderColor: Colors.black,
            onPressed: lab.isPlaying ? () => lab.stop() : null,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformSelector(BuildContext context, HapticLabProvider lab) {
    return PixelCard(
      title: 'WAVE PATTERN GENERATOR',
      child: Column(
        children: [
          Row(
            children: WaveformType.values.map((type) {
              final bool isSelected = lab.config.type == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: GestureDetector(
                    onTap: () => lab.updateWaveformType(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? VibesTheme.diamondCyan : VibesTheme.deepVoid,
                        border: Border.all(
                          color: isSelected ? Colors.white : VibesTheme.surfaceBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            type.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : VibesTheme.pixelWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type.name.substring(0, 3).toUpperCase(),
                            style: VibesTheme.pixelHeadline(
                              fontSize: 8,
                              color: isSelected ? Colors.black : VibesTheme.mutedStone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratorControls(BuildContext context, HapticLabProvider lab) {
    final config = lab.config;

    return PixelCard(
      title: 'PHYSICS PARAMETERS',
      child: Column(
        children: [
          PixelSlider(
            label: 'FREQUENCY',
            value: config.frequency,
            min: 1.0,
            max: 1000.0,
            divisions: 200,
            unit: 'Hz',
            isResonantZone: config.isHardwareResonant,
            activeColor: config.isHardwareResonant ? VibesTheme.goldNugget : VibesTheme.diamondCyan,
            onChanged: (val) => lab.updateFrequency(val),
          ),
          const SizedBox(height: 14),
          PixelSlider(
            label: 'AMPLITUDE / INTENSITY',
            value: config.amplitude * 100.0,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            unit: '%',
            activeColor: VibesTheme.emeraldXP,
            onChanged: (val) => lab.updateAmplitude(val / 100.0),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingControls(BuildContext context, HapticLabProvider lab) {
    final config = lab.config;

    return PixelCard(
      title: 'TIMING & BURST PROFILE',
      child: Column(
        children: [
          PixelSlider(
            label: 'BURST DURATION',
            value: config.burstDurationMs.toDouble(),
            min: 50.0,
            max: 2000.0,
            divisions: 39,
            unit: 'ms',
            activeColor: VibesTheme.pixelWhite,
            onChanged: (val) => lab.updateBurstDuration(val.toInt()),
          ),
          if (config.type == WaveformType.square || config.type == WaveformType.pulseTrain) ...[
            const SizedBox(height: 14),
            PixelSlider(
              label: 'DUTY CYCLE (PULSE WIDTH)',
              value: config.dutyCycle * 100.0,
              min: 5.0,
              max: 95.0,
              divisions: 18,
              unit: '%',
              activeColor: VibesTheme.goldNugget,
              onChanged: (val) => lab.updateDutyCycle(val / 100.0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncSwitches(BuildContext context, HapticLabProvider lab) {
    return PixelCard(
      title: 'AUDIO-HAPTIC COUPLING',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PixelSwitch(
            label: 'HAPTIC MOTOR',
            value: lab.hapticsEnabled,
            activeColor: VibesTheme.emeraldXP,
            onChanged: (val) => lab.toggleHaptics(val),
          ),
          PixelSwitch(
            label: 'AUDIO SINK',
            value: lab.audioEnabled,
            activeColor: VibesTheme.diamondCyan,
            onChanged: (val) => lab.toggleAudio(val),
          ),
          PixelSwitch(
            label: 'LOOP',
            value: lab.config.isLooping,
            activeColor: VibesTheme.goldNugget,
            onChanged: (val) => lab.toggleLooping(val),
          ),
        ],
      ),
    );
  }
}
