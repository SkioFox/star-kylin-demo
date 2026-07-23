### 技术栈选型
底座技术栈选哪个?这决定后续全部实现路径。

  1. Qt/QML (C++) ✔
     麒麟官方生态,原生性能最强,内嵌web用QtWebEngine。最能兑现"媲美原生"。推
     荐。
  2. Electron
     web栈开发最快、内嵌web最自然,但内存/启动/图表帧率难达原生目标。
  3. Tauri (Rust)
     比Electron轻,但麒麟系统WebView碎片化,K线性能受web渲染上限约束。

目标运行的CPU架构?影响编译工具链与第三方依赖选型。

  1. [✔] ARM64 (飞腾/鲲鹏)
  麒麟大量部署在国产ARM芯片,通常是主战场。
  2. [✔] x86_64
  兼容常规Intel/AMD PC。

当前这一步你想要什么产出?

  1. 仅需求分析文档 ✔
     把上面的分析细化成一份完整需求/架构文档(如 
     REQUIREMENTS.md),暂不写代码。
  2. 分析 + M0 骨架
     确认技术栈后,顺带搭建可编译启动的项目骨架。
  3. 先只讨论,不落地
     继续对齐需求,暂不产出文件。

### Mac电脑的问题

⏺ 能开发,但不能只在 Mac 上闭环。分两件事说清楚:

  能在 Mac 上做的

  Qt/QML + QtWebEngine 本身是跨平台的,macOS
  上能写、能编、能跑。所以业务逻辑、QML 
  界面、大部分交互的日常迭代在 Mac 上没问题。

  Mac 上做不了、必须 Linux/麒麟的

  你的交付物是麒麟(Linux)的 .deb,ARM64/x86_64。这些在 macOS
  上原生做不了:
  - 打 .deb:Debian 打包工具链只在 Linux 上;macOS 产不出
  .deb。
  - 麒麟系统集成:托盘、DPI、主题跟随、.deb 签名安装。
  - X11/Wayland:macOS 用 Cocoa,根本不是这两者——我们文档里最
  关键的"合成器决定能否嵌入"这类问题,Mac 上验证不了。
  - 国密链路、QtWebEngine/Chromium 
  的麒麟版本行为、性能基线:全依赖真实麒麟环境。

  所以"Mac 写代码 → 直接打包 →
  拷到行内电脑验证"这条路中间缺了一个 Linux 构建环节,跨不过
  去。而且只靠"偶尔拷到行内机器试"这种长反馈循环,遇到
  Wayland/DPI/国密这些坑会非常痛。

  推荐做法(取决于你的 Mac 芯片)

  关键分叉:你的 Mac 是 Apple Silicon(M 系列)还是 Intel?
  - Apple Silicon(大概率):它本身就是
  ARM64,和飞腾/鲲鹏同架构。可以在本地跑 麒麟 V10 ARM64 
  虚拟机(UTM/Parallels/VMware Fusion),ARM64
  原生、不用模拟、速度可用。→ 在这个 VM 
  里开发+冒烟测试,几乎等价于在国产 ARM 
  机器上跑,最后再上行内真机做 M-1。
  - Intel Mac:只能跑 x86_64 麒麟 VM;ARM64 得靠 QEMU
  模拟(慢)或交给行内 CI 出 ARM 包。

  统一的构建方式:用 Docker/容器在麒麟或近似 Debian 环境里出
  .deb(Apple Silicon 上 linux/arm64 容器原生跑,快),这样你
  Mac 上和行内 CI 上能用同一套可复现构建。

  落到我们的计划

  - 日常开发:Mac + 本地麒麟 VM(Apple Silicon 强烈建议)。
  - 出包:容器化 Linux 构建,不在 macOS 原生打。
  - 最终验证:仍然是行内真机 M-1(这点文档已写),VM
  不能替代真机的性能/国密/合规结论。

  ⚠ 还有个非技术但常见的坑:银行内网通常禁止外部/个人电脑接入
  ,代码可能不允许带出内网。这会直接影响"Mac 开发 +
  拷进去验证"是否合规——这条你得先跟行内确认,否则开发模式可能
  整个要变(比如只能在行内配的麒麟开发机上做)。

