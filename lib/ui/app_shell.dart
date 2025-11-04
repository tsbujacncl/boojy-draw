import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'canvas_viewport.dart';
import 'dialogs/new_canvas_dialog.dart';
import 'dialogs/file_dialogs.dart';
import 'panels/layers_panel.dart';
import 'panels/color_picker_panel.dart';
import 'widgets/tool_selector.dart';
import '../providers/canvas_controller.dart';
import '../providers/brush_controller.dart';
import '../providers/tool_controller.dart';
import '../providers/selection_controller.dart';
import '../providers/document_controller.dart';
import '../providers/layer_stack_controller.dart';
import '../providers/history_controller.dart';
import '../services/file_io_service.dart';
import '../models/brush_stroke.dart';
import '../models/tool_type.dart';

/// Main application shell with collapsible panels
/// Layout: TopBar | LeftPanel | Canvas | RightPanel | BottomBar
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // Panel visibility state
  bool _leftPanelVisible = true;
  bool _rightPanelVisible = true;

  // Panel widths
  static const double _leftPanelWidth = 250;
  static const double _rightPanelWidth = 280;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top bar with menu and toolbar
          _buildTopBar(),

          // Main content area
          Expanded(
            child: Row(
              children: [
                // Left panel (tool options)
                if (_leftPanelVisible) _buildLeftPanel(),

                // Canvas area (center)
                Expanded(
                  child: _buildCanvasArea(),
                ),

                // Right panel (layers + color picker)
                if (_rightPanelVisible) _buildRightPanel(),
              ],
            ),
          ),

          // Bottom status bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  /// Top bar with menu and toolbar
  Widget _buildTopBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // App icon/title
          Icon(
            Icons.brush,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Boojy Draw',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 32),

          // Menu items
          _buildMenuButton('File'),
          _buildMenuButton('Edit'),
          _buildMenuButton('View'),
          _buildMenuButton('Layer'),
          _buildMenuButton('Select'),
          _buildMenuButton('Help'),

          const SizedBox(width: 24),

          // Tool selector
          const ToolSelector(),

          const Spacer(),

          // History (Undo/Redo)
          Consumer(
            builder: (context, ref, child) {
              final historyState = ref.watch(historyControllerProvider);
              final historyController = ref.read(historyControllerProvider.notifier);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    tooltip: 'Undo (Cmd+Z)',
                    onPressed: historyState.canUndo
                        ? () => historyController.undo()
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    tooltip: 'Redo (Cmd+Shift+Z)',
                    onPressed: historyState.canRedo
                        ? () => historyController.redo()
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),

          // Quick tools
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Canvas (Cmd+N)',
            onPressed: _handleNew,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Open (Cmd+O)',
            onPressed: _handleOpen,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save (Cmd+S)',
            onPressed: _handleSave,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More',
            onSelected: (value) {
              switch (value) {
                case 'save_as':
                  _handleSaveAs();
                  break;
                case 'export_png':
                  _handleExportPNG();
                  break;
                case 'export_jpg':
                  _handleExportJPG();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save_as',
                child: ListTile(
                  leading: Icon(Icons.save_as),
                  title: Text('Save As...'),
                  subtitle: Text('Cmd+Shift+S'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'export_png',
                child: ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Export PNG...'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export_jpg',
                child: ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Export JPG...'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String label) {
    return TextButton(
      onPressed: () {
        // TODO: Implement menu
      },
      child: Text(label),
    );
  }

  /// Left panel with tool options
  Widget _buildLeftPanel() {
    final brushSettings = ref.watch(brushControllerProvider);
    final brushController = ref.read(brushControllerProvider.notifier);
    final toolState = ref.watch(toolControllerProvider);
    final selectionState = ref.watch(selectionControllerProvider);
    final selectionController = ref.read(selectionControllerProvider.notifier);

    return Container(
      width: _leftPanelWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          _buildPanelHeader(
            'Tool Options',
            onClose: () => setState(() => _leftPanelVisible = false),
          ),

          // Tool options content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Brush tool options
                if (toolState.activeTool == ToolType.brush) ...[
                  Text(
                    'Brush Settings',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),

                  // Brush size slider
                  _buildSlider(
                    'Size',
                    brushSettings.size,
                    1,
                    500,
                    (value) => brushController.setSize(value),
                  ),
                  const SizedBox(height: 16),

                  // Opacity slider
                  _buildSlider(
                    'Opacity',
                    brushSettings.opacity * 100,
                    0,
                    100,
                    (value) => brushController.setOpacity(value / 100),
                  ),
                  const SizedBox(height: 16),

                  // Pressure curve dropdown
                  Text(
                    'Pressure Curve',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PressureCurve>(
                    initialValue: brushSettings.pressureCurve,
                    items: PressureCurve.values
                        .map((curve) => DropdownMenuItem(
                              value: curve,
                              child: Text(curve.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        brushController.setPressureCurve(value);
                      }
                    },
                  ),
                ],

                // Selection tool options
                if (toolState.activeTool == ToolType.rectangleSelection ||
                    toolState.activeTool == ToolType.lassoSelection ||
                    toolState.activeTool == ToolType.magicWand) ...[
                  Text(
                    'Selection Settings',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),

                  // Magic Wand tolerance slider
                  if (toolState.activeTool == ToolType.magicWand) ...[
                    _buildSlider(
                      'Tolerance',
                      selectionState.tolerance.toDouble(),
                      0,
                      100,
                      (value) => selectionController.setTolerance(value.toInt()),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Feather slider (all selection tools)
                  _buildSlider(
                    'Feather',
                    selectionState.feather,
                    0,
                    100,
                    (value) => selectionController.setFeather(value),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Modifiers',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Shift: Add to selection\n'
                    '• Alt: Subtract from selection\n'
                    '• Shift+Alt: Intersect selection',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Right panel with layers and color picker
  Widget _buildRightPanel() {
    return Container(
      width: _rightPanelWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Layers panel
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildPanelHeader(
                  'Layers',
                  onClose: () => setState(() => _rightPanelVisible = false),
                ),
                const Expanded(
                  child: LayersPanel(),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),

          // Color picker panel
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPanelHeader('Color'),
                const Expanded(
                  child: ColorPickerPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Canvas area (center)
  Widget _buildCanvasArea() {
    return const CanvasViewport();
  }

  /// Bottom status bar
  Widget _buildBottomBar() {
    final canvasState = ref.watch(canvasControllerProvider);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Toggle panels
          IconButton(
            icon: Icon(
              _leftPanelVisible ? Icons.chevron_left : Icons.chevron_right,
              size: 18,
            ),
            tooltip: 'Toggle Left Panel',
            onPressed: () => setState(() => _leftPanelVisible = !_leftPanelVisible),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),

          // Status info (live from canvas state)
          Text(
            'Zoom: ${canvasState.zoomPercentage}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 24),
          Text(
            'Canvas: ${canvasState.dimensionsString}',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const Spacer(),

          // Undo/Redo status
          Consumer(
            builder: (context, ref, child) {
              final historyState = ref.watch(historyControllerProvider);
              final historyController = ref.read(historyControllerProvider.notifier);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Undo count indicator
                  if (historyState.undoCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${historyState.undoCount} action${historyState.undoCount > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.undo, size: 18),
                    tooltip: historyState.canUndo
                        ? 'Undo ${historyState.undoDescription} (Cmd+Z)'
                        : 'Nothing to undo',
                    onPressed: historyState.canUndo
                        ? () => historyController.undo()
                        : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.redo, size: 18),
                    tooltip: historyState.canRedo
                        ? 'Redo ${historyState.redoDescription} (Cmd+Shift+Z)'
                        : 'Nothing to redo',
                    onPressed: historyState.canRedo
                        ? () => historyController.redo()
                        : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 16),

          // Toggle right panel
          IconButton(
            icon: Icon(
              _rightPanelVisible ? Icons.chevron_right : Icons.chevron_left,
              size: 18,
            ),
            tooltip: 'Toggle Right Panel',
            onPressed: () => setState(() => _rightPanelVisible = !_rightPanelVisible),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Panel header with title and optional close button
  Widget _buildPanelHeader(String title, {VoidCallback? onClose}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  /// Slider widget with label and callback
  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Show new canvas dialog
  Future<void> _showNewCanvasDialog() async {
    final result = await showNewCanvasDialog(context);

    if (result != null && mounted) {
      final size = result['size'] as Size;
      final backgroundColor = result['backgroundColor'] as Color;

      ref.read(canvasControllerProvider.notifier).newCanvas(
        size: size,
        backgroundColor: backgroundColor,
      );
    }
  }

  // File operation handlers
  Future<void> _handleSave() async {
    final controller = ref.read(documentControllerProvider.notifier);
    final success = await controller.save();
    if (!success && mounted) {
      await _handleSaveAs();
    } else if (success && mounted) {
      _showSnackbar('Project saved successfully');
    }
  }

  Future<void> _handleSaveAs() async {
    if (!mounted) return;

    final filePath = await showSaveDialog(context);
    if (!mounted || filePath == null) return;

    final controller = ref.read(documentControllerProvider.notifier);
    final success = await controller.saveAs(filePath);

    if (!mounted) return;
    if (success) {
      _showSnackbar('Project saved successfully');
    } else {
      _showSnackbar('Failed to save project', isError: true);
    }
  }

  Future<void> _handleOpen() async {
    if (!mounted) return;

    // Check for unsaved changes
    final documentState = ref.read(documentControllerProvider);
    if (documentState.isModified) {
      final shouldSave = await showUnsavedChangesDialog(context);
      if (!mounted || shouldSave == null) return;

      if (shouldSave) {
        await _handleSave();
      }
    }

    if (!mounted) return;
    final filePath = await showOpenDialog(context);
    if (!mounted || filePath == null) return;

    final controller = ref.read(documentControllerProvider.notifier);
    final success = await controller.load(filePath);

    if (!mounted) return;
    if (success) {
      _showSnackbar('Project loaded successfully');
    } else {
      _showSnackbar('Failed to load project', isError: true);
    }
  }

  Future<void> _handleNew() async {
    if (!mounted) return;

    // Check for unsaved changes
    final documentState = ref.read(documentControllerProvider);
    if (documentState.isModified) {
      final shouldSave = await showUnsavedChangesDialog(context);
      if (!mounted || shouldSave == null) return;

      if (shouldSave) {
        await _handleSave();
      }
    }

    if (!mounted) return;
    await _showNewCanvasDialog();
  }

  Future<void> _handleExportPNG() async {
    if (!mounted) return;

    final options = await showExportDialog(context);
    if (!mounted || options == null) return;

    if (options['format'] != 'png') return;

    final filePath = await showExportPNGDialog(context);
    if (!mounted || filePath == null) return;

    final canvasState = ref.read(canvasControllerProvider);
    final layerStackState = ref.read(layerStackProvider);

    final success = await FileIOService.exportPNG(
      filePath: filePath,
      layerStackState: layerStackState,
      canvasSize: canvasState.canvasSize,
      backgroundColor: canvasState.backgroundColor,
      includeTransparency: options['includeTransparency'] as bool,
    );

    if (!mounted) return;
    if (success) {
      _showSnackbar('PNG exported successfully');
    } else {
      _showSnackbar('Failed to export PNG', isError: true);
    }
  }

  Future<void> _handleExportJPG() async {
    if (!mounted) return;

    final options = await showExportDialog(context);
    if (!mounted || options == null) return;

    if (options['format'] != 'jpg') return;

    final filePath = await showExportJPGDialog(context);
    if (!mounted || filePath == null) return;

    final canvasState = ref.read(canvasControllerProvider);
    final layerStackState = ref.read(layerStackProvider);

    final success = await FileIOService.exportJPG(
      filePath: filePath,
      layerStackState: layerStackState,
      canvasSize: canvasState.canvasSize,
      backgroundColor: canvasState.backgroundColor,
      quality: options['quality'] as int,
    );

    if (!mounted) return;
    if (success) {
      _showSnackbar('JPG exported successfully');
    } else {
      _showSnackbar('Failed to export JPG', isError: true);
    }
  }

  /// Show a snackbar message
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: isError
              ? Theme.of(context).colorScheme.onError
              : Theme.of(context).colorScheme.onPrimaryContainer,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
