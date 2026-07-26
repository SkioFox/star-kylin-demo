# amd64 麒麟虚拟机验证环境任务

> 建立日期：2026-07-24  
> 状态：**本地 amd64 麒麟 VM 预验证已完成：`0.1.0-20260726.3` 已安装，从开始菜单验证登录、离线 Web、K 线和互联网示例；原生 `CTest 7/7` 通过，`kylin-acceptance` 快照已创建。客户真机、ARM64 与离线依赖包门禁仍未关闭。**  
> 范围：仅建立一台本地 amd64 银河麒麟验证虚拟机，并从宿主机通过 SSH 管理它。

## 1. 目标与边界

目标是在 Intel Mac 上建立一台与已知客户参考环境尽可能接近的 `amd64` 银河麒麟 VM，用于本项目的预验证：应用图形界面、QtWebEngine、安装包、桌面入口、SSH 自动化和日志采集。

该 VM 是开发前置验证环境，**不能替代客户参考机的 T0A.0 原始基线采集，也不能据此宣称客户麒麟兼容或关闭 A01--A13**。客户参考环境当前已知为：银河麒麟 V10 SP1、`amd64`、Intel Xeon Gold 6248R、Linux `5.4.18`；glibc、Qt 和 QtWebEngine 版本仍须从客户机只读采集确认。

明确不做：第二台 VM、ARM64 仿真、桥接到公司局域网、X11 转发验收、客体内的真实客户数据或凭据。

## 2. 宿主机盘点

| 项目 | 实测值 | 判断 |
|---|---:|---|
| 宿主系统 | macOS 12.7.4 (Monterey), Intel x86_64 | 符合 VirtualBox Intel host 支持范围 |
| CPU | Intel Core i5-5287U，具备 `VMX` | 可使用同架构硬件虚拟化 |
| 内存 | 16 GB；自检时即时可用约 5.3 GB | 单 VM 初始分配 4 GB，避免宿主换页 |
| 可用磁盘 | 56 GiB（2026-07-24 复核） | 下载 4.38 GB ISO 后将低于运行门槛；**下载前应达到至少 60 GiB，下载后和创建客体前至少保留 55 GiB** |
| 现有虚拟化软件 | 未发现 | 可干净安装 |
| 本地麒麟 ISO | 未发现 | 必须由持有授权的一方提供 |

## 3. 方案择优

### 3.1 候选比较

| 方案 | 结论 | 原因 |
|---|---|---|
| **VirtualBox 基础包（选用）** | 适合 | GPLv3 基础包；官方明确支持 Intel macOS 12；同为 x86_64，不需要 QEMU 跨架构模拟；自带快照和 NAT 端口转发。 |
| UTM/QEMU | 备选 | UTM 是 Apache-2.0 前端，基于 QEMU，也支持 Hypervisor.framework；但此场景不需要它的跨架构仿真能力，VirtualBox 的 Intel 客体和命令行网络配置更直接。 |
| VMware Fusion / Parallels | 不选 | 不属于本次开源方案范围。 |

不安装 VirtualBox Extension Pack：基础包即可满足图形控制台、NAT、SSH 转发和快照；扩展包为不同许可证，且本任务不需要 USB 直通或远程显示能力。

### 3.2 开源资料与决策依据

