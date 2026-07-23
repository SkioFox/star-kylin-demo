import { createRequire } from "node:module";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const here = dirname(fileURLToPath(import.meta.url));
const lucide = require(resolve(here, "../../ui-prototype/node_modules/lucide"));
const output = resolve(here, "../resources/icons");

const selected = {
  "arrow-left": "ArrowLeft",
  "arrow-right": "ArrowRight",
  "badge-check": "BadgeCheck",
  calculator: "Calculator",
  "chart-candlestick": "ChartCandlestick",
  "chevron-down": "ChevronDown",
  database: "Database",
  eye: "Eye",
  "eye-off": "EyeOff",
  "globe-2": "Globe2",
  landmark: "Landmark",
  "layout-dashboard": "LayoutDashboard",
  "lock-keyhole": "LockKeyhole",
  "log-out": "LogOut",
  "monitor-up": "MonitorUp",
  "refresh-cw": "RefreshCw",
  server: "Server",
  "shield-check": "ShieldCheck",
  "triangle-alert": "TriangleAlert",
  "user-round": "UserRound",
  x: "X",
};

function escape(value) {
  return String(value).replaceAll("&", "&amp;").replaceAll('"', "&quot;");
}

function element([tag, attributes]) {
  const serialized = Object.entries(attributes)
    .map(([key, value]) => `${key}="${escape(value)}"`)
    .join(" ");
  return `  <${tag} ${serialized}/>`;
}

mkdirSync(output, { recursive: true });
for (const [fileName, exportName] of Object.entries(selected)) {
  const icon = lucide.icons?.[exportName] || lucide[exportName];
  const iconNode = icon?.iconNode || icon;
  if (!Array.isArray(iconNode)) throw new Error(`Missing Lucide icon: ${exportName}`);
  const svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">',
    ...iconNode.map(element),
    "</svg>",
    "",
  ].join("\n");
  writeFileSync(resolve(output, `${fileName}.svg`), svg, "utf8");
}
