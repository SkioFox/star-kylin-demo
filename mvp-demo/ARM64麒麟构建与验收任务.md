# ARM64 麒麟构建与验收任务

> 建立日期：2026-07-28  
> 状态：**待执行。当前没有 ARM64 原生构建机或 ARM64 麒麟验收机，尚未生成 `arm64` DEB。**  
> 适用范围：`mvp-demo/app` 的 ARM64 原生构建、安装和验收。该文档不替代 `amd64` 麒麟验证记录。

## 1. 当前结论

- 已完成的 amd64 麒麟 VM 验证不能证明 ARM64 可用。
- 当前 Intel Mac 只能原生构建 amd64。通过 Docker/QEMU 模拟 `linux/arm64` 安装 QtWebEngine 依赖时，`libc-bin` 的 post-install trigger 触发 QEMU `SIGSEGV`；没有生成 Builder、ARM 二进制或 ARM DEB。
- 不允许修改 CPack 的 `Architecture` 字段把 amd64 二进制伪装为 arm64。
- ARM64 包必须由 `uname -m` 为 `aarch64` 或 `arm64` 的原生 Linux 构建通道生成，并在 ARM64 麒麟机器完成安装、启动和卸载闭环。

可用路径按优先级排序：

1. 同一台 ARM64 麒麟机器同时构建和验收。
2. ARM64 Linux/麒麟构建机生成包，摆渡到同基线的干净 ARM64 麒麟验收机。
3. ARM Mac 的原生 `linux/arm64` Docker Builder 仅可生成开发候选包，仍须在 ARM64 麒麟验收机完成最终验证。

不要将 Intel Mac 的 QEMU 仿真、Ubuntu ARM 容器或非 ARM 麒麟机器的结果写为 ARM64 兼容结论。

## 2. 前置条件

需要一台可访问的 ARM64 麒麟或 Linux 构建机；推荐同时准备一台干净的 ARM64 麒麟验收机。若两者为同一台机器，构建前先创建系统快照或明确可回滚基线。

构建机需要：

- `uname -m` 输出 `aarch64` 或 `arm64`，且 `dpkg --print-architecture` 输出 `arm64`。
- CMake 3.16+、C++17 编译器、CPack、`file`、`dpkg-dev`。
- 与目标环境匹配的 Qt 开发包：Core、Gui、Qml、Quick、QuickControls2、Test、SVG、QtWebEngine 与 `qml-module-qtwebengine`。Qt 5.12 或 Qt 6 均可进入工程，但最终以目标机实际基线为准。
- 批准的软件源或离线依赖包。无网络环境不得临时使用公共源，也不得随应用打包 glibc。
- 用于验收的图形桌面；SSH 仅用于源码、制品和日志摆渡，不替代桌面图形验收。

不要记录、传递或要求提供任何系统账号密码、私钥、客户数据或生产凭据。

## 3. T0A 基线采集

先在 ARM64 麒麟验收机执行以下只读命令，并将完整输出保存为 `arm64-kylin-baseline-YYYY-MM-DD.txt`。这一步不安装软件、不修改配置。

```bash
date -Is
uname -a
uname -m
dpkg --print-architecture
cat /etc/os-release
getconf GNU_LIBC_VERSION
printf 'session=%s\n' "${XDG_SESSION_TYPE:-unknown}"
qmake -v 2>/dev/null || true
qtpaths --version 2>/dev/null || true
dpkg-query -W -f='${binary:Package}\t${Version}\n' \
  'libqt5*' 'qml-module-qt*' 'qtbase5-dev' 'qtdeclarative5-dev' \
  'qtwebengine5-dev' 'libqt5svg5-dev' 2>/dev/null || true
find /usr -type f -name QtWebEngineProcess 2>/dev/null
```

归档该文件及其 SHA-256：

```bash
sha256sum arm64-kylin-baseline-YYYY-MM-DD.txt \
  > arm64-kylin-baseline-YYYY-MM-DD.txt.sha256
```

