import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tool_type.dart';
import '../../providers/tool_controller.dart';

/// Tool selector widget for switching between tools
class ToolSelector extends ConsumerWidget {
  const ToolSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolState = ref.watch(toolControllerProvider);
    final toolController = ref.read(toolControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolButton(
            context,
            tool: ToolType.brush,
            isActive: toolState.activeTool == ToolType.brush,
            onTap: () => toolController.setTool(ToolType.brush),
          ),
          const SizedBox(width: 4),
          _buildToolButton(
            context,
            tool: ToolType.rectangleSelection,
            isActive: toolState.activeTool == ToolType.rectangleSelection,
            onTap: () => toolController.setTool(ToolType.rectangleSelection),
          ),
          const SizedBox(width: 4),
          _buildToolButton(
            context,
            tool: ToolType.lassoSelection,
            isActive: toolState.activeTool == ToolType.lassoSelection,
            onTap: () => toolController.setTool(ToolType.lassoSelection),
          ),
          const SizedBox(width: 4),
          _buildToolButton(
            context,
            tool: ToolType.magicWand,
            isActive: toolState.activeTool == ToolType.magicWand,
            onTap: () => toolController.setTool(ToolType.magicWand),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required ToolType tool,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tool.tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : null,
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: isActive ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            tool.icon,
            size: 20,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
