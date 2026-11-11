import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';
import '../services/haptics_service.dart';

class PixelSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String unit;
  final ValueChanged<double> onChanged;
  final Color activeColor;
  final bool isResonantZone;

  const PixelSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.unit,
    required this.onChanged,
    this.activeColor = VibesTheme.emeraldXP,
    this.isResonantZone = false,
  });

  @override
  State<PixelSlider> createState() => _PixelSliderState();
}

class _PixelSliderState extends State<PixelSlider> {
  double _lastTickValue = 0.0;

  void _handleChanged(double val) {
    // Emit micro-tick if value changed by a meaningful step
    if ((val - _lastTickValue).abs() >= ((widget.max - widget.min) / (widget.divisions ?? 50))) {
      _lastTickValue = val;
      HapticsService().playTick();
    }
    widget.onChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  widget.label,
                  style: VibesTheme.monoLabel(fontSize: 12, color: VibesTheme.mutedStone),
                ),
                if (widget.isResonantZone) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: VibesTheme.goldNugget.withOpacity(0.15),
                      border: Border.all(color: VibesTheme.goldNugget, width: 1),
                    ),
                    child: Text(
                      'SWEET SPOT ⚡',
                      style: VibesTheme.monoLabel(
                        fontSize: 9,
                        color: VibesTheme.goldNugget,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: VibesTheme.deepVoid,
                border: Border.all(color: VibesTheme.surfaceBorder, width: 1.5),
              ),
              child: Text(
                '${widget.value.toStringAsFixed(widget.value < 10 ? 1 : 0)} ${widget.unit}',
                style: VibesTheme.monoNumeric(
                  fontSize: 13,
                  color: widget.activeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8.0,
            activeTrackColor: widget.activeColor,
            inactiveTrackColor: VibesTheme.deepVoid,
            thumbColor: widget.activeColor,
            overlayColor: widget.activeColor.withOpacity(0.2),
            thumbShape: const _PixelSliderThumbShape(thumbRadius: 10),
            trackShape: const _PixelSliderTrackShape(),
          ),
          child: Slider(
            value: widget.value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: _handleChanged,
          ),
        ),
      ],
    );
  }
}

class _PixelSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const _PixelSliderThumbShape({required this.thumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(thumbRadius * 2, thumbRadius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Chunky square pixel thumb
    final Rect thumbRect = Rect.fromCenter(
      center: center,
      width: thumbRadius * 1.8,
      height: thumbRadius * 2.2,
    );

    // Hard pixel shadow
    final Rect shadowRect = thumbRect.translate(2.0, 2.0);
    canvas.drawRect(shadowRect, Paint()..color = Colors.black.withOpacity(0.7));

    // Outer pixel border
    canvas.drawRect(thumbRect, Paint()..color = Colors.black);

    // Inner filled body
    final Rect innerRect = thumbRect.deflate(2.0);
    canvas.drawRect(innerRect, Paint()..color = sliderTheme.thumbColor ?? VibesTheme.emeraldXP);

    // Center pixel notch
    final Rect notchRect = Rect.fromCenter(center: center, width: 2.0, height: 8.0);
    canvas.drawRect(notchRect, Paint()..color = Colors.black);
  }
}

class _PixelSliderTrackShape extends RoundedRectSliderTrackShape {
  const _PixelSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Inactive track with border
    final Paint inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor ?? VibesTheme.deepVoid;
    final Paint borderPaint = Paint()
      ..color = VibesTheme.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(trackRect, inactivePaint);
    canvas.drawRect(trackRect, borderPaint);

    // Active track
    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    final Paint activePaint = Paint()..color = sliderTheme.activeTrackColor ?? VibesTheme.emeraldXP;
    canvas.drawRect(activeRect, activePaint);
  }
}
