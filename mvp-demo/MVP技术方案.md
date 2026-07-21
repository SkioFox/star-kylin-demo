# 星麒业务工作台 MVP Demo 技术方案

> 版本：v0.1
> 日期：2026-07-21
> 状态：**方案已形成，T0A/T0B 环境与演示内容待回填**
> 需求基线：[MVP-demo需求.md](./MVP-demo需求.md)
> UI 基线：[UI原型与功能规格.md](./UI原型与功能规格.md)
> UI 技术验收：[ui-prototype/UI验收记录.md](./ui-prototype/UI验收记录.md)

## 1. 方案目标与边界

本方案只服务 `mvp-demo`，目标是在一台明确的麒麟 V10 验收机上完成以下闭环：

1. C++/QML 原生外壳启动并还原已验收 UI。
2. 两个纯 Mock 用户登录后看到不同授权模块。
3. 在标签中安全加载一个指定 Web 页面。
4. 直接拉起一个清单内的固定麒麟应用。
5. 在标签中离线展示可交互的 Mock K 线。
6. 完成构建、运行、演示和真机验收记录。

本方案不实现真实 CAS、权限中心、业务鉴权、国密、审计平台、通用 JSBridge、原生 IPC、插件市场、在线更新或生产级应用治理。Demo 中形成的接口不得被描述为上述生产能力已经落地。

## 2. 技术决策

| 领域 | MVP 选型 | 决策理由 |
|---|---|---|
| 桌面外壳 | C++17 + Qt Quick/QML + Qt Quick Controls 2 | 已由需求确定；适合麒麟原生窗口和固定工作台布局 |
| 构建 | CMake + CTest | 需求已定；Qt 原生支持，无需新增构建框架 |
| Web 容器 | QtWebEngine / `WebEngineView` | 同时承载指定 Web 页面和本地 K 线页面 |
| Mock 登录 | 进程内 C++ 服务 | 不搭 HTTP Mock 服务，不增加端口、部署和网络依赖 |
| 配置 | 编译进 `qrc` 的只读 `manifest.json` | 用户、角色、模块、URL 和程序路径不可被普通用户改写 |
| K 线 | 本地 ECharts `6.1.0` + 本地 Mock 数据 | 直接复用已验收原型和已锁依赖；运行时不访问 CDN |
| 图标 | 从当前 Lucide `1.25.0` 中提取所需 SVG 并编入 `qrc` | 与原型一致；正式程序不依赖 Node/npm 运行时 |
| 状态保存 | 仅进程内内存 | MVP 无恢复上次会话需求，退出后回到登录页 |
| 日志 | Qt `QLoggingCategory` | 标准能力足够；不引入第三方日志库 |
| 交付运行 | 验收机上的构建产物与运行说明 | MVP 先闭环指定真机；不把 `.deb` 打包作为本轮结论 |

### 2.1 Qt 版本策略

方案不预先猜测 Qt 版本。T0A 必须先记录验收镜像提供或行内批准的 Qt、QtWebEngine 和 Chromium 版本，再锁定单一 Qt 主版本进行实现和运行验证。

- 优先使用与目标麒麟镜像兼容且可获得安全维护的 Qt 套件。
- 同一交付物不得混用 Qt 主版本或来自不同发行源的 QtWebEngine 组件。
- 必须具备 `Core`、`Gui`、`Qml`、`Quick`、`QuickControls2`、`WebEngineQuick` 和 `Test` 模块。
- T0A 若发现 ECharts `6.1.0` 与目标 QtWebEngine/Chromium 不兼容，才允许调整图表版本；调整后必须重新执行 K 线视觉与交互验收并更新第三方清单。
- Qt 授权方式、动态链接要求及 QtWebEngine/Chromium 安全维护责任在交付前确认；MVP 也必须附第三方许可证说明。

## 3. 总体架构

