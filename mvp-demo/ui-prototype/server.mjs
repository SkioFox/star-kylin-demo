import { createServer } from "node:http";
import { readFile } from "node:fs/promises";

const port = Number(process.env.PORT || 4173);
const root = new URL("./", import.meta.url);
const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".map": "application/json; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".png": "image/png",
  ".svg": "image/svg+xml",
};

createServer(async (request, response) => {
  try {
    const pathname = decodeURIComponent(new URL(request.url, "http://localhost").pathname);
    const requestedPath = pathname === "/" ? "/index.html" : pathname;
    const fileUrl = new URL(`.${requestedPath}`, root);

    if (!fileUrl.href.startsWith(root.href)) {
      response.writeHead(403).end("Forbidden");
      return;
    }

    const body = await readFile(fileUrl);
    const extension = requestedPath.slice(requestedPath.lastIndexOf("."));
    response.writeHead(200, {
      "Cache-Control": "no-store",
      "Content-Type": contentTypes[extension] || "application/octet-stream",
    });
    response.end(body);
  } catch {
    response.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    response.end("Not found");
  }
}).listen(port, "127.0.0.1", () => {
  console.log(`UI prototype: http://127.0.0.1:${port}`);
});
