import 'dart:ui';

/// Canvas size presets for quick canvas creation
class CanvasPreset {
  final String name;
  final Size size;
  final String category; // 'screen', 'print', 'social'
  final String description;

  const CanvasPreset({
    required this.name,
    required this.size,
    required this.category,
    required this.description,
  });

  /// Screen/Digital presets
  static const hdLandscape = CanvasPreset(
    name: 'HD Landscape',
    size: Size(1920, 1080),
    category: 'screen',
    description: '1920×1080 px',
  );

  static const hdPortrait = CanvasPreset(
    name: 'HD Portrait',
    size: Size(1080, 1920),
    category: 'screen',
    description: '1080×1920 px',
  );

  static const square2k = CanvasPreset(
    name: 'Square 2K',
    size: Size(2000, 2000),
    category: 'screen',
    description: '2000×2000 px',
  );

  static const fourK = CanvasPreset(
    name: '4K Landscape',
    size: Size(3840, 2160),
    category: 'screen',
    description: '3840×2160 px',
  );

  static const ipadPro = CanvasPreset(
    name: 'iPad Pro',
    size: Size(2048, 2732),
    category: 'screen',
    description: '2048×2732 px',
  );

  /// Print presets (at 300 DPI)
  static const a4Portrait = CanvasPreset(
    name: 'A4 Portrait',
    size: Size(2480, 3508),
    category: 'print',
    description: '2480×3508 px (300 DPI)',
  );

  static const a4Landscape = CanvasPreset(
    name: 'A4 Landscape',
    size: Size(3508, 2480),
    category: 'print',
    description: '3508×2480 px (300 DPI)',
  );

  static const letterPortrait = CanvasPreset(
    name: 'US Letter Portrait',
    size: Size(2550, 3300),
    category: 'print',
    description: '2550×3300 px (300 DPI)',
  );

  static const letterLandscape = CanvasPreset(
    name: 'US Letter Landscape',
    size: Size(3300, 2550),
    category: 'print',
    description: '3300×2550 px (300 DPI)',
  );

  /// Social media presets
  static const instagramSquare = CanvasPreset(
    name: 'Instagram Post',
    size: Size(1080, 1080),
    category: 'social',
    description: '1080×1080 px',
  );

  static const instagramStory = CanvasPreset(
    name: 'Instagram Story',
    size: Size(1080, 1920),
    category: 'social',
    description: '1080×1920 px',
  );

  static const twitterPost = CanvasPreset(
    name: 'Twitter Post',
    size: Size(1200, 675),
    category: 'social',
    description: '1200×675 px',
  );

  /// Get all presets by category
  static List<CanvasPreset> getByCategory(String category) {
    return allPresets.where((p) => p.category == category).toList();
  }

  /// All available presets
  static const allPresets = [
    // Screen
    hdLandscape,
    hdPortrait,
    square2k,
    fourK,
    ipadPro,
    // Print
    a4Portrait,
    a4Landscape,
    letterPortrait,
    letterLandscape,
    // Social
    instagramSquare,
    instagramStory,
    twitterPost,
  ];

  /// Category names
  static const categories = ['screen', 'print', 'social'];

  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'screen':
        return 'Screen / Digital';
      case 'print':
        return 'Print';
      case 'social':
        return 'Social Media';
      default:
        return category;
    }
  }
}
