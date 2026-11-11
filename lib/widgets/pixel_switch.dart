import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';
import '../services/haptics_service.dart';

class PixelSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final Color activeColor;

  const PixelSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor = VibesTheme.emeraldXP,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticsService().playMechanicalClick();
        onChanged(!value);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: VibesTheme.monoLabel(
                fontSize: 12,
                color: value ? VibesTheme.pixelWhite : VibesTheme.mutedStone,
              ),
            ),
            const SizedBox(width: 8),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.fastOutSlowIn,
            width: 48,
            height: 26,
            decoration: BoxDecoration(
              color: VibesTheme.deepVoid,
              border: Border.all(
                color: value ? activeColor : VibesTheme.surfaceBorder,
                width: 2.0,
              ),
              boxShadow: [
                if (value)
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 4,
                  ),
              ],
            ),
            padding: const EdgeInsets.all(2.0),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 120),
              curve: Curves.fastOutSlowIn,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: value ? activeColor : VibesTheme.mutedStone,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    color: value ? Colors.black : Colors.white24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
