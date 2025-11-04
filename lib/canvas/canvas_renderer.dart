import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/canvas_state.dart';
import '../providers/drawing_state_controller.dart';
import '../tools/brush_engine.dart';

/// Custom painter for rendering the canvas
class CanvasRenderer extends CustomPainter {
  final CanvasState canvasState;
  final Size viewportSize;
  final DrawingState drawingState;

  const CanvasRenderer({
    required this.canvasState,
    required this.viewportSize,
    required this.drawingState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Save canvas state
    canvas.save();

    // Center the canvas in viewport
    final centerOffset = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );

    // Apply transformations: pan, zoom, rotation
    canvas.translate(
      centerOffset.dx + canvasState.panOffset.dx,
      centerOffset.dy + canvasState.panOffset.dy,
    );

    canvas.scale(canvasState.zoom);

    if (canvasState.rotation != 0) {
      canvas.rotate(canvasState.rotation);
    }

    // Center the actual canvas rect
    final canvasRect = Rect.fromCenter(
      center: Offset.zero,
      width: canvasState.canvasSize.width,
      height: canvasState.canvasSize.height,
    );

    // Draw checkerboard background (for transparency visualization)
    _drawCheckerboard(canvas, canvasRect);

    // Draw canvas background
    final bgPaint = Paint()..color = canvasState.backgroundColor;
    canvas.drawRect(canvasRect, bgPaint);

    // Draw canvas border
    final borderPaint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / canvasState.zoom; // Keep border thin when zoomed

    canvas.drawRect(canvasRect, borderPaint);

    // Draw committed strokes
    for (final stroke in drawingState.committedStrokes) {
      BrushEngine.renderStroke(canvas, stroke);
    }

    // Draw current stroke being drawn
    if (drawingState.currentStroke != null) {
      BrushEngine.renderStroke(canvas, drawingState.currentStroke!);
    }

    // Restore canvas state
    canvas.restore();

    // Draw viewport info overlay (top-left corner)
    _drawInfoOverlay(canvas, size);
  }

  void _drawCheckerboard(Canvas canvas, Rect rect) {
    const checkerSize = 16.0; // Size of each checker square
    final lightPaint = Paint()..color = const Color(0xFFCCCCCC);
    final darkPaint = Paint()..color = const Color(0xFFAAAAAA);

    final startX = (rect.left / checkerSize).floor() * checkerSize;
    final startY = (rect.top / checkerSize).floor() * checkerSize;
    final endX = rect.right;
    final endY = rect.bottom;

    for (double y = startY; y < endY; y += checkerSize) {
      for (double x = startX; x < endX; x += checkerSize) {
        final checkerRect = Rect.fromLTWH(x, y, checkerSize, checkerSize);

        // Only draw if within canvas bounds
        if (rect.overlaps(checkerRect)) {
          final isEvenRow = ((y - startY) / checkerSize).floor() % 2 == 0;
          final isEvenCol = ((x - startX) / checkerSize).floor() % 2 == 0;
          final isLight = isEvenRow == isEvenCol;

          canvas.drawRect(
            checkerRect.intersect(rect),
            isLight ? lightPaint : darkPaint,
          );
        }
      }
    }
  }

  void _drawInfoOverlay(Canvas canvas, Size size) {
    // Draw subtle info in top-left corner
    final textStyle = ui.TextStyle(
      color: Colors.white.withValues(alpha: 0.7),
      fontSize: 12,
      fontWeight: FontWeight.w500,
      shadows: [
        const Shadow(
          color: Colors.black54,
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    );

    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(textStyle)
      ..addText(
        'Zoom: ${canvasState.zoomPercentage} | '
        'Size: ${canvasState.dimensionsString}',
      );

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size.width));

    canvas.drawParagraph(paragraph, const Offset(12, 12));
  }

  @override
  bool shouldRepaint(CanvasRenderer oldDelegate) {
    return oldDelegate.canvasState != canvasState ||
        oldDelegate.viewportSize != viewportSize ||
        oldDelegate.drawingState != drawingState;
  }

  @override
  bool shouldRebuildSemantics(CanvasRenderer oldDelegate) => false;
}

/// Helper widget that wraps canvas rendering with proper sizing
class CanvasRenderWidget extends StatelessWidget {
  final CanvasState canvasState;
  final DrawingState drawingState;

  const CanvasRenderWidget({
    super.key,
    required this.canvasState,
    required this.drawingState,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return ClipRect(
          child: CustomPaint(
            size: viewportSize,
            painter: CanvasRenderer(
              canvasState: canvasState,
              viewportSize: viewportSize,
              drawingState: drawingState,
            ),
          ),
        );
      },
    );
  }
}
