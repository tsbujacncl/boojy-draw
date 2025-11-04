import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Show save file dialog
/// Returns the selected file path or null if canceled
Future<String?> showSaveDialog(BuildContext context) async {
  final result = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Project',
    fileName: 'Untitled.draw',
    type: FileType.custom,
    allowedExtensions: ['draw'],
  );

  return result;
}

/// Show open file dialog
/// Returns the selected file path or null if canceled
Future<String?> showOpenDialog(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Open Project',
    type: FileType.custom,
    allowedExtensions: ['draw'],
    allowMultiple: false,
  );

  return result?.files.single.path;
}

/// Show export PNG dialog
/// Returns the selected file path or null if canceled
Future<String?> showExportPNGDialog(BuildContext context) async {
  final result = await FilePicker.platform.saveFile(
    dialogTitle: 'Export PNG',
    fileName: 'export.png',
    type: FileType.custom,
    allowedExtensions: ['png'],
  );

  return result;
}

/// Show export JPG dialog
/// Returns the selected file path or null if canceled
Future<String?> showExportJPGDialog(BuildContext context) async {
  final result = await FilePicker.platform.saveFile(
    dialogTitle: 'Export JPG',
    fileName: 'export.jpg',
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg'],
  );

  return result;
}

/// Show export options dialog
/// Returns map with format ('png' or 'jpg'), quality (1-100), and includeTransparency (bool)
Future<Map<String, dynamic>?> showExportDialog(BuildContext context) async {
  String selectedFormat = 'png';
  int quality = 90;
  bool includeTransparency = true;

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Export Image'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Format selection
                  const Text(
                    'Format',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'png',
                        label: Text('PNG'),
                        icon: Icon(Icons.image),
                      ),
                      ButtonSegment(
                        value: 'jpg',
                        label: Text('JPG'),
                        icon: Icon(Icons.image),
                      ),
                    ],
                    selected: {selectedFormat},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        selectedFormat = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // PNG-specific options
                  if (selectedFormat == 'png') ...[
                    CheckboxListTile(
                      title: const Text('Include Transparency'),
                      value: includeTransparency,
                      onChanged: (value) {
                        setState(() {
                          includeTransparency = value ?? true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],

                  // JPG-specific options
                  if (selectedFormat == 'jpg') ...[
                    Text(
                      'Quality: $quality%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: quality.toDouble(),
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: '$quality%',
                      onChanged: (value) {
                        setState(() {
                          quality = value.toInt();
                        });
                      },
                    ),
                    const Text(
                      'Note: JPG does not support transparency',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'format': selectedFormat,
                    'quality': quality,
                    'includeTransparency': includeTransparency,
                  });
                },
                child: const Text('Export'),
              ),
            ],
          );
        },
      );
    },
  );

  return result;
}

/// Show unsaved changes dialog
/// Returns true to save, false to discard, null to cancel
Future<bool?> showUnsavedChangesDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to save them before continuing?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Discard
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true), // Save
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
