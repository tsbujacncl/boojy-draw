import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/command.dart';
import '../models/layer.dart';
import '../providers/layer_stack_controller.dart';

/// Command for adding a new layer
class AddLayerCommand extends Command {
  final Ref ref;
  final Layer layer;
  final int index;

  AddLayerCommand({
    required this.ref,
    required this.layer,
    required this.index,
  });

  @override
  String get description => 'Add Layer';

  @override
  Future<void> execute() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.insertLayer(layer, index);
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.deleteLayer(layer.id);
  }
}

/// Command for deleting a layer
class DeleteLayerCommand extends Command {
  final Ref ref;
  final Layer layer;
  final int index;

  DeleteLayerCommand({
    required this.ref,
    required this.layer,
    required this.index,
  });

  @override
  String get description => 'Delete Layer';

  @override
  Future<void> execute() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.deleteLayer(layer.id);
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.insertLayer(layer, index);
  }
}

/// Command for duplicating a layer
class DuplicateLayerCommand extends Command {
  final Ref ref;
  final String sourceLayerId;
  String? _duplicatedLayerId;
  int? _insertIndex;

  DuplicateLayerCommand({
    required this.ref,
    required this.sourceLayerId,
  });

  @override
  String get description => 'Duplicate Layer';

  @override
  Future<void> execute() async {
    final controller = ref.read(layerStackProvider.notifier);
    final layerStack = ref.read(layerStackProvider);

    // Store the index where the duplicate will be inserted
    final sourceIndex = layerStack.layers.indexWhere((l) => l.id == sourceLayerId);
    _insertIndex = sourceIndex + 1;

    controller.duplicateLayer(sourceLayerId);

    // Get the ID of the newly duplicated layer
    final newLayerStack = ref.read(layerStackProvider);
    if (_insertIndex != null && _insertIndex! < newLayerStack.layers.length) {
      _duplicatedLayerId = newLayerStack.layers[_insertIndex!].id;
    }
  }

  @override
  Future<void> undo() async {
    if (_duplicatedLayerId == null) return;

    final controller = ref.read(layerStackProvider.notifier);
    controller.deleteLayer(_duplicatedLayerId!);
  }
}

/// Command for reordering layers
class ReorderLayersCommand extends Command {
  final Ref ref;
  final int oldIndex;
  final int newIndex;

  ReorderLayersCommand({
    required this.ref,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  String get description => 'Reorder Layers';

  @override
  Future<void> execute() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.reorderLayers(oldIndex, newIndex);
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(layerStackProvider.notifier);
    // Reverse the reorder
    controller.reorderLayers(newIndex, oldIndex);
  }
}

/// Command for toggling layer visibility
class ToggleLayerVisibilityCommand extends Command {
  final Ref ref;
  final String layerId;

  ToggleLayerVisibilityCommand({
    required this.ref,
    required this.layerId,
  });

  @override
  String get description => 'Toggle Layer Visibility';

  @override
  Future<void> execute() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.toggleVisibility(layerId);
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(layerStackProvider.notifier);
    // Toggle again to undo
    controller.toggleVisibility(layerId);
  }
}

/// Command for toggling layer lock
class ToggleLayerLockCommand extends Command {
  final Ref ref;
  final String layerId;

  ToggleLayerLockCommand({
    required this.ref,
    required this.layerId,
  });

  @override
  String get description => 'Toggle Layer Lock';

  @override
  Future<void> execute() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.toggleLock(layerId);
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(layerStackProvider.notifier);
    // Toggle again to undo
    controller.toggleLock(layerId);
  }
}

/// Command for changing layer opacity
class SetLayerOpacityCommand extends Command {
  final Ref ref;
  final String layerId;
  final double newOpacity;
  double? _oldOpacity;

  SetLayerOpacityCommand({
    required this.ref,
    required this.layerId,
    required this.newOpacity,
  });

  @override
  String get description => 'Change Layer Opacity';

  @override
  Future<void> execute() async {
    final layerStack = ref.read(layerStackProvider);
    final layer = layerStack.layers.firstWhere((l) => l.id == layerId);
    _oldOpacity = layer.opacity;

    final controller = ref.read(layerStackProvider.notifier);
    controller.setOpacity(layerId, newOpacity);
  }

  @override
  Future<void> undo() async {
    if (_oldOpacity == null) return;

    final controller = ref.read(layerStackProvider.notifier);
    controller.setOpacity(layerId, _oldOpacity!);
  }
}

/// Command for renaming a layer
class RenameLayerCommand extends Command {
  final Ref ref;
  final String layerId;
  final String newName;
  String? _oldName;

  RenameLayerCommand({
    required this.ref,
    required this.layerId,
    required this.newName,
  });

  @override
  String get description => 'Rename Layer';

  @override
  Future<void> execute() async {
    final layerStack = ref.read(layerStackProvider);
    final layer = layerStack.layers.firstWhere((l) => l.id == layerId);
    _oldName = layer.name;

    final controller = ref.read(layerStackProvider.notifier);
    controller.setName(layerId, newName);
  }

  @override
  Future<void> undo() async {
    if (_oldName == null) return;

    final controller = ref.read(layerStackProvider.notifier);
    controller.setName(layerId, _oldName!);
  }
}
