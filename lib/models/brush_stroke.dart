import 'dart:ui';
import 'stroke_point.dart';

/// Represents a complete brush stroke with points and settings
class BrushStroke {
  final List<StrokePoint> points;
  final Color color;
  final double size;
  final double opacity;
  final BrushType brushType;
  final BlendMode blendMode;

  const BrushStroke({
    required this.points,
    required this.color,
    required this.size,
    required this.opacity,
    required this.brushType,
    this.blendMode = BlendMode.srcOver,
  });

  /// Check if stroke has enough points to render
  bool get isValid => points.length >= 2;

  /// Get bounding box of the stroke
  Rect getBounds() {
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.position.dx;
    double minY = points.first.position.dy;
    double maxX = points.first.position.dx;
    double maxY = points.first.position.dy;

    for (final point in points) {
      minX = minX < point.position.dx ? minX : point.position.dx;
      minY = minY < point.position.dy ? minY : point.position.dy;
      maxX = maxX > point.position.dx ? maxX : point.position.dx;
      maxY = maxY > point.position.dy ? maxY : point.position.dy;
    }

    // Add padding based on brush size
    final padding = size / 2;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }

  /// Get total length of the stroke
  double get length {
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 1; i < points.length; i++) {
      total += points[i].distanceTo(points[i - 1]);
    }
    return total;
  }

  BrushStroke copyWith({
    List<StrokePoint>? points,
    Color? color,
    double? size,
    double? opacity,
    BrushType? brushType,
    BlendMode? blendMode,
  }) {
    return BrushStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      brushType: brushType ?? this.brushType,
      blendMode: blendMode ?? this.blendMode,
    );
  }

  @override
  String toString() =>
      'BrushStroke(${points.length} points, $brushType, size: $size)';
}

/// Types of brushes available
enum BrushType {
  pencil('Pencil', 'Hard-edged, precise lines'),
  pen('Pen', 'Smooth, anti-aliased lines'),
  marker('Marker', 'Soft-edged, buildable opacity'),
  airbrush('Airbrush', 'Spray effect with falloff'),
  eraser('Eraser', 'Erase pixels');

  final String displayName;
  final String description;

  const BrushType(this.displayName, this.description);
}

/// Pressure curve types for stylus input
enum PressureCurve {
  linear('Linear', 'Direct pressure mapping'),
  easeIn('Ease In', 'Gradual pressure increase'),
  easeOut('Ease Out', 'Gradual pressure decrease'),
  sCurve('S-Curve', 'Smooth pressure response');

  final String displayName;
  final String description;

  const PressureCurve(this.displayName, this.description);

  /// Apply pressure curve to raw pressure value
  double apply(double pressure) {
    switch (this) {
      case PressureCurve.linear:
        return pressure;
      case PressureCurve.easeIn:
        return pressure * pressure; // Quadratic ease in
      case PressureCurve.easeOut:
        return 1 - (1 - pressure) * (1 - pressure); // Quadratic ease out
      case PressureCurve.sCurve:
        // Smoothstep function
        return pressure * pressure * (3 - 2 * pressure);
    }
  }
}
