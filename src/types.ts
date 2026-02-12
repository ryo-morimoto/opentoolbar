/**
 * DOM-based anchor for locating an element at runtime.
 * Always available regardless of framework.
 * Used by the toolbar to re-discover the element on page load.
 */
export interface DomAnchor {
  /** CSS selector that uniquely identifies the element on the page */
  selector: string;
  /** Text content of the element at comment creation time (for staleness comparison) */
  textContent: string;
  /** HTML tag name (e.g., "button", "div") */
  tagName: string;
  /** Bounding rectangle at comment creation time (for pin positioning fallback) */
  boundingRect: { x: number; y: number; width: number; height: number };
  /** Truncated outer HTML snapshot (for staleness comparison and AI context) */
  htmlSnapshot: string;
}

/**
 * Source-code anchor for tracking an element back to its source file.
 * Only available when a framework adapter (React/Vue/Svelte) is active.
 * Used for git-level staleness detection and AI agent context.
 */
export interface SourceAnchor {
  /** Path to the source file that renders this element (relative to project root) */
  filePath: string;
  /** Name of the component that renders this element (e.g., "LoginButton") */
  componentName: string | null;
  /** Line number in the source file */
  lineNumber: number | null;
  /** Git commit SHA at the time the comment was created (for staleness detection via git diff) */
  commitSha: string;
}

/**
 * Author of a comment.
 * Populated from git config (local dev) or GitHub profile (preview deploy).
 */
export interface Author {
  /** Display name */
  name: string;
  /** Email address */
  email: string;
  /** Avatar URL (GitHub profile image, or null for local dev) */
  avatarUrl: string | null;
  /** Where the author info was sourced from */
  source: "git-config" | "github";
}

/**
 * A comment attached to a UI element.
 * Stored as JSON on the git shadow branch.
 */
export interface Comment {
  /** Unique identifier (nanoid, 12 characters) */
  id: string;
  /** Comment text (plain text, no markdown in MVP) */
  text: string;
  /** Git branch name the comment was created on (e.g., "main", "feature/auth") */
  branch: string;
  /** DOM-based anchor (always present) */
  domAnchor: DomAnchor;
  /** Source-code anchor (present only when framework adapter was active at creation time) */
  sourceAnchor: SourceAnchor | null;
  /** Who created this comment */
  author: Author;
  /** Persisted state: only "active" or "resolved". Stale is computed at display time. */
  status: "active" | "resolved";
  /** ISO 8601 timestamp of creation */
  createdAt: string;
  /** ISO 8601 timestamp of last status change */
  updatedAt: string;
}

/**
 * Top-level structure of a comment file stored on the shadow branch.
 * One file per page (pathname) per project.
 */
export interface CommentFile {
  /** Schema version for forward compatibility (currently 1) */
  version: 1;
  /** The project identifier (from script tag data-project-id or CLI config) */
  projectId: string;
  /** The page pathname this file covers (e.g., "/", "/dashboard", "/settings") */
  pathname: string;
  /** All comments on this page */
  comments: Comment[];
}
