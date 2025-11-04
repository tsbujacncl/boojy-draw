import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/command.dart';

/// State for the history stack
class HistoryState {
  final List<Command> undoStack;
  final List<Command> redoStack;
  final int maxStackSize;

  const HistoryState({
    this.undoStack = const [],
    this.redoStack = const [],
    this.maxStackSize = 50,
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  /// Get undo stack size
  int get undoCount => undoStack.length;

  /// Get redo stack size
  int get redoCount => redoStack.length;

  /// Get description of the next undo command
  String? get undoDescription =>
      undoStack.isNotEmpty ? undoStack.last.description : null;

  /// Get description of the next redo command
  String? get redoDescription =>
      redoStack.isNotEmpty ? redoStack.last.description : null;

  HistoryState copyWith({
    List<Command>? undoStack,
    List<Command>? redoStack,
    int? maxStackSize,
  }) {
    return HistoryState(
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      maxStackSize: maxStackSize ?? this.maxStackSize,
    );
  }
}

/// Controller for managing undo/redo history
class HistoryController extends StateNotifier<HistoryState> {
  HistoryController() : super(const HistoryState());

  /// Execute and record a command
  Future<void> execute(Command command) async {
    // Execute the command
    await command.execute();

    // Try to merge with the last command if possible
    if (state.undoStack.isNotEmpty) {
      final lastCommand = state.undoStack.last;
      if (lastCommand.canMergeWith(command)) {
        final merged = lastCommand.mergeWith(command);
        if (merged != null) {
          // Replace the last command with the merged one
          final newUndoStack = List<Command>.from(state.undoStack);
          newUndoStack[newUndoStack.length - 1] = merged;

          state = state.copyWith(
            undoStack: newUndoStack,
            redoStack: [], // Clear redo stack after new action
          );
          return;
        }
      }
    }

    // Add to undo stack
    final newUndoStack = List<Command>.from(state.undoStack);
    newUndoStack.add(command);

    // Limit stack size
    if (newUndoStack.length > state.maxStackSize) {
      newUndoStack.removeAt(0);
    }

    state = state.copyWith(
      undoStack: newUndoStack,
      redoStack: [], // Clear redo stack after new action
    );
  }

  /// Undo the last command
  Future<bool> undo() async {
    if (!state.canUndo) return false;

    final command = state.undoStack.last;
    await command.undo();

    // Move command from undo to redo stack
    final newUndoStack = List<Command>.from(state.undoStack)..removeLast();
    final newRedoStack = List<Command>.from(state.redoStack)..add(command);

    state = state.copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );

    return true;
  }

  /// Redo the last undone command
  Future<bool> redo() async {
    if (!state.canRedo) return false;

    final command = state.redoStack.last;
    await command.redo();

    // Move command from redo to undo stack
    final newRedoStack = List<Command>.from(state.redoStack)..removeLast();
    final newUndoStack = List<Command>.from(state.undoStack)..add(command);

    state = state.copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );

    return true;
  }

  /// Clear all history
  void clear() {
    state = const HistoryState();
  }
}

/// Provider for history controller
final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>(
  (ref) => HistoryController(),
);
