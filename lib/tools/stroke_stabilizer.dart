import 'dart:ui';
import '../models/stroke_point.dart';

/// Stabilizes stroke input using a Kalman filter-like approach
class StrokeStabilizer {
  final double smoothingFactor; // 0.0 (no smoothing) to 1.0 (max smoothing)

  Offset? _lastPosition;
  Offset? _velocity;

  StrokeStabilizer({required this.smoothingFactor});

  /// Process a new point and return the stabilized point
  StrokePoint stabilize(StrokePoint input) {
    if (_lastPosition == null) {
      _lastPosition = input.position;
      _velocity = Offset.zero;
      return input;
    }

    // Calculate raw velocity
    final rawVelocity = input.position - _lastPosition!;

    // Smooth velocity using exponential moving average
    _velocity = _velocity! * smoothingFactor + rawVelocity * (1 - smoothingFactor);

    // Apply smoothed velocity
    final stabilizedPosition = _lastPosition! + _velocity!;
    _lastPosition = stabilizedPosition;

    return input.copyWith(position: stabilizedPosition);
  }

  /// Reset stabilizer state (call when starting a new stroke)
  void reset() {
    _lastPosition = null;
    _velocity = null;
  }
}

/// Optimizes stroke points by removing redundant points
class StrokeOptimizer {
  final double minDistance; // Minimum distance between points
  final double angleThreshold; // Minimum angle change to keep point

  StrokeOptimizer({
    this.minDistance = 1.0,
    this.angleThreshold = 0.1, // ~5.7 degrees
  });

  /// Optimize a list of stroke points
  List<StrokePoint> optimize(List<StrokePoint> points) {
    if (points.length < 3) return points;

    final optimized = <StrokePoint>[points.first];

    for (int i = 1; i < points.length - 1; i++) {
      final prev = optimized.last;
      final current = points[i];
      final next = points[i + 1];

      // Check distance
      if (prev.distanceTo(current) < minDistance) {
        continue; // Skip points too close together
      }

      // Check angle change (Douglas-Peucker-like)
      final angle1 = _angle(prev.position, current.position);
      final angle2 = _angle(current.position, next.position);
      final angleDiff = (angle1 - angle2).abs();

      if (angleDiff > angleThreshold) {
        optimized.add(current); // Keep points where direction changes
      }
    }

    // Always keep the last point
    optimized.add(points.last);

    return optimized;
  }

  double _angle(Offset from, Offset to) {
    return (to - from).direction;
  }
}

/// Velocity-based pressure simulator for mouse input
class VelocityPressureSimulator {
  final double minVelocity; // Velocity for full pressure
  final double maxVelocity; // Velocity for min pressure

  VelocityPressureSimulator({
    this.minVelocity = 0.1,
    this.maxVelocity = 5.0,
  });

  /// Simulate pressure based on velocity (for mouse input without pressure)
  double simulatePressure(double velocity) {
    if (velocity <= minVelocity) return 1.0;
    if (velocity >= maxVelocity) return 0.3;

    // Linear interpolation between full and min pressure
    final t = (velocity - minVelocity) / (maxVelocity - minVelocity);
    return 1.0 - (t * 0.7); // Range from 1.0 to 0.3
  }

  /// Calculate pressure from two stroke points
  double pressureFromPoints(StrokePoint current, StrokePoint previous) {
    final velocity = current.velocityTo(previous);
    return simulatePressure(velocity);
  }
}
