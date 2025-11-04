import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/brush_controller.dart';

/// Color picker panel with HSV wheel, hex input, RGBA sliders, and swatches
class ColorPickerPanel extends ConsumerStatefulWidget {
  const ColorPickerPanel({super.key});

  @override
  ConsumerState<ColorPickerPanel> createState() => _ColorPickerPanelState();
}

class _ColorPickerPanelState extends ConsumerState<ColorPickerPanel> {
  late TextEditingController _hexController;
  List<Color> _recentColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.cyan,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController();
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brushSettings = ref.watch(brushControllerProvider);
    final brushController = ref.read(brushControllerProvider.notifier);
    final currentColor = brushSettings.color;

    // Update hex field when color changes externally
    final hexValue = '#${_colorToHex(currentColor)}';
    if (_hexController.text != hexValue && !_hexController.selection.isValid) {
      _hexController.text = hexValue;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current color display
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: currentColor,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),

          // HSV Color Picker
          Center(
            child: HSVColorPicker(
              color: currentColor,
              onColorChanged: (color) {
                brushController.setColor(color);
                _addToRecentColors(color);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Hex input
          TextField(
            controller: _hexController,
            decoration: InputDecoration(
              labelText: 'Hex Color',
              prefixText: '#',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
              LengthLimitingTextInputFormatter(8),
            ],
            onSubmitted: (value) {
              final color = _parseHexColor(value);
              if (color != null) {
                brushController.setColor(color);
                _addToRecentColors(color);
              }
            },
          ),
          const SizedBox(height: 16),

          // RGBA Sliders
          _buildColorSlider(
            'Red',
            (currentColor.r * 255).round().toDouble(),
            Colors.red,
            (value) {
              final newColor = Color.from(
                alpha: currentColor.a,
                red: value / 255,
                green: currentColor.g,
                blue: currentColor.b,
              );
              brushController.setColor(newColor);
              _addToRecentColors(newColor);
            },
          ),
          const SizedBox(height: 8),
          _buildColorSlider(
            'Green',
            (currentColor.g * 255).round().toDouble(),
            Colors.green,
            (value) {
              final newColor = Color.from(
                alpha: currentColor.a,
                red: currentColor.r,
                green: value / 255,
                blue: currentColor.b,
              );
              brushController.setColor(newColor);
              _addToRecentColors(newColor);
            },
          ),
          const SizedBox(height: 8),
          _buildColorSlider(
            'Blue',
            (currentColor.b * 255).round().toDouble(),
            Colors.blue,
            (value) {
              final newColor = Color.from(
                alpha: currentColor.a,
                red: currentColor.r,
                green: currentColor.g,
                blue: value / 255,
              );
              brushController.setColor(newColor);
              _addToRecentColors(newColor);
            },
          ),
          const SizedBox(height: 8),
          _buildColorSlider(
            'Alpha',
            (currentColor.a * 255).round().toDouble(),
            Colors.grey,
            (value) {
              final newColor = Color.from(
                alpha: value / 255,
                red: currentColor.r,
                green: currentColor.g,
                blue: currentColor.b,
              );
              brushController.setColor(newColor);
              _addToRecentColors(newColor);
            },
          ),
          const SizedBox(height: 16),

          // Recent colors swatches
          Text(
            'Recent Colors',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentColors.map((color) {
              return GestureDetector(
                onTap: () => brushController.setColor(color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: color == currentColor
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: color == currentColor ? 3 : 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSlider(
    String label,
    double value,
    Color trackColor,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: trackColor,
              inactiveTrackColor: trackColor.withValues(alpha: 0.3),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 255,
              divisions: 255,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toInt().toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _addToRecentColors(Color color) {
    setState(() {
      // Remove if already exists
      _recentColors.remove(color);
      // Add to front (MRU)
      _recentColors.insert(0, color);
      // Keep only 8 most recent
      if (_recentColors.length > 8) {
        _recentColors = _recentColors.take(8).toList();
      }
    });
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }

  Color? _parseHexColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if not provided
      }
      if (hex.length == 8) {
        final value = int.parse(hex, radix: 16);
        final a = ((value >> 24) & 0xFF) / 255.0;
        final r = ((value >> 16) & 0xFF) / 255.0;
        final g = ((value >> 8) & 0xFF) / 255.0;
        final b = (value & 0xFF) / 255.0;
        return Color.from(alpha: a, red: r, green: g, blue: b);
      }
    } catch (e) {
      // Invalid hex color
    }
    return null;
  }
}

/// HSV Color Picker Widget
class HSVColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final double size;

  const HSVColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.size = 200,
  });

  @override
  State<HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<HSVColorPicker> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.color);
  }

  @override
  void didUpdateWidget(HSVColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color != oldWidget.color) {
      _hsvColor = HSVColor.fromColor(widget.color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // SV Square (Saturation-Value picker)
        GestureDetector(
          onPanUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final s = (localPosition.dx / widget.size).clamp(0.0, 1.0);
            final v = 1.0 - (localPosition.dy / widget.size).clamp(0.0, 1.0);

            setState(() {
              _hsvColor = _hsvColor.withSaturation(s).withValue(v);
            });
            widget.onColorChanged(_hsvColor.toColor());
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomPaint(
                painter: _SVSquarePainter(_hsvColor.hue),
                child: Stack(
                  children: [
                    Positioned(
                      left: _hsvColor.saturation * widget.size - 6,
                      top: (1.0 - _hsvColor.value) * widget.size - 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _hsvColor.toColor(),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Hue Slider
        GestureDetector(
          onPanUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final hue = ((localPosition.dx / widget.size) * 360).clamp(0.0, 360.0);

            setState(() {
              _hsvColor = _hsvColor.withHue(hue);
            });
            widget.onColorChanged(_hsvColor.toColor());
          },
          child: Container(
            width: widget.size,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomPaint(
                painter: _HueSliderPainter(),
                child: Stack(
                  children: [
                    Positioned(
                      left: (_hsvColor.hue / 360) * widget.size - 4,
                      top: 4,
                      child: Container(
                        width: 8,
                        height: 16,
                        decoration: BoxDecoration(
                          color: HSVColor.fromAHSV(1.0, _hsvColor.hue, 1.0, 1.0).toColor(),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter for the Saturation-Value square
class _SVSquarePainter extends CustomPainter {
  final double hue;

  _SVSquarePainter(this.hue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create gradient for saturation (left to right)
    final saturationGradient = LinearGradient(
      colors: [
        Colors.white,
        HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
      ],
    );

    // Create gradient for value (top to bottom)
    final valueGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black,
      ],
    );

    // Draw saturation gradient
    canvas.drawRect(rect, Paint()..shader = saturationGradient.createShader(rect));

    // Draw value gradient on top
    canvas.drawRect(rect, Paint()..shader = valueGradient.createShader(rect));
  }

  @override
  bool shouldRepaint(_SVSquarePainter oldDelegate) => oldDelegate.hue != hue;
}

/// Painter for the hue slider
class _HueSliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = LinearGradient(
      colors: [
        const HSVColor.fromAHSV(1.0, 0, 1.0, 1.0).toColor(),
        const HSVColor.fromAHSV(1.0, 60, 1.0, 1.0).toColor(),
        const HSVColor.fromAHSV(1.0, 120, 1.0, 1.0).toColor(),
        const HSVColor.fromAHSV(1.0, 180, 1.0, 1.0).toColor(),
        const HSVColor.fromAHSV(1.0, 240, 1.0, 1.0).toColor(),
        const HSVColor.fromAHSV(1.0, 300, 1.0, 1.0).toColor(),
        const HSVColor.fromAHSV(1.0, 360, 1.0, 1.0).toColor(),
      ],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
