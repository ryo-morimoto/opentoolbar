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

### Relationship with react-grab

- react-grab specializes in **element selection + React component info extraction**
- Has a **plugin system** (`__REACT_GRAB__.registerPlugin()`)
- This tool can either build on top of react-grab or implement equivalent logic internally

### Multi-project / Worktree Support

- localhost:3000 alone is not sufficient for identification
- Need to **compose keys from projectId + branch**
- localStorage: `otb:${projectId}:${branch}:${pathname}`
- File storage: `.comments/${branch}/${pathname}.json`

### Integration Method Selection

- **Script tag approach** is optimal for MVP (same approach as react-grab)
- Provider pattern rejected due to high invasiveness
- Vite/Next Plugin deferred to future
