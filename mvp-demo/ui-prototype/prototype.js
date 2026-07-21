(() => {
  "use strict";

  const app = document.querySelector("#app");
  let chart = null;
  let loginTimer = null;
  let webTimer = null;
  let nativeTimer = null;
  let toastTimer = null;
  let pendingFocus = null;
  let autoDismissToast = false;
  let skipChartStateSave = false;

  const viewState = {
    web: "ready",
    kline: "ready",
    period: "day",
    zoom: { start: 18, end: 100 },
  };

  const profiles = {
    demoA: {
      username: "demoA",
      displayName: "演示用户 A",
      shortName: "A",
      role: "综合柜员",
      modules: ["web", "kline"],
    },
    demoB: {
      username: "demoB",
      displayName: "演示用户 B",
      shortName: "B",
      role: "运营主管",
      modules: ["web", "native"],
    },
  };

  const modules = {
    web: {
      id: "web",
      name: "Web 业务",
      description: "指定业务页面",
      icon: "globe-2",
      status: "授权来源可用",
      accent: "#0b5cad",
      tint: "#eaf2fc",
    },
    kline: {
      id: "kline",
      name: "行情中心",
      description: "本地 Mock 行情",
      icon: "chart-candlestick",
      status: "本地数据可用",
      accent: "#1c7f8f",
      tint: "#e4f2f4",
    },
    native: {
      id: "native",
      name: "本机工具",
      description: "指定麒麟应用",
      icon: "calculator",
      status: "等待本机检测",
      accent: "#9a651a",
      tint: "#fbf1df",
    },
  };

  function icon(name, className = "icon") {
    return `<i data-lucide="${name}" class="${className}" aria-hidden="true"></i>`;
  }

  function getRoute() {
    const params = new URLSearchParams(window.location.search);
    const screen = params.get("screen") || "login";
    const username = profiles[params.get("user")] ? params.get("user") : "demoA";
    const profile = profiles[username];
    const requestedTabs = (params.get("tabs") || "")
      .split(",")
      .filter((tab) => ["web", "kline"].includes(tab) && profile.modules.includes(tab));
    if (["web", "kline"].includes(screen) && profile.modules.includes(screen) && !requestedTabs.includes(screen)) {
      requestedTabs.push(screen);
    }

    const requestedState = params.get("state");
    if (screen === "web" && requestedState) viewState.web = requestedState;
    if (screen === "kline" && requestedState) viewState.kline = requestedState;
    if (params.get("period")) viewState.period = params.get("period");

    return {
      screen,
      username,
      state: requestedState || (screen === "web" ? viewState.web : screen === "kline" ? viewState.kline : "ready"),
      modal: params.get("modal") || "",
      period: viewState.period,
      openTabs: requestedTabs,
      nativeOutcome: params.get("native") || "missing",
      persist: params.get("persist") === "1",
    };
  }

  function setRoute(changes, replace = false) {
    const params = new URLSearchParams(window.location.search);
    Object.entries(changes).forEach(([key, value]) => {
      if (value === undefined || value === null || value === "") {
        params.delete(key);
      } else {
        params.set(key, value);
      }
    });
    const next = `${window.location.pathname}?${params.toString()}`;
    window.history[replace ? "replaceState" : "pushState"]({}, "", next);
    render();
  }

  function render() {
    window.clearTimeout(loginTimer);
    window.clearTimeout(webTimer);
    window.clearTimeout(nativeTimer);
    window.clearTimeout(toastTimer);
    if (chart) {
      const zoom = chart.getOption()?.dataZoom?.[0];
      if (zoom && !skipChartStateSave) viewState.zoom = { start: zoom.start, end: zoom.end };
      chart.dispose();
      chart = null;
    }
    skipChartStateSave = false;

    const route = getRoute();
    const protectedScreen = !["login", "config-error", "workbench"].includes(route.screen);
    if (protectedScreen && !profiles[route.username].modules.includes(route.screen)) {
      setRoute({ screen: "workbench", state: null, modal: null, period: null }, true);
      return;
    }
    if (route.modal.startsWith("native-") && !profiles[route.username].modules.includes("native")) {
      setRoute({ screen: "workbench", state: null, modal: null }, true);
      return;
    }

    if (route.screen === "config-error") {
      app.innerHTML = renderConfigError();
    } else if (route.screen === "login") {
      app.innerHTML = renderLogin(route);
    } else {
      app.innerHTML = renderShell(route);
    }

    if (window.lucide) {
      window.lucide.createIcons();
    }

    if (route.screen === "kline" && route.state === "ready") {
      window.requestAnimationFrame(() => initKline(route.period));
    }

    if (route.modal) {
      [".global-header", ".status-track", ".workspace"].forEach((selector) => {
        const element = document.querySelector(selector);
        if (!element) return;
        element.inert = true;
        element.setAttribute("aria-hidden", "true");
      });
      window.requestAnimationFrame(() => {
        document.querySelector("[data-dialog-primary]")?.focus();
      });
    } else if (pendingFocus) {
      const focusRequest = pendingFocus;
      pendingFocus = null;
      window.requestAnimationFrame(() => {
        const selector = focusRequest.type === "tab"
          ? `[role="tab"][data-open="${focusRequest.screen}"]`
          : "[data-main-focus]";
        document.querySelector(selector)?.focus();
      });
    }

    if (route.state === "native-success" && autoDismissToast && !route.persist) {
      toastTimer = window.setTimeout(() => {
        autoDismissToast = false;
        setRoute({ state: null });
      }, 4000);
    }

    window.__prototypeReady = true;
  }

  function renderLogin(route) {
    const hasError = route.state === "error";
    const isLoading = route.state === "loading";
    const username = route.username || "demoA";
    const password = hasError ? "wrong-pass" : "demo-only";

    return `
      <section class="login-screen" aria-labelledby="login-title">
        <div class="login-identity">
          <div class="bank-brand">
            <span class="bank-symbol">${icon("landmark")}</span>
            <div>
              <div class="bank-name">XX银行</div>
              <div class="bank-edition">Kylin desktop · demo</div>
            </div>
          </div>

          <div class="identity-copy">
            <div class="identity-rule"></div>
            <h1>星麒业务工作台</h1>
            <p>面向内部业务人员的统一桌面入口</p>
          </div>

          <ul class="trust-list" aria-label="演示环境状态">
            <li>${icon("shield-check")}<span>授权入口 · 按角色呈现</span></li>
            <li>${icon("database")}<span>本地数据 · 不连接真实行情</span></li>
            <li>${icon("lock-keyhole")}<span>受控访问 · 演示环境</span></li>
          </ul>

          <div class="identity-foot">
            <span>麒麟桌面端</span>
            <span>UI PROTOTYPE v0.1</span>
          </div>
        </div>

        <div class="login-form-area">
          <form class="login-form-wrap" id="login-form" novalidate>
            <div class="environment-kicker">演示环境</div>
            <h2 id="login-title">Mock 演示登录</h2>
            <p>登录后进入当前角色的授权工作台。</p>

            <div class="field">
              <label for="username">用户名</label>
              <div class="input-shell">
                <input
                  id="username"
                  name="username"
                  value="${username}"
                  autocomplete="off"
                  spellcheck="false"
                  aria-invalid="${hasError}"
                  aria-describedby="login-error"
                  ${isLoading ? "disabled" : ""}
                >
              </div>
            </div>

            <div class="field">
              <label for="password">密码</label>
              <div class="input-shell">
                <input
                  id="password"
                  name="password"
                  type="password"
                  value="${password}"
                  autocomplete="off"
                  aria-invalid="${hasError}"
                  aria-describedby="login-error"
                  ${isLoading ? "disabled" : ""}
                >
                <button class="input-action" type="button" data-action="toggle-password" title="显示密码" aria-label="显示密码">
                  ${icon("eye")}
                </button>
              </div>
            </div>

            <div id="login-error" class="login-error${hasError ? "" : " is-empty"}" role="alert">
              ${icon("triangle-alert")}
              <span>${hasError ? "用户名或密码不正确，请重新输入。" : "登录信息有效。"}</span>
            </div>

            <button class="primary-button login-submit" type="submit" data-login-submit ${isLoading ? "disabled aria-busy=\"true\"" : ""}>
              ${isLoading ? '<span class="spinner" aria-hidden="true"></span><span>正在登录</span>' : "登录"}
            </button>
            <div class="login-note">${icon("badge-check")}<span>当前页面仅使用演示账号和 Mock 数据</span></div>
          </form>
        </div>
      </section>
    `;
  }

  function renderShell(route) {
    const profile = profiles[route.username];
    const activeModule = route.screen === "workbench" ? "workbench" : route.screen;
    const body = route.screen === "web"
      ? renderWeb(route)
      : route.screen === "kline"
        ? renderKline(route)
        : renderWorkbench(profile, route);

    return `
      <section class="app-shell" aria-label="星麒业务工作台">
        ${renderHeader(profile)}
        ${renderStatusTrack(profile)}
        <div class="workspace">
          ${renderSidebar(profile, activeModule)}
          <section class="main-panel">
            ${renderTabs(route)}
            <div class="screen-content">${body}</div>
          </section>
        </div>
        ${route.modal.startsWith("native-") ? renderNativeDialog(route.modal) : ""}
        ${route.state === "native-success" ? renderToast() : ""}
      </section>
    `;
  }

  function renderHeader(profile) {
    return `
      <header class="global-header">
        <div class="header-brand">
          <span class="bank-symbol">${icon("landmark")}</span>
          <span class="product-name">星麒业务工作台</span>
        </div>
        <div class="header-actions">
          <span class="environment-tag">${icon("monitor-up")}演示环境</span>
          <div class="user-menu-wrap">
            <button class="user-trigger" type="button" data-action="toggle-user-menu" aria-haspopup="menu" aria-controls="user-popover" aria-expanded="false">
              <span class="user-avatar">${profile.shortName}</span>
              <span class="user-trigger-copy">
                <strong>${profile.displayName}</strong>
                <span>${profile.role}</span>
              </span>
              ${icon("chevron-down")}
            </button>
            <div class="user-popover" id="user-popover" role="menu" hidden>
              <div class="popover-identity">
                <strong>${profile.displayName}</strong>
                <span>${profile.username} · ${profile.role}</span>
              </div>
              <button class="popover-action" type="button" role="menuitem" data-action="logout">
                ${icon("log-out")}<span>退出登录</span>
              </button>
            </div>
          </div>
        </div>
      </header>
    `;
  }

  function renderStatusTrack(profile) {
    return `
      <div class="status-track" aria-label="业务状态">
        <div class="status-track-label"><span class="live-dot"></span><span>业务状态</span></div>
        <div class="status-items">
          <div class="status-item">${icon("monitor-up")}<span>环境：<strong>演示环境</strong></span></div>
          <div class="status-item">${icon("server")}<span>本地 Mock：<strong>可用</strong></span></div>
          <div class="status-item">${icon("database")}<span>本地数据：<strong class="data-number">09:30:00</strong></span></div>
          <div class="status-item">${icon("user-round")}<span>角色：<strong>${profile.role}</strong></span></div>
        </div>
      </div>
    `;
  }

  function renderSidebar(profile, activeModule) {
    const klineItem = profile.modules.includes("kline")
      ? navItem("kline", "chart-candlestick", "行情中心", activeModule)
      : "";
    const nativeItem = profile.modules.includes("native")
      ? navItem("native", "calculator", "本机工具", activeModule)
      : "";

    return `
      <aside class="sidebar" aria-label="主导航">
        <nav class="nav-scroll">
          <div class="nav-section-label">工作区</div>
          ${navItem("workbench", "layout-dashboard", "工作台", activeModule)}
          <div class="nav-section-label">业务办理</div>
          ${navItem("web", "globe-2", "Web 业务", activeModule)}
          ${(klineItem || nativeItem) ? `<div class="nav-section-label">业务辅助</div>${klineItem}${nativeItem}` : ""}
        </nav>
        <div class="sidebar-user">
          <div class="sidebar-user-summary">
            <span class="user-avatar">${profile.shortName}</span>
            <div><strong>${profile.displayName}</strong><span>${profile.role}</span></div>
          </div>
          <button class="sidebar-logout" type="button" data-action="logout">${icon("log-out")}<span>退出登录</span></button>
        </div>
      </aside>
    `;
  }

  function navItem(moduleId, iconName, label, activeModule) {
    const isActive = moduleId === activeModule;
    return `
      <button class="nav-item${isActive ? " is-active" : ""}" type="button" data-open="${moduleId}"${isActive ? " aria-current=\"page\"" : ""}>
        ${icon(iconName)}<span>${label}</span>
      </button>
    `;
  }

  function renderTabs(route) {
    const tabs = [tabMarkup("workbench", "工作台", "layout-dashboard", route.screen, false)];
    route.openTabs.forEach((screen) => {
      const module = modules[screen];
      tabs.push(tabMarkup(screen, module.name, module.icon, route.screen, true));
    });
    return `<div class="tab-strip" role="tablist" aria-label="已打开任务">${tabs.join("")}</div>`;
  }

  function tabMarkup(screen, label, iconName, activeScreen, closable) {
    return `
      <div class="tab${screen === activeScreen ? " is-active" : ""}">
        <button
          class="tab-main"
          type="button"
          role="tab"
          aria-selected="${screen === activeScreen}"
          tabindex="${screen === activeScreen ? "0" : "-1"}"
          data-open="${screen}"
        >${icon(iconName)}<span>${label}</span></button>
        ${closable ? `<button class="tab-close" type="button" data-action="close-tab" data-close-tab="${screen}" title="关闭${label}" aria-label="关闭${label}">${icon("x")}</button>` : ""}
      </div>
    `;
  }

  function renderWorkbench(profile, route) {
    return `
      <section class="workbench" aria-labelledby="workbench-title" tabindex="-1" data-main-focus>
        <div class="content-heading">
          <div>
            <h1 id="workbench-title">工作台</h1>
            <p>${profile.role}当前可用的授权业务入口</p>
          </div>
          <time class="heading-date data-number" datetime="2026-07-21">2026-07-21 · 周二</time>
        </div>

        <h2 class="section-title">可用应用</h2>
        <div class="module-grid">
          ${profile.modules.map((moduleId) => renderModuleCard(modules[moduleId], route)).join("")}
        </div>

        <div class="session-facts" aria-label="当前会话信息">
          <div class="session-fact"><span>当前身份</span><strong>${profile.displayName} · ${profile.role}</strong></div>
          <div class="session-fact"><span>数据边界</span><strong>本地 Mock 数据</strong></div>
          <div class="session-fact"><span>授权模块</span><strong>${profile.modules.length} 个业务入口</strong></div>
        </div>
      </section>
    `;
  }

  function renderModuleCard(module, route) {
    const isNativeLoading = module.id === "native" && route.state === "native-loading";
    const status = isNativeLoading ? "正在启动本机应用…" : module.status;
    return `
      <button
        class="module-card"
        type="button"
        data-open="${module.id}"
        style="--module-accent: ${module.accent}; --module-tint: ${module.tint}"
        ${isNativeLoading ? "disabled aria-busy=\"true\"" : ""}
      >
        <span class="module-icon">${icon(module.icon)}</span>
        <span class="module-copy"><strong>${module.name}</strong><span>${module.description}</span></span>
        ${icon("arrow-right", "module-arrow")}
        <span class="module-status"><span class="module-status-dot${isNativeLoading ? " is-loading" : ""}"></span><span>${status}</span></span>
      </button>
    `;
  }

  function renderWeb(route) {
    const isError = route.state === "error";
    const isLoading = route.state === "loading";
    const isBlocked = route.state === "blocked";
    return `
      <section class="module-screen web-module" aria-label="Web 业务" tabindex="-1" data-main-focus aria-busy="${isLoading}">
        <div class="web-toolbar">
          <button class="icon-button" type="button" title="后退" aria-label="后退" disabled>${icon("arrow-left")}</button>
          <button class="icon-button" type="button" title="前进" aria-label="前进" disabled>${icon("arrow-right")}</button>
          <button class="icon-button" type="button" data-action="refresh-web" title="刷新" aria-label="刷新" ${isLoading ? "disabled" : ""}>${icon("refresh-cw")}</button>
          <div class="web-title">指定业务系统</div>
          <div class="origin-badge">${icon("globe-2")}<span>演示来源：bank.example</span></div>
        </div>
        <div class="web-progress${isLoading ? " is-loading" : ""}">
          <span class="sr-only" role="status">${isLoading ? "页面正在加载" : "页面加载完成"}</span>
        </div>
        <div class="web-stage">
          ${isError ? renderWebError() : renderEmbeddedApp(isLoading)}
          ${isBlocked ? renderWebBlockedNotice() : ""}
        </div>
      </section>
    `;
  }

  function renderEmbeddedApp(isLoading = false) {
    return `
      <section class="embedded-app${isLoading ? " is-loading" : ""}" aria-label="内嵌演示业务页面">
        <header class="embedded-header">
          <div class="embedded-brand">${icon("briefcase-business")}<span>客户服务工作台</span></div>
          <span class="demo-data-tag">演示数据</span>
        </header>
        <nav class="embedded-nav" aria-label="业务页面导航">
          <span class="is-active">客户查询</span><span>业务受理</span><span>任务记录</span>
        </nav>
        <div class="embedded-content">
          <h2>客户查询</h2>
          <p>查询结果仅用于界面演示</p>
          <form class="customer-search" data-demo-search>
            <label for="customer-keyword">客户号 / 证件号</label>
            <input id="customer-keyword" value="DEMO-20260721" aria-label="客户号或证件号">
            <button class="primary-button" type="submit">查询</button>
          </form>
          <div class="result-table-wrap">
            <div class="result-table-title"><strong>查询结果</strong><span>共 2 条演示记录</span></div>
            <table class="result-table">
              <thead><tr><th>客户名称</th><th>客户号</th><th>客户类型</th><th>归属机构</th><th>状态</th></tr></thead>
              <tbody>
                <tr><td>演示客户 A</td><td class="data-number">DEMO-0001</td><td>个人</td><td>总行营业部</td><td><span class="table-status">正常</span></td></tr>
                <tr><td>演示客户 B</td><td class="data-number">DEMO-0002</td><td>企业</td><td>科技支行</td><td><span class="table-status">正常</span></td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>
    `;
  }

  function renderWebError() {
    return `
      <div class="web-error-state">
        <div class="state-message" role="alert">
          <span class="state-icon">${icon("triangle-alert")}</span>
          <h2>页面暂时无法打开</h2>
          <p>无法连接到已授权地址。请检查连接后重新加载。</p>
          <button class="primary-button" type="button" data-action="reload-web">${icon("refresh-cw")}<span>重新加载</span></button>
        </div>
      </div>
    `;
  }

  function renderWebBlockedNotice() {
    return `
      <div class="blocked-notice" role="status">
        ${icon("shield-x")}
        <div><strong>已阻止打开未授权地址</strong><span>原业务页面保持不变。</span></div>
        <button class="icon-button" type="button" data-action="close-blocked" title="关闭提示" aria-label="关闭提示">${icon("x")}</button>
      </div>
    `;
  }

  function renderKline(route) {
    const periodLabels = { day: "日 K", week: "周 K", month: "月 K" };
    const isReady = route.state === "ready";
    const periodName = periodLabels[route.period] || periodLabels.day;
    return `
      <section class="module-screen kline-module" aria-label="行情中心" tabindex="-1" data-main-focus aria-busy="${route.state === "loading"}">
        <div class="kline-toolbar">
          <div class="quote-identity"><strong>示例指数</strong><span>DEMO.IDX</span></div>
          <div class="quote-price"><strong>3,218.56</strong><span class="quote-up">+12.35&nbsp;&nbsp;+0.39%</span></div>
          <div class="period-control" aria-label="K 线周期">
            ${Object.entries(periodLabels).map(([id, label]) => `<button class="period-button${route.period === id ? " is-active" : ""}" type="button" data-period="${id}" aria-pressed="${route.period === id}">${label}</button>`).join("")}
          </div>
          <button class="secondary-button kline-reset" type="button" data-action="reset-chart" ${isReady ? "" : "disabled"}>${icon("rotate-ccw")}<span>重置视图</span></button>
        </div>
        <div class="chart-status-line">
          <span class="mock-badge">${icon("database")}MOCK 数据</span>
          <span>本地数据集</span><span class="data-number">更新时间 09:30:00</span>
        </div>
        <div class="chart-wrap">${renderKlineStage(route.state, periodName)}</div>
        ${renderKlineFooter(route.state)}
      </section>
    `;
  }

  function renderKlineStage(state, periodName) {
    if (state === "ready") {
      return `<div id="kline-chart" role="img" aria-label="示例指数 ${periodName}与成交量图，当前上涨 0.39%"></div>`;
    }
    if (state === "loading") {
      return `
        <div class="kline-state" role="status">
          <span class="state-loader" aria-hidden="true"></span>
          <h2>正在加载演示行情</h2>
          <p>正在读取本地 Mock 数据。</p>
        </div>
      `;
    }
    if (state === "empty") {
      return `
        <div class="kline-state">
          <span class="state-icon is-neutral">${icon("database")}</span>
          <h2>暂无演示行情数据</h2>
          <p>本地数据集没有可展示的记录。</p>
          <button class="primary-button" type="button" data-action="reload-kline">${icon("refresh-cw")}<span>重新加载数据</span></button>
        </div>
      `;
    }
    return `
      <div class="kline-state" role="alert">
        <span class="state-icon">${icon("triangle-alert")}</span>
        <h2>行情数据加载失败</h2>
        <p>无法读取本地 Mock 数据，请重新加载。</p>
        <button class="primary-button" type="button" data-action="reload-kline">${icon("refresh-cw")}<span>重新加载数据</span></button>
      </div>
    `;
  }

  function renderKlineFooter(state) {
    if (state !== "ready") {
      const message = state === "loading" ? "正在准备当前行情数据" : "当前无可用行情数据";
      return `<div class="quote-detail quote-detail-state" aria-live="polite">${message}</div>`;
    }
    return `
      <div class="quote-detail" aria-label="当前行情数据">
        <div class="quote-detail-item"><span>日期</span><strong>2026-07-21</strong></div>
        <div class="quote-detail-item"><span>开盘</span><strong>3,201.10</strong></div>
        <div class="quote-detail-item"><span>最高</span><strong>3,225.20</strong></div>
        <div class="quote-detail-item"><span>最低</span><strong>3,198.00</strong></div>
        <div class="quote-detail-item"><span>收盘</span><strong>3,218.56</strong></div>
        <div class="quote-detail-item"><span>涨跌</span><strong class="quote-up">+0.39%</strong></div>
      </div>
    `;
  }

  function renderNativeDialog(kind) {
    const failed = kind === "native-failed";
    const title = failed ? "应用启动失败" : "未找到指定应用";
    const description = failed
      ? "“麒麟计算器”未能正常启动，请检查应用状态后重试。"
      : "请确认验收机已安装“麒麟计算器”，然后重新检测。";
    const detail = failed ? "启动结果：应用返回失败状态" : "检测目标：清单中的固定应用路径";
    const actionLabel = failed ? "重试" : "重新检测";
    return `
      <div class="dialog-layer" role="presentation">
        <section class="dialog" role="dialog" aria-modal="true" aria-labelledby="native-dialog-title" aria-describedby="native-dialog-description">
          <div class="dialog-head">
            <strong>本机工具</strong>
            <button class="icon-button" type="button" data-action="close-dialog" title="关闭" aria-label="关闭">${icon("x")}</button>
          </div>
          <div class="dialog-body">
            <span class="dialog-icon">${icon("triangle-alert")}</span>
            <div class="dialog-copy">
              <h2 id="native-dialog-title">${title}</h2>
              <p id="native-dialog-description">${description}</p>
              <div class="dialog-detail">${detail}</div>
            </div>
          </div>
          <div class="dialog-actions">
            <button class="secondary-button" type="button" data-action="close-dialog">关闭</button>
            <button class="primary-button" type="button" data-action="recheck-native" data-dialog-primary>${icon("refresh-cw")}<span>${actionLabel}</span></button>
          </div>
        </section>
      </div>
    `;
  }

  function renderToast() {
    return `
      <div class="toast" role="status">
        ${icon("circle-check")}
        <div><strong>应用已启动</strong><span>麒麟计算器已在独立窗口打开</span></div>
        <button class="icon-button" type="button" data-action="close-toast" title="关闭通知" aria-label="关闭通知">${icon("x")}</button>
      </div>
    `;
  }

  function renderConfigError() {
    return `
      <section class="config-error-screen" aria-labelledby="config-error-title" tabindex="-1" data-main-focus>
        <div class="config-error-brand">${icon("landmark")}<span>星麒业务工作台</span></div>
        <div class="config-error-content" role="alert">
          <span class="state-icon">${icon("file-warning")}</span>
          <h1 id="config-error-title">演示配置无效</h1>
          <p>工作台无法启动。请检查只读 Manifest 后重新运行应用。</p>
          <div class="config-error-code">配置检查未通过 · 未加载任何业务模块</div>
          <button class="secondary-button" type="button" data-action="exit-demo">${icon("log-out")}<span>退出演示</span></button>
        </div>
      </section>
    `;
  }

  function initKline(period) {
    const element = document.querySelector("#kline-chart");
    if (!element || !window.echarts) return;

    const market = createMarketData(period);
    chart = window.echarts.init(element, null, { renderer: "canvas" });
    chart.setOption({
      animation: false,
      backgroundColor: "#fcfdff",
      textStyle: {
        color: "#596b82",
        fontFamily: '"Noto Sans CJK SC", "Microsoft YaHei", sans-serif',
      },
      axisPointer: {
        link: [{ xAxisIndex: [0, 1] }],
        label: { backgroundColor: "#344a63", fontSize: 10 },
      },
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "cross" },
        formatter: (items) => {
          const candle = items.find((item) => item.seriesType === "candlestick");
          const volume = items.find((item) => item.seriesType === "bar");
          if (!candle) return "";
          const [, open, close, low, high] = candle.data;
          const price = new Intl.NumberFormat("zh-CN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
          const quantity = new Intl.NumberFormat("zh-CN");
          return [
            `<strong>${candle.axisValue}</strong>`,
            `开盘 ${price.format(open)}`,
            `最高 ${price.format(high)}`,
            `最低 ${price.format(low)}`,
            `收盘 ${price.format(close)}`,
            `成交量 ${quantity.format(volume?.value ?? 0)}`,
          ].join("<br>");
        },
        borderColor: "#b9c9da",
        borderWidth: 1,
        backgroundColor: "rgba(255,255,255,0.96)",
        textStyle: { color: "#14243a", fontSize: 11 },
        extraCssText: "box-shadow:0 8px 24px rgba(10,47,94,.12);border-radius:4px;",
      },
      grid: [
        { left: 64, right: 28, top: 28, height: "59%" },
        { left: 64, right: 28, top: "74%", height: "16%" },
      ],
      xAxis: [
        {
          type: "category",
          data: market.dates,
          boundaryGap: true,
          axisLine: { lineStyle: { color: "#b9c9da" } },
          axisTick: { show: false },
          axisLabel: { show: false },
          splitLine: { show: false },
          min: "dataMin",
          max: "dataMax",
        },
        {
          type: "category",
          gridIndex: 1,
          data: market.dates,
          boundaryGap: true,
          axisLine: { lineStyle: { color: "#b9c9da" } },
          axisTick: { show: false },
          axisLabel: { color: "#6c7d91", fontSize: 10, margin: 10 },
          splitLine: { show: false },
          min: "dataMin",
          max: "dataMax",
        },
      ],
      yAxis: [
        {
          scale: true,
          position: "left",
          splitNumber: 5,
          axisLine: { show: false },
          axisTick: { show: false },
          axisLabel: { color: "#6c7d91", fontSize: 10, formatter: (value) => value.toFixed(0) },
          splitLine: { lineStyle: { color: "#e3eaf2", type: "dashed" } },
        },
        {
          scale: true,
          gridIndex: 1,
          splitNumber: 2,
          axisLine: { show: false },
          axisTick: { show: false },
          axisLabel: { color: "#6c7d91", fontSize: 9, formatter: (value) => `${Math.round(value / 1000)}k` },
          splitLine: { lineStyle: { color: "#edf1f6" } },
        },
      ],
      dataZoom: [
        { type: "inside", xAxisIndex: [0, 1], start: viewState.zoom.start, end: viewState.zoom.end, zoomOnMouseWheel: true, moveOnMouseMove: true },
      ],
      series: [
        {
          name: "K 线",
          type: "candlestick",
          data: market.values,
          itemStyle: {
            color: "#ffffff",
            color0: "#17805c",
            borderColor: "#b63e49",
            borderColor0: "#17805c",
            borderWidth: 1.4,
          },
          emphasis: { itemStyle: { borderWidth: 2 } },
        },
        {
          name: "成交量",
          type: "bar",
          xAxisIndex: 1,
          yAxisIndex: 1,
          data: market.volumes.map((volume, index) => ({
            value: volume,
            itemStyle: {
              color: market.values[index][1] >= market.values[index][0] ? "rgba(182,62,73,.56)" : "rgba(23,128,92,.56)",
            },
          })),
          barMaxWidth: 10,
        },
      ],
    });

    chart.on("datazoom", () => {
      const zoom = chart?.getOption()?.dataZoom?.[0];
      if (zoom) viewState.zoom = { start: zoom.start, end: zoom.end };
    });

    window.addEventListener("resize", resizeChart, { once: true });
  }

  function createMarketData(period) {
    const daily = createDailyMarketData(380);
    if (period === "day") return toMarketArrays(daily.slice(-60));

    const groups = new Map();
    daily.forEach((record) => {
      const date = record.date;
      let key;
      if (period === "week") {
        const monday = new Date(date);
        monday.setDate(date.getDate() - ((date.getDay() + 6) % 7));
        key = monday.toISOString().slice(0, 10);
      } else {
        key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
      }
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(record);
    });

    const aggregated = [...groups.entries()].map(([key, records]) => {
      const open = records[0].value[0];
      const close = records.at(-1).value[1];
      const low = Math.min(...records.map((record) => record.value[2]));
      const high = Math.max(...records.map((record) => record.value[3]));
      const endDate = records.at(-1).date;
      return {
        date: endDate,
        label: period === "week"
          ? `${String(endDate.getFullYear()).slice(2)}-${records.at(-1).label}`
          : key,
        value: [open, close, low, high].map((value) => Number(value.toFixed(2))),
        volume: records.reduce((total, record) => total + record.volume, 0),
      };
    });

    return toMarketArrays(aggregated.slice(period === "week" ? -52 : -18));
  }

  function createDailyMarketData(count) {
    const dates = [];
    const cursor = new Date("2026-07-21T00:00:00");
    while (dates.length < count) {
      if (cursor.getDay() !== 0 && cursor.getDay() !== 6) dates.unshift(new Date(cursor));
      cursor.setDate(cursor.getDate() - 1);
    }

    let previousClose = 3180;
    return dates.map((date, index) => {
      const wave = Math.sin(index * 0.47) * 13 + Math.cos(index * 0.18) * 7;
      const drift = 0.52 + (index % 19 === 0 ? -9 : 0);
      const open = previousClose + Math.sin(index * 1.07) * 8;
      const close = open + wave * 0.42 + drift;
      const low = Math.min(open, close) - 6 - (index % 4) * 2.1;
      const high = Math.max(open, close) + 7 + (index % 5) * 1.9;
      previousClose = close;
      return {
        date,
        label: `${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`,
        value: [open, close, low, high].map((value) => Number(value.toFixed(2))),
        volume: 42000 + ((index * 7919) % 56000),
      };
    });
  }

  function toMarketArrays(records) {
    return {
      dates: records.map((record) => record.label),
      values: records.map((record) => record.value),
      volumes: records.map((record) => record.volume),
    };
  }

  function resizeChart() {
    chart?.resize();
  }

  function openModule(moduleId) {
    const route = getRoute();
    if (moduleId === "workbench") {
      setRoute({ screen: "workbench", state: null, modal: null, tabs: route.openTabs.join(",") || null });
      return;
    }
    if (moduleId === "native") {
      setRoute({ screen: "workbench", state: "native-loading", modal: null });
      nativeTimer = window.setTimeout(() => {
        if (route.nativeOutcome === "success") {
          autoDismissToast = true;
          setRoute({ state: "native-success", modal: null });
        } else {
          setRoute({ state: null, modal: route.nativeOutcome === "failed" ? "native-failed" : "native-missing" });
        }
      }, 520);
      return;
    }

    const openTabs = [...route.openTabs];
    if (!openTabs.includes(moduleId)) openTabs.push(moduleId);
    const state = moduleId === "web" ? viewState.web : viewState.kline;
    setRoute({ screen: moduleId, state, modal: null, tabs: openTabs.join(","), period: viewState.period });
  }

  function closeTab(screen) {
    const route = getRoute();
    const index = route.openTabs.indexOf(screen);
    const openTabs = route.openTabs.filter((tab) => tab !== screen);
    let nextScreen = route.screen;
    if (route.screen === screen) nextScreen = openTabs[Math.max(0, index - 1)] || "workbench";
    const state = nextScreen === "web" ? viewState.web : nextScreen === "kline" ? viewState.kline : null;
    pendingFocus = { type: "tab", screen: nextScreen };
    setRoute({ screen: nextScreen, state, tabs: openTabs.join(",") || null, modal: null, period: viewState.period });
  }

  function resetSessionState() {
    viewState.web = "ready";
    viewState.kline = "ready";
    viewState.period = "day";
    viewState.zoom = { start: 18, end: 100 };
    autoDismissToast = false;
  }

  app.addEventListener("submit", (event) => {
    if (event.target.matches("#login-form")) {
      event.preventDefault();
      const form = new FormData(event.target);
      const username = String(form.get("username") || "").trim();
      const password = String(form.get("password") || "");
      const submit = event.target.querySelector("[data-login-submit]");
      submit.disabled = true;
      submit.innerHTML = '<span class="spinner" aria-hidden="true"></span><span>正在登录</span>';
      if (window.lucide) window.lucide.createIcons();

      loginTimer = window.setTimeout(() => {
        if (profiles[username] && password === "demo-only") {
          resetSessionState();
          pendingFocus = { type: "main" };
          setRoute({ screen: "workbench", user: username, state: null, modal: null, period: null, tabs: null, native: null });
        } else {
          setRoute({ screen: "login", user: profiles[username] ? username : "demoA", state: "error", modal: null }, true);
          document.querySelector("#password")?.focus();
        }
      }, 520);
      return;
    }

    if (event.target.matches("[data-demo-search]")) {
      event.preventDefault();
    }
  });

  app.addEventListener("click", (event) => {
    const closeTabButton = event.target.closest('[data-action="close-tab"]');
    if (closeTabButton) {
      event.stopPropagation();
      closeTab(closeTabButton.dataset.closeTab);
      return;
    }

    const openTarget = event.target.closest("[data-open]");
    if (openTarget) {
      pendingFocus = openTarget.matches('[role="tab"]')
        ? { type: "tab", screen: openTarget.dataset.open }
        : { type: "main" };
      openModule(openTarget.dataset.open);
      return;
    }

    const actionTarget = event.target.closest("[data-action]");
    if (!actionTarget) return;

    const action = actionTarget.dataset.action;
    if (action === "toggle-password") {
      const password = document.querySelector("#password");
      const showing = password.type === "text";
      password.type = showing ? "password" : "text";
      actionTarget.setAttribute("aria-label", showing ? "显示密码" : "隐藏密码");
      actionTarget.setAttribute("title", showing ? "显示密码" : "隐藏密码");
      actionTarget.innerHTML = icon(showing ? "eye" : "eye-off");
      window.lucide?.createIcons();
      return;
    }

    if (action === "toggle-user-menu") {
      const menu = document.querySelector(".user-popover");
      const isOpening = menu.hidden;
      menu.hidden = !isOpening;
      actionTarget.setAttribute("aria-expanded", String(isOpening));
      if (isOpening) menu.querySelector('[role="menuitem"]')?.focus();
      return;
    }

    if (action === "logout") {
      resetSessionState();
      setRoute({ screen: "login", user: null, state: null, modal: null, period: null, tabs: null, native: null });
      return;
    }

    if (action === "refresh-web") {
      viewState.web = "loading";
      setRoute({ state: "loading" });
      webTimer = window.setTimeout(() => {
        viewState.web = "ready";
        setRoute({ state: "ready" });
      }, 900);
      return;
    }

    if (action === "reload-web") {
      viewState.web = "ready";
      setRoute({ state: "ready" });
      return;
    }

    if (action === "close-blocked") {
      viewState.web = "ready";
      setRoute({ state: "ready" });
      return;
    }

    if (action === "reload-kline") {
      viewState.kline = "ready";
      viewState.zoom = { start: 18, end: 100 };
      setRoute({ state: "ready" });
      return;
    }

    if (action === "close-dialog") {
      setRoute({ modal: null });
      document.querySelector('[data-open="native"]')?.focus();
      return;
    }

    if (action === "recheck-native") {
      const modal = getRoute().modal;
      setRoute({ modal: null, state: "native-loading" });
      nativeTimer = window.setTimeout(() => setRoute({ state: null, modal }), 720);
      return;
    }

    if (action === "reset-chart") {
      viewState.zoom = { start: 18, end: 100 };
      chart?.dispatchAction({ type: "dataZoom", ...viewState.zoom });
      return;
    }

    if (action === "close-toast") {
      autoDismissToast = false;
      setRoute({ state: null });
      return;
    }

    if (action === "exit-demo") {
      resetSessionState();
      setRoute({ screen: "login", state: null, modal: null, tabs: null });
    }
  });

  app.addEventListener("click", (event) => {
    const periodButton = event.target.closest("[data-period]");
    if (periodButton) {
      viewState.period = periodButton.dataset.period;
      viewState.zoom = { start: viewState.period === "month" ? 0 : 18, end: 100 };
      skipChartStateSave = true;
      setRoute({ period: viewState.period, state: viewState.kline });
    }
  });

  app.addEventListener("keydown", (event) => {
    const tab = event.target.closest('[role="tab"][data-open]');
    if (tab && ["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) {
      event.preventDefault();
      const tabs = [...document.querySelectorAll('[role="tab"][data-open]')];
      const currentIndex = tabs.indexOf(tab);
      const nextIndex = event.key === "Home"
        ? 0
        : event.key === "End"
          ? tabs.length - 1
          : (currentIndex + (event.key === "ArrowRight" ? 1 : -1) + tabs.length) % tabs.length;
      const nextTab = tabs[nextIndex];
      pendingFocus = { type: "tab", screen: nextTab.dataset.open };
      openModule(nextTab.dataset.open);
      return;
    }

    const menuItem = event.target.closest('[role="menuitem"]');
    if (menuItem && ["ArrowDown", "ArrowUp", "Home", "End"].includes(event.key)) {
      event.preventDefault();
      menuItem.focus();
    }
  });

  document.addEventListener("click", (event) => {
    const menu = document.querySelector(".user-popover:not([hidden])");
    if (!menu || event.target.closest(".user-menu-wrap")) return;
    menu.hidden = true;
    document.querySelector(".user-trigger")?.setAttribute("aria-expanded", "false");
  });

  document.addEventListener("keydown", (event) => {
    const dialog = document.querySelector('[role="dialog"]');
    if (event.key === "Escape") {
      const menu = document.querySelector(".user-popover:not([hidden])");
      if (dialog) {
        setRoute({ modal: null });
        document.querySelector('[data-open="native"]')?.focus();
      } else if (menu) {
        menu.hidden = true;
        const trigger = document.querySelector(".user-trigger");
        trigger?.setAttribute("aria-expanded", "false");
        trigger?.focus();
      }
      return;
    }

    if (dialog && event.key === "Tab") {
      const focusable = [...dialog.querySelectorAll("button:not(:disabled), input:not(:disabled), [tabindex]:not([tabindex='-1'])")];
      if (!focusable.length) return;
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
  });

  window.addEventListener("popstate", render);
  window.addEventListener("resize", resizeChart);
  render();
})();
