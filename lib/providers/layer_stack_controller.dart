import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/layer.dart';
import '../models/brush_stroke.dart';
import '../tools/layer_compositor.dart';

/// State for the layer stack
class LayerStackState {
  final List<Layer> layers;
  final String? activeLayerId;

  const LayerStackState({
    required this.layers,
    this.activeLayerId,
  });

  /// Get active layer
  Layer? get activeLayer {
    if (activeLayerId == null) return null;
    try {
      return layers.firstWhere((l) => l.id == activeLayerId);
    } catch (e) {
      return null;
    }
  }

  /// Get active layer index
  int? get activeLayerIndex {
    if (activeLayerId == null) return null;
    return layers.indexWhere((l) => l.id == activeLayerId);
  }

  /// Check if stack is valid
  bool get isValid => layers.isNotEmpty;

  LayerStackState copyWith({
    List<Layer>? layers,
    String? activeLayerId,
    bool clearActiveLayer = false,
  }) {
    return LayerStackState(
      layers: layers ?? this.layers,
      activeLayerId:
          clearActiveLayer ? null : (activeLayerId ?? this.activeLayerId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayerStackState &&
          runtimeType == other.runtimeType &&
          layers == other.layers &&
          activeLayerId == other.activeLayerId;

  @override
  int get hashCode => layers.hashCode ^ activeLayerId.hashCode;
}

/// Controller for managing layer stack
class LayerStackController extends StateNotifier<LayerStackState> {
  LayerStackController()
      : super(LayerStackState(
          layers: [Layer.empty(name: 'Layer 1', index: 1)],
          activeLayerId: null,
        )) {
    // Set first layer as active
    if (state.layers.isNotEmpty) {
      state = state.copyWith(activeLayerId: state.layers.first.id);
    }
  }

  /// Add a new empty layer
  void addLayer({String? name}) {
    final newLayer = Layer.empty(
      name: name,
      index: state.layers.length + 1,
    );

    final updatedLayers = [...state.layers, newLayer];

    state = state.copyWith(
      layers: updatedLayers,
      activeLayerId: newLayer.id,
    );
  }

  /// Insert layer at specific index
  void insertLayer(Layer layer, int index) {
    final updatedLayers = List<Layer>.from(state.layers);
    updatedLayers.insert(index.clamp(0, updatedLayers.length), layer);

    state = state.copyWith(layers: updatedLayers);
  }

  /// Delete layer by ID
  void deleteLayer(String layerId) {
    if (state.layers.length == 1) {
      // Don't delete the last layer
      return;
    }

    final updatedLayers =
        state.layers.where((l) => l.id != layerId).toList();

    // If deleted layer was active, select another
    String? newActiveId = state.activeLayerId;
    if (layerId == state.activeLayerId) {
      newActiveId = updatedLayers.isNotEmpty ? updatedLayers.last.id : null;
    }

    state = state.copyWith(
      layers: updatedLayers,
      activeLayerId: newActiveId,
    );
  }

  /// Duplicate layer
  void duplicateLayer(String layerId) {
    final layer = state.layers.firstWhere((l) => l.id == layerId);
    final index = state.layers.indexOf(layer);

    final duplicated = Layer.empty(
      name: '${layer.name} copy',
    ).copyWith(
      opacity: layer.opacity,
      visible: layer.visible,
      locked: false,
      blendMode: layer.blendMode,
      image: layer.image, // Share same image reference (will need deep copy later)
    );

    insertLayer(duplicated, index + 1);

    state = state.copyWith(activeLayerId: duplicated.id);
  }

  /// Set active layer
  void setActiveLayer(String layerId) {
    state = state.copyWith(activeLayerId: layerId);
  }

  /// Update layer properties
  void updateLayer(String layerId, Layer Function(Layer) updater) {
    final updatedLayers = state.layers.map((layer) {
      if (layer.id == layerId) {
        return updater(layer);
      }
      return layer;
    }).toList();

    state = state.copyWith(layers: updatedLayers);
  }

  /// Toggle layer visibility
  void toggleVisibility(String layerId) {
    updateLayer(layerId, (layer) => layer.copyWith(visible: !layer.visible));
  }

  /// Toggle layer lock
  void toggleLock(String layerId) {
    updateLayer(layerId, (layer) => layer.copyWith(locked: !layer.locked));
  }

  /// Set layer opacity
  void setOpacity(String layerId, double opacity) {
    updateLayer(
        layerId, (layer) => layer.copyWith(opacity: opacity.clamp(0.0, 1.0)));
  }

  /// Set layer name
  void setName(String layerId, String name) {
    updateLayer(layerId, (layer) => layer.copyWith(name: name));
  }

  /// Set layer blend mode
  void setBlendMode(String layerId, BlendMode blendMode) {
    updateLayer(layerId, (layer) => layer.copyWith(blendMode: blendMode));
  }

  /// Set layer image
  void setLayerImage(String layerId, ui.Image? image) {
    updateLayer(layerId, (layer) => layer.copyWith(image: image));
  }

  /// Reorder layers (move layer from oldIndex to newIndex)
  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    final updatedLayers = List<Layer>.from(state.layers);
    final layer = updatedLayers.removeAt(oldIndex);

    // Adjust newIndex if moving down
    final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    updatedLayers.insert(adjustedIndex, layer);

    state = state.copyWith(layers: updatedLayers);
  }

  /// Merge layer down (merge with layer below)
  Future<void> mergeDown(
    String layerId, {
    required Size canvasSize,
    required Map<String, List<BrushStroke>> layerStrokes,
  }) async {
    final index = state.layers.indexWhere((l) => l.id == layerId);
    if (index <= 0) return; // Can't merge bottom layer

    final upperLayer = state.layers[index];
    final lowerLayer = state.layers[index - 1];

    // Composite the two layers together
    final mergedImage = await LayerCompositor.compositeLayersToImage(
      layers: [lowerLayer, upperLayer],
      canvasSize: canvasSize,
      layerStrokes: layerStrokes,
    );

    // Update lower layer with merged image and clear its strokes
    final updatedLowerLayer = lowerLayer.copyWith(
      image: mergedImage,
      name: '${lowerLayer.name} + ${upperLayer.name}',
    );

    // Remove both layers and insert the merged one
    final updatedLayers = List<Layer>.from(state.layers);
    updatedLayers.removeAt(index); // Remove upper layer
    updatedLayers[index - 1] = updatedLowerLayer; // Update lower layer

    // If the deleted layer was active, select the merged layer
    String? newActiveId = state.activeLayerId;
    if (layerId == state.activeLayerId) {
      newActiveId = updatedLowerLayer.id;
    }

    state = state.copyWith(
      layers: updatedLayers,
      activeLayerId: newActiveId,
    );
  }

  /// Flatten all layers
  Future<void> flattenAll({
    required Size canvasSize,
    required Map<String, List<BrushStroke>> layerStrokes,
  }) async {
    if (state.layers.isEmpty) return;

    // Composite all layers into a single image
    final flattenedImage = await LayerCompositor.compositeLayersToImage(
      layers: state.layers,
      canvasSize: canvasSize,
      layerStrokes: layerStrokes,
    );

    // Create a new flattened layer
    final flattened = Layer.empty(name: 'Flattened', index: 1).copyWith(
      image: flattenedImage,
    );

    state = LayerStackState(
      layers: [flattened],
      activeLayerId: flattened.id,
    );
  }

  /// Clear all layers and reset to single empty layer
  void reset() {
    final newLayer = Layer.empty(name: 'Layer 1', index: 1);

    state = LayerStackState(
      layers: [newLayer],
      activeLayerId: newLayer.id,
    );
  }
}

/// Provider for layer stack controller
final layerStackProvider =
    StateNotifierProvider<LayerStackController, LayerStackState>(
  (ref) => LayerStackController(),
);
