# Boojy Draw - Keyboard Shortcuts

Complete reference of all keyboard shortcuts in Boojy Draw.

## File Operations

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+N` (macOS) / `Ctrl+N` (Windows) | New Project | Create a new canvas with save prompt if unsaved changes exist |
| `Cmd+O` (macOS) / `Ctrl+O` (Windows) | Open Project | Open an existing .draw project file |
| `Cmd+S` (macOS) / `Ctrl+S` (Windows) | Save | Save current project (prompts for location if new) |
| `Cmd+Shift+S` (macOS) / `Ctrl+Shift+S` (Windows) | Save As | Save project to a new location |

## Edit Operations

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+Z` (macOS) / `Ctrl+Z` (Windows) | Undo | Undo the last action (up to 50 actions) |
| `Cmd+Shift+Z` (macOS) / `Ctrl+Shift+Z` (Windows) | Redo | Redo the last undone action |

## View & Navigation

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd++` (macOS) / `Ctrl++` (Windows) | Zoom In | Increase canvas zoom level |
| `Cmd+-` (macOS) / `Ctrl+-` (Windows) | Zoom Out | Decrease canvas zoom level |
| `Cmd+0` (macOS) / `Ctrl+0` (Windows) | Zoom to Fit | Fit entire canvas in viewport |
| `Cmd+1` (macOS) / `Ctrl+1` (Windows) | Zoom to 100% | Reset zoom to actual size (1:1 pixels) |
| `Space + Drag` | Pan Canvas | Move the canvas viewport (hold Space while dragging) |
| `Middle Mouse Button + Drag` | Pan Canvas | Move the canvas viewport (alternative method) |
| `Scroll Wheel` | Zoom | Zoom in/out at cursor position |

## Tool Selection

| Shortcut | Tool | Description |
|----------|------|-------------|
| `B` | Brush Tool | Switch to brush for freehand drawing |
| `M` | Rectangle Selection | Switch to rectangle selection tool |
| `L` | Lasso Selection | Switch to lasso (freehand) selection tool |
| `W` | Magic Wand | Switch to magic wand (color-based) selection tool |
| `V` | Transform Tool | Switch to transform tool for moving/scaling/rotating |
| `I` | Eyedropper Tool | Switch to eyedropper for picking colors |

## Selection Operations

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+A` (macOS) / `Ctrl+A` (Windows) | Select All | Select the entire canvas |
| `Cmd+D` (macOS) / `Ctrl+D` (Windows) | Deselect | Clear the current selection |
| `Shift + Tool` | Add to Selection | Add to existing selection (hold Shift while using selection tool) |
| `Alt + Tool` | Subtract from Selection | Remove from existing selection (hold Alt while using selection tool) |
| `Shift+Alt + Tool` | Intersect Selection | Create intersection with existing selection |

## Transform Operations

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Enter` | Apply Transform | Apply the current transformation |
| `Escape` | Cancel Transform | Cancel the current transformation |
| `Shift + Drag Corner` | Constrain Aspect | Scale while maintaining aspect ratio |
| `Shift + Rotate` | Snap Rotation | Snap rotation to 15° increments |

## Drawing Modifiers

| Modifier | Effect | Description |
|----------|--------|-------------|
| `Pressure (Stylus)` | Vary Stroke | Control brush size/opacity with pen pressure |
| `Speed (Mouse)` | Simulate Pressure | Brush responds to drawing speed when using mouse |

## Panel Management

| Action | Method | Description |
|--------|--------|-------------|
| Toggle Left Panel | Click arrow in status bar | Show/hide tool options panel |
| Toggle Right Panel | Click arrow in status bar | Show/hide layers and color picker panels |

## Tips

- **Pressure Sensitivity**: Boojy Draw supports stylus pressure from Wacom, Surface Pen, and Apple Pencil (via Sidecar)
- **Mouse Drawing**: When using a mouse, stroke size/opacity varies based on drawing speed
- **Stroke Stabilization**: Built-in Kalman filter smooths jittery strokes automatically
- **Undo Limit**: History stores up to 50 undoable actions to balance memory usage
- **Command Merging**: Consecutive similar actions may be merged (e.g., multiple strokes on same layer)

## Platform-Specific Notes

### macOS
- All shortcuts use `Cmd` (Command) key
- Trackpad pinch-to-zoom supported
- Apple Pencil via Sidecar fully supported

### Windows
- All shortcuts use `Ctrl` (Control) key
- Surface Pen fully supported
- Wacom tablets fully supported

## Planned Shortcuts (Future Versions)

These shortcuts are planned but not yet implemented:

- `Cmd/Ctrl+C`: Copy selection
- `Cmd/Ctrl+V`: Paste selection
- `Cmd/Ctrl+X`: Cut selection
- `E`: Eraser tool shortcut
- `X`: Swap foreground/background colors
- `Tab`: Hide all panels
- `[` / `]`: Decrease/increase brush size
- `Delete`: Delete selection

## See Also

- [UX Specification](../docs/boojy_draw_ux_spec_v0.1.md) - Complete feature documentation
- [TODO.md](../TODO.md) - Implementation roadmap
- [README.md](../README.md) - Project overview

---

*Last updated: Phase 8 Step 18 - January 2025*
