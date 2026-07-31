# Kylin Sky Demo App

首次环境准备、跨平台支持、协作流程和麒麟验收边界见上级目录的[团队协作开发指南](../本机开发指南.md)。

已完成环境准备后：

```bash
./tools/local-dev.sh doctor
./tools/local-dev.sh test
./tools/local-dev.sh run
```

`run` 在前台启动；关闭窗口或按 `Ctrl+C` 停止。后台方式使用 `start` / `stop`。不要在 macOS 或普通 Linux 开发机执行 DEB 安装验证；该步骤只在对应架构的麒麟验收环境执行。
