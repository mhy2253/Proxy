# shadowsocks-rust 一键部署

这个目录提供一个用于 **Ubuntu ARM64 / aarch64** 服务器的一键部署脚本，用来快速安装和启动 `shadowsocks-rust` 服务端。

## 功能说明

脚本会自动完成以下操作：

- 下载 `shadowsocks-rust` 最新指定版本安装包
- 解压并安装 `ssserver`、`ssservice`
- 自动生成服务端密钥
- 自动写入配置文件
- 自动创建 `systemd` 服务
- 自动启动服务并设置开机自启

## 使用方法

直接执行下面这条命令：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/mhy2253/Proxy/main/Setup_and_Deployment/install_shadowsocks_rust.sh)