import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brush_settings.dart';
import '../models/brush_stroke.dart';

/// Brush controller managing brush settings and state
class BrushController extends StateNotifier<BrushSettings> {
  BrushController() : super(const BrushSettings());

  /// Change brush type
  void setBrushType(BrushType type) {
    state = BrushSettings.forBrush(type);
  }

  /// Set brush size (1-500 pixels)
  void setSize(double size) {
    state = state.copyWith(size: size.clamp(1.0, 500.0));
  }

  /// Set brush opacity (0-1)
  void setOpacity(double opacity) {
    state = state.copyWith(opacity: opacity.clamp(0.0, 1.0));
  }

  /// Set brush flow (0-1)
  void setFlow(double flow) {
    state = state.copyWith(flow: flow.clamp(0.0, 1.0));
  }

  /// Set brush color
  void setColor(Color color) {
    state = state.copyWith(color: color);
  }

  /// Set pressure curve
  void setPressureCurve(PressureCurve curve) {
    state = state.copyWith(pressureCurve: curve);
  }

  /// Toggle pressure affects size
  void togglePressureSize() {
    state = state.copyWith(pressureSizeEnabled: !state.pressureSizeEnabled);
  }

  /// Toggle pressure affects opacity
  void togglePressureOpacity() {
    state = state.copyWith(
        pressureOpacityEnabled: !state.pressureOpacityEnabled);
  }

  /// Set smoothing level (0-1)
  void setSmoothing(double smoothing) {
    state = state.copyWith(smoothing: smoothing.clamp(0.0, 1.0));
  }

  /// Set blend mode
  void setBlendMode(BlendMode mode) {
    state = state.copyWith(blendMode: mode);
  }

  /// Quick brush shortcuts
  void selectPencil() => setBrushType(BrushType.pencil);
  void selectPen() => setBrushType(BrushType.pen);
  void selectMarker() => setBrushType(BrushType.marker);
  void selectAirbrush() => setBrushType(BrushType.airbrush);
  void selectEraser() => setBrushType(BrushType.eraser);

  /// Adjust brush size with +/- keys
  void increaseBrushSize([double amount = 5.0]) {
    setSize(state.size + amount);
  }

  void decreaseBrushSize([double amount = 5.0]) {
    setSize(state.size - amount);
  }
}

/// Provider for brush controller
final brushControllerProvider =
    StateNotifierProvider<BrushController, BrushSettings>(
  (ref) => BrushController(),
);
