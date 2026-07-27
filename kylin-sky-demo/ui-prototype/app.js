const quotes = [
  { name: "平安银行", code: "000001", price: "11.24", change: "-0.36%", amount: "12.4 亿", category: "银行" },
  { name: "中证银行", code: "399986", price: "4,311.08", change: "+0.36%", amount: "54.8 亿", category: "行业指数" },
  { name: "沪深 300", code: "000300", price: "3,821.40", change: "-0.42%", amount: "626 亿", category: "宽基指数" },
  { name: "上证 50", code: "000016", price: "2,731.55", change: "+0.18%", amount: "198 亿", category: "宽基指数" },
  { name: "宁德时代", code: "300750", price: "186.82", change: "+1.12%", amount: "29.1 亿", category: "新能源" },
  { name: "中国移动", code: "600941", price: "108.34", change: "-0.71%", amount: "8.7 亿", category: "通信服务" },
  { name: "科创 50", code: "000688", price: "982.61", change: "-0.94%", amount: "84.0 亿", category: "科技成长" },
  { name: "黄金 ETF", code: "518880", price: "6.413", change: "+0.28%", amount: "6.2 亿", category: "商品基金" }
];

const stage = document.getElementById("view-stage");
const title = document.getElementById("view-title");
const subtitle = document.getElementById("view-subtitle");
const quoteBody = document.getElementById("quote-body");
const toast = document.getElementById("toast");
let selected = 0;

// The static prototype renders representative embedded content locally. The production
// WebView will load only the signed Manifest entryUrl, never an arbitrary typed URL.
function embeddedDocument(app, external) {
  const body = external
    ? `<header><b>${app.name}</b><span>公开内容 · 仅供阅读</span></header><section class="public-hero"><p>今日精选</p><h2>${app.name}</h2><span>聚合公开信息，帮助研究人员快速掌握重要动态。</span></section><div class="public-grid"><article><h3>宏观观察</h3><p>主要市场波动收敛，关注跨市场风险传导。</p></article><article><h3>产业趋势</h3><p>算力、通信与能源基础设施持续受到关注。</p></article><article><h3>学习中心</h3><p>合规公开课程与行业解读内容。</p></article></div>`
    : `<header><b>运营协同系统</b><span>当前队列 · 华东区域</span></header><div class="business-summary"><article><small>待核验事项</small><strong>18</strong><span>较昨日 +3</span></article><article><small>处理中工单</small><strong>42</strong><span>其中 6 项临近时限</span></article><article><small>已完成</small><strong>126</strong><span>今日完成率 93%</span></article></div><section class="business-list"><h3>待处理事项</h3><p><b>对公开户资料复核</b><span>待补充材料 · 10:45</span></p><p><b>网点服务异常跟进</b><span>处理中 · 10:32</span></p><p><b>权限申请二次确认</b><span>待核验 · 10:18</span></p></section>`;
  return `<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><style>body{margin:0;font-family:Arial,'Microsoft YaHei',sans-serif;color:#23384e;background:#f5f8fb}header{height:48px;display:flex;align-items:center;justify-content:space-between;padding:0 22px;background:#fff;border-bottom:1px solid #dce6ef}header b{font-size:16px}header span{font-size:12px;color:#5d7287}.business-summary,.public-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;padding:18px}.business-summary article,.public-grid article{padding:15px;background:#fff;border:1px solid #dce6ef}.business-summary small{display:block;color:#657b90}.business-summary strong{display:block;margin:8px 0;font-size:28px;color:#0a67b4}.business-summary span{font-size:12px;color:#667b8e}.business-list{margin:0 18px;padding:17px;background:#fff;border:1px solid #dce6ef}.business-list h3{margin:0 0 10px}.business-list p{display:flex;justify-content:space-between;padding:11px 0;margin:0;border-top:1px solid #e3ebf2}.business-list span{color:#60778c;font-size:12px}.public-hero{padding:32px 22px;background:#e7f1fa;border-bottom:1px solid #c9dce9}.public-hero p{margin:0;color:#0a67b4;font-size:12px}.public-hero h2{margin:7px 0;font-size:26px}.public-hero span{color:#5d7287}</style></head><body>${body}</body></html>`;
}

window.addEventListener("load", () => {
  webScreen = function webScreenWithApprovedTargets(external) {
    const targets = external
      ? [{ appId:"market-insights", name:"市场观察", url:"https://insights.example.com" }, { appId:"public-learning", name:"公开培训", url:"https://learn.example.com" }, { appId:"industry-news", name:"行业资讯", url:"https://news.example.com" }]
      : [{ appId:"ops-workflow", name:"运营协同", url:"https://ops.example.bank" }];
    title.textContent = external ? "在线网页" : "指定业务";
    subtitle.textContent = external ? "已批准网页配置 · 独立会话" : "运营协同系统 · 业务域受控";
    const render = (index = 0) => {
      const app = targets[index];
      stage.innerHTML = webFrame(app.name, "", targets, external, index);
      stage.querySelector(".embedded-frame").srcdoc = embeddedDocument(app, external);
      document.getElementById("web-refresh").addEventListener("click", () => showToast(`正在重新加载 ${app.name}`));
      const select = document.getElementById("web-target");
      if (select) select.addEventListener("change", () => { const next = Number(select.value); render(next); showToast(`已切换至${targets[next].name}`); });
    };
    render();
  };
});

window.addEventListener("load", () => {
  const previousMarketScreen = marketScreen;
  const boards = [
    { name:"上期所", rows:[["沪铜主力","78,620","+0.48%","+374","+2,240"],["沪金主连","772.60","+0.68%","+5.22","+1,318"],["螺纹主连","3,124","-0.31%","-10","-4,820"]] },
    { name:"郑商所", rows:[["烧碱主连","1,910","+2.36%","+44","+8,223"],["苹果主连","7,765","+1.38%","+106","-1,746"],["玻璃主连","910","+1.11%","+10","+3,918"]] },
    { name:"大商所", rows:[["豆粕主连","3,204","+0.47%","+15","-3,500"],["焦炭主连","1,857.5","+0.90%","+16.5","-397"],["PVC 主连","4,644","+0.35%","+16","+671"]] },
    { name:"能源化工", rows:[["轻质原油连续","90.780","-1.53%","-1.410","-13,210"],["布伦特原油连续","98.700","-1.99%","-1.990","-9,421"],["乙二醇主连","4,986","+1.26%","+62","+9,843"]] },
    { name:"金融期货", rows:[["十年国债主连","109.260","+0.02%","+0.020","-1,274"],["中证 500 主连","5,782.6","-1.28%","-75.0","+4,630"],["沪深 300 主连","4,578.2","-1.73%","-80.4","+7,100"]] },
    { name:"外盘期货", rows:[["纽约银连续","58.300","+0.76%","+0.442","-9,000"],["纽约金主连","4,055.7","+0.14%","+5.500","-18,870"],["美大豆主连","1,246.750","+0.75%","+9.250","+4,260"]] }
  ];
  window.renderFuturesScreen = function futuresSemanticScreen(name, detail) {
    if (name !== "期货观察") return previousMarketScreen(name, detail);
    title.textContent = "期货观察";
    subtitle.textContent = "交易所与品类监测 · 非交易界面";
    let selected = { name:"沪铜主力", price:"78,620", change:"+0.48%", field:"上期所" };
    const render = () => {
      stage.innerHTML = `<section class="futures-workbench"><div class="futures-nav"><button class="active" type="button">综合屏</button><button type="button">期货</button><button type="button">期权</button><button type="button">热点商品</button><span>行情状态：6 个分组已载入</span></div><div class="futures-board-grid">${boards.map(board => `<section><header><h2>${board.name}</h2><span>查看全部</span></header><table><thead><tr><th>合约</th><th>最新</th><th>涨幅%</th><th>涨跌</th><th>日增仓</th></tr></thead><tbody>${board.rows.map((row, index) => `<tr data-futures="${board.name}|${row.join("|")}" class="${row[0] === selected.name ? "selected" : ""}"><td>${row[0]}</td><td>${row[1]}</td><td class="${tone(row[2])}">${row[2]}</td><td class="${tone(row[2])}">${row[3]}</td><td class="${row[4].startsWith("+") ? "positive" : "negative"}">${row[4]}</td></tr>`).join("")}</tbody></table></section>`).join("")}</div><div class="futures-detail-row"><section class="futures-news"><h3>期市要闻</h3><p><time>10:25</time> 能源品种波动收敛，关注库存与运力数据</p><p><time>10:17</time> 金属板块交投活跃，日增仓变化扩大</p><p><time>09:59</time> 利率期货维持窄幅整理</p></section><section class="futures-chart"><header><div><small>${selected.field}</small><h3>${selected.name} <b class="${tone(selected.change)}">${selected.price} ${selected.change}</b></h3></div>${window.skyChart.toolbar(["分时", "日 K", "周 K"])}</header><div class="chart-canvas futures-kline"></div></section><section class="futures-related"><h3>关联品种</h3><p><span>沪铝主连</span><b class="positive">+0.67%</b></p><p><span>氧化铝主连</span><b class="positive">+0.66%</b></p><p><span>国际铜主连</span><b class="negative">-0.21%</b></p></section></div></section>`;
      window.skyChart.bind(stage.querySelector(".futures-chart"), stage.querySelector(".futures-kline"), { profile:"futures", period:"日 K", zoom:1, offset:0 }, true);
      stage.querySelectorAll("[data-futures]").forEach(row => row.addEventListener("click", () => { const [field, contract, price, change] = row.dataset.futures.split("|"); selected = { field, name:contract, price, change }; render(); }));
    };
    render();
  };
});

