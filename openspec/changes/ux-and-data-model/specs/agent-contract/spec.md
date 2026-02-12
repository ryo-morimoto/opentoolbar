## ADDED Requirements

### Requirement: Agent read contract
AI agents SHALL discover and read comments from the shadow branch using only git commands. No toolbar UI, CLI, or opentoolbar-specific tooling is required for reading.

#### Scenario: List comment files for a project
- **WHEN** an agent runs `git show opentoolbar/comments/v1:<projectId>/`
- **THEN** all comment files (pages) for that project are listed

#### Scenario: Read comments for a specific page
- **WHEN** an agent runs `git show opentoolbar/comments/v1:<projectId>/dashboard.json`
- **THEN** the full CommentFile JSON is returned

#### Scenario: Filter comments by current branch
- **WHEN** an agent pipes the JSON through `jq` filtering by the current git branch
- **THEN** only comments matching the current branch are returned

#### Scenario: Find comments referencing a source file
- **WHEN** an agent runs `git grep "<filename>" opentoolbar/comments/v1`
- **THEN** all comment files containing references to that filename are returned

#### Scenario: Detect stale comments
- **WHEN** an agent extracts `sourceAnchor.commitSha` and runs `git diff <commitSha>..HEAD -- <filePath>`
- **THEN** a non-empty diff indicates the comment is stale

#### Scenario: Find commits that addressed a comment
- **WHEN** an agent runs `git log --all --grep="Opentoolbar-Comment: <id>"`
- **THEN** code commits linked to that comment via git trailers are returned

### Requirement: Agent write contract via CLI
AI agents SHALL create and resolve comments using the opentoolbar CLI as the preferred write path. The CLI handles shadow branch mechanics.

#### Scenario: Create a comment via CLI
- **WHEN** an agent runs `opentoolbar comment add` with project, pathname, selector, text, and source file arguments
- **THEN** a new comment is committed to the shadow branch

#### Scenario: Resolve a comment via CLI
- **WHEN** an agent runs `opentoolbar comment resolve --id <id>`
- **THEN** the comment status changes to `resolved` on the shadow branch

### Requirement: Agent write contract via git plumbing
When the CLI is unavailable, agents SHALL write directly to the shadow branch using git plumbing commands (`hash-object`, `ls-tree`, `mktree`, `commit-tree`, `update-ref`). This MUST NOT check out the shadow branch into the working tree.

#### Scenario: Create a comment via git plumbing
- **WHEN** an agent modifies the JSON with jq, creates a blob, rebuilds the tree at each nesting level, and commits
- **THEN** the shadow branch is updated without affecting the working tree

### Requirement: Agent comment discovery
AI agents SHALL discover comments by checking for the shadow branch. The shadow branch IS the discovery mechanism — no configuration file or manifest is needed.

#### Scenario: Discover shadow branch existence
- **WHEN** an agent checks `git branch -a | grep opentoolbar/comments`
- **THEN** the presence of the branch indicates comments may exist

#### Scenario: List projects with comments
- **WHEN** an agent runs `git ls-tree opentoolbar/comments/v1`
- **THEN** project IDs are listed as top-level directories
