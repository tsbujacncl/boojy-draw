import 'dart:ui';

/// A single point in a brush stroke with position, pressure, and timing
class StrokePoint {
  final Offset position;
  final double pressure; // 0.0 to 1.0
  final DateTime timestamp;
  final double tilt; // Stylus tilt angle (0.0 to 1.0)
  final double orientation; // Stylus orientation in radians

  const StrokePoint({
    required this.position,
    this.pressure = 1.0,
    required this.timestamp,
    this.tilt = 0.0,
    this.orientation = 0.0,
  });

  /// Create from pointer event data
  factory StrokePoint.fromPointer({
    required Offset position,
    required double pressure,
    double tilt = 0.0,
    double orientation = 0.0,
  }) {
    return StrokePoint(
      position: position,
      pressure: pressure.clamp(0.0, 1.0),
      timestamp: DateTime.now(),
      tilt: tilt,
      orientation: orientation,
    );
  }

  /// Calculate distance to another point
  double distanceTo(StrokePoint other) {
    return (position - other.position).distance;
  }

  /// Calculate velocity to another point (pixels per millisecond)
  double velocityTo(StrokePoint other) {
    final distance = distanceTo(other);
    final timeDiff = timestamp.difference(other.timestamp).inMilliseconds;
    if (timeDiff == 0) return 0.0;
    return distance / timeDiff;
  }

  /// Interpolate between two points
  static StrokePoint lerp(StrokePoint a, StrokePoint b, double t) {
    return StrokePoint(
      position: Offset.lerp(a.position, b.position, t)!,
      pressure: a.pressure + (b.pressure - a.pressure) * t,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        a.timestamp.millisecondsSinceEpoch +
            ((b.timestamp.millisecondsSinceEpoch -
                        a.timestamp.millisecondsSinceEpoch) *
                    t)
                .round(),
      ),
      tilt: a.tilt + (b.tilt - a.tilt) * t,
      orientation: a.orientation + (b.orientation - a.orientation) * t,
    );
  }

  @override
  String toString() =>
      'StrokePoint(pos: $position, pressure: ${pressure.toStringAsFixed(2)})';

  StrokePoint copyWith({
    Offset? position,
    double? pressure,
    DateTime? timestamp,
    double? tilt,
    double? orientation,
  }) {
    return StrokePoint(
      position: position ?? this.position,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
      tilt: tilt ?? this.tilt,
      orientation: orientation ?? this.orientation,
    );
  }
}
