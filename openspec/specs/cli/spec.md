# CLI Specification

## Purpose

Define the optional CLI server that provides file-based storage, multi-project support, and MCP integration.

## Requirements

### Requirement: Optional CLI Server

The system MUST function without the CLI; the CLI is an optional enhancement.

#### Scenario: CLI not installed

- GIVEN a project using only the script tag
- WHEN the toolbar loads
- THEN it operates fully using localStorage fallback

### Requirement: Project Root Detection

The CLI MUST detect the project root by traversing up from cwd.

#### Scenario: Project with package.json

- GIVEN the CLI is run inside a project directory
- WHEN it traverses upward from cwd
- THEN it stops at the first directory containing `package.json`

#### Scenario: Project with .git only

- GIVEN a directory has `.git` but no `package.json`
- WHEN the CLI traverses upward
- THEN it uses that directory as the project root

#### Scenario: No project root found

- GIVEN the CLI is run outside any project
- WHEN traversal reaches `/` without finding markers
- THEN it throws "Project root not found"

### Requirement: Branch Detection

The CLI MUST detect the current git branch, including worktree scenarios.

#### Scenario: Standard git branch

- GIVEN a normal git repository
- WHEN the CLI queries the branch
- THEN it returns the current branch name via `git rev-parse --abbrev-ref HEAD`

#### Scenario: Git worktree

- GIVEN a git worktree checkout
- WHEN the CLI queries the branch
- THEN it correctly returns the worktree's branch (not the main repo's branch)

### Requirement: WebSocket Server

The CLI MUST start a WebSocket server for real-time browser communication.

#### Scenario: Browser connects

- GIVEN the CLI is running on port 4567
- WHEN a browser establishes a WebSocket connection and sends a sync message
- THEN the CLI responds with comments for the requested pathname

#### Scenario: Comment added via browser

- GIVEN a browser sends an "add" message with a comment
- WHEN the CLI receives it
- THEN it saves the comment to the appropriate file
- AND broadcasts the new comment to all connected browsers

### Requirement: HTTP Health Endpoint

The CLI MUST expose a health check endpoint at `GET /health`.

#### Scenario: Health check

- GIVEN the CLI is running
- WHEN a client sends `GET /health`
- THEN it responds with `{ "status": "ok", "project": "<name>", "branch": "<branch>" }`

### Requirement: REST Fallback API

The CLI SHOULD provide a REST endpoint for comment retrieval.

#### Scenario: Get comments for a page

- GIVEN comments exist for pathname "/"
- WHEN a client sends `GET /comments?pathname=/`
- THEN it responds with `{ "comments": [...] }`

### Requirement: File Watching

The CLI MUST watch `.comments/` for external changes and broadcast updates.

#### Scenario: External file modification

- GIVEN a comment file is modified outside the CLI (e.g., git pull)
- WHEN chokidar detects the change
- THEN the CLI broadcasts the updated data to all connected browsers

### Requirement: MCP Server

The CLI MUST start an MCP server alongside the WebSocket server for AI agent integration.

#### Scenario: Agent queries feedback

- GIVEN an AI agent connects via MCP
- WHEN it calls `get_ui_feedback` with optional pathname and status filters
- THEN the CLI returns matching comments with summary counts

#### Scenario: Agent resolves a comment

- GIVEN an AI agent calls `resolve_comment` with a commentId
- WHEN the CLI processes the request
- THEN the comment is marked as resolved in the file
