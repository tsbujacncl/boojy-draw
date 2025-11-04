import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/command.dart';
import '../providers/layer_stack_controller.dart';

/// Command for applying a transform (move, scale, rotate)
class ApplyTransformCommand extends Command {
  final WidgetRef ref;
  final String layerId;
  final Matrix4 transform;
  ui.Image? _beforeImage;
  ui.Image? _afterImage;

  ApplyTransformCommand({
    required this.ref,
    required this.layerId,
    required this.transform,
  });

  @override
  String get description => 'Transform';

  @override
  Future<void> execute() async {
    // Store the before image
    final layerStack = ref.read(layerStackProvider);
    final layer = layerStack.layers.firstWhere((l) => l.id == layerId);
    _beforeImage = layer.image;

    // The actual transformation will be done by the transform tool
    // This command just tracks the before/after state
  }

  /// Set the after image (called after transform is applied)
  void setAfterImage(ui.Image? image) {
    _afterImage = image;
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.setLayerImage(layerId, _beforeImage);
  }

  /// Redo the transform
  @override
  Future<void> redo() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.setLayerImage(layerId, _afterImage);
  }
}

/// Command for flipping a layer
class FlipLayerCommand extends Command {
  final WidgetRef ref;
  final String layerId;
  final bool horizontal;
  ui.Image? _beforeImage;
  ui.Image? _afterImage;

  FlipLayerCommand({
    required this.ref,
    required this.layerId,
    required this.horizontal,
  });

  @override
  String get description => horizontal ? 'Flip Horizontal' : 'Flip Vertical';

  @override
  Future<void> execute() async {
    // Store the before image
    final layerStack = ref.read(layerStackProvider);
    final layer = layerStack.layers.firstWhere((l) => l.id == layerId);
    _beforeImage = layer.image;
  }

  /// Set the after image (called after flip is applied)
  void setAfterImage(ui.Image? image) {
    _afterImage = image;
  }

  @override
  Future<void> undo() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.setLayerImage(layerId, _beforeImage);
  }

  /// Redo the flip
  @override
  Future<void> redo() async {
    final controller = ref.read(layerStackProvider.notifier);
    controller.setLayerImage(layerId, _afterImage);
  }
}
