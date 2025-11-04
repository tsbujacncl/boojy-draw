import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brush_stroke.dart';
import '../models/stroke_point.dart';

/// State for the current drawing session
class DrawingState {
  final List<BrushStroke> committedStrokes; // Finalized strokes
  final BrushStroke? currentStroke; // Stroke being drawn
  final bool isDrawing;

  const DrawingState({
    this.committedStrokes = const [],
    this.currentStroke,
    this.isDrawing = false,
  });

  DrawingState copyWith({
    List<BrushStroke>? committedStrokes,
    BrushStroke? currentStroke,
    bool? isDrawing,
    bool clearCurrentStroke = false,
  }) {
    return DrawingState(
      committedStrokes: committedStrokes ?? this.committedStrokes,
      currentStroke: clearCurrentStroke ? null : (currentStroke ?? this.currentStroke),
      isDrawing: isDrawing ?? this.isDrawing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingState &&
          runtimeType == other.runtimeType &&
          committedStrokes == other.committedStrokes &&
          currentStroke == other.currentStroke &&
          isDrawing == other.isDrawing;

  @override
  int get hashCode =>
      committedStrokes.hashCode ^ currentStroke.hashCode ^ isDrawing.hashCode;
}

/// Controller for managing drawing state
class DrawingStateController extends StateNotifier<DrawingState> {
  DrawingStateController() : super(const DrawingState());

  /// Start a new stroke
  void startStroke(BrushStroke stroke) {
    state = state.copyWith(
      currentStroke: stroke,
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

  /// Finish the current stroke and commit it
  void endStroke() {
    if (state.currentStroke == null) return;

    final committed = [...state.committedStrokes, state.currentStroke!];

    state = state.copyWith(
      committedStrokes: committed,
      isDrawing: false,
      clearCurrentStroke: true,
    );
  }

  /// Cancel the current stroke without committing
  void cancelStroke() {
    state = state.copyWith(
      isDrawing: false,
      clearCurrentStroke: true,
    );
  }

  /// Clear all strokes
  void clearAll() {
    state = const DrawingState();
  }

  /// Undo last stroke
  void undo() {
    if (state.committedStrokes.isEmpty) return;

    final strokes = List<BrushStroke>.from(state.committedStrokes);
    strokes.removeLast();

    state = state.copyWith(committedStrokes: strokes);
  }
}

/// Provider for drawing state controller
final drawingStateProvider =
    StateNotifierProvider<DrawingStateController, DrawingState>(
  (ref) => DrawingStateController(),
);
