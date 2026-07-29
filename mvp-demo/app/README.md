# 星麒业务工作台 MVP 应用

正式 Qt/QML 实现目录。当前开发实现覆盖工程骨架、只读 Manifest、Mock 登录与角色过滤、门户外壳、受控 WebEngine、固定原生程序拉起和离线 K 线。

## 当前实现边界

- Web 使用仅进程内的 Profile；导航、资源、弹窗、下载、证书绕过和权限请求均由白名单/拒绝策略处理。
- Native 仅接收 Manifest 内已授权模块的绝对路径和固定参数，直接使用 `QProcess::startDetached`，不经 Shell 或 PATH 搜索。
- K 线使用随包 ECharts `6.1.0`、`mock-market.json` 和独立离线 Profile。日/周/月显示分别为 60/52/18 条，所有网络请求均被 CSP 和 Profile 策略拒绝。
- `tools/generate-mock-market.mjs` 仅用于开发时冻结合成 JSON；运行时不需要 Node，也不会访问网络。

当前验证来自 Ubuntu 22.04 x86_64 Qt 5.15 开发容器，不构成麒麟或 ARM64 验收。T0A/T0B 未完成前，Native 仅能演示缺失/失败状态，最终固定程序、麒麟 Qt 基线和目标架构包仍待确认。

## 依赖

- CMake 3.16+
- C++17 编译器
- Linux `.deb` 打包工具：CPack、`file`、`dpkg-dev`
- Qt 5.12+ 或 Qt 6，组件：Core、Gui、Qml、Quick、QuickControls2、Test
- Qt 5 额外需要 WebEngine 与 `qml-module-qtwebengine`；Qt 6 需要 WebEngineQuick
- SVG 图标需要对应 Qt SVG 运行插件

T0A 完成后必须锁定一个 Qt 主版本。当前双版本 CMake 入口只用于在环境未冻结前减少无意义返工，不代表最终交付同时支持两个 Qt 主版本。

## 构建

```bash
cmake -S . -B build -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

Linux/麒麟测试包：

```bash
cmake -S . -B build-release -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --parallel
ctest --test-dir build-release --output-on-failure
cmake --install build-release --prefix staging
cpack --config build-release/CPackConfig.cmake
```

双架构交付必须在对应架构构建机分别执行同一脚本：

```bash
# ARM64 麒麟/Linux 构建机，要求 uname -m 为 aarch64 或 arm64
STAR_KYLIN_EXPECTED_DEB_ARCH=arm64 ./tools/build-deb.sh

# x86_64 麒麟/Linux 构建机
STAR_KYLIN_EXPECTED_DEB_ARCH=amd64 ./tools/build-deb.sh
```

产物分别写入 `dist/arm64/` 和 `dist/amd64/`，并生成 `.sha256` 文件。脚本会读取构建机和 `.deb` 的真实架构；不允许通过修改 CPack 标签把 x86_64 二进制伪装成 ARM64 包。

从干净仓库构建 Docker 依赖镜像、生成两个包和执行麒麟验收的完整步骤见 [MVP双架构DEB构建指南.md](../MVP双架构DEB构建指南.md)。
ARM64 的构建机前置条件、制品校验和麒麟安装验收见 [ARM64麒麟构建与验收任务.md](../ARM64麒麟构建与验收任务.md)。

Qt/QML 插件不会被 `dpkg-shlibdeps` 全部发现。Qt 5 测试通道已经提供 Ubuntu/Kylin 常见包名作为默认值；T0A 锁定实际镜像后，通过 `STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS` 覆盖为验收环境的准确依赖，不能直接照搬未验证包名。

Intel Mac 的构建结果不能替代 Linux/麒麟 `.deb` 与真机验收。

## 开发验证

开发容器可用以下命令复跑 QML 窗口截图和交互烟测：

```bash
./tools/capture-ui-smoke.sh
```

生成的 `output/qt5-smoke/` 仅作开发证据。它要求 Xvfb、xdotool、ImageMagick 和中文字体，不属于安装包运行依赖。
