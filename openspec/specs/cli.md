# CLI Specification

## 概要

CLIはオプショナル。ファイル保存、マルチプロジェクト対応、MCP連携を提供する。

## 起動

```bash
# プロジェクトルートで実行
cd ~/projects/my-app
npx react-ui-comments

# オプション
npx react-ui-comments \
  --port 4567 \           # CLIサーバーのポート（デフォルト: 4567）
  --target 3000 \         # 対象のdevサーバーポート（情報表示用）
  --branch feature-a      # 手動でブランチ指定（worktree用）
```

## CLIの役割

1. プロジェクトルートを検出（package.json or .git）
2. git branchを取得（worktree対応）
3. `.comments/` ディレクトリを作成/管理
4. WebSocketサーバーを起動してブラウザと通信
5. MCPサーバーを起動してエージェントと通信
6. ファイル変更を監視して他のブラウザに同期

## プロジェクト検出

```typescript
async function detectProjectRoot(): Promise<string> {
  let dir = process.cwd();
  
  while (dir !== '/') {
    if (await exists(path.join(dir, 'package.json'))) {
      return dir;
    }
    if (await exists(path.join(dir, '.git'))) {
      return dir;
    }
    dir = path.dirname(dir);
  }
  
  throw new Error('Project root not found');
}
```

## ブランチ検出（worktree対応）

```typescript
async function detectBranch(): Promise<string> {
  try {
    // git worktree でも動作する
    const result = await exec('git rev-parse --abbrev-ref HEAD');
    return result.stdout.trim();
  } catch {
    return 'unknown';
  }
}
```

## WebSocket API

### エンドポイント

```
ws://localhost:4567
```

### メッセージ

```typescript
// ブラウザ → CLI
interface ClientMessage {
  type: 'sync' | 'add' | 'update' | 'delete' | 'export';
  payload: {
    pathname?: string;
    comment?: Comment;
    commentId?: string;
    format?: 'prompt' | 'json';
  };
}

// CLI → ブラウザ
interface ServerMessage {
  type: 'sync' | 'add' | 'update' | 'delete' | 'export' | 'error';
  payload: {
    comments?: Comment[];
    comment?: Comment;
    content?: string;
    error?: string;
  };
}
```

### フロー

```
1. 接続時
   Browser → CLI: { type: 'sync', payload: { pathname: '/' } }
   CLI → Browser: { type: 'sync', payload: { comments: [...] } }

2. コメント追加
   Browser → CLI: { type: 'add', payload: { comment: {...} } }
   CLI: ファイルに保存
   CLI → 全Browser: { type: 'add', payload: { comment: {...} } }

3. エクスポート
   Browser → CLI: { type: 'export', payload: { format: 'prompt' } }
   CLI → Browser: { type: 'export', payload: { content: '...' } }
```

## HTTP API

### ヘルスチェック

```
GET http://localhost:4567/health
Response: { "status": "ok", "project": "my-app", "branch": "main" }
```

### コメント取得（REST fallback）

```
GET http://localhost:4567/comments?pathname=/
Response: { "comments": [...] }
```

## ファイル操作

### 保存

```typescript
async function saveComment(comment: Comment, pathname: string): Promise<void> {
  const branch = await detectBranch();
  const filePath = path.join(
    '.comments',
    sanitizePath(branch),
    sanitizePath(pathname) + '.json'
  );
  
  const data = await loadOrCreate(filePath);
  data.comments.push(comment);
  data.updatedAt = new Date().toISOString();
  
  await fs.writeFile(filePath, JSON.stringify(data, null, 2));
}

function sanitizePath(p: string): string {
  // "/" → "index", "/about" → "about", "/users/123" → "users-123"
  if (p === '/') return 'index';
  return p.replace(/^\//, '').replace(/\//g, '-');
}
```

### 監視

```typescript
const watcher = chokidar.watch('.comments/**/*.json', {
  ignoreInitial: true
});

watcher.on('change', async (filePath) => {
  // 他のブラウザに変更を通知
  const data = await fs.readFile(filePath, 'utf-8');
  broadcast({ type: 'sync', payload: JSON.parse(data) });
});
```

## 終了時

```
Ctrl+C で終了
→ WebSocket接続をクローズ
→ MCPサーバーを停止
```
