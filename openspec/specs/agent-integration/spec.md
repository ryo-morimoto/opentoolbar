# Agent Integration Specification

## Purpose

Define how UI comments are exported to and consumed by AI agents, the key differentiator of opentoolbar.

## Requirements

### Requirement: Prompt Copy Export

The system MUST provide a "Copy as Prompt" action that exports comments as a structured markdown prompt.

#### Scenario: Export active comments

- GIVEN 2 active comments and 1 outdated comment on a page
- WHEN the user clicks "Copy as Prompt"
- THEN the clipboard contains a markdown report with all comments
- AND active comments are listed first, followed by outdated
- AND each comment includes component name, file path, element snapshot, selector, and comment text

#### Scenario: Outdated comment annotation

- GIVEN an outdated comment is included in the export
- WHEN the prompt is generated
- THEN the comment includes a note: "This element has been modified since the comment was created."

### Requirement: JSON Export

The system MUST support JSON export of comments.

#### Scenario: Export all comments as JSON

- GIVEN comments exist on a page
- WHEN the user triggers JSON export
- THEN the output is a JSON object with `version`, `exportedAt`, and `comments` array

### Requirement: MCP Tool - get_ui_feedback

The CLI MCP server MUST expose a `get_ui_feedback` tool.

#### Scenario: Get all feedback

- GIVEN comments exist across multiple pages
- WHEN an agent calls `get_ui_feedback` without filters
- THEN it returns all comments with a summary of total, active, and outdated counts

#### Scenario: Filter by pathname

- GIVEN comments exist on "/" and "/about"
- WHEN an agent calls `get_ui_feedback` with `pathname: "/"`
- THEN only comments for "/" are returned

#### Scenario: Filter by status

- GIVEN both active and outdated comments exist
- WHEN an agent calls `get_ui_feedback` with `status: "active"`
- THEN only active comments are returned

### Requirement: MCP Tool - resolve_comment

The CLI MCP server MUST expose a `resolve_comment` tool.

#### Scenario: Resolve a comment

- GIVEN an active comment with id "c_abc123"
- WHEN an agent calls `resolve_comment` with `commentId: "c_abc123"`
- THEN the comment is removed or marked as resolved in the storage file

### Requirement: End-to-End Agent Workflow

The system SHOULD support the full workflow: developer comments -> agent retrieves -> agent fixes -> agent resolves.

#### Scenario: AI-assisted fix cycle

- GIVEN a developer leaves a comment "Change button color to #2563EB"
- WHEN an AI agent calls `get_ui_feedback` via MCP
- THEN it receives the comment with file path and component info
- AND the agent can modify the source file and call `resolve_comment`
