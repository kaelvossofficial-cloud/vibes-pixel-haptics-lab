import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';
import '../services/haptics_service.dart';

class PixelButton extends StatefulWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double height;
  final double? width;
  final bool isDepressed;
  final bool isSecondary;

  const PixelButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor = VibesTheme.emeraldXP,
    this.borderColor = Colors.black,
    this.textColor = Colors.black,
    this.height = 48.0,
    this.width,
    this.isDepressed = false,
    this.isSecondary = false,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressedDown = false;

  @override
  Widget build(BuildContext context) {
    final bool activePressed = _isPressedDown || widget.isDepressed;
    final double depth = activePressed ? 1.0 : 4.0;
    final double topMargin = activePressed ? 3.0 : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressedDown = true);
          HapticsService().playTick();
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressedDown = false);
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        setState(() => _isPressedDown = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.fastOutSlowIn,
        margin: EdgeInsets.only(top: topMargin, bottom: 4.0 - topMargin),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? VibesTheme.surfaceBorder
              : (widget.isSecondary ? VibesTheme.obsidianSlate : widget.backgroundColor),
          border: Border.all(
            color: widget.isSecondary ? VibesTheme.surfaceBorder : widget.borderColor,
            width: 2.0,
          ),
          boxShadow: [
            if (!activePressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.85),
                offset: Offset(depth, depth),
                blurRadius: 0,
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: VibesTheme.pixelHeadline(
                fontSize: 13,
                color: widget.onPressed == null
                    ? VibesTheme.mutedStone
                    : (widget.isSecondary ? VibesTheme.pixelWhite : widget.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
