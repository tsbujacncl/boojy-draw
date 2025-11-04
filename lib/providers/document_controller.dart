import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../services/file_io_service.dart';
import 'canvas_controller.dart';
import 'layer_stack_controller.dart';

/// State for the current document
class DocumentState {
  final String? filePath;
  final String? fileName;
  final bool isModified;
  final bool isSaving;
  final DateTime? lastSaved;
  final DateTime? lastAutosaved;

  const DocumentState({
    this.filePath,
    this.fileName,
    this.isModified = false,
    this.isSaving = false,
    this.lastSaved,
    this.lastAutosaved,
  });

  DocumentState copyWith({
    String? filePath,
    String? fileName,
    bool? isModified,
    bool? isSaving,
    DateTime? lastSaved,
    DateTime? lastAutosaved,
  }) {
    return DocumentState(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      isModified: isModified ?? this.isModified,
      isSaving: isSaving ?? this.isSaving,
      lastSaved: lastSaved ?? this.lastSaved,
      lastAutosaved: lastAutosaved ?? this.lastAutosaved,
    );
  }

  bool get hasPath => filePath != null;
  String get displayName => fileName ?? 'Untitled';
}

/// Controller for managing the current document
class DocumentController extends StateNotifier<DocumentState> {
  final Ref ref;
  Timer? _autosaveTimer;

  DocumentController(this.ref) : super(const DocumentState()) {
    _startAutosave();
  }

  /// Start the autosave timer (every 2 minutes)
  void _startAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _performAutosave(),
    );
  }

  /// Mark document as modified
  void markModified() {
    if (!state.isModified) {
      state = state.copyWith(isModified: true);
    }
  }

  /// Save the current project
  Future<bool> save() async {
    // If no path, use Save As
    if (!state.hasPath) {
      return false; // Caller should show Save As dialog
    }

    return _saveToPath(state.filePath!);
  }

  /// Save the project to a specific path
  Future<bool> saveAs(String filePath) async {
    final success = await _saveToPath(filePath);
    if (success) {
      final fileName = filePath.split(Platform.pathSeparator).last;
      state = state.copyWith(
        filePath: filePath,
        fileName: fileName,
      );
    }
    return success;
  }

  /// Internal save logic
  Future<bool> _saveToPath(String filePath) async {
    try {
      state = state.copyWith(isSaving: true);

      final canvasState = ref.read(canvasControllerProvider);
      final layerStackState = ref.read(layerStackProvider);

      final success = await FileIOService.saveProject(
        filePath: filePath,
        canvasState: canvasState,
        layerStackState: layerStackState,
        title: state.fileName ?? 'Untitled',
      );

      if (success) {
        state = state.copyWith(
          isSaving: false,
          isModified: false,
          lastSaved: DateTime.now(),
        );
      } else {
        state = state.copyWith(isSaving: false);
      }

      return success;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  /// Load a project from a file
  Future<bool> load(String filePath) async {
    try {
      final loaded = await FileIOService.loadProject(filePath);
      if (loaded == null) return false;

      // Update canvas state
      final canvasController = ref.read(canvasControllerProvider.notifier);
      canvasController.newCanvas(
        size: loaded.drawFile.canvas.size,
        backgroundColor: loaded.drawFile.canvas.backgroundColor,
      );
      canvasController.setZoom(loaded.drawFile.canvas.zoom);
      canvasController.panBy(loaded.drawFile.canvas.panOffset);

      // Replace layer stack with loaded layers
      final layerStackController = ref.read(layerStackProvider.notifier);
      // Directly set the new layer stack state
      layerStackController.state = LayerStackState(
        layers: loaded.layers,
        activeLayerId: loaded.layers.isNotEmpty ? loaded.layers.first.id : null,
      );

      // Update document state
      final fileName = filePath.split(Platform.pathSeparator).last;
      state = DocumentState(
        filePath: filePath,
        fileName: fileName,
        isModified: false,
        lastSaved: loaded.drawFile.metadata.modifiedAt,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a new document (reset to defaults)
  Future<void> newDocument() async {
    // Create default canvas
    final canvasController = ref.read(canvasControllerProvider.notifier);
    canvasController.newCanvas(
      size: const Size(800, 600),
      backgroundColor: const Color(0xFFFFFFFF),
    );

    // Clear all layers and create a new one
    final layerStackController = ref.read(layerStackProvider.notifier);
    final currentLayers = ref.read(layerStackProvider).layers;
    for (final layer in currentLayers) {
      layerStackController.deleteLayer(layer.id);
    }
    layerStackController.addLayer();

    // Reset document state
    state = const DocumentState();
  }

  /// Perform autosave
  Future<void> _performAutosave() async {
    // Only autosave if modified
    if (!state.isModified || state.isSaving) return;

    try {
      // Get autosave directory
      final docsDir = await getApplicationDocumentsDirectory();
      final autosaveDir = Directory('${docsDir.path}/Boojy/Autosaves');
      await autosaveDir.create(recursive: true);

      // Generate autosave filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final autosavePath = '${autosaveDir.path}/autosave_$timestamp.draw';

      // Save
      final canvasState = ref.read(canvasControllerProvider);
      final layerStackState = ref.read(layerStackProvider);

      await FileIOService.saveProject(
        filePath: autosavePath,
        canvasState: canvasState,
        layerStackState: layerStackState,
        title: state.fileName ?? 'Untitled (Autosave)',
      );

      state = state.copyWith(lastAutosaved: DateTime.now());

      // Clean up old autosaves (keep only last 3)
      await _cleanupAutosaves(autosaveDir);
    } catch (e) {
      // Autosave failed, but don't show error to user
    }
  }

  /// Clean up old autosaves, keeping only the last 3
  Future<void> _cleanupAutosaves(Directory autosaveDir) async {
    try {
      final files = autosaveDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.draw'))
          .toList();

      // Sort by modification time (newest first)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      // Delete all but the last 3
      for (int i = 3; i < files.length; i++) {
        await files[i].delete();
      }
    } catch (e) {
      // Cleanup failed, but don't show error
    }
  }

  /// Check for autosave recovery on launch
  static Future<List<File>> findAutosaves() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final autosaveDir = Directory('${docsDir.path}/Boojy/Autosaves');

      if (!await autosaveDir.exists()) {
        return [];
      }

      final files = autosaveDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.draw'))
          .toList();

      // Sort by modification time (newest first)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      return files;
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }
}

/// Provider for document controller
final documentControllerProvider =
    StateNotifierProvider<DocumentController, DocumentState>(
  (ref) => DocumentController(ref),
);
