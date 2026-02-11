#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# OpenSpec + Compound Engineering セットアップ
#
# Showboat/Rodney による検証フェーズ付き
#
# 使い方: bash setup.sh
# 前提: Node.js 20.19.0+, Gitリポジトリルートで実行
# ============================================================

OPENSPEC_DIR="openspec"
SCHEMA_DIR="${OPENSPEC_DIR}/schemas/compound"
TEMPLATE_DIR="${SCHEMA_DIR}/templates"
PLUGINS_DIR="plugins"

info()  { printf "\033[0;36m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[0;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[0;33m⚠ %s\033[0m\n" "$1"; }
err()   { printf "\033[0;31m✗ %s\033[0m\n" "$1"; exit 1; }

command -v node >/dev/null 2>&1 || err "Node.js が見つかりません (20.19.0+ 必須)"
NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
[ "$NODE_MAJOR" -lt 20 ] && err "Node.js 20.19.0+ が必要です (現在: $(node -v))"
[ ! -d ".git" ] && err "Gitリポジトリのルートで実行してください"

# === Step 1: OpenSpec 初期化 ===
info "OpenSpec を初期化中..."
if [ -d "$OPENSPEC_DIR" ] && [ -f "${OPENSPEC_DIR}/project.md" ]; then
  warn "OpenSpec は既に初期化済み。スキーマのみインストールします。"
else
  bunx @fission-ai/openspec@latest init --tools claude --force
  ok "OpenSpec 初期化完了"
fi

# === Step 2: compound スキーマ ===
info "compound スキーマを作成中..."
mkdir -p "$TEMPLATE_DIR"

cat > "${SCHEMA_DIR}/schema.yaml" << 'EOF'
name: compound
version: 1
description: |
  Compound Engineering workflow with verification.
  /compound:ship で 計画→実装→検証→レビュー→学習 が自律的に回る。