```text
┌──────────────────────────────────────────────────────────────┐
│                        QML 表现层                            │
│ LoginPage / AppShell / Workbench / TaskTabs / 状态与弹窗     │
├──────────────────────────────────────────────────────────────┤
│                    AppController + ListModel                 │
│ 会话状态 / 授权模块 / 打开标签 / 活动模块 / UI 状态           │
├────────────────────┬──────────────────┬──────────────────────┤
│ ManifestService    │ MockAuthService  │ NativeLauncher       │
│ 加载与严格校验      │ 假账号与角色      │ 固定程序直接拉起       │
├────────────────────┴─────────┬────────┴──────────────────────┤
│ UrlPolicy + QtWebEngine      │ 本地 K 线 Web 页面            │
│ 指定页面、导航/弹窗/下载拦截   │ ECharts + Mock 数据 + CSP     │
├──────────────────────────────┴───────────────────────────────┤
│ Qt / Linux / 麒麟 V10 / 外部白名单应用                       │
└──────────────────────────────────────────────────────────────┘
```

### 3.1 进程模型

```text
star-kylin-demo 主进程
  ├─ QML UI 与 C++ 控制器
  ├─ QtWebEngineProcess：指定 Web 页面
  ├─ QtWebEngineProcess：本地 K 线页面
  └─ QProcess：拉起白名单麒麟应用（独立系统窗口）
```

QtWebEngine 本身是多进程架构。门户不尝试把原生应用窗口嵌入标签，也不实现进程注入或窗口句柄接管。

### 3.2 组件职责

| 组件 | 职责 | 不负责 |
|---|---|---|
| `AppController` | 启动状态、登录/退出、模块分发、标签单实例、错误反馈 | 解析任意外部配置、执行业务鉴权 |
| `ManifestService` | 从 `qrc` 加载并校验 Manifest，生成只读定义 | 在线更新、用户目录覆盖、签名治理平台 |
| `MockAuthService` | 校验两个假账号并返回用户/角色 | 网络认证、令牌、真实密码存储 |
| `ModuleListModel` | 向 QML 暴露当前角色可见模块 | 决定权限主数据 |
| `TabListModel` | 固定工作台、Web/K 线标签单实例、切换与关闭 | 原生应用窗口管理 |
| `UrlPolicy` | 对顶层导航、重定向、资源来源和新窗口做精确判断 | 代替目标 Web 后端鉴权 |
| `NativeLauncher` | 校验固定路径并通过 QProcess 直接启动 | Shell、路径搜索、IPC、进程托管 |
| `WebModulePage` | Web 工具条、加载/错误/越界状态、刷新 | 任意地址输入、下载管理器 |
| `KlineModulePage` | 加载离线图表页，呈现加载/空/错误状态 | 真实行情、通用 Bridge |

## 4. 工程目录

正式实现放在 `mvp-demo/app`，原型目录继续只作为 UI 基线：

```text
mvp-demo/
  MVP-demo需求.md
  MVP技术方案.md
  UI原型与功能规格.md
  ui-prototype/                 # 已验收浏览器原型，不作为正式运行时
  app/
    CMakeLists.txt
    cmake/
    src/
      main.cpp
      appcontroller.{h,cpp}
      manifestservice.{h,cpp}
      mockauthservice.{h,cpp}
      modulelistmodel.{h,cpp}
      tablistmodel.{h,cpp}
      urlpolicy.{h,cpp}
      nativelauncher.{h,cpp}
    qml/
      Main.qml
      Theme.qml
      LoginPage.qml
      AppShell.qml
      WorkbenchPage.qml
      WebModulePage.qml
      KlineModulePage.qml
      components/
    resources/
      resources.qrc
      manifest.json
      icons/                    # 只放实际使用的 SVG
      web-demo/                 # 默认离线 Web 演示页
      web-kline/
        index.html
        styles.css
        kline.js
        mock-market.json
        vendor/echarts.min.js
    tests/
      CMakeLists.txt
      test_manifest.cpp
      test_auth.cpp
      test_tabs.cpp
      test_urlpolicy.cpp
    THIRD_PARTY_NOTICES.md
    README.md
```

不建立通用 SDK、插件框架、依赖注入容器或数据库层。MVP 只有上述真实需要的边界。

## 5. 启动与配置

### 5.1 启动顺序

```text
进程启动
  → 初始化 QtWebEngine
  → 加载 qrc:/config/manifest.json
  → 完整校验 Manifest
      ├─ 失败：进入全屏配置错误页，不创建业务 WebView
      └─ 成功：创建 AppController 和模型，进入 Mock 登录页
```

