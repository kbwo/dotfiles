// What stderr-blog's own parser (src/lib/cosense/parser.mjs, the authority the
// Lua port follows) makes of every page under a directory: one JSON object per
// page on stdout, for parser_diff.lua to compare the port's answers with.
// usage: node parser_reference.mjs <stderr-blog repo> <pages dir>
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const [repo, pagesDir] = process.argv.slice(2);
const { parsePage, analyzePage, imageSourcesOf } = await import(join(repo, "src/lib/cosense/parser.mjs"));

const bytes = (s) => Buffer.byteLength(s, "utf8");
const walk = (d) => readdirSync(d).flatMap((n) => (statSync(join(d, n)).isDirectory() ? walk(join(d, n)) : n.endsWith(".txt") ? [join(d, n)] : []));

function linksInLine(nodes, text) {
  const out = [];
  const visit = (list, offset) => {
    for (const node of list) {
      if (node.page !== undefined && !node.project && ["link", "hashTag", "icon", "strongIcon"].includes(node.type)) {
        const start = bytes(text.slice(0, offset));
        out.push([node.type, node.page, start, start + bytes(node.raw)]);
      }
      if (node.children) visit(node.children, offset + node.prefix.length);
      offset += node.raw.length;
    }
  };
  visit(nodes, 0);
  return out;
}

for (const file of walk(pagesDir)) {
  const text = readFileSync(file, "utf8");
  const links = parsePage(text).map((line) => linksInLine(line.nodes, line.text));
  const { title, descriptions } = analyzePage(text);
  process.stdout.write(JSON.stringify({ file: relative(pagesDir, file), links, title, descriptions, images: imageSourcesOf(text) }) + "\n");
}
