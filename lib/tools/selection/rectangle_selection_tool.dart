import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/selection.dart';
import '../../providers/selection_controller.dart';
import '../../providers/canvas_controller.dart';

/// Rectangle selection tool for creating rectangular selections
class RectangleSelectionTool extends ConsumerStatefulWidget {
  final Widget child;

  const RectangleSelectionTool({super.key, required this.child});

  @override
  ConsumerState<RectangleSelectionTool> createState() =>
      _RectangleSelectionToolState();
}

class _RectangleSelectionToolState
    extends ConsumerState<RectangleSelectionTool> {
  Offset? _startPoint;
  Offset? _currentPoint;
  bool _isSelecting = false;
  SelectionMode _mode = SelectionMode.replace;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          widget.child,
          if (_isSelecting && _startPoint != null && _currentPoint != null)
            _SelectionOverlay(
              startPoint: _startPoint!,
              currentPoint: _currentPoint!,
            ),
        ],
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    // Only handle primary button (left click)
    if (event.buttons != kPrimaryButton) return;

    final canvasState = ref.read(canvasControllerProvider);
    final selectionController = ref.read(selectionControllerProvider.notifier);

    // Convert screen to canvas coordinates
    final canvasPosition = canvasState.screenToCanvas(
      event.localPosition,
      context.size ?? Size.zero,
    );

    // Determine selection mode from modifier keys
    _mode = _getSelectionMode(
      event.kind == PointerDeviceKind.mouse
          ? HardwareKeyboard.instance.logicalKeysPressed
          : {},
    );
    selectionController.setMode(_mode);

    setState(() {
      _startPoint = canvasPosition;
      _currentPoint = canvasPosition;
      _isSelecting = true;
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isSelecting || _startPoint == null) return;

    final canvasState = ref.read(canvasControllerProvider);

    // Convert screen to canvas coordinates
    final canvasPosition = canvasState.screenToCanvas(
      event.localPosition,
      context.size ?? Size.zero,
    );

    setState(() {
      _currentPoint = canvasPosition;
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isSelecting || _startPoint == null || _currentPoint == null) return;

    final selectionController = ref.read(selectionControllerProvider.notifier);

    // Create rectangle from start and current points
    final rect = Rect.fromPoints(_startPoint!, _currentPoint!);

    // Only create selection if rectangle has non-zero area
    if (rect.width.abs() > 1 && rect.height.abs() > 1) {
      selectionController.selectRectangle(rect, mode: _mode);
    }

    _cleanup();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _cleanup();
  }

  void _cleanup() {
    setState(() {
      _isSelecting = false;
      _startPoint = null;
      _currentPoint = null;
      _mode = SelectionMode.replace;
    });
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

/// Overlay widget showing the selection being drawn
class _SelectionOverlay extends StatelessWidget {
  final Offset startPoint;
  final Offset currentPoint;

  const _SelectionOverlay({
    required this.startPoint,
    required this.currentPoint,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SelectionOverlayPainter(
        startPoint: startPoint,
        currentPoint: currentPoint,
      ),
      size: Size.infinite,
    );
  }
}

/// Custom painter for drawing the selection rectangle during creation
class _SelectionOverlayPainter extends CustomPainter {
  final Offset startPoint;
  final Offset currentPoint;

  _SelectionOverlayPainter({
    required this.startPoint,
    required this.currentPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(startPoint, currentPoint);

    // Draw semi-transparent fill
    final fillPaint = Paint()
      ..color = const Color(0x33007AFF)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    // Draw solid border
    final borderPaint = Paint()
      ..color = const Color(0xFF007AFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(_SelectionOverlayPainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.currentPoint != currentPoint;
  }
}
