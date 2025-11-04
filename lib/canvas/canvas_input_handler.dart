import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/canvas_controller.dart';
import '../providers/tool_controller.dart';
import '../providers/selection_controller.dart';
import '../providers/document_controller.dart';
import '../models/tool_type.dart';
import '../ui/dialogs/file_dialogs.dart';

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

      // File operations
      final documentController = ref.read(documentControllerProvider.notifier);
      final isShift = HardwareKeyboard.instance.isShiftPressed;

      // Cmd/Ctrl + S (Save)
      if (isModifier && !isShift && event.logicalKey == LogicalKeyboardKey.keyS) {
        _handleSave(documentController);
        return KeyEventResult.handled;
      }

      // Cmd/Ctrl + Shift + S (Save As)
      if (isModifier && isShift && event.logicalKey == LogicalKeyboardKey.keyS) {
        _handleSaveAs();
        return KeyEventResult.handled;
      }

      // Cmd/Ctrl + O (Open)
      if (isModifier && event.logicalKey == LogicalKeyboardKey.keyO) {
        _handleOpen();
        return KeyEventResult.handled;
      }

      // Cmd/Ctrl + N (New)
      if (isModifier && event.logicalKey == LogicalKeyboardKey.keyN) {
        _handleNew();
        return KeyEventResult.handled;
      }

      // Selection commands
      final selectionController = ref.read(selectionControllerProvider.notifier);
      final canvasState = ref.read(canvasControllerProvider);

      // Cmd/Ctrl + A (Select All)
      if (isModifier && event.logicalKey == LogicalKeyboardKey.keyA) {
        selectionController.selectAll(canvasState.canvasSize);
        return KeyEventResult.handled;
      }

      // Cmd/Ctrl + D (Deselect)
      if (isModifier && event.logicalKey == LogicalKeyboardKey.keyD) {
        selectionController.clearSelection();
        return KeyEventResult.handled;
      }

      // Tool switching shortcuts (only if no modifier keys)
      if (!isModifier) {
        final toolController = ref.read(toolControllerProvider.notifier);

        // B key - Brush tool
        if (event.logicalKey == LogicalKeyboardKey.keyB) {
          toolController.setTool(ToolType.brush);
          return KeyEventResult.handled;
        }

        // M key - Rectangle Selection tool
        if (event.logicalKey == LogicalKeyboardKey.keyM) {
          toolController.setTool(ToolType.rectangleSelection);
          return KeyEventResult.handled;
        }

        // L key - Lasso Selection tool
        if (event.logicalKey == LogicalKeyboardKey.keyL) {
          toolController.setTool(ToolType.lassoSelection);
          return KeyEventResult.handled;
        }

        // W key - Magic Wand tool
        if (event.logicalKey == LogicalKeyboardKey.keyW) {
          toolController.setTool(ToolType.magicWand);
          return KeyEventResult.handled;
        }

        // V key - Transform tool
        if (event.logicalKey == LogicalKeyboardKey.keyV) {
          toolController.setTool(ToolType.transform);
          return KeyEventResult.handled;
        }

        // I key - Eyedropper tool
        if (event.logicalKey == LogicalKeyboardKey.keyI) {
          toolController.setTool(ToolType.eyedropper);
          return KeyEventResult.handled;
        }
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

  // File operation handlers
  Future<void> _handleSave(DocumentController controller) async {
    final success = await controller.save();
    if (!success && mounted) {
      // No path, need Save As dialog
      await _handleSaveAs();
    }
  }

  Future<void> _handleSaveAs() async {
    if (!mounted) return;

    final filePath = await showSaveDialog(context);
    if (filePath != null) {
      final controller = ref.read(documentControllerProvider.notifier);
      await controller.saveAs(filePath);
    }
  }

  Future<void> _handleOpen() async {
    if (!mounted) return;

    // Check for unsaved changes
    final documentState = ref.read(documentControllerProvider);
    if (documentState.isModified) {
      final shouldSave = await showUnsavedChangesDialog(context);
      if (!mounted || shouldSave == null) return; // Canceled

      if (shouldSave) {
        // Save before opening
        final controller = ref.read(documentControllerProvider.notifier);
        final saved = await controller.save();
        if (!mounted) return;
        if (!saved) {
          // Need Save As
          final filePath = await showSaveDialog(context);
          if (!mounted || filePath == null) return; // Canceled save
          await controller.saveAs(filePath);
        }
      }
    }

    if (!mounted) return;
    // Show open dialog
    final filePath = await showOpenDialog(context);
    if (!mounted || filePath == null) return;

    final controller = ref.read(documentControllerProvider.notifier);
    await controller.load(filePath);
  }

  Future<void> _handleNew() async {
    if (!mounted) return;

    // Check for unsaved changes
    final documentState = ref.read(documentControllerProvider);
    if (documentState.isModified) {
      final shouldSave = await showUnsavedChangesDialog(context);
      if (!mounted || shouldSave == null) return; // Canceled

      if (shouldSave) {
        // Save before creating new
        final controller = ref.read(documentControllerProvider.notifier);
        final saved = await controller.save();
        if (!mounted) return;
        if (!saved) {
          // Need Save As
          final filePath = await showSaveDialog(context);
          if (!mounted || filePath == null) return; // Canceled save
          await controller.saveAs(filePath);
        }
      }
    }

    // Create new document
    final controller = ref.read(documentControllerProvider.notifier);
    await controller.newDocument();
  }
}
