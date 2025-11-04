import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/command.dart';
import '../models/brush_stroke.dart';
import '../models/layer.dart';
import '../providers/layer_stack_controller.dart';

/// Command for drawing a brush stroke
class BrushStrokeCommand extends Command {
  final Ref ref;
  final String layerId;
  final BrushStroke stroke;

  // Store the layer image before the stroke for undo
  ui.Image? _beforeImage;
  ui.Image? _afterImage;

  BrushStrokeCommand({
    required this.ref,
    required this.layerId,
    required this.stroke,
  });

  @override
  String get description => 'Brush Stroke';

  @override
  Future<void> execute() async {
    // Capture the before state for undo
    final layer = _getLayer();
    if (layer != null) {
      _beforeImage = layer.image;
    }
  }

  /// Set the after image (called after stroke is rendered)
  void setAfterImage(ui.Image? image) {
    _afterImage = image;
  }

  @override
  Future<void> undo() async {
    final layerController = ref.read(layerStackProvider.notifier);
    layerController.setLayerImage(layerId, _beforeImage);
  }

  /// Redo the stroke by restoring the after image
  @override
  Future<void> redo() async {
    final layerController = ref.read(layerStackProvider.notifier);
    layerController.setLayerImage(layerId, _afterImage);
  }

  @override
  bool canMergeWith(Command other) {
    if (other is! BrushStrokeCommand) return false;

    // Can merge if it's on the same layer and same brush settings
    return other.layerId == layerId &&
           stroke.color == other.stroke.color &&
           stroke.brushType == other.stroke.brushType &&
           stroke.size == other.stroke.size;
  }

  @override
  Command? mergeWith(Command other) {
    if (!canMergeWith(other)) return null;

    // Keep the current command but update the after image
    // This effectively merges consecutive strokes
    final otherBrush = other as BrushStrokeCommand;
    _afterImage = otherBrush._afterImage;
    return this;
  }

  Layer? _getLayer() {
    final layerStack = ref.read(layerStackProvider);
    try {
      return layerStack.layers.firstWhere((layer) => layer.id == layerId);
    } catch (e) {
      return null;
    }
  }
}
