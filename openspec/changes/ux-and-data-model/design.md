## Context

opentoolbar needs foundational UX and data model definitions before any component can be implemented. The project follows Entire.io's shadow branch architecture for git-native comment storage and Vercel Toolbar's framework-agnostic approach. Key design decisions were made in the explore session documented in LEARNINGS.md.

## Goals / Non-Goals

**Goals:**
- Define all UX states and transitions for comment creation and management
- Define TypeScript types that map 1:1 to the JSON stored on the shadow branch
- Define the shadow branch directory structure, branch scoping, and git trailers
- Define a contract for AI agents to read/write comments using git commands

**Non-Goals:**
- Toolbar UI implementation
- CLI implementation
- GitHub API integration for preview deploys
- Framework adapter implementation (React/Vue/Svelte)
- Element selection algorithm / CSS selector generation

## Decisions

### Dual-layer anchor (Source + DOM)
Each comment stores two anchors. DomAnchor (CSS selector, textContent, boundingRect, htmlSnapshot) is always present and framework-agnostic. SourceAnchor (filePath, componentName, lineNumber, commitSha) is nullable and requires a framework adapter.

**Alternatives considered:** Single anchor (DOM only) — rejected because git-level staleness detection requires source file tracking. Single anchor (Source only) — rejected because it requires a framework adapter to function at all.

### Single shadow branch with branch field
One orphan branch `opentoolbar/comments/v1` for all code branches. Each comment stores the code branch name in a `branch` field. Filtering happens at read time.

**Alternatives considered:** One shadow branch per code branch — rejected because branch names containing `/` complicate paths, and it causes shadow branch proliferation. Following Entire.io's approach.

### Stale as computed state
Only `active` and `resolved` are persisted. `stale` is computed at display time via git diff (source changed) or DOM mismatch (content diverged).

**Alternatives considered:** Storing `stale` as a third status — rejected because staleness is relative to the current code state and changes with every commit.

### Git trailers for comment-commit linkage
`Opentoolbar-Comment: <id>` trailers link code commits to comments via a `prepare-commit-msg` hook. Enables bidirectional lookup.

**Alternatives considered:** Storing commit references in the comment JSON — rejected because it requires updating the shadow branch on every code commit. Trailers keep the linkage in the code commit itself.

### Agent write path: CLI preferred, git plumbing as fallback
CLI is the recommended write path for agents. Direct git plumbing (`hash-object` → `mktree` → `commit-tree` → `update-ref`) is documented for environments where CLI cannot be installed.

**Alternatives considered:** CLI only — rejected because some agent environments cannot install external tools. Git plumbing only — rejected because it's error-prone for nested tree updates.

## Risks / Trade-offs

- **[Risk] Git plumbing complexity** → Mitigated by recommending CLI as primary path and clearly documenting the two-level tree rebuild for plumbing.
- **[Risk] nanoid collision** → At 12 characters with 64-char alphabet, collision probability is negligible at expected scale (thousands, not millions of comments).
- **[Risk] Shadow branch divergence in teams** → Mitigated by same merge-friendly design as Entire (per-page files minimize conflicts).
- **[Trade-off] No iframe support in MVP** → Simplifies implementation; can be added later.