基线确认项：麒麟版本与补丁、glibc、Qt/QtWebEngine/QML 模块、`QtWebEngineProcess` 路径、X11/Wayland、分辨率和缩放。若构建机和验收机不是同一基线，先记录差异并重新评估运行依赖，不能直接复用包。

## 4. 原生 ARM64 构建

### 4.1 直接在 ARM64 麒麟/Linux 构建机

源码位于构建机后，进入应用目录并确认真实架构：

```bash
cd /path/to/star-kylin-demo/mvp-demo/app
uname -m
dpkg --print-architecture
```

只有两项分别为 `aarch64`/`arm64` 后才执行构建。每个可分发包使用新 release，避免覆盖历史制品：

```bash
STAR_KYLIN_EXPECTED_DEB_ARCH=arm64 \
STAR_KYLIN_PACKAGE_RELEASE=20260728.1 \
./tools/build-deb.sh
```

脚本会执行 Release CMake 配置、编译、`CTest`、安装树、CPack、DEB 架构检查和 SHA-256 生成。预期产物：

```text
dist/arm64/star-kylin-demo_0.1.0-20260728.1_arm64.deb
dist/arm64/star-kylin-demo_0.1.0-20260728.1_arm64.deb.sha256
```

如果 Qt 开发包不齐，先通过批准源或离线介质补齐，再重新执行同一命令。不要以跳过测试、关闭 QtWebEngine sandbox、手工改架构字段或使用 QEMU 崩溃后的中间层来绕过问题。

### 4.2 ARM64 Linux Docker 构建机

仅当 Docker 本身运行在原生 ARM64 主机上时使用。构建环境镜像：

```bash
cd /path/to/star-kylin-demo/mvp-demo/app
docker build --platform linux/arm64 \
  -t star-kylin-build:arm64 packaging/docker
```

若官方 Ubuntu Ports 源不可用，可使用已批准的镜像源；不能把公共源作为最终麒麟交付依赖：

```bash
docker build --platform linux/arm64 \
  --build-arg UBUNTU_PORTS_MIRROR=http://<approved-ubuntu-ports-mirror>/ubuntu-ports \
  -t star-kylin-build:arm64 packaging/docker
```

出包：

```bash
docker run --rm --platform linux/arm64 \
  -v "$PWD:/workspace" -w /workspace \
  -e STAR_KYLIN_EXPECTED_DEB_ARCH=arm64 \
  -e STAR_KYLIN_PACKAGE_RELEASE=20260728.1 \
  star-kylin-build:arm64 ./tools/build-deb.sh
```

Docker 结果只是 ARM64 开发候选包，不能替代下一节的 ARM64 麒麟安装验收。

## 5. 制品完整性与架构校验

在构建机、项目根目录运行。不能只根据文件名判断架构：

```bash
cd /path/to/star-kylin-demo/mvp-demo/app
pkg='dist/arm64/star-kylin-demo_0.1.0-20260728.1_arm64.deb'

sha256sum -c "$pkg.sha256"
dpkg-deb --field "$pkg" Package Version Architecture Depends
test "$(dpkg-deb --field "$pkg" Architecture)" = arm64

tmpdir="$(mktemp -d)"
dpkg-deb -x "$pkg" "$tmpdir"
file "$tmpdir/opt/star-kylin-demo/bin/star-kylin-demo"
readelf -h "$tmpdir/opt/star-kylin-demo/bin/star-kylin-demo" | grep 'Class\|Machine'
rm -rf "$tmpdir"
```

通过标准：`Architecture: arm64`，ELF 显示 `AArch64` 或 `ARM aarch64`，校验文件通过。任一项不满足即停止，不得发送到验收机。

同时归档：构建日志、`CTest` 输出、`dpkg-deb --field`、`file`、`readelf` 和 `.sha256`。

## 6. 摆渡到 ARM64 麒麟验收机

