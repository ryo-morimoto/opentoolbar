# Proposal: ux-and-data-model

## What

Define the UX interaction flow and the TypeScript data model that supports it. The UX specifies how users create, view, and resolve comments on UI elements. The data model defines the types stored on the git shadow branch, consumed by the browser, CLI, and AI agents.

## Why

All implementation (toolbar UI, CLI, GitHub API integration) depends on two things being defined first: what the user does (UX) and what data represents that (types). Without these, each component will be designed in isolation and won't fit together.

## Scope

**IN:**
- UX flow specification: comment mode activation, element selection, comment creation, pin display, comment states
- TypeScript type definitions: Comment, Anchor (DOM + Source), Author, CommentFile
- Shadow branch file format: directory structure, JSON schema for comment files
- AI agent read/write contract: what an agent sees when reading comment files

**OUT:**
- Toolbar UI implementation (separate change)
- CLI implementation (separate change)
- GitHub API integration (separate change)
- Framework adapters — React/Vue/Svelte (separate change)
- Element selection algorithm / CSS selector generation (separate change)
