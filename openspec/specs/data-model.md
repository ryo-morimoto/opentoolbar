# Data Model

## Comment

```typescript
interface Comment {
  id: string;                     // UUID v4

  // Element identification (anchor)
  anchor: ElementAnchor;

  // Comment content
  text: string;

  // Metadata
  status: 'active' | 'outdated';
  createdAt: string;              // ISO8601
  updatedAt: string;
}
```

## ElementAnchor

Information for identifying an element. Hybrid approach using CSS selector + coordinates.

```typescript
interface ElementAnchor {
  // Primary identification
  selector: string;               // Unique CSS selector

  // Additional info from react-grab (if available)
  componentName?: string;         // "LoginForm"
  filePath?: string;              // "src/components/LoginForm.tsx:24"

  // Fallback information
  boundingRect: DOMRect;          // Position and size
  textContent?: string;           // First 100 chars of innerText
  tagName: string;                // "BUTTON"

  // Change detection
  htmlSnapshot: string;           // First 500 chars of outerHTML
}
```

## Selector Generation Algorithm

```typescript
function generateSelector(element: Element): string {
  // 1. Prefer id if available
  if (element.id) return `#${element.id}`;

  // 2. Use data-testid if available
  const testId = element.getAttribute('data-testid');
  if (testId) return `[data-testid="${testId}"]`;

  // 3. Build relative path from parent (using nth-child etc.)
  return buildPathSelector(element);
}

function buildPathSelector(element: Element): string {
  const path: string[] = [];
  let current: Element | null = element;

  while (current && current !== document.body) {
    let selector = current.tagName.toLowerCase();

    // Add class names if present (first 1-2)
    if (current.classList.length > 0) {
      selector += '.' + Array.from(current.classList).slice(0, 2).join('.');
    }

    // Use nth-child if siblings share the same selector
    const siblings = current.parentElement?.querySelectorAll(`:scope > ${selector}`);
    if (siblings && siblings.length > 1) {
      const index = Array.from(siblings).indexOf(current) + 1;
      selector += `:nth-child(${index})`;
    }

    path.unshift(selector);
    current = current.parentElement;
  }

  return path.join(' > ');
}
```

## Element Re-identification

```typescript
function findElement(anchor: ElementAnchor): Element | null {
  // 1. Query by selector
  const bySelector = document.querySelector(anchor.selector);
  if (bySelector) return bySelector;

  // 2. Fallback: match text near coordinates
  const candidates = document.elementsFromPoint(
    anchor.boundingRect.x + anchor.boundingRect.width / 2,
    anchor.boundingRect.y + anchor.boundingRect.height / 2
  );

  for (const el of candidates) {
    if (el.tagName === anchor.tagName &&
        el.textContent?.startsWith(anchor.textContent || '')) {
      return el;
    }
  }

  return null; // Element not found (treated as outdated)
}
```

## Outdated Detection

```typescript
function checkOutdated(comment: Comment): boolean {
  const element = findElement(comment.anchor);

  if (!element) return true;  // Element disappeared

  // Compare with HTML snapshot
  const currentSnapshot = element.outerHTML.slice(0, 500);
  return currentSnapshot !== comment.anchor.htmlSnapshot;
}
```

## File Storage Format

### Directory Structure

```
my-app/
+-- .comments/
|   +-- config.json              # Project config
|   +-- main/                    # Directory per branch
|   |   +-- index.json           # Comments for page "/"
|   |   +-- about.json           # Comments for page "/about"
|   +-- feature-a/
|       +-- index.json
+-- src/
+-- package.json
```

### Per-page JSON File

```jsonc
// .comments/main/index.json
{
  "version": 1,
  "pathname": "/",
  "updatedAt": "2024-01-15T10:30:00Z",
  "comments": [
    {
      "id": "c_abc123",
      "anchor": {
        "selector": "#login-btn",
        "boundingRect": { "x": 100, "y": 200, "width": 80, "height": 32 },
        "textContent": "Login",
        "tagName": "BUTTON",
        "htmlSnapshot": "<button id=\"login-btn\">Login</button>"
      },
      "text": "Change button color to #2563EB",
      "status": "active",
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```
