# 星麒业务工作台高保真 UI 原型

本目录是 [UI 原型与功能规格](../UI原型与功能规格.md) 的可运行视觉实现，仅用于界面与交互评审，不连接真实认证、业务系统、本机应用或行情服务。

浏览器技术验收结论与边界见 [UI 验收记录](./UI验收记录.md)。

## 运行

本机 Node/npm 默认通过 Volta 使用：

```bash
cd mvp-demo/ui-prototype
npm install
npm run preview
```

浏览器打开：<http://127.0.0.1:4173>

Mock 账号：

| 用户名 | 密码 | 角色 | 授权模块 |
|---|---|---|---|
| `demoA` | `demo-only` | 综合柜员 | Web 业务、行情中心 |
| `demoB` | `demo-only` | 运营主管 | Web 业务、本机工具 |

## 评审页面

| 状态 | URL 参数 |
|---|---|
| 登录默认 | `?screen=login` |
| 登录中 | `?screen=login&state=loading` |
| 登录失败 | `?screen=login&user=demoA&state=error` |
| 角色 A 工作台 | `?screen=workbench&user=demoA` |
| 角色 B 工作台 | `?screen=workbench&user=demoB` |
| Web 正常 | `?screen=web&user=demoA&state=ready` |
| Web 加载 | `?screen=web&user=demoA&state=loading` |
| Web 错误 | `?screen=web&user=demoA&state=error` |
| Web 越界拦截 | `?screen=web&user=demoA&state=blocked` |
| K 线（保留 Web 与行情任务） | `?screen=kline&user=demoA&period=day&tabs=web,kline` |
| K 线加载 | `?screen=kline&user=demoA&state=loading` |
| K 线空数据 | `?screen=kline&user=demoA&state=empty` |
| K 线错误 | `?screen=kline&user=demoA&state=error` |
| 原生应用启动中 | `?screen=workbench&user=demoB&state=native-loading` |
| 原生应用成功 | `?screen=workbench&user=demoB&state=native-success&persist=1` |
| 原生应用缺失 | `?screen=workbench&user=demoB&modal=native-missing` |
| 原生应用失败 | `?screen=workbench&user=demoB&modal=native-failed` |
| Manifest 配置错误 | `?screen=config-error` |

页面支持实际操作：Mock 登录/退出、角色菜单过滤、标签打开/关闭、Web 刷新与失败重试、原生应用检测反馈、K 线周期切换/缩放/平移/十字线/重置视图。

## UI 图

| 编号 | 页面状态 | 1440×900 | 1366×768 |
|---|---|---|---|
| 01 | 登录默认 | [PNG](./output/playwright/1440x900/01-login.png) | [PNG](./output/playwright/1366x768/01-login.png) |
| 02 | 登录中 | [PNG](./output/playwright/1440x900/02-login-loading.png) | [PNG](./output/playwright/1366x768/02-login-loading.png) |
| 03 | 登录失败 | [PNG](./output/playwright/1440x900/03-login-error.png) | [PNG](./output/playwright/1366x768/03-login-error.png) |
| 04 | 角色 A 工作台 | [PNG](./output/playwright/1440x900/04-workbench-role-a.png) | [PNG](./output/playwright/1366x768/04-workbench-role-a.png) |
| 05 | 角色 B 工作台 | [PNG](./output/playwright/1440x900/05-workbench-role-b.png) | [PNG](./output/playwright/1366x768/05-workbench-role-b.png) |
| 06 | Web 正常 | [PNG](./output/playwright/1440x900/06-web-ready.png) | [PNG](./output/playwright/1366x768/06-web-ready.png) |
| 07 | Web 加载 | [PNG](./output/playwright/1440x900/07-web-loading.png) | [PNG](./output/playwright/1366x768/07-web-loading.png) |
| 08 | Web 错误 | [PNG](./output/playwright/1440x900/08-web-error.png) | [PNG](./output/playwright/1366x768/08-web-error.png) |
| 09 | Web 越界拦截 | [PNG](./output/playwright/1440x900/09-web-blocked.png) | [PNG](./output/playwright/1366x768/09-web-blocked.png) |
| 10 | K 线 | [PNG](./output/playwright/1440x900/10-kline.png) | [PNG](./output/playwright/1366x768/10-kline.png) |
| 11 | K 线加载 | [PNG](./output/playwright/1440x900/11-kline-loading.png) | [PNG](./output/playwright/1366x768/11-kline-loading.png) |
| 12 | K 线空数据 | [PNG](./output/playwright/1440x900/12-kline-empty.png) | [PNG](./output/playwright/1366x768/12-kline-empty.png) |
| 13 | K 线错误 | [PNG](./output/playwright/1440x900/13-kline-error.png) | [PNG](./output/playwright/1366x768/13-kline-error.png) |
| 14 | 原生应用启动中 | [PNG](./output/playwright/1440x900/14-native-loading.png) | [PNG](./output/playwright/1366x768/14-native-loading.png) |
| 15 | 原生应用成功 | [PNG](./output/playwright/1440x900/15-native-success.png) | [PNG](./output/playwright/1366x768/15-native-success.png) |
| 16 | 原生应用缺失 | [PNG](./output/playwright/1440x900/16-native-missing.png) | [PNG](./output/playwright/1366x768/16-native-missing.png) |
| 17 | 原生应用失败 | [PNG](./output/playwright/1440x900/17-native-failed.png) | [PNG](./output/playwright/1366x768/17-native-failed.png) |
| 18 | Manifest 配置错误 | [PNG](./output/playwright/1440x900/18-config-error.png) | [PNG](./output/playwright/1366x768/18-config-error.png) |

高 DPI 等效逻辑视口：[登录页](./output/playwright/scaling/1366x768-at-150pct-login.png) · [K 线页](./output/playwright/scaling/1366x768-at-150pct-kline.png)

## 实现说明

- 无前端框架、无构建步骤；原型由原生 HTML/CSS/JavaScript 实现。
- Lucide 提供本地图标，ECharts 提供本地 K 线交互，不依赖 CDN。
- `server.mjs` 仅使用 Node 标准库提供本地静态预览。
- URL 参数用于稳定复现评审状态，不代表正式产品路由设计。
- 截图由 Playwright 在真实浏览器中生成，产物位于 `output/playwright`。

## 已验证

- 18 个状态在 `1440×900`、`1366×768`、125% 与 150% 等效逻辑视口下共完成 72 次布局检查，均无页面级溢出、关键文本裁切和空白图表。
- 所有可见按钮与输入控件不小于 `44×44px`；5 个代表页面的 118 个可见文本节点均达到 WCAG AA 对比度。
- 登录成功/失败、两个角色菜单差异、退出登录可操作。
- 未授权角色直接访问模块 URL 时返回其工作台。
- Web 错误可重新加载；原生应用错误弹窗支持焦点约束、键盘关闭和关闭后回焦。
- 日 K、周 K、月 K 使用对应粒度的 Mock 聚合数据；滚轮缩放与拖拽平移会更新可视数据区间；十字线浮层使用中文 OHLC 与成交量字段。
- 浏览器控制台为 `0 errors / 0 warnings`。
