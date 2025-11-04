import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'canvas_viewport.dart';
import 'dialogs/new_canvas_dialog.dart';
import '../providers/canvas_controller.dart';
import '../providers/brush_controller.dart';
import '../models/brush_stroke.dart';

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

          const Spacer(),

          // Quick tools
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Canvas (Cmd+N)',
            onPressed: _showNewCanvasDialog,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Open (Cmd+O)',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save (Cmd+S)',
            onPressed: () {},
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
                Text(
                  'Brush Settings',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 16),

                // Brush size slider
                _buildBrushSlider(
                  'Size',
                  brushSettings.size,
                  1,
                  500,
                  (value) => brushController.setSize(value),
                ),
                const SizedBox(height: 16),

                // Opacity slider
                _buildBrushSlider(
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        'Layers panel\n(Coming soon)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Color picker\n(Coming soon)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
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

          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo, size: 18),
            tooltip: 'Undo (Cmd+Z)',
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.redo, size: 18),
            tooltip: 'Redo (Cmd+Shift+Z)',
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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

  /// Brush slider widget with label and callback
  Widget _buildBrushSlider(
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
}
