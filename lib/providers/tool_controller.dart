import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tool_type.dart';

/// State for the active tool
class ToolState {
  final ToolType activeTool;

  const ToolState({
    this.activeTool = ToolType.brush,
  });

  ToolState copyWith({
    ToolType? activeTool,
  }) {
    return ToolState(
      activeTool: activeTool ?? this.activeTool,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolState &&
          runtimeType == other.runtimeType &&
          activeTool == other.activeTool;

  @override
  int get hashCode => activeTool.hashCode;
}

/// Controller for managing the active tool
class ToolController extends StateNotifier<ToolState> {
  ToolController() : super(const ToolState());

  /// Set the active tool
  void setTool(ToolType tool) {
    state = state.copyWith(activeTool: tool);
  }

  /// Quick tool selection methods
  void selectBrush() => setTool(ToolType.brush);
  void selectRectangleSelection() => setTool(ToolType.rectangleSelection);
  void selectLassoSelection() => setTool(ToolType.lassoSelection);
  void selectMagicWand() => setTool(ToolType.magicWand);
  void selectTransform() => setTool(ToolType.transform);
  void selectEyedropper() => setTool(ToolType.eyedropper);
}

/// Provider for tool controller
final toolControllerProvider =
    StateNotifierProvider<ToolController, ToolState>(
  (ref) => ToolController(),
);
