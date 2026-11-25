// How stderr-blog's editor ranks link completion candidates (tools/cosense/editor/suggest.js
// `rankTitles`, the authority lua/notes/complete.lua `rank` ports): reads one JSON case per
// line on stdin — { titles, query, kind, current } — and writes the titles offered, in order,
// as one JSON array per line, for complete_diff.lua to compare.
// usage: node complete_reference.mjs <stderr-blog repo> < cases
import { createInterface } from "node:readline";
import { join } from "node:path";

const repo = process.argv[2];
const { rankTitles } = await import(join(repo, "tools/cosense/editor/suggest.js"));

for await (const line of createInterface({ input: process.stdin })) {
  if (!line) continue;
  const { titles, query, kind, current } = JSON.parse(line);
  const items = titles.map((t) => ({ title: t.title, updated: t.updated, linkedAt: t.linked_at }));
  console.log(JSON.stringify(rankTitles(items, query, kind, current).map((t) => t.title)));
}
