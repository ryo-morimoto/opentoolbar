# Project Learnings

> AI agents reference this file when starting a new change.
> Automatically appended during the /compound:ship archive step.

---

## Learnings from Design Discussion (2024-01)

### Vercel Preview Comments Technical Research

- Vercel **auto-injects scripts at the edge** (during Preview Deployments)
- `@vercel/toolbar` package allows manual injection
- Comments are **bound to DOM elements** (CSS selector-based)
- From their blog: "A comment marks exactly in the UI where things need to improve as it's actually attached to the underlying DOM element."
- `@vercel/toolbar` is **framework agnostic** — generic `mountVercelToolbar()` API works with any framework, plus dedicated integrations for Next.js, Nuxt, SvelteKit, Remix, Astro

### Relationship with react-grab

- react-grab specializes in **element selection + React component info extraction**
- Uses **bippy** to tap into React Fiber internals for source location (filePath, lineNumber, componentName)
- Has a **plugin system** (`__REACT_GRAB__.registerPlugin()`) with rich hooks (onElementSelect, transformCopyContent, etc.)
- **Dev mode only** — production builds strip source locations, falls back to component names only
- **React only** — depends on Fiber architecture, not usable with Vue/Svelte/vanilla
- opentoolbar should NOT depend on react-grab. Instead, use it as an **optional adapter** to enrich anchors with source info when React is available

### Integration Method Selection

- **Script tag approach** is optimal for MVP (same approach as react-grab)
- Provider pattern rejected due to high invasiveness
- Vite/Next Plugin deferred to future

---

## Design Decisions from Explore Session (2025-02)

### Data Store: Git with Shadow Branch (Entire-inspired)

- Primary data store is **git**, not localStorage or a remote database
- Follow [Entire.io](https://github.com/entireio/cli) architecture: **shadow branch** (`opentoolbar/comments/v1`) stores comment data separately from code commits
- Code branches stay clean — no `.comments/` directory polluting diffs
- Link comments to commits via **git trailers** (e.g., `Opentoolbar-Comment: <id>`)
- `.opentoolbar/` directory in working tree contains **settings only** (like Entire's `.entire/settings.json`)
- Research: [Entire CLI README](https://github.com/entireio/cli), [Entire Docs](https://docs.entire.io/core-concepts)

### Framework: Agnostic Core + Optional Adapters

- Core is **vanilla JS, framework agnostic** — must work without React/Vue/Svelte
- Element anchoring in core uses **CSS selector + textContent + position** (no framework dependency)
- Optional adapters enrich anchors with framework-specific info:
  - React adapter: bippy/Fiber → filePath, componentName, lineNumber
  - Vue adapter: component tree → source info
  - Svelte adapter: component info
- This mirrors Vercel Toolbar's approach (generic core + framework-specific integrations)

### Comment Lifecycle: Intent as Persistent Context

- Comments are **not TODOs** that get deleted after resolution
- Comments contain **intent** ("why this UI should be this way") which remains valuable after the action is addressed
- Analogy: Entire preserves "why code was written this way" (AI session context); opentoolbar preserves "why UI should be this way" (design intent context)
- Comments are **basically immutable once created** — they accumulate as contextual history
- Resolution is a **status change**, not deletion — resolved comments stay in git history and remain queryable
- AI agents can read comments directly from the shadow branch — no MCP server or export step needed

### Anchor Design: Dual-Layer (Source + DOM)

- Each comment stores two types of anchors:
  - **Source anchor** (persistent, git-trackable): filePath, componentName, commitSha at creation time
  - **DOM anchor** (runtime, for re-discovery): CSS selector, textContent, bounding rect
- Staleness detection via 3 layers:
  1. **Git level** (offline): `git diff <comment-commit>..HEAD -- <filePath>` — detects source changes without browser
  2. **DOM level** (runtime): re-locate element via DOM anchor signals, compare to stored state
  3. **Human level** (explicit): user can re-anchor, resolve, or confirm still-relevant
- Source anchor requires framework adapter (React/Vue/Svelte) — without adapter, only DOM anchor is available

### Write Path: Dual-Route (Local CLI + GitHub API)

- **Local dev**: Browser → WebSocket → CLI (localhost) → git (direct write to shadow branch)
- **Preview deploy**: Browser → GitHub API → shadow branch (remote write, no CLI needed)
- Same shadow branch, same data format — two write paths to the same source of truth
- CLI-less operation is supported for preview deploys; CLI is only needed for local dev
- If CLI is not connected in local dev, toolbar shows "Not connected" and operates read-only

### Authentication & Author

- **Preview deploy**: GitHub OAuth — provides authentication and user identity (name, avatar, profile)
- **Local dev**: `git config user.name` / `user.email` — provided by CLI via WebSocket
- Author info is stored with each comment, sourced from whichever write path created it

### UX: Interaction Flow

- Hover icon (always visible) → click to enter comment mode
- Comment mode: hover highlights elements → click or drag to select
- Inline popover for writing comments
- Pin remains on page after comment is created (active comments only)
- Toolbar dropdown shows all comments (active, stale, resolved)

### UX: Comment States

- Data stores two states: `active` and `resolved`
- `stale` is **computed at display time** — detected via git diff (source changed since comment commitSha) or DOM mismatch
- Pins on page: active only. Stale/resolved visible in toolbar dropdown
- State transitions: active → resolved (explicit), stale → active (re-anchor), stale → resolved

### Multi-project / Worktree Support

- Need to **compose keys from projectId + branch** for identification
- Single shadow branch for all code branches — each comment stores which code branch it was created on via the `branch` field (Entire-inspired). Toolbar filters by current branch at read time.
- Git worktree support follows Entire's model — each worktree has independent tracking
