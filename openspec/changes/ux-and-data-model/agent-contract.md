# AI Agent Contract

How AI agents (Claude Code, Cursor, Copilot, etc.) read and write opentoolbar comments using only git commands.

## Read Contract

An agent discovers and reads comments from the shadow branch without needing the toolbar UI, CLI, or any opentoolbar-specific tooling.

### Step-by-Step: Read Comments for a Page

```bash
# 1. List all comment files for a project
git show opentoolbar/comments/v1:my-app/ 2>/dev/null

# 2. Read comments for a specific page (e.g., /dashboard)
git show opentoolbar/comments/v1:my-app/dashboard.json

# 3. Read comments for the root page (/)
git show opentoolbar/comments/v1:my-app/_.json

# 4. Filter by current branch (using jq)
git show opentoolbar/comments/v1:my-app/dashboard.json | \
  jq --arg branch "$(git branch --show-current)" \
  '.comments | map(select(.branch == $branch))'
```

### Step-by-Step: Find All Comments Referencing a File

An agent working on `src/components/SubmitButton.tsx` can find related comments:

```bash
# Search all comment files for references to a source file
git grep "SubmitButton.tsx" opentoolbar/comments/v1
```

### Step-by-Step: Detect Stale Comments

```bash
# 1. Read a comment file and extract source anchors
git show opentoolbar/comments/v1:my-app/dashboard.json | \
  jq '.comments[] | select(.sourceAnchor != null) | {id, file: .sourceAnchor.filePath, since: .sourceAnchor.commitSha}'

# 2. For each comment, check if the source file changed since the comment was created
git diff a1b2c3d4e5f6..HEAD -- src/components/Dashboard/SubmitButton.tsx

# If diff is non-empty, the comment is stale
```

### Step-by-Step: Find Commits That Addressed a Comment

```bash
# Find code commits that reference a specific comment via git trailers
git log --all --grep="Opentoolbar-Comment: V1StGXR8_Z5j" --oneline
```

## Write Contract

An agent can create, resolve, or modify comments by committing to the shadow branch.

### Recommended: Use the CLI

The CLI provides the simplest write path for local agents:

```bash
# Create a comment (CLI handles shadow branch mechanics)
opentoolbar comment add \
  --project my-app \
  --pathname /dashboard \
  --selector "button.btn-primary" \
  --text "This button should be red" \
  --file src/components/SubmitButton.tsx \
  --component SubmitButton \
  --line 24

# Resolve a comment
opentoolbar comment resolve --id V1StGXR8_Z5j
```

### Alternative: Direct Git Operations

When the CLI is not available, agents can write directly to the shadow branch using git plumbing commands. This avoids checking out the shadow branch into the working tree.

```bash
# 1. Read the current file content from the shadow branch
CONTENT=$(git show opentoolbar/comments/v1:my-app/dashboard.json 2>/dev/null || echo '{"version":1,"projectId":"my-app","pathname":"/dashboard","comments":[]}')

# 2. Modify the JSON (add a new comment)
# Note: openssl rand -hex 6 produces 12 hex characters (0-9, a-f).
# This is a pragmatic approximation of nanoid (A-Za-z0-9_-) for
# environments without a nanoid generator. The IDs are valid but
# use a narrower character set than the canonical format.
UPDATED=$(echo "$CONTENT" | jq --arg id "$(openssl rand -hex 6)" \
  --arg branch "$(git branch --show-current)" \
  --arg sha "$(git rev-parse HEAD)" \
  --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '.comments += [{
    id: $id,
    text: "This button should be red per brand guidelines",
    branch: $branch,
    domAnchor: {
      selector: "button.btn-primary",
      textContent: "Submit",
      tagName: "button",
      boundingRect: { x: 0, y: 0, width: 0, height: 0 },
      htmlSnapshot: "<button class=\"btn-primary\">Submit</button>"
    },
    sourceAnchor: {
      filePath: "src/components/SubmitButton.tsx",
      componentName: "SubmitButton",
      lineNumber: 24,
      commitSha: $sha
    },
    author: {
      name: "Claude",
      email: "noreply@anthropic.com",
      avatarUrl: null,
      source: "git-config"
    },
    status: "active",
    createdAt: $now,
    updatedAt: $now
  }]')

# 3. Write to the shadow branch without checking it out
BLOB=$(echo "$UPDATED" | git hash-object -w --stdin)

# Rebuild the my-app/ subtree with the updated file
NEW_APP_TREE=$(git ls-tree opentoolbar/comments/v1:my-app | \
  sed "s|^\(100644 blob \)[0-9a-f]*\(\tdashboard.json\)$|\1$BLOB\2|" | \
  git mktree)

# Rebuild the root tree with the updated my-app/ subtree
NEW_ROOT_TREE=$(git ls-tree opentoolbar/comments/v1 | \
  sed "s|^\(040000 tree \)[0-9a-f]*\(\tmy-app\)$|\1$NEW_APP_TREE\2|" | \
  git mktree)

COMMIT=$(echo "Add comment on /dashboard" | \
  git commit-tree "$NEW_ROOT_TREE" -p opentoolbar/comments/v1)
git update-ref refs/heads/opentoolbar/comments/v1 "$COMMIT"
```

**Note**: The direct git plumbing approach is complex. The CLI is the preferred write path for agents. The plumbing commands above are provided for environments where the CLI cannot be installed.

### Resolving a Comment

```bash
# Using CLI (recommended)
opentoolbar comment resolve --id V1StGXR8_Z5j

# Using jq + git plumbing (same mechanism as create, modify the JSON)
# Update: .status = "resolved", .updatedAt = <now>
```

### Agent-Created Comments

When an AI agent creates a comment, it follows the same schema. Notable differences:

- `author.name`: The agent's name (e.g., "Claude", "Copilot")
- `author.source`: `"git-config"` (agents operate locally)
- `branch`: Current code branch from `git branch --show-current`
- `domAnchor`: May be minimal — an agent may not have full DOM context. At minimum, provide `selector` and `tagName`. Other fields can be empty strings / zero rects.
- `sourceAnchor`: Agents often have **better** source context than the browser. They can populate `filePath`, `componentName`, `lineNumber`, and current `commitSha` directly.

## Discovery: How an Agent Knows Comments Exist

1. **Shadow branch presence**: `git branch -a | grep opentoolbar/comments` — if the branch exists, comments may exist
2. **Project listing**: `git ls-tree opentoolbar/comments/v1` — lists project IDs
3. **File listing**: `git ls-tree opentoolbar/comments/v1:my-app/` — lists all pages with comments

No configuration file or manifest is needed. The shadow branch IS the discovery mechanism.
