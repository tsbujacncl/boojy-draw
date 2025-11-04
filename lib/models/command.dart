/// Base class for all undoable commands
abstract class Command {
  /// Execute the command
  Future<void> execute();

  /// Undo the command
  Future<void> undo();

  /// Redo the command (default implementation re-executes)
  Future<void> redo() async {
    await execute();
  }

  /// Get a description of this command for debugging/UI
  String get description;

  /// Whether this command can be merged with another command
  /// (e.g., consecutive brush strokes on the same layer)
  bool canMergeWith(Command other) => false;

  /// Merge this command with another command
  /// Returns a new command that represents both actions
  Command? mergeWith(Command other) => null;
}
