import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../canvas/canvas_input_handler.dart';
import '../canvas/canvas_renderer.dart';
import '../providers/canvas_controller.dart';
import '../providers/drawing_state_controller.dart';
import '../providers/layer_stack_controller.dart';
import '../providers/tool_controller.dart';
import '../models/tool_type.dart';
import '../tools/brush_tool.dart';
import '../tools/selection/rectangle_selection_tool.dart';
import '../tools/selection/lasso_selection_tool.dart';
import '../tools/selection/magic_wand_tool.dart';
import '../tools/transform_tool.dart';

/// Main canvas viewport widget
class CanvasViewport extends ConsumerWidget {
  const CanvasViewport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasControllerProvider);
    final drawingState = ref.watch(drawingStateProvider);
    final layerStackState = ref.watch(layerStackProvider);
    final toolState = ref.watch(toolControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark background
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          final canvasContent = ClipRect(
            child: Stack(
              children: [
                // Canvas renderer with drawing state and layers
                CanvasRenderWidget(
                  canvasState: canvasState,
                  drawingState: drawingState,
                  layerStackState: layerStackState,
                ),

                // Zoom controls overlay (bottom-right)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _ZoomControls(),
                ),
              ],
            ),
          );

          // Wrap with appropriate tool based on active tool
          final toolWrappedContent = _buildToolWrapper(
            toolState.activeTool,
            canvasContent,
          );

          return CanvasInputHandler(
            viewportSize: viewportSize,
            child: toolWrappedContent,
          );
        },
      ),
    );
  }

  /// Build the appropriate tool wrapper based on active tool
  Widget _buildToolWrapper(ToolType toolType, Widget child) {
    switch (toolType) {
      case ToolType.brush:
        return BrushTool(child: child);
      case ToolType.rectangleSelection:
        return RectangleSelectionTool(child: child);
      case ToolType.lassoSelection:
        return LassoSelectionTool(child: child);
      case ToolType.magicWand:
        return MagicWandTool(child: child);
      case ToolType.transform:
        return TransformTool(child: child);
      case ToolType.eyedropper:
        // TODO: Implement eyedropper tool (Phase 7+)
        return child;
    }
  }
}

/// Zoom controls widget
class _ZoomControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasControllerProvider);
    final controller = ref.read(canvasControllerProvider.notifier);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zoom in button
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              iconSize: 18,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              onPressed: () => controller.zoomIn(),
              tooltip: 'Zoom In (Cmd/Ctrl +)',
            ),

            // Current zoom percentage
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                canvasState.zoomPercentage,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Zoom out button
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              iconSize: 18,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              onPressed: () => controller.zoomOut(),
              tooltip: 'Zoom Out (Cmd/Ctrl -)',
            ),

            const Divider(height: 8),

            // Zoom to fit button
            IconButton(
              icon: const Icon(Icons.fit_screen, size: 18),
              iconSize: 18,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              onPressed: () {
                // Get viewport size from context
                final renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  // Get viewport size by going up the tree
                  final viewportSize = MediaQuery.of(context).size;
                  controller.zoomToFit(viewportSize);
                }
              },
              tooltip: 'Zoom to Fit (Cmd/Ctrl 0)',
            ),

            // Zoom to 100% button
            IconButton(
              icon: const Icon(Icons.crop_free, size: 18),
              iconSize: 18,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              onPressed: () => controller.zoomToActualSize(),
              tooltip: 'Zoom to 100% (Cmd/Ctrl 1)',
            ),
          ],
        ),
      ),
    );
  }
}
