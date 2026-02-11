# react-ui-comments

> Vercel Preview Comments の OSS 版。UI上で直接コメントを残し、AIエージェントに構造化して渡せる。

🚧 **Work in Progress** — 開発中

## 特徴

- **DOM要素にバインドされたコメント** — Vercelと同様のUX
- **AIエージェント連携** — コメントを構造化して Cursor / Claude Code に渡せる
- **マルチプロジェクト対応** — worktree / 複数ブランチでも混ざらない
- **Script tag 導入** — 1行追加で動作

## インストール

```bash
npm install react-ui-comments
```

## 使い方

### Script tag（推奨）

```tsx
// Next.js
{process.env.NODE_ENV === 'development' && (
  <script
    src="https://unpkg.com/react-ui-comments"
    data-project-id="my-app"
  />
)}
```

### CLI（オプション）

```bash
# ファイル保存・MCP連携を有効化
npx react-ui-comments
```

## エージェント連携

```
[Copy as Prompt] ボタン → クリップボードにコピー
```

AIエージェントに渡せる構造化されたフィードバックが生成されます。

## 開発

```bash
# セットアップ
npm install

# 開発サーバー
npm run dev

# テスト
npm test
```

## ライセンス

MIT
