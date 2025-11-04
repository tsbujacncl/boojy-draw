import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/command.dart';
import '../models/selection.dart';
import '../providers/selection_controller.dart';

/// Command for creating/modifying a selection
class SelectionCommand extends Command {
  final WidgetRef ref;
  final Selection? newSelection;
  Selection? _oldSelection;

  SelectionCommand({
    required this.ref,
    required this.newSelection,
  });

  @override
  String get description => 'Selection';

  @override
  Future<void> execute() async {
    final selectionState = ref.read(selectionControllerProvider);
    _oldSelection = selectionState.selection;

    final controller = ref.read(selectionControllerProvider.notifier);
    if (newSelection != null) {
      controller.setSelection(newSelection!);
    } else {
      controller.clearSelection();
    }
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(selectionControllerProvider.notifier);
    if (_oldSelection != null) {
      controller.setSelection(_oldSelection!);
    } else {
      controller.clearSelection();
    }
  }
}

/// Command for cutting selection
class CutSelectionCommand extends Command {
  final WidgetRef ref;
  final String layerId;
  final Selection selection;
  ui.Image? _beforeImage;
  ui.Image? _afterImage;

  CutSelectionCommand({
    required this.ref,
    required this.layerId,
    required this.selection,
  });

  @override
  String get description => 'Cut';

  @override
  Future<void> execute() async {
    // Store the before image - will be implemented when cut functionality is added
    // This is a placeholder for future cut/copy/paste operations
  }

  @override
  Future<void> undo() async {
    // Restore the before image
    // This is a placeholder for future cut/copy/paste operations
  }
}

/// Command for pasting selection
class PasteSelectionCommand extends Command {
  final WidgetRef ref;
  final String layerId;
  final ui.Image pastedImage;
  final ui.Offset position;
  ui.Image? _beforeImage;

  PasteSelectionCommand({
    required this.ref,
    required this.layerId,
    required this.pastedImage,
    required this.position,
  });

  @override
  String get description => 'Paste';

  @override
  Future<void> execute() async {
    // Store the before image - will be implemented when paste functionality is added
    // This is a placeholder for future cut/copy/paste operations
  }

  @override
  Future<void> undo() async {
    // Restore the before image
    // This is a placeholder for future cut/copy/paste operations
  }
}
