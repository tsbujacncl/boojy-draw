# Boojy Draw - Implementation TODO

## Phase 1: Foundation & UI Shell (Days 1-3) ✅ COMPLETE

### Step 1: Project Setup & Dependencies ✅
- [x] Add `flutter_riverpod` to pubspec.yaml
- [x] Add `image` package for image manipulation
- [x] Add `path_provider` for file I/O
- [x] Add `file_picker` for file dialogs
- [x] Configure desktop window settings (min/initial size)
- [x] Set up Material 3 theming (dark + light)

### Step 2: Main Window Layout Structure ✅
- [x] Create `AppShell` widget (main container)
- [x] Build `TopBar` (menu bar + toolbar)
- [x] Build `LeftPanel` (tool options, collapsible)
- [x] Build `CenterArea` (canvas viewport)
- [x] Build `RightPanel` (layers + color picker, collapsible)
- [x] Build `BottomBar` (status info)
- [x] Add panel collapse/expand functionality
- [ ] Add keyboard shortcut for hide all panels (Tab) - Deferred to Phase 8

### Step 3: Panel Widgets (Placeholder Content) ✅
- [x] Create `ToolOptionsPanel` widget (integrated in AppShell)
- [x] Create `CanvasViewport` widget with placeholder grid
- [x] Create `LayersPanel` widget with empty list
- [x] Create `ColorPickerPanel` widget with basic color square
- [x] Create `StatusBar` widget with static text
- [x] Wire up panel state management (Riverpod - local state for now)

### Step 4: Theming & Polish ✅
- [x] Implement Material 3 dark theme
- [x] Implement Material 3 light theme
- [ ] Add panel resize handles (draggable splitters) - Deferred to v1.0
- [x] Add proper spacing and shadows
- [x] Add panel borders and visual hierarchy
- [x] Test panel collapse/resize behavior

---

## Phase 2: Canvas System (Days 4-5)

### Step 5: Canvas Core
- [ ] Create `CanvasController` (Riverpod StateNotifier)
- [ ] Create `CanvasState` model (size, zoom, pan, rotation)
- [ ] Implement canvas size presets (A4, Square, HD, Custom)
- [ ] Add new canvas dialog
- [ ] Implement checkerboard background for transparency
- [ ] Add viewport zoom (mouse wheel, Cmd +/-)
- [ ] Add viewport pan (Space + drag, middle mouse)
- [ ] Add rotation (Cmd + drag handle, snap to 0/90/180/270)

### Step 6: Canvas Rendering
- [ ] Create `CanvasRenderer` (CustomPainter)
- [ ] Implement coordinate transformation (canvas ↔ screen space)
- [ ] Add high-DPI support (devicePixelRatio)
- [ ] Optimize for 60 FPS viewport changes
- [ ] Add zoom level indicator in status bar
- [ ] Add canvas size indicator in status bar
- [ ] Test performance with 3000x3000 canvas

---

## Phase 3: Basic Brush Engine (Days 6-8)

### Step 7: Input Handling
- [ ] Set up pointer event listeners (mouse, stylus)
- [ ] Detect pressure sensitivity from stylus
- [ ] Create `StrokePoint` model (position, pressure, timestamp)
- [ ] Create `BrushStroke` model (list of points, settings)
- [ ] Implement Kalman filter for stroke stabilization
- [ ] Test with mouse (speed-based fallback)
- [ ] Test with stylus (Wacom, Surface, Apple Pencil via Sidecar)

### Step 8: Pencil & Pen Brushes
- [ ] Create `BrushEngine` class
- [ ] Implement Pencil brush (hard-edge, aliased)
- [ ] Implement Pen brush (smooth, anti-aliased)
- [ ] Create brush settings UI (size slider)
- [ ] Create brush settings UI (opacity slider)
- [ ] Add pressure curve dropdown (Linear, Ease In, Ease Out, S-Curve)
- [ ] Implement pressure curve mapping
- [ ] Add real-time stroke preview overlay
- [ ] Commit stroke to active layer on pointer up
- [ ] Add brush shortcuts (B key)

---

## Phase 4: Layer System (Days 9-10)

