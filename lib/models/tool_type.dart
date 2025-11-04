import 'package:flutter/material.dart';

/// Available tool types in the application
enum ToolType {
  brush,
  rectangleSelection,
  lassoSelection,
  magicWand,
  transform,
  eyedropper,
}

extension ToolTypeExtension on ToolType {
  /// Display name for the tool
  String get displayName {
    switch (this) {
      case ToolType.brush:
        return 'Brush';
      case ToolType.rectangleSelection:
        return 'Rectangle Select';
      case ToolType.lassoSelection:
        return 'Lasso Select';
      case ToolType.magicWand:
        return 'Magic Wand';
      case ToolType.transform:
        return 'Transform';
      case ToolType.eyedropper:
        return 'Eyedropper';
    }
  }

  /// Icon for the tool
  IconData get icon {
    switch (this) {
      case ToolType.brush:
        return Icons.brush;
      case ToolType.rectangleSelection:
        return Icons.crop_square;
      case ToolType.lassoSelection:
        return Icons.gesture;
      case ToolType.magicWand:
        return Icons.auto_fix_high;
      case ToolType.transform:
        return Icons.transform;
      case ToolType.eyedropper:
        return Icons.colorize;
    }
  }

  /// Keyboard shortcut for the tool
  String get shortcut {
    switch (this) {
      case ToolType.brush:
        return 'B';
      case ToolType.rectangleSelection:
        return 'M';
      case ToolType.lassoSelection:
        return 'L';
      case ToolType.magicWand:
        return 'W';
      case ToolType.transform:
        return 'V';
      case ToolType.eyedropper:
        return 'I';
    }
  }

  /// Tooltip text
  String get tooltip {
    return '$displayName ($shortcut)';
  }
}
