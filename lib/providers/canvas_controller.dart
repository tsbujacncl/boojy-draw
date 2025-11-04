import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/canvas_state.dart';
import '../models/canvas_preset.dart';

/// Canvas controller managing canvas state and transformations
class CanvasController extends StateNotifier<CanvasState> {
  CanvasController() : super(CanvasState.defaultCanvas());

  // Zoom limits (10% to 6400%)
  static const double minZoom = 0.1;
  static const double maxZoom = 64.0;

  /// Create a new canvas with specified size and background
  void newCanvas({
    required Size size,
    Color backgroundColor = const Color(0xFFFFFFFF),
  }) {
    state = CanvasState(
      canvasSize: size,
      backgroundColor: backgroundColor,
      zoom: 1.0,
      panOffset: Offset.zero,
      rotation: 0.0,
    );
  }

  /// Create canvas from preset
  void newCanvasFromPreset(CanvasPreset preset,
      {Color? backgroundColor}) {
    newCanvas(
      size: preset.size,
      backgroundColor: backgroundColor ?? const Color(0xFFFFFFFF),
    );
  }

  /// Set zoom level (clamped to min/max)
  void setZoom(double zoom) {
    state = state.copyWith(
      zoom: zoom.clamp(minZoom, maxZoom),
    );
  }

  /// Zoom in by factor (default 1.2x)
  void zoomIn([double factor = 1.2]) {
    setZoom(state.zoom * factor);
  }

  /// Zoom out by factor (default 1.2x)
  void zoomOut([double factor = 1.2]) {
    setZoom(state.zoom / factor);
  }

  /// Zoom to specific percentage (e.g., 100 for 100%)
  void zoomToPercentage(double percentage) {
    setZoom(percentage / 100);
  }

  /// Zoom to fit canvas in viewport
  void zoomToFit(Size viewportSize) {
    final scaleX = viewportSize.width / state.canvasSize.width;
    final scaleY = viewportSize.height / state.canvasSize.height;
    final fitZoom = math.min(scaleX, scaleY) * 0.9; // 90% to add padding

    state = state.copyWith(
      zoom: fitZoom.clamp(minZoom, maxZoom),
      panOffset: Offset.zero, // Center canvas
    );
  }

  /// Zoom to 100% (actual pixels)
  void zoomToActualSize() {
    state = state.copyWith(
      zoom: 1.0,
      panOffset: Offset.zero,
    );
  }

  /// Set pan offset
  void setPan(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  /// Add delta to current pan
  void panBy(Offset delta) {
    state = state.copyWith(
      panOffset: state.panOffset + delta,
    );
  }

  /// Reset pan to center
  void resetPan() {
    state = state.copyWith(panOffset: Offset.zero);
  }

  /// Set rotation (in radians)
  void setRotation(double radians) {
    // Normalize to 0-2π range
    final normalized = radians % (2 * math.pi);
    state = state.copyWith(rotation: normalized);
  }

  /// Rotate by delta (in radians)
  void rotateBy(double deltaRadians) {
    setRotation(state.rotation + deltaRadians);
  }

  /// Snap rotation to nearest 90° angle
  void snapRotation() {
    final degrees = state.rotation * 180 / math.pi;
    final snapped = (degrees / 90).round() * 90;
    setRotation(snapped * math.pi / 180);
  }

  /// Reset rotation to 0
  void resetRotation() {
    state = state.copyWith(rotation: 0.0);
  }

  /// Set background color
  void setBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color);
  }

  /// Reset view (zoom, pan, rotation)
  void resetView() {
    state = state.copyWith(
      zoom: 1.0,
      panOffset: Offset.zero,
      rotation: 0.0,
    );
  }

  /// Handle mouse wheel zoom (with focal point)
  void handleWheelZoom(double delta, Offset focalPoint, Size viewportSize) {
    final oldZoom = state.zoom;

    // Calculate zoom change (positive delta = zoom in)
    final zoomFactor = delta > 0 ? 1.1 : 0.9;
    final newZoom = (oldZoom * zoomFactor).clamp(minZoom, maxZoom);

    if (oldZoom == newZoom) return; // Already at limit

    // Convert focal point to canvas coordinates before zoom
    final canvasPoint = state.screenToCanvas(focalPoint, viewportSize);

    // Update zoom
    state = state.copyWith(zoom: newZoom);

    // Convert same canvas point to new screen coordinates
    final newScreenPoint = state.canvasToScreen(canvasPoint, viewportSize);

    // Adjust pan to keep focal point stationary
    final panAdjustment = focalPoint - newScreenPoint;
    state = state.copyWith(
      panOffset: state.panOffset + panAdjustment,
    );
  }
}

/// Provider for canvas controller
final canvasControllerProvider =
    StateNotifierProvider<CanvasController, CanvasState>(
  (ref) => CanvasController(),
);
