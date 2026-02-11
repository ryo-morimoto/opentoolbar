import { defineConfig } from "tsup";

export default defineConfig([
  {
    entry: { index: "src/index.ts" },
    format: ["esm", "cjs"],
    dts: true,
    clean: true,
  },
  {
    entry: { cli: "src/cli.ts" },
    format: ["esm", "cjs"],
  },
  {
    entry: { opentoolbar: "src/index.ts" },
    format: ["iife"],
    globalName: "OpenToolbar",
    outExtension: () => ({ js: ".global.js" }),
  },
]);