artifacts:
  # --- 事前計画 (最小限) ---
  - id: proposal
    generates: proposal.md
    description: What / Why / Scope だけ。How は書かない。
    template: proposal.md
    instruction: |
      Create a lightweight proposal for this change.
      RULES:
      - Write ONLY: What, Why, Scope. Do NOT write How.
      - Keep under 30 lines. Longer = scope too big, split it.
      - Use the user's language.
      - Reference openspec/specs/ and openspec/learnings/LEARNINGS.md.
    requires: []

  - id: tasks
    generates: tasks.md
    description: 実装チェックリスト。
    template: tasks.md
    instruction: |
      Generate an implementation checklist from the proposal.
      RULES:
      - Each task: verifiable action with acceptance criteria.
      - Group into phases if >5 tasks.
      - Reference openspec/learnings/ to avoid past mistakes.
      - Same language as proposal.
    requires: [proposal]

  # --- 検証 (Showboat/Rodney) ---
  - id: demo
    generates: demo.md
    description: Showboat/Rodneyで実装の動作証拠を記録。
    template: demo.md
    instruction: |
      Create a demo document that PROVES the implementation works.
      Use Showboat CLI to record actual command execution results.

      SETUP:
      - Run `uvx showboat --help` to learn all available commands.
      - If the change involves a web UI, also run `uvx rodney --help`.

      PROCESS:
      1. `showboat init <change-dir>/demo.md '<Change Title> - Demo'`
      2. For EACH scenario in the proposal/specs:
         a. `showboat note` — describe what this scenario tests.
         b. `showboat exec` — run the actual command/API call and record output.
         c. If web UI: `rodney start` → `rodney open` → `rodney screenshot` → `showboat image`.
      3. `showboat note` — final summary of what was verified.

      RULES:
      - NEVER write to demo.md directly. ALWAYS use showboat commands.
      - Every scenario in proposal/specs MUST have a corresponding demo section.
      - If a scenario cannot be demoed via CLI/browser, note why and what was done instead.
      - Run `showboat verify <demo.md>` at the end to confirm all outputs are reproducible.
      - If verify fails, fix the issue and re-record that section with `showboat pop` + `showboat exec`.
    requires: [tasks]

  # --- 実装後レビュー ---
  - id: review
    generates: review.md
    description: 実装済みコード + デモ結果に対する設計レビュー。
    template: review.md
    instruction: |
      Review the IMPLEMENTED code AND the demo document.

      REVIEW CRITERIA:
      1. Design coherence — will it break under growth?
      2. Pattern consistency — follows existing codebase patterns?
      3. Future friction — next change easier or harder?
      4. Scope check — stayed within proposal scope?
      5. Demo coverage — does demo.md cover all proposal scenarios?
      6. Demo integrity — does `showboat verify demo.md` pass?

      RULES:
      - Read actual code diff AND demo.md.
      - Cite file paths and line ranges.
      - Classify: [MUST FIX] / [SHOULD FIX] / [CONSIDER].
      - If demo is missing scenarios, classify as [MUST FIX].
      - No issues = say so. Don't invent problems.
    requires: [demo]

  # --- 知識の蓄積 ---
  - id: learnings
    generates: learnings.md
    description: 知識の複利的蓄積。
    template: learnings.md
    instruction: |
      Extract reusable knowledge from this change cycle.
      CAPTURE: Patterns discovered, Mistakes caught, Design decisions, Warnings for future.
      RULES:
      - Each learning: actionable, 2-3 lines max.
      - Include verification insights (what showboat/rodney revealed that tests missed).
      - Reference specific files when relevant.
      - Append to openspec/learnings/LEARNINGS.md (don't overwrite).
      - Same language as proposal.
    requires: [review]

apply:
  requires: [tasks]
  tracks: tasks.md
EOF

# --- テンプレート ---
cat > "${TEMPLATE_DIR}/proposal.md" << 'EOF'
# Proposal: {{change_name}}

## What
<!-- 何を作る/変更するか。1-3文。 -->

## Why
<!-- なぜ必要か。 -->

## Scope
<!-- IN: 含むもの / OUT: 含めないもの -->
EOF

cat > "${TEMPLATE_DIR}/tasks.md" << 'EOF'
# Tasks: {{change_name}}

## Phase 1
- [ ] **1.1**: (description) — Acceptance: (verification)
- [ ] **1.2**: (description) — Acceptance: (verification)
EOF

cat > "${TEMPLATE_DIR}/demo.md" << 'EOF'
<!-- This file is generated by Showboat. Do NOT edit directly. -->
<!-- Use: showboat init, showboat exec, showboat note, showboat image -->
<!-- Run: showboat verify <this-file> to validate all outputs -->
EOF

cat > "${TEMPLATE_DIR}/review.md" << 'EOF'
# Review: {{change_name}}

## Summary
## Findings
### [MUST FIX]
### [SHOULD FIX]
### [CONSIDER]
## Design Assessment
- Coherence: OK / Issue
- Pattern consistency: OK / Issue
- Future friction: Easier / Harder / Neutral
## Demo Coverage
- Scenarios in proposal: N
- Scenarios in demo: N
- showboat verify: PASS / FAIL
EOF

cat > "${TEMPLATE_DIR}/learnings.md" << 'EOF'
# Learnings: {{change_name}}

## Patterns Discovered
## Mistakes Caught
## Verification Insights
<!-- テストでは見つからなかったがデモで発見した問題 -->
## Design Decisions
## Warnings for Future
EOF

ok "compound スキーマ作成完了"

# === Step 3: learnings ===
mkdir -p "${OPENSPEC_DIR}/learnings"
if [ ! -f "${OPENSPEC_DIR}/learnings/LEARNINGS.md" ]; then
  cat > "${OPENSPEC_DIR}/learnings/LEARNINGS.md" << 'EOF'
# Project Learnings

> AI agentは新しいchange開始時にこのファイルを参照する。
> /compound:ship の archive ステップで自動追記される。

---
EOF
  ok "LEARNINGS.md 作成完了"
fi

# === Step 4: Compound Engineering プラグイン ===
info "Compound Engineering プラグインをインストール中..."

# プラグインファイルは plugins/ に同梱済み。マーケットプレース登録+インストールのみ。
if command -v claude >/dev/null 2>&1; then
  claude plugin marketplace add "${PWD}/${PLUGINS_DIR}" 2>/dev/null || true
  claude plugin install compound@opentoolbar-plugins --scope project 2>/dev/null || true
  ok "compound プラグイン登録完了 (/compound:ship, /compound:plan, /compound:review)"
else
  warn "claude CLI が見つかりません。手動で登録してください:"
  warn "  claude plugin marketplace add ./plugins"
  warn "  claude plugin install compound@opentoolbar-plugins --scope project"
fi

# === Step 5: project.md ===
if [ -f "${OPENSPEC_DIR}/project.md" ] && ! grep -q "Compound Engineering" "${OPENSPEC_DIR}/project.md"; then
  cat >> "${OPENSPEC_DIR}/project.md" << 'EOF'

## Compound Engineering Guidelines

### Skills
- `/compound:ship <desc>` — Full autonomous cycle: plan → implement → verify → review → learn → archive.
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
EOF
  ok "project.md 更新完了"
fi

# === Step 6: config.yaml ===
CONFIG_FILE="${OPENSPEC_DIR}/config.yaml"
if [ -f "$CONFIG_FILE" ] && ! grep -q "default_schema" "$CONFIG_FILE"; then
  echo -e "\ndefault_schema: compound" >> "$CONFIG_FILE"
elif [ ! -f "$CONFIG_FILE" ]; then
  echo "default_schema: compound" > "$CONFIG_FILE"
fi
ok "config.yaml 設定完了"

# === Step 7: Showboat/Rodney 確認 ===
info "Showboat/Rodney の利用可能性を確認中..."
if command -v uvx >/dev/null 2>&1; then
  ok "uvx が利用可能 (showboat/rodney は uvx 経由で実行)"
else
  warn "uvx が見つかりません。Showboat/Rodneyの実行には uv のインストールが必要です:"
  warn "  curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# === Step 8: AI ツール設定再生成 ===
bunx @fission-ai/openspec@latest update --force 2>/dev/null || warn "openspec update 失敗。手動: bunx @fission-ai/openspec update"

# === 完了 ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "セットアップ完了!"
echo ""
echo "  /compound:ship <desc>     全自動 (計画→実装→検証→レビュー→学習→保存)"
echo "  /compound:review <ref>    既存コードの後追いレビュー + 検証"
echo "  /compound:plan <desc>     チーム合意用proposal"
echo ""
echo "  例: /compound:ship ユーザー認証にOAuth追加"
echo ""
echo "  検証ツール: showboat (uvx showboat), rodney (uvx rodney)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