## demo问题
demo用什么语言写?这决定整个 demo 的工程形态: C++/QML、pthon3
K 线图怎么实现? → 内嵌 web 图表库、原生
现在就开始搭建吗? → 先不写,再确认需求

## 架构问题

### Intel x86_64 机器上可以通过以下方式交叉生成ARM64 .deb：

  - 使用 aarch64-linux-gnu 交叉编译器。
  - 准备完整的 ARM64 sysroot。
  - 准备 ARM64 版本的 Qt、QtWebEngine、QML 插件和运行库。
  - 给 CMake 配置 ARM64 toolchain file。

  也可以使用 ARM64 Docker/QEMU 模拟构建，但 QtWebEngine编译和依赖安装会比较慢，稳定性也较差。

  不能做的是直接用当前 x86_64 Qt 工具链编译，然后把CPack 的架构字段改成 arm64。这样只是“ARM64 文件名”，里面的 ELF 二进制仍然是 x86_64，麒麟 ARM 无法运行。、当前新增的 build-deb.sh 会主动阻止这种情况。

  因此：

  - Intel 机器可以作为 ARM64 交叉构建机。
  - 但需要额外的 ARM64 工具链和 Qt 依赖。
  - 最可靠方案仍是 ARM64 麒麟/Linux 原生构建机。
  - 最终 ARM 包必须在 ARM64 麒麟真机安装、启动和验收，

Intel 机器只能完成交叉编译验证，不能替代真机验收。ARM Mac 可以更可靠地生成 Linux ARM64 .deb，但仍有边界。

### Apple Silicon 本身运行 macOS，不能直接用 macOS 编译器生成麒麟 Linux 二进制。
 
 通过docker容器运行：

  docker run --platform linux/arm64 ...

容器内运行的是真实 ARM64 Linux 用户空间，不需要 QEMU模拟 CPU。因此可以稳定生成真正包含 AArch64 ELF 的arm64.deb，比 Intel Mac 模拟 ARM64 可靠很多。
但它只证明“ARM64 Linux 包有效”，还不能自动证明“麒麟可运行”。最终可靠性取决于：

  - 容器的 glibc 版本不能高于目标麒麟。
  - Qt、QtWebEngine、QML 插件版本要与麒麟环境一致。
  - Debian 依赖包名和版本需要匹配麒麟软件源。
  - QtWebEngineProcess、Chromium 资源、sandbox、GPU 和中文字体必须真机验证。

  推荐分级：

  1. ARM Mac + ARM64 Ubuntu/Debian 容器：生成 ARM64开发验证包，可靠。
  2. ARM Mac + 与目标麒麟一致的 ARM64 容器/sysroot：可作为正式构建通道候选。
  3. ARM64 麒麟原生机器或官方构建环境：最终交付最可靠。
  4. ARM64 麒麟真机安装和 A01–A13：最终支持声明的必要条件。

  还应检查包内二进制，而不只看包名：

  dpkg-deb -f package_arm64.deb Architecture file extracted/opt/star-kylin-demo/bin/star-kylin-demo
  readelf -h extracted/opt/star-kylin-demo/bin/star-kylin-demo

  预期分别看到 arm64、ARM aarch64 和 AArch64。ARM Mac能很好地解决 ARM64 构建问题，但 x86_64 最终包仍建议使用 x86_64 Linux/麒麟构建通道。

### 在 ARM Mac 上应使用：

  docker run --platform linux/arm64 ...

