# Shadow Branch File Format

## Branch Name

```
opentoolbar/comments/v1
```

This is a single orphan branch in the same git repository. It is separate from all working branches (main, feature/*). Version is in the branch name for future migration (`v2`, etc.).

## Branch Scoping (Entire-inspired)

There is **one shadow branch** for the entire repository, not one per code branch. Each comment stores which code branch it was created on via the `branch` field.

```
Single shadow branch: opentoolbar/comments/v1
  └── my-app/dashboard.json
        comments: [
          { id: "abc", branch: "main", ... },
          { id: "def", branch: "feature/auth", ... }
        ]
```

**Rationale** (following Entire's approach):
- Avoids proliferation of shadow branches
- Branch name is metadata, not a file path component (branches can contain `/` which complicates paths)
- Toolbar filters comments by current branch at read time
- All comments for a page are in one file, queryable across branches

**Filtering behavior:**
- Toolbar shows comments for the **current code branch** by default
- Comments from other branches are visible in the dropdown with a branch label
- AI agents can filter by branch or read all comments across branches

## Directory Structure

Files are organized by project ID and pathname:

```
opentoolbar/comments/v1 (branch root)
├── <projectId>/
│   ├── _.json                    ← comments for pathname "/"
│   ├── dashboard.json            ← comments for pathname "/dashboard"
│   ├── settings.json             ← comments for pathname "/settings"
│   └── settings/profile.json     ← comments for pathname "/settings/profile"
```

### Pathname to Filename Mapping

| Pathname | Filename |
|---|---|
| `/` | `_.json` |
| `/dashboard` | `dashboard.json` |
| `/settings` | `settings.json` |
| `/settings/profile` | `settings/profile.json` |
| `/users/123` | `users/123.json` |

Rules:
- Strip leading `/`
- If empty (root `/`), use `_` as filename
- Append `.json`
- Directory separators in pathname become directory separators in file path

### Why Per-Page Files?

- **Merge-friendly**: Two people commenting on different pages will never conflict
- **Efficient reads**: Load only the comments for the current page, not the entire project
- **AI-friendly**: An agent can read a single file for the page it's working on

## Comment ID Generation

- **Format**: nanoid, 12 characters, URL-safe alphabet (`A-Za-z0-9_-`)
- **Example**: `V1StGXR8_Z5j`
- **Collision risk**: With 12 characters and URL-safe alphabet (64 chars), the probability of collision is negligible for the expected scale (thousands of comments per project, not millions)
- **Generation**: Client-side (browser or CLI). No server coordination needed.

## Git Trailers

Following Entire's pattern, opentoolbar links code commits to comments via git trailers.

### When Trailers Are Added

The CLI provides a `prepare-commit-msg` git hook. When a developer commits code:
1. The hook checks if any **active comments** reference files touched by this commit (via `sourceAnchor.filePath`)
2. If matching comments exist, trailers are appended to the commit message

### Format

```
feat: Update dashboard button styling

Opentoolbar-Comment: V1StGXR8_Z5j
Opentoolbar-Comment: Xk9mP2qR7wYn
```

### Bidirectional Lookup

```
Code commit → Comments:
  1. Extract "Opentoolbar-Comment: <id>" trailers from commit message
  2. Search shadow branch for the comment ID

Comments → Code commits:
  Given comment ID V1StGXR8_Z5j
  → git log --all --grep="Opentoolbar-Comment: V1StGXR8_Z5j"
  → Finds the code commit(s) that addressed this comment
```

### Use Cases

- **Auto-resolve**: CLI can offer to resolve comments when the referenced files are committed
- **Traceability**: Audit trail of which commits addressed which UI feedback
- **AI context**: An agent can see "this comment was addressed in commit abc123"

## Example File

`opentoolbar/comments/v1/my-app/dashboard.json`:

```json
{
  "version": 1,
  "projectId": "my-app",
  "pathname": "/dashboard",
  "comments": [
    {
      "id": "V1StGXR8_Z5j",
      "text": "This button should use the brand color (red) per design system guidelines",
      "branch": "feature/dashboard-redesign",
      "domAnchor": {
        "selector": "button.btn-primary",
        "textContent": "Submit",
        "tagName": "button",
        "boundingRect": { "x": 340, "y": 520, "width": 120, "height": 40 },
        "htmlSnapshot": "<button class=\"btn-primary\">Submit</button>"
      },
      "sourceAnchor": {
        "filePath": "src/components/Dashboard/SubmitButton.tsx",
        "componentName": "SubmitButton",
        "lineNumber": 24,
        "commitSha": "a1b2c3d4e5f6"
      },
      "author": {
        "name": "Alice Chen",
        "email": "alice@example.com",
        "avatarUrl": "https://avatars.githubusercontent.com/u/12345",
        "source": "github"
      },
      "status": "active",
      "createdAt": "2025-02-11T10:30:00Z",
      "updatedAt": "2025-02-11T10:30:00Z"
    },
    {
      "id": "Xk9mP2qR7wYn",
      "text": "Spacing between cards is inconsistent — should be 16px uniformly",
      "branch": "main",
      "domAnchor": {
        "selector": ".dashboard-grid",
        "textContent": "",
        "tagName": "div",
        "boundingRect": { "x": 20, "y": 100, "width": 960, "height": 600 },
        "htmlSnapshot": "<div class=\"dashboard-grid\">...</div>"
      },
      "sourceAnchor": null,
      "author": {
        "name": "Bob Miller",
        "email": "bob@example.com",
        "avatarUrl": null,
        "source": "git-config"
      },
      "status": "active",
      "createdAt": "2025-02-11T11:00:00Z",
      "updatedAt": "2025-02-11T11:00:00Z"
    }
  ]
}
```