window.addEventListener("load", () => {
  const profiles = {
    bank: { base: 4311, volatility: 31, drift: -0.72, phase: 0.7, label: "中证银行" },
    domestic: { base: 3821, volatility: 28, drift: -0.38, phase: 1.9, label: "沪深 300" },
    global: { base: 17862, volatility: 132, drift: 2.4, phase: 3.2, label: "恒生指数" },
    futures: { base: 786, volatility: 11, drift: 0.28, phase: 4.6, label: "沪铜主力" },
    native: { base: 3821, volatility: 18, drift: 0.12, phase: 5.8, label: "沪深 300" },
    stock: { base: 11.24, volatility: 0.17, drift: -0.003, phase: 1.2, label: "平安银行" },
    growth: { base: 186.82, volatility: 4.7, drift: 0.08, phase: 2.7, label: "宁德时代" },
    telecom: { base: 108.34, volatility: 1.6, drift: 0.02, phase: 4.1, label: "中国移动" },
    tech: { base: 982.61, volatility: 19, drift: -0.11, phase: 5.1, label: "科创 50" },
    gold: { base: 6.413, volatility: 0.09, drift: 0.002, phase: 0.2, label: "黄金 ETF" },
    sh: { base: 3814.20, volatility: 27, drift: -0.21, phase: 2.4, label: "上证指数" },
    sz: { base: 13774.68, volatility: 126, drift: -0.74, phase: 3.4, label: "深证成指" },
    chiNext: { base: 3480.87, volatility: 54, drift: -0.34, phase: 1.1, label: "创业板指" },
    dji: { base: 51747.25, volatility: 520, drift: 3.2, phase: 5.4, label: "道琼斯工业指数" },
    spx: { base: 7411.98, volatility: 76, drift: .64, phase: 4.4, label: "标普 500" },
    ixic: { base: 24975.82, volatility: 260, drift: -1.1, phase: 2.8, label: "纳斯达克综合指数" },
    nikkei: { base: 39786.12, volatility: 340, drift: .92, phase: .5, label: "日经 225" },
    ftse: { base: 8620.31, volatility: 88, drift: -.26, phase: 3.1, label: "富时 100" },
    goldSpot: { base: 772.60, volatility: 5.8, drift: 0.06, phase: 3.8, label: "Au9999 基准金价" }
  };
  const periodSettings = {
    "分时": { points: 96, scale: 0.31, unit: "分", start: "09:30", end: "15:00" },
    "日 K": { points: 100, scale: 1, unit: "日", start: "04-08", end: "07-26" },
    "周 K": { points: 72, scale: 2.9, unit: "周", start: "2025-03", end: "2026-07" },
    "月 K": { points: 60, scale: 7.4, unit: "月", start: "2021-08", end: "2026-07" }
  };

  function seriesFor(profileKey, period) {
    const profile = profiles[profileKey];
    const setting = periodSettings[period];
    const values = [];
    let previous = profile.base - profile.volatility * 1.8;
    for (let index = 0; index < setting.points; index += 1) {
      const seasonal = Math.sin(index * 0.39 + profile.phase) * profile.volatility * 0.62;
      const pulse = Math.cos(index * 0.17 + profile.phase * 1.7) * profile.volatility * 0.31;
      const impulse = (index % 17 === 0 ? profile.volatility * 0.9 : 0) - (index % 23 === 0 ? profile.volatility * 0.72 : 0);
      const open = previous + Math.sin(index * 0.63 + profile.phase) * profile.volatility * 0.18 * setting.scale;
      const close = open + (seasonal + pulse + impulse + profile.drift * index) * 0.19 * setting.scale;
      const spread = (profile.volatility * (0.33 + Math.abs(Math.sin(index * 0.51 + profile.phase)) * 0.48)) * setting.scale;
      const high = Math.max(open, close) + spread;
      const low = Math.min(open, close) - spread * 0.92;
      const volume = 36 + Math.round(Math.abs(close - open) / Math.max(1, profile.volatility * setting.scale) * 74 + Math.abs(Math.sin(index * 0.27 + profile.phase)) * 44);
      values.push({ open, high, low, close, volume });
      previous = close;
    }
    const latestOffset = profile.base - values[values.length - 1].close;
    return values.map(item => ({ ...item, open: item.open + latestOffset, high: item.high + latestOffset, low: item.low + latestOffset, close: item.close + latestOffset }));
  }

  function formatPrice(value) {
    return value >= 1000 ? value.toLocaleString("zh-CN", { maximumFractionDigits: 1 }) : value.toFixed(2);
  }

  function klineMarkup(model, compact = false) {
    const setting = periodSettings[model.period];
    const all = seriesFor(model.profile, model.period);
    const visibleCount = Math.max(compact ? 18 : 24, Math.floor(all.length / model.zoom));
    const maxOffset = Math.max(0, all.length - visibleCount);
    model.offset = Math.max(0, Math.min(model.offset, maxOffset));
    const end = all.length - model.offset;
    const candles = all.slice(Math.max(0, end - visibleCount), end);
    const width = compact ? 382 : 760;
    const height = compact ? 220 : 450;
    const left = compact ? 38 : 48;
    const right = 35;
    const priceTop = 24;
    const priceBottom = compact ? 130 : 286;
    const volumeTop = priceBottom + 18;
    const volumeBottom = compact ? 176 : 354;
    const indicatorTop = volumeBottom + 18;
    const indicatorBottom = height - 29;
    const high = Math.max(...candles.map(item => item.high));
    const low = Math.min(...candles.map(item => item.low));
    const padding = Math.max((high - low) * 0.11, 1);
    const upper = high + padding;
    const lower = low - padding;
    const y = value => priceTop + (upper - value) / (upper - lower) * (priceBottom - priceTop);
    const xStep = (width - left - right) / candles.length;
    const bodyWidth = Math.max(2.5, xStep * 0.58);
    const maxVolume = Math.max(...candles.map(item => item.volume));
    const movingAverage = (size, index) => candles.slice(Math.max(0, index - size + 1), index + 1).reduce((sum, item) => sum + item.close, 0) / Math.min(size, index + 1);
    const ma5 = candles.map((item, index) => `${index ? "L" : "M"}${left + index * xStep + xStep / 2},${y(movingAverage(5, index))}`).join(" ");
    const ma10 = candles.map((item, index) => `${index ? "L" : "M"}${left + index * xStep + xStep / 2},${y(movingAverage(10, index))}`).join(" ");
    const priceGrid = Array.from({ length: 5 }, (_, index) => lower + (upper - lower) * index / 4).map(value => `<line x1="${left}" x2="${width - right}" y1="${y(value)}" y2="${y(value)}"/><text x="4" y="${y(value) + 4}">${formatPrice(value)}</text>`).join("");
    const shapes = candles.map((item, index) => {
      const x = left + index * xStep + (xStep - bodyWidth) / 2;
      const cx = x + bodyWidth / 2;
      const up = item.close >= item.open;
      const top = Math.min(y(item.open), y(item.close));
      const bodyHeight = Math.max(1.5, Math.abs(y(item.open) - y(item.close)));
      const volumeHeight = item.volume / maxVolume * (volumeBottom - volumeTop);
      const macdValue = ((item.close - movingAverage(6, index)) / Math.max(1, upper - lower)) * 140;
      const macdY = Math.max(indicatorTop, Math.min(indicatorBottom, (indicatorTop + indicatorBottom) / 2 - macdValue));
      return `<g class="candle ${up ? "up" : "down"}"><line x1="${cx}" y1="${y(item.high)}" x2="${cx}" y2="${y(item.low)}"/><rect x="${x}" y="${top}" width="${bodyWidth}" height="${bodyHeight}"/><rect class="volume" x="${x}" y="${volumeBottom - volumeHeight}" width="${bodyWidth}" height="${volumeHeight}"/><rect class="macd-bar" x="${x}" y="${Math.min((indicatorTop + indicatorBottom) / 2, macdY)}" width="${bodyWidth}" height="${Math.abs((indicatorTop + indicatorBottom) / 2 - macdY)}"/></g>`;
    }).join("");
    const dateLabels = `<text x="${left}" y="${height - 8}">${setting.start}</text><text x="${width - right - 34}" y="${height - 8}">${setting.end}</text>`;
    const rangeLabel = model.zoom > 1 || model.offset > 0 ? `已查看 ${candles.length}/${all.length} 根` : `${setting.unit}线 ${candles.length} 根`;
    return `<svg class="kline-svg" viewBox="0 0 ${width} ${height}" role="img" tabindex="0" aria-label="${profiles[model.profile].label}${model.period} K 线图，可使用滚轮缩放、拖拽平移查看历史数据"><title>${profiles[model.profile].label} ${model.period} · ${rangeLabel}</title><g class="chart-grid">${priceGrid}<line x1="${left}" x2="${width - right}" y1="${volumeTop - 7}" y2="${volumeTop - 7}"/><line x1="${left}" x2="${width - right}" y1="${indicatorTop - 7}" y2="${indicatorTop - 7}"/><line x1="${left}" x2="${width - right}" y1="${(indicatorTop + indicatorBottom) / 2}" y2="${(indicatorTop + indicatorBottom) / 2}"/></g><path class="ma-line ma5" d="${ma5}"/><path class="ma-line ma10" d="${ma10}"/>${shapes}<text x="${left}" y="${volumeTop - 10}">成交量</text><text x="${left}" y="${indicatorTop - 10}">MACD</text><text class="chart-range" x="${width - right - 100}" y="16">${rangeLabel}</text>${dateLabels}</svg>`;
  }

  function bindChart(host, model, compact = false) {
    const render = () => { host.innerHTML = klineMarkup(model, compact); };
    render();
    const svg = host.querySelector(".kline-svg");
    let startX = 0;
    let startOffset = 0;
    svg.addEventListener("wheel", event => {
      event.preventDefault();
      model.zoom = Math.max(1, Math.min(4, Number((model.zoom + (event.deltaY < 0 ? 0.25 : -0.25)).toFixed(2))));
      render();
      bindChart(host, model, compact);
    }, { passive: false });
    svg.addEventListener("pointerdown", event => { startX = event.clientX; startOffset = model.offset; svg.setPointerCapture(event.pointerId); });
    svg.addEventListener("pointerup", event => {
      const all = seriesFor(model.profile, model.period);
      const visibleCount = Math.max(compact ? 18 : 24, Math.floor(all.length / model.zoom));
      const movement = Math.round((startX - event.clientX) / Math.max(4, svg.clientWidth / visibleCount));
      model.offset = Math.max(0, Math.min(all.length - visibleCount, startOffset + movement));
      if (Math.abs(movement) > 0) { render(); bindChart(host, model, compact); }
    });
    return render;
  }

  function bindChartControls(root, host, model, compact = false) {
    const render = () => bindChart(host, model, compact);
    root.querySelectorAll("[data-period]").forEach(button => button.addEventListener("click", () => {
      model.period = button.dataset.period;
      model.zoom = 1;
      model.offset = 0;
      root.querySelectorAll("[data-period]").forEach(item => item.classList.toggle("active", item === button));
      render();
      showToast(`已切换至${model.period}`);
    }));
    root.querySelectorAll("[data-zoom]").forEach(button => button.addEventListener("click", () => {
      const action = button.dataset.zoom;
      model.zoom = action === "reset" ? 1 : Math.max(1, Math.min(4, Number((model.zoom + (action === "in" ? 0.5 : -0.5)).toFixed(2))));
      if (action === "reset") model.offset = 0;
      render();
      showToast(action === "reset" ? "已重置图表视图" : action === "in" ? "已放大图表" : "已缩小图表");
    }));
    render();
  }

  function chartToolbar(periods) {
    return `<div class="chart-controls"><div class="segmented" aria-label="K 线周期">${periods.map((period, index) => `<button type="button" data-period="${period}" class="${index === 1 ? "active" : ""}">${period}</button>`).join("")}</div><div class="chart-zoom" aria-label="图表缩放"><button type="button" data-zoom="out" title="缩小图表">−</button><button type="button" data-zoom="in" title="放大图表">+</button><button type="button" data-zoom="reset">重置</button></div></div>`;
  }

  klineSvg = function klineSvgReplacement(model, compact = false) { return klineMarkup(typeof model === "object" ? model : { profile: "domestic", period: "日 K", zoom: 1, offset: 0 }, compact); };
  marketTable = function marketTableReplacement(titleText, chips, list = quotes, profile = "domestic") {
    return `<section class="console-layout"><section class="console-main"><div class="console-tabs">${chips.map((item, index) => `<button class="${index === 0 ? "active" : ""}">${item}</button>`).join("")}</div><div class="quote-table"><table><thead><tr><th>名称</th><th>最新价</th><th>涨跌幅</th><th>涨跌</th><th>成交额</th><th>分类</th></tr></thead><tbody>${tableRows(list)}</tbody></table></div><div class="news-dock"><div><h3>市场快讯</h3><p>10:22 银行板块成交活跃，资金流向保持分化</p><p>10:18 宽基指数窄幅震荡，关注量价匹配情况</p><p>10:12 全球主要市场进入交投活跃时段</p></div><div class="sector-mini"><h3>热点板块</h3><span>银行 <b class="positive">+0.36%</b></span><span>通信 <b class="negative">-0.71%</b></span><span>新能源 <b class="positive">+1.12%</b></span></div></div></section><aside class="console-side"><div class="side-quote"><p>${titleText} · 概览</p><h2>${formatPrice(profiles[profile].base)} <span class="negative">-0.42%</span></h2><small>领涨 12 · 领跌 23 · 平盘 8</small></div><div class="market-chart-widget">${chartToolbar(["分时", "日 K", "周 K"])}<div class="chart-canvas mini-kline"></div></div><div class="side-list"><h3>重点观察</h3><p>流动性保持平稳，行业表现分化</p><p>外盘期指进入活跃时段</p></div></aside></section>`;
  };
  function showMarketTable(titleText, chips, list, profile) {
    stage.innerHTML = marketTable(titleText, chips, list, profile);
    bindChartControls(stage.querySelector(".market-chart-widget"), stage.querySelector(".mini-kline"), { profile, period: "日 K", zoom: 1, offset: 0 }, true);
  }
  watchlistScreen = function watchlistScreenReplacement() { title.textContent = "自选"; subtitle.textContent = "默认关注 · 8 个标的"; showMarketTable("默认关注", ["默认关注", "银行", "宽基指数", "商品基金"], quotes, "bank"); };
  marketScreen = function marketScreenReplacement(name, detail) {
    title.textContent = name;
    subtitle.textContent = detail;
    if (name === "期货观察") {
      stage.innerHTML = `<section class="futures-screen"><div class="futures-top">${["综合屏", "上期所", "郑商所", "大商所"].map((item, index) => `<button class="${index === 0 ? "active" : ""}">${item}</button>`).join("")}</div><div class="futures-grid">${["上期所", "郑商所", "大商所", "能源化工", "金融期货", "外盘期货"].map((item, index) => `<article><h2>${item}</h2><table><thead><tr><th>合约</th><th>最新</th><th>涨跌幅</th></tr></thead><tbody>${quotes.slice(index % 3, index % 3 + 3).map(quote => `<tr><td>${quote.name}</td><td>${quote.price}</td><td class="${tone(quote.change)}">${quote.change}</td></tr>`).join("")}</tbody></table></article>`).join("")}</div><div class="futures-bottom"><section><h3>期市要闻</h3><p>能源品种波动收敛，关注库存与运力数据</p><p>利率期货维持窄幅整理</p></section><section class="market-chart-widget futures-kline">${chartToolbar(["分时", "日 K", "周 K"])}<div class="chart-canvas mini-kline"></div></section></div></section>`;
      bindChartControls(stage.querySelector(".futures-kline"), stage.querySelector(".mini-kline"), { profile: "futures", period: "日 K", zoom: 1, offset: 0 }, true);
      return;
    }
    const profile = name === "全球市场" ? "global" : "domestic";
    const groups = name === "全球市场" ? ["主要指数", "美洲", "欧洲", "亚太"] : ["重要指数", "A 股", "板块热点", "基金"];
    showMarketTable(name, groups, name === "全球市场" ? quotes.slice(2).concat(quotes.slice(0, 2)) : quotes, profile);
  };
  chartScreen = function chartScreenReplacement() {
    const model = { profile: "bank", period: "日 K", zoom: 1, offset: 0 };
    title.textContent = "个股研究";
    subtitle.textContent = "中证银行 · 399986";
    stage.innerHTML = `<section class="chart-console"><div class="quote-head"><div><h2>中证银行 <b class="negative">4,311.08 -0.42%</b></h2><p>开 4,327.80 · 高 4,346.15 · 低 4,302.42 · 成交额 54.8 亿</p></div>${chartToolbar(["分时", "日 K", "周 K", "月 K"])}</div><div class="chart-area"><div class="chart-canvas main-kline"></div><aside><h3>五档行情</h3>${[5, 4, 3, 2, 1].map(level => `<p>卖 ${level}<span>${(4311 + level * .2).toFixed(2)}</span><b>${120 + level * 38}</b></p>`).join("")}<hr>${[1, 2, 3, 4, 5].map(level => `<p>买 ${level}<span>${(4311 - level * .2).toFixed(2)}</span><b>${160 + level * 22}</b></p>`).join("")}</aside></div><div class="research-grid"><section><h3>关联资讯</h3><p>政策预期稳定，银行板块估值修复仍需观察量能</p><p>机构观点：高股息资产保持防御属性</p></section><section><h3>资金与指标</h3><p>主力净流入 <b class="positive">+1.26 亿</b></p><p>滚轮缩放，拖拽图表可查看历史区间</p></section></div></section>`;
    bindChartControls(stage, stage.querySelector(".main-kline"), model);
  };
  nativeMarketScreen = function nativeMarketScreenReplacement() {
    const model = { profile: "native", period: "日 K", zoom: 1, offset: 0 };
    title.textContent = "原生行情中心";
    subtitle.textContent = "Qt 原生渲染 · 本地高刷新数据";
    stage.innerHTML = `<section class="chart-console native-market"><div class="native-ribbon"><span>Qt 原生图表</span><span><i class="dot dot-green"></i>行情流已连接</span><span>刷新间隔 1 秒</span><button type="button">暂停刷新</button></div><div class="quote-head"><div><h2>沪深 300 <b class="negative">3,821.40 -0.42%</b></h2><p>本地渲染 · 可缩放 · 可平移 · 多指标叠加</p></div>${chartToolbar(["分时", "日 K", "周 K", "月 K"])}</div><div class="chart-area native-chart"><div class="chart-canvas main-kline"></div><aside><h3>当前蜡烛</h3><p>时间<span>14:55</span></p><p>开盘<span>3,824.0</span></p><p>最高<span>3,840.2</span></p><p>最低<span>3,812.4</span></p><p>收盘<span>3,821.4</span></p><hr><h3>指标</h3><p>MA5 <span>3,830.5</span></p><p>MA10 <span>3,842.1</span></p></aside></div></section>`;
    bindChartControls(stage, stage.querySelector(".main-kline"), model);
  };
  window.skyChart = { bind: bindChartControls, toolbar: chartToolbar, price: formatPrice };
});

