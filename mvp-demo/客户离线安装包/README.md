# 星麒业务工作台离线交付物

- `star-kylin-demo-offline-amd64-0.1.0-20260726.3`：原始离线包，三个本地 DEB 在一次 Kylin APT 事务中求解；部分客户机的 APT 2.0 不会将前两项本地依赖作为候选，导致应用依赖未满足。
- `star-kylin-demo-offline-amd64-0.1.0-20260729.1`：安装器修复版。应用二进制不变，改为先使用 `dpkg` 离线安装两个 WebEngine 运行时包，再安装应用，并在写入前严格校验已采集的客户基线。客户机应使用此版本。

每个交付目录均有独立 `README.md`、`install.sh`、`SHA256SUMS` 和对应压缩包的 SHA-256 文件。
