## ADDED Requirements

### Requirement: Comment mode lifecycle
The toolbar SHALL provide a comment mode with four states: Idle, Comment Mode, Highlighting, and Popover. Users MUST be able to enter comment mode via a hover icon click or the `C` keyboard shortcut, and exit via ESC, re-clicking the icon, or pressing `C` again.

#### Scenario: Enter comment mode via hover icon
- **WHEN** user clicks the toolbar hover icon in Idle state
- **THEN** the toolbar enters Comment Mode, cursor changes, and page interactions are suppressed

#### Scenario: Enter comment mode via keyboard shortcut
- **WHEN** user presses `C` in Idle state
- **THEN** the toolbar enters Comment Mode

#### Scenario: Exit comment mode
- **WHEN** user presses ESC, clicks the hover icon again, or presses `C` again in Comment Mode
- **THEN** the toolbar returns to Idle state and page interactions resume

#### Scenario: Element highlighting on hover
- **WHEN** user hovers over a page element in Comment Mode
- **THEN** the element is visually highlighted (outlined) as Highlighting state

#### Scenario: Select element by click
- **WHEN** user clicks a highlighted element
- **THEN** a comment creation Popover opens adjacent to the element

#### Scenario: Select region by drag
- **WHEN** user clicks and drags to encompass a region
- **THEN** a comment creation Popover opens anchored to the bounding box of the drag region

#### Scenario: Nested element selection
- **WHEN** cursor is over nested elements
- **THEN** the innermost (deepest) element is highlighted without requiring modifier keys

#### Scenario: SPA navigation during comment mode
- **WHEN** the page navigates to a new route while in Comment Mode
- **THEN** Comment Mode remains active and pins update for the new pathname

### Requirement: Comment creation popover
The toolbar SHALL display an inline popover for creating comments. The popover MUST contain a multiline text input (auto-focused), author display, and Submit/Cancel buttons. Submit MUST be available via `Cmd+Enter` (Mac) / `Ctrl+Enter` (Win/Linux). The Submit button MUST be disabled when text is empty.

#### Scenario: Submit comment
- **WHEN** user types text and presses Cmd+Enter or clicks Submit
- **THEN** the comment is saved, a pin appears at the element, the popover closes, and Comment Mode remains active

#### Scenario: Cancel comment
- **WHEN** user presses ESC or clicks Cancel in the popover
- **THEN** the draft is discarded and the toolbar returns to Comment Mode

#### Scenario: Click outside popover
- **WHEN** user clicks outside the popover area
- **THEN** the popover closes, draft is discarded, and Comment Mode remains active

#### Scenario: Click on existing pin
- **WHEN** user clicks an existing comment pin
- **THEN** a read-only popover opens showing the comment text, author, and timestamp

### Requirement: Pin display
Active comments SHALL display pins at the top-right corner of the anchored element's bounding rect. Pins MUST be positioned in a toolbar-owned overlay layer. Only active comments show pins; resolved and stale comments are visible only in the toolbar dropdown.

#### Scenario: Pin positioning on scroll/resize
- **WHEN** the page scrolls or resizes
- **THEN** pins reposition by recalculating the anchored element's bounding rect

#### Scenario: Anchored element not found
- **WHEN** the anchored element is not in the current DOM (removed or different page)
- **THEN** the pin is hidden

#### Scenario: Anchored element scrolled out of viewport
- **WHEN** the anchored element exists but is scrolled out of the viewport
- **THEN** the pin is hidden and the comment remains accessible via the toolbar dropdown's click-to-scroll

#### Scenario: Multiple pins at same position
- **WHEN** two pins would occupy the same position
- **THEN** pins stack vertically with a small offset to avoid overlap

### Requirement: Toolbar dropdown
The toolbar SHALL provide a dropdown listing all comments for the current page. Each item MUST show: status indicator (filled circle for active, warning for stale, empty circle for resolved), comment number, truncated text, element name, author, and relative timestamp. Items MUST be sorted: active newest first, then stale newest first, then resolved newest first.

#### Scenario: Click dropdown item
- **WHEN** user clicks a comment item in the dropdown
- **THEN** the page scrolls to the anchored element and opens the comment popover

#### Scenario: Filter by state
- **WHEN** user selects a filter tab (active / stale / resolved / all)
- **THEN** the dropdown shows only comments matching the selected filter

### Requirement: Comment state transitions
Comments SHALL have two persisted states: `active` and `resolved`. The `stale` state MUST be computed at display time, not stored. A comment is stale when the source file changed since `sourceAnchor.commitSha` (via git diff) or the DOM element's content diverges from the stored `domAnchor.htmlSnapshot`.

#### Scenario: Resolve a comment
- **WHEN** user triggers the resolve action on an active or stale comment
- **THEN** the comment status changes to `resolved` and the pin is removed from the page

#### Scenario: Re-anchor a stale comment
- **WHEN** user triggers the re-anchor action on a stale comment
- **THEN** the anchors are refreshed to the current element state and the comment returns to `active`

#### Scenario: Unresolve a comment
- **WHEN** user triggers the unresolve action on a resolved comment
- **THEN** the comment status changes back to `active` and a pin reappears
