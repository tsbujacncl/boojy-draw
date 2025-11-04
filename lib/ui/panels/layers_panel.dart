import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/layer_stack_controller.dart';
import '../../providers/drawing_state_controller.dart';
import '../../providers/canvas_controller.dart';
import '../../models/layer.dart';
import '../../tools/layer_compositor.dart';

/// Layers panel widget for managing layers
class LayersPanel extends ConsumerWidget {
  const LayersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layerStack = ref.watch(layerStackProvider);
    final layerController = ref.read(layerStackProvider.notifier);

    return Column(
      children: [
        // Layers list
        Expanded(
          child: layerStack.layers.isEmpty
              ? Center(
                  child: Text(
                    'No layers',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: layerStack.layers.length,
                  reverse: true, // Show top layer first
                  onReorder: (oldIndex, newIndex) {
                    // Adjust indices for reverse order
                    final actualOldIndex = layerStack.layers.length - 1 - oldIndex;
                    final actualNewIndex = layerStack.layers.length - 1 - newIndex;
                    layerController.reorderLayers(actualOldIndex, actualNewIndex);
                  },
                  itemBuilder: (context, index) {
                    // Reverse index for display
                    final layerIndex = layerStack.layers.length - 1 - index;
                    final layer = layerStack.layers[layerIndex];
                    final isActive = layer.id == layerStack.activeLayerId;

                    return LayerTile(
                      key: ValueKey(layer.id),
                      layer: layer,
                      isActive: isActive,
                      onTap: () => layerController.setActiveLayer(layer.id),
                      onVisibilityToggle: () => layerController.toggleVisibility(layer.id),
                      onLockToggle: () => layerController.toggleLock(layer.id),
                      onOpacityChanged: (opacity) => layerController.setOpacity(layer.id, opacity),
                      onRename: (name) => layerController.setName(layer.id, name),
                      onDelete: () => layerController.deleteLayer(layer.id),
                      onDuplicate: () => layerController.duplicateLayer(layer.id),
                    );
                  },
                ),
        ),

        // Layer actions
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: 'New Layer',
                onPressed: () => layerController.addLayer(),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                tooltip: 'Delete Layer',
                onPressed: layerStack.activeLayer != null
                    ? () => layerController.deleteLayer(layerStack.activeLayerId!)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Duplicate Layer',
                onPressed: layerStack.activeLayer != null
                    ? () => layerController.duplicateLayer(layerStack.activeLayerId!)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual layer tile widget
class LayerTile extends StatelessWidget {
  final Layer layer;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onLockToggle;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const LayerTile({
    super.key,
    required this.layer,
    required this.isActive,
    required this.onTap,
    required this.onVisibilityToggle,
    required this.onLockToggle,
    required this.onOpacityChanged,
    required this.onRename,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : null,
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Thumbnail
              LayerThumbnail(
                layer: layer,
                size: 40,
              ),
              const SizedBox(width: 8),

              // Layer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layer.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(layer.opacity * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),

              // Controls
              IconButton(
                icon: Icon(
                  layer.visible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onVisibilityToggle,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  layer.locked ? Icons.lock : Icons.lock_open,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onLockToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that displays a thumbnail for a layer
class LayerThumbnail extends ConsumerWidget {
  final Layer layer;
  final double size;

  const LayerThumbnail({
    super.key,
    required this.layer,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingStateProvider);
    final canvasState = ref.watch(canvasControllerProvider);
    final strokes = drawingState.getStrokesForLayer(layer.id);

    // If layer has a cached thumbnail and no new strokes, use it
    if (layer.thumbnail != null && strokes.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: RawImage(
            image: layer.thumbnail,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // If layer is empty (no image and no strokes), show placeholder
    if (layer.isEmpty && strokes.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Center(child: Icon(Icons.layers, size: 20)),
      );
    }

    // Generate thumbnail on-the-fly
    return FutureBuilder<ui.Image>(
      future: LayerCompositor.generateThumbnail(
        layer: layer,
        originalSize: canvasState.canvasSize,
        thumbnailSize: Size(size, size),
        strokes: strokes,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: RawImage(
                image: snapshot.data,
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        // Loading state
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
