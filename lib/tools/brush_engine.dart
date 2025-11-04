import 'package:flutter/material.dart';
import '../models/brush_stroke.dart';
import '../models/brush_settings.dart';

/// Engine for rendering brush strokes
class BrushEngine {
  /// Render a complete stroke to canvas
  static void renderStroke(Canvas canvas, BrushStroke stroke) {
    if (!stroke.isValid) return;

    switch (stroke.brushType) {
      case BrushType.pencil:
        _renderPencil(canvas, stroke);
        break;
      case BrushType.pen:
        _renderPen(canvas, stroke);
        break;
      case BrushType.marker:
        _renderMarker(canvas, stroke);
        break;
      case BrushType.airbrush:
        _renderAirbrush(canvas, stroke);
        break;
      case BrushType.eraser:
        _renderEraser(canvas, stroke);
        break;
    }
  }

  /// Render pencil brush (hard-edged, precise)
  static void _renderPencil(Canvas canvas, BrushStroke stroke) {
    final paint = Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = stroke.blendMode;

    for (int i = 1; i < stroke.points.length; i++) {
      final prev = stroke.points[i - 1];
      final current = stroke.points[i];

      // Apply pressure to stroke width
      final avgPressure = (prev.pressure + current.pressure) / 2;
      paint.strokeWidth = stroke.size * avgPressure;

      canvas.drawLine(prev.position, current.position, paint);
    }
  }

  /// Render pen brush (smooth, anti-aliased)
  static void _renderPen(Canvas canvas, BrushStroke stroke) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = stroke.blendMode
      ..isAntiAlias = true;

    // Create smooth path using quadratic curves
    final path = Path();
    path.moveTo(stroke.points.first.position.dx, stroke.points.first.position.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      final prev = stroke.points[i - 1];
      final current = stroke.points[i];

      // Calculate midpoint for smooth curves
      final midPoint = Offset(
        (prev.position.dx + current.position.dx) / 2,
        (prev.position.dy + current.position.dy) / 2,
      );

      // Quadratic curve to midpoint
      path.quadraticBezierTo(
        prev.position.dx,
        prev.position.dy,
        midPoint.dx,
        midPoint.dy,
      );

      // Apply pressure
      final avgPressure = (prev.pressure + current.pressure) / 2;
      paint.strokeWidth = stroke.size * avgPressure;
    }

    // Draw to last point
    final last = stroke.points.last;
    path.lineTo(last.position.dx, last.position.dy);

    canvas.drawPath(path, paint);
  }

  /// Render marker brush (soft-edged, buildable)
  static void _renderMarker(Canvas canvas, BrushStroke stroke) {
    final paint = Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity * 0.3)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = stroke.blendMode
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    for (int i = 1; i < stroke.points.length; i++) {
      final prev = stroke.points[i - 1];
      final current = stroke.points[i];

      final avgPressure = (prev.pressure + current.pressure) / 2;
      paint.strokeWidth = stroke.size * avgPressure * 1.2;

      canvas.drawLine(prev.position, current.position, paint);
    }
  }

  /// Render airbrush (spray effect with falloff)
  static void _renderAirbrush(Canvas canvas, BrushStroke stroke) {
    for (final point in stroke.points) {
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity * 0.05)
        ..blendMode = stroke.blendMode
        ..isAntiAlias = true
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      final radius = stroke.size * point.pressure;
      canvas.drawCircle(point.position, radius, paint);
    }
  }

  /// Render eraser (clears pixels)
  static void _renderEraser(Canvas canvas, BrushStroke stroke) {
    final paint = Paint()
      ..color = Colors.transparent
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.clear
      ..isAntiAlias = true;

    for (int i = 1; i < stroke.points.length; i++) {
      final prev = stroke.points[i - 1];
      final current = stroke.points[i];

      final avgPressure = (prev.pressure + current.pressure) / 2;
      paint.strokeWidth = stroke.size * avgPressure;

      canvas.drawLine(prev.position, current.position, paint);
    }
  }

  /// Create a brush cursor preview
  static void renderCursor(Canvas canvas, Offset position, BrushSettings settings) {
    // Outer circle (brush size indicator)
    final outerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawCircle(position, settings.size / 2, outerPaint);

    // Inner crosshair
    final crosshairPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.0;

    const crosshairSize = 10.0;
    canvas.drawLine(
      Offset(position.dx - crosshairSize, position.dy),
      Offset(position.dx + crosshairSize, position.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy - crosshairSize),
      Offset(position.dx, position.dy + crosshairSize),
      crosshairPaint,
    );
  }
}