window.addEventListener("load", () => {
  const previousMarketScreen = marketScreen;
  const profileFor = quote => ({
    "000001": "stock",
    "399986": "bank",
    "000300": "domestic",
    "000016": "domestic",
    "300750": "growth",
    "600941": "telecom",
    "000688": "tech",
    "518880": "gold"
  })[quote.code] || "domestic";
  const tableRowsForWatchlist = list => list.map((quote, index) => `<tr data-quote-index="${index}"><td>${index + 1}</td><td>${quote.code}</td><td>${quote.name}</td><td>${quote.price}</td><td class="${tone(quote.change)}">${quote.change}</td><td class="${tone(quote.change)}">${quote.change.startsWith("+") ? "+" : "-"}${(index * 1.73 + .26).toFixed(2)}</td><td class="${index % 3 === 0 ? "negative" : "positive"}">${index % 3 === 0 ? "-" : "+"}${(index * .42 + .18).toFixed(2)} 亿</td><td>${(1.07 + index * .31).toFixed(2)}</td></tr>`).join("");

  marketTable = function linkedMarketTable(titleText, chips, list = quotes) {
    return `<section class="linked-market-layout"><section class="linked-market-main"><div class="console-tabs">${chips.map((item, index) => `<button class="${index === 0 ? "active" : ""}">${item}</button>`).join("")}</div><div class="market-table-wrap"><table class="market-scan-table"><thead><tr><th>#</th><th>代码</th><th>名称</th><th>现价</th><th>涨幅%</th><th>涨跌</th><th>主力净流入</th><th>换手%</th></tr></thead><tbody>${tableRowsForWatchlist(list)}</tbody></table></div><div class="market-news-strip"><section><h3>市场快讯</h3><p>10:22 银行板块成交活跃，资金流向保持分化</p><p>10:18 宽基指数窄幅震荡，关注量价匹配情况</p></section><section><h3>异动提醒</h3><p>开盘后量能放大标的 3 个</p><p>北向相关资金维持净流出</p></section></div></section><aside class="market-detail-pane" aria-label="当前标的详情"></aside></section>`;
  };

  function bindMarketDetail(list, defaultIndex = 0) {
    const pane = stage.querySelector(".market-detail-pane");
    const rows = stage.querySelectorAll("[data-quote-index]");
    const showDetail = index => {
      const quote = list[index];
      const profile = profileFor(quote);
      rows.forEach(row => row.classList.toggle("selected", Number(row.dataset.quoteIndex) === index));
      pane.innerHTML = `<div class="detail-quote-head"><div><small>${quote.code} · ${quote.category}</small><h2>${quote.name}</h2></div><div><strong>${quote.price}</strong><b class="${tone(quote.change)}">${quote.change}</b></div></div><section class="intraday-panel"><header><h3>盘中走势</h3><span>分时 · 均价 · 量能</span></header>${klineSvg({ profile, period: "分时", zoom: 1, offset: 0 }, true)}</section><section class="detail-kline-panel"><header><h3>区间走势</h3>${window.skyChart.toolbar(["日 K", "周 K", "月 K"])}</header><div class="chart-canvas detail-kline"></div></section><section class="hot-sector-panel"><h3>关联板块</h3><div><span>银行</span><b class="positive">+0.36%</b><span>高股息</span><b class="negative">-0.18%</b></div><p>行情与资讯围绕当前选中标的切换</p></section>`;
      window.skyChart.bind(pane.querySelector(".detail-kline-panel"), pane.querySelector(".detail-kline"), { profile, period: "日 K", zoom: 1, offset: 0 }, true);
    };
    rows.forEach(row => row.addEventListener("click", () => showDetail(Number(row.dataset.quoteIndex))));
    showDetail(defaultIndex);
  }

  function renderLinkedMarket(titleText, chips, list, selectedIndex = 0) {
    stage.innerHTML = marketTable(titleText, chips, list);
    bindMarketDetail(list, selectedIndex);
  }

  watchlistScreen = function watchlistScreenLinked() {
    title.textContent = "自选";
    subtitle.textContent = "默认关注 · 8 个标的 · 选中行联动详情";
    renderLinkedMarket("默认关注", ["默认关注", "银行", "宽基指数", "商品基金"], quotes);
  };

  marketScreen = function marketScreenLinked(name, detail) {
    if (name === "期货观察") return previousMarketScreen(name, detail);
    title.textContent = name;
    subtitle.textContent = detail;
    const list = name === "全球市场" ? quotes.slice(2).concat(quotes.slice(0, 2)) : quotes;
    const chips = name === "全球市场" ? ["主要指数", "美洲", "欧洲", "亚太"] : ["重要指数", "A 股", "板块热点", "基金"];
    renderLinkedMarket(name, chips, list, name === "全球市场" ? 2 : 1);
  };
});

