# UX Specification: opentoolbar

## 1. Comment Mode Lifecycle

### State Diagram

```
                    ┌──────────────────────────────────────┐
                    │                                      │
                    ▼                                      │
             ┌──────────┐   click hover icon    ┌─────────┴──┐
             │          │   or shortcut (C)      │            │
             │  Idle    │──────────────────────▶│  Comment   │
             │          │                        │  Mode      │
             │          │◀──────────────────────│            │
             └──────────┘   ESC / click icon     └─────┬──────┘
                                again / shortcut       │
                                                       │ hover element
                                                       ▼
                                                ┌──────────────┐
                                                │  Highlighting │
                                                │  (element     │
                                                │   under       │
                                                │   cursor)     │
                                                └──────┬───────┘
                                                       │ click or
                                                       │ drag-select
                                                       ▼
                                                ┌──────────────┐
                                                │  Popover      │
                                                │  (comment     │
                                                │   input)      │
                                                └──────┬───────┘
                                                       │
                                          ┌────────────┼────────────┐
                                          │            │            │
                                          ▼            ▼            ▼
                                       Submit       Cancel        ESC
                                     (save pin)   (discard)    (discard)
                                          │            │            │
                                          ▼            └────────────┘
                                   Back to Comment            │
                                   Mode (ready for            ▼
                                   next comment)        Back to Comment
                                                        Mode
```

### States

