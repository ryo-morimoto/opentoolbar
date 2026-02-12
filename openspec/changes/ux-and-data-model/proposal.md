## Why

All implementation (toolbar UI, CLI, GitHub API integration) depends on two things being defined first: what the user does (UX) and what data represents that (types). Without these, each component will be designed in isolation and won't fit together.

## What Changes

- Define the complete UX interaction flow: comment mode activation, element highlighting, popover creation, pin display, toolbar dropdown, comment state transitions
- Define TypeScript types for the data model: DomAnchor, SourceAnchor, Author, Comment, CommentFile
- Define the git shadow branch file format: directory structure, branch scoping, pathname mapping, git trailers
- Define the AI agent read/write contract: how agents discover, read, and write comments using git commands

## Capabilities

### New Capabilities
- `ux-flow`: Comment mode lifecycle, element selection, popover, pin display, toolbar dropdown, state transitions
- `data-model`: TypeScript types (DomAnchor, SourceAnchor, Author, Comment, CommentFile) stored on the shadow branch
- `shadow-branch-format`: Directory structure, branch scoping, pathname mapping, ID generation, git trailers on `opentoolbar/comments/v1`
- `agent-contract`: AI agent read/write contract using git commands and CLI

### Modified Capabilities

## Impact

- `src/types.ts`: Complete rewrite — old types (ElementAnchor, CommentPage) replaced with new types
- `src/index.ts`: Exports updated to match new type names
- `src/types.test.ts`: Rewritten to cover all new types
