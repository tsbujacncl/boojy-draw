import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brush_stroke.dart';
import '../models/stroke_point.dart';
import '../providers/brush_controller.dart';
import '../providers/canvas_controller.dart';
import '../providers/drawing_state_controller.dart';
import '../providers/layer_stack_controller.dart';
import '../providers/history_controller.dart';
import '../commands/brush_stroke_command.dart';
import 'stroke_stabilizer.dart';
import 'layer_compositor.dart';

/// Brush tool for drawing on canvas
class BrushTool extends ConsumerStatefulWidget {
  final Widget child;

  const BrushTool({super.key, required this.child});

  @override
  ConsumerState<BrushTool> createState() => _BrushToolState();
}

class _BrushToolState extends ConsumerState<BrushTool> {
  StrokeStabilizer? _stabilizer;
  VelocityPressureSimulator? _pressureSimulator;
  StrokePoint? _lastPoint;
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    // Ignore if not a drawing pointer (pen, touch, or mouse)
    if (event.kind != PointerDeviceKind.stylus &&
        event.kind != PointerDeviceKind.mouse &&
        event.kind != PointerDeviceKind.touch) {
      return;
    }

    final brushSettings = ref.read(brushControllerProvider);
    final canvasState = ref.read(canvasControllerProvider);
    final layerStack = ref.read(layerStackProvider);

    // Check if there's an active layer and it's not locked
    if (layerStack.activeLayer == null || layerStack.activeLayer!.locked) {
      return;
    }

    // Convert screen coordinates to canvas coordinates
    final canvasPosition = canvasState.screenToCanvas(
      event.localPosition,
      context.size ?? Size.zero,
    );

    // Initialize stabilizer with current smoothing setting
    _stabilizer = StrokeStabilizer(smoothingFactor: brushSettings.smoothing);

    // Initialize pressure simulator for mouse input
    _pressureSimulator = VelocityPressureSimulator();

    // Get pressure (1.0 for mouse, actual pressure for stylus)
    final pressure = event.kind == PointerDeviceKind.stylus
        ? event.pressure
        : 1.0;

    final firstPoint = StrokePoint.fromPointer(
      position: canvasPosition,
      pressure: pressure,
      tilt: event.tilt,
      orientation: event.orientation,
    );

    _lastPoint = firstPoint;
    _isDrawing = true;

    // Start new stroke on active layer
    final stroke = BrushStroke(
      points: [firstPoint],
      color: brushSettings.color,
      size: brushSettings.size,
      opacity: brushSettings.opacity,
      brushType: brushSettings.brushType,
      blendMode: brushSettings.blendMode,
    );

    ref.read(drawingStateProvider.notifier).startStroke(
          stroke,
          layerStack.activeLayerId!,
        );
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isDrawing || _lastPoint == null) return;

    final brushSettings = ref.read(brushControllerProvider);
    final canvasState = ref.read(canvasControllerProvider);

    // Convert to canvas coordinates
    final canvasPosition = canvasState.screenToCanvas(
      event.localPosition,
      context.size ?? Size.zero,
    );

    // Get pressure
    double pressure;
    if (event.kind == PointerDeviceKind.stylus) {
      pressure = event.pressure;
    } else {
      // Simulate pressure from velocity for mouse
      final rawPoint = StrokePoint.fromPointer(
        position: canvasPosition,
        pressure: 1.0,
      );
      final velocity = rawPoint.velocityTo(_lastPoint!);
      pressure = _pressureSimulator?.simulatePressure(velocity) ?? 1.0;
    }

    // Create raw point
    var point = StrokePoint.fromPointer(
      position: canvasPosition,
      pressure: pressure,
      tilt: event.tilt,
      orientation: event.orientation,
    );

    // Apply stabilization
    if (_stabilizer != null && brushSettings.smoothing > 0) {
      point = _stabilizer!.stabilize(point);
    }

    // Add point to current stroke
    ref.read(drawingStateProvider.notifier).addPoint(point);
    _lastPoint = point;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isDrawing) return;

    _endStroke();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (!_isDrawing) return;

    ref.read(drawingStateProvider.notifier).cancelStroke();
    _cleanup();
  }

  Future<void> _endStroke() async {
    final drawingState = ref.read(drawingStateProvider);
    final currentStroke = drawingState.currentStroke;
    final currentLayerId = drawingState.currentLayerId;

    if (currentStroke == null || currentLayerId == null || currentStroke.points.isEmpty) {
      _cleanup();
      return;
    }

    // End stroke in drawing state
    ref.read(drawingStateProvider.notifier).endStroke();

    // Get the active layer and capture before image
    final layerStack = ref.read(layerStackProvider);
    final activeLayer = layerStack.layers.firstWhere(
      (layer) => layer.id == currentLayerId,
      orElse: () => throw Exception('Active layer not found'),
    );

    // Create command
    final command = BrushStrokeCommand(
      ref: ref,
      layerId: currentLayerId,
      stroke: currentStroke,
    );

    // Execute command through history (this will capture before state)
    await ref.read(historyControllerProvider.notifier).execute(command);

    // Bake the stroke into the layer image
    final canvasState = ref.read(canvasControllerProvider);
    final updatedImage = await LayerCompositor.renderLayerToImage(
      layer: activeLayer,
      size: canvasState.canvasSize,
      strokes: [currentStroke],
    );

    // Set after image and update layer
    command.setAfterImage(updatedImage);
    ref.read(layerStackProvider.notifier).setLayerImage(currentLayerId, updatedImage);

    // Clear the stroke from drawing state
    ref.read(drawingStateProvider.notifier).clearLayer(currentLayerId);

    _cleanup();
  }

  void _cleanup() {
    _isDrawing = false;
    _lastPoint = null;
    _stabilizer?.reset();
    _stabilizer = null;
    _pressureSimulator = null;
  }
}
