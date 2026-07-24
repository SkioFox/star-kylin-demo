# MVP Demo 开发验证记录

> 日期：2026-07-24
> 结论：开发通道验证通过；麒麟/目标架构验收未完成。

## 验证环境

- 构建容器：由 `app/packaging/docker/Dockerfile` 新建的 `star-kylin-build:amd64` / Qt 5.15 开发环境
- 安装冒烟容器：`star-kylin-qt-smoke:qt5-visual`
- 基础系统：Ubuntu 22.04 x86_64
- 构建类型：Release
- 构建工具：CMake、Ninja、CTest、CPack DEB
- 说明：该环境只证明 x86_64 Linux 开发通道，不替代麒麟真机或 ARM64 证据。

## 可复核命令

在 `mvp-demo/app` 目录执行：

```bash
docker build --platform linux/amd64 \
  -t star-kylin-build:amd64 packaging/docker
docker run --rm --platform linux/amd64 \
  -v "$PWD:/workspace" -w /workspace \
  -e STAR_KYLIN_EXPECTED_DEB_ARCH=amd64 \
  star-kylin-build:amd64 ./tools/build-deb.sh
```

最近一次结果：`7/7` CTest 通过，包含 Manifest、标签、Mock 登录、Native、URL Policy、资源和 K 线数据测试。

## 安装闭环

试验包：`app/dist/amd64/star-kylin-demo_0.1.0_amd64.deb`

- `dpkg -i`：通过
- Xvfb 下命令行启动：通过，进程持续运行至测试超时；仅输出测试环境要求的 `Sandboxing disabled by user.`
- `dpkg -r star-kylin-demo`：通过
- 卸载后 `/opt/star-kylin-demo`：无残留
- SHA-256：`b23284be77c16af6ae782b89c5b2eb81062f567ddfe4258093f9ed08ddf52494`
- `sha256sum -c`：通过；`dpkg-deb --field Architecture`：`amd64`
- 二进制 ELF：`Advanced Micro Devices X86-64`

包内容已检查，包含：

- `/opt/star-kylin-demo/bin/star-kylin-demo`
- Desktop Entry 和应用图标
- `THIRD_PARTY_NOTICES.md`
- ECharts、Lucide 许可证文本

双架构构建入口为 `app/tools/build-deb.sh`。该脚本已在 amd64 通道完整验证，并会拒绝把 amd64 二进制改标为 arm64。ARM64 包必须在 `uname -m` 为 `aarch64`/`arm64` 且具备目标 QtWebEngine 依赖的构建机运行同一脚本后，才能形成 ARM64 开发证据。

从干净仓库构建依赖镜像和执行双架构流程见 [MVP双架构DEB构建指南.md](./MVP双架构DEB构建指南.md)。

## UI 与功能开发证据

已有 Qt 5.15 开发截图和烟测输出位于 `app/output/qt5-smoke/` 与 `app/output/qt5-smoke-min/`，覆盖登录、工作台、Web、越界拦截、Native 失败态、K 线日/周/月视图及最小 `820x480` 视口。

这些截图属于开发期证据，不构成 A12 麒麟真机验收。

## 未关闭门禁

- T0A：ARM64/x86_64 麒麟版本、Qt/QtWebEngine 基线、两套对应架构构建通道和两类真机空窗口。
- T0B：真实内网页面、固定 Native 绝对路径、目标 QtWebEngine 的 ECharts 兼容性、摆渡资源与许可证确认。
- T8：`arm64`、`amd64` 两个 `.deb`、两类干净同基线麒麟机安装/启动/卸载，以及双架构 A01–A13、S1–S6、N1–N8 全量证据。

不得使用本记录中的 amd64 包或 Intel Mac 结果宣称麒麟或 ARM64 支持。

## 客户操作系统参考对照(2026-07-24)

客户已提供一台参考机信息(Talk-History §客户操作系统参考),另有 ARM64 机器尚未拿到真机。

### 客户参考机基线（已知事实）

以下信息来自 `Talk-History.md` 的客户参考摘录；客户尚未提供该机的 glibc、Qt 和 QtWebEngine 原始命令输出，因此这些运行时版本不属于已知基线。

| 属性 | 值 |
|---|---|
| OS | 银河麒麟桌面操作系统 **V10SP1** |
| 架构 | **amd64 (x86-64)** |
| CPU | Intel Xeon Gold 6248R |
| 内核 | 5.4.18-142-generic |

### 与当前 mvp-demo 设计的对照

| 维度 | 当前状态 | 对照结果 |
|---|---|---|
| **架构** | `dist/amd64/` 有真实 amd64 `.deb`；ADR-0002 将 ARM64 定为战略主战场 | ✅ 指令集匹配。现有 amd64 参考机是当前第一个可关闭的 T0A 门禁；不改变 ARM64 与 amd64 双架构最终交付。 |
| **glibc** | 当前 `.deb` 声明 `libc6 (>= 2.34)` | ⚠️ 高风险待核实。客户内核版本不能推导 glibc 版本；必须执行 `getconf GNU_LIBC_VERSION` 和 `dpkg-query -W libc6` 后判断。 |
| **Qt/QtWebEngine** | 当前包还依赖 `libqt5core5a (>= 5.15.1)`、`libqt5webengine5 (>= 5.14.1)`、`libqt5webenginecore5` 与 QML WebEngine 模块 | ⚠️ 待 T0A 核实版本、包名、`QtWebEngineProcess` 和 Chromium 资源。只检查 Qt Core 不足以判断可运行性。 |
| **内核** | ELF 标注 `for GNU/Linux 3.2.0` | ✅ 内核 5.4.18 满足该 ELF 最低内核 ABI；这不代表 glibc、Qt 或桌面运行时兼容。 |

