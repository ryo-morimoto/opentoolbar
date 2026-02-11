# Project Learnings

> AI agentは新しいchange開始時にこのファイルを参照する。
> /compound:ship の archive ステップで自動追記される。

---

## 設計議論からの学び (2024-01)

### Vercel Preview Comments の技術調査

- Vercelは**エッジでスクリプトを自動注入**している（Preview Deployment時）
- `@vercel/toolbar` パッケージで手動注入も可能
- コメントは**DOM要素にバインド**される（CSSセレクタベース）
- ブログより: "A comment marks exactly in the UI where things need to improve as it's actually attached to the underlying DOM element."

### react-grab との関係

- react-grabは**要素選択 + Reactコンポーネント情報取得**に特化
- **プラグインシステム**がある（`__REACT_GRAB__.registerPlugin()`）
- 本ツールはreact-grabの上に構築するか、同等のロジックを内包するか選択可能

### マルチプロジェクト/Worktree対応

- localhost:3000だけでは識別不可能
- **projectId + branch でキーを構成**する必要あり
- localStorage: `ruc:${projectId}:${branch}:${pathname}`
- ファイル保存: `.comments/${branch}/${pathname}.json`

### 導入方式の選択

- **Script tag方式**がMVPに最適（react-grabと同じアプローチ）
- Providerは侵襲性が高いため却下
- Vite/Next Pluginは将来対応
