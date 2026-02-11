# Data Model

## Comment

```typescript
interface Comment {
  id: string;                     // UUID v4
  
  // 要素特定（アンカー）
  anchor: ElementAnchor;
  
  // コメント内容
  text: string;
  
  // メタデータ
  status: 'active' | 'outdated';
  createdAt: string;              // ISO8601
  updatedAt: string;
}
```

## ElementAnchor

要素を特定するための情報。CSSセレクタ + 座標のハイブリッド方式。

```typescript
interface ElementAnchor {
  // 主要な特定情報
  selector: string;               // 一意なCSSセレクタ
  
  // react-grabからの追加情報（あれば）
  componentName?: string;         // "LoginForm"
  filePath?: string;              // "src/components/LoginForm.tsx:24"
  
  // フォールバック情報
  boundingRect: DOMRect;          // 位置・サイズ
  textContent?: string;           // innerTextの先頭100文字
  tagName: string;                // "BUTTON"
  
  // 変更検出用
  htmlSnapshot: string;           // outerHTMLの先頭500文字
}
```

## セレクタ生成アルゴリズム

```typescript
function generateSelector(element: Element): string {
  // 1. idがあれば最優先
  if (element.id) return `#${element.id}`;
  
  // 2. data-testid等があれば使用
  const testId = element.getAttribute('data-testid');
  if (testId) return `[data-testid="${testId}"]`;
  
  // 3. 親からの相対パスを構築（nth-child等を使用）
  return buildPathSelector(element);
}

function buildPathSelector(element: Element): string {
  const path: string[] = [];
  let current: Element | null = element;
  
  while (current && current !== document.body) {
    let selector = current.tagName.toLowerCase();
    
    // クラス名があれば追加（最初の1-2個）
    if (current.classList.length > 0) {
      selector += '.' + Array.from(current.classList).slice(0, 2).join('.');
    }
    
    // 同じセレクタの兄弟がいれば nth-child
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

## 要素の再特定

```typescript
function findElement(anchor: ElementAnchor): Element | null {
  // 1. セレクタでクエリ
  const bySelector = document.querySelector(anchor.selector);
  if (bySelector) return bySelector;
  
  // 2. フォールバック: 座標近くでテキスト一致
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
  
  return null; // 要素が見つからない（outdated扱い）
}
```

## Outdated検出

```typescript
function checkOutdated(comment: Comment): boolean {
  const element = findElement(comment.anchor);
  
  if (!element) return true;  // 要素が消えた
  
  // HTMLスナップショットと比較
  const currentSnapshot = element.outerHTML.slice(0, 500);
  return currentSnapshot !== comment.anchor.htmlSnapshot;
}
```

## ファイル保存形式

### ディレクトリ構造

```
my-app/
├── .comments/
│   ├── config.json              # プロジェクト設定
│   ├── main/                    # ブランチごとにディレクトリ
│   │   ├── index.json           # ページ "/" のコメント
│   │   └── about.json           # ページ "/about" のコメント
│   └── feature-a/
│       └── index.json
├── src/
└── package.json
```

### ページ別JSONファイル

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
        "textContent": "ログイン",
        "tagName": "BUTTON",
        "htmlSnapshot": "<button id=\"login-btn\">ログイン</button>"
      },
      "text": "ボタンの色を#2563EBに変更",
      "status": "active",
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```