window.addEventListener("load", () => {
  const previousMarketScreen = marketScreen;
  const domesticMarkets = [
    { code:"1A0001", name:"上证指数", price:"3,814.20", change:"-1.61%", open:"3,853.63", high:"3,861.04", low:"3,808.64", status:"交易中", profile:"sh" },
    { code:"399001", name:"深证成指", price:"13,774.68", change:"-2.47%", open:"13,915.04", high:"14,061.35", low:"13,774.68", status:"交易中", profile:"sz" },
    { code:"399006", name:"创业板指", price:"3,480.87", change:"-2.65%", open:"3,515.50", high:"3,561.35", low:"3,480.87", status:"交易中", profile:"chiNext" },
    { code:"000300", name:"沪深 300", price:"3,821.40", change:"-0.42%", open:"3,842.10", high:"3,865.21", low:"3,813.52", status:"交易中", profile:"domestic" },
    { code:"000016", name:"上证 50", price:"2,731.55", change:"+0.18%", open:"2,720.18", high:"2,740.92", low:"2,711.40", status:"交易中", profile:"domestic" }
  ];
  const globalMarkets = [
    { code:"DJI", name:"道琼斯工业指数", price:"51,747.25", change:"+0.46%", open:"51,791.37", high:"52,118.19", low:"51,682.36", status:"美洲 · 已收盘", profile:"dji" },
    { code:"SPX", name:"标普 500 指数", price:"7,411.98", change:"+0.05%", open:"7,406.30", high:"7,460.98", low:"7,396.53", status:"美洲 · 已收盘", profile:"spx" },
    { code:"IXIC", name:"纳斯达克综合指数", price:"24,975.82", change:"-0.64%", open:"25,107.34", high:"25,222.14", low:"24,918.09", status:"美洲 · 已收盘", profile:"ixic" },
    { code:"N225", name:"日经 225", price:"39,786.12", change:"+0.31%", open:"39,620.44", high:"39,924.11", low:"39,548.37", status:"亚太 · 交易中", profile:"nikkei" },
    { code:"FTSE", name:"富时 100", price:"8,620.31", change:"-0.18%", open:"8,640.82", high:"8,668.54", low:"8,609.48", status:"欧洲 · 交易中", profile:"ftse" }
  ];
  marketScreen = function marketScreenOverview(name, detail) {
    if (name === "期货观察") return previousMarketScreen(name, detail);
    const isGlobal = name === "全球市场";
    const list = isGlobal ? globalMarkets : domesticMarkets;
    const tabs = isGlobal ? ["主要指数", "美洲", "欧洲", "亚太"] : ["重要指数", "A 股", "板块热点", "基金"];
    title.textContent = name;
    subtitle.textContent = detail;
    stage.innerHTML = `<section class="market-overview"><section class="market-overview-main"><div class="market-type-tabs">${tabs.map((tab, index) => `<button type="button" class="${index === 0 ? "active" : ""}">${tab}</button>`).join("")}<span>${isGlobal ? "时区状态已载入" : "国内市场状态已载入"}</span></div><div class="market-status-grid"><span><b>${isGlobal ? "3" : "5"}</b> 个市场可观察</span><span><b>${isGlobal ? "2" : "0"}</b> 个交易中</span><span><b>10:24:18</b> 最近状态</span></div><div class="market-overview-table"><table><thead><tr><th>代码</th><th>名称</th><th>现价</th><th>涨跌幅</th><th>开盘</th><th>最高</th><th>最低</th><th>交易状态</th></tr></thead><tbody>${list.map((item, index) => `<tr data-market-index="${index}"><td>${item.code}</td><td>${item.name}</td><td>${item.price}</td><td class="${tone(item.change)}">${item.change}</td><td>${item.open}</td><td>${item.high}</td><td>${item.low}</td><td><span class="market-status">${item.status}</span></td></tr>`).join("")}</tbody></table></div><footer><span>${isGlobal ? "时区与交易日状态为演示信息" : "当前指数按市场分类展示"}</span><span>点击行查看详情</span></footer></section><aside class="market-overview-detail"></aside></section>`;
    const pane = stage.querySelector(".market-overview-detail");
    const rows = stage.querySelectorAll("[data-market-index]");
    const setCurrent = index => {
      const item = list[index];
      rows.forEach(row => row.classList.toggle("selected", Number(row.dataset.marketIndex) === index));
      pane.innerHTML = `<div class="market-detail-head"><small>${item.code} · ${item.status}</small><h2>${item.name}</h2><div><strong>${item.price}</strong><b class="${tone(item.change)}">${item.change}</b></div></div><section class="market-detail-chart"><header><h3>${isGlobal ? "跨时区走势" : "指数走势"}</h3>${window.skyChart.toolbar(["分时", "日 K", "周 K", "月 K"])}</header><div class="chart-canvas market-main-kline"></div></section><section class="market-detail-facts"><h3>当日区间</h3><dl><div><dt>开盘</dt><dd>${item.open}</dd></div><div><dt>最高</dt><dd>${item.high}</dd></div><div><dt>最低</dt><dd>${item.low}</dd></div><div><dt>状态</dt><dd>${item.status}</dd></div></dl></section><section class="market-related"><h3>相关指数</h3>${list.filter((_, itemIndex) => itemIndex !== index).slice(0, 3).map(related => `<p><span>${related.name}</span><b class="${tone(related.change)}">${related.change}</b></p>`).join("")}</section>`;
      window.skyChart.bind(pane.querySelector(".market-detail-chart"), pane.querySelector(".market-main-kline"), { profile:item.profile, period:"日 K", zoom:1, offset:0 }, true);
    };
    rows.forEach(row => row.addEventListener("click", () => setCurrent(Number(row.dataset.marketIndex))));
    setCurrent(isGlobal ? 1 : 0);
  };
});
const watchlistMarkup = stage.innerHTML;
window.addEventListener("load", () => {
  const researchProfiles = { "000001": "stock", "399986": "bank", "000300": "domestic", "000016": "domestic", "300750": "growth", "600941": "telecom", "000688": "tech", "518880": "gold" };
  const researchSet = [quotes[0], quotes[1], quotes[2], quotes[4], quotes[5]];

  chartScreen = function chartScreenResearchWorkbench() {
    let currentIndex = 1;
    const render = () => {
      const quote = researchSet[currentIndex];
      const profile = researchProfiles[quote.code];
      title.textContent = "个股研究";
      subtitle.textContent = `${quote.name} · ${quote.code} · 研究工作台`;
      stage.innerHTML = `<section class="research-workbench"><aside class="research-watchlist"><header><h2>研究对象</h2><button type="button" title="管理自选">⋯</button></header><div class="research-watch-rows">${researchSet.map((item, index) => `<button type="button" data-research-index="${index}" class="${index === currentIndex ? "active" : ""}"><span><b>${item.name}</b><small>${item.code}</small></span><span class="${tone(item.change)}"><i>${item.change}</i><strong>${item.price}</strong></span></button>`).join("")}</div><footer><span>已添加 5 个研究对象</span><button type="button">管理列表</button></footer></aside><section class="research-center"><div class="research-quote-head"><div><p>${quote.code} · ${quote.category}</p><h2>${quote.name} <b class="${tone(quote.change)}">${quote.price} ${quote.change}</b></h2><span>开 ${quote.price} · 高 ${quote.price} · 低 ${quote.price} · 成交额 ${quote.amount}</span></div>${window.skyChart.toolbar(["分时", "日 K", "周 K", "月 K"])}</div><div class="research-main-chart"><div class="chart-canvas research-kline"></div></div><div class="research-bottom"><section class="fund-flow"><header><h3>资金与指标</h3><span>近 5 日</span></header><dl><div><dt>主力净流入</dt><dd class="positive">+1.26 亿</dd></div><div><dt>大单净额</dt><dd class="negative">-0.38 亿</dd></div><div><dt>量比</dt><dd>1.18</dd></div><div><dt>换手率</dt><dd>2.31%</dd></div></dl><div class="fund-bars" aria-label="五日资金流柱状图"><i></i><i></i><i></i><i></i><i></i></div></section><section class="research-news"><header><h3>关联资讯</h3><button type="button">全部资讯</button></header><p><time>10:22</time> 行业资金流向保持分化，关注估值与量能匹配</p><p><time>10:11</time> 机构观点更新，防御属性与高股息逻辑仍待验证</p><p><time>09:56</time> 市场观察：跨市场波动对相关板块的影响</p></section></div></section><aside class="research-context"><section class="order-book"><header><h3>五档行情</h3><span>延时状态</span></header>${[5,4,3,2,1].map(level => `<p><label>卖 ${level}</label><b>${Number(quote.price.replace(/,/g, "")) + level * .02}</b><span>${120 + level * 36}</span></p>`).join("")}<hr>${[1,2,3,4,5].map(level => `<p><label>买 ${level}</label><b>${Number(quote.price.replace(/,/g, "")) - level * .02}</b><span>${160 + level * 24}</span></p>`).join("")}</section><section class="research-events"><header><h3>异动详情</h3><span class="pill">正常</span></header><p><time>10:18</time> 成交量较前 30 分钟提升</p><p><time>09:48</time> 价格进入日内波动区间</p></section><section class="research-sectors"><header><h3>关联板块</h3><button type="button">查看</button></header><p><span>银行</span><b class="positive">+0.36%</b></p><p><span>高股息</span><b class="negative">-0.18%</b></p><p><span>沪深 300</span><b class="negative">-0.42%</b></p></section></aside></section>`;
      window.skyChart.bind(stage.querySelector(".research-center"), stage.querySelector(".research-kline"), { profile, period: "日 K", zoom: 1, offset: 0 });
      stage.querySelectorAll("[data-research-index]").forEach(button => button.addEventListener("click", () => { currentIndex = Number(button.dataset.researchIndex); render(); }));
    };
    render();
  };
});
const labels = { dashboard: "工作台", watchlist: "自选", stock: "个股研究", market: "市场行情", global: "全球市场", futures: "期货观察", gold: "黄金业务", web: "指定业务", external: "在线网页", network: "网络验证", nativeMarket: "原生行情中心", native: "本机应用集成" };

