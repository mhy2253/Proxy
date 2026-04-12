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
```

如果服务器没有 `wget`，也可以使用：

```bash
curl -fsSL https://raw.githubusercontent.com/mhy2253/Proxy/main/Setup_and_Deployment/install_shadowsocks_rust.sh | bash
```

## 执行完成后

脚本执行完成后，会输出以下信息：

- 配置文件路径
- 服务端口
- 加密方式
- 自动生成的密码
- 服务运行状态

请保存输出中的密码，客户端连接时需要使用。

## 默认配置

脚本默认使用以下参数：

- 监听地址：`::`
- 端口：`8388`
- 加密方式：`chacha20-ietf-poly1305`
- 传输模式：`tcp_and_udp`

配置文件路径：

```bash
/etc/shadowsocks-rust/config.json
```

服务文件路径：

```bash
/etc/systemd/system/ssserver.service
```

## 常用管理命令

查看服务状态：

```bash
systemctl status ssserver --no-pager
```

查看运行日志：

```bash
journalctl -u ssserver -f
```

重启服务：

```bash
sudo systemctl restart ssserver
```

停止服务：

```bash
sudo systemctl stop ssserver
```

开机自启：

```bash
sudo systemctl enable ssserver
```

## 客户端连接参数

客户端需要填写以下内容：

- 服务器地址：你的服务器公网 IP 或域名
- 端口：`8388`
- 密码：脚本执行完成后输出的密码
- 加密方式：`chacha20-ietf-poly1305`

## 注意事项

- 本脚本适用于 **Ubuntu ARM64 / aarch64**
- 脚本需要在具有 `sudo` 权限的用户下执行
- 如果服务器启用了云安全组或其他防火墙，请自行放行对应端口
- 建议执行完成后立即保存生成的密码

## 文件说明

- `install_shadowsocks_rust.sh`：一键部署脚本