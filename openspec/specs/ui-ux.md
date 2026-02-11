# UI/UX Specification

## Modes

| State | Description |
|-------|-------------|
| OFF | Nothing displayed |
| ON | Hover highlight + pin display + popover |

## Controls

| Action | Method |
|--------|--------|
| Toggle comment mode ON/OFF | Toggle button (UI) |
| Toggle comment mode ON/OFF | Shortcut (Cmd+Shift+C / Ctrl+Shift+C) |
| Select element | Hover -> Click |
| Add comment | Popover appears after element selection |
| View comment | Click pin -> Popover |

## Highlight (Vercel-like)

```css
/* On hover */
.ruc-highlight {
  outline: 2px solid #3B82F6;
  background: rgba(59, 130, 246, 0.1);
  border-radius: 4px;
  pointer-events: none;
  position: absolute;
  z-index: 10000;
  transition: all 0.1s ease;
}
```

## Pins

```
+----------------------------------+
|  [1]  <- Circular badge (24px)   |
|   |                              |
|   |   Position  top-right of     |
|   |             element          |
|   |   Color  active=#3B82F6      |
|   |          outdated=#9CA3AF    |
|   |   Display  number (page seq) |
+----------------------------------+
```

```css
.ruc-pin {
  position: absolute;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #3B82F6;
  color: white;
  font-size: 12px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 10001;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.ruc-pin--outdated {
  background: #9CA3AF;
}

.ruc-pin:hover {
  transform: scale(1.1);
}
```

## Popover

```
+--------------------------------------------+
|  +--------------------------------------+  |
|  |                                      |  |
|  |  Comment textarea                    |  |
|  |  (min-height: 60px)                  |  |
|  |                                      |  |
|  +--------------------------------------+  |
|                                            |
|  [Cancel]                     [Save]       |
+--------------------------------------------+

View mode:
+--------------------------------------------+
|  Change button color to #2563EB            |
|                                            |
|  ---------------------------------------- |
|  2024/01/15 10:30                          |
|                          [Edit] [Delete]   |
+--------------------------------------------+
```

```css
.ruc-popover {
  position: absolute;
  min-width: 280px;
  max-width: 360px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  padding: 12px;
  z-index: 10002;
}

.ruc-popover__textarea {
  width: 100%;
  min-height: 60px;
  border: 1px solid #E5E7EB;
  border-radius: 4px;
  padding: 8px;
  font-size: 14px;
  resize: vertical;
}

.ruc-popover__actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 12px;
}

.ruc-popover__btn {
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
}

.ruc-popover__btn--primary {
  background: #3B82F6;
  color: white;
  border: none;
}

.ruc-popover__btn--secondary {
  background: white;
  color: #374151;
  border: 1px solid #E5E7EB;
}
```

## Toggle Button

```
+--------------------------------------------+
|                                            |
|  Fixed at bottom-right of screen           |
|                                            |
|                        +--------+          |
|                        | :) 3   |  <- Comment count
|                        +--------+          |
+--------------------------------------------+
```

```css
.ruc-toggle {
  position: fixed;
  bottom: 20px;
  right: 20px;
  padding: 8px 16px;
  background: #1F2937;
  color: white;
  border-radius: 20px;
  font-size: 14px;
  cursor: pointer;
  z-index: 10003;
  display: flex;
  align-items: center;
  gap: 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.ruc-toggle--active {
  background: #3B82F6;
}
```

## Z-Index Layers

| Layer | z-index | Purpose |
|-------|---------|---------|
| Highlight | 10000 | Hover highlight |
| Pin | 10001 | Comment pins |
| Popover | 10002 | Popover |
| Toggle | 10003 | Toggle button |
