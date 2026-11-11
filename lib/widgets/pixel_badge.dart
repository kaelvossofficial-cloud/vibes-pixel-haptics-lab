import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';

class PixelBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? backgroundColor;
  final Widget? icon;

  const PixelBadge({
    super.key,
    required this.text,
    this.color = VibesTheme.diamondCyan,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: VibesTheme.monoLabel(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