Manifest 校验必须在显示工作台前完成。解析失败不能回退到硬编码的宽松配置。

### 5.2 Manifest 结构

```json
{
  "schemaVersion": 1,
  "users": {
    "demoA": { "password": "demo-only", "displayName": "演示用户 A", "role": "roleA" },
    "demoB": { "password": "demo-only", "displayName": "演示用户 B", "role": "roleB" }
  },
  "roles": {
    "roleA": ["appWeb", "appKline"],
    "roleB": ["appWeb", "appNative"]
  },
  "modules": [
    {
      "id": "appWeb",
      "type": "web",
      "name": "Web 业务",
      "entryUrl": "qrc:/web-demo/index.html",
      "allowedLocalPrefixes": ["qrc:/web-demo/"],
      "allowedNavigationOrigins": [],
      "allowedResourceOrigins": []
    },
    {
      "id": "appNative",
      "type": "native",
      "name": "本机工具",
      "program": "/usr/bin/<验收机固定程序>",
      "args": []
    },
    {
      "id": "appKline",
      "type": "kline",
      "name": "行情中心",
      "entryUrl": "qrc:/web-kline/index.html"
    }
  ]
}
```

`qrc` 页面不按网络 Origin 比较，只允许命中当前模块的精确资源前缀。替换为内网 Web 页面时，清空 `allowedLocalPrefixes`，`entryUrl` 必须使用 HTTPS，并分别列出允许的顶层导航 Origin 和页面确实依赖的资源 Origin。配置仍编译进 `qrc`，不从用户可写目录覆盖。

### 5.3 校验规则

- `schemaVersion` 必须等于程序支持的版本。
- 用户名、角色 ID、模块 ID 非空且唯一；用户引用的角色必须存在。
- 角色引用的模块必须存在；模块类型只允许 `web`、`native`、`kline`。
- Web URL 必须是受支持的 `qrc` 页面或 HTTPS URL；禁止 HTTP 降级、用户信息段和通配 Origin。
- `qrc` 入口必须位于模块自己的 `allowedLocalPrefixes` 下；HTTPS 入口的精确 Origin 必须包含在顶层导航白名单中。
- Native `program` 必须是绝对路径，`args` 只能来自只读清单且数量、长度受限。
- K 线入口必须指向应用自身 `qrc` 资源，不允许远程 URL。
- 任一未知字段若影响安全语义，应按配置错误处理，不静默忽略。

## 6. 核心功能实现

### 6.1 Mock 登录与权限

`MockAuthService` 直接读取已经通过校验的用户定义。登录过程保留约 `300–500ms` 的异步状态反馈，但不发起网络请求。

```text
login(username, password)
  → 输入长度与空值检查
  → 与只读 Mock 用户匹配
  → 成功：建立内存 Session，按 role 生成可见模块
  → 失败：返回统一错误，聚焦密码输入框
```

- 只接受 `demoA/demo-only` 和 `demoB/demo-only`。
- 不记录密码，不把输入写入日志，不创建 token/cookie。
- QML 只根据 `ModuleListModel` 渲染入口；直接请求未授权模块时由 `AppController` 再校验一次并拒绝。
- 退出时清空 Session、标签、Web Profile 的 cookie/cache，返回登录页。

### 6.2 工作台与任务标签

`TabListModel` 使用模块 ID 作为唯一键：

- `workbench` 固定为首项，不可关闭。
- Web/K 线首次打开时新增标签；重复打开只激活已有标签。
- 关闭活动标签后激活左侧相邻标签，没有相邻业务标签时回到工作台。
- 切换标签不销毁对应页面实例，保留 Web 滚动位置和 K 线缩放区间。
- 退出登录或进程退出才销毁全部业务标签。
- 原生应用不进入标签模型。

QML 必须实现原型已验收的 roving tab 焦点：活动标签 `TabFocus`，方向键/Home/End 切换，关闭后焦点回到相邻标签。

### 6.3 指定 Web 页面

#### Profile 策略

