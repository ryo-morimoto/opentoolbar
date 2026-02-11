# Agent Integration

**差別化ポイント**: コメントをAIエージェントに構造化して渡せる。

## プロンプトコピー機能

### トリガー

```
[Copy as Prompt] ボタン → クリップボードにコピー
```

### 出力フォーマット

```markdown
## UI Feedback Report

### Issue #1 (active)
- **Component**: `LoginForm` at `src/components/LoginForm.tsx:24`
- **Element**: `<button class="submit-btn">ログイン</button>`
- **Selector**: `button.submit-btn`
- **Comment**: 「ボタンの色がデザインと違う。#3B82F6 → #2563EB に修正してほしい」

### Issue #2 (outdated)
- **Component**: `Header` at `src/components/Header.tsx:12`
- **Comment**: 「ロゴのサイズを大きく」
- **Note**: This element has been modified since the comment was created.

---
Please fix the active issues above.
```

### 実装

```typescript
function exportAsPrompt(comments: Comment[]): string {
  const active = comments.filter(c => c.status === 'active');
  const outdated = comments.filter(c => c.status === 'outdated');
  
  let output = '## UI Feedback Report\n\n';
  
  [...active, ...outdated].forEach((comment, i) => {
    output += `### Issue #${i + 1} (${comment.status})\n`;
    
    if (comment.anchor.componentName) {
      output += `- **Component**: \`${comment.anchor.componentName}\``;
      if (comment.anchor.filePath) {
        output += ` at \`${comment.anchor.filePath}\``;
      }
      output += '\n';
    }
    
    output += `- **Element**: \`${comment.anchor.htmlSnapshot.slice(0, 100)}\`\n`;
    output += `- **Selector**: \`${comment.anchor.selector}\`\n`;
    output += `- **Comment**: 「${comment.text}」\n`;
    
    if (comment.status === 'outdated') {
      output += `- **Note**: This element has been modified since the comment was created.\n`;
    }
    
    output += '\n';
  });
  
  output += '---\nPlease fix the active issues above.\n';
  
  return output;
}
```

## MCP連携（CLI経由）

### アーキテクチャ

```
┌─────────────────────┐     ┌─────────────────────┐
│  Claude Code        │     │  Browser            │
│  / Cursor           │     │  (Script tag)       │
│                     │     │                     │
│  MCP Client ────────┼────►│                     │
└─────────────────────┘     └─────────────────────┘
           │
           ▼
┌─────────────────────┐
│  CLI (MCP Server)   │
│  port: 4567         │
│                     │
│  - get_ui_feedback  │
│  - get_screenshot   │
│  - resolve_comment  │
└─────────────────────┘
           │
           ▼
     .comments/*.json
```

### MCPツール定義

```typescript
// get_ui_feedback
{
  name: "get_ui_feedback",
  description: "Get all UI feedback comments from the current page or project",
  inputSchema: {
    type: "object",
    properties: {
      pathname: {
        type: "string",
        description: "Page path to filter (optional, e.g., '/' or '/about')"
      },
      status: {
        type: "string",
        enum: ["active", "outdated", "all"],
        description: "Filter by status"
      }
    }
  },
  returns: {
    comments: Comment[],
    summary: {
      total: number,
      active: number,
      outdated: number
    }
  }
}

// resolve_comment
{
  name: "resolve_comment",
  description: "Mark a comment as resolved/deleted",
  inputSchema: {
    type: "object",
    properties: {
      commentId: { type: "string" }
    },
    required: ["commentId"]
  }
}
```

### ユースケース

```
1. 開発者がUIにコメントを残す
   「このボタンの色を#2563EBに変更」

2. Claude Code / Cursor でコマンド実行
   > UIフィードバックを確認して修正して

3. AIがMCP経由でコメント取得
   → ファイルパス・コンポーネント情報付き

4. AIが自動修正
   → 該当ファイルを開いて色を変更

5. AIがコメントを解決済みにマーク
```

## CLI起動時のMCPサーバー

```typescript
// CLI が起動すると自動でMCPサーバーも起動
// npx react-ui-comments --port 4567

import { Server } from "@modelcontextprotocol/sdk/server/index.js";

const server = new Server({
  name: "opentoolbar",
  version: "1.0.0"
});

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "get_ui_feedback",
      description: "Get UI feedback comments",
      inputSchema: { /* ... */ }
    },
    {
      name: "resolve_comment",
      description: "Mark comment as resolved",
      inputSchema: { /* ... */ }
    }
  ]
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "get_ui_feedback") {
    const comments = await loadComments(request.params.arguments);
    return { content: [{ type: "text", text: JSON.stringify(comments) }] };
  }
  // ...
});
```

## JSONエクスポート

```typescript
function exportAsJSON(comments: Comment[]): string {
  return JSON.stringify({
    version: 1,
    exportedAt: new Date().toISOString(),
    comments: comments.map(c => ({
      ...c,
      // スクリーンショットは別途対応（サイズ問題）
    }))
  }, null, 2);
}
```