- [VirtualBox 用户手册：支持的宿主机](https://www.virtualbox.org/manual/ch01.html#hostossupport)：列出 macOS 12 与 Intel 硬件要求。
- [VirtualBox 下载页](https://www.virtualbox.org/wiki/Downloads)：提供 macOS/Intel 安装包和校验和。
- [VirtualBox 许可 FAQ](https://www.virtualbox.org/wiki/Licensing_FAQ)：基础包为 GPLv3；扩展包许可证不同。
- [VirtualBox NAT 端口转发](https://www.virtualbox.org/manual/ch06.html#natforward)：支持将宿主端口安全地映射到客体 SSH。
- [VirtualBox 快照](https://www.virtualbox.org/manual/ch01.html#snapshots)：可在一台 VM 内维护可回滚的基线。
- [UTM 项目说明](https://github.com/utmapp/UTM)：UTM 基于 QEMU，具备全系统仿真和 Hypervisor.framework 加速，作为备选方案保留。

## 4. 固定配置

| 配置项 | 固定值 | 说明 |
|---|---|---|
| VM 名称 | `star-kylin-amd64` | 仅此一台 |
| 客体 ISO | 经授权的银河麒麟 V10 SP1 `amd64` Desktop ISO | ISO 文件名、SHA-256 和来源需归档 |
| CPU | 2 vCPU | 宿主机为双核四线程，保留资源给 macOS |
| 内存 | 4096 MB | 结合当前宿主可用内存确定的初始值；仅在宿主资源充足且真实 QtWebEngine 验证需要时上调 |
| 磁盘 | 60 GB 动态分配 VDI | 不预分配；2026-07-24 因桌面安装器要求全盘安装至少 50 GB，从初始 40 GB 扩展至 60 GB；创建前仍需留至少 55 GiB 宿主可用空间以容纳 ISO、依赖和快照差异 |
| 图形 | VMSVGA，128 MB 显存，**关闭 3D** | 首次设置出现 VMSVGA 输出错误和无响应表现后关闭 3D；保留该处置记录，后续以真实 QtWebEngine 页面验证 |
| 网络 | NAT | 不向局域网暴露客体 |
| SSH | `127.0.0.1:2222 -> guest:22` | 仅本机可访问；禁止 `0.0.0.0` 监听 |
| 文件传输 | `scp` / `rsync -e ssh` | 不依赖共享目录或 Guest Additions |
| UI 验收 | VirtualBox 图形控制台 | SSH 仅用于构建、日志和自动化；不使用 X11 转发代替 UI 验收 |

## 5. 执行跟踪

### V0 前置条件

- [x] **V0.1 宿主机兼容性盘点**：确认 Intel x86_64、VT-x、16 GB 内存和 macOS 12.7.4。
- [x] **V0.2 虚拟化方案选择**：选定 VirtualBox 基础包，不使用 Extension Pack。
- [x] **V0.3 磁盘空间处理**：下载 ISO 前宿主可用空间达到至少 60 GiB，下载后和创建客体前至少保留 55 GiB；2026-07-24 下载前为 76 GiB。
- [x] **V0.4 合规安装介质**：已从[麒麟官网试用下载](https://www.kylinos.cn/support/trial/)的“银河麒麟桌面操作系统 V10 -> Intel（不包括 12 代）”入口下载 `Kylin-Desktop-V10-SP1-2503-HWE-Release-20250430-X86_64.iso`（4.38 GB）。2026-07-24 本地 SHA-256 为 `1b67f3c98132142a15cce21f10422124635eda7d4cf3761372b0fe668c60ce35`，与官网公布值一致；它是本地预验证介质，不能证明与客户补丁/Qt 运行时完全一致。

### V1 宿主软件

- [x] **V1.1 安装 VirtualBox 基础包**：通过 Homebrew cask 安装；不安装 Extension Pack。2026-07-24 已从官方源下载、由 Homebrew 校验并通过 macOS 安装器完成安装；版本为 `7.2.14r174565`。
  - 完成证据：`VBoxManage --version` 输出、macOS 系统扩展批准记录。
- [x] **V1.2 启动自检**：打开 VirtualBox 并确认可创建 x86_64 Linux VM。
  - 完成证据：`VirtualBox.app` 可启动；`VBoxManage list hostinfo` 显示硬件虚拟化为 `yes`、支持平台为 `x86`、CPU 为 4 个逻辑处理器；当前无已注册 VM。

### V2 安装一台麒麟客体

- [x] **V2.1 创建 VM**：2026-07-24 已创建并启动唯一的 `star-kylin-amd64`；配置为 2 vCPU、4096 MB、60 GB 动态 VDI、UEFI、ICH9、VMSVGA 128 MB/3D、NAT。SSH 转发已预置为 `guestssh,tcp,127.0.0.1,2222,,22`。
  - 边界：不创建第二台 VM，不启用桥接网络。
- [x] **V2.2 图形安装麒麟**：安装、普通验证账号创建、首次桌面登录及 SSH 基线采集均已完成。
  - 完成证据：桌面截图、`/etc/os-release`、`uname -m`、`dpkg --print-architecture`。
- [x] **V2.3 安装 SSH 服务**：经客体软件源安装并启用 `openssh-server`，宿主专用密钥已验证可登录。未修改系统既有的密码 SSH 策略；NAT 转发仅监听宿主回环地址，后续如需关闭密码登录须在重启复测 SSH 后单独执行。
  - 完成证据：`systemctl is-active ssh`（或发行版等价服务名）和 `ss -lnt`。
- [x] **V2.4 配置本地端口转发**：设置 `guestssh,tcp,127.0.0.1,2222,,22`。
 - 完成证据：`VBoxManage showvminfo star-kylin-amd64 --machinereadable` 中的规则与宿主 SSH 成功日志。

#### V2.3 一次性客体引导

首次 SSH 尚不可达时，必须由客体本地账号在终端完成一次 `sudo` 认证；密码不传给本任务、不写入日志或文档。以账号 `skiofox` 执行以下命令后，后续管理全部使用宿主专用 SSH 密钥：

```bash
sudo bash -c 'set -e; apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server; install -d -m 700 -o skiofox -g skiofox /home/skiofox/.ssh; printf "%s\n" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkKjr8D2Xx6Q35qhE1Q1Ugoxtxw1RHgIMYuOB4isZTq star-kylin-amd64-local-vm" >> /home/skiofox/.ssh/authorized_keys; chown skiofox:skiofox /home/skiofox/.ssh/authorized_keys; chmod 600 /home/skiofox/.ssh/authorized_keys; systemctl enable --now ssh'
```

密码登录不在此引导命令中关闭，必须在宿主密钥登录已验证后再关闭，避免把 VM 锁在 SSH 之外。

### V3 基线、快照与项目预验证

- [x] **V3.1 建立 SSH 主机别名**：宿主 `~/.ssh/config` 使用别名 `star-kylin-amd64`，连接至 `127.0.0.1:2222`；仅写入本机公钥。
  - 完成证据：`ssh star-kylin-amd64 'uname -m'` 返回 `x86_64`。
- [x] **V3.2 采集 VM 基线**：按项目既有 T0A.0 只读命令采集 OS、glibc、Qt、QtWebEngine、QML 和 `QtWebEngineProcess`。
  - 边界：文件标记为“本地 VM 预验证”，不可替代客户参考机输出。
- [x] **V3.3 快照策略**：已建立 `kylin-base`（干净系统）、`kylin-builder`（已安装开发依赖）和 `kylin-acceptance`（已安装并图形验收 `0.1.0-20260726.3`）。始终只有一台运行中的 VM。
  - 完成证据：`VBoxManage snapshot star-kylin-amd64 list`。
- [x] **V3.4 制品验证**：`0.1.0-20260726.3` 已完成原生 `CTest 7/7`、包控制字段与 SHA-256 检查；安装至 `/opt` 后，从开始菜单验证登录、离线 Web、K 线和互联网示例均正常，运行进程与已安装版本一致，未发现本次新增 coredump。已创建 `kylin-acceptance` 快照保留该状态；卸载演练未在此快照中执行。
  - 边界：仅记录预验证；客户真机兼容结论仍等待 T0A.0 与目标环境。

## 6. 固定操作命令（V2.4 以后）

```bash
# 配置 NAT SSH 转发，只监听宿主回环地址。
VBoxManage modifyvm "star-kylin-amd64" \
  --nat-pf1 "guestssh,tcp,127.0.0.1,2222,,22"

# 验证宿主到客体的 SSH。
ssh -p 2222 <guest-user>@127.0.0.1 'uname -m && cat /etc/os-release'

# 摆渡 amd64 包，不通过共享目录。
scp -P 2222 mvp-demo/app/dist/amd64/*.deb <guest-user>@127.0.0.1:/tmp/
```

客体用户名只在实际安装时确定；不得在文档、仓库或命令历史中记录密码。SSH 私钥留在宿主机，客体只保存对应公钥。

## 7. 当前阻塞与下一动作

当前状态：本地 amd64 预验证闭环已完成。唯一 VM 的 SSH、运行时基线、Qt 5.12 原生构建、`CTest 7/7`、CPack、`0.1.0-20260726.3` 安装和开始菜单图形验收均已完成；运行时 DNS 已固定为 VirtualBox NAT 的 `10.0.2.3` 和备用 `223.5.5.5`。Docker Desktop 数据仍不作未经授权的清理。

官网候选来源：[银河麒麟官网试用申请下载](https://www.kylinos.cn/support/trial/)（页面中的“银河麒麟桌面操作系统 V10 -> Intel（不包括 12 代）”）。该页面会打开带文件名、SHA-256、SM3 和签名文件的官方下载页。

下一动作：将同一流程应用到客户 amd64 真机，并在获得 ARM64 真机和对应构建通道后分别完成 ARM64 打包、安装与验收；无网络客户还需准备与客户基线绑定的离线依赖包组。

## 8. 执行记录

| 时间 | 事实与处置 | 证据/影响 |
|---|---|---|
| 2026-07-24 | 宿主确认 macOS 12.7.4、Intel i5-5287U、VT-x、16 GB 内存；选择 VirtualBox 基础包 `7.2.14r174565`。 | `VBoxManage list hostinfo` 显示硬件虚拟化可用；不安装 Extension Pack。 |
| 2026-07-24 | 从麒麟官网试用下载入口取得银河麒麟**桌面** V10 SP1 2503 HWE Intel（非 12 代）ISO。 | 文件为 `Kylin-Desktop-V10-SP1-2503-HWE-Release-20250430-X86_64.iso`，SHA-256 已核验匹配。 |
| 2026-07-24 | 创建唯一 VM `star-kylin-amd64`，初始 40 GB 动态 VDI；麒麟全盘安装提示磁盘低于 50 GB。 | 在尚未写入客体系统前扩展为 60 GB 动态 VDI，不影响宿主实际预分配空间。 |
| 2026-07-24 | 完成专业版、Live、全盘安装；未启用全盘加密或逻辑卷，未安装奇安信网神终端、友虹版式阅读器、WPS。 | 保持本地预验证系统最小化。 |
| 2026-07-24 | 安装完成后卸载 ISO，从已安装硬盘首次启动。 | VM 当前为 `running`，SATA 光驱未挂载 ISO。 |
| 2026-07-24 | 首次设置出现 `VMSVGA: failed to create output target ... VERR_NOT_IMPLEMENTED`，语言页/底部按钮受 `1024x768` 限制。 | 关闭 3D 加速后画面稳定；用户在客体设置调整至 `1366x768`。底部不可见按钮可用 `Tab`、`Enter` 确认。 |
| 2026-07-24 | 首次桌面已进入；普通验证账号为 `skiofox`。 | 用户名不是密码；密码不记录、不传递。 |
| 2026-07-24 | 宿主生成 VM 专用 ED25519 密钥。 | 私钥仅在宿主 `~/.ssh/id_ed25519_star_kylin_vm`；记录公钥指纹 `SHA256:9QEn+Nerifzm4NnkNaT2A/h0TzsYg90PuKh6e6l7NJU`。 |
| 2026-07-25 | 尝试经 VirtualBox 键盘注入 SSH 引导命令；随后从宿主以专用密钥连接 `127.0.0.1:2222`。 | SSH 在横幅交换阶段超时，不能作为 SSH 已启用或公钥已写入的证据。检查时客体处于锁屏/休眠画面，终端输出不可见；待解锁后以短验证命令确认，不盲目重试安装。 |
| 2026-07-25 | 解锁后确认 SSH 引导已成功：`openssh-server` 已安装、`ssh` 为 `active`、22 端口监听，`authorized_keys` 存在。 | 客体普通用户 `skiofox`；宿主初次密钥连接前仍在 SSH 横幅阶段超时。 |
| 2026-07-25 | 读取客体网络与防火墙：`enp0s3=10.0.2.15/24`、网关为 `10.0.2.2`；KSC 防火墙公共入站链默认拒绝，TCP 22 未列入允许项。 | VirtualBox NAT 规则已在宿主监听，但被客体 KSC 入站规则拦截；不是 `sshd` 或 NAT 参数故障。 |
| 2026-07-25 | 临时插入最小防火墙规则：仅允许 NAT 网关 `10.0.2.2` 访问客体 TCP 22。 | `iptables -I KSC_PUBLIC_INPUT 1 -s 10.0.2.2 -p tcp --dport 22 -j ACCEPT` 后，宿主专用密钥 SSH 成功。规则持久化待按 KSC 正确方式确认；重启后必须复测。 |
| 2026-07-25 | 首次宿主 SSH 成功。 | `Kylin V10 SP1`、用户 `skiofox`、主机名 `star-kylin-amd64`、架构 `amd64`、内核 `5.10.0-18-generic`；宿主别名设为 `star-kylin-amd64`。 |
| 2026-07-25 | 完成本地 VM 只读运行时基线采集。 | 原始输出：[amd64麒麟虚拟机验证基线-2026-07-25.txt](./amd64麒麟虚拟机验证基线-2026-07-25.txt)，SHA-256 `39860fe664f3c9507b4d907d43e099864bd4d1dad92cf8102480940ec77514f5`；同一文件保存在客体 `~/star-kylin-local-vm-baseline-2026-07-25.txt`。 |
| 2026-07-25 | 本地 VM 基线结论：glibc 为 `2.31-0kylin9.2k0.3`；Qt Core/QML/WebEngine Core 为 `5.12.12`；`QtWebEngineProcess` 位于 `/usr/lib/x86_64-linux-gnu/qt5/libexec/QtWebEngineProcess`。 | `qmake`、`qtpaths` 未安装，说明开发包尚未装载；本基线仅代表本地官方 ISO VM，不能替代客户参考机 T0A.0 采集。 |
| 2026-07-25 | 解析现有 `star-kylin-demo_0.1.0_amd64.deb` 控制文件。 | 当前包要求 `libc6 (>= 2.34)`、`libqt5core5a (>= 5.15.1)`、`libqt5webengine5 (>= 5.14.1)`、`qml-module-qtwebengine`；与本地 VM glibc 2.31/Qt 5.12.12 不兼容，**不得安装该 Ubuntu 22.04 产物**。 |
| 2026-07-25 | 工程兼容性初查。 | `mvp-demo/app/CMakeLists.txt` 未指定 Qt 5.15 最低版本，使用 Qt5/Qt6 分支；`Dockerfile.ubuntu20` 已注明 Qt 5.12 候选基座。下一步验证麒麟 Qt 5.12 开发包是否足以原生构建和运行。 |
| 2026-07-25 | 在安装开发依赖前创建 VirtualBox 快照 `kylin-base`。 | UUID `157e7af7-8bad-438b-8431-76f221fe283b`；保留初始运行时、SSH 配置和基线，后续可回滚。 |
| 2026-07-25 | 只读检查麒麟软件源与构建依赖安装模拟。 | 源内可用 CMake 3.16.3、Ninja 1.10、Qt Base/QML/WebEngine/SVG dev 5.12.12、`qml-module-qtwebengine`；实际安装将新增 47 包并升级 17 个 glibc/Qt/X11 补丁包，构建前已通过快照隔离。 |
| 2026-07-25 | 原生首次构建失败：缺少 `Qt5QuickControls2Config.cmake`。 | 定位为未安装 `qtquickcontrols2-5-dev`；不是源码业务缺陷。补装该开发包后继续构建。 |
| 2026-07-25 | 原生第二轮构建发现 Qt 5.12 API 差异。 | `Qt::SkipEmptyParts`、`Qt::KeepEmptyParts` 与 `setUrlRequestInterceptor` 在 Qt 5.12 不可用；已增加 Qt 5.12 分支，分别使用 `QString::*EmptyParts` 和 `setRequestInterceptor`，Qt 5.14+/Qt6 保持原 API。 |
| 2026-07-25 | 原生构建与测试通过。 | Release 二进制成功链接；真实 CTest 在构建目录执行 `7/7` 通过。首次使用 `ctest --test-dir` 因 CTest 3.16 不支持该参数而误报无测试，已改为在构建目录执行。 |
| 2026-07-25 | 麟原生 CPack 生成 amd64 包并归档。 | `star-kylin-demo_0.1.0_amd64.deb` SHA-256 为 `d568ea60c089bb667927719c0632e1ebd4b9d06992865f800b8ef264bf6f1327`；产物、SHA 和 ELF 版本证据存于 `amd64麒麟虚拟机验证产物/`。ELF 仅需要 `GLIBC_2.2.5`/`GLIBC_2.4`。 |
| 2026-07-25 | 待安装包前发现客体已锁屏；自动键盘注入被锁屏界面作为一次错误密码尝试。 | 包安装命令未进入终端，未安装 `.deb`；锁屏提示尚有 4 次失败后锁定账号。后续任何键盘注入前必须截图确认终端前台。 |
| 2026-07-25 | 即使已截图确认终端前台，客体在应用启动窗口期间仍可能进入锁屏，自动键盘注入再次未触达终端。 | 停止所有 VirtualBox 键盘注入，避免账号锁定；后续非图形自动化只走已验证 SSH，图形应用启动改由用户在已解锁桌面手动点击桌面入口。 |
| 2026-07-25 | 宿主显示体验调整。 | 客体保持 `1366x768` 作为 MVP 验证工作区；VirtualBox GUI 缩放设为 `125%`（`GUI/ScaleFactor=1.25`），建议配合“全屏模式”放大 Retina Mac 上的实际显示，不影响客体分辨率证据。 |
| 2026-07-25 | 在图形桌面通过开始菜单启动“星麒业务工作台”两次，界面未出现。 | `coredumpctl` 记录两个 `SIGABRT`，均落在 `QtWebEngine::initialize()`；说明桌面入口和安装包已被系统执行，问题发生于应用早期初始化。 |
| 2026-07-25 | 通过 SSH 非图形启动捕获精确错误，未进行任何 VirtualBox 键盘注入。 | 标准错误为 `QtWebEngine::initialize() must be called after the construction of the application object.`；根因是麒麟 QtWebEngine `5.12.12` 与当前较新 Qt 初始化顺序不兼容，不是缺少动态库或桌面入口配置错误。 |
| 2026-07-25 | 修复 `app/src/main.cpp` 的 Qt 5.12 分支。 | Qt `< 5.14` 在构造 `QGuiApplication` 前设置 `Qt::AA_ShareOpenGLContexts`，并在构造后调用 `QtWebEngine::initialize()`；Qt 5.14+/Qt 6 维持原顺序，避免扩大兼容性修改范围。 |
| 2026-07-25 | 将修复后的源码通过 `rsync` 同步到 `~/star-kylin-demo-src`，在 VM 的 `~/star-kylin-demo-build` 增量 Release 编译。 | `cmake --build ... --parallel 2` 成功；在构建目录运行 `ctest --output-on-failure`，结果 `7/7` 通过。 |
| 2026-07-25 | 在 VM 以 `cpack -G DEB` 重新生成修复包。 | `star-kylin-demo_0.1.0_amd64.deb`，SHA-256 `da579d93bf4d87a38974919c3b57caccd9d7c882d9f9600281b5141aec61359f`；运行时依赖显示 `libqt5core5a (>= 5.12.2)`、`libqt5webengine5 (>= 5.9.0)`，与 VM Qt 5.12 基线相容。 |
| 2026-07-25 | 尝试通过 SSH 无交互安装修复包。 | `sudo -n` 正确拒绝并要求本地管理员认证；未使用、传递或记录任何密码。包安装必须由已解锁的 VM 图形终端手动确认，之后再继续 UI 验收。 |
| 2026-07-25 | 通过 VM 图形终端执行 `sudo dpkg -i ~/star-kylin-demo-build/star-kylin-demo_0.1.0_amd64.deb`。 | `/var/log/dpkg.log` 显示 `star-kylin-demo` 于 22:39:47 开始升级、22:39:50 状态为 `installed`；桌面入口文件触发器也完成。后续启动验证必须使用这一时间点之后的新日志，不能以此前 22:29 的旧包 coredump 作结论。 |
| 2026-07-25 | 截图读取已安装初始化修复包的真实终端错误。 | 应用不再 coredump，但 QML 报 `module "QtWebEngine" version 1.10 is not installed`；`Main.qml` 因无法加载 `WebModulePage` 退出。该截图替代了用户手工转录，确认安装步骤成功、错误发生于 QML 导入阶段。 |
| 2026-07-25 | 读取 VM 的 `/usr/lib/x86_64-linux-gnu/qt5/qml/QtWebEngine/plugins.qmltypes`。 | 文件由 `qmlplugindump ... QtWebEngine 1.8` 生成，`WebEngineView` 最高导出版本也是 `1.8`；客体 `qml-module-qtwebengine` 已安装但不提供 1.10，根因与包缺失无关。 |
| 2026-07-25 | 修复 `qml/WebModulePage.qml` 与 `qml/KlineModulePage.qml`。 | 将 `import QtWebEngine 1.10` 降为 `1.8`；页面实际使用的导航、新视图、证书、权限、渲染进程事件 API 均在客体导出的 1.8 范围内。 |
| 2026-07-25 | 完成最终候选包的 VM 原生增量构建、测试和打包。 | `CTest 7/7` 通过；包 SHA-256 为 `4e9c65abadd389403892e856ca08bec056a1787f15fa50c3daed823725a75d42`，归档于 `amd64麒麟虚拟机验证产物/qt512-webengine-qml18-fix-2026-07-25/`。 |
| 2026-07-25 | 从 SSH 将构建目录新版接入当前 X11 图形会话启动，未模拟键盘或鼠标。 | 主进程持续运行，已派生两个 `QtWebEngineProcess`，启动日志为空；随后截图发现客体进入锁屏，故尚不能把该进程结果当作 UI 可见性验收。必须由用户解锁后截图确认。 |
| 2026-07-25 | 排查解锁后 UI 无法持续显示。 | `org.ukui.screensaver` 配置为 `idle-delay=5`，且 `idle-activation-enabled`、`sleep-activation-enabled`、`lock-enabled`、`idle-lock-enabled` 全为 `true`，触发“您已休息”锁屏并遮挡验证窗口。 |
| 2026-07-25 | 为本地 VM 图形验收临时调整验证账号的用户级屏保设置。 | 通过当前用户 D-Bus 执行 `gsettings set org.ukui.screensaver <key> false` 关闭上述四项，并逐项回读为 `false`；不使用 sudo、不修改系统级安全策略。验收结束时如需恢复，逐项设回 `true`。 |
| 2026-07-26 | 开始菜单点击“星麒业务工作台”无界面。 | 读取 `~/.xsession-errors` 确认桌面入口仍运行 2026-07-25 22:31 安装的旧 `/opt` 二进制，报 `QtWebEngine 1.10 is not installed` 后退出；构建目录新版尚未通过 `dpkg` 升级到 `/opt`，不是开始菜单本身失效。 |
| 2026-07-26 | 重新 CPack 当前麒麟原生构建并归档最新候选包。 | 包 SHA-256 为 `5c8e2386e58353dd51d21ab09d9a4ad3867c4d08446559acb33aa6cdab97f5f8`，归档于 `amd64麒麟虚拟机验证产物/latest-2026-07-26/`；待由客体本地图形终端执行 `sudo dpkg -i ~/star-kylin-demo-build/star-kylin-demo_0.1.0_amd64.deb` 后，开始菜单才会使用最新 QML 修复版本。 |
| 2026-07-26 | 增加独立的“互联网示例”模块。 | 该模块使用单独无痕 Web Profile；Manifest 仅允许 `https://www.baidu.com` 作为顶层导航和资源来源，不放开通配 Origin、HTTP、证书错误、下载或弹窗越界。 |
| 2026-07-26 | 已安装 `0.1.0-20260726.2` 修复登录后的空 Profile 崩溃。 | `/opt` 包版本为 `0.1.0-20260726.2`；从开始菜单可启动、登录，并成功显示离线 Web、K 线和互联网示例。 |
| 2026-07-26 | VM 重启后浏览器和互联网示例均不能打开百度。 | 路由及公网 IP 连通，但 DHCP 注入的 DNS 为不可达 `0.191.213.14`、`192.168.2.1`；VirtualBox NAT DNS `10.0.2.3` 可解析。通过 NetworkManager 将“有线连接 1”持久设为 `ignore-auto-dns=yes`、DNS=`10.0.2.3,223.5.5.5` 后恢复。该项只影响 VM 网络，不修改应用。 |
| 2026-07-26 | 新生成的 CTest 可执行文件在 SSH 中无输出、看似失败。 | `kysec-auth` 日志显示麒麟执行控制对每个新哈希弹出“未授权程序”对话框；选择“始终允许”后，`test_auth`、`test_resources`、`test_kline_data` 均通过，随后全量 `CTest 7/7` 通过。开发构建的本地授权不得当作客户交付策略。 |
| 2026-07-26 | 生成发布号包 `0.1.0-20260726.3` 并完成原生回归。 | `CTest 7/7` 通过；包架构 `amd64`、Qt 5.12 运行依赖已检查；SHA-256 为 `b870bacf170a267b9910fd1c4f258577e563cb855e77e3292c8c7310b159fb32`，归档于 `amd64麒麟虚拟机验证产物/external-web-module-verified-20260726.3/`。 |
| 2026-07-26 | 在 VM 图形终端升级安装 `0.1.0-20260726.3` 并完成开始菜单验收。 | `dpkg-query` 确认为 `0.1.0-20260726.3`；从开始菜单启动后登录、离线 Web、K 线和互联网示例均正常，运行进程为 `/opt/star-kylin-demo/bin/star-kylin-demo`；历史 coredump 均早于本轮验收。 |
| 2026-07-26 | 创建 `kylin-acceptance` 快照。 | UUID `5d4b25e0-8521-4eab-be9d-b69038d709eb`；保留 DNS 持久配置、已安装 `.3` 包与已完成图形验收状态，便于继续开发前回滚。 |

## 9. 麒麟原生构建、安装与验证流程（已执行）

本流程用于本地 amd64 VM 预验证；最终客户交付仍须在客户 T0A.0 基线确认后的对应构建通道复验。

1. 在宿主修改 `mvp-demo/app` 源码后，通过 SSH 别名同步：`rsync -az --delete --exclude '.git' --exclude 'build-*' --exclude 'dist' mvp-demo/app/ star-kylin-amd64:/home/skiofox/star-kylin-demo-src/`。
2. 在 VM 原生编译并测试：`cmake --build ~/star-kylin-demo-build --parallel 2`，然后 `cd ~/star-kylin-demo-build && ctest --output-on-failure`。麒麟随附 CTest 3.16 不支持 `ctest --test-dir`，必须进入构建目录执行。首次运行或重编译后，KySec 可能逐个询问新测试二进制的执行授权；仅本地开发 VM 可在核对路径后选择“始终允许”。
3. 在同一构建目录运行 `cpack -G DEB`，再用 `sha256sum star-kylin-demo_<version>_amd64.deb` 归档校验值，用 `dpkg-deb -I` 检查架构和依赖。
4. 由 VM 已解锁桌面中的本地账号执行 `sudo dpkg -i ~/star-kylin-demo-build/star-kylin-demo_<version>_amd64.deb`。每次源码修复、重新 CPack 后都必须再次执行此命令，确保开始菜单运行的是最新包；提权认证只能在客体本地完成，SSH 自动化不接收、不保存密码。
5. 从开始菜单启动“星麒业务工作台”，同时检查进程、`coredumpctl` 和用户会话日志。若菜单无界面，先通过 SSH 执行 `/opt/star-kylin-demo/bin/star-kylin-demo >/tmp/star-kylin-demo.out 2>&1` 取得早期 QtWebEngine 错误，再决定是否修改源码。
6. 验收时须在 VirtualBox 图形控制台进行，不以 SSH/X11 转发代替：登录页、工作台、内嵌离线 Web 页、K 线模块、退出与再次启动均需留证；结束后再做卸载和快照。

### 9.1 VM DNS 与执行授权边界

- 重启后先用 `nmcli -f connection.id,ipv4.ignore-auto-dns,ipv4.dns connection show "有线连接 1"` 确认 DNS 仍为 `10.0.2.3,223.5.5.5`；该 NetworkManager 配置可跨重启保持。若 SSH 不通，还须单独检查此前临时加入的 KSC 入站规则。
- KySec 的“始终允许”按可执行文件哈希记录。开发目录每次重新链接都会得到新哈希，因此可能再次出现提示；不要通过关闭全局执行控制或将未知目录广泛设为可信来规避。
- 客户交付包不能要求用户逐项点“允许”。应由客户安全管理员采用批准的软件源或包签名、发布者信任链完成一次性安装信任；具体机制必须按客户麒麟安全策略确认。
