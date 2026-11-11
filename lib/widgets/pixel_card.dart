import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';
import '../core/theme/pixel_borders.dart';

class PixelCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color? glowColor;
  final EdgeInsetsGeometry padding;

  const PixelCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.backgroundColor = VibesTheme.obsidianSlate,
    this.borderColor = VibesTheme.surfaceBorder,
    this.glowColor,
    this.padding = const EdgeInsets.all(14.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glowColor != null
          ? PixelBorders.activeNeonContainer(
              backgroundColor: backgroundColor,
              neonColor: glowColor!,
            )
          : PixelBorders.container(
              backgroundColor: backgroundColor,
              borderColor: borderColor,
            ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || trailing != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: VibesTheme.pixelHeadline(
                      fontSize: 12,
                      color: VibesTheme.diamondCyan,
                    ),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 2,
              color: VibesTheme.surfaceBorder,
              margin: const EdgeInsets.only(bottom: 12),
            ),
          ],
          child,
        ],
      ),
    );
  }
}
