# Surge Ruleset Structure

This directory contains optimized Surge rule lists.

## Files

### direct.list
- China traffic direct rules
- Payment / video / Tencent / railway services
- GEOIP,CN based baseline routing
- No USER-AGENT or IP-CIDR dependency

### proxy.list (planned)
- International traffic routing rules

### reject.list (planned)
- Ads / tracking / telemetry blocking rules

## Design Principles

- DOMAIN / DOMAIN-SUFFIX first (stable)
- GEOIP used as fallback baseline
- Avoid USER-AGENT rules (unstable)
- Avoid IP-CIDR unless necessary (CDN volatility)
- Keep rules minimal, deterministic, and maintainable
