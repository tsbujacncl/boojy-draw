import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/canvas_state.dart';
import '../providers/transform_controller.dart';
import '../providers/selection_controller.dart';
import '../providers/canvas_controller.dart';

/// Transform tool for moving, scaling, and rotating selections
class TransformTool extends ConsumerStatefulWidget {
  final Widget child;

  const TransformTool({super.key, required this.child});

  @override
  ConsumerState<TransformTool> createState() => _TransformToolState();
}

enum _Handle {
  topLeft,
  topCenter,
  topRight,
  middleRight,
  bottomRight,
  bottomCenter,
  bottomLeft,
  middleLeft,
  rotation,
  move,
}

class _TransformToolState extends ConsumerState<TransformTool> {
  _Handle? _activeHandle;
  Offset? _lastPointerPosition;

  @override
  Widget build(BuildContext context) {
    final transformState = ref.watch(transformControllerProvider);
    final selectionState = ref.watch(selectionControllerProvider);
    final canvasState = ref.watch(canvasControllerProvider);

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: [
          // Canvas content
          Listener(
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            child: widget.child,
          ),

          // Transform overlay
          if (transformState != null || selectionState.hasSelection)
            _buildTransformOverlay(
              transformState,
              selectionState,
              canvasState,
            ),
        ],
      ),
    );
  }

  Widget _buildTransformOverlay(
    dynamic transformState,
    SelectionState selectionState,
    CanvasState canvasState,
  ) {
    // Calculate the bounds to transform
    Rect bounds;
    if (transformState != null) {
      bounds = transformState.transformedBounds;
    } else if (selectionState.hasSelection) {
      bounds = selectionState.selection!.bounds!;
    } else {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _TransformOverlayPainter(
        bounds: bounds,
        canvasState: canvasState,
        activeHandle: _activeHandle,
      ),
      child: Stack(
        children: _buildHandles(bounds, canvasState),
      ),
    );
  }

  List<Widget> _buildHandles(Rect bounds, CanvasState canvasState) {
    final handles = <Widget>[];

    // Convert canvas coordinates to screen coordinates
    Offset canvasToScreen(Offset point) {
      final centerOffset = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );

      return Offset(
        (point.dx - canvasState.canvasSize.width / 2) * canvasState.zoom +
            centerOffset.dx +
            canvasState.panOffset.dx,
        (point.dy - canvasState.canvasSize.height / 2) * canvasState.zoom +
            centerOffset.dy +
            canvasState.panOffset.dy,
      );
    }

    const handleSize = 12.0;
    final handleHalfSize = handleSize / 2;

    // Define handle positions
    final handlePositions = {
      _Handle.topLeft: bounds.topLeft,
      _Handle.topCenter: Offset(bounds.center.dx, bounds.top),
      _Handle.topRight: bounds.topRight,
      _Handle.middleRight: Offset(bounds.right, bounds.center.dy),
      _Handle.bottomRight: bounds.bottomRight,
      _Handle.bottomCenter: Offset(bounds.center.dx, bounds.bottom),
      _Handle.bottomLeft: bounds.bottomLeft,
      _Handle.middleLeft: Offset(bounds.left, bounds.center.dy),
    };

    // Add rotation handle (above top center)
    final rotationY = bounds.top - 40 / canvasState.zoom;
    final rotationHandlePos = Offset(bounds.center.dx, rotationY);

    // Create handles
    for (final entry in handlePositions.entries) {
      final screenPos = canvasToScreen(entry.value);
      handles.add(
        Positioned(
          left: screenPos.dx - handleHalfSize,
          top: screenPos.dy - handleHalfSize,
          child: _buildHandle(entry.key, handleSize),
        ),
      );
    }

    // Add rotation handle
    final rotationScreenPos = canvasToScreen(rotationHandlePos);
    handles.add(
      Positioned(
        left: rotationScreenPos.dx - handleHalfSize,
        top: rotationScreenPos.dy - handleHalfSize,
        child: _buildRotationHandle(handleSize),
      ),
    );

    return handles;
  }

  Widget _buildHandle(_Handle handle, double size) {
    final isActive = _activeHandle == handle;

    return MouseRegion(
      cursor: _getHandleCursor(handle),
      child: GestureDetector(
        onPanStart: (details) => _onHandleDragStart(handle, details),
        onPanUpdate: (details) => _onHandleDragUpdate(handle, details),
        onPanEnd: (details) => _onHandleDragEnd(handle, details),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
            shape: BoxShape.rectangle,
          ),
        ),
      ),
    );
  }

  Widget _buildRotationHandle(double size) {
    final isActive = _activeHandle == _Handle.rotation;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onPanStart: (details) => _onHandleDragStart(_Handle.rotation, details),
        onPanUpdate: (details) => _onHandleDragUpdate(_Handle.rotation, details),
        onPanEnd: (details) => _onHandleDragEnd(_Handle.rotation, details),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.refresh,
            size: 8,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  SystemMouseCursor _getHandleCursor(_Handle handle) {
    switch (handle) {
      case _Handle.topLeft:
      case _Handle.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case _Handle.topRight:
      case _Handle.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case _Handle.topCenter:
      case _Handle.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case _Handle.middleLeft:
      case _Handle.middleRight:
        return SystemMouseCursors.resizeLeftRight;
      case _Handle.rotation:
        return SystemMouseCursors.click;
      case _Handle.move:
        return SystemMouseCursors.move;
    }
  }

  void _onHandleDragStart(_Handle handle, DragStartDetails details) {
    setState(() {
      _activeHandle = handle;
      _lastPointerPosition = details.globalPosition;
    });

    // Initialize transform if not already started
    final transformController = ref.read(transformControllerProvider.notifier);
    final selectionState = ref.read(selectionControllerProvider);

    if (ref.read(transformControllerProvider) == null && selectionState.hasSelection) {
      transformController.startTransform(selectionState.selection!.bounds!);
    }
  }

  void _onHandleDragUpdate(_Handle handle, DragUpdateDetails details) {
    if (_lastPointerPosition == null) return;

    final delta = details.globalPosition - _lastPointerPosition!;
    _lastPointerPosition = details.globalPosition;

    final transformController = ref.read(transformControllerProvider.notifier);
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    switch (handle) {
      case _Handle.topLeft:
      case _Handle.topCenter:
      case _Handle.topRight:
      case _Handle.middleRight:
      case _Handle.bottomRight:
      case _Handle.bottomCenter:
      case _Handle.bottomLeft:
      case _Handle.middleLeft:
        // Scale operation
        transformController.scale(
          details.globalPosition,
          delta,
          isShiftPressed, // Constrain aspect ratio with Shift
        );
        break;

      case _Handle.rotation:
        // Rotation operation
        final transformState = ref.read(transformControllerProvider);
        if (transformState != null) {
          final center = transformState.originalBounds.center;
          final angle = (details.globalPosition - Offset(center.dx, center.dy))
              .direction;
          transformController.rotate(angle, snap: isShiftPressed);
        }
        break;

      case _Handle.move:
        // Move operation
        transformController.move(delta);
        break;
    }
  }

  void _onHandleDragEnd(_Handle handle, DragEndDetails details) {
    setState(() {
      _activeHandle = null;
      _lastPointerPosition = null;
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    // Check if clicking inside bounds to start move
    final transformState = ref.read(transformControllerProvider);
    final selectionState = ref.read(selectionControllerProvider);

    if (transformState != null || selectionState.hasSelection) {
      setState(() {
        _activeHandle = _Handle.move;
      });
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_activeHandle == _Handle.move && _lastPointerPosition != null) {
      final delta = event.position - _lastPointerPosition!;
      ref.read(transformControllerProvider.notifier).move(delta);
      _lastPointerPosition = event.position;
    } else if (_activeHandle == _Handle.move) {
      _lastPointerPosition = event.position;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    setState(() {
      _activeHandle = null;
      _lastPointerPosition = null;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final transformController = ref.read(transformControllerProvider.notifier);

    // Enter: Apply transform
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (transformController.hasTransform) {
        transformController.applyTransform();
        return KeyEventResult.handled;
      }
    }

    // Escape: Cancel transform
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (transformController.hasTransform) {
        transformController.cancelTransform();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}

/// Custom painter for the transform overlay
class _TransformOverlayPainter extends CustomPainter {
  final Rect bounds;
  final CanvasState canvasState;
  final _Handle? activeHandle;

  _TransformOverlayPainter({
    required this.bounds,
    required this.canvasState,
    this.activeHandle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Transform to screen coordinates
    final centerOffset = Offset(
      size.width / 2,
      size.height / 2,
    );

    canvas.save();
    canvas.translate(
      centerOffset.dx + canvasState.panOffset.dx,
      centerOffset.dy + canvasState.panOffset.dy,
    );
    canvas.scale(canvasState.zoom);

    // Draw transform bounds
    final boundsRect = Rect.fromCenter(
      center: bounds.center - Offset(
        canvasState.canvasSize.width / 2,
        canvasState.canvasSize.height / 2,
      ),
      width: bounds.width,
      height: bounds.height,
    );

    final boundsPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / canvasState.zoom;

    canvas.drawRect(boundsRect, boundsPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TransformOverlayPainter oldDelegate) {
    return oldDelegate.bounds != bounds ||
        oldDelegate.canvasState != canvasState ||
        oldDelegate.activeHandle != activeHandle;
  }
}