window.addEventListener("load", () => {
  const formatResearchPrice = value => Number(value).toLocaleString("zh-CN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const normalizeResearchNumbers = () => {
    const active = stage.querySelector(".research-watch-rows button.active strong");
    if (!active) return;
    const base = Number(active.textContent.replace(/,/g, ""));
    if (!Number.isFinite(base)) return;
    const tick = base >= 1000 ? 8.36 : base >= 100 ? .76 : .08;
    const meta = stage.querySelector(".research-quote-head > div > span");
    const nextMeta = `开 ${formatResearchPrice(base + tick * .16)} · 高 ${formatResearchPrice(base + tick)} · 低 ${formatResearchPrice(base - tick * .82)} · 成交额 54.8 亿`;
    if (meta && meta.textContent !== nextMeta) meta.textContent = nextMeta;
    stage.querySelectorAll(".order-book p").forEach((row, index) => {
      const price = index < 5 ? base + (5 - index) * tick / 20 : base - (index - 4) * tick / 20;
      const value = formatResearchPrice(price);
      const cell = row.querySelector("b");
      if (cell && cell.textContent !== value) cell.textContent = value;
    });
  };
  new MutationObserver(normalizeResearchNumbers).observe(stage, { childList: true, subtree: true });
  normalizeResearchNumbers();
});

window.addEventListener("load", () => {
  const marketScreenWithoutFutures = marketScreen;
  marketScreen = function finalMarketScreen(name, detail) {
    return name === "期货观察" ? window.renderFuturesScreen(name, detail) : marketScreenWithoutFutures(name, detail);
  };
});