| State | Description | User sees |
|---|---|---|
| **Idle** | Toolbar visible as hover icon. Page behaves normally. | Small floating icon (e.g., bottom-right) |
| **Comment Mode** | Listening for element hover. Page interactions suppressed (clicks don't navigate). | Cursor changes, subtle overlay tint |
| **Highlighting** | Cursor is over an element. Visual highlight shows what would be selected. | Element outlined/highlighted |
| **Popover** | Element selected. Inline popover open for comment input. | Popover near selected element |

### Transitions

| From | To | Trigger |
|---|---|---|
| Idle | Comment Mode | Click hover icon OR press `C` shortcut |
| Comment Mode | Idle | Press ESC / click hover icon again / press `C` again |
| Comment Mode | Highlighting | Mouse enters an element |
| Highlighting | Comment Mode | Mouse leaves element (back to empty area) |
| Highlighting | Popover | Click element OR complete drag selection |
| Popover | Comment Mode | Submit comment (save) |
| Popover | Comment Mode | Cancel (click cancel button or press ESC) |

### Edge Cases

- **Click outside popover**: Closes popover, discards draft, returns to Comment Mode
- **Click on existing pin**: Opens that comment's popover for viewing (not creation)
- **Drag selection**: User clicks and drags to encompass a region; all elements in the region are grouped as one selection. Anchor is the bounding box of the region.
- **Nested elements**: Highlight targets the most specific (deepest) element under cursor. No modifier key needed — always selects the innermost element.
- **iframes**: Not supported in MVP. Toolbar and comments are scoped to the top-level document.
- **Page navigation (SPA)**: On route change, pins update to show comments for the new pathname. Comment mode remains active across navigations.

## 2. Comment Creation Flow

### Popover Layout

```
┌─────────────────────────────────┐
│ ┌─────────────────────────────┐ │
│ │                             │ │
│ │  [Comment text input]       │ │
│ │  (multiline, auto-resize)   │ │
│ │                             │ │
│ └─────────────────────────────┘ │
│                                 │
│  [Author avatar + name]        │
│                                 │
│         [Cancel]  [Submit ⌘↵]  │
└─────────────────────────────────┘
        ▲
        │ arrow pointing to selected element
```

### Fields

| Field | Required | Source |
|---|---|---|
| Comment text | Yes | User input (plain text, no markdown in MVP) |
| Author | Auto | git config (local) or GitHub profile (preview) |
| Anchor | Auto | Generated from selected element |

### Behavior

- Popover appears adjacent to the selected element (preferred position: right or below, auto-flips if near viewport edge)
- Text input is focused immediately on open
- Submit: `⌘+Enter` (Mac) / `Ctrl+Enter` (Windows/Linux), or click Submit button
- Cancel: `ESC` or click Cancel button
- Empty text: Submit button is disabled
- After submit: pin appears at element, popover closes, user stays in Comment Mode

## 3. Pin Display

### Placement

- Pins appear at the **top-right corner** of the anchored element's bounding rect
- Pins are absolutely positioned in a toolbar-owned overlay layer (not injected into the page DOM tree)
- On scroll/resize: pins reposition by recalculating the anchored element's bounding rect

### Visibility

- Only **active** comments show pins on the page
- Resolved and stale comments do NOT show pins (visible only in toolbar dropdown)
- If the anchored element is not found in the current DOM (element removed, different page), the pin is hidden
- If the anchored element exists but is scrolled out of the viewport, the pin is hidden. The comment remains accessible via the toolbar dropdown's click-to-scroll behavior.

### Pin Interaction

- **Click pin**: Opens a read-only popover showing the comment text, author, and timestamp
- **Pin hover**: Highlights the anchored element (same visual as Comment Mode highlighting)
- Pins are numbered in creation order (per page) for easy reference

### Multiple Pins

- Multiple pins can exist on the same page
- Pins do not overlap: if two pins would occupy the same position, they stack vertically with a small offset

## 4. Toolbar Dropdown

### Layout

```
┌──────────────────────────────────┐
│  Comments (3 active, 1 resolved) │
├──────────────────────────────────┤
│  ● #1 "Button color should..."   │ ← active
│    LoginButton · @alice · 2h ago │
│  ● #2 "Spacing is off on..."     │ ← active
│    Header · @bob · 1h ago        │
│  ● #3 "Add hover state to..."    │ ← active (stale)
│    NavLink · @alice · 3d ago     │  ⚠ source changed
│  ○ #4 "Fixed padding issue"      │ ← resolved
│    Card · @alice · 1d ago        │
└──────────────────────────────────┘
```

### Content Per Item

- Status indicator: ● active, ⚠ stale, ○ resolved
- Comment number (#N, page-scoped)
- Comment text (truncated to one line)
- Element name (component name if adapter available, otherwise tag name)
- Author name
- Relative timestamp

### Sort Order

- Active (newest first) → Stale (newest first) → Resolved (newest first)

### Interactions

- **Click item**: Scrolls to the anchored element and opens the comment popover
- **Filter**: Tabs or toggle to filter by active / stale / resolved / all
- **Resolve action**: Available on each active/stale item via context menu or button

## 5. Comment State Transitions

### Stored States

Only two states are persisted in the data:

```
active ────────────▶ resolved
         (user explicitly resolves)
```

### Computed State: Stale

`stale` is derived at display time, not stored. A comment is stale when:

1. **Source changed** (git-level): The file at `sourceAnchor.filePath` has been modified since `sourceAnchor.commitSha` (detected via `git diff`)
2. **DOM mismatch** (runtime): The element found by `domAnchor.selector` has different `textContent` or structure than the stored `domAnchor.htmlSnapshot`

An `active` comment can appear as stale. A `resolved` comment's staleness is not displayed (it's already resolved).

### Actions

| Action | From | To | Who |
|---|---|---|---|
| **Resolve** | active / stale | resolved | User (via dropdown or popover) |
| **Re-anchor** | stale | active (with updated anchors) | User (confirms element, anchors are refreshed) |
| **Unresolve** | resolved | active | User (reopen a resolved comment) |

### Visual Differentiation (Dropdown)

| State | Indicator | Text style |
|---|---|---|
| Active | ● (filled circle) | Normal |
| Stale | ⚠ (warning) | Normal + "source changed" label |
| Resolved | ○ (empty circle) | Dimmed / muted |
