import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'layer.dart';

/// Represents a .draw file format (v0.1)
/// File structure:
/// - manifest.json: Canvas metadata, layer info, settings
/// - layers/[layer_id].png: Layer image data
/// - thumbnail.png: 512x512 preview image
class DrawFile {
  final String version;
  final DrawFileMetadata metadata;
  final CanvasData canvas;
  final List<LayerData> layers;
  final ui.Image? thumbnail;

  const DrawFile({
    this.version = '0.1',
    required this.metadata,
    required this.canvas,
    required this.layers,
    this.thumbnail,
  });

  /// Convert to JSON for manifest.json
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'metadata': metadata.toJson(),
      'canvas': canvas.toJson(),
      'layers': layers.map((l) => l.toJson()).toList(),
    };
  }

  /// Create from JSON (manifest.json)
  factory DrawFile.fromJson(Map<String, dynamic> json) {
    return DrawFile(
      version: json['version'] as String? ?? '0.1',
      metadata: DrawFileMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      canvas: CanvasData.fromJson(json['canvas'] as Map<String, dynamic>),
      layers: (json['layers'] as List)
          .map((l) => LayerData.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Metadata about the draw file
class DrawFileMetadata {
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String appVersion;

  const DrawFileMetadata({
    required this.title,
    this.createdBy = 'Boojy Draw',
    required this.createdAt,
    required this.modifiedAt,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'appVersion': appVersion,
    };
  }

  factory DrawFileMetadata.fromJson(Map<String, dynamic> json) {
    return DrawFileMetadata(
      title: json['title'] as String,
      createdBy: json['createdBy'] as String? ?? 'Boojy Draw',
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      appVersion: json['appVersion'] as String,
    );
  }

  DrawFileMetadata copyWith({
    String? title,
    String? createdBy,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? appVersion,
  }) {
    return DrawFileMetadata(
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

/// Canvas data for the draw file
class CanvasData {
  final Size size;
  final Color backgroundColor;
  final double zoom;
  final Offset panOffset;
  final double rotation;

  const CanvasData({
    required this.size,
    required this.backgroundColor,
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'width': size.width,
      'height': size.height,
      'backgroundColor': backgroundColor.toARGB32(),
      'zoom': zoom,
      'panOffsetX': panOffset.dx,
      'panOffsetY': panOffset.dy,
      'rotation': rotation,
    };
  }

  factory CanvasData.fromJson(Map<String, dynamic> json) {
    return CanvasData(
      size: Size(
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      ),
      backgroundColor: Color(json['backgroundColor'] as int),
      zoom: (json['zoom'] as num?)?.toDouble() ?? 1.0,
      panOffset: Offset(
        (json['panOffsetX'] as num?)?.toDouble() ?? 0.0,
        (json['panOffsetY'] as num?)?.toDouble() ?? 0.0,
      ),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Layer data for the draw file
class LayerData {
  final String id;
  final String name;
  final double opacity;
  final bool visible;
  final bool locked;
  final BlendMode blendMode;
  final int order; // Bottom to top (0 = bottom)
  final DateTime createdAt;
  final DateTime modifiedAt;

  const LayerData({
    required this.id,
    required this.name,
    this.opacity = 1.0,
    this.visible = true,
    this.locked = false,
    this.blendMode = BlendMode.srcOver,
    required this.order,
    required this.createdAt,
    required this.modifiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'opacity': opacity,
      'visible': visible,
      'locked': locked,
      'blendMode': blendMode.name,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  factory LayerData.fromJson(Map<String, dynamic> json) {
    return LayerData(
      id: json['id'] as String,
      name: json['name'] as String,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      visible: json['visible'] as bool? ?? true,
      locked: json['locked'] as bool? ?? false,
      blendMode: _parseBlendMode(json['blendMode'] as String?),
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }

  /// Convert from Layer model
  factory LayerData.fromLayer(Layer layer, int order) {
    return LayerData(
      id: layer.id,
      name: layer.name,
      opacity: layer.opacity,
      visible: layer.visible,
      locked: layer.locked,
      blendMode: layer.blendMode,
      order: order,
      createdAt: layer.createdAt,
      modifiedAt: layer.modifiedAt,
    );
  }

  static BlendMode _parseBlendMode(String? mode) {
    if (mode == null) return BlendMode.srcOver;

    try {
      return BlendMode.values.firstWhere(
        (bm) => bm.name == mode,
        orElse: () => BlendMode.srcOver,
      );
    } catch (e) {
      return BlendMode.srcOver;
    }
  }
}
