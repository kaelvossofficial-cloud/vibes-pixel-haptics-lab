import 'waveform_config.dart';

class PresetItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final WaveformConfig config;
  final double rating; // e.g. 4.9
  final int reviewsCount;
  final int downloadsCount;
  final String author;
  final String iconEmoji;

  const PresetItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.config,
    this.rating = 4.8,
    this.reviewsCount = 42,
    this.downloadsCount = 1337,
    this.author = "PixelLab",
    this.iconEmoji = "⚡",
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'config': config.toJson(),
      'rating': rating,
      'reviews_count': reviewsCount,
      'downloads_count': downloadsCount,
      'author': author,
      'icon_emoji': iconEmoji,
    };
  }

  factory PresetItem.fromJson(Map<String, dynamic> json) {
    return PresetItem(
      id: json['id'] as String? ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Custom Preset',
      category: json['category'] as String? ?? 'User Custom',
      description: json['description'] as String? ?? '',
      config: WaveformConfig.fromJson(json['config'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 1,
      downloadsCount: (json['downloads_count'] as num?)?.toInt() ?? 1,
      author: json['author'] as String? ?? 'Explorer',
      iconEmoji: json['icon_emoji'] as String? ?? '🕹️',
    );
  }
}