### Step 9: Layer Management
- [ ] Create `Layer` model (raster, name, opacity, visible, locked, blendMode)
- [ ] Create `LayerStack` controller (Riverpod)
- [ ] Build layers panel UI with list
- [ ] Add layer thumbnail rendering (64x64)
- [ ] Add visibility toggle (eye icon)
- [ ] Add lock toggle (lock icon)
- [ ] Add opacity slider per layer
- [ ] Implement New Layer (Cmd+Shift+N)
- [ ] Implement Delete Layer (Delete key with confirmation)
- [ ] Implement Duplicate Layer (Cmd+J)
- [ ] Implement layer reordering (drag in panel)
- [ ] Add active layer selection/highlight

### Step 10: Compositing & Blend Modes
- [ ] Create layer compositor (stack → flattened output)
- [ ] Implement Normal blend mode
- [ ] Implement Multiply blend mode
- [ ] Implement Screen blend mode
- [ ] Implement Overlay blend mode
- [ ] Implement Add blend mode
- [ ] Add blend mode dropdown in layers panel
- [ ] Test blend modes with reference images
- [ ] Implement Merge Down (Cmd+E)
- [ ] Implement Flatten All (Shift+Cmd+E)

---

## Phase 5: Remaining Brushes & Tools (Days 11-12)

### Step 11: Complete Brush Set
- [ ] Implement Marker brush (soft-edge, buildable opacity)
- [ ] Implement Airbrush (spray effect with falloff)
- [ ] Implement Eraser (clear pixels, respects opacity)
- [ ] Add brush preset selector to toolbar
- [ ] Add brush preview thumbnail
- [ ] Add tool shortcuts (E for eraser)
- [ ] Add brush size visual indicator (cursor ring)
- [ ] Test all brushes with pressure sensitivity
- [ ] Optimize brush rendering performance

