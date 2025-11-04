import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

/// Transform type
enum TransformType {
  none,
  move,
  scale,
  rotate,
}

/// Transform state for active transformations
class TransformState {
  final Matrix4 matrix;
  final Rect originalBounds;
  final TransformType type;
  final bool isActive;

  const TransformState({
    required this.matrix,
    required this.originalBounds,
    this.type = TransformType.none,
    this.isActive = false,
  });

  factory TransformState.empty() {
    return TransformState(
      matrix: Matrix4.identity(),
      originalBounds: Rect.zero,
      type: TransformType.none,
      isActive: false,
    );
  }

  /// Get current transformed bounds
  Rect get transformedBounds {
    if (!isActive) return originalBounds;

    final points = [
      originalBounds.topLeft,
      originalBounds.topRight,
      originalBounds.bottomLeft,
      originalBounds.bottomRight,
    ];

    final transformed = points.map((p) {
      final vector = matrix.transform3(Vector3(p.dx, p.dy, 0));
      return Offset(vector.x, vector.y);
    }).toList();

    return Rect.fromPoints(
      transformed.reduce((a, b) => Offset(
            a.dx < b.dx ? a.dx : b.dx,
            a.dy < b.dy ? a.dy : b.dy,
          )),
      transformed.reduce((a, b) => Offset(
            a.dx > b.dx ? a.dx : b.dx,
            a.dy > b.dy ? a.dy : b.dy,
          )),
    );
  }

  TransformState copyWith({
    Matrix4? matrix,
    Rect? originalBounds,
    TransformType? type,
    bool? isActive,
  }) {
    return TransformState(
      matrix: matrix ?? this.matrix.clone(),
      originalBounds: originalBounds ?? this.originalBounds,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
    );
  }
}
