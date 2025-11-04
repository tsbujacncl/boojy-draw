import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/selection.dart';
import '../../providers/selection_controller.dart';
import '../../providers/canvas_controller.dart';

/// Lasso selection tool for creating freehand selections
class LassoSelectionTool extends ConsumerStatefulWidget {
  final Widget child;

  const LassoSelectionTool({super.key, required this.child});

  @override
  ConsumerState<LassoSelectionTool> createState() => _LassoSelectionToolState();
}

class _LassoSelectionToolState extends ConsumerState<LassoSelectionTool> {
  List<Offset> _points = [];
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
          if (_isSelecting && _points.isNotEmpty)
            _LassoOverlay(points: _points),
        ],
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;

    final canvasState = ref.read(canvasControllerProvider);
    final selectionController = ref.read(selectionControllerProvider.notifier);

    final canvasPosition = canvasState.screenToCanvas(
      event.localPosition,
      context.size ?? Size.zero,
    );

    _mode = _getSelectionMode(
      event.kind == PointerDeviceKind.mouse
          ? HardwareKeyboard.instance.logicalKeysPressed
          : {},
    );
    selectionController.setMode(_mode);

    setState(() {
      _points = [canvasPosition];
      _isSelecting = true;
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isSelecting) return;

    final canvasState = ref.read(canvasControllerProvider);
    final canvasPosition = canvasState.screenToCanvas(
      event.localPosition,
      context.size ?? Size.zero,
    );

    setState(() {
      _points.add(canvasPosition);
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isSelecting || _points.length < 3) {
      _cleanup();
      return;
    }

    final selectionController = ref.read(selectionControllerProvider.notifier);
    selectionController.selectLasso(_points, mode: _mode);

    _cleanup();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _cleanup();
  }

  void _cleanup() {
    setState(() {
      _isSelecting = false;
      _points = [];
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

/// Overlay showing the lasso path being drawn
class _LassoOverlay extends StatelessWidget {
  final List<Offset> points;

  const _LassoOverlay({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LassoOverlayPainter(points: points),
      size: Size.infinite,
    );
  }
}

/// Custom painter for the lasso path
class _LassoOverlayPainter extends CustomPainter {
  final List<Offset> points;

  _LassoOverlayPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Draw the path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    // Close path visually
    path.lineTo(points.first.dx, points.first.dy);

    // Draw semi-transparent fill
    final fillPaint = Paint()
      ..color = const Color(0x33007AFF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFF007AFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_LassoOverlayPainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}
