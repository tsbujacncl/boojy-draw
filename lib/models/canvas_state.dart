import 'dart:ui';

/// Immutable state representing the canvas configuration and viewport
class CanvasState {
  final Size canvasSize;
  final double zoom; // 0.1 to 64.0 (10% to 6400%)
  final Offset panOffset;
  final double rotation; // in radians, 0 to 2π
  final Color backgroundColor;

  const CanvasState({
    required this.canvasSize,
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.rotation = 0.0,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  /// Default canvas state (1920×1080, white background)
  factory CanvasState.defaultCanvas() {
    return const CanvasState(
      canvasSize: Size(1920, 1080),
      backgroundColor: Color(0xFFFFFFFF),
    );
  }

  /// Create canvas from preset
  CanvasState.fromPreset({
    required this.canvasSize,
    required this.backgroundColor,
  })  : zoom = 1.0,
        panOffset = Offset.zero,
        rotation = 0.0;

  /// Copy with modifications
  CanvasState copyWith({
    Size? canvasSize,
    double? zoom,
    Offset? panOffset,
    double? rotation,
    Color? backgroundColor,
  }) {
    return CanvasState(
      canvasSize: canvasSize ?? this.canvasSize,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      rotation: rotation ?? this.rotation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// Get zoom percentage (e.g., 1.0 → "100%")
  String get zoomPercentage => '${(zoom * 100).toStringAsFixed(0)}%';

  /// Get canvas dimensions as string
  String get dimensionsString =>
      '${canvasSize.width.toInt()}×${canvasSize.height.toInt()} px';

  /// Convert canvas coordinates to screen coordinates
  Offset canvasToScreen(Offset canvasPoint, Size viewportSize) {
    // Center canvas in viewport
    final centerOffset = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );

    // Apply zoom and pan
    return Offset(
          canvasPoint.dx * zoom,
          canvasPoint.dy * zoom,
        ) +
        panOffset +
        centerOffset;
  }

  /// Convert screen coordinates to canvas coordinates
  Offset screenToCanvas(Offset screenPoint, Size viewportSize) {
    final centerOffset = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );

    return (screenPoint - panOffset - centerOffset) / zoom;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasState &&
          runtimeType == other.runtimeType &&
          canvasSize == other.canvasSize &&
          zoom == other.zoom &&
          panOffset == other.panOffset &&
          rotation == other.rotation &&
          backgroundColor == other.backgroundColor;

  @override
  int get hashCode =>
      canvasSize.hashCode ^
      zoom.hashCode ^
      panOffset.hashCode ^
      rotation.hashCode ^
      backgroundColor.hashCode;
}
