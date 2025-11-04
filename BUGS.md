# Known Bugs & Issues

## Active Issues

### 🐛 Zoom Keyboard Shortcuts Not Working (macOS)
**Status:** Open
**Priority:** Medium
**Phase:** 2 (Canvas System)
**Date Reported:** 2025-11-04

**Description:**
Cmd/Ctrl + Plus/Minus keyboard shortcuts for zoom in/out don't seem to respond when held down.

**Expected Behavior:**
- Pressing `Cmd/Ctrl` + `+` should zoom in
- Pressing `Cmd/Ctrl` + `-` should zoom out
- Holding these keys should continuously zoom

**Actual Behavior:**
- Keys don't trigger zoom action consistently
- May be related to key event detection or modifier key handling

**Workarounds:**
- Use mouse wheel + Cmd/Ctrl for zooming (works)
- Use on-screen zoom buttons (bottom-right corner)

**Technical Notes:**
- KeyRepeatEvent handling was added (line 84, canvas_input_handler.dart)
- Fixed system error beeps, but zoom action itself not triggering
- Possible issues:
  - Modifier key detection (`isMeta`, `isControl`)
  - Key combinations not being recognized
  - Event propagation issue

**Files Affected:**
- `lib/canvas/canvas_input_handler.dart` (lines 84-122)

**Next Steps:**
- Debug key event logging to see what events are actually firing
- Test with different keyboard layouts
- Consider alternative shortcut detection method

---

## Resolved Issues

### ✅ Canvas Overlapping Side Panels
**Status:** Fixed
**Phase:** 2
**Date Fixed:** 2025-11-04

**Issue:** Canvas would render on top of left and right panels when zoomed in.
**Fix:** Added `ClipRect` widgets to `CanvasViewport` and `CanvasRenderWidget`.

### ✅ System Error Beeps on Key Hold
**Status:** Fixed
**Phase:** 2
**Date Fixed:** 2025-11-04

**Issue:** Holding Space or zoom keys caused repeating error audio beeps.
**Fix:** Added `KeyRepeatEvent` handling to properly consume key repeat events.

---

## Future Considerations

- Test keyboard shortcuts across different platforms (Windows, Linux)
- Add customizable keyboard shortcuts (Phase 8+)
- Consider accessibility alternatives for keyboard-only navigation
