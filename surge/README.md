# Surge Ruleset Structure (Specification)

This directory contains manually maintained Surge rule lists.

## 1. Rule Format

Each rule follows this structure:

```
TYPE,VALUE[,POLICY]
```

Supported types:
- DOMAIN
- DOMAIN-SUFFIX
- DOMAIN-KEYWORD
- IP-CIDR
- IP-CIDR6
- GEOIP
- PROCESS-NAME
- FINAL

Example:
```
DOMAIN-SUFFIX,example.com
GEOIP,CN,DIRECT
```

---

## 2. File Responsibilities

### direct.list
- Domestic traffic routing
- Chinese services (WeChat, Alipay, Bilibili, etc.)
- GEOIP,CN used as fallback
- Must NOT include proxy targets

### proxy.list
- International services routing
- Google, GitHub, OpenAI, social platforms
- Must NOT overlap with direct.list domains

### reject.list (optional)
- Ads, tracking, telemetry domains
- Must be safe to block globally

---

## 3. Design Rules

### 3.1 Priority Order
Rules are evaluated top-to-bottom.
More specific rules must appear before generic rules.

Recommended order:
1. DOMAIN / DOMAIN-SUFFIX (specific services)
2. PROCESS-NAME (if used)
3. GEOIP (country fallback)
4. FINAL (global fallback)

---

### 3.2 Stability Principles
- Prefer DOMAIN-SUFFIX over IP-CIDR
- Avoid USER-AGENT rules (unstable / deprecated)
- Avoid large IP ranges unless necessary
- Prefer minimal and deterministic rules

---

### 3.3 Conflict Rule
A domain MUST NOT appear in multiple policy contexts:
- direct vs proxy conflict is not allowed
- resolve conflicts by removing or consolidating rules

---

## 4. Maintenance Policy

- Keep rule sets minimal
- Remove unused or redundant entries
- Prefer long-term stable domains

---

## 5. Notes

This repository is intentionally lightweight.
No automation, validation, or CI is used.
Rules are maintained manually for transparency and simplicity.
