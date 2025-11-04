import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/selection.dart';
import '../../providers/selection_controller.dart';
import '../../providers/canvas_controller.dart';
import '../../providers/layer_stack_controller.dart';
import 'flood_fill.dart';

/// Magic Wand tool for selecting regions by color similarity
class MagicWandTool extends ConsumerStatefulWidget {
  final Widget child;

  const MagicWandTool({super.key, required this.child});

  @override
  ConsumerState<MagicWandTool> createState() => _MagicWandToolState();
}

class _MagicWandToolState extends ConsumerState<MagicWandTool> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          widget.child,
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) async {
    if (event.buttons != kPrimaryButton || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final canvasState = ref.read(canvasControllerProvider);
      final layerStack = ref.read(layerStackProvider);
      final selectionState = ref.read(selectionControllerProvider);
      final selectionController =
          ref.read(selectionControllerProvider.notifier);

      // Get active layer
      final activeLayer = layerStack.activeLayer;
      if (activeLayer == null || activeLayer.image == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Convert screen to canvas coordinates
      final canvasPosition = canvasState.screenToCanvas(
        event.localPosition,
        context.size ?? Size.zero,
      );

      // Adjust for layer position (layers are centered)
      final layerX =
          canvasPosition.dx + (canvasState.canvasSize.width / 2);
      final layerY =
          canvasPosition.dy + (canvasState.canvasSize.height / 2);

      final layerPoint = Offset(layerX, layerY);

      // Perform flood fill
      final points = await FloodFill.floodFill(
        image: activeLayer.image!,
        startPoint: layerPoint,
        tolerance: selectionState.tolerance,
      );

      if (points.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Convert points to selection path
      final path = _createPathFromPoints(points, canvasState.canvasSize);

      // Determine selection mode from modifier keys
      final mode = _getSelectionMode(
        event.kind == PointerDeviceKind.mouse
            ? HardwareKeyboard.instance.logicalKeysPressed
            : {},
      );

      final selection = Selection(
        path: path,
        feather: selectionState.feather,
        bounds: path.getBounds(),
      );

      if (mode == SelectionMode.replace) {
        selectionController.setMode(mode);
        selectionController.setSelection(selection);
      } else {
        selectionController.setMode(mode);
        selectionController.setSelection(selection);
        selectionController.setMode(SelectionMode.replace);
      }
    } catch (e) {
      debugPrint('Magic Wand error: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  ui.Path _createPathFromPoints(List<Offset> points, Size canvasSize) {
    final path = ui.Path();

    if (points.isEmpty) return path;

    // Adjust points back to canvas coordinates (centered)
    final adjustedPoints = points.map((p) {
      return Offset(
        p.dx - (canvasSize.width / 2),
        p.dy - (canvasSize.height / 2),
      );
    }).toList();

    // Create path from points
    // Group adjacent points into rectangles for better performance
    final rects = <Rect>[];
    for (final point in adjustedPoints) {
      rects.add(Rect.fromLTWH(point.dx, point.dy, 1, 1));
    }

    // Add all rectangles to path
    for (final rect in rects) {
      path.addRect(rect);
    }

    return path;
  }

  SelectionMode _getSelectionMode(Set<LogicalKeyboardKey> pressedKeys) {
    final shiftPressed = pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.shiftRight);
    final altPressed = pressedKeys.contains(LogicalKeyboardKey.altLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.altRight);

    if (shiftPressed && altPressed) {
      return SelectionMode.intersect;
    } else if (shiftPressed) {
      return SelectionMode.add;
    } else if (altPressed) {
      return SelectionMode.subtract;
    }
    return SelectionMode.replace;
  }
}
