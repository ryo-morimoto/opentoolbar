# CLI Specification

## Overview

CLI is optional. It provides file storage, multi-project support, and MCP integration.

## Startup

```bash
# Run at project root
cd ~/projects/my-app
npx opentoolbar

# Options
npx opentoolbar \
  --port 4567 \           # CLI server port (default: 4567)
  --target 3000 \         # Target dev server port (for display)
  --branch feature-a      # Manual branch override (for worktrees)
```

## CLI Responsibilities

1. Detect project root (package.json or .git)
2. Get git branch (worktree-aware)
3. Create/manage `.comments/` directory
4. Start WebSocket server for browser communication
5. Start MCP server for agent communication
6. Watch file changes and sync to other browsers

## Project Detection

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

## Branch Detection (worktree-aware)

```typescript
async function detectBranch(): Promise<string> {
  try {
    // Works with git worktrees
    const result = await execFile('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
    return result.stdout.trim();
  } catch {
    return 'unknown';
  }
}
```

## WebSocket API

### Endpoint

```
ws://localhost:4567
```

### Messages

```typescript
// Browser -> CLI
interface ClientMessage {
  type: 'sync' | 'add' | 'update' | 'delete' | 'export';
  payload: {
    pathname?: string;
    comment?: Comment;
    commentId?: string;
    format?: 'prompt' | 'json';
  };
}

// CLI -> Browser
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

### Flow

```
1. On connection
   Browser -> CLI: { type: 'sync', payload: { pathname: '/' } }
   CLI -> Browser: { type: 'sync', payload: { comments: [...] } }

2. Add comment
   Browser -> CLI: { type: 'add', payload: { comment: {...} } }
   CLI: Save to file
   CLI -> All browsers: { type: 'add', payload: { comment: {...} } }

3. Export
   Browser -> CLI: { type: 'export', payload: { format: 'prompt' } }
   CLI -> Browser: { type: 'export', payload: { content: '...' } }
```

## HTTP API

### Health Check

```
GET http://localhost:4567/health
Response: { "status": "ok", "project": "my-app", "branch": "main" }
```

### Get Comments (REST fallback)

```
GET http://localhost:4567/comments?pathname=/
Response: { "comments": [...] }
```

## File Operations

### Save

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
  // "/" -> "index", "/about" -> "about", "/users/123" -> "users-123"
  if (p === '/') return 'index';
  return p.replace(/^\//, '').replace(/\//g, '-');
}
```

### Watch

```typescript
const watcher = chokidar.watch('.comments/**/*.json', {
  ignoreInitial: true
});

watcher.on('change', async (filePath) => {
  // Notify other browsers of changes
  const data = await fs.readFile(filePath, 'utf-8');
  broadcast({ type: 'sync', payload: JSON.parse(data) });
});
```

## On Exit

```
Ctrl+C to exit
-> Close WebSocket connections
-> Stop MCP server
```
