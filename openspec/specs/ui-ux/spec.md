# UI/UX Specification

## Purpose

Define the visual behavior, interaction patterns, and styling for the comment toolbar overlay.

## Requirements

### Requirement: Comment Mode Toggle

The system MUST provide a toggle to switch comment mode on and off.

#### Scenario: Toggle via UI button

- GIVEN the toolbar is loaded
- WHEN the user clicks the toggle button (fixed bottom-right)
- THEN comment mode toggles between ON and OFF

#### Scenario: Toggle via keyboard shortcut

- GIVEN the toolbar is loaded
- WHEN the user presses Cmd+Shift+C (macOS) or Ctrl+Shift+C (other)
- THEN comment mode toggles between ON and OFF

### Requirement: Element Highlight on Hover

The system MUST highlight elements on hover when comment mode is ON.

#### Scenario: Hover over an element

- GIVEN comment mode is ON
- WHEN the user hovers over a DOM element
- THEN a blue outline (2px solid #3B82F6) with semi-transparent background appears
- AND the highlight follows the element's bounding rect

#### Scenario: Comment mode is OFF

- GIVEN comment mode is OFF
- WHEN the user hovers over elements
- THEN no highlight is displayed

### Requirement: Comment Pins

The system MUST display numbered pins on elements that have comments.

#### Scenario: Active comment pin

- GIVEN an element has an active comment
- WHEN pins are rendered
- THEN a circular badge (24px, #3B82F6) with the page-sequence number appears at the element's top-right

#### Scenario: Outdated comment pin

- GIVEN an element has an outdated comment
- WHEN pins are rendered
- THEN the pin color is #9CA3AF (gray) instead of blue

### Requirement: Comment Popover

The system MUST show a popover for adding and viewing comments.

#### Scenario: Add a new comment

- GIVEN comment mode is ON and the user clicks an element
- WHEN the popover appears
- THEN it shows a textarea with Cancel and Save buttons

#### Scenario: View an existing comment

- GIVEN an element has a comment
- WHEN the user clicks its pin
- THEN the popover displays the comment text, timestamp, and Edit/Delete actions

### Requirement: Z-Index Layering

The system MUST maintain a consistent z-index layering order.

#### Scenario: Overlay stacking

- GIVEN toolbar elements are rendered
- WHEN they overlap with the host page
- THEN the stacking order is: Highlight (10000) < Pin (10001) < Popover (10002) < Toggle (10003)

### Requirement: Toggle Button with Count

The system MUST display a persistent toggle button showing the comment count.

#### Scenario: Comments exist

- GIVEN there are 3 active comments on the page
- WHEN the toggle button renders
- THEN it displays the count "3" next to the icon
