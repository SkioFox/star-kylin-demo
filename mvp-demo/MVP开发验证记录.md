# MVP Demo 开发验证记录

> 日期：2026-07-23
> 结论：开发通道验证通过；麒麟/目标架构验收未完成。

## 验证环境

- 容器：`star-kylin-qt-smoke:qt5-packaging` / Qt 5.15 开发环境
- 基础系统：Ubuntu 22.04 x86_64
- 构建类型：Release
- 构建工具：CMake、Ninja、CTest、CPack DEB
- 说明：该环境只证明 x86_64 Linux 开发通道，不替代麒麟真机或 ARM64 证据。

## 可复核命令

在 `mvp-demo/app` 目录执行：

```bash
cmake -S . -B build-verify -G Ninja -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build-verify --parallel
ctest --test-dir build-verify --output-on-failure
cmake --install build-verify --prefix staging-verify
cpack --config build-verify/CPackConfig.cmake -B package-verify
```

最近一次结果：`7/7` CTest 通过，包含 Manifest、标签、Mock 登录、Native、URL Policy、资源和 K 线数据测试。

## 安装闭环

试验包：`app/dist/amd64/star-kylin-demo_0.1.0_amd64.deb`

- `dpkg -i`：通过
- Xvfb 下命令行启动：通过，进程持续运行至测试超时；仅输出测试环境要求的 `Sandboxing disabled by user.`
- `dpkg -r star-kylin-demo`：通过
- 卸载后 `/opt/star-kylin-demo`：无残留
- SHA-256：`dceefea1cafdfed42e4de7a7bec0c65b995ed6dfa0d06d0ee4e589d9c77b9cd7`

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
