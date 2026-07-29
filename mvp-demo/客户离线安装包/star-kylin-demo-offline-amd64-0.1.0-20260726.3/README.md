# 星麒业务工作台离线安装包

适用基线：银河麒麟桌面操作系统 V10 SP1（`KYLIN_RELEASE_ID=2503`）、`amd64`、Qt `5.12.12-0kylin1k0.9` WebEngine 运行时。

本包包含已验证应用 `0.1.0-20260726.3`，以及客户机缺失的下列麒麟原生运行依赖：

- `libqt5webengine5_5.12.12-0kylin1k0.9_amd64.deb`
- `qml-module-qtwebengine_5.12.12-0kylin1k0.9_amd64.deb`

客户基线已存在它们所需的 `libqt5webengine-data`、`libqt5webenginecore5`、Qt Quick、Qt QML 等依赖。本包不包含系统升级包，也不连接网络。

## 安装

将整个目录或压缩包带到客户机，解压后在该目录执行：

```bash
sudo ./install.sh
```

脚本会先校验 `SHA256SUMS`，再以本地文件路径调用 `apt-get --no-download` 安装依赖和应用。不要使用 `dpkg -i` 单独安装应用包。

## 启动与卸载

安装完成后，从开始菜单启动“星麒业务工作台”，或执行：

```bash
/opt/star-kylin-demo/bin/star-kylin-demo
```

卸载应用：

```bash
sudo apt remove star-kylin-demo
```

本离线包只适用于上述基线；若客户机的 `libqt5webengine-data` 或 `libqt5webenginecore5` 不是 `5.12.12-0kylin1k0.9`，安装器会停止，需要重新制作匹配版本的依赖包组。
