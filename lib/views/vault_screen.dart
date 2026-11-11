import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/vibes_theme.dart';
import '../models/preset_item.dart';
import '../providers/haptic_lab_provider.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_badge.dart';
import '../widgets/pixel_card.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    '16-Bit Gaming',
    'Seismic & Physics',
    'Biological',
    'Mechanical Switches',
    'Sci-Fi & Cybernetics',
  ];

  @override
  Widget build(BuildContext context) {
    final lab = context.watch<HapticLabProvider>();
    final presets = lab.allVaultPresets.where((p) {
      if (_selectedCategory == 'ALL') return true;
      return p.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: VibesTheme.deepVoid,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRESET VAULT',
                        style: VibesTheme.pixelHeadline(
                          fontSize: 16,
                          color: VibesTheme.diamondCyan,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CURATED TACTILE PROFILES',
                        style: VibesTheme.monoLabel(
                          fontSize: 10,
                          color: VibesTheme.mutedStone,
                        ),
                      ),
                    ],
                  ),
                  PixelButton(
                    label: '+ NEW',
                    height: 36,
                    backgroundColor: VibesTheme.diamondCyan,
                    textColor: Colors.black,
                    onPressed: () => _showCreatePresetDialog(context, lab),
                  ),
                ],
              ),
            ),

            // Category Filter Bar
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? VibesTheme.diamondCyan : VibesTheme.obsidianSlate,
                        border: Border.all(
                          color: isSelected ? Colors.white : VibesTheme.surfaceBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: VibesTheme.pixelHeadline(
                            fontSize: 9,
                            color: isSelected ? Colors.black : VibesTheme.pixelWhite,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Presets List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                physics: const BouncingScrollPhysics(),
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final bool isCurrent = lab.activePreset?.id == preset.id;
                  return _buildPresetCard(context, preset, isCurrent, lab);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    PresetItem preset,
    bool isCurrent,
    HapticLabProvider lab,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      child: PixelCard(
        borderColor: isCurrent ? VibesTheme.emeraldXP : VibesTheme.surfaceBorder,
        glowColor: isCurrent ? VibesTheme.emeraldXP : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pixel Avatar / Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: VibesTheme.deepVoid,
                    border: Border.all(color: VibesTheme.surfaceBorder, width: 2.0),
                  ),
                  child: Center(
                    child: Text(
                      preset.iconEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              preset.title,
                              style: VibesTheme.pixelHeadline(
                                fontSize: 13,
                                color: VibesTheme.pixelWhite,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PixelBadge(
                            text: '${preset.config.frequency.toStringAsFixed(0)} Hz',
                            color: VibesTheme.diamondCyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'BY @${preset.author}',
                            style: VibesTheme.monoLabel(
                              fontSize: 10,
                              color: VibesTheme.mutedStone,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '★ ${preset.rating.toStringAsFixed(1)}',
                            style: VibesTheme.monoNumeric(
                              fontSize: 10,
                              color: VibesTheme.goldNugget,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '↓ ${preset.downloadsCount}',
                            style: VibesTheme.monoLabel(
                              fontSize: 10,
                              color: VibesTheme.mutedStone,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              preset.description,
              style: VibesTheme.monoLabel(
                fontSize: 11,
                color: VibesTheme.pixelWhite.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PixelButton(
                    label: 'TEST VIBE ⚡',
                    height: 36,
                    backgroundColor: VibesTheme.emeraldXP,
                    textColor: Colors.black,
                    onPressed: () {
                      lab.applyPreset(preset);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PixelButton(
                    label: isCurrent ? 'LOADED ✓' : 'EDIT IN LAB',
                    height: 36,
                    isSecondary: true,
                    onPressed: () {
                      lab.applyPreset(preset);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Preset "${preset.title}" transferred to Synthesis Lab!',
                            style: VibesTheme.monoLabel(fontSize: 12, color: VibesTheme.emeraldXP),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePresetDialog(BuildContext context, HapticLabProvider lab) {
    final titleController = TextEditingController(text: 'Custom Vibe');
    final descController = TextEditingController(text: 'Synthesized physics haptic profile.');
    String selectedEmoji = '⚡';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: VibesTheme.obsidianSlate,
          shape: const BeveledRectangleBorder(
            side: BorderSide(color: VibesTheme.diamondCyan, width: 2.0),
          ),
          title: Text(
            'CAPTURE TO VAULT',
            style: VibesTheme.pixelHeadline(fontSize: 14, color: VibesTheme.diamondCyan),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Lab settings (${lab.config.type.displayName} @ ${lab.config.frequency.toStringAsFixed(0)} Hz) will be saved.',
                style: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                style: VibesTheme.monoNumeric(fontSize: 13, color: VibesTheme.pixelWhite),
                decoration: InputDecoration(
                  labelText: 'PRESET NAME',
                  labelStyle: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone),
                  filled: true,
                  fillColor: VibesTheme.deepVoid,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                style: VibesTheme.monoNumeric(fontSize: 13, color: VibesTheme.pixelWhite),
                decoration: InputDecoration(
                  labelText: 'DESCRIPTION',
                  labelStyle: VibesTheme.monoLabel(fontSize: 11, color: VibesTheme.mutedStone),
                  filled: true,
                  fillColor: VibesTheme.deepVoid,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['⚡', '🕹️', '🌊', '🔥', '🤖', '👾'].map((emoji) {
                  final isChosen = selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setDlgState(() => selectedEmoji = emoji),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isChosen ? VibesTheme.diamondCyan.withOpacity(0.3) : Colors.transparent,
                        border: Border.all(
                          color: isChosen ? VibesTheme.diamondCyan : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: VibesTheme.pixelHeadline(fontSize: 11, color: VibesTheme.mutedStone)),
            ),
            PixelButton(
              label: 'SAVE',
              height: 36,
              backgroundColor: VibesTheme.diamondCyan,
              textColor: Colors.black,
              onPressed: () {
                lab.saveCurrentAsCustomPreset(
                  title: titleController.text.trim().isEmpty ? 'Custom Vibe' : titleController.text.trim(),
                  category: 'User Custom',
                  description: descController.text.trim(),
                  iconEmoji: selectedEmoji,
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
