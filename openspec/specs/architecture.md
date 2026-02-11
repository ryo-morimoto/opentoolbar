# Architecture

## Integration Methods

### Priority Order

1. **Script tag (MVP)** — Simplest approach, same as react-grab
2. **Vite/Next Plugin (future)** — Easier integration
3. **CLI + Proxy (future)** — Non-invasive, full feature set

### Script Tag Approach

```html
<script
  src="https://unpkg.com/opentoolbar"
  data-project-id="my-app"           <!-- Required: project identifier -->
  data-branch="feature-a"            <!-- Optional: branch -->
  data-cli-port="4567"               <!-- Optional: CLI port -->
></script>
```

```tsx
// Usage in Next.js / Vite
{process.env.NODE_ENV === 'development' && (
  <script
    src="https://unpkg.com/opentoolbar"
    data-project-id={process.env.npm_package_name}
  />
)}
```

## Data Flow

```
+---------------------------------------------------------------+
|  CLI (optional)                                               |
|  $ npx opentoolbar --port 3000                                |
|  -> Runs at project root                                      |
|  -> Saves JSON to .comments/ directory                        |
|  -> Syncs with browser via WebSocket/HTTP                     |
+---------------------------------------------------------------+
                              | sync
+---------------------------------------------------------------+
|  Browser (Script tag)                                         |
|  -> If CLI is running, saves to files                         |
|  -> If no CLI, falls back to localStorage (with projectId)    |
+---------------------------------------------------------------+
```

## Multi-project / Worktree Support

### Problem

```
~/projects/
+-- my-app/                      # main branch -> localhost:3000
+-- my-app-feature-a/            # worktree: feature-a -> localhost:3001
+-- my-app-feature-b/            # worktree: feature-b -> localhost:3002
+-- another-project/             # different project -> localhost:3000 (time-shared)
```

- localhost:3000 alone doesn't identify the project
- Comments should be separated by branch even within the same project
- Browser localStorage is shared per domain, causing conflicts

### Solution: Hybrid Approach

| Mode | Condition | Storage | Git-managed |
|------|-----------|---------|-------------|
| CLI mode | CLI is running | `.comments/` files | Yes |
| Fallback | No CLI | localStorage + projectId | No |

### localStorage Key Design

```typescript
const key = `otb:${projectId}:${branch}:${pathname}`;
// e.g., "otb:my-app:feature-a:/"
```

## Browser <-> CLI Communication

```typescript
// WebSocket messages
interface Message {
  type: 'sync' | 'add' | 'update' | 'delete' | 'export';
  payload: any;
}

// Initial connection
Browser -> CLI: { type: 'sync', payload: { pathname: '/' } }
CLI -> Browser: { type: 'sync', payload: { comments: [...] } }

// Export (agent integration)
Browser -> CLI: { type: 'export', payload: { format: 'prompt' } }
CLI -> Browser: { type: 'export', payload: { content: '## UI Feedback...' } }
```

## CLI Detection Logic

```typescript
async function detectCLI(): Promise<CLIConnection | null> {
  const port = getDataAttribute('cli-port') || 4567;

  try {
    const res = await fetch(`http://localhost:${port}/health`);
    if (res.ok) {
      return new CLIConnection(new WebSocket(`ws://localhost:${port}`));
    }
  } catch {
    // CLI is not running
  }

  return null; // localStorage fallback
}
```