### glibc 风险的缓解路径

| 路径 | 做法 | 代价 |
|---|---|---|
| **A. 更低 glibc 基座重建** | 在客户 glibc 基线确认后，用不高于该基线的受控 Linux/sysroot 重建；重新检查 DEB `Depends` 和 ELF。 | 中；Ubuntu 20.04 只是候选，不能预先承诺具体 `libc6` 最低版本。 |
| **B. 应用自带 Qt + 受控运行时** | 仅在 Qt/QtWebEngine 缺失或版本不符时采用；所有随包库也必须以兼容客户 glibc 的基座编译。 | 高；包体积、许可证、QtWebEngineProcess、`.pak`、locales 和安全维护责任增加。 |
| **C. 先关闭 amd64 T0A** | 收集真实基线，先执行依赖模拟安装和空 WebEngine 冒烟，再决定 A/B。 | 最低；当前应优先执行。 |

**建议：先走 C。** 在客户 amd64 参考机记录以下命令输出后，再选择构建基座和 Qt 装载策略：

```bash
cat /etc/os-release
uname -m
getconf GNU_LIBC_VERSION
dpkg --print-architecture
qmake -v
dpkg-query -W -f='${binary:Package}\t${Version}\n' \
  libc6 libqt5core5a libqt5qml5 libqt5webengine5 libqt5webenginecore5
find /usr -name QtWebEngineProcess -type f 2>/dev/null
```

`mvp-demo/app/packaging/docker/Dockerfile.ubuntu20` 是待验证的候选构建基座，不是已证明兼容客户机的兜底结论。

### 客户机基线采集方法

以下命令必须在客户提供的 amd64 银河麒麟参考机执行，不能以 Intel Mac、Ubuntu Docker 或本地虚拟机结果替代。命令只读取系统和软件包信息，不安装软件、不修改配置，也不需要 `sudo`。

可在麒麟桌面打开“终端”应用（通常可尝试 `Ctrl+Alt+T`），或从获准访问的机器使用 SSH 登录：

```bash
ssh <username>@<customer-kylin-host>
```

登录后执行，结果会保存到当前用户家目录：

```bash
{
  echo '=== os-release ==='
  cat /etc/os-release

  echo '=== architecture ==='
  uname -m
  uname -r
  dpkg --print-architecture

  echo '=== glibc ==='
  getconf GNU_LIBC_VERSION
  dpkg-query -W libc6 2>&1

  echo '=== qt ==='
  qmake -v 2>&1
  qtpaths --qt-version 2>&1
  dpkg-query -W -f='${binary:Package}\t${Version}\n' \
    libc6 libqt5core5a libqt5qml5 \
    libqt5webengine5 libqt5webenginecore5 2>&1

  echo '=== webengine process ==='
  find /usr -name QtWebEngineProcess -type f 2>/dev/null
} | tee "$HOME/star-kylin-amd64-baseline-$(date +%F).txt"
```

采集文件 `~/star-kylin-amd64-baseline-YYYY-MM-DD.txt` 是 amd64 T0A 的输入。拿到结果前不要安装当前测试 `.deb`，也不要根据内核版本推测 glibc/Qt 版本。

### 采集后的决策规则

| 客户机结果 | 构建决策 |
|---|---|
| glibc 满足当前包的 `libc6 (>= 2.34)`，且 Qt/QtWebEngine/QML 依赖满足 | 当前 Ubuntu 22.04 amd64 包可作为候选，进入干净麒麟机安装验证。 |
| glibc 低于 2.34 但满足较低基座构建后的实际依赖 | 以受控低 glibc 基座或客户麒麟 sysroot 重建；重新检查 DEB `Depends`、QML 和 WebEngine 冒烟。 |
| glibc、Qt 或 QtWebEngine 不满足 | 不直接安装当前包；选择客户麒麟/sysroot 构建，或按兼容 glibc 重建完整自带 Qt 运行时。 |

无论选择哪条路径，只有 amd64 麒麟真机安装、桌面/命令行启动和 A01–A13 通过后，才能关闭 amd64 T0A/T8；ARM64 需在另一台 ARM64 麒麟机独立执行同样过程。

### ARM64 展望

客户还有 ARM64 机器(飞腾/鲲鹏)未拿到。当前 dist/ 仅有 amd64 包,ARM64 构建通道已设计(build-deb.sh 支持 `STAR_KYLIN_EXPECTED_DEB_ARCH=arm64`),但未执行。拿到 ARM 真机后:

- 若为 Apple Silicon Mac:可用 `docker run --platform linux/arm64` 原生构建 ARM64 `.deb`
- 若为 Intel Mac + ARM 麒麟构建机:在构建机上直接执行 `STAR_KYLIN_EXPECTED_DEB_ARCH=arm64 ./tools/build-deb.sh`
- 无论哪种:最终包必须在 ARM64 麒麟真机通过 A01–A13
