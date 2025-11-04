import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transform_state.dart';

/// Controller for managing transform operations
class TransformController extends StateNotifier<TransformState?> {
  TransformController() : super(null);

  /// Start a new transform with the given initial bounds
  void startTransform(Rect initialBounds) {
    state = TransformState(
      matrix: Matrix4.identity(),
      originalBounds: initialBounds,
      type: TransformType.none,
    );
  }

  /// Update the transform matrix
  void updateMatrix(Matrix4 matrix, TransformType type) {
    if (state == null) return;
    state = state!.copyWith(matrix: matrix, type: type);
  }

  /// Move the transform by the given offset
  void move(Offset delta) {
    if (state == null) return;

    final moveMatrix = Matrix4.translationValues(delta.dx, delta.dy, 0);
    final newMatrix = moveMatrix * state!.matrix;

    state = state!.copyWith(
      matrix: newMatrix,
      type: TransformType.move,
    );
  }

  /// Scale the transform from a specific handle
  void scale(
    Offset handlePosition,
    Offset delta,
    bool constrainAspect,
  ) {
    if (state == null) return;

    final center = state!.originalBounds.center;

    // Calculate scale factors based on handle movement
    final scaleX = (handlePosition.dx - center.dx + delta.dx) /
        (handlePosition.dx - center.dx);
    final scaleY = (handlePosition.dy - center.dy + delta.dy) /
        (handlePosition.dy - center.dy);

    final finalScaleX = constrainAspect ? scaleX : scaleX;
    final finalScaleY = constrainAspect ? scaleX : scaleY;

    // Create new matrix with scale applied around center
    final translate1 = Matrix4.translationValues(center.dx, center.dy, 0);
    final scaleMatrix = Matrix4.diagonal3Values(finalScaleX, finalScaleY, 1.0);
    final translate2 = Matrix4.translationValues(-center.dx, -center.dy, 0);

    final newMatrix = translate1 * scaleMatrix * translate2;

    state = state!.copyWith(
      matrix: newMatrix,
      type: TransformType.scale,
    );
  }

  /// Rotate the transform by the given angle (in radians)
  void rotate(double angle, {bool snap = false}) {
    if (state == null) return;

    final center = state!.originalBounds.center;

    // Snap to 15-degree increments if requested
    double finalAngle = angle;
    if (snap) {
      const snapInterval = 15.0 * (3.14159265359 / 180.0); // 15 degrees in radians
      finalAngle = (angle / snapInterval).round() * snapInterval;
    }

    // Create rotation matrix around center point
    final translate1 = Matrix4.translationValues(center.dx, center.dy, 0);
    final rotateMatrix = Matrix4.rotationZ(finalAngle);
    final translate2 = Matrix4.translationValues(-center.dx, -center.dy, 0);

    final newMatrix = translate1 * rotateMatrix * translate2;

    state = state!.copyWith(
      matrix: newMatrix,
      type: TransformType.rotate,
    );
  }

  /// Flip the transform horizontally
  void flipHorizontal() {
    if (state == null) return;

    final center = state!.originalBounds.center;

    // Apply horizontal flip around center
    final translate1 = Matrix4.translationValues(center.dx, 0, 0);
    final flipMatrix = Matrix4.diagonal3Values(-1.0, 1.0, 1.0);
    final translate2 = Matrix4.translationValues(-center.dx, 0, 0);

    final flipTransform = translate1 * flipMatrix * translate2;
    final newMatrix = state!.matrix * flipTransform;

    state = state!.copyWith(matrix: newMatrix);
  }

  /// Flip the transform vertically
  void flipVertical() {
    if (state == null) return;

    final center = state!.originalBounds.center;

    // Apply vertical flip around center
    final translate1 = Matrix4.translationValues(0, center.dy, 0);
    final flipMatrix = Matrix4.diagonal3Values(1.0, -1.0, 1.0);
    final translate2 = Matrix4.translationValues(0, -center.dy, 0);

    final flipTransform = translate1 * flipMatrix * translate2;
    final newMatrix = state!.matrix * flipTransform;

    state = state!.copyWith(matrix: newMatrix);
  }

  /// Apply the transform (commits the changes)
  /// Returns the final transformed bounds
  Rect? applyTransform() {
    if (state == null) return null;

    final transformedBounds = state!.transformedBounds;

    // Clear the transform state
    state = null;

    return transformedBounds;
  }

  /// Cancel the transform (discards changes)
  void cancelTransform() {
    state = null;
  }

  /// Check if a transform is currently active
  bool get hasTransform => state != null;
}

/// Provider for transform controller
final transformControllerProvider =
    StateNotifierProvider<TransformController, TransformState?>(
  (ref) => TransformController(),
);