容器内需要安装 ARM64 版本的 Linux Qt、QtWebEngine、QML和 C++ 工具链。进入容器后确认：
  uname -m
  dpkg --print-architecture

  应分别得到类似：

  aarch64
  arm64

  然后执行项目脚本：

  STAR_KYLIN_EXPECTED_DEB_ARCH=arm64 ./tools/build-deb.sh

  脚本会生成：

  mvp-demo/app/dist/arm64/star-kylin-demo_0.1.0_arm64.deb

  需要注意两点：

  - 现有 star-kylin-qt-smoke:qt5-packaging镜像如果只有amd64 版本，ARM Mac 上可能只是通过模拟运行，不能直接作为ARM构建环境。需要构建或获取对应的 linux/arm64镜像。
  - ARM Mac 生成的是有效的 Linux ARM64 包，但仍需在麒麟ARM64 真机验证 QtWebEngine、运行依赖、字体、GPU 和桌面入口，才能作为最终麒麟包。

因此结论是：ARM Mac 可以承担 ARM64 .deb 的开发构建和验证，前提是使用真正的 ARM64 Linux/Qt 构建环境；x86_64 包继续由 Intel Mac 或 x86_64 Linux/麒麟环境生成。

### 现在本地这个star-kylin-demo_0.1.0_amd64.deb是通过同样方式生成

  mvp-demo/app/dist/amd64/star-kylin-demo_0.1.0_amd64.deb

  通过相同思路生成的：

  - Intel Mac，宿主架构 x86_64
  - x86_64 Ubuntu 22.04 Docker 容器
  - 容器内使用 Linux Qt 5.15、QtWebEngine、CMake、CTest 和 CPack
  - 执行 mvp-demo/app/tools/build-deb.sh
  - CTest 7/7 通过
  - 包内 Architecture 检查为 amd64
  - SHA-256：dceefea1cafdfed42e4de7a7bec0c65b995ed6dfa0d06d0ee4e589d9c77b9cd7

  ARM Mac 可以复制这套流程，只需要换成真正的 ARM64 Ubuntu/麒麟 Qt 构建镜像，并执行：STAR_KYLIN_EXPECTED_DEB_ARCH=arm64 ./tools/build-deb.sh

  这样两个包的构建流程就是对称的：Intel Mac 产出 amd64，ARM Mac 产出 arm64。

### Intel Mac生成x86 deb流程

通过x86_64 Docker 构建镜像完成, 不是直接用 macOS 编译器。

  本机环境当：

  Mac CPU: Intel x86_64
  Docker: x86_64 Linux VM
  容器系统: Ubuntu 22.04 x86_64
  Qt: 5.15 + QtWebEngine
  构建工具: CMake + Ninja + CTest + CPack

  实际执行方式等价于：

  cd star-kylin-demo

  docker run --rm \
    -v "$PWD/mvp-demo/app:/workspace" \
    -w /workspace \
    -e STAR_KYLIN_EXPECTED_DEB_ARCH=amd64 \
    -e STAR_KYLIN_BUILD_DIR=/workspace/build-verify \
    -e STAR_KYLIN_STAGING_DIR=/workspace/staging-script-
    amd64 \
    -e STAR_KYLIN_OUTPUT_DIR=/workspace/dist/amd64 \
    star-kylin-qt-smoke:qt5-packaging \
    ./tools/build-deb.sh

  其中 star-kylin-qt-smoke:qt5-packaging 是你本机当时已经存在的 Docker 镜像，里面安装了 Ubuntu、Qt 5.15、QtWebEngine、CMake、Ninja 和 DEB 打包工具。

  mvp-demo/app/tools/build-deb.sh 在容器中依次执行：

  检查 uname -m 为 x86_64
          ↓
  映射 Debian 架构为 amd64
          ↓
  CMake Release 配置
          ↓
  CMake install 生成 staging
          ↓
  CPack 生成 amd64.deb
          ↓
  dpkg-deb 检查 Architecture=amd64
          ↓
  生成 SHA-256

  项目目录通过 Docker bind mount 映射到 /workspace，所以容器生成的文件会直接出现在宿主机：

  mvp-demo/app/dist/amd64/
  ├── star-kylin-demo_0.1.0_amd64.deb
  └── star-kylin-demo_0.1.0_amd64.deb.sha256

  整个二进制编译和 DEB 打包都发生在 x86_64 Ubuntu 容器中，macOS 只负责运行 Docker 和保存源码、产物。
