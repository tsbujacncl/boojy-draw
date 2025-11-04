import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brush_stroke.dart';
import '../models/stroke_point.dart';

/// State for the current drawing session
class DrawingState {
  final Map<String, List<BrushStroke>> layerStrokes; // Strokes per layer ID
  final BrushStroke? currentStroke; // Stroke being drawn
  final String? currentLayerId; // Layer for current stroke
  final bool isDrawing;

  const DrawingState({
    this.layerStrokes = const {},
    this.currentStroke,
    this.currentLayerId,
    this.isDrawing = false,
  });

  /// Get strokes for a specific layer
  List<BrushStroke> getStrokesForLayer(String layerId) {
    return layerStrokes[layerId] ?? [];
  }

  /// Get all strokes (flattened)
  List<BrushStroke> get allStrokes {
    return layerStrokes.values.expand((strokes) => strokes).toList();
  }

  DrawingState copyWith({
    Map<String, List<BrushStroke>>? layerStrokes,
    BrushStroke? currentStroke,
    String? currentLayerId,
    bool? isDrawing,
    bool clearCurrentStroke = false,
    bool clearCurrentLayerId = false,
  }) {
    return DrawingState(
      layerStrokes: layerStrokes ?? this.layerStrokes,
      currentStroke: clearCurrentStroke ? null : (currentStroke ?? this.currentStroke),
      currentLayerId: clearCurrentLayerId ? null : (currentLayerId ?? this.currentLayerId),
      isDrawing: isDrawing ?? this.isDrawing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingState &&
          runtimeType == other.runtimeType &&
          layerStrokes == other.layerStrokes &&
          currentStroke == other.currentStroke &&
          currentLayerId == other.currentLayerId &&
          isDrawing == other.isDrawing;

  @override
  int get hashCode =>
      layerStrokes.hashCode ^
      currentStroke.hashCode ^
      currentLayerId.hashCode ^
      isDrawing.hashCode;
}

/// Controller for managing drawing state
class DrawingStateController extends StateNotifier<DrawingState> {
  DrawingStateController() : super(const DrawingState());

  /// Start a new stroke on a specific layer
  void startStroke(BrushStroke stroke, String layerId) {
    state = state.copyWith(
      currentStroke: stroke,
      currentLayerId: layerId,
      isDrawing: true,
    );
  }

  /// Add a point to the current stroke
  void addPoint(StrokePoint point) {
    if (state.currentStroke == null) return;

    final updatedPoints = [...state.currentStroke!.points, point];
    final updatedStroke = state.currentStroke!.copyWith(points: updatedPoints);

    state = state.copyWith(currentStroke: updatedStroke);
  }

  /// Finish the current stroke and commit it to the layer
  void endStroke() {
    if (state.currentStroke == null || state.currentLayerId == null) return;

    final updatedLayerStrokes = Map<String, List<BrushStroke>>.from(state.layerStrokes);
    final layerStrokes = updatedLayerStrokes[state.currentLayerId] ?? [];
    updatedLayerStrokes[state.currentLayerId!] = [...layerStrokes, state.currentStroke!];

    state = state.copyWith(
      layerStrokes: updatedLayerStrokes,
      isDrawing: false,
      clearCurrentStroke: true,
      clearCurrentLayerId: true,
    );
  }

  /// Cancel the current stroke without committing
  void cancelStroke() {
    state = state.copyWith(
      isDrawing: false,
      clearCurrentStroke: true,
      clearCurrentLayerId: true,
    );
  }

  /// Clear all strokes
  void clearAll() {
    state = const DrawingState();
  }

  /// Clear strokes for a specific layer
  void clearLayer(String layerId) {
    final updatedLayerStrokes = Map<String, List<BrushStroke>>.from(state.layerStrokes);
    updatedLayerStrokes.remove(layerId);
    state = state.copyWith(layerStrokes: updatedLayerStrokes);
  }

  /// Undo last stroke on a specific layer
  void undoLayer(String layerId) {
    final layerStrokes = state.getStrokesForLayer(layerId);
    if (layerStrokes.isEmpty) return;

    final updatedStrokes = List<BrushStroke>.from(layerStrokes);
    updatedStrokes.removeLast();

    final updatedLayerStrokes = Map<String, List<BrushStroke>>.from(state.layerStrokes);
    updatedLayerStrokes[layerId] = updatedStrokes;

    state = state.copyWith(layerStrokes: updatedLayerStrokes);
  }
}

/// Provider for drawing state controller
final drawingStateProvider =
    StateNotifierProvider<DrawingStateController, DrawingState>(
  (ref) => DrawingStateController(),
);