function tone(value) { return value.startsWith("+") ? "positive" : "negative"; }
function showToast(message) { toast.textContent = message; toast.classList.add("show"); window.clearTimeout(showToast.timer); showToast.timer = window.setTimeout(() => toast.classList.remove("show"), 2200); }
function renderQuotes(list = quotes) {
  quoteBody.innerHTML = list.map((item, index) => `<tr data-index="${index}" class="${index === selected ? "selected" : ""}"><td>${item.name}<span class="code">${item.code}</span></td><td>${item.price}</td><td class="${tone(item.change)}">${item.change}</td><td class="${tone(item.change)}">${item.change.startsWith("+") ? "+" : "-"}${index ? "8.12" : "0.04"}</td><td>${item.amount}</td><td>${item.category}</td></tr>`).join("");
  quoteBody.querySelectorAll("tr").forEach(row => row.addEventListener("click", () => selectQuote(Number(row.dataset.index))));
}
function selectQuote(index) {
  selected = index; const item = quotes[index]; renderQuotes();
  document.getElementById("instrument-code").textContent = item.code;
  document.getElementById("instrument-name").textContent = item.name;
  document.getElementById("instrument-price").textContent = item.price;
  const change = document.getElementById("instrument-change"); change.textContent = item.change; change.className = tone(item.change);
  document.getElementById("sparkline-path").setAttribute("d", index % 2 ? "M0,45 C28,59 43,30 68,44 S114,78 139,56 S190,27 215,44 S265,62 300,27" : "M0,61 C25,51 42,78 68,60 S110,30 137,46 S182,76 204,52 S258,20 300,39");
}
function marketScreen(name, detail) {
  title.textContent = name; subtitle.textContent = detail;
  stage.innerHTML = `<section class="market-workspace"><div class="data-pane"><div class="table-header-line"><span>${detail}</span><button type="button" class="plain-button">切换分类</button></div><div class="table-wrap"><table><thead><tr><th>名称</th><th>最新价</th><th>涨跌幅</th><th>涨跌额</th><th>成交额</th><th>市场状态</th></tr></thead><tbody>${quotes.slice(1).map((q,i)=>`<tr><td>${q.name}<span class="code">${q.code}</span></td><td>${q.price}</td><td class="${tone(q.change)}">${q.change}</td><td class="${tone(q.change)}">${q.change.startsWith("+")?"+":"-"}${(i+2.31).toFixed(2)}</td><td>${q.amount}</td><td>连续更新</td></tr>`).join("")}</tbody></table></div><div class="table-footnote"><span>数据每 5 秒更新一次</span><span>点击任意行查看详情</span></div></div><aside class="detail-pane"><div class="detail-heading"><span>市场摘要</span><button class="icon-button">•••</button></div><div class="instrument"><p>市场状态</p><h1>${name}</h1><div><strong>6 / 8</strong><span class="positive">上涨标的</span></div></div><div class="detail-section"><h2>观察提示</h2><a href="#">关注开盘后的量价同步变化</a><a href="#">行业指数分化扩大</a><a href="#">外盘市场进入活跃时段</a></div></aside></section>`;
}
function chartScreen() {
  title.textContent = "个股研究"; subtitle.textContent = "中证银行 · 399986";
  stage.innerHTML = `<section class="chart-view"><div class="module-panel"><div class="module-heading"><div><h2>中证银行 <span class="negative">-0.42%</span></h2><p>3,821.40 · 开盘 3,842.10 · 最高 3,865.21 · 最低 3,813.52</p></div><div class="segmented">${["分时","日 K","周 K","月 K"].map((x,i)=>`<button class="${i===1?"active":""}">${x}</button>`).join("")}</div></div><div class="chart-grid"><span class="chart-caption">价格走势</span><i class="chart-line"></i><div class="chart-axis"><span>3,890</span><span>3,850</span><span>3,810</span><span>3,770</span></div></div></div></section>`;
  stage.querySelectorAll(".segmented button").forEach(button => button.addEventListener("click", () => { stage.querySelectorAll(".segmented button").forEach(b => b.classList.remove("active")); button.classList.add("active"); showToast(`已切换至${button.textContent}视图`); }));
}
function webScreen(external) {
  title.textContent = external ? "在线网页" : "指定业务"; subtitle.textContent = external ? "固定外部来源 · 独立会话" : "业务域 · 受控容器";
  stage.innerHTML = `<section class="web-view"><div class="browser-frame"><div class="browser-toolbar"><button title="后退">←</button><button title="前进">→</button><button title="刷新" id="web-refresh"><img src="assets/refresh-cw.svg" alt=""></button><span class="origin-label">${external ? "https://www.example.com" : "https://business.example.bank"}</span><span class="origin-state">● ${external ? "外部受控页面" : "来源已受控"}</span></div><div class="web-content"><div class="web-card"><h2>${external ? "外部服务展示页" : "指定业务系统"}</h2><p>${external ? "该页面使用独立会话，不共享内部业务登录状态，也不提供下载或本机能力。" : "此处承接已授权业务系统。页面导航、资源来源、下载和弹窗均受应用清单约束。"}</p><div class="service-list"><span>页面状态 <i>已加载</i></span><span>会话范围 <i>${external ? "独立" : "业务组"}</i></span><span>可用能力 <i>${external ? "无原生能力" : "按授权清单"}</i></span></div></div></div></div></section>`;
  document.getElementById("web-refresh").addEventListener("click", () => showToast("正在重新加载页面"));
}
function networkScreen() {
  title.textContent = "网络验证"; subtitle.textContent = "统一连接能力状态";
  const protocols = [["HTTP","服务请求","42 ms"],["HTTPS","安全服务请求","58 ms"],["SSE","事件流订阅","已连接"],["WebSocket","实时通道","已连接"]];
  stage.innerHTML = `<section class="network-view"><div class="network-grid">${protocols.map(([name,desc,value])=>`<article class="protocol-card"><header><h2>${name}</h2><span class="pill">连接正常</span></header><dl><dt>用途</dt><dd>${desc}</dd><dt>最近结果</dt><dd>${value}</dd><dt>最后检查</dt><dd>10:24:18</dd></dl><button type="button">重新检查</button></article>`).join("")}</div></section>`;
  stage.querySelectorAll(".protocol-card button").forEach(button => button.addEventListener("click", () => { button.textContent="检查中"; button.disabled=true; setTimeout(()=>{button.textContent="重新检查";button.disabled=false;showToast("连接检查完成")},650); }));
}
function nativeScreen() {
  title.textContent = "本机应用集成"; subtitle.textContent = "已批准工具 · 独立系统窗口";
  const cards = [["系统计算器","用于验证受控本机应用启动。","calculator.svg"],["终端工具","用于技术支持场景的固定工具入口。","monitor-up.svg"],["文档查看器","用于查看本地已批准文档。","database.svg"]];
  stage.innerHTML = `<section class="native-view"><div class="native-grid">${cards.map(([name,desc,icon])=>`<article class="native-card"><img src="assets/${icon}" alt=""><h2>${name}</h2><p>${desc}</p><button type="button">启动应用</button></article>`).join("")}</div></section>`;
  stage.querySelectorAll(".native-card button").forEach(button => button.addEventListener("click", () => {button.textContent="正在请求启动";button.disabled=true;setTimeout(()=>{button.textContent="启动应用";button.disabled=false;showToast("已请求启动，应用将在独立窗口打开")},650)}));
}
function goldScreen() {
  const banks = [
    { name:"中国银行", product:"积存金", buy:"772.60", sell:"776.60", spread:"4.00", change:"+0.68%", time:"10:24:18" },
    { name:"工商银行", product:"如意金", buy:"773.10", sell:"777.10", spread:"4.00", change:"+0.72%", time:"10:24:12" },
    { name:"建设银行", product:"建行金", buy:"772.80", sell:"776.80", spread:"4.00", change:"+0.65%", time:"10:24:05" },
    { name:"农业银行", product:"传世之宝", buy:"773.50", sell:"778.00", spread:"4.50", change:"+0.71%", time:"10:23:56" },
    { name:"交通银行", product:"沃德金", buy:"772.40", sell:"776.90", spread:"4.50", change:"+0.62%", time:"10:23:48" },
    { name:"招商银行", product:"招财金", buy:"774.20", sell:"778.20", spread:"4.00", change:"+0.76%", time:"10:23:37" }
  ];
  title.textContent = "黄金业务";
  subtitle.textContent = "银行贵金属报价查询 · 人民币元/克";
  stage.innerHTML = `<section class="gold-workspace"><section class="gold-main"><div class="gold-tabs"><button class="active" type="button">银行积存金</button><button type="button">实物金条</button><span>报价基准：Au9999</span><button class="gold-refresh" type="button">刷新报价</button></div><div class="gold-summary"><div><span>基准金价</span><strong>772.60</strong><b class="positive">+0.68%</b></div><div><span>银行最低买入价</span><strong>772.40</strong><b>交通银行</b></div><div><span>银行最高卖出价</span><strong>778.20</strong><b>招商银行</b></div><div><span>报价覆盖</span><strong>6 / 6</strong><b>更新正常</b></div></div><div class="gold-table-wrap"><table class="gold-table"><thead><tr><th>银行</th><th>产品</th><th>买入价</th><th>卖出价</th><th>点差</th><th>日内涨跌</th><th>最近报价</th></tr></thead><tbody>${banks.map((bank, index) => `<tr data-gold-index="${index}"><td>${bank.name}</td><td>${bank.product}</td><td>${bank.buy}</td><td>${bank.sell}</td><td>${bank.spread}</td><td class="${tone(bank.change)}">${bank.change}</td><td>${bank.time}</td></tr>`).join("")}</tbody></table></div><footer class="gold-footnote"><span>报价仅用于查询与对比；实际成交以银行渠道确认结果为准。</span><span>所有价格单位：人民币元/克</span></footer></section><aside class="gold-detail-pane"></aside></section>`;
  const detail = stage.querySelector(".gold-detail-pane");
  const rows = stage.querySelectorAll("[data-gold-index]");
  const showBank = index => {
    const bank = banks[index];
    rows.forEach(row => row.classList.toggle("selected", Number(row.dataset.goldIndex) === index));
    detail.innerHTML = `<div class="gold-detail-head"><small>${bank.product} · 人民币元/克</small><h2>${bank.name}</h2><div><strong>${bank.sell}</strong><b class="positive">${bank.change}</b></div></div><section class="gold-chart-panel"><header><h3>基准金价趋势</h3>${window.skyChart.toolbar(["分时", "日 K", "周 K", "月 K"])}</header><div class="chart-canvas gold-kline"></div></section><section class="gold-compare"><h3>当前报价</h3><dl><div><dt>买入价</dt><dd>${bank.buy}</dd></div><div><dt>卖出价</dt><dd>${bank.sell}</dd></div><div><dt>点差</dt><dd>${bank.spread}</dd></div><div><dt>最近报价</dt><dd>${bank.time}</dd></div></dl></section><section class="gold-news"><h3>黄金观察</h3><p>关注国际金价、人民币汇率与银行报价差变化</p><p>银行产品规则和交易时段以各机构公告为准</p></section>`;
    window.skyChart.bind(detail.querySelector(".gold-chart-panel"), detail.querySelector(".gold-kline"), { profile:"goldSpot", period:"日 K", zoom:1, offset:0 }, true);
  };
  rows.forEach(row => row.addEventListener("click", () => showBank(Number(row.dataset.goldIndex))));
  stage.querySelector(".gold-refresh").addEventListener("click", () => { showToast("已更新银行黄金报价时间"); });
  showBank(0);
}
function watchlistScreen() {
  title.textContent = "自选"; subtitle.textContent = "默认关注 · 8 个标的";
  stage.innerHTML = watchlistMarkup;
  renderQuotes();
}
function dashboardScreen() {
  title.textContent = "工作台"; subtitle.textContent = "常用任务与服务状态";
  stage.innerHTML = `<section class="native-view"><div class="module-panel"><div class="module-heading"><div><h2>我的工作</h2><p>从常用任务恢复当前工作上下文</p></div><span class="update-time">07 月 26 日 · 周日</span></div><div class="native-grid dashboard-grid"><article class="native-card"><img src="assets/eye.svg" alt=""><h2>自选</h2><p>8 个关注标的，行情订阅稳定。</p><button type="button" data-open="watchlist">打开自选</button></article><article class="native-card"><img src="assets/chart-candlestick.svg" alt=""><h2>个股研究</h2><p>中证银行 · 最近打开于 10:22。</p><button type="button" data-open="stock">继续研究</button></article><article class="native-card"><img src="assets/shield-check.svg" alt=""><h2>指定业务</h2><p>受控业务入口，来源策略已加载。</p><button type="button" data-open="web">进入业务</button></article></div></div></section>`;
  stage.querySelectorAll("[data-open]").forEach(button => button.addEventListener("click", () => changeView(button.dataset.open)));
}
function activateTaskTab(view) {
  const taskTabs = document.querySelector(".task-tabs");
  let tab = taskTabs.querySelector(`[data-view="${view}"]`);
  if (!tab) {
    tab = document.createElement("button");
    tab.type = "button";
    tab.className = "task-tab";
    tab.dataset.view = view;
    tab.innerHTML = `${labels[view]} <span class="tab-close">×</span>`;
    taskTabs.append(tab);
    tab.addEventListener("click", () => changeView(view));
  }
  taskTabs.querySelectorAll(".task-tab").forEach(item => item.classList.toggle("active", item === tab));
}
function changeView(view) {
  document.querySelectorAll(".nav-item").forEach(item => item.classList.toggle("active", item.dataset.view === view));
  activateTaskTab(view);
  if (view === "dashboard") dashboardScreen();
  if (view === "watchlist") watchlistScreen();
  if (view === "stock") chartScreen();
  if (view === "market") marketScreen("市场行情", "重要指数 · 国内市场");
  if (view === "global") marketScreen("全球市场", "跨时区指数 · 当前交易状态");
  if (view === "futures") marketScreen("期货观察", "主要合约 · 分市场展示");
  if (view === "gold") goldScreen();
  if (view === "web") webScreen(false);
  if (view === "external") webScreen(true);
  if (view === "network") networkScreen();
  if (view === "nativeMarket") nativeMarketScreen();
  if (view === "native") nativeScreen();
}
renderQuotes();
document.querySelectorAll("[data-view]").forEach(button => button.addEventListener("click", () => changeView(button.dataset.view)));
document.getElementById("refresh-button").addEventListener("click", () => { const now = new Date(); document.getElementById("update-time").textContent = `更新于 ${now.toLocaleTimeString("zh-CN", {hour:"2-digit",minute:"2-digit",second:"2-digit"})}`; showToast("市场数据已刷新"); });
document.getElementById("login-form").addEventListener("submit", event => {
  event.preventDefault();
  const username = document.getElementById("username");
  const password = document.getElementById("password");
  const error = document.getElementById("login-error");
  const button = document.getElementById("login-button");
  if (!username.value.trim() || !password.value) { error.textContent = "请输入用户名和密码后继续。"; return; }
  error.textContent = ""; button.disabled = true; button.textContent = "正在验证";
  window.setTimeout(() => { document.getElementById("login-screen").hidden = true; watchlistScreen(); button.disabled = false; button.textContent = "登录工作台"; showToast("已加载当前账号的工作区"); }, 650);
});

