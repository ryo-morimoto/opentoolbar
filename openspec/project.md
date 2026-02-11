# opentoolbar

Open-source alternative to Vercel Toolbar. Leave comments directly on UI and pass them as structured data to AI agents — that's the key differentiator.

## Vision

```
Developers/designers leave comments while viewing UI
           |
   Stored as structured data
           |
AI agents automatically suggest fixes and implement them
```

## Differentiation

| Tool | Element selection | Comments | Agent integration |
|------|-------------------|----------|-------------------|
| @vercel/toolbar | Yes | Yes | No |
| react-grab | Yes | No | Yes (copy only) |
| **opentoolbar** | Yes | Yes | Yes (structured + MCP) |

## Target Users

- Frontend developers (self-review)
- Designers & PMs (design feedback)
- Developers who want integration with AI agents (Cursor, Claude Code, etc.)

## Tech Stack

- TypeScript
- React (for target apps)
- Vanilla JS (core logic for script tag version)
- Vitest (testing)

## Compound Engineering Guidelines

### Skills
- `/compound:ship <desc>` — Full autonomous cycle: plan -> implement -> verify -> review -> learn -> archive.
- `/compound:review <ref>` — Retroactive review with demo verification.
- `/compound:plan <desc>` — Proposal only (team alignment).

### Verification (Showboat + Rodney)
- Every change produces a `demo.md` built with `showboat exec`/`showboat image` commands.
- demo.md is NEVER written directly — always via showboat CLI.
- `showboat verify demo.md` must pass before review.
- For web UI changes, use `rodney` for screenshots.
- demo.md archives together with the change as evidence.

### Principles
- The cycle runs autonomously. Only unresolvable MUST FIX items stop the flow.
- Proposals < 30 lines. Bigger = split.
- Review covers both code AND demo.
- `openspec/learnings/LEARNINGS.md` compounds knowledge across changes.
