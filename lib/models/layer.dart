import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Represents a single layer in the layer stack
class Layer {
  final String id;
  final String name;
  final ui.Image? image; // Raster buffer (null = empty layer)
  final ui.Image? thumbnail; // Small preview image (64x64)
  final double opacity; // 0.0 to 1.0
  final bool visible;
  final bool locked;
  final BlendMode blendMode;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const Layer({
    required this.id,
    required this.name,
    this.image,
    this.thumbnail,
    this.opacity = 1.0,
    this.visible = true,
    this.locked = false,
    this.blendMode = BlendMode.srcOver,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Create a new empty layer
  factory Layer.empty({
    String? name,
    int? index,
  }) {
    final now = DateTime.now();
    final layerName = name ?? 'Layer ${index ?? 1}';

    return Layer(
      id: const Uuid().v4(),
      name: layerName,
      image: null,
      opacity: 1.0,
      visible: true,
      locked: false,
      blendMode: BlendMode.srcOver,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Create default background layer
  factory Layer.background({
    required Size size,
    Color color = Colors.white,
  }) {
    final now = DateTime.now();

    return Layer(
      id: const Uuid().v4(),
      name: 'Background',
      image: null, // Will be filled with color during rendering
      opacity: 1.0,
      visible: true,
      locked: false,
      blendMode: BlendMode.srcOver,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Check if layer is empty (no image data)
  bool get isEmpty => image == null;

  /// Get layer dimensions
  Size get size => image != null
      ? Size(image!.width.toDouble(), image!.height.toDouble())
      : Size.zero;

  Layer copyWith({
    String? id,
    String? name,
    ui.Image? image,
    ui.Image? thumbnail,
    double? opacity,
    bool? visible,
    bool? locked,
    BlendMode? blendMode,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool clearImage = false,
    bool clearThumbnail = false,
  }) {
    return Layer(
      id: id ?? this.id,
      name: name ?? this.name,
      image: clearImage ? null : (image ?? this.image),
      thumbnail: clearThumbnail ? null : (thumbnail ?? this.thumbnail),
      opacity: opacity ?? this.opacity,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      blendMode: blendMode ?? this.blendMode,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Layer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          image == other.image &&
          thumbnail == other.thumbnail &&
          opacity == other.opacity &&
          visible == other.visible &&
          locked == other.locked &&
          blendMode == other.blendMode;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      image.hashCode ^
      thumbnail.hashCode ^
      opacity.hashCode ^
      visible.hashCode ^
      locked.hashCode ^
      blendMode.hashCode;

  @override
  String toString() => 'Layer(id: $id, name: $name, visible: $visible, opacity: $opacity)';
}
