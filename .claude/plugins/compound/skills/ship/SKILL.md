---
name: ship
description: Run the complete compound engineering cycle autonomously. Use when the user wants to implement a feature end-to-end with plan, implement, verify, review, and learn steps.
disable-model-invocation: true
---

Run the complete compound engineering cycle autonomously.

You are an autonomous engineering agent. Execute the FULL cycle without stopping between steps. Do not ask "shall I proceed?" — just proceed.

## Step 1: Plan

- Derive a short kebab-case change name from the description.
- Read `openspec/learnings/LEARNINGS.md` — incorporate past lessons.
- Read `openspec/specs/` — understand existing architecture and decisions.
- Create `openspec/changes/<change-name>/proposal.md` (What/Why/Scope only, under 30 lines).
- Create `openspec/changes/<change-name>/tasks.md` (implementation checklist).
- Do NOT stop. Proceed to Step 2.

## Step 2: Implement

- Execute all tasks via red/green TDD.
- Run existing test suite after implementation. Fix failures before proceeding.
- Do NOT stop. Proceed to Step 3.

## Step 3: Verify (Showboat + Rodney)

- Run `uvx showboat --help` to learn available commands.
- If change involves web UI, also run `uvx rodney --help`.
- Build demo.md using ONLY showboat commands (never write demo.md directly):
  1. `showboat init openspec/changes/<change-name>/demo.md '<Title> - Demo'`
  2. For EACH scenario from the proposal/specs:
     - `showboat note` to describe the scenario
     - `showboat exec` to run actual commands and record output
     - For web UI: `rodney start` → `rodney open` → `rodney screenshot` → `showboat image`
  3. `showboat note` for final summary
- Run `showboat verify openspec/changes/<change-name>/demo.md`.
- If verify fails: `showboat pop` the failing section, fix, re-record.
- If rodney was used: `rodney stop`.
- Do NOT stop. Proceed to Step 4.

## Step 4: Review

- Create `openspec/changes/<change-name>/review.md`.
- Review BOTH the code AND demo.md.
- Check: does demo.md cover all proposal scenarios? Does `showboat verify` pass?
- If NO [MUST FIX] → proceed to Step 5.
- If [MUST FIX] → fix autonomously (re-record affected demo sections too), re-review. After 2 failed attempts → STOP and report to user.

## Step 5: Archive

- Create `openspec/changes/<change-name>/learnings.md`.
- Append learnings to `openspec/learnings/LEARNINGS.md`.
- Print summary:
  ```
  ✓ <change-name> complete
    Files changed: N
    Demo: N scenarios verified (showboat verify: PASS)
    Review: N MUST FIX (fixed) / N SHOULD FIX / N CONSIDER
    Learnings: N captured
  ```

## Rules

1. Never ask "should I continue?" between steps.
2. Only stop for: unresolvable MUST FIX (after 2 attempts) or unfixable test failures.
3. Always read LEARNINGS.md before planning.
4. NEVER write demo.md directly — always use showboat/rodney commands.
5. Every proposal scenario must appear in demo.md.
6. Append (don't overwrite) LEARNINGS.md.
