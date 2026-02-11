# Agent Integration

**Key differentiator**: Pass comments to AI agents as structured data.

## Prompt Copy Feature

### Trigger

```
[Copy as Prompt] button -> Copy to clipboard
```

### Output Format

```markdown
## UI Feedback Report

### Issue #1 (active)
- **Component**: `LoginForm` at `src/components/LoginForm.tsx:24`
- **Element**: `<button class="submit-btn">Login</button>`
- **Selector**: `button.submit-btn`
- **Comment**: "Button color doesn't match the design. Change #3B82F6 to #2563EB."

### Issue #2 (outdated)
- **Component**: `Header` at `src/components/Header.tsx:12`
- **Comment**: "Make the logo bigger"
- **Note**: This element has been modified since the comment was created.

---
Please fix the active issues above.
```

### Implementation

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
    output += `- **Comment**: "${comment.text}"\n`;

    if (comment.status === 'outdated') {
      output += `- **Note**: This element has been modified since the comment was created.\n`;
    }

    output += '\n';
  });

  output += '---\nPlease fix the active issues above.\n';

  return output;
}
```

## MCP Integration (via CLI)

### Architecture

```
+---------------------+     +---------------------+
|  Claude Code        |     |  Browser            |
|  / Cursor           |     |  (Script tag)       |
|                     |     |                     |
|  MCP Client --------+---->|                     |
+---------------------+     +---------------------+
           |
           v
+---------------------+
|  CLI (MCP Server)   |
|  port: 4567         |
|                     |
|  - get_ui_feedback  |
|  - get_screenshot   |
|  - resolve_comment  |
+---------------------+
           |
           v
     .comments/*.json
```

### MCP Tool Definitions

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

### Use Case

```
1. Developer leaves a comment on UI
   "Change this button color to #2563EB"

2. Run command in Claude Code / Cursor
   > Check UI feedback and fix it

3. AI retrieves comments via MCP
   -> With file paths and component info

4. AI applies fixes automatically
   -> Opens the file and changes the color

5. AI marks the comment as resolved
```

## MCP Server on CLI Startup

```typescript
// MCP server starts automatically when CLI launches
// npx opentoolbar --port 4567

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

## JSON Export

```typescript
function exportAsJSON(comments: Comment[]): string {
  return JSON.stringify({
    version: 1,
    exportedAt: new Date().toISOString(),
    comments: comments.map(c => ({
      ...c,
      // Screenshots handled separately (size concerns)
    }))
  }, null, 2);
}
```
