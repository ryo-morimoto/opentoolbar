# Tasks: ux-and-data-model

## Phase 1: TypeScript Types

- [x] **1.1**: Define `DomAnchor` interface with doc comments — Acceptance: type compiles, all 5 fields documented
- [x] **1.2**: Define `SourceAnchor` interface with nullable fields — Acceptance: type compiles, componentName and lineNumber are `string | null` and `number | null`
- [x] **1.3**: Define `Author` interface with source union — Acceptance: type compiles, source is `"git-config" | "github"`
- [x] **1.4**: Define `Comment` interface with branch field — Acceptance: type compiles, status is `"active" | "resolved"`, branch is string, stale is NOT stored
- [x] **1.5**: Define `CommentFile` interface — Acceptance: type compiles, version is literal `1`, includes projectId

## Phase 2: Tests

- [x] **2.1**: Test DomAnchor interface satisfaction — Acceptance: test passes with valid DomAnchor object
- [x] **2.2**: Test SourceAnchor with full and null fields — Acceptance: tests pass for both populated and null componentName/lineNumber
- [x] **2.3**: Test Author for both git-config and github sources — Acceptance: tests pass for both source values
- [x] **2.4**: Test Comment with and without sourceAnchor — Acceptance: tests pass for active/resolved status, null/present sourceAnchor
- [x] **2.5**: Test CommentFile interface — Acceptance: test passes with empty comments array

## Phase 3: Exports

- [x] **3.1**: Update `src/index.ts` to export all new types — Acceptance: DomAnchor, SourceAnchor, Author, Comment, CommentFile all exported
