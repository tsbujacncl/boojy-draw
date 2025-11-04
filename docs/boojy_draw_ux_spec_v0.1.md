# 🎨 Boojy Draw — UX & Layout Specification v0.1

**Status:** Draft for review  
**Date:** November 2025  
**Scope:** Desktop-first (macOS/Windows), adaptive for tablet later  
**Theme:** Neutral-dark hybrid UI with Venus Orange accent `#F4A261`  
**Goal:** Instantly usable for hobbyists; scalable to “Studio Mode” later

---

## 1. Design Language & Tokens

### Colours
| Purpose | Hex | Description |
|----------|-----|-------------|
| Background / Stage | `#2B2C32` | Main canvas environment |
| Panels / Toolbars | `#35363E` | Interface surfaces |
| Borders / Dividers | `#454650` | Subtle outlines |
| Text Primary | `#EAEAEA` | Main UI text |
| Text Secondary | `#B0B1B6` | Muted labels |
| Accent (Draw / Venus) | `#F4A261` | Core app accent |
| Brand Accent (Global) | `#A855F7` | Rarely used in Draw |

### Typography
- **Font Family:** Inter (fallback: SF Pro / Roboto)
- **Sizes:** 13 (body), 12 (meta), 16 (panel titles), 20 (dialog titles)

### Radii & Spacing
- **Radius:** 8px  
- **Spacing scale:** 4 / 8 / 12 / 16 / 24 px

### Motion
- Hover → 80ms fade  
- Panel expand/collapse → 180ms ease-out  
- Save/autosave pulse → 1.2x glow for 200ms

---

## 2. Layout Regions & Behaviour

### 🧭 A. Top Bar (Global Controls)
**Contents**
- Menus: File / Edit / View / Layer / Select / Filter / Text / Help  
- Contextual controls: Brush preset, Size, Opacity, Blend Mode  
- Quick actions: Undo / Redo / Save / Export  
- Status dot animates on autosave/export  

**Behaviour**
- Fixed, context-aware  
- Sliders: compact (160px wide), keyboard-focusable  
- Tablet: text labels collapse to icons

---

### 🎨 B. Left Sidebar (Tool Palette)
**Default Tools**
Brush, Pencil, Eraser, Smudge, Fill, Select (Lasso/Rect), Shape, **Text**, Move, Zoom  

**Behaviour**
- Icon-only with hover/long-press tooltips  
- Active tool glows Venus Orange  
- Right-click (desktop) or long-press (tablet) opens sub-tools  
- Fixed layout for v0.1 (collapsible later)

**Shortcuts**
| Tool | Key |
|------|-----|
| Brush | B |
| Eraser | E |
| Fill | G |
| Select | S |
| Move | V |
| Text | T |
| Zoom | Z |
| Pan | Space+Drag |
| Brush Size | [ / ] |

---

### 🖼️ C. Central Canvas (Drawing Zone)
**Defaults**
- Desktop preset: 1920×1080 @ 72–144 dpi  
- iPad/tablet: device resolution

**New Canvas Dialog**
- Tabs: **Screen**, **Print**, **Custom**  
- Background colour picker (default transparent)

**Interactions**
- Zoom (wheel/pinch), Pan (Space+Drag), Rotate (future)  
- Transform handles around selections  
- **Zen Mode:** Tab hides UI; full-zen hides all panels

---

### 🧩 D. Right Sidebar (Tabs)
**Tabs**
1. **Layers**
   - Thumbnail list  
   - Visibility 👁 / Lock 🔒 / Opacity slider  
   - Blend modes: Normal / Multiply / Screen / Overlay  
   - Add / Delete / Duplicate  
   - Lock transparency toggle  

2. **Colour**
   - Wheel, RGB/HSV sliders, HEX field  
   - 10 recent swatches  
   - Eyedropper sync  

3. **Reserved (v1.0):** Brush / History

**Behaviour**
- Collapsible  
- Width: 280–340px  
- Tablet: overlay drawer (edge-swipe)

---

### 📊 E. Bottom Status Bar
**Displays**
- Canvas size  
- Zoom %  
- Autosave time  
- Undo count  

**Extras**
- Optional memory usage (dev mode only)

---

## 3. Tools & Context

### Brush / Pencil / Eraser / Smudge
- Shared backend with preset profiles  
- Controls: Size, Opacity, Flow, Pressure curve (Soft/Med/Firm)  
- Blend modes: Normal / Multiply / Add  

### Fill
- Flood fill with tolerance (0–100)  
- Sample: Current Layer / All Visible  
- Contiguous toggle

