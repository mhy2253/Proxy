## shadowsocks-rust 一键部署

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