### Step 12: Color System
- [ ] Create HSV color wheel widget (hue ring + SV triangle)
- [ ] Add hex color input field (#RRGGBB or #RRGGBBAA)
- [ ] Add RGBA sliders (0-255)
- [ ] Implement recent swatches (8 slots, MRU order)
- [ ] Implement eyedropper tool (Cmd+click or I key)
- [ ] Add eyedropper mode: current layer only
- [ ] Add eyedropper mode: all visible layers (Alt modifier)
- [ ] Add foreground/background color swap (X key)
- [ ] Wire color changes to brush engine

---

## Phase 6: Selection & Transform (Days 13-14)

### Step 13: Selection Tools
- [ ] Create `Selection` model (path, feather, mode)
- [ ] Implement Rectangle selection tool (M key)
- [ ] Implement Lasso selection tool (L key, freehand path)
- [ ] Implement Magic Wand tool (W key, flood fill)
- [ ] Add tolerance slider for Magic Wand (0-100, default 32)
- [ ] Add selection overlay rendering (marching ants)
- [ ] Add selection modifiers: Add (Shift)
- [ ] Add selection modifiers: Subtract (Alt)
- [ ] Add selection modifiers: Intersect (Shift+Alt)
- [ ] Add feather option (0-100px)
- [ ] Add Select All (Cmd+A)
- [ ] Add Deselect (Cmd+D)

### Step 14: Transform Operations
- [ ] Create transform overlay with handles
- [ ] Implement Move (drag selection, arrow keys)
- [ ] Implement Scale (corner handles, Shift = constrain aspect)
- [ ] Implement Rotate (rotate handle, Shift = snap 15°)
- [ ] Implement Flip Horizontal
- [ ] Implement Flip Vertical
- [ ] Add Apply transform (Enter key, rasterize)
- [ ] Add Cancel transform (Esc key)
- [ ] Use bicubic interpolation for scale/rotate quality
- [ ] Test with anti-aliasing

---

## Phase 7: File I/O & Persistence (Days 15-16)

### Step 15: Save/Load
- [ ] Design `.draw` file format (JSON schema + ZIP structure)
- [ ] Create `DrawFile` model (metadata, layers, canvas info)
- [ ] Implement Save Project (Cmd+S)
- [ ] Implement Save As (Cmd+Shift+S)
- [ ] Implement Open Project (Cmd+O)
- [ ] Implement New Project (Cmd+N with save prompt)
- [ ] Add file picker dialogs
- [ ] Generate 512x512 thumbnail for metadata
- [ ] Implement ZIP compression for layers (PNG blobs)
- [ ] Test save/load round-trip (verify all data preserved)
- [ ] Add file format versioning (v0.1)
- [ ] Handle forward compatibility (ignore unknown fields)

### Step 16: Autosave & Export
- [ ] Implement autosave timer (every 2 minutes)
- [ ] Run autosave on background isolate (non-blocking)
- [ ] Save autosaves to `~/Documents/Boojy/Autosaves/`
- [ ] Implement autosave retention (keep last 3, delete older)
- [ ] Add autosave recovery on launch
- [ ] Show "Autosaving..." indicator (bottom-right, 1s fade)
- [ ] Create Export dialog (PNG/JPG format selector)
- [ ] Implement PNG export (with transparency option)
- [ ] Implement JPG export (flatten layers, quality slider 1-100)
- [ ] Add export size options (100%, 50%, 200%, custom)
- [ ] Use isolate for export encoding (non-blocking)
- [ ] Test export performance (5000x5000 in <5s target)

---

## Phase 8: Undo/Redo & Polish (Days 17-18)

### Step 17: History System
- [ ] Implement Command pattern for undo/redo
- [ ] Create `HistoryStack` controller (Riverpod)
- [ ] Track brush strokes (incremental diffs)
- [ ] Track layer operations (new, delete, merge, reorder)
- [ ] Track transform operations
- [ ] Track selection changes
- [ ] Implement Undo (Cmd+Z)
- [ ] Implement Redo (Cmd+Shift+Z)
- [ ] Set history stack limit (50 actions)
- [ ] Optimize memory (store diffs, not full copies)
- [ ] Update status bar with undo/redo availability

### Step 18: Final Polish & Testing
- [ ] Create keyboard shortcuts documentation
- [ ] Add tooltips to all toolbar buttons
- [ ] Test performance with 3000x3000, 10 layers (≥30 FPS target)
- [ ] Test performance with 5000x5000 canvas
- [ ] Stress test with 50+ layers
- [ ] Test on macOS (Intel + Apple Silicon)
- [ ] Test on Windows 11
- [ ] Test with Wacom tablet
- [ ] Test with Surface Pen
- [ ] Test with Apple Pencil via Sidecar
- [ ] Test with mouse (stabilization)
- [ ] Fix stylus lag/jitter issues
- [ ] Implement crash recovery
- [ ] Add error handling for file I/O failures
- [ ] Run through all tester scenarios from SPRINT-MVP.md
- [ ] Fix all critical bugs
- [ ] Build release packages (macOS + Windows)
- [ ] Update README with build instructions
- [ ] Create CONTRIBUTING.md

---

## Future Features (Post-MVP, v1.0)
- [ ] Custom brush editor
- [ ] Layer masks
- [ ] Text layers with font selection
- [ ] Symmetry tools (horizontal, vertical, radial)
- [ ] Filters (blur, sharpen, adjust levels, curves)
- [ ] Reference image overlay
- [ ] Gradient fills
- [ ] History panel UI
- [ ] Customizable keyboard shortcuts
- [ ] Brush stabilization settings UI
- [ ] Canvas rotation with UI handle
- [ ] Zoom to fit (Cmd+0)
- [ ] Zoom to actual pixels (Cmd+1)

---

## Testing Checklist (Before Release)
- [ ] Pressure sensitivity rated ≥4/5 by 3+ stylus users
- [ ] Mouse users can complete a piece with stabilization
- [ ] 3000x3000, 10 layers renders at ≥30 FPS
- [ ] Save/load preserves all layer data correctly
- [ ] Zero data-loss bugs in testing
- [ ] Export PNG matches canvas exactly
- [ ] Autosave recovers unsaved work
- [ ] Builds run on fresh macOS install
- [ ] Builds run on fresh Windows install
- [ ] ≥70% testers say they'd use for real work
- [ ] ≥80% complete test tasks without help
- [ ] Avg rating ≥4/5 from tester survey
- [ ] Startup time <2s on 8GB RAM, SSD
- [ ] Autosave completes in <500ms
- [ ] Export 5000x5000 PNG in <5s