- 业务 Web 标签共享一个仅当前进程有效的 Profile，便于同一演示会话内复用 cookie。
- 使用内存 cookie/cache；不在用户目录持久化会话。
- K 线使用独立离线 Profile，禁止 HTTP/HTTPS 网络请求。
- 退出登录时清理业务 Profile；不与系统浏览器共享 Profile。

#### 导航策略

顶层页面、服务器重定向和 `window.open` 都必须经过 `UrlPolicy`：

```text
请求 URL
  → QUrl 解析成功？
  → scheme/host/有效端口组成的 Origin 精确命中？
  → 是否属于当前模块白名单？
      ├─ 是：允许
      └─ 否：拒绝，保留当前页并显示“已阻止打开未授权地址”
```

- 禁止字符串前缀判断，避免 `allowed.example.evil`、端口变化和 HTTP 降级绕过。
- 默认拒绝新窗口；若目标业务确需新窗口，MVP 仍在当前受控标签内处理且重新校验，不交给系统浏览器。
- 拦截并取消下载请求；MVP 不提供文件下载能力。
- 证书错误直接失败，不提供“继续访问”。
- 发布构建不开启远程调试和 DevTools。
- `loadStarted` 进入加载态，`loadFinished(true)` 进入可用态，`loadFinished(false)` 或渲染进程异常进入可恢复错误态。
- 错误页面由 QML 外壳呈现，不加载网络返回的自定义错误脚本。

资源来源控制与顶层导航分开。真实目标页若依赖 CDN、字体、接口或 WebSocket，必须在 T0B 列清依赖并逐项加入 `allowedResourceOrigins`；不能直接放开 `*`。

### 6.4 原生应用拉起

`NativeLauncher` 只接受模块 ID，不接受来自输入框、URL 或 Web 页的程序路径和参数：

```text
launch(moduleId)
  → 当前角色是否授权
  → 模块是否为 native
  → program 是否与已校验清单完全一致
  → QFileInfo：存在、普通文件、可执行
  → QProcess 直接使用 program + args 启动，不经过 shell
```

- 启动期间禁用入口，防止重复拉起。
- 路径缺失或不可执行时显示“未找到指定应用”。
- Qt 返回启动失败时显示“应用启动失败”，允许重试。
- 启动成功定义为 Qt 已成功创建进程并取得有效 PID；不声称目标窗口已经完成业务初始化。
- 不调用 `sh -c`、`bash -c`、`system()`，不在 PATH 中搜索替代程序，不尝试第二个候选路径。
- MVP 不跟踪退出状态、不终止外部应用、不传递登录票据。

### 6.5 K 线模块

正式程序不把整个浏览器原型塞进 WebView，只提取 K 线所需页面和资源：

- `index.html`：图表容器、语义摘要和空/错状态。
- `echarts.min.js`：固定为验收版本并本地化。
- `mock-market.json`：固定、可审查、无真实行情。
- `kline.js`：日 K 数据、自然周聚合、自然月聚合、缩放、平移、十字线和重置。
- `styles.css`：只包含图表区域样式，不复制 QML 外壳样式。

页面通过 `qrc:/web-kline/index.html` 加载，设置以下 CSP 基线：

```text
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';
img-src 'self' data:;
connect-src 'none';
object-src 'none';
base-uri 'none';
form-action 'none';
frame-src 'none'
```

- 页面不实现 QWebChannel 或通用 JSBridge。
- K 线 Profile 对 HTTP/HTTPS 请求一律拒绝，断网时必须完整运行。
- 日 K 固定显示最近 60 条；周 K 按自然周聚合后显示 52 条；月 K 按自然月聚合后显示 18 条。
- 聚合规则：开盘取首条、收盘取末条、最高取最大、最低取最小、成交量求和。
- 十字线浮层使用中文日期、开盘、最高、最低、收盘、成交量字段；当前点变化时同步更新底部表格和可访问文本摘要。
- 为兼容目标 QtWebEngine，页面脚本避免未经 T0A 验证的新 JavaScript 语法。

### 6.6 UI 落地

