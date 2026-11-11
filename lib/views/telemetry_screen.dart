import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/vibes_theme.dart';
import '../core/theme/pixel_borders.dart';
import '../providers/haptic_lab_provider.dart';
import '../services/telemetry_service.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_card.dart';
import '../widgets/pixel_badge.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  final TelemetryService _telemetryService = TelemetryService();

  @override
  Widget build(BuildContext context) {
    final lab = context.watch<HapticLabProvider>();
    final config = lab.config;
    final records = _telemetryService.records;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHYSICS TELEMETRY',
                        style: VibesTheme.pixelHeadline(
                          fontSize: 16,
                          color: VibesTheme.goldNugget,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'OSCILLATION & G-FORCE LOGS',
                        style: VibesTheme.monoLabel(
                          fontSize: 10,
                          color: VibesTheme.mutedStone,
                        ),
                      ),
                    ],
                  ),
                  PixelBadge(
                    text: '${records.length} EVENTS',
                    color: VibesTheme.goldNugget,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Physics Metrics 2x2 Grid
              _buildPhysicsGrid(context, config),
              const SizedBox(height: 16),

              // Export Data Actions Card
              _buildExportCard(context, config),
              const SizedBox(height: 16),

              // Pulse Train Preview Matrix
              _buildPulseSequenceMatrix(context, config),
              const SizedBox(height: 16),

              // Real-Time Event Log
              _buildEventLogCard(context, records),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicsGrid(BuildContext context, dynamic config) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                label: 'OSCILLATION PERIOD',
                value: '${config.periodMs.toStringAsFixed(2)} ms',
                subtext: 'tau = 1/f',
                accentColor: VibesTheme.diamondCyan,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                label: 'ESTIMATED G-FORCE',
                value: '≈ ${config.estimatedGForce.toStringAsFixed(2)} g',
                subtext: 'LRA Peak Acceleration',
                accentColor: config.isHardwareResonant ? VibesTheme.goldNugget : VibesTheme.emeraldXP,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                label: 'MOTOR COUPLING',
                value: config.isHardwareResonant ? 'RESONANT' : 'SUB-OPTIMAL',
                subtext: 'Sweet spot: 150-250 Hz',
                accentColor: config.isHardwareResonant ? VibesTheme.goldNugget : VibesTheme.mutedStone,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                label: 'ENERGY TRANSFER',
                value: '${((config.amplitude * config.frequency / 10).clamp(1.0, 99.9)).toStringAsFixed(1)} J/s',
                subtext: 'P = A^2 * w^2 model',
                accentColor: VibesTheme.pixelWhite,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: PixelBorders.container(
        backgroundColor: VibesTheme.obsidianSlate,
        borderColor: VibesTheme.surfaceBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: VibesTheme.monoLabel(fontSize: 9, color: VibesTheme.mutedStone),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: VibesTheme.monoNumeric(
              fontSize: 14,
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: VibesTheme.monoLabel(fontSize: 8, color: VibesTheme.mutedStone),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(BuildContext context, dynamic config) {
    return PixelCard(
      title: 'DATA EXPORT & TRANSMISSION',
      child: Column(
        children: [
          Text(
            'Export raw millisecond pulse sequences, frequency vectors, and telemetry captures for MATLAB, Python, or spreadsheet analysis.',
            style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.pixelWhite.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  label: 'EXPORT JSON',
                  icon: const Icon(Icons.code, size: 16, color: Colors.black),
                  backgroundColor: VibesTheme.diamondCyan,
                  textColor: Colors.black,
                  height: 40,
                  onPressed: () async {
                    await _telemetryService.shareTelemetryFile(
                      activeConfig: config,
                      isJson: true,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PixelButton(
                  label: 'EXPORT CSV',
                  icon: const Icon(Icons.table_chart, size: 16, color: Colors.black),
                  backgroundColor: VibesTheme.emeraldXP,
                  textColor: Colors.black,
                  height: 40,
                  onPressed: () async {
                    await _telemetryService.shareTelemetryFile(
                      activeConfig: config,
                      isJson: false,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulseSequenceMatrix(BuildContext context, dynamic config) {
    final int samples = 16;
    final double step = (config.burstDurationMs / samples);

    return PixelCard(
      title: 'TIME-DOMAIN INTENSITY MATRIX',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: List.generate(samples, (i) {
                final double timeMs = i * step;
                final double t = timeMs / 1000.0;
                final double sample = config.sampleAt(t).abs() * config.amplitude;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: (sample * 44).clamp(3.0, 44.0),
                      color: config.isHardwareResonant
                          ? VibesTheme.goldNugget
                          : VibesTheme.emeraldXP,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 ms', style: VibesTheme.monoLabel(fontSize: 9, color: VibesTheme.mutedStone)),
              Text('${(config.burstDurationMs / 2).round()} ms',
                  style: VibesTheme.monoLabel(fontSize: 9, color: VibesTheme.mutedStone)),
              Text('${config.burstDurationMs} ms',
                  style: VibesTheme.monoLabel(fontSize: 9, color: VibesTheme.mutedStone)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventLogCard(BuildContext context, List<TelemetryRecord> records) {
    final DateFormat formatter = DateFormat('HH:mm:ss');

    return PixelCard(
      title: 'EVENT TELEMETRY LOG',
      trailing: GestureDetector(
        onTap: () {
          setState(() {
            _telemetryService.clearLogs();
          });
        },
        child: Text(
          'CLEAR',
          style: VibesTheme.pixelHeadline(fontSize: 9, color: VibesTheme.redstone),
        ),
      ),
      child: records.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'NO PULSES RECORDED YET.\nTRIGGER A VIBE IN THE LAB TO LOG DATA.',
                  textAlign: TextAlign.center,
                  style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.take(10).length,
              separatorBuilder: (_, __) => Container(
                height: 1,
                color: VibesTheme.surfaceBorder,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              itemBuilder: (context, index) {
                final r = records[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            formatter.format(r.timestamp),
                            style: VibesTheme.monoLabel(fontSize: 10, color: VibesTheme.mutedStone),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            r.config.type.name.toUpperCase(),
                            style: VibesTheme.pixelHeadline(fontSize: 9, color: VibesTheme.diamondCyan),
                          ),
                        ],
                      ),
                      Text(
                        '${r.config.frequency.toStringAsFixed(0)} Hz | ${(r.config.amplitude * 100).round()}% | ${r.config.estimatedGForce.toStringAsFixed(2)}g',
                        style: VibesTheme.monoNumeric(fontSize: 11, color: VibesTheme.pixelWhite),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
