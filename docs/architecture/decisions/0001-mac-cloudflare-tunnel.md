# 0001. Host on a MacBook with Cloudflare Tunnel

- **Status:** accepted
- **Date:** 2026-09-18

## Context

We want to host this fork ourselves. Cloud container platforms can wait.

## Decision

Run Phoenix and Redis on the MacBook. Put Cloudflare Tunnel in front so the app has HTTPS and a stable hostname without opening inbound ports.

## Consequences

- Start/stop is a pair of local scripts plus a tunnel script.
- Websockets must be allowed through the tunnel (cloudflared supports this).
- Docker/Kubernetes/GCloud remain undocumented until needed.
