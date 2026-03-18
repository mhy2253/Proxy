## 安装步骤（OpenWrt 25.12）

```bash
# 更新包列表
apk update

# 安装 sing-box 和依赖
apk add sing-box
apk add kmod-nft-tproxy
apk add ip-full

```
## nftables 规则
- 保存为 /etc/nftables.d/sing-box.nft：
```nft
table inet sing-box {
    chain prerouting {
        type filter hook prerouting priority mangle; policy accept;

        # 跳过本机流量
        iif lo return

        # 跳过私有地址
        ip daddr {
            0.0.0.0/8,
            127.0.0.0/8,
            10.0.0.0/8,
            172.16.0.0/12,
            192.168.0.0/16,
            169.254.0.0/16,
            224.0.0.0/4,
            240.0.0.0/4
        } return

        ip6 daddr { ::1, fc00::/7, fe80::/10 } return

        # TCP/UDP 透明代理
        meta l4proto { tcp, udp } tproxy to :7893 meta mark set 1
    }

    chain output {
        type route hook output priority mangle; policy accept;

        # 跳过 sing-box 自身流量，防止循环
        meta skuid "sing-box" return

        # 跳过私有地址
        ip daddr {
            0.0.0.0/8,
            127.0.0.0/8,
            10.0.0.0/8,
            172.16.0.0/12,
            192.168.0.0/16,
            169.254.0.0/16,
            224.0.0.0/4,
            240.0.0.0/4
        } return

        meta l4proto { tcp, udp } meta mark set 1
    }
}

```

## 路由规则（开机自动执行）
- 保存为 /etc/hotplug.d/iface/99-sing-box：
```bash
#!/bin/sh
[ "$ACTION" = ifup ] || exit 0
ip rule add fwmark 1 table 100 2>/dev/null
ip route add local default dev lo table 100 2>/dev/null

```

## systemd 服务（OpenWrt 用 procd）
- sing-box 的 init 脚本 OpenWrt 包里已自带，直接启用：
```bash
service sing-box enable
service sing-box start

```
- 配置文件路径默认为 /etc/sing-box/config.json。
## 应用 nftables 规则
```bash
# 重启防火墙使规则生效
service firewall restart

# 验证规则是否加载
nft list table inet sing-box

```
