import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brush_stroke.dart';
import '../models/stroke_point.dart';
import '../providers/brush_controller.dart';
import '../providers/canvas_controller.dart';
import '../providers/drawing_state_controller.dart';
import '../providers/layer_stack_controller.dart';
import 'stroke_stabilizer.dart';

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

  void _endStroke() {
    ref.read(drawingStateProvider.notifier).endStroke();
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
