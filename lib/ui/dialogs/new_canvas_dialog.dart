import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/canvas_preset.dart';

/// Dialog for creating a new canvas with presets or custom size
class NewCanvasDialog extends StatefulWidget {
  const NewCanvasDialog({super.key});

  @override
  State<NewCanvasDialog> createState() => _NewCanvasDialogState();
}

class _NewCanvasDialogState extends State<NewCanvasDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _backgroundColor = Colors.white;

  // Custom size controllers
  final _widthController = TextEditingController(text: '1920');
  final _heightController = TextEditingController(text: '1080');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'New Canvas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Screen'),
                Tab(text: 'Print'),
                Tab(text: 'Social'),
                Tab(text: 'Custom'),
              ],
            ),
            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPresetGrid('screen'),
                  _buildPresetGrid('print'),
                  _buildPresetGrid('social'),
                  _buildCustomTab(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Background color picker
            _buildBackgroundColorPicker(),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _createCanvas,
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetGrid(String category) {
    final presets = CanvasPreset.getByCategory(category);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        return _buildPresetCard(preset);
      },
    );
  }

  Widget _buildPresetCard(CanvasPreset preset) {
    return Card(
      child: InkWell(
        onTap: () => _createCanvasFromPreset(preset),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                preset.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                preset.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Canvas Size',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _widthController,
                  decoration: const InputDecoration(
                    labelText: 'Width (px)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Text('×', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (px)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Common sizes: 1920×1080 (HD), 3840×2160 (4K), 2000×2000 (Square)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorPicker() {
    return Row(
      children: [
        const Text('Background: '),
        const SizedBox(width: 12),
        _buildColorOption(Colors.transparent, 'Transparent'),
        const SizedBox(width: 8),
        _buildColorOption(Colors.white, 'White'),
        const SizedBox(width: 8),
        _buildColorOption(Colors.black, 'Black'),
        const SizedBox(width: 8),
        _buildColorOption(const Color(0xFFE5E5E5), 'Grey'),
      ],
    );
  }

  Widget _buildColorOption(Color color, String label) {
    final isSelected = _backgroundColor == color;
    final isTransparent = color == Colors.transparent;

    return InkWell(
      onTap: () => setState(() => _backgroundColor = color),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(2),
                // Checkerboard pattern for transparent
                image: isTransparent
                    ? const DecorationImage(
                        image: AssetImage('assets/checkerboard.png'),
                        repeat: ImageRepeat.repeat,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _createCanvasFromPreset(CanvasPreset preset) {
    Navigator.of(context).pop({
      'size': preset.size,
      'backgroundColor': _backgroundColor,
    });
  }

  void _createCanvas() {
    final width = int.tryParse(_widthController.text) ?? 1920;
    final height = int.tryParse(_heightController.text) ?? 1080;

    // Validate dimensions
    if (width < 1 || height < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid dimensions (minimum 1×1 px)'),
        ),
      );
      return;
    }

    if (width > 10000 || height > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum canvas size is 10000×10000 px'),
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'size': Size(width.toDouble(), height.toDouble()),
      'backgroundColor': _backgroundColor,
    });
  }
}

/// Show new canvas dialog and return result
Future<Map<String, dynamic>?> showNewCanvasDialog(BuildContext context) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => const NewCanvasDialog(),
  );
}