- `Theme.qml` 集中定义已验收颜色、字体、间距、圆角和控件高度，QML 页面不散落重复色值。
- 顶栏、状态轨道、侧栏、标签栏采用稳定网格尺寸；业务内容使用剩余空间。
- 所有按钮、输入和图标按钮最小命中区域为 `44×44px`。
- 图标使用编入 `qrc` 的 SVG，不使用 Emoji 或在线图标资源。
- 控件提供 `Accessible.name`、选中/展开状态和可见焦点；模态框关闭后回到触发入口。
- 监听窗口 DPI/尺寸变化，在 `820×480` 逻辑尺寸以上保持可用；禁止按视口宽度缩放字号。
- 遵循系统减少动态效果设置；加载动画只用于局部状态。

## 7. 状态模型与接口

### 7.1 核心状态

| 对象 | 状态 |
|---|---|
| 应用 | `Starting / ConfigError / LoggedOut / LoggedIn` |
| 登录 | `Idle / Submitting / Failed` |
| Web | `Loading / Ready / Error / Blocked` |
| K 线 | `Loading / Ready / Empty / Error` |
| Native | `Idle / Starting / Started / Missing / Failed` |

状态使用枚举和明确转换，不用多个互相矛盾的布尔值组合。

### 7.2 `AppController` 向 QML 暴露的最小接口

```text
只读属性
  appState
  currentUser
  currentRole
  activeModuleId
  modulesModel
  tabsModel

命令
  login(username, password)
  logout()
  openModule(moduleId)
  activateTab(moduleId)
  closeTab(moduleId)
  refreshModule(moduleId)
  launchNative(moduleId)
```

QML 不直接读取 Manifest、不自行拼 URL、不直接创建 QProcess。所有授权和类型分发都经过 `AppController`。

## 8. 安全边界

| 信任区 | 数据/能力 | 处理原则 |
|---|---|---|
| 可信 | 编译进 `qrc` 的程序、Manifest、图标和 K 线资源 | 启动时完整校验，运行期只读 |
| 低信任 | 指定 Web 页面及其跳转内容 | 精确 Origin、无 Bridge、禁下载、证书失败即拒绝 |
| 不可信输入 | 用户名、密码、URL 触发的导航 | 长度/格式检查；Mock 凭证不记录；导航重新校验 |
| 外部系统 | 被 QProcess 拉起的麒麟应用 | 固定路径/参数；独立窗口；无票据和 IPC |

必须纳入单元或真机验证的安全用例：

- `https://allowed.example.evil`、不同端口和 HTTP 降级均被拒绝。
- 30x 重定向至未授权 Origin 被拒绝。
- `window.open`、下载和证书错误不会绕过容器策略。
- 未授权角色不能通过直接调用控制器打开模块。
- Manifest 缺字段、重复 ID、未知类型或错误引用时只显示配置错误页。
- Native 路径/参数不能由用户输入、Web 页面或用户目录配置修改。
- K 线页面在断网环境下没有任何网络请求。

## 9. 构建与交付

### 9.1 T0A 环境基线

在验收机执行并记录：

```bash
cat /etc/os-release
uname -m
uname -r
echo "$XDG_SESSION_TYPE"
cmake --version
gcc --version
qmake -v
dpkg-query -W 'qt*' | sort
```

还需确认 QtWebEngine 运行示例、中文字体、输入法、GPU 渲染和软件渲染回退是否正常。T0A 输出写入后续真机验收记录，不回填生产级文档。

### 9.2 架构策略

- MVP 的权威交付架构由验收机 `uname -m` 决定，不根据行业经验猜测。
- 若只能先提供一台机器，优先使用现有决策中的 ARM64 飞腾/鲲鹏机器；x86_64 可用于开发期冒烟。
- C++/QML 代码不得包含架构分支；第三方资源必须是纯 JS/SVG/数据或有对应架构包。
- 若 T0A 额外安排 `.deb` 探路，架构名使用 Debian 规范：ARM64 为 `arm64`，x86_64 为 `amd64`；结果只记为实验，不纳入 MVP DoD。
- 后续要求双架构交付时，应在两个原生或受支持的构建环境分别构建；不把 Intel Mac 上的 ARM 模拟结果作为真机结论。

### 9.3 CMake 约束