只摆渡候选 `.deb` 与同名 `.sha256`，不要使用共享目录替代制品记录。SSH 示例中的主机名、账号和路径按实际环境替换；不在命令或文档中提供密码：

```bash
pkg='dist/arm64/star-kylin-demo_0.1.0-20260728.1_arm64.deb'
ssh <user>@<arm64-kylin-host> 'mkdir -p /tmp/star-kylin-demo/dist/arm64'
scp "$pkg" "$pkg.sha256" \
  <user>@<arm64-kylin-host>:/tmp/star-kylin-demo/dist/arm64/
```

无网络验收机还需要与该 ARM64 基线绑定的离线依赖包组、校验清单及批准的本地安装流程。应用包为 thin `.deb`，依赖必须以 `dpkg-deb --field "$pkg" Depends` 和基线软件源中的实际包名为准。

## 7. ARM64 麒麟安装与图形验收

在干净的 ARM64 麒麟机中执行。先确认制品和机器架构匹配：

```bash
cd /tmp/star-kylin-demo
uname -m
dpkg --print-architecture
sha256sum -c dist/arm64/star-kylin-demo_0.1.0-20260728.1_arm64.deb.sha256
dpkg-deb --field dist/arm64/star-kylin-demo_0.1.0-20260728.1_arm64.deb Architecture Depends
```

期望机器为 `aarch64`/`arm64`，包字段为 `arm64`。随后由具备本地授权的管理员在图形终端安装：

```bash
sudo dpkg -i dist/arm64/star-kylin-demo_0.1.0-20260728.1_arm64.deb
dpkg-query -W -f='${Status}\n${Version}\n' star-kylin-demo
```

若出现依赖缺失，保留 `dpkg` 原始输出，按批准的软件源或离线包组安装准确依赖后再次执行 `dpkg -i`。不要在受控网络或无网络机器上盲目执行 `apt-get -f install`，不要关闭 KySec、WebEngine sandbox 或全局安全策略来换取启动。

验证必须针对已安装路径和开始菜单入口，不能用构建目录二进制代替：

```bash
/opt/star-kylin-demo/bin/star-kylin-demo
```

随后从开始菜单启动“星麒业务工作台”，完成并截图记录：

1. Mock 登录成功与失败状态；使用项目预置的演示账号，不使用真实业务账号。
2. 门户、角色可见模块、标签打开/关闭和刷新。
3. 离线 Web 页面正常加载，越权导航被拦截。
4. K 线日/周/月切换、缩放、悬浮信息和离线数据正常。
5. QtWebEngine 页面无崩溃；如失败，保留终端输出和 `journalctl --user -b`/`coredumpctl` 中对应时间段日志。
6. 桌面入口与命令行入口均启动到安装版本；记录 `/opt/star-kylin-demo/bin/star-kylin-demo` 进程路径。

按 [MVP-demo需求.md](./MVP-demo需求.md) 中 A01--A13、S1--S6 和适用 N1--N8 完成全量验收。ARM64 机器需要独立记录 DPI、字体、输入法、X11/Wayland、GPU 及 20 次模块循环结果。

## 8. 卸载闭环与证据

图形验收完成后，在管理员本地终端执行：

```bash
sudo dpkg -r star-kylin-demo
test ! -e /opt/star-kylin-demo
dpkg-query -W star-kylin-demo || true
```

归档以下内容后，ARM64 验收才可标记完成：

- ARM64 基线与 SHA-256。
- 构建、CTest、CPack、架构与 ELF 检查输出。
- 应用 DEB、SHA-256、`Depends` 字段和离线依赖清单（如适用）。
- 安装、开始菜单、命令行启动、核心页面和卸载截图/日志。
- 已知问题、修复版本和复验结果。

任何一个条件未完成时，状态只能写为“ARM64 候选包”或“ARM64 验证中”，不能写为“ARM64 麒麟已支持”。
