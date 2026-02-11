---
name: review
description: Review already-implemented code retroactively, with demo verification. Use when the user wants to review existing code changes or a git ref.
disable-model-invocation: true
---

Review already-implemented code retroactively, with demo verification.

Run without stopping between steps.

## Step 1: Retroactive Change

- Create `openspec/changes/<change-name>/`.
- Generate proposal.md from actual code diff.
- Generate tasks.md retroactively — all tasks marked `[x]`.

## Step 2: Verify (Showboat)

- Build demo.md with showboat commands to verify existing implementation.
- `showboat verify` must pass.

## Step 3: Review + Learnings

- Create review.md + learnings.md from code AND demo.
- [MUST FIX] → fix + re-record demo. Stop after 2 failed attempts.

## Step 4: Archive

- Append learnings to LEARNINGS.md. Print summary.
