import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/brush_stroke.dart';
import '../models/layer.dart';
import 'brush_engine.dart';

/// Helper for compositing layers and rendering strokes to layers
class LayerCompositor {
  /// Render strokes onto a layer image
  static Future<ui.Image> renderStrokesToImage({
    required List<BrushStroke> strokes,
    required Size size,
    Color? backgroundColor,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw background if provided
    if (backgroundColor != null) {
      final bgPaint = Paint()..color = backgroundColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        bgPaint,
      );
    }

    // Render all strokes
    for (final stroke in strokes) {
      BrushEngine.renderStroke(canvas, stroke);
    }

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  /// Composite multiple layers into a single image
  static Future<ui.Image> compositeLayersToImage({
    required List<Layer> layers,
    required Size canvasSize,
    Map<String, List<BrushStroke>>? layerStrokes,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Composite each layer in order (bottom to top)
    for (final layer in layers) {
      if (!layer.visible) continue;

      canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: layer.opacity));

      // If layer has an image, draw it
      if (layer.image != null) {
        final paint = Paint()..blendMode = layer.blendMode;
        canvas.drawImage(layer.image!, Offset.zero, paint);
      }

      // If layer has strokes, render them
      if (layerStrokes != null && layerStrokes.containsKey(layer.id)) {
        final strokes = layerStrokes[layer.id]!;
        for (final stroke in strokes) {
          BrushEngine.renderStroke(canvas, stroke);
        }
      }

      canvas.restore();
    }

    final picture = recorder.endRecording();
    return await picture.toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );
  }

  /// Render a single layer with its strokes to an image
  static Future<ui.Image> renderLayerToImage({
    required Layer layer,
    required Size size,
    List<BrushStroke>? strokes,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw existing layer image if present
    if (layer.image != null) {
      canvas.drawImage(layer.image!, Offset.zero, Paint());
    }

    // Draw strokes
    if (strokes != null) {
      for (final stroke in strokes) {
        BrushEngine.renderStroke(canvas, stroke);
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  /// Create a thumbnail image for a layer
  static Future<ui.Image> generateThumbnail({
    required Layer layer,
    required Size originalSize,
    required Size thumbnailSize,
    List<BrushStroke>? strokes,
  }) async {
    // First render full-size
    final fullImage = await renderLayerToImage(
      layer: layer,
      size: originalSize,
      strokes: strokes,
    );

    // Then scale down to thumbnail size
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Calculate scaling to fit
    final scaleX = thumbnailSize.width / originalSize.width;
    final scaleY = thumbnailSize.height / originalSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final scaledWidth = originalSize.width * scale;
    final scaledHeight = originalSize.height * scale;

    // Center in thumbnail
    final offsetX = (thumbnailSize.width - scaledWidth) / 2;
    final offsetY = (thumbnailSize.height - scaledHeight) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);
    canvas.drawImage(fullImage, Offset.zero, Paint());
    canvas.restore();

    final picture = recorder.endRecording();
    return await picture.toImage(
      thumbnailSize.width.toInt(),
      thumbnailSize.height.toInt(),
    );
  }
}
