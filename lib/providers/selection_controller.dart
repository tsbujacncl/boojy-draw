import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/selection.dart';

/// State for selection system
class SelectionState {
  final Selection? selection;
  final double feather; // Current feather setting
  final int tolerance; // Magic wand tolerance (0-100)
  final SelectionMode mode; // Current selection mode

  const SelectionState({
    this.selection,
    this.feather = 0.0,
    this.tolerance = 32,
    this.mode = SelectionMode.replace,
  });

  /// Check if there's an active selection
  bool get hasSelection => selection != null && !selection!.isEmpty;

  SelectionState copyWith({
    Selection? selection,
    double? feather,
    int? tolerance,
    SelectionMode? mode,
    bool clearSelection = false,
  }) {
    return SelectionState(
      selection: clearSelection ? null : (selection ?? this.selection),
      feather: feather ?? this.feather,
      tolerance: tolerance ?? this.tolerance,
      mode: mode ?? this.mode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectionState &&
          runtimeType == other.runtimeType &&
          selection == other.selection &&
          feather == other.feather &&
          tolerance == other.tolerance &&
          mode == other.mode;

  @override
  int get hashCode =>
      selection.hashCode ^
      feather.hashCode ^
      tolerance.hashCode ^
      mode.hashCode;
}

/// Controller for managing selections
class SelectionController extends StateNotifier<SelectionState> {
  SelectionController() : super(const SelectionState());

  /// Set new selection (replaces existing)
  void setSelection(Selection selection) {
    final combined = state.selection?.combine(selection, state.mode) ?? selection;
    state = state.copyWith(selection: combined);
  }

  /// Clear current selection
  void clearSelection() {
    state = state.copyWith(clearSelection: true, mode: SelectionMode.replace);
  }

  /// Select all (entire canvas)
  void selectAll(Size canvasSize) {
    final selection = Selection.all(canvasSize, feather: state.feather);
    setSelection(selection);
  }

  /// Set feather amount (0-100 pixels)
  void setFeather(double feather) {
    state = state.copyWith(feather: feather.clamp(0.0, 100.0));

    // Update existing selection if present
    if (state.selection != null) {
      final updated = state.selection!.copyWith(feather: state.feather);
      state = state.copyWith(selection: updated);
    }
  }

  /// Set magic wand tolerance (0-100)
  void setTolerance(int tolerance) {
    state = state.copyWith(tolerance: tolerance.clamp(0, 100));
  }

  /// Set selection mode (for modifiers)
  void setMode(SelectionMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Create rectangular selection
  void selectRectangle(Rect rect, {SelectionMode? mode}) {
    final selection = Selection.rectangle(rect, feather: state.feather);
    final effectiveMode = mode ?? state.mode;

    if (effectiveMode == SelectionMode.replace) {
      state = state.copyWith(selection: selection, mode: SelectionMode.replace);
    } else {
      setSelection(selection);
      state = state.copyWith(mode: SelectionMode.replace);
    }
  }

  /// Create lasso selection from points
  void selectLasso(List<Offset> points, {SelectionMode? mode}) {
    final selection = Selection.fromPoints(points, feather: state.feather);
    final effectiveMode = mode ?? state.mode;

    if (effectiveMode == SelectionMode.replace) {
      state = state.copyWith(selection: selection, mode: SelectionMode.replace);
    } else {
      setSelection(selection);
      state = state.copyWith(mode: SelectionMode.replace);
    }
  }

  /// Translate selection by offset
  void translateSelection(Offset offset) {
    if (state.selection != null) {
      final translated = state.selection!.translate(offset);
      state = state.copyWith(selection: translated);
    }
  }

  /// Transform selection with matrix
  void transformSelection(Matrix4 matrix) {
    if (state.selection != null) {
      final transformed = state.selection!.transform(matrix);
      state = state.copyWith(selection: transformed);
    }
  }

  /// Invert selection
  void invertSelection(Size canvasSize) {
    if (state.selection == null || state.selection!.isEmpty) {
      selectAll(canvasSize);
    } else {
      // TODO: Implement proper selection inversion
      // For now, just select all (would need path boolean operations)
      selectAll(canvasSize);
    }
  }

  /// Grow selection by pixels
  void growSelection(double pixels) {
    // TODO: Implement selection growing
    // Would need to expand the path outward
  }

  /// Shrink selection by pixels
  void shrinkSelection(double pixels) {
    // TODO: Implement selection shrinking
    // Would need to contract the path inward
  }
}

/// Provider for selection controller
final selectionControllerProvider =
    StateNotifierProvider<SelectionController, SelectionState>(
  (ref) => SelectionController(),
);
