import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Selection mode for combining selections
enum SelectionMode {
  replace, // New selection (default)
  add,     // Add to existing (Shift)
  subtract, // Remove from existing (Alt)
  intersect, // Intersect with existing (Shift+Alt)
}

/// Represents a selection region on the canvas
class Selection {
  final ui.Path path;
  final double feather; // Feather radius in pixels (0-100)
  final Rect? bounds; // Cached bounds for performance

  const Selection({
    required this.path,
    this.feather = 0.0,
    this.bounds,
  });

  /// Create empty selection
  factory Selection.empty() {
    return Selection(
      path: ui.Path(),
      feather: 0.0,
      bounds: null,
    );
  }

  /// Create rectangular selection
  factory Selection.rectangle(Rect rect, {double feather = 0.0}) {
    final path = ui.Path()..addRect(rect);
    return Selection(
      path: path,
      feather: feather,
      bounds: rect,
    );
  }

  /// Create selection from points (lasso)
  factory Selection.fromPoints(List<Offset> points, {double feather = 0.0}) {
    if (points.isEmpty) return Selection.empty();

    final path = ui.Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    return Selection(
      path: path,
      feather: feather,
      bounds: _calculateBounds(path),
    );
  }

  /// Create selection for entire canvas
  factory Selection.all(Size canvasSize, {double feather = 0.0}) {
    return Selection.rectangle(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      feather: feather,
    );
  }

  /// Check if selection is empty
  bool get isEmpty => bounds == null || bounds!.isEmpty;

  /// Check if point is in selection
  bool contains(Offset point) {
    if (isEmpty) return false;
    if (bounds != null && !bounds!.contains(point)) return false;
    return path.contains(point);
  }

  /// Get selection bounds
  Rect get selectionBounds => bounds ?? Rect.zero;

  /// Combine this selection with another using a mode
  Selection combine(Selection other, SelectionMode mode) {
    if (mode == SelectionMode.replace) {
      return other;
    }

    if (isEmpty) {
      return mode == SelectionMode.subtract ? this : other;
    }

    if (other.isEmpty) {
      return mode == SelectionMode.intersect ? Selection.empty() : this;
    }

    final combinedPath = ui.Path();

    switch (mode) {
      case SelectionMode.replace:
        return other;

      case SelectionMode.add:
        combinedPath.addPath(path, Offset.zero);
        combinedPath.addPath(other.path, Offset.zero);
        break;

      case SelectionMode.subtract:
        // Note: Path.combine with difference is not directly available
        // For now, we'll use addPath which creates a union
        // A more sophisticated implementation would use actual path difference
        combinedPath.addPath(path, Offset.zero);
        // TODO: Implement proper path subtraction
        break;

      case SelectionMode.intersect:
        // TODO: Implement proper path intersection
        // For now, return the smaller bounds
        combinedPath.addPath(path, Offset.zero);
        break;
    }

    return Selection(
      path: combinedPath,
      feather: feather,
      bounds: _calculateBounds(combinedPath),
    );
  }

  /// Create a copy with modifications
  Selection copyWith({
    ui.Path? path,
    double? feather,
    Rect? bounds,
    bool clearBounds = false,
  }) {
    return Selection(
      path: path ?? this.path,
      feather: feather ?? this.feather,
      bounds: clearBounds ? null : (bounds ?? this.bounds),
    );
  }

  /// Transform selection with matrix
  Selection transform(Matrix4 matrix) {
    final transformedPath = path.transform(matrix.storage);
    return Selection(
      path: transformedPath,
      feather: feather,
      bounds: _calculateBounds(transformedPath),
    );
  }

  /// Translate selection by offset
  Selection translate(Offset offset) {
    final translatedPath = path.shift(offset);
    final translatedBounds = bounds?.shift(offset);
    return Selection(
      path: translatedPath,
      feather: feather,
      bounds: translatedBounds,
    );
  }

  /// Calculate bounds for a path
  static Rect? _calculateBounds(ui.Path path) {
    final metrics = path.computeMetrics();
    if (!metrics.iterator.moveNext()) return null;

    final bounds = path.getBounds();
    return bounds.isEmpty ? null : bounds;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Selection &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          feather == other.feather &&
          bounds == other.bounds;

  @override
  int get hashCode => path.hashCode ^ feather.hashCode ^ bounds.hashCode;

  @override
  String toString() =>
      'Selection(bounds: $bounds, feather: $feather, isEmpty: $isEmpty)';
}
