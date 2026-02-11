# Architecture

## 導入方式

### 優先度順

1. **Script tag（MVP）** - 最もシンプル、react-grabと同じアプローチ
2. **Vite/Next Plugin（将来）** - より楽な導入
3. **CLI + Proxy（将来）** - 非侵襲、完全な機能

### Script tag方式

```html
<script
  src="https://unpkg.com/react-ui-comments"
  data-project-id="my-app"           <!-- 必須: プロジェクト識別 -->
  data-branch="feature-a"            <!-- オプション: ブランチ -->
  data-cli-port="4567"               <!-- オプション: CLIポート -->
></script>
```

```tsx
// Next.js / Vite での使用例
{process.env.NODE_ENV === 'development' && (
  <script
    src="https://unpkg.com/react-ui-comments"
    data-project-id={process.env.npm_package_name}
  />
)}
```

## データフロー

```
┌─────────────────────────────────────────────────────────────────┐
│  CLI（オプション）                                               │
│  $ npx react-ui-comments --port 3000                           │
│  → プロジェクトルートで起動                                       │
│  → .comments/ ディレクトリにJSON保存                             │
│  → WebSocket/HTTPで ブラウザと同期                               │
└─────────────────────────────────────────────────────────────────┘
                              ↕ 同期
┌─────────────────────────────────────────────────────────────────┐
│  ブラウザ（Script tag）                                          │
│  → CLIが起動していればファイル保存                                │
│  → CLIがなければlocalStorage（projectId付き）にフォールバック      │
└─────────────────────────────────────────────────────────────────┘
```

## マルチプロジェクト/Worktree対応

### 問題

```
~/projects/
├── my-app/                      # main branch → localhost:3000
├── my-app-feature-a/            # worktree: feature-a → localhost:3001
├── my-app-feature-b/            # worktree: feature-b → localhost:3002
└── another-project/             # 別プロジェクト → localhost:3000（時間差で使用）
```

- localhost:3000 だけでは何のプロジェクトか分からない
- 同一プロジェクトでもブランチごとにコメントを分けたい
- ブラウザのlocalStorageはドメイン単位で混ざる

### 解決策: ハイブリッド方式

| モード | 条件 | 保存先 | Git管理 |
|--------|------|--------|---------|
| CLIモード | CLIが起動中 | `.comments/` ファイル | ✅ 可能 |
| フォールバック | CLIなし | localStorage + projectId | ❌ |

### localStorage キー設計

```typescript
const key = `ruc:${projectId}:${branch}:${pathname}`;
// 例: "ruc:my-app:feature-a:/"
```

## ブラウザ ↔ CLI 通信

```typescript
// WebSocket messages
interface Message {
  type: 'sync' | 'add' | 'update' | 'delete' | 'export';
  payload: any;
}

// 初期接続
Browser → CLI: { type: 'sync', payload: { pathname: '/' } }
CLI → Browser: { type: 'sync', payload: { comments: [...] } }

// エクスポート（エージェント連携）
Browser → CLI: { type: 'export', payload: { format: 'prompt' } }
CLI → Browser: { type: 'export', payload: { content: '## UI Feedback...' } }
```

## CLI検出ロジック

```typescript
async function detectCLI(): Promise<CLIConnection | null> {
  const port = getDataAttribute('cli-port') || 4567;
  
  try {
    const res = await fetch(`http://localhost:${port}/health`);
    if (res.ok) {
      return new CLIConnection(new WebSocket(`ws://localhost:${port}`));
    }
  } catch {
    // CLIが起動していない
  }
  
  return null; // localStorageフォールバック
}
```
