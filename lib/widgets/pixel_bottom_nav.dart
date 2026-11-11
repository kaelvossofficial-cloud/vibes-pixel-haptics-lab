import 'package:flutter/material.dart';
import '../core/theme/vibes_theme.dart';
import '../services/haptics_service.dart';

class PixelBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PixelBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: VibesTheme.deepVoid,
        border: Border(
          top: BorderSide(color: VibesTheme.surfaceBorder, width: 2.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'LAB', '🔬'),
          _buildNavItem(1, 'VAULT', '💎'),
          _buildNavItem(2, 'TELEMETRY', '📊'),
          _buildNavItem(3, 'CONFIG', '⚙️'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconEmoji) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticsService().playTick();
        onTap(index);
      },
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              iconEmoji,
              style: TextStyle(
                fontSize: isSelected ? 20 : 17,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: VibesTheme.pixelHeadline(
                fontSize: 9,
                color: isSelected ? VibesTheme.emeraldXP : VibesTheme.mutedStone,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 2,
              width: 18,
              color: isSelected ? VibesTheme.emeraldXP : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