const candles = [
  [3821,3842,3805,3836,56],[3836,3858,3818,3824,48],[3824,3834,3788,3802,75],[3802,3820,3792,3815,42],[3815,3864,3808,3852,82],[3852,3870,3839,3844,61],[3844,3851,3816,3821,52],[3821,3835,3798,3810,63],[3810,3828,3792,3818,47],[3818,3862,3812,3856,88],[3856,3876,3831,3842,71],[3842,3854,3804,3813,67],[3813,3830,3780,3796,84],[3796,3822,3772,3819,58],[3819,3845,3809,3831,45],[3831,3869,3820,3857,91],[3857,3884,3837,3872,80],[3872,3890,3845,3851,62],[3851,3860,3812,3824,54],[3824,3840,3797,3805,72]
];

function klineSvg(compact = false) {
  const width = compact ? 382 : 760, height = compact ? 220 : 450, plotTop = 26, plotBottom = compact ? 150 : 310, left = 38, right = 34;
  const hi = 3900, lo = 3740, xStep = (width - left - right) / candles.length;
  const y = value => plotTop + (hi - value) / (hi - lo) * (plotBottom - plotTop);
  const grids = [3760,3800,3840,3880].map(v => `<line x1="${left}" x2="${width-right}" y1="${y(v)}" y2="${y(v)}"/><text x="4" y="${y(v)+4}">${v}</text>`).join("");
  const bodies = candles.map(([o,h,l,c,v],i) => { const x = left + i*xStep + 3, color = c >= o ? "up" : "down", top = Math.min(y(o),y(c)), bodyH=Math.max(2,Math.abs(y(o)-y(c))); return `<g class="candle ${color}"><line x1="${x+xStep*.31}" y1="${y(h)}" x2="${x+xStep*.31}" y2="${y(l)}"/><rect x="${x}" y="${top}" width="${Math.max(3,xStep*.62)}" height="${bodyH}"/><rect class="volume" x="${x}" y="${plotBottom+18+(92-v)}" width="${Math.max(3,xStep*.62)}" height="${v}"/></g>`; }).join("");
  const line = candles.map((d,i)=>`${i ? "L":"M"}${left+i*xStep+xStep*.31},${y((d[0]+d[3])/2)}`).join(" ");
  const macd = candles.map((d,i)=>`${i ? "L":"M"}${left+i*xStep+xStep*.31},${height-42-(i%5)*4-(d[3]-3810)/8}`).join(" ");
  return `<svg class="kline-svg" viewBox="0 0 ${width} ${height}" role="img" aria-label="标准 K 线图，包含蜡烛、成交量和 MACD 指标"><g class="chart-grid">${grids}<line x1="${left}" x2="${width-right}" y1="${plotBottom+8}" y2="${plotBottom+8}"/><line x1="${left}" x2="${width-right}" y1="${height-78}" y2="${height-78}"/></g><path class="ma-line" d="${line}"/><path class="macd-line" d="${macd}"/>${bodies}<text x="${left}" y="${plotBottom+14}">成交量</text><text x="${left}" y="${height-88}">MACD</text><text x="${left}" y="${height-12}">09:30</text><text x="${width-right-30}" y="${height-12}">15:00</text></svg>`;
}

function tableRows(list) { return list.map((q,i)=>`<tr><td>${q.name}<span class="code">${q.code}</span></td><td>${q.price}</td><td class="${tone(q.change)}">${q.change}</td><td class="${tone(q.change)}">${q.change.startsWith("+")?"+":"-"}${(i*1.73+.26).toFixed(2)}</td><td>${q.amount}</td><td>${q.category}</td></tr>`).join(""); }

function marketTable(titleText, chips, list = quotes) { return `<section class="console-layout"><section class="console-main"><div class="console-tabs">${chips.map((x,i)=>`<button class="${i===0?"active":""}">${x}</button>`).join("")}</div><div class="quote-table"><table><thead><tr><th>名称</th><th>最新价</th><th>涨跌幅</th><th>涨跌</th><th>成交额</th><th>分类</th></tr></thead><tbody>${tableRows(list)}</tbody></table></div><div class="news-dock"><div><h3>市场快讯</h3><p>10:22  银行板块成交活跃，资金流向保持分化</p><p>10:18  宽基指数窄幅震荡，关注量价匹配情况</p><p>10:12  全球主要市场进入交投活跃时段</p></div><div class="sector-mini"><h3>热点板块</h3><span>银行 <b class="positive">+0.36%</b></span><span>通信 <b class="negative">-0.71%</b></span><span>新能源 <b class="positive">+1.12%</b></span></div></div></section><aside class="console-side"><div class="side-quote"><p>${titleText} · 概览</p><h2>3,821.40 <span class="negative">-0.42%</span></h2><small>领涨 12 · 领跌 23 · 平盘 8</small></div>${klineSvg(true)}<div class="side-list"><h3>重点观察</h3><p>流动性保持平稳，行业表现分化</p><p>外盘期指进入活跃时段</p></div></aside></section>`; }

