## ADDED Requirements

### Requirement: Shadow branch naming and structure
The system SHALL use a single orphan branch named `opentoolbar/comments/v1` to store comment data. Files MUST be organized as `<projectId>/<pathname>.json`. The root pathname `/` MUST map to `_.json`. All other pathnames strip the leading `/` and append `.json`.

#### Scenario: Pathname to filename mapping
- **WHEN** a comment is created on pathname `/dashboard`
- **THEN** it is stored in `<projectId>/dashboard.json` on the shadow branch

#### Scenario: Root pathname mapping
- **WHEN** a comment is created on pathname `/`
- **THEN** it is stored in `<projectId>/_.json` on the shadow branch

#### Scenario: Nested pathname mapping
- **WHEN** a comment is created on pathname `/settings/profile`
- **THEN** it is stored in `<projectId>/settings/profile.json` on the shadow branch

### Requirement: Branch scoping
The system SHALL use a single shadow branch for all code branches. Each comment MUST store which code branch it was created on via the `branch` field. The toolbar MUST filter comments by the current code branch by default. Comments from other branches MUST be accessible with a branch label.

#### Scenario: Comments from multiple code branches
- **WHEN** comments exist on both `main` and `feature/auth` branches
- **THEN** all comments are stored in the same file with different `branch` field values

#### Scenario: Filtering by current branch
- **WHEN** the toolbar reads comments while on the `main` branch
- **THEN** comments with `branch: "main"` are shown by default

### Requirement: Comment ID generation
Comment IDs SHALL be generated client-side using nanoid with 12 characters and URL-safe alphabet (`A-Za-z0-9_-`). No server coordination is needed.

#### Scenario: Generate unique ID
- **WHEN** a new comment is created
- **THEN** a 12-character nanoid is generated as the comment ID

### Requirement: Git trailers for comment-commit linkage
The system SHALL link code commits to comments via git trailers in the format `Opentoolbar-Comment: <id>`. A `prepare-commit-msg` hook MUST check if active comments reference files touched by the commit (via `sourceAnchor.filePath`) and append matching trailers.

#### Scenario: Commit touches a file referenced by a comment
- **WHEN** a developer commits changes to `src/components/Button.tsx` and an active comment references that file
- **THEN** the commit message includes `Opentoolbar-Comment: <comment-id>` as a trailer

#### Scenario: Bidirectional lookup from comment to commits
- **WHEN** searching for commits that addressed comment `V1StGXR8_Z5j`
- **THEN** `git log --all --grep="Opentoolbar-Comment: V1StGXR8_Z5j"` returns matching commits
