## ADDED Requirements

### Requirement: DomAnchor type
The system SHALL define a `DomAnchor` interface for locating elements at runtime. It MUST contain: `selector` (CSS selector string), `textContent` (string), `tagName` (string), `boundingRect` ({x, y, width, height} as numbers), and `htmlSnapshot` (string). This type MUST be framework-agnostic.

#### Scenario: DomAnchor with all fields populated
- **WHEN** a comment is created on a button element
- **THEN** the DomAnchor stores the CSS selector, text content, tag name, bounding rect, and HTML snapshot

#### Scenario: DomAnchor with empty textContent
- **WHEN** a comment is created on a container element with no text
- **THEN** the DomAnchor stores an empty string for textContent

### Requirement: SourceAnchor type
The system SHALL define a `SourceAnchor` interface for tracking elements to source files. It MUST contain: `filePath` (string), `componentName` (string or null), `lineNumber` (number or null), and `commitSha` (string). This type is only populated when a framework adapter is active.

#### Scenario: SourceAnchor with full framework info
- **WHEN** a React adapter provides component source location
- **THEN** the SourceAnchor stores filePath, componentName, lineNumber, and commitSha

#### Scenario: SourceAnchor without component info
- **WHEN** a framework adapter cannot determine component name or line
- **THEN** componentName and lineNumber are null while filePath and commitSha remain populated

### Requirement: Author type
The system SHALL define an `Author` interface. It MUST contain: `name` (string), `email` (string), `avatarUrl` (string or null), and `source` (literal union `"git-config" | "github"`). Local dev uses `git-config` source; preview deploys use `github` source.

#### Scenario: Local dev author from git config
- **WHEN** a comment is created in local development
- **THEN** the Author has source `"git-config"` and avatarUrl is null

#### Scenario: Preview deploy author from GitHub
- **WHEN** a comment is created on a preview deployment
- **THEN** the Author has source `"github"` and avatarUrl contains the GitHub profile image URL

### Requirement: Comment type
The system SHALL define a `Comment` interface. It MUST contain: `id` (string), `text` (string), `branch` (string), `domAnchor` (DomAnchor), `sourceAnchor` (SourceAnchor or null), `author` (Author), `status` (literal union `"active" | "resolved"`), `createdAt` (ISO 8601 string), and `updatedAt` (ISO 8601 string). The `stale` state MUST NOT be a stored value.

#### Scenario: Comment with domAnchor only
- **WHEN** a comment is created without a framework adapter
- **THEN** sourceAnchor is null and domAnchor is populated

#### Scenario: Comment with both anchors
- **WHEN** a comment is created with a framework adapter active
- **THEN** both domAnchor and sourceAnchor are populated

#### Scenario: Comment status values
- **WHEN** a comment is persisted
- **THEN** status is either `"active"` or `"resolved"` — never `"stale"`

### Requirement: CommentFile type
The system SHALL define a `CommentFile` interface as the top-level structure stored on the shadow branch. It MUST contain: `version` (literal `1`), `projectId` (string), `pathname` (string), and `comments` (array of Comment). One file per page per project.

#### Scenario: Empty comment file
- **WHEN** a page has no comments yet
- **THEN** the CommentFile has version 1, the project ID, the pathname, and an empty comments array

#### Scenario: Comment file with multiple comments
- **WHEN** a page has comments from different branches and authors
- **THEN** all comments are stored in the same CommentFile, each with their own branch field
