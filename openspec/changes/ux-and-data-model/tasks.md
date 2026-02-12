# Tasks: ux-and-data-model

## Phase 1: UX Flow Specification

- [x] **1.1**: Define comment mode lifecycle (activation via hover icon / shortcut, element highlight on hover, click/drag to select, exit mode) — Acceptance: state diagram covers all transitions, edge cases documented (e.g., clicking outside, ESC to cancel)
- [x] **1.2**: Define comment creation flow (inline popover appears after selection, user types comment, submit/cancel actions) — Acceptance: wireframe or ASCII diagram of popover, required vs optional fields specified
- [x] **1.3**: Define pin display behavior (active-only pins on page, positioning relative to anchored element, behavior on scroll/resize) — Acceptance: pin placement rules documented, what happens when element is off-screen
- [x] **1.4**: Define toolbar dropdown (comment list showing all states, filtering by active/stale/resolved, click-to-navigate to pin) — Acceptance: dropdown layout specified, sort order defined
- [x] **1.5**: Define comment state transitions and visual representation (active/resolved stored, stale computed, re-anchor and resolve actions) — Acceptance: state diagram, visual differentiation between states in dropdown

## Phase 2: Data Model (TypeScript Types)

- [x] **2.1**: Define `DomAnchor` type (CSS selector, textContent, tagName, bounding rect, HTML snapshot) — Acceptance: type compiles, each field has doc comment explaining purpose and when it's used
- [x] **2.2**: Define `SourceAnchor` type (filePath, componentName, lineNumber, commitSha) — Acceptance: type compiles, clearly marked as optional (requires framework adapter)
- [x] **2.3**: Define `Author` type (name, email, avatarUrl, source: "git-config" | "github") — Acceptance: type covers both local and preview deploy author sources
- [x] **2.4**: Define `Comment` type (id, text, anchor, author, status, timestamps) — Acceptance: type compiles, `status` is `"active" | "resolved"`, stale is NOT a stored state
- [x] **2.5**: Define `CommentFile` type (the top-level structure stored as JSON on shadow branch — version, pathname, projectId, comments array) — Acceptance: type compiles, includes schema version for future migration

## Phase 3: Shadow Branch File Format

- [x] **3.1**: Define directory structure on `opentoolbar/comments/v1` branch — Acceptance: documented with examples, explains sharding/organization strategy (e.g., by pathname, by project)
- [x] **3.2**: Define JSON file schema with a concrete example — Acceptance: a complete example JSON file with 2+ comments, validatable against the TypeScript types
- [x] **3.3**: Define comment ID generation strategy — Acceptance: strategy documented (e.g., UUID v4, nanoid), uniqueness and collision risk addressed

## Phase 4: AI Agent Contract

- [x] **4.1**: Define read contract (how an agent discovers and reads comments from shadow branch) — Acceptance: step-by-step example of an agent reading comments using only git commands
- [x] **4.2**: Define write contract (how an agent creates or resolves a comment) — Acceptance: step-by-step example of an agent writing a comment and committing to shadow branch
