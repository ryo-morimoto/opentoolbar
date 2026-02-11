# Data Model Specification

## Purpose

Define core data structures for UI comments, element anchoring, and file storage.

## Requirements

### Requirement: Comment Structure

The system MUST store comments as objects with id, anchor, text, status, and timestamps.

#### Scenario: Create a comment

- GIVEN a selected UI element with a valid anchor
- WHEN the user submits comment text
- THEN a Comment is created with a UUID v4 id, status "active", and ISO8601 timestamps

#### Scenario: Comment status values

- GIVEN a comment exists
- WHEN the system evaluates its status
- THEN the status MUST be one of "active" or "outdated"

### Requirement: Element Anchor

The system MUST anchor comments to DOM elements using a hybrid CSS selector + coordinate approach.

#### Scenario: Anchor with id

- GIVEN an element with `id="login-btn"`
- WHEN a comment is anchored
- THEN the selector is `#login-btn`

#### Scenario: Anchor with data-testid

- GIVEN an element with `data-testid="submit"`
- WHEN a comment is anchored
- THEN the selector is `[data-testid="submit"]`

#### Scenario: Anchor with path selector fallback

- GIVEN an element with no id or data-testid
- WHEN a comment is anchored
- THEN the selector is built from tag names, class names (first 1-2), and nth-child

### Requirement: Element Re-identification

The system SHOULD re-identify elements using CSS selector with coordinate/text fallback.

#### Scenario: Selector still matches

- GIVEN a comment with selector `#login-btn`
- WHEN `document.querySelector` finds the element
- THEN that element is returned

#### Scenario: Selector no longer matches

- GIVEN a comment whose selector no longer matches any element
- WHEN the system attempts re-identification
- THEN it falls back to `elementsFromPoint` near the stored coordinates
- AND matches by tagName and textContent prefix

#### Scenario: Element not found at all

- GIVEN neither selector nor fallback finds the element
- WHEN re-identification fails
- THEN the function returns null (element treated as outdated)

### Requirement: Outdated Detection

The system MUST detect when a commented element has changed since the comment was created.

#### Scenario: Element disappeared

- GIVEN the anchored element no longer exists in the DOM
- WHEN outdated check runs
- THEN the comment is marked as outdated

#### Scenario: Element HTML changed

- GIVEN the element exists but its outerHTML (first 500 chars) differs from the stored snapshot
- WHEN outdated check runs
- THEN the comment is marked as outdated

### Requirement: File Storage Format

The system MUST store comments as per-page JSON files organized by branch.

#### Scenario: Directory structure

- GIVEN a project with comments on multiple pages and branches
- WHEN comments are saved via CLI
- THEN files are organized as `.comments/{branch}/{pathname}.json`

#### Scenario: Page JSON structure

- GIVEN comments for page "/"
- WHEN saved to file
- THEN the JSON contains `version`, `pathname`, `updatedAt`, and `comments` array conforming to the CommentPage interface
