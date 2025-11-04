# 🎨 Boojy Draw – UX & Layout Specification v0.1
**Version:** 0.1 (Preview Phase)  
**Date:** November 2025  
**Part of:** Boojy Creative Suite  

---

## 1. Overview

**Boojy Draw** is a cross-platform digital painting and illustration app focused on clarity, speed, and creative flow.  
It bridges the simplicity of **Procreate** with the flexibility of **Krita** and **Photoshop**, designed for artists, students, and hobbyists who want a frictionless, open-source drawing tool.

**Core Goals**
- Instantly intuitive for beginners.  
- Powerful enough for everyday illustration work.  
- Visually consistent across all Boojy apps (Audio, Design, Video).  
- Feels lightweight, modern, and cohesive.

---

## 2. Design Language

- **Primary Background:** `#2A2B35` (balanced space grey)  
- **Text:** `#F5F5F5` (light neutral)  
- **Accent (Venus / Draw):** `#F4A261` (Venus Orange)  
- **Secondary UI Surface:** `#1A1B23` (darker shade for contrast)  
- **Borders:** `#3A3B45`  
- **Font Family:** *Boojy Sans* (rounded geometric, consistent across suite)

**Visual Tone:**  
Elegant minimalism — dark, cinematic workspace with warm Venus-orange accents.  
Every Boojy app uses the same grid, spacing, and animation rhythm for seamless familiarity.

---

## 3. Layout Overview

Boojy Draw’s interface is divided into **four main zones** plus one adaptive behaviour layer.  
This approach balances focus for artists with quick access for experienced users.

---

### 🧭 Top Bar — Global Controls
- Horizontal strip across the top of the window.
- Contains:
  - **Menus:** File, Edit, View, Layer, Select, Filter, Text, Help  
  - **Tool Settings:** Brush preset, size slider, opacity slider, blend mode.  
  - **Quick Actions:** Undo, Redo, Save, Export.  
- Planet indicator (Venus glow) animates on autosave or export.

**Behaviour**
- Always visible.
- Contextual sections change depending on active tool.
- Supports keyboard shortcuts and dropdowns.

---

### 🎨 Left Sidebar — Tool Palette
Vertical toolbar pinned to the left edge of the window.

**Default Tools**
- 🖌️ Brush  
- ✏️ Pencil  
- 🩹 Eraser  
- 💧 Smudge  
- 🎨 Fill  
- ✂️ Selection  
- 🔲 Shape  
- ✍️ Text  
- 🖐 Move  
- 🔍 Zoom  

**Behaviour**
- Icon-only; hover (desktop) or long-press (tablet) reveals tooltip.  
- Active tool glows Venus Orange.  
- Right-click (desktop) or long-press (tablet) opens sub-tool menu (e.g., Pencil → Charcoal).  
- Fixed for v0.1, collapsible in future versions.

---

### 🖼️ Central Canvas — Drawing Zone
The core workspace where artists paint, sketch, or design.

**Behaviour**
- Fully dynamic size (adapts to window or device screen).  
- Zoom, rotate, pan via mouse wheel or gestures.  
- Stylus pressure sensitivity supported (Wacom, Apple Pencil, Surface Pen).  
- Transform handles appear around selected layers for resizing or rotating.  
- “Zen Mode” hides all panels with one keypress or gesture.

**Canvas Defaults**
- Auto-adjusts to display resolution (Full HD or Retina on desktop, full-screen on iPad).  
- “New Canvas” popup offers presets: *Screen / Print / Custom*.  
- Background colour selectable.

---

### 🧩 Right Sidebar — Layers & Properties
Docked vertical panel on the right, divided into two main tabs:

#### 1. **Layers**
- Thumbnails of each layer.  
- Visibility toggle 👁, lock 🔒, rename, drag to reorder.  
- Blend modes (Normal, Multiply, Screen, Overlay).  
- Add/delete layer buttons at bottom.  

#### 2. **Colour**
- Colour wheel, sliders (RGB/HSV), HEX field.  
- 10 recent swatches.  
- Accent orange highlight for current colour.  

**Behaviour**
- Collapsible; remembers last open tab.  
- Tabs shown at top (Layers / Colour / Text).  
- Same UI template shared across Boojy Suite.

---

### ✍️ Text Panel (New for v0.1)
- Accessible via **Text Tool** (T icon in left toolbar).  
- Opens contextual sub-panel below top bar when active.

**Basic Text Features (v0.1)**
- Add editable text box layer.  
- Change font (system fonts + custom font import).  
- Adjust size, colour, alignment, line spacing.  
- Bold, italic, underline toggle.  
- Rotate and scale directly on canvas (with handles).  
- Drag text box freely on canvas.  
- Editable via double-click.  
- Text layers behave like normal layers (reorder, blend, lock).  

**Deferred for Future Versions**
- Text effects (stroke, shadow).  
- Warp, path text, text-on-curve.  
- Gradient and mask support.  

---

### 📊 Bottom Bar — Info & Status
A minimal status row along the bottom.

**Displays**
- Canvas size (e.g. 3000×2000 px)  
- Zoom level  
- Autosave status (“Saved 1m ago”)  
- Undo count (e.g. “Undo: 120/200”)  

**Behaviour**
- Non-interactive; informational only.  
- Flashes gently when autosave or export completes.  
- Optional memory usage indicator in dev mode.

---

### 📱 Tablet Adaptation
- Layout retains logic but condenses UI:
  - Top bar slimmer; icons replace text.
  - Left toolbar scrollable.
  - Right panel becomes pop-out overlays.
  - Brush size/opacity use edge sliders (Procreate style).
