# Architecture Specification

## Purpose

Define integration methods, data flow, and multi-project support for opentoolbar.

## Requirements

### Requirement: Script Tag Integration

The system MUST support a script tag integration as the primary (MVP) method.

#### Scenario: Basic script tag setup

- GIVEN a web application with a development server
- WHEN the developer adds `<script src="https://unpkg.com/opentoolbar" data-project-id="my-app">` to their HTML
- THEN the toolbar initializes with the specified project ID
- AND comment mode becomes available

#### Scenario: Script tag with optional attributes

- GIVEN a script tag with `data-branch` and `data-cli-port` attributes
- WHEN the toolbar initializes
- THEN it uses the specified branch for comment storage keys
- AND it attempts CLI connection on the specified port

### Requirement: Hybrid Storage

The system MUST support a hybrid storage model with CLI mode and localStorage fallback.

#### Scenario: CLI is running

- GIVEN the CLI server is running on the configured port
- WHEN the browser toolbar initializes
- THEN comments are saved to `.comments/` files via WebSocket

#### Scenario: CLI is not running

- GIVEN no CLI server is detected
- WHEN the browser toolbar initializes
- THEN comments fall back to localStorage with key `otb:${projectId}:${branch}:${pathname}`

### Requirement: CLI Detection

The system MUST detect CLI availability via HTTP health check.

#### Scenario: Health check succeeds

- GIVEN the CLI is running on port 4567
- WHEN the browser sends `GET /health`
- THEN a WebSocket connection is established for real-time sync

#### Scenario: Health check fails

- GIVEN no CLI is running
- WHEN the health check request fails
- THEN the system returns null and uses localStorage fallback

### Requirement: Multi-project Isolation

The system MUST isolate comments by project ID and branch.

#### Scenario: Same localhost port, different projects

- GIVEN two projects both running on localhost:3000
- WHEN comments are stored
- THEN each project's comments are keyed by its project ID and branch
- AND no cross-contamination occurs

### Requirement: Browser-CLI Communication

The system MUST use WebSocket for real-time browser-CLI communication.

#### Scenario: Initial sync

- GIVEN a browser connects to the CLI WebSocket
- WHEN the browser sends `{ type: 'sync', payload: { pathname: '/' } }`
- THEN the CLI responds with all comments for that pathname

#### Scenario: Comment broadcast

- GIVEN multiple browsers connected to the CLI
- WHEN one browser adds a comment
- THEN the CLI saves to file and broadcasts to all connected browsers

## Future Considerations

- Vite/Next Plugin integration (easier setup, no script tag needed)
- CLI + Proxy mode (non-invasive, full feature set)
