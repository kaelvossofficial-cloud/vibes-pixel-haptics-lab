import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';
import '../models/waveform_config.dart';

class PixelOscilloscope extends StatefulWidget {
  final WaveformConfig config;
  final bool isPlaying;
  final double height;

  const PixelOscilloscope({
    super.key,
    required this.config,
    required this.isPlaying,
    this.height = 160.0,
  });

  @override
  State<PixelOscilloscope> createState() => _PixelOscilloscopeState();
}

class _PixelOscilloscopeState extends State<PixelOscilloscope>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0B10), // Deep CRT black
            border: Border.all(
              color: widget.isPlaying
                  ? (widget.config.isHardwareResonant
                      ? VibesTheme.goldNugget
                      : VibesTheme.emeraldXP)
                  : VibesTheme.surfaceBorder,
              width: 2.0,
            ),
            boxShadow: [
              if (widget.isPlaying)
                BoxShadow(
                  color: (widget.config.isHardwareResonant
                          ? VibesTheme.goldNugget
                          : VibesTheme.emeraldXP)
                      .withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _OscilloscopePainter(
                  config: widget.config,
                  isPlaying: widget.isPlaying,
                  phaseOffset: _animController.value,
                ),
              ),
              // Corner Readout HUD
              Positioned(
                top: 8,
                left: 10,
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      color: widget.isPlaying ? VibesTheme.emeraldXP : VibesTheme.mutedStone,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isPlaying ? 'OSC LIVE: SYNC' : 'OSC STANDBY',
                      style: VibesTheme.monoLabel(
                        fontSize: 10,
                        color: widget.isPlaying ? VibesTheme.emeraldXP : VibesTheme.mutedStone,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 10,
                child: Text(
                  '${widget.config.frequency.toStringAsFixed(0)} Hz | ${(widget.config.amplitude * 100).round()}%',
                  style: VibesTheme.monoNumeric(
                    fontSize: 11,
                    color: VibesTheme.diamondCyan,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 10,
                child: Text(
                  'T = ${widget.config.periodMs.toStringAsFixed(2)} ms',
                  style: VibesTheme.monoLabel(
                    fontSize: 10,
                    color: VibesTheme.pixelWhite.withOpacity(0.7),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Text(
                  'G ≈ ${widget.config.estimatedGForce.toStringAsFixed(2)} g',
                  style: VibesTheme.monoLabel(
                    fontSize: 10,
                    color: widget.config.isHardwareResonant
                        ? VibesTheme.goldNugget
                        : VibesTheme.pixelWhite.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OscilloscopePainter extends CustomPainter {
  final WaveformConfig config;
  final bool isPlaying;
  final double phaseOffset;

  _OscilloscopePainter({
    required this.config,
    required this.isPlaying,
    required this.phaseOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawRetroGrid(canvas, size);
    _drawWaveform(canvas, size);
  }

  void _drawRetroGrid(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E2838).withOpacity(0.4)
      ..strokeWidth = 1.0;

    final Paint centerLinePaint = Paint()
      ..color = const Color(0xFF2E3D52).withOpacity(0.6)
      ..strokeWidth = 1.0;

    // Vertical subdivisions
    const int vDivisions = 12;
    final double vStep = size.width / vDivisions;
    for (int i = 0; i <= vDivisions; i++) {
      final double x = i * vStep;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        i == (vDivisions ~/ 2) ? centerLinePaint : gridPaint,
      );
    }

    // Horizontal subdivisions
    const int hDivisions = 6;
    final double hStep = size.height / hDivisions;
    for (int j = 0; j <= hDivisions; j++) {
      final double y = j * hStep;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        j == (hDivisions ~/ 2) ? centerLinePaint : gridPaint,
      );
    }
  }

  void _drawWaveform(Canvas canvas, Size size) {
    final double midY = size.height / 2.0;
    final double maxWaveHeight = (size.height / 2.0) * 0.85;
    final Color traceColor = config.isHardwareResonant
        ? VibesTheme.goldNugget
        : VibesTheme.emeraldXP;

    // Glowing beam paint
    final Paint glowPaint = Paint()
      ..color = traceColor.withOpacity(isPlaying ? 0.45 : 0.2)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    // Sharp pixel trace paint
    final Paint tracePaint = Paint()
      ..color = traceColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final int resolution = size.width.toInt();

    // Scale wave display across screen width (e.g. 2 to 4 full periods visible)
    final double visiblePeriods = (config.frequency / 35.0).clamp(1.5, 6.0);
    final double speedFactor = isPlaying ? (phaseOffset * 2.0 * math.pi) : 0.0;

    bool firstPoint = true;

    for (int x = 0; x <= resolution; x += 2) {
      final double normalizedX = x / size.width;
      final double t = (normalizedX * visiblePeriods) + (speedFactor / (2 * math.pi));
      final double sample = config.sampleAt(t);

      final double y = midY - (sample * config.amplitude * maxWaveHeight);

      if (firstPoint) {
        path.moveTo(x.toDouble(), y);
        firstPoint = false;
      } else {
        path.lineTo(x.toDouble(), y);
      }
    }

    // Draw phosphor glow then sharp beam
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, tracePaint);
  }

  @override
  bool shouldRepaint(covariant _OscilloscopePainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.phaseOffset != phaseOffset;
  }
}
