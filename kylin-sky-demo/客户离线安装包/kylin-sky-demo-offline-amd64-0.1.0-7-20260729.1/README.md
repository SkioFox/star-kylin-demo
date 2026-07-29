# 麒麟工作台 amd64 离线安装包

本包交付 `kylin-sky-demo 0.1.0-7`，只适用于已采集的客户基线：银河麒麟桌面操作系统 V10 SP1（`PROJECT_CODENAME=V10SP1`、`KYLIN_RELEASE_ID=2503`）、`amd64`、glibc `2.31-0kylin9.1k22.0`。

客户基线已安装 Qt Quick、`libqt5svg5`、`libqt5webengine-data` 和 `libqt5webenginecore5`；缺失的下列精确版本随包提供：

- `libqt5webengine5_5.12.12-0kylin1k0.9_amd64.deb`
- `qml-module-qtwebengine_5.12.12-0kylin1k0.9_amd64.deb`

安装器会拒绝架构、系统发行版或上述已安装基线不匹配的设备，也会拒绝已有不同版本的两项随包依赖。它不会访问网络、执行系统升级或从软件源下载软件包。

## 安装

将整个目录或对应 `.tar.gz` 完整摆渡到目标机，解压后在目录中执行：

```bash
sudo ./install.sh
```

脚本先校验 `SHA256SUMS`，再调用 `apt-get --no-download` 以本地路径安装依赖和应用。不要单独执行 `dpkg -i kylin-sky-demo_0.1.0-7_amd64.deb`，否则 QML WebEngine 依赖无法由离线包统一解析。

## 启动与卸载

安装成功后可从开始菜单启动“麒麟工作台”，或执行：

```bash
/opt/kylin-sky-demo/bin/kylin-sky-demo
```

卸载应用：

```bash
sudo apt remove kylin-sky-demo
```

## 构建与验证状态

应用 DEB 由原生 amd64 麒麟 V10 SP1 构建机以 Release 配置生成，包字段为 `Version: 0.1.0-7`、`Architecture: amd64`，其 SHA-256 由 `SHA256SUMS` 记录。已完成 CMake 编译、CPack、依赖字段和包内容静态检查。

当前构建机通过非交互 SSH 运行 CTest 时，KySec 对新的测试二进制哈希阻塞执行；因此当前版本的 CTest、GUI、客户实机安装和开始菜单回归仍需在获授权的目标机完成。该包未包含受信任麒麟签名；若客户机强制 DEB 签名，必须由安全团队按受控流程提供签名变体，不得使用 `--no-debsig` 或降低安全策略绕过。
