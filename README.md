# opentoolbar

> Open-source alternative to Vercel Toolbar. Leave comments on UI and export to AI agents.

🚧 **Work in Progress**

## Features

- **DOM-bound comments** — Same UX as Vercel Preview Comments
- **AI agent integration** — Export structured feedback to Cursor / Claude Code
- **Multi-project support** — Works with worktrees and multiple branches
- **Script tag install** — One line to get started

## Install

```bash
npm install opentoolbar
```

## Usage

### Script tag (recommended)

```tsx
// Next.js
{process.env.NODE_ENV === 'development' && (
  <script
    src="https://unpkg.com/opentoolbar"
    data-project-id="my-app"
  />
)}
```

### CLI (optional)

```bash
# Enable file storage + MCP integration
npx opentoolbar
```

## Agent Integration

```
[Copy as Prompt] button → Copies to clipboard
```

Generates structured feedback ready for AI agents.

## Development

```bash
npm install
npm run dev
npm test
```

## License

MIT
