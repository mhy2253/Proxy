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

