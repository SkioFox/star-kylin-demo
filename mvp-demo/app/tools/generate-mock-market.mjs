import { writeFileSync } from "node:fs";

const DAYS = 380;
const end = new Date(Date.UTC(2026, 6, 21));
const dates = [];

for (let cursor = new Date(end); dates.length < DAYS; cursor.setUTCDate(cursor.getUTCDate() - 1)) {
  const day = cursor.getUTCDay();
  if (day !== 0 && day !== 6) {
    dates.unshift(new Date(cursor));
  }
}

let previousClose = 3180;
const daily = dates.map((date, index) => {
  const wave = Math.sin(index * 0.47) * 13 + Math.cos(index * 0.18) * 7;
  const drift = 0.52 + (index % 19 === 0 ? -9 : 0);
  const open = previousClose + Math.sin(index * 1.07) * 8;
  const close = open + wave * 0.42 + drift;
  const low = Math.min(open, close) - 6 - (index % 4) * 2.1;
  const high = Math.max(open, close) + 7 + (index % 5) * 1.9;
  previousClose = close;
  return {
    date: date.toISOString().slice(0, 10),
    open: Number(open.toFixed(2)),
    high: Number(high.toFixed(2)),
    low: Number(low.toFixed(2)),
    close: Number(close.toFixed(2)),
    volume: 42000 + ((index * 7919) % 56000),
  };
});

const market = {
  schemaVersion: 1,
  symbol: "DEMO.IDX",
  updatedAt: "2026-07-21T09:30:00+08:00",
  daily,
};
const json = `${JSON.stringify(market, null, 2)}\n`;

writeFileSync(new URL("../resources/web-kline/mock-market.json", import.meta.url), json);
writeFileSync(
  new URL("../resources/web-kline/mock-market.js", import.meta.url),
  `window.STAR_KYLIN_MARKET_DATA = ${json};`,
);
