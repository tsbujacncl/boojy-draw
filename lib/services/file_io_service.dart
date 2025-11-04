import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/draw_file.dart';
import '../models/layer.dart';
import '../models/canvas_state.dart';
import '../providers/layer_stack_controller.dart';

/// Service for handling .draw file I/O operations
class FileIOService {
  static const String appVersion = '0.1.0';

  /// Save a project to a .draw file
  /// Returns true if successful
  static Future<bool> saveProject({
    required String filePath,
    required CanvasState canvasState,
    required LayerStackState layerStackState,
    String? title,
  }) async {
    try {
      // Create DrawFile model
      final now = DateTime.now();
      final metadata = DrawFileMetadata(
        title: title ?? 'Untitled',
        createdAt: now,
        modifiedAt: now,
        appVersion: appVersion,
      );

      final canvasData = CanvasData(
        size: canvasState.canvasSize,
        backgroundColor: canvasState.backgroundColor,
        zoom: canvasState.zoom,
        panOffset: canvasState.panOffset,
        rotation: canvasState.rotation,
      );

      // Convert layers to LayerData
      final layersData = <LayerData>[];
      for (int i = 0; i < layerStackState.layers.length; i++) {
        final layer = layerStackState.layers[i];
        layersData.add(LayerData.fromLayer(layer, i));
      }

      final drawFile = DrawFile(
        metadata: metadata,
        canvas: canvasData,
        layers: layersData,
      );

      // Create ZIP archive
      final archive = Archive();

      // Add manifest.json
      final manifestJson = jsonEncode(drawFile.toJson());
      final manifestBytes = utf8.encode(manifestJson);
      archive.addFile(
        ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
      );

      // Add layer PNGs
      for (final layer in layerStackState.layers) {
        if (layer.image != null) {
          final pngBytes = await _imageToBytes(layer.image!);
          archive.addFile(
            ArchiveFile('layers/${layer.id}.png', pngBytes.length, pngBytes),
          );
        }
      }

      // Generate and add thumbnail
      final thumbnail = await _generateThumbnail(
        layerStackState.layers,
        canvasState.canvasSize,
        canvasState.backgroundColor,
      );
      if (thumbnail != null) {
        final thumbnailBytes = await _imageToBytes(thumbnail);
        archive.addFile(
          ArchiveFile('thumbnail.png', thumbnailBytes.length, thumbnailBytes),
        );
      }

      // Encode ZIP
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);

      if (zipBytes == null) {
        return false;
      }

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(zipBytes);

      return true;
    } catch (e) {
      print('Error saving project: $e');
      return false;
    }
  }

  /// Load a project from a .draw file
  /// Returns DrawFile with loaded data, or null if failed
  static Future<LoadedProject?> loadProject(String filePath) async {
    try {
      // Read file
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      // Decode ZIP
      final archive = ZipDecoder().decodeBytes(bytes);

      // Read manifest.json
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        print('Error: manifest.json not found in archive');
        return null;
      }

      final manifestContent = manifestFile.content;
      final manifestJson = utf8.decode(manifestContent is Uint8List
          ? manifestContent
          : Uint8List.fromList(manifestContent as List<int>));
      final manifestData = jsonDecode(manifestJson) as Map<String, dynamic>;
      final drawFile = DrawFile.fromJson(manifestData);

      // Load layer images
      final layers = <Layer>[];
      for (final layerData in drawFile.layers) {
        final layerFile = archive.findFile('layers/${layerData.id}.png');
        ui.Image? image;

        if (layerFile != null) {
          final content = layerFile.content;
          image = await _bytesToImage(content is Uint8List
              ? content
              : Uint8List.fromList(content as List<int>));
        }

        layers.add(Layer(
          id: layerData.id,
          name: layerData.name,
          opacity: layerData.opacity,
          visible: layerData.visible,
          locked: layerData.locked,
          blendMode: layerData.blendMode,
          image: image,
          createdAt: layerData.createdAt,
          modifiedAt: layerData.modifiedAt,
        ));
      }

      // Load thumbnail
      final thumbnailFile = archive.findFile('thumbnail.png');
      ui.Image? thumbnail;
      if (thumbnailFile != null) {
        final content = thumbnailFile.content;
        thumbnail = await _bytesToImage(content is Uint8List
            ? content
            : Uint8List.fromList(content as List<int>));
      }

      return LoadedProject(
        drawFile: drawFile,
        layers: layers,
        thumbnail: thumbnail,
      );
    } catch (e) {
      print('Error loading project: $e');
      return null;
    }
  }

  /// Export canvas as PNG
  static Future<bool> exportPNG({
    required String filePath,
    required LayerStackState layerStackState,
    required Size canvasSize,
    required Color backgroundColor,
    bool includeTransparency = true,
  }) async {
    try {
      // Create composite image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background if not transparent
      if (!includeTransparency) {
        final bgPaint = Paint()..color = backgroundColor;
        canvas.drawRect(
          Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
          bgPaint,
        );
      }

      // Draw all visible layers
      for (final layer in layerStackState.layers) {
        if (!layer.visible || layer.image == null) continue;

        canvas.saveLayer(
          null,
          Paint()
            ..color = Colors.white.withValues(alpha: layer.opacity)
            ..blendMode = layer.blendMode,
        );

        canvas.drawImage(layer.image!, Offset.zero, Paint());
        canvas.restore();
      }

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        canvasSize.width.toInt(),
        canvasSize.height.toInt(),
      );

      // Convert to PNG bytes
      final pngBytes = await _imageToBytes(image);

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return true;
    } catch (e) {
      print('Error exporting PNG: $e');
      return false;
    }
  }

  /// Export canvas as JPG
  static Future<bool> exportJPG({
    required String filePath,
    required LayerStackState layerStackState,
    required Size canvasSize,
    required Color backgroundColor,
    int quality = 90,
  }) async {
    try {
      // Create composite image (JPG doesn't support transparency)
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background
      final bgPaint = Paint()..color = backgroundColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
        bgPaint,
      );

      // Draw all visible layers
      for (final layer in layerStackState.layers) {
        if (!layer.visible || layer.image == null) continue;

        canvas.saveLayer(
          null,
          Paint()
            ..color = Colors.white.withValues(alpha: layer.opacity)
            ..blendMode = layer.blendMode,
        );

        canvas.drawImage(layer.image!, Offset.zero, Paint());
        canvas.restore();
      }

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        canvasSize.width.toInt(),
        canvasSize.height.toInt(),
      );

      // Convert to PNG bytes first (Flutter doesn't directly support JPG encoding)
      final pngByteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (pngByteData == null) return false;

      // Use image package to convert PNG to JPG
      final pngImage = img.decodePng(pngByteData.buffer.asUint8List());
      if (pngImage == null) return false;

      final jpgBytes = img.encodeJpg(pngImage, quality: quality);

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(jpgBytes);

      return true;
    } catch (e) {
      print('Error exporting JPG: $e');
      return false;
    }
  }

  /// Convert ui.Image to PNG bytes
  static Future<Uint8List> _imageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }
    return byteData.buffer.asUint8List();
  }

  /// Convert bytes to ui.Image
  static Future<ui.Image> _bytesToImage(List<int> bytes) async {
    final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Generate a 512x512 thumbnail from layers
  static Future<ui.Image?> _generateThumbnail(
    List<Layer> layers,
    Size canvasSize,
    Color backgroundColor,
  ) async {
    try {
      const thumbnailSize = 512.0;

      // Calculate scale to fit canvas in thumbnail
      final scale = thumbnailSize / canvasSize.longestSide;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Apply scale
      canvas.scale(scale);

      // Draw background
      final bgPaint = Paint()..color = backgroundColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
        bgPaint,
      );

      // Draw all visible layers
      for (final layer in layers) {
        if (!layer.visible || layer.image == null) continue;

        canvas.saveLayer(
          null,
          Paint()
            ..color = Colors.white.withValues(alpha: layer.opacity)
            ..blendMode = layer.blendMode,
        );

        canvas.drawImage(layer.image!, Offset.zero, Paint());
        canvas.restore();
      }

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        (canvasSize.width * scale).toInt(),
        (canvasSize.height * scale).toInt(),
      );

      return image;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
}

/// Loaded project data
class LoadedProject {
  final DrawFile drawFile;
  final List<Layer> layers;
  final ui.Image? thumbnail;

  const LoadedProject({
    required this.drawFile,
    required this.layers,
    this.thumbnail,
  });
}
