# MVP Demo 构建问题与处置记录

> 日期：2026-07-24
> 范围：`mvp-demo` 开发期的源码、Docker、DEB 打包与架构验证。
> 使用方式：本记录保留实际问题和处置证据，不以开发环境结果替代 ARM64/x86_64 麒麟真机验收。

## 当前结论

- Dockerfile 新建的 Ubuntu 22.04 amd64 Builder 已完成独立构建。
- 该 Builder 已从源码完成 Release 编译、CTest `7/7`、CPack、SHA-256、DEB 控制字段和 ELF 架构验证。
- 当前 amd64 开发验证包可完成容器内安装、启动和卸载闭环。
- ARM64 包、ARM64 麒麟真机和两类麒麟最终验收仍未完成，不能标记为支持。

## 问题清单

| ID | 现象与影响 | 根因 | 已采取措施 | 当前状态 / 后续动作 |
|---|---|---|---|---|
| P01 | 早期文档允许“至少一个目标架构包”，与 MVP 的 ARM64+x86_64 双架构目标不一致。 | 需求被写成条件范围，而非强制交付。 | 需求、技术方案和任务拆解已改为 `arm64`、`amd64` 两包均为强制交付；T0A/T8 改为双架构门禁。 | 已修正；等待两类构建机和真机。 |
| P02 | Intel Mac 只能原生生成 amd64，不能形成可信的 ARM64 QtWebEngine 包。 | macOS Intel 主机不是 Linux ARM64 构建环境；仅修改 CPack 架构字段会产生错误包。 | `build-deb.sh` 读取真实 `uname -m` 与 DEB `Architecture`，架构不匹配立即失败。 | 已防止伪 ARM 包；ARM Mac 或 ARM64 Linux/麒麟构建机需执行同一脚本。 |
| P03 | ARM64 Ubuntu 基础镜像可启动，但 Intel Mac 的 QEMU Builder 在 QtWebEngine 依赖层多次长时间无完成缓存。 | Intel 主机上的 ARM 模拟叠加国内软件源网络波动，速度和稳定性不足。 | 停止不完整 QEMU 探测，不把模拟结果当作 ARM 证据。 | 未关闭；改由 ARM Mac/ARM64 原生 Linux 环境验证。 |
| P04 | Docker BuildKit 在 `apt-get install` 阶段进度不透明，网络不稳时看似停滞。 | QtWebEngine 依赖下载量大；BuildKit 输出和中断后的缓存表现不直观。 | 使用传统 Docker builder 完成一次可观察的 amd64 镜像构建，并记录网络、缓存策略。 | amd64 已验证；团队日常应拉取已批准 Builder，而非重复安装依赖。 |
| P05 | 首次 Builder 构建耗时长、网络累计下载数百 MB，重复中断后重新下载。 | QtWebEngine、Chromium、LLVM、QML 依赖体积大；只有整层安装成功后 Docker 才保留缓存层。 | 构建指南增加 Docker Desktop 代理、内网 APT/Harbor、避免日常 `--pull`、预构建 Builder 和 BuildKit 缓存建议。 | 已记录；需要平台/运维提供内网镜像和依赖源。 |
| P06 | 传统 Docker builder 曾把约 153 MB 项目目录发送给守护进程，增加无效等待。 | Dockerfile 不复制项目源码，但构建命令使用了整个 `app` 目录作为 context。 | 构建指南改为仅使用 `packaging/docker/` 作为 Docker context。 | 已修正。 |
| P07 | 对同一构建目录并发执行 CMake/Ninja 时出现 `premature end of file`，测试目标一度找不到。 | 多个验证命令竞争写同一个 `build-*` 目录。 | 使用独立的 `build-dockerfile-amd64`、`staging-*`、`dist/*` 目录；构建脚本支持通过环境变量显式指定。 | 已修正；同一目录禁止并行构建。 |
| P08 | `.sha256` 文件最初只记录包文件名，从项目根目录运行 `sha256sum -c` 找不到包。 | 校验文件在输出目录生成，记录路径与文档执行目录不一致。 | `build-deb.sh` 改为写入相对于 `mvp-demo/app` 根目录的包路径；文档验证命令同步复核通过。 | 已修正。 |
| P09 | 安装冒烟首次使用只读 `/workspace` 挂载失败。 | 测试镜像预设工作目录位于 `/workspace/mvp-demo/app`，只读挂载后无法创建该路径。 | 安装包改挂载到只读 `/packages`，并使用 `/tmp` 作为工作目录。 | 已修正；最新 amd64 包安装、启动、卸载通过。 |
| P10 | 容器内 Xvfb 启动 WebEngine 需要 `QTWEBENGINE_DISABLE_SANDBOX=1`。 | 容器 root/Xvfb 烟测环境不满足 Chromium sandbox 前提。 | 该变量只用于开发容器的图形烟测，未写入应用、Desktop Entry 或 DEB。 | 已隔离；麒麟真机不得以关闭 sandbox 解决运行问题。 |
| P11 | 当前 CMake 默认 Debian 运行依赖来自 Ubuntu 22.04，不能直接视为麒麟最终依赖。 | 麒麟版本、Qt 装载策略、软件源包名尚未由 T0A 锁定。 | 提供 `STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS` 覆盖入口；指南明确要求按麒麟实际源替换。 | 未关闭；T0A 必须给出两类架构的最终依赖清单。 |
| P12 | 默认 Native 绝对路径、真实 Web Origin、目标 QtWebEngine/ECharts 兼容性仍未冻结。 | T0B 依赖业务和验收环境输入。 | 当前 Manifest 使用安全占位值和离线夹具；实现不做路径搜索或通配 Origin。 | 未关闭；T0B 确认后回填并在两架构重验。 |
| P13 | 客户 amd64 参考机仅确认 OS、CPU、内核和架构，不能据此推导 glibc、Qt 或 QtWebEngine 兼容性。 | 客户运行时基线原始命令输出尚未取得。 | 已建立 T0A.0 客户 amd64 基线采集任务，并在验证记录、技术方案和 T0A 补充 glibc、QtWebEngine、QML 模块与 `QtWebEngineProcess` 的采集项。 | 未关闭；优先完成 T0A.0。 |

## 可复核证据

| 证据 | 最新结果 |
|---|---|
| Builder | `star-kylin-build:amd64`，由 `app/packaging/docker/Dockerfile` 构建 |
| CTest | `7/7` 通过：Manifest、标签、Mock 登录、Native、URL Policy、资源、K 线数据 |
| 标准开发包 | `app/dist/amd64/star-kylin-demo_0.1.0_amd64.deb` |
| SHA-256 | `b23284be77c16af6ae782b89c5b2eb81062f567ddfe4258093f9ed08ddf52494` |
| 架构验证 | DEB `Architecture=amd64`；ELF `Advanced Micro Devices X86-64` |
| 安装闭环 | 容器内 `dpkg -i`、Xvfb 命令行启动、`dpkg -r` 和 `/opt` 残留检查均通过 |

完整构建命令见 [MVP双架构DEB构建指南.md](./MVP双架构DEB构建指南.md)，任务门禁见 [MVP任务拆解.md](./MVP任务拆解.md)。

## 未关闭的外部门禁

1. ARM64 原生构建机与 ARM64 麒麟验收机。
2. x86_64 麒麟验收机。
3. 两类验收机的麒麟版本、Qt/QtWebEngine、运行依赖、字体、X11/Wayland 和 GPU 基线。
4. 真实 Web Origin、固定 Native 程序路径与参数。
5. 两个包在各自干净麒麟机的 A01–A13、S1–S6、N1–N8 证据。
