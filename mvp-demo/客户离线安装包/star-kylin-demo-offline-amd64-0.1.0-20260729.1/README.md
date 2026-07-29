# 星麒业务工作台离线安装包

这是安装器修复版离线包；应用二进制仍为 `star-kylin-demo 0.1.0-20260726.3`。修复版包名中的 `20260729.1` 仅表示离线安装流程修订。

适用基线：银河麒麟桌面操作系统 V10 SP1（`PROJECT_CODENAME=V10SP1`、`KYLIN_RELEASE_ID=2503`）、`amd64`、glibc `2.31-0kylin9.1k22.0`。

客户基线已存在 Qt Quick、`libqt5svg5`、`libqt5webengine-data` 和 `libqt5webenginecore5`；本包提供缺失的精确版本：

- `libqt5webengine5_5.12.12-0kylin1k0.9_amd64.deb`
- `qml-module-qtwebengine_5.12.12-0kylin1k0.9_amd64.deb`

## 安装

将完整压缩包摆渡到客户机后执行：

```bash
sha256sum -c star-kylin-demo-offline-amd64-0.1.0-20260729.1.tar.gz.sha256
tar -xzf star-kylin-demo-offline-amd64-0.1.0-20260729.1.tar.gz
cd star-kylin-demo-offline-amd64-0.1.0-20260729.1
sudo ./install.sh
```

安装器会校验文件和客户基线，再按固定顺序用 `dpkg -i` 离线安装 WebEngine 库、QML 模块和应用。它不使用 `apt --fix-broken install`，不连接网络，也不会安装系统升级包。

如果安装器报告基线不匹配，不要继续执行裸 `apt --fix-broken install`；保存完整报错和以下命令输出，以便制作匹配的依赖包：

```bash
dpkg --print-architecture
cat /etc/os-release
dpkg-query -W -f='${Package}\t${Version}\n' \
  libc6:amd64 libqt5quickcontrols2-5:amd64 libqt5svg5:amd64 \
  libqt5webengine-data libqt5webenginecore5:amd64
```

## 启动与卸载

```bash
/opt/star-kylin-demo/bin/star-kylin-demo
sudo apt remove star-kylin-demo
```

若客户机强制 DEB 签名，仍须由安全团队提供受信任签名变体；不得使用 `--no-debsig` 或降低 KySec 策略绕过。
