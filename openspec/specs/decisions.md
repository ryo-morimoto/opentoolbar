# Open Decisions

Decisions to be made during implementation.

## Decided

| # | Item | Decision | Reason |
|---|------|----------|--------|
| 1 | Target framework | React | Narrow the scope |
| 2 | Storage | localStorage + CLI (hybrid) | Multi-project support |
| 3 | Authentication | Anonymous | Keep it simple |
| 4 | Distribution | npm package | Standard approach |
| 5 | Element binding | CSS selector + coordinates | Same as Vercel |
| 6 | Threads | Single comment | Keep MVP simple |
| 7 | Status | active / outdated | Sufficient for needs |

## Undecided (to be decided during MVP implementation)

| # | Item | Options | Notes |
|---|------|---------|-------|
| 1 | react-grab integration | A: Depend on it / B: Independent implementation inspired by it | Element selection logic |
| 2 | `.comments/` git management | A: Ignored by default / B: Included by default | Intent for team sharing |
| 3 | Shortcut customization | A: Fixed / B: Configurable | |

## Future Considerations (post-MVP)

| # | Item | Priority | Notes |
|---|------|----------|-------|
| 1 | Auto screenshot capture | Medium | html2canvas or manual |
| 2 | Vite/Next Plugin | Medium | Easier integration |
| 3 | Markdown support | Low | Comment body formatting |
| 4 | Multi-browser sync | Low | Real-time or on reload |
