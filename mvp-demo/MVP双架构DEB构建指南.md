# 星麒业务工作台 MVP 双架构 DEB 构建指南

本指南用于从干净仓库生成两个独立的 Linux 安装包：

- `arm64`：ARM64 麒麟/Linux 构建机或 ARM Mac 的 Linux ARM64 容器
- `amd64`：x86_64 麒麟/Linux 构建机或 Intel Mac 的 Linux amd64 容器

两个包必须分别在对应架构的麒麟真机验收。Docker 中生成的包是开发/构建验证证据，不能替代麒麟真机验收。

开发过程中已发生问题、根因、处置和未关闭门禁见 [MVP构建问题与处置记录.md](./MVP构建问题与处置记录.md)。

## 1. 前置条件

- Git
- Docker Desktop 或 Docker Engine，支持 Linux 容器
- 仓库源码已下载
- 目标架构对应的 Qt 5.15、QtWebEngine 和 Ubuntu/Kylin 运行依赖可从批准的软件源或离线源获取

进入应用目录：

```bash
cd star-kylin-demo/mvp-demo/app
```

## 2. 网络、缓存与团队镜像

首次构建镜像会下载 Ubuntu 索引以及 Qt、QtWebEngine、Chromium、LLVM、QML 等依赖，下载量约数百 MB，最终 Builder 镜像约 1 GB。慢或失败通常来自三条彼此独立的网络链路：Docker Hub 基础镜像、Ubuntu APT 软件源和 Docker Desktop 的虚拟机网络。

### 2.1 代理与镜像源

- 在 Docker Desktop 的 `Settings > Resources > Proxies` 配置 HTTP/HTTPS 代理；仅在宿主终端设置代理不保证 Docker 守护进程和构建容器可用。
- 无法使用 Docker Desktop 全局代理时，可在镜像构建命令中传入 `HTTP_PROXY`、`HTTPS_PROXY`、`NO_PROXY`：

```bash
docker build \
  --build-arg HTTP_PROXY=http://<proxy-host>:<port> \
  --build-arg HTTPS_PROXY=http://<proxy-host>:<port> \
  --build-arg NO_PROXY=localhost,127.0.0.1,<internal-domain> \
  ...
```

- Docker Hub Registry Mirror 只能加速基础镜像拉取，不能加速 Ubuntu APT 依赖下载。
- 生产/麒麟构建必须使用行内批准的 Kylin APT 镜像、制品库或离线依赖包；不要把不受控公网镜像源作为最终构建依赖。

### 2.2 缓存与日常使用

- 日常构建不要加 `--pull`，避免每次都强制请求 Docker Hub；只在主动升级基础镜像时执行一次带 `--pull` 的镜像刷新。
- Docker 的缓存层只有整条 `apt-get install` 成功后才会保存。中途断网或停止构建会丢失该层，因此第一次成功构建的 Builder 镜像应保留。
- Builder 镜像不依赖项目源码。构建镜像时只使用 `packaging/docker/` 作为 Docker context，避免向 Docker 守护进程传输编译目录、截图和历史产物。
- 团队应将首次成功构建的 `star-kylin-build:amd64` 与 `star-kylin-build:arm64` 推送到内网 Harbor/制品库。后续开发者只拉取批准镜像并运行 `build-deb.sh`，不重复下载 QtWebEngine 依赖。
- 若由平台团队维护 BuildKit，可为 APT 归档和索引配置持久缓存；项目侧仍应以已批准的 Builder 镜像为可复现基线，而不是依赖个人电脑缓存。

## 3. 构建镜像

项目提供了固定构建依赖清单：[Dockerfile](./app/packaging/docker/Dockerfile)。镜像以 Ubuntu 22.04 为基础，包含 CMake、Ninja、Qt 5.15、QtWebEngine、QML 模块和 CPack 所需工具。

### Intel Mac 或 x86_64 Linux

```bash
docker build --platform linux/amd64 \
  -t star-kylin-build:amd64 packaging/docker
```

### ARM Mac 或 ARM64 Linux

```bash
docker build --platform linux/arm64 \
  -t star-kylin-build:arm64 packaging/docker
```

ARM Mac 上的 Docker 构建必须使用 `linux/arm64` 镜像。不要使用只有 amd64 架构的旧镜像，否则 Docker 可能启用模拟运行。

如需主动更新 Ubuntu 基础镜像，在上述命令中额外加入 `--pull`；更新后应重新执行本指南的构建、包验证和麒麟验收。

