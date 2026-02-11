# Decisions Specification

## Purpose

Track architectural and design decisions, both resolved and pending.

## Requirements

### Requirement: Target Framework

The system MUST target React as the primary framework for MVP.

### Requirement: Hybrid Storage

The system MUST use a hybrid storage model: localStorage (fallback) + CLI file storage.

### Requirement: Anonymous Usage

The system MUST NOT require authentication. All usage is anonymous.

### Requirement: npm Distribution

The system MUST be distributed as an npm package with CDN support (unpkg, jsdelivr).

### Requirement: CSS Selector + Coordinate Binding

The system MUST bind comments to elements using CSS selectors with coordinate-based fallback.

### Requirement: Single Comment per Anchor

The system MUST support a single comment per anchor point (no threading) for MVP.

### Requirement: Two-State Status

The system MUST use a two-state status model: "active" and "outdated".

## Open Decisions (to be decided during MVP implementation)

### Decision: react-grab Integration

- **Option A**: Depend on react-grab for element selection
- **Option B**: Implement equivalent logic independently, inspired by react-grab

### Decision: .comments/ Git Management

- **Option A**: Default to .gitignore (developer-local)
- **Option B**: Default to git-tracked (team-shared)

### Decision: Shortcut Customization

- **Option A**: Fixed shortcuts only
- **Option B**: User-configurable shortcuts

## Future Considerations

- Auto screenshot capture (html2canvas or manual) — Medium priority
- Vite/Next Plugin for easier integration — Medium priority
- Markdown support in comment body — Low priority
- Multi-browser real-time sync — Low priority
