# 麒麟工作台离线交付物

当前可交付目录：[kylin-sky-demo-offline-amd64-0.2.1-5-20260730.2](./kylin-sky-demo-offline-amd64-0.2.1-5-20260730.2/)。它依据 `mvp-demo/客机麒麟实机基线信息/star-kylin-amd64-baseline-2026-07-28.txt` 制作，只支持记录中的 Kylin V10 SP1 release 2503 amd64 基线。

`20260730.2` 是 `0.2.1-5` 的安装器修订版。它改用固定顺序的 `dpkg --install` 安装本地依赖和应用，以规避部分客户麒麟 APT 将本地应用 DEB 路径错误降级为相对路径的问题；应用二进制与 `20260730.1` 相同。

交付时同时提供目录内的 `.tar.gz`、`.tar.gz.sha256` 和未解压目录。目标机必须通过 `sudo ./install.sh` 安装，不要拆分或单独安装其中的 DEB。
