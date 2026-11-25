// What stderr-blog's editor makes of pasted text (tools/cosense/editor/input.js
// `transformPaste`, the authority lua/notes/paste.lua ports): reads one JSON case per
// line on stdin — { before, after, text }, the page split at the cursor — and writes
// the text to insert, as one JSON string per line, for paste_diff.lua to compare.
// usage: node paste_reference.mjs <stderr-blog repo> < cases
import { createInterface } from "node:readline";
import { join } from "node:path";

const repo = process.argv[2];
// convertUrl reads the editor's own address off the page it runs in (lua/notes/paste.lua `OWN`).
globalThis.window = { location: { origin: "http://localhost:39321" } };
const { EditorState } = await import(join(repo, "node_modules/@codemirror/state/dist/index.js"));
const { transformPaste } = await import(join(repo, "tools/cosense/editor/input.js"));
const { pageField } = await import(join(repo, "tools/cosense/editor/decorate.js"));

for await (const line of createInterface({ input: process.stdin })) {
  if (!line) continue;
  const { before, after, text } = JSON.parse(line);
  const state = EditorState.create({ doc: before + after, selection: { anchor: before.length }, extensions: [pageField] });
  console.log(JSON.stringify(transformPaste(state, text)));
}