- `CMAKE_AUTOMOC`、`CMAKE_AUTORCC`、`CMAKE_AUTOUIC` 开启。
- QML、Manifest、SVG、Web/K 线资源统一由 `resources.qrc` 编入产物。
- 只链接实际使用的 Qt 模块，不引入 Boost、Web 框架或第三方 JSON 库；Manifest 使用 Qt JSON API。
- 测试使用 Qt Test 并通过 CTest 执行。
- Release 构建关闭远程调试和测试入口，保留必要符号包由交付流程决定。

### 9.4 离线依赖与许可证

内网无公网场景下，以下内容必须随源码或受控制品一并准备：

- 目标架构 Qt/QtWebEngine 开发包及运行依赖的来源说明。
- ECharts `6.1.0`、所选 Lucide SVG 及对应许可证文本。
- `THIRD_PARTY_NOTICES.md` 和依赖版本/校验值清单。
- CMake/GCC 工具链版本说明和离线构建脚本。
- 不在内网构建阶段执行 `npm install`、访问 CDN 或下载字体。

## 10. 测试方案

### 10.1 自动化检查

| 层级 | 检查内容 | 工具 |
|---|---|---|
| C++ 单元 | Manifest 校验、Mock 登录、角色过滤、标签单实例、URL Origin 判断 | Qt Test + CTest |
| QML 组件 | 模型绑定、焦点路径、状态切换的最小冒烟 | Qt Quick Test（目标环境可用时） |
| K 线页面 | 日/周/月数据量、非空画布、缩放/平移、中文浮层、断网 | Playwright，仅作为开发/验收工具 |
| 构建 | Debug/Release 编译、资源存在、无未解析运行库 | CMake/CTest/`ldd` |

安全关键逻辑至少覆盖：合法/非法 Origin、端口差异、重定向、重复模块 ID、未知角色、未授权模块和不可执行程序。

### 10.2 麒麟真机验收

按 `MVP-demo需求.md` 的 A01–A12 执行，并补充：

- `1440×900`、`1366×768` 和目标机实际 `100% / 125% / 150%` 缩放截图。
- X11/Wayland、中文字体、输入法、键盘焦点和外部应用窗口行为。
- 断网后本地 K 线可用，指定 Web 显示可恢复错误。
- 连续打开/切换/关闭 Web 与 K 线 20 次，无崩溃或持续白屏。
- 记录一次冷启动、空载内存和打开 K 线后的内存，仅作为基线，不宣称生产 SLA。

### 10.3 完成判定

- CTest 全部通过。
- A01–A12 全部通过且有截图/日志记录。
- 控制台和应用日志无未处理异常、敏感输入或真实业务数据。
- 指定验收机从源码构建、启动和完整演示闭环完成。
- 实现与 UI 原型的可见差异均记录并经业务确认。

## 11. 实施顺序

| 阶段 | 实施内容 | 退出条件 |
|---|---|---|
| T0A | 锁定麒麟、CPU、Qt/QtWebEngine、合成器、字体和构建通道 | 环境基线表完整；空 WebEngine 窗口可运行 |
| T0B | 确认 Web URL、Origin、原生程序、ECharts 兼容性和 Mock 数据 | Manifest 内容可冻结；许可证可交付 |
| T1 | 创建 `app` CMake 骨架、资源和日志 | Debug/Release 可编译，麒麟可启动空窗口 |
| T2 | 按 UI 基线实现登录、外壳、工作台、标签和状态组件 | 主要布局与键盘路径通过 |
| T3 | 实现 Manifest 校验、模型和模块分发 | 无效配置拒绝启动；角色映射正确 |
| T4 | 实现 Mock 登录/退出和权限过滤 | A01–A04 通过 |
| T5 | 实现受控 WebView 和错误恢复 | A05–A07 通过 |
| T6 | 实现固定 QProcess 拉起 | A08–A09 通过 |
| T7 | 提取并嵌入离线 K 线页面 | A10–A11 通过 |
| T8 | 真机回归、基线记录和演示材料 | A01–A12、构建产物和交付文档齐全 |

T2 完成后可并行推进 T4–T7，但 T5/T6/T7 分别受 T0B 对应内容约束。任何 QtWebEngine 或 ARM64 阻塞必须在 T0A 暴露，不能留到 T8。

## 12. 风险与处理