### Select
- Rectangular / Lasso  
- Feather slider  
- Transform handles auto-appear  
- Invert / Clear selection options

### Shape
- Rectangle, Ellipse, Line (v0.1)  
- Fill / Stroke / Corner radius  
- Shift = constrain; Alt = draw from centre  

### ✍️ Text (Basic v0.1)
**Editing**
- Add text box (Text Tool)  
- Double-click to edit text  
- Font (system + custom import)  
- Size, Weight (Bold/Italic), Underline  
- Colour + Opacity  
- Alignment (Left/Centre/Right)  
- Line & letter spacing sliders  

**Canvas**
- Rotate / Scale handles  
- Drag freely  
- Snaps to alignment guides (future)

**Layers**
- Text layers behave like standard layers (rename, reorder, blend, lock)

---

## 4. Canvas, Files & Persistence

### File Format
- `.draw` = zipped JSON + PNG layers + assets/fonts  
- Version tag for forward-compatibility  

### Save / Autosave / Recovery
- First Save prompt: “Local or Boojy Cloud?” (remember choice)  
- Autosave every 60s (diff-based)  
- Crash recovery: "Recovered project available"  

### Export Options
- PNG (with transparency)  
- JPG (quality slider)  
- TIFF (flattened)  
- “Export all layers to PNGs” option  

---

## 5. Layers & Blending
- Unlimited layers (hardware-dependent)  
- Opacity slider  
- Blend modes: Normal / Multiply / Screen / Overlay  
- Lock transparency toggle  
- Grouping deferred to v1.0

---

## 6. Undo & History
- 200 undo steps  
- Ctrl/⌘+Z / Ctrl/⌘+Shift+Z  
- Tablet: two/three-finger gestures (future)  
- History panel deferred (v1.0)

---

## 7. Accessibility, Help & Onboarding
- **First Launch Tips:**  
  - “Press **B** to draw”  
  - “Use **[ / ]** to resize brush”  
  - “Press **Tab** to hide panels”
- **Tooltips:** hover or long-press → name + shortcut + tip  
- **Help Menu:** shortcut reference  
- **Telemetry:** opt-in (disabled by default)

---

## 8. Tablet Adaptation (Phase 2)
- Left toolbar scrollable  
- Right panel as overlay drawers  
- Edge sliders for brush size/opacity  
- “UI Toggle” button hides both sidebars  
- Same spacing, grid, colours across devices

---

## 9. Deferred (Not in v0.1)
| Category | Deferred Items |
|-----------|----------------|
| Brushes | Custom brush designer, textures |
| Layers | Groups, masks, adjustment layers |
| Text | Warp, gradients, effects |
| Colour | CMYK, ICC profiles |
| Filters | Blur, sharpen, noise |
| History | Dedicated panel |
| Guides | Grid, symmetry, snapping |
| Collaboration | Multi-user drawing |

---

## 10. QA Acceptance (v0.1)
- Launch → new canvas within 5 seconds  
- Create 6 layers; blend/opacity functional  
- Add text, edit font, resize, export PNG (transparent)  
- Save `.draw`, reopen, all data intact  
- Autosave every 60s  
- Export formats verified  

---

## 11. Milestones (Engineering)
| Step | Focus | Deliverable |
|------|--------|-------------|
| 1 | Shell & Theme | Layout scaffolding, shared tokens |
| 2 | Canvas & Brush | Raster engine MVP |
| 3 | Layers | Stack model, blend modes |
| 4 | Colour | Picker, eyedropper, swatches |
| 5 | Select & Transform | Lasso, handles |
| 6 | Text (basic) | Add/edit, custom fonts |
| 7 | File I/O | `.draw` save/export, autosave |
| 8 | Polish & QA | Hints, performance tests |

---

## 12. UX Design Principles
| Principle | Description |
|------------|--------------|
| **Clarity** | Clean, minimal interface |
| **Familiarity** | Feels natural to Procreate/Krita users |
| **Speed** | Responsive canvas and autosave |
| **Consistency** | Shared design across all Boojy apps |
| **Creativity** | Focus on canvas, low friction |

---

## 13. Target Users
- Hobbyists and students  
- Independent illustrators and designers  
- Artists migrating from iPad apps  
- Users seeking a free, modern alternative to Krita/Photoshop

---

## 14. Platform Plan
- **Engine:** Flutter  
- **Supported:** macOS, Windows, Linux, iPadOS  
- **Storage:** Local + Boojy Cloud  
- **Distribution:** boojy.org/preview

---

© 2025 Boojy.org — Designed by Tyr Bujac  
*Part of the Boojy Suite: Creative Freedom for Everyone.*