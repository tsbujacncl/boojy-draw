import 'dart:ui';
import 'brush_stroke.dart';

/// Current brush settings and configuration
class BrushSettings {
  final BrushType brushType;
  final double size; // 1.0 to 500.0 pixels
  final double opacity; // 0.0 to 1.0
  final double flow; // 0.0 to 1.0
  final Color color;
  final PressureCurve pressureCurve;
  final bool pressureSizeEnabled; // Pressure affects size
  final bool pressureOpacityEnabled; // Pressure affects opacity
  final double smoothing; // 0.0 to 1.0 (stroke stabilization)
  final BlendMode blendMode;

  const BrushSettings({
    this.brushType = BrushType.pencil,
    this.size = 25.0,
    this.opacity = 1.0,
    this.flow = 1.0,
    this.color = const Color(0xFF000000),
    this.pressureCurve = PressureCurve.linear,
    this.pressureSizeEnabled = true,
    this.pressureOpacityEnabled = true,
    this.smoothing = 0.3,
    this.blendMode = BlendMode.srcOver,
  });

  /// Default settings for each brush type
  factory BrushSettings.forBrush(BrushType type) {
    switch (type) {
      case BrushType.pencil:
        return const BrushSettings(
          brushType: BrushType.pencil,
          size: 3.0,
          opacity: 1.0,
          flow: 1.0,
          smoothing: 0.1,
        );
      case BrushType.pen:
        return const BrushSettings(
          brushType: BrushType.pen,
          size: 5.0,
          opacity: 1.0,
          flow: 1.0,
          smoothing: 0.3,
        );
      case BrushType.marker:
        return const BrushSettings(
          brushType: BrushType.marker,
          size: 25.0,
          opacity: 0.5,
          flow: 0.3,
          smoothing: 0.5,
        );
      case BrushType.airbrush:
        return const BrushSettings(
          brushType: BrushType.airbrush,
          size: 50.0,
          opacity: 0.3,
          flow: 0.2,
          smoothing: 0.4,
        );
      case BrushType.eraser:
        return const BrushSettings(
          brushType: BrushType.eraser,
          size: 25.0,
          opacity: 1.0,
          flow: 1.0,
          smoothing: 0.2,
          blendMode: BlendMode.clear,
        );
    }
  }

  /// Calculate effective size based on pressure
  double getEffectiveSize(double pressure) {
    if (!pressureSizeEnabled) return size;
    final adjustedPressure = pressureCurve.apply(pressure);
    return size * (0.3 + 0.7 * adjustedPressure); // Min 30% of size
  }

  /// Calculate effective opacity based on pressure
  double getEffectiveOpacity(double pressure) {
    if (!pressureOpacityEnabled) return opacity;
    final adjustedPressure = pressureCurve.apply(pressure);
    return opacity * adjustedPressure;
  }

  /// Check if this is an eraser
  bool get isEraser => brushType == BrushType.eraser;

  BrushSettings copyWith({
    BrushType? brushType,
    double? size,
    double? opacity,
    double? flow,
    Color? color,
    PressureCurve? pressureCurve,
    bool? pressureSizeEnabled,
    bool? pressureOpacityEnabled,
    double? smoothing,
    BlendMode? blendMode,
  }) {
    return BrushSettings(
      brushType: brushType ?? this.brushType,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      flow: flow ?? this.flow,
      color: color ?? this.color,
      pressureCurve: pressureCurve ?? this.pressureCurve,
      pressureSizeEnabled: pressureSizeEnabled ?? this.pressureSizeEnabled,
      pressureOpacityEnabled:
          pressureOpacityEnabled ?? this.pressureOpacityEnabled,
      smoothing: smoothing ?? this.smoothing,
      blendMode: blendMode ?? this.blendMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrushSettings &&
          runtimeType == other.runtimeType &&
          brushType == other.brushType &&
          size == other.size &&
          opacity == other.opacity &&
          flow == other.flow &&
          color == other.color &&
          pressureCurve == other.pressureCurve &&
          pressureSizeEnabled == other.pressureSizeEnabled &&
          pressureOpacityEnabled == other.pressureOpacityEnabled &&
          smoothing == other.smoothing &&
          blendMode == other.blendMode;

  @override
  int get hashCode =>
      brushType.hashCode ^
      size.hashCode ^
      opacity.hashCode ^
      flow.hashCode ^
      color.hashCode ^
      pressureCurve.hashCode ^
      pressureSizeEnabled.hashCode ^
      pressureOpacityEnabled.hashCode ^
      smoothing.hashCode ^
      blendMode.hashCode;
}
