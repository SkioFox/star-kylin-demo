# 麒麟工作台 amd64 离线安装包

本离线包交付 `kylin-sky-demo 0.2.1-4`，用于已采集的客户基线：银河麒麟桌面操作系统 V10 SP1（`PROJECT_CODENAME=V10SP1`、`KYLIN_RELEASE_ID=2503`）、`amd64`、glibc `2.31-0kylin9.1k22.0`。

它不是 ARM64 包，也不适用于其他 V10 SP、其他 release 或非麒麟系统。安装器会在任何写入之前检查架构、发行版、glibc 和 Qt 运行时基线；不匹配时会退出，不会联网、升级系统或替换系统 Qt。

## 包含内容

客户基线已具备 Qt Quick、SVG、QtWebEngine Core/Data 与 Noto CJK 字体。基线中缺少的两个精确版本随包提供：

- `libqt5webengine5_5.12.12-0kylin1k0.9_amd64.deb`
- `qml-module-qtwebengine_5.12.12-0kylin1k0.9_amd64.deb`

应用 DEB、上述依赖、安装器和 SHA-256 清单都位于此目录。安装器使用 `apt-get --no-download`，所有路径均为本地文件，整个安装过程不访问网络。

## 安装

将完整目录或同名 `.tar.gz` 经批准摆渡至目标机。请不要单独执行 `dpkg -i`，否则离线依赖无法统一解析。

```bash
sha256sum -c kylin-sky-demo-offline-amd64-0.2.1-4-20260730.1.tar.gz.sha256
tar -xzf kylin-sky-demo-offline-amd64-0.2.1-4-20260730.1.tar.gz
cd kylin-sky-demo-offline-amd64-0.2.1-4-20260730.1
sudo ./install.sh
dpkg-query -W -f='${Package} ${Version} ${Architecture}\n' kylin-sky-demo
```

预期版本为 `kylin-sky-demo 0.2.1-4 amd64`。成功后，可从开始菜单启动“麒麟工作台”，或执行：

```bash
/opt/kylin-sky-demo/bin/kylin-sky-demo
```

## 验证与卸载

安装后验证登录、中文导航、默认最大化窗口、各市场默认标的、图表周期/缩放、外汇离线页、网络检查和本机应用反馈；详细逐页清单见项目的 `集中验证清单.md`。

卸载仅移除本应用，不移除基线原有 Qt 包：

```bash
sudo apt remove kylin-sky-demo
```

## 签名边界

这是未签名基线包。若客户机强制麒麟 DEB 签名，目标机可能拒绝安装；必须由客户安全团队提供同一 `amd64` 包的受信任签名变体。不得使用 `--no-debsig`、关闭 KySec 或修改客户信任策略绕过安装。