- Single “UI Toggle” button hides both sidebars for edge-to-edge canvas.

---

## 4. Canvas Engine

- Raster-based drawing engine.  
- File format: `.draw` (JSON metadata + PNG layers).  
- Autosave every 60 seconds; crash recovery on reopen.  
- Undo limit: 200 steps (user-adjustable later).  
- Supports transform handles for scale/rotate.  
- CMYK deferred until v1.0.

---

## 5. Brush System

**Brush Types (v0.1)**
1. Pencil  
2. Pen  
3. Marker  
4. Airbrush  
5. Eraser  

**Brush Options**
- Size, opacity, flow sliders (top bar).  
- Pressure sensitivity curve presets (soft, medium, firm).  
- Brush presets list (Quick Select menu).  
- Blend modes: Normal, Multiply, Add.  

**Deferred**
- Custom brush creation and texture import (v1.0+).

---

## 6. Layers System

- Unlimited layers (hardware-dependent).  
- Grouping deferred to v1.0.  
- Layer opacity, visibility, lock.  
- Drag-and-drop ordering.  
- Transparency lock toggle.  
- Layer rename and duplicate.

---

## 7. Colour System

- RGB workflow (CMYK later).  
- Floating colour overlay accessible anywhere (like Procreate).  
- Wheel, RGB/HSV sliders, HEX field, recent colours.  
- Shared across Boojy Suite for consistent UX.

---

## 8. File Management

- `.draw` format for layered projects.  
- Save/load locally or to Boojy Cloud (optional).  
- Auto backup every 60s to prevent loss.  
- Export formats:
  - PNG (with transparency)
  - JPG (adjustable quality)
  - TIFF (flattened)
  - All layers as individual PNGs  

---

## 9. Text System (Summary)

| Feature | Included v0.1 | Notes |
|----------|----------------|-------|
| Add text layers | ✅ | Via Text tool |
| Font change | ✅ | System + custom fonts |
| Bold/Italic/Underline | ✅ | Basic toggles |
| Colour & opacity | ✅ | From colour picker |
| Alignment | ✅ | Left/centre/right |
| Rotate/Scale | ✅ | Canvas handles |
| Line spacing | ✅ | Simple slider |
| Warp/Curve/Gradient | ❌ | Deferred |
| Masked text | ❌ | Deferred |

---

## 10. Undo & History

- 200 undo steps default.  
- Redo: `Ctrl+Shift+Z` or two-finger gesture.  
- History resets on new project.  
- “Undo History” panel planned for v1.0.

---

## 11. Branding & Theming

- Accent Colour: Venus Orange `#F4A261`.  
- Dark grey interface for comfort.  
- Animated planet glow in title bar.  
- Shared grid system with Boojy Audio and Design.  
- Same corner radius (8px) and spacing rhythm across suite.  

---

## 12. Accessibility & Shortcuts

- Hover tooltips (desktop) / long-press hints (tablet).  
- Common shortcuts:  
  - `B` Brush  
  - `E` Eraser  
  - `T` Text  
  - `Ctrl+Z` Undo  
  - `Ctrl+S` Save  
  - `Tab` Toggle panels  
- Zen Mode toggle hides all UI for distraction-free work.  
- Adaptive UI density planned (Compact / Standard / Large).

---

## 13. Target Users

- Hobbyists and students.  
- Independent illustrators and designers.  
- Artists switching from iPad apps to desktop.  
- Users seeking a free, modern alternative to Krita or Photoshop.  

---

## 14. Platform Plan

- **Engine:** Flutter (cross-platform)  
- **Supported:** macOS, Windows, Linux, iPadOS  
- **Storage:** Local + Boojy Cloud (optional)  
- **Distribution:** Download from boojy.org/preview  

---

## 15. Deferred Features (Beyond v0.1)

| Category | Deferred Items |
|-----------|----------------|
| Brushes | Custom brush creator, textures |
| Layers | Grouping, masks, adjustment layers |
| Text | Warp, gradients, effects |
| Colour | CMYK workflow, colour profiles |
| Effects | Filters (blur, sharpen, noise) |
| Collaboration | Multi-user drawing |
| Export | PDF, PSD formats |

---

## 16. UX Design Principles

| Principle | Description |
|------------|--------------|
| **Clarity** | Clean layout, minimal clutter |
| **Familiarity** | Feels natural to Procreate/Krita users |
| **Speed** | Immediate brush response and autosave |
| **Consistency** | Common UI across all Boojy apps |
| **Creativity** | Maximise canvas visibility and simplicity |

---

## 17. Development Roadmap

| Week | Focus | Deliverable |
|------|--------|-------------|
| 1–2 | Core UI shell, tool system | Static layout in Flutter |
| 3–4 | Canvas & brush engine | Working drawing prototype |
| 5–6 | Layers + colour system | Editable stack and picker |
| 7–8 | Text system | Add/edit text layers |
| 9–10 | File save/export | `.draw` save + PNG export |
| 11 | Testing + feedback | Internal + tester review |
| 12 | Preview Release | Publish for Boojy testers |

---

## 18. Summary

**Boojy Draw v0.1** aims to provide an accessible but professional foundation for digital art creation.  
The goal: *as intuitive as Procreate, as flexible as Krita, and as cohesive as GarageBand for art.*

---

© 2025 Boojy.org – Designed by Tyr Bujac  
*Part of the Boojy Suite: Creative Freedom for Everyone.*