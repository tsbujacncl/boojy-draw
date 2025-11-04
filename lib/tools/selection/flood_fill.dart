import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Flood fill helper for Magic Wand tool
class FloodFill {
  /// Perform flood fill from a point with tolerance
  /// Returns a list of points that match the color within tolerance
  static Future<List<Offset>> floodFill({
    required ui.Image image,
    required Offset startPoint,
    required int tolerance,
  }) async {
    final width = image.width;
    final height = image.height;

    // Check bounds
    if (startPoint.dx < 0 ||
        startPoint.dy < 0 ||
        startPoint.dx >= width ||
        startPoint.dy >= height) {
      return [];
    }

    // Get image pixels
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];

    final pixels = byteData.buffer.asUint8List();

    // Get start color
    final startX = startPoint.dx.toInt();
    final startY = startPoint.dy.toInt();
    final startColor = _getPixelColor(pixels, startX, startY, width);

    // Track visited pixels
    final visited = List.generate(
      height,
      (_) => List.filled(width, false),
    );

    // Result points
    final result = <Offset>[];

    // Queue for BFS
    final queue = <Offset>[Offset(startX.toDouble(), startY.toDouble())];
    visited[startY][startX] = true;

    // 4-directional flood fill (up, down, left, right)
    const directions = [
      Offset(1, 0), // right
      Offset(-1, 0), // left
      Offset(0, 1), // down
      Offset(0, -1), // up
    ];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final x = current.dx.toInt();
      final y = current.dy.toInt();

      result.add(current);

      // Check all 4 directions
      for (final dir in directions) {
        final newX = x + dir.dx.toInt();
        final newY = y + dir.dy.toInt();

        // Check bounds
        if (newX < 0 || newX >= width || newY < 0 || newY >= height) {
          continue;
        }

        // Skip if already visited
        if (visited[newY][newX]) continue;

        // Get pixel color
        final pixelColor = _getPixelColor(pixels, newX, newY, width);

        // Check if color matches within tolerance
        if (_colorMatch(startColor, pixelColor, tolerance)) {
          visited[newY][newX] = true;
          queue.add(Offset(newX.toDouble(), newY.toDouble()));
        }
      }
    }

    return result;
  }

  /// Get pixel color at position
  static Color _getPixelColor(List<int> pixels, int x, int y, int width) {
    final index = (y * width + x) * 4;
    return Color.fromARGB(
      pixels[index + 3], // alpha
      pixels[index], // red
      pixels[index + 1], // green
      pixels[index + 2], // blue
    );
  }

  /// Check if two colors match within tolerance
  static bool _colorMatch(Color c1, Color c2, int tolerance) {
    final dr = ((c1.r * 255).round() - (c2.r * 255).round()).abs();
    final dg = ((c1.g * 255).round() - (c2.g * 255).round()).abs();
    final db = ((c1.b * 255).round() - (c2.b * 255).round()).abs();
    final da = ((c1.a * 255).round() - (c2.a * 255).round()).abs();

    // Calculate color distance (0-255 scale)
    final distance = (dr + dg + db + da) / 4;

    // Tolerance is 0-100, map to 0-255
    final threshold = (tolerance / 100.0) * 255.0;

    return distance <= threshold;
  }

  /// Convert list of points to rectangular regions for selection path
  static List<Rect> pointsToRects(List<Offset> points) {
    if (points.isEmpty) return [];

    // Group consecutive points into rectangles
    // This is a simplified version - could be optimized
    final rects = <Rect>[];

    for (final point in points) {
      rects.add(Rect.fromLTWH(point.dx, point.dy, 1, 1));
    }

    return rects;
  }
}