function watchlistScreen() { title.textContent="自选"; subtitle.textContent="默认关注 · 8 个标的"; stage.innerHTML=marketTable("默认关注",["默认关注","银行","宽基指数","商品基金"]); }
function marketScreen(name, detail) { title.textContent=name; subtitle.textContent=detail; const groups=name==="期货观察"?["综合屏","上期所","郑商所","大商所"]:name==="全球市场"?["主要指数","美洲","欧洲","亚太"]:["重要指数","A 股","板块热点","基金"]; if(name==="期货观察"){ stage.innerHTML=`<section class="futures-screen"><div class="futures-top">${groups.map((x,i)=>`<button class="${i===0?"active":""}">${x}</button>`).join("")}</div><div class="futures-grid">${["上期所","郑商所","大商所","能源化工","金融期货","外盘期货"].map((x,i)=>`<article><h2>${x}</h2><table><thead><tr><th>合约</th><th>最新</th><th>涨跌幅</th></tr></thead><tbody>${quotes.slice(i%3,i%3+3).map(q=>`<tr><td>${q.name}</td><td>${q.price}</td><td class="${tone(q.change)}">${q.change}</td></tr>`).join("")}</tbody></table></article>`).join("")}</div><div class="futures-bottom"><section><h3>期市要闻</h3><p>能源品种波动收敛，关注库存与运力数据</p><p>利率期货维持窄幅整理</p></section><section class="native-chart-small">${klineSvg(true)}</section></div></section>`; return;} stage.innerHTML=marketTable(name,groups, name==="全球市场" ? quotes.slice(2).concat(quotes.slice(0,2)) : quotes); }
function chartScreen() { title.textContent="个股研究"; subtitle.textContent="中证银行 · 399986"; stage.innerHTML=`<section class="chart-console"><div class="quote-head"><div><h2>中证银行 <b class="negative">3,821.40 -0.42%</b></h2><p>开 3,842.10 · 高 3,865.21 · 低 3,813.52 · 成交额 54.8 亿</p></div><div class="segmented"><button>分时</button><button class="active">日 K</button><button>周 K</button><button>月 K</button></div></div><div class="chart-area">${klineSvg()}<aside><h3>五档行情</h3>${[5,4,3,2,1].map(n=>`<p>卖 ${n}<span>${(3821+n*.2).toFixed(2)}</span><b>${120+n*38}</b></p>`).join("")}<hr>${[1,2,3,4,5].map(n=>`<p>买 ${n}<span>${(3821-n*.2).toFixed(2)}</span><b>${160+n*22}</b></p>`).join("")}</aside></div><div class="research-grid"><section><h3>关联资讯</h3><p>政策预期稳定，银行板块估值修复仍需观察量能</p><p>机构观点：高股息资产保持防御属性</p></section><section><h3>资金与指标</h3><p>主力净流入 <b class="positive">+1.26 亿</b></p><p>MACD 处于零轴下方，短线波动放大</p></section></div></section>`; stage.querySelectorAll(".segmented button").forEach(button=>button.addEventListener("click",()=>{stage.querySelectorAll(".segmented button").forEach(b=>b.classList.remove("active"));button.classList.add("active");showToast(`已切换至${button.textContent}视图`)})); }
function nativeMarketScreen() { title.textContent="原生行情中心"; subtitle.textContent="Qt 原生渲染 · 本地高刷新数据"; stage.innerHTML=`<section class="chart-console native-market"><div class="native-ribbon"><span>Qt 原生图表</span><span><i class="dot dot-green"></i>行情流已连接</span><span>刷新间隔 1 秒</span><button>暂停刷新</button></div><div class="quote-head"><div><h2>沪深 300 <b class="negative">3,821.40 -0.42%</b></h2><p>本地渲染 · 十字线 · 缩放 · 平移 · 多指标叠加</p></div><div class="segmented"><button>分时</button><button class="active">日 K</button><button>周 K</button></div></div><div class="chart-area native-chart">${klineSvg()}<aside><h3>当前蜡烛</h3><p>时间<span>14:55</span></p><p>开盘<span>3,824.0</span></p><p>最高<span>3,840.2</span></p><p>最低<span>3,812.4</span></p><p>收盘<span>3,821.4</span></p><hr><h3>指标</h3><p>MA5 <span>3,830.5</span></p><p>MA10 <span>3,842.1</span></p></aside></div></section>`; }
function webFrame(name, subtitleText, targets, external, activeIndex = 0) { const activeTarget = targets[activeIndex]; const content=external?`<header><b>${name}</b><span>公开内容 · 仅供阅读</span></header><section class="public-hero"><p>今日精选</p><h2>市场与产业观察</h2><span>聚合公开信息，帮助研究人员快速掌握重要动态。</span></section><div class="public-grid"><article><h3>宏观观察</h3><p>主要市场波动收敛，关注跨市场风险传导。</p></article><article><h3>产业趋势</h3><p>算力、通信与能源基础设施持续受到关注。</p></article><article><h3>学习中心</h3><p>合规公开课程与行业解读内容。</p></article></div>`:`<header><b>运营协同系统</b><span>当前队列 · 华东区域</span></header><div class="business-summary"><article><small>待核验事项</small><strong>18</strong><span>较昨日 +3</span></article><article><small>处理中工单</small><strong>42</strong><span>其中 6 项临近时限</span></article><article><small>已完成</small><strong>126</strong><span>今日完成率 93%</span></article></div><section class="business-list"><h3>待处理事项</h3><p><b>对公开户资料复核</b><span>待补充材料 · 10:45</span></p><p><b>网点服务异常跟进</b><span>处理中 · 10:32</span></p><p><b>权限申请二次确认</b><span>待核验 · 10:18</span></p></section>`; return `<section class="web-view"><div class="browser-frame"><div class="browser-toolbar"><button title="后退">←</button><button title="前进">→</button><button title="刷新" id="web-refresh"><img src="assets/refresh-cw.svg" alt=""></button>${external?`<label class="target-picker" for="web-target">已批准页面</label><select id="web-target">${targets.map((app,i)=>`<option value="${i}" ${i===activeIndex?"selected":""}>${app.name}</option>`).join("")}</select>`:""}<span class="origin-label">${activeTarget.url}</span><span class="origin-state">● ${external?"外部受控会话":"业务域受控"}</span></div><iframe class="embedded-frame" title="${name}内嵌内容" sandbox="allow-same-origin" srcdoc="<!doctype html><html lang='zh-CN'><head><style>body{margin:0;font-family:Arial,'Microsoft YaHei',sans-serif;color:#23384e;background:#f5f8fb}header{height:48px;display:flex;align-items:center;justify-content:space-between;padding:0 22px;background:#fff;border-bottom:1px solid #dce6ef}header b{font-size:16px}header span{font-size:12px;color:#5d7287}.business-summary,.public-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;padding:18px}.business-summary article,.public-grid article{padding:15px;background:#fff;border:1px solid #dce6ef}.business-summary small{display:block;color:#657b90}.business-summary strong{display:block;margin:8px 0;font-size:28px;color:#0a67b4}.business-summary span{font-size:12px;color:#667b8e}.business-list{margin:0 18px;padding:17px;background:#fff;border:1px solid #dce6ef}.business-list h3{margin:0 0 10px}.business-list p{display:flex;justify-content:space-between;padding:11px 0;margin:0;border-top:1px solid #e3ebf2}.business-list span{color:#60778c;font-size:12px}.public-hero{padding:32px 22px;background:#e7f1fa;border-bottom:1px solid #c9dce9}.public-hero p{margin:0;color:#0a67b4;font-size:12px}.public-hero h2{margin:7px 0;font-size:26px}.public-hero span{color:#5d7287}</style></head><body>${content}</body></html>"></iframe></div></section>`; }
function webScreen(external) { const targets=external?[{appId:"market-insights",name:"市场观察",url:"https://insights.example.com"},{appId:"public-learning",name:"公开培训",url:"https://learn.example.com"},{appId:"industry-news",name:"行业资讯",url:"https://news.example.com"}]:[{appId:"ops-workflow",name:"运营协同",url:"https://ops.example.bank"}]; title.textContent=external?"在线网页":"指定业务"; subtitle.textContent=external?"已批准网页配置 · 独立会话":"运营协同系统 · 业务域受控"; const render = (index = 0) => { const app = targets[index]; stage.innerHTML=webFrame(app.name,"",targets,external,index); document.getElementById("web-refresh").addEventListener("click",()=>showToast(`正在重新加载 ${app.name}`)); const select=document.getElementById("web-target"); if(select) select.addEventListener("change",()=>{const next = Number(select.value); render(next); showToast(`已切换至${targets[next].name}`);}); }; render(); }