## 4. 生成安装包

构建脚本会根据构建容器的 `uname -m` 选择包架构，并检查 CPack 输出的真实 `Architecture` 字段。它拒绝把 x86_64 二进制改标为 ARM64。

### 生成 amd64 包

```bash
docker run --rm --platform linux/amd64 \
  -v "$PWD:/workspace" \
  -w /workspace \
  -e STAR_KYLIN_EXPECTED_DEB_ARCH=amd64 \
  star-kylin-build:amd64 \
  ./tools/build-deb.sh
```

产物：`dist/amd64/star-kylin-demo_<version>_amd64.deb` 和对应 `.sha256`。

### 生成 arm64 包

```bash
docker run --rm --platform linux/arm64 \
  -v "$PWD:/workspace" \
  -w /workspace \
  -e STAR_KYLIN_EXPECTED_DEB_ARCH=arm64 \
  star-kylin-build:arm64 \
  ./tools/build-deb.sh
```

产物：`dist/arm64/star-kylin-demo_<version>_arm64.deb` 和对应 `.sha256`。

脚本默认使用 Release 构建、CTest、CMake install 和 CPack。可通过以下变量调整路径或并行度：

```text
STAR_KYLIN_BUILD_DIR
STAR_KYLIN_STAGING_DIR
STAR_KYLIN_OUTPUT_DIR
STAR_KYLIN_BUILD_JOBS
STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS
```

`STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS` 必须替换为目标麒麟软件源中实际存在的运行依赖，不能直接把 Ubuntu 包名当作麒麟最终依赖。

## 5. 验证包架构和校验值

在项目根目录、对应构建镜像中执行，不能只根据文件名判断：

```bash
pkg=dist/amd64/star-kylin-demo_0.1.0_amd64.deb
sha256sum -c "$pkg.sha256"
test "$(dpkg-deb --field "$pkg" Architecture)" = amd64
dpkg-deb --contents "$pkg"
```

ARM64 包将 `amd64` 替换为 `arm64`，并使用 `dist/arm64` 路径。还可以检查 ELF 头：

```bash
rm -rf /tmp/star-kylin-package
dpkg-deb -x "$pkg" /tmp/star-kylin-package
file /tmp/star-kylin-package/opt/star-kylin-demo/bin/star-kylin-demo
readelf -h /tmp/star-kylin-package/opt/star-kylin-demo/bin/star-kylin-demo | grep 'Class\|Machine'
```

预期 ARM64 包显示 `ARM aarch64`/`AArch64`，amd64 包显示 `x86-64`/`Advanced Micro Devices X86-64`。

## 6. 麒麟安装验收

将对应架构包和 `.sha256` 摆渡到同架构、同 Qt 基线的干净麒麟机器，在批准的依赖源可用后执行：

```bash
sha256sum -c star-kylin-demo_<version>_<arch>.deb.sha256
sudo dpkg -i star-kylin-demo_<version>_<arch>.deb
/opt/star-kylin-demo/bin/star-kylin-demo
sudo dpkg -r star-kylin-demo
test ! -e /opt/star-kylin-demo
```

同时检查桌面入口启动，并执行需求中的 A01–A13、S1–S6 和适用 N1–N8。ARM64 与 amd64 必须分别留存安装日志、截图、资源基线和已知问题记录。

## 7. 常见错误

- `Unsupported build architecture`：构建机不是 `aarch64/arm64` 或 `x86_64/amd64`。
- `Refusing to relabel the package`：请求的目标架构与构建机不一致；不要绕过该检查。
- CMake 找不到 Qt/WebEngine：构建镜像没有对应架构的 Qt 开发包，或 Qt 版本未锁定。
- 包能生成但麒麟安装失败：检查麒麟运行依赖、QtWebEngineProcess、QML 插件、Chromium `.pak`/locales 和软件源包名。
- ARM Mac 上生成的包无法在麒麟启动：先确认容器是 `linux/arm64`，再在麒麟真机检查 Qt/系统 ABI；macOS 本身不是 Linux 运行环境。
- Docker 构建长期停留在 `apt-get install`：检查 Docker Desktop 代理、Ubuntu APT 连通性和是否正在首次下载 QtWebEngine；优先从内网制品库拉取已构建的 Builder 镜像。

Intel Mac 可可靠生成 amd64 开发包；ARM Mac 可可靠生成 arm64 开发包，前提是使用对应架构的 Linux 容器。两者都不能替代最终麒麟真机验收。