| 风险 | 触发信号 | 处理 |
|---|---|---|
| 目标镜像缺 QtWebEngine 或版本过旧 | T0A 示例无法运行、ECharts 白屏 | 优先使用行内批准的兼容 Qt 套件；必要时调整 ECharts 并重验 |
| ARM64 依赖缺失 | CMake 找不到模块或 QtWebEngineProcess 无法启动 | 提前准备 ARM64 原生构建机和离线包，不在 Intel Mac 上硬闭环 |
| 真实 Web 页依赖多 Origin | 页面部分资源失败、重定向越界 | T0B 抓取依赖清单，最小化增加资源 Origin，不放开通配符 |
| 目标页证书不被 Chromium 信任 | `loadFinished(false)`、证书错误 | 使用行内受信证书链；禁止代码忽略证书错误 |
| GPU/驱动兼容问题 | 黑屏、渲染进程退出 | 记录驱动和 QtWebEngine 日志；仅在真机验证后采用批准的软件渲染参数 |
| 中文字体或 DPI 差异 | 截断、字形替换、控件错位 | T0A 锁字体；必要时随包提供已批准字体并重新截图验收 |
| 原生程序路径跨镜像不同 | 文件不存在或不可执行 | 每个验收镜像冻结一份编译期 Manifest，不做运行时路径搜索 |
| 外网到内网反馈慢 | 修复验证周期过长 | x86 麒麟 VM 前移冒烟；依赖和构建工具全量离线化 |

## 13. 开工前必须回填

| 决策 | 当前默认 | 必须确认时间 |
|---|---|---|
| 麒麟 V10 子版本、CPU/型号、X11/Wayland | 未知；ARM64 优先但以验收机为准 | T1 前 |
| Qt/QtWebEngine/Chromium 与授权方式 | 使用验收镜像兼容版本 | T1 前 |
| Web 演示页与 Origin | 先用 `qrc` 离线页 | T5 前 |
| 原生应用绝对路径与参数 | 验收机中选一个固定程序 | T6 前 |
| ECharts 兼容性与许可证归档 | `6.1.0` / Apache-2.0 | T7 前 |
| K 线 Mock 数据 | 复用原型固定数据，禁止真实行情 | T7 前 |
| 银行名称、Logo 和最终文案 | `XX银行` 占位 | 最终 UI 验收前 |

如果这些输入尚未拿到，可以完成方案评审和 T1/T2 外壳开发；不得用猜测值完成对应功能的最终验收。

## 14. 需求追踪

| MVP 模块/用例 | 技术落点 |
|---|---|
| M1 / A12 门户外壳与真机 | QML 表现层、AppController、CMake、T0A/T8 |
| M2 / A01–A04 Mock 登录权限 | ManifestService、MockAuthService、ModuleListModel |
| M3 / A05–A07 内嵌 Web | WebModulePage、业务 Profile、UrlPolicy |
| M4 / A08–A09 原生拉起 | NativeLauncher、只读 program/args、QProcess |
| M5 / A10–A11 K 线 | 独立离线 Profile、ECharts、本地 Mock 数据、CSP |
| S1 | NativeLauncher 不经 Shell，不接收用户路径/参数 |
| S2 | 精确 Origin、重定向/弹窗/下载/证书错误拦截 |
| S3 | 仅两个假账号；输入不落日志 |
| S4 | K 线资源和数据全部本地化，网络请求为零 |
| S5 | 不实现 QWebChannel 或通用 JSBridge |

## 15. MVP 技术完成定义

- [ ] T0A/T0B 已回填，Qt、CPU、Web、Native 和图表依赖已锁定。
- [ ] `mvp-demo/app` 可在指定麒麟真机编译、启动并完成演示。
- [ ] Manifest 无效时拒绝进入工作台；普通用户不能覆盖白名单。
- [ ] Mock 登录、角色菜单、标签、Web、Native、K 线均按 UI 基线实现。
- [ ] Web 越界、下载、弹窗、证书错误和 Native 非白名单路径均被拒绝。
- [ ] K 线断网可用且没有特权 Bridge。
- [ ] CTest 与 A01–A12 全部通过。
- [ ] 构建产物、构建运行说明、演示脚本、验收记录和第三方许可证齐全。
