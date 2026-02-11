---
name: plan
description: Generate proposal only for team alignment. Does NOT implement. Use when the user wants to plan a change and get team buy-in before implementation.
disable-model-invocation: true
---

Generate proposal only for team alignment. Does NOT implement.

1. Derive a short kebab-case change name from the description.
2. Read `openspec/learnings/LEARNINGS.md` and `openspec/specs/`.
3. Create `openspec/changes/<change-name>/proposal.md` only (What/Why/Scope, under 30 lines).
4. STOP. Print the proposal and wait for feedback.

After team approval, run `/compound:ship <change-name>` to implement.
The existing proposal will be reused.
