# opentoolbar

Open-source alternative to Vercel Toolbar. UI上で直接コメントを残し、**AIエージェントに構造化して渡せる**ことが最大の差別化ポイント。

## Vision

```
開発者/デザイナーがUIを見ながらコメント
           ↓
   構造化データとして保存
           ↓
AIエージェントが自動で修正提案・実装
```

## 差別化

| ツール | 要素選択 | コメント | エージェント連携 |
|--------|----------|----------|------------------|
| @vercel/toolbar | ✅ | ✅ | ❌ |
| react-grab | ✅ | ❌ | ✅（コピーのみ） |
| **opentoolbar** | ✅ | ✅ | ✅（構造化+MCP） |

## ターゲットユーザー

- フロントエンド開発者（セルフレビュー）
- デザイナー・PM（デザインフィードバック）
- AIエージェント（Cursor, Claude Code等）と連携したい開発者

## 技術スタック

- TypeScript
- React（開発対象アプリ用）
- Vanilla JS（Script tag版のコアロジック）
- Vitest（テスト）

## Compound Engineering Guidelines

### Commands
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
