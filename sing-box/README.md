# sing-box 配置说明

此目录用于存放 sing-box 配置模板。

## 文件说明

- `config.json`：第一份配置，TUN / fake-ip 方案。
- `latest.example.json`：适配最新版 sing-box 内核，以系统代理方式代理的配置。
- `latest-tun.example.json`：适配最新版 sing-box 内核，以 TUN 方式代理的配置。

## 使用说明

公开仓库中的配置文件均为模板，不应直接写入真实节点密码、真实服务器地址、SNI 或 WebSocket Host。

本地使用时建议复制模板：

```bash
cp sing-box/latest.example.json sing-box/config.local.json
```

然后在 `config.local.json` 中填写真实节点信息。

`config.local.json` 已被 `.gitignore` 忽略，避免误提交真实配置。
