import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/canvas_controller.dart';

/// Handles input events for canvas (zoom, pan, etc.)
class CanvasInputHandler extends ConsumerStatefulWidget {
  final Widget child;
  final Size viewportSize;

  const CanvasInputHandler({
    super.key,
    required this.child,
    required this.viewportSize,
  });

  @override
  ConsumerState<CanvasInputHandler> createState() =>
      _CanvasInputHandlerState();
}

class _CanvasInputHandlerState extends ConsumerState<CanvasInputHandler> {
  bool _isSpacePressed = false;
  bool _isPanning = false;
  Offset? _lastPanPosition;

  // Focus node for keyboard shortcuts
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus for keyboard shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerSignal: _handlePointerSignal,
        child: MouseRegion(
          cursor: _getCursor(),
          child: widget.child,
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final controller = ref.read(canvasControllerProvider.notifier);

    // Track space key for panning
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent || event is KeyRepeatEvent) {
        setState(() => _isSpacePressed = true);
        return KeyEventResult.handled;
      } else if (event is KeyUpEvent) {
        setState(() {
          _isSpacePressed = false;
          _isPanning = false;
          _lastPanPosition = null;
        });
        return KeyEventResult.handled;
      }
    }

    // Zoom shortcuts
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final isMeta = event.logicalKey == LogicalKeyboardKey.meta ||
          event.logicalKey == LogicalKeyboardKey.metaLeft ||
          event.logicalKey == LogicalKeyboardKey.metaRight;

      final isControl = event.logicalKey == LogicalKeyboardKey.control ||
          event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight;

      final isModifier = isMeta || isControl;

      // Cmd/Ctrl + Plus (zoom in)
      if (isModifier &&
          (event.logicalKey == LogicalKeyboardKey.equal ||
              event.logicalKey == LogicalKeyboardKey.add)) {
        controller.zoomIn();
        return KeyEventResult.handled;
      }

      // Cmd/Ctrl + Minus (zoom out)
      if (isModifier &&
          (event.logicalKey == LogicalKeyboardKey.minus ||
              event.logicalKey == LogicalKeyboardKey.numpadSubtract)) {
        controller.zoomOut();
        return KeyEventResult.handled;
      }

      // Cmd/Ctrl + 0 (zoom to fit)
      if (isModifier && event.logicalKey == LogicalKeyboardKey.digit0) {
        controller.zoomToFit(widget.viewportSize);
        return KeyEventResult.handled;
      }

      // Cmd/Ctrl + 1 (zoom to 100%)
      if (isModifier && event.logicalKey == LogicalKeyboardKey.digit1) {
        controller.zoomToActualSize();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _handlePointerDown(PointerDownEvent event) {
    // Space + left click or middle mouse button = start panning
    if ((_isSpacePressed && event.buttons == kPrimaryMouseButton) ||
        event.buttons == kMiddleMouseButton) {
      setState(() {
        _isPanning = true;
        _lastPanPosition = event.position;
      });
    }

    // Request focus when clicking on canvas
    _focusNode.requestFocus();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_isPanning && _lastPanPosition != null) {
      final delta = event.position - _lastPanPosition!;
      ref.read(canvasControllerProvider.notifier).panBy(delta);
      _lastPanPosition = event.position;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_isPanning) {
      setState(() {
        _isPanning = false;
        _lastPanPosition = null;
      });
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final controller = ref.read(canvasControllerProvider.notifier);

      // Check if this is a zoom gesture (pinch on trackpad)
      // or a mouse wheel event
      final scrollDelta = event.scrollDelta;

      // Horizontal scroll is usually for pinch-to-zoom on trackpad
      // Vertical scroll with Ctrl/Cmd is also zoom
      final isZoomGesture = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;

      if (isZoomGesture || scrollDelta.dy.abs() > 0) {
        // Mouse wheel zoom
        final zoomDelta = -scrollDelta.dy.sign;
        controller.handleWheelZoom(
          zoomDelta,
          event.position,
          widget.viewportSize,
        );
      }
    }
  }

  MouseCursor _getCursor() {
    if (_isPanning) {
      return SystemMouseCursors.grabbing;
    } else if (_isSpacePressed) {
      return SystemMouseCursors.grab;
    }
    return SystemMouseCursors.basic;
  }
}
