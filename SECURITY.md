# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please do **not** open a public GitHub issue.

Instead, report it privately via email: **jelmermax@gmail.com**

Please include:
- A description of the vulnerability
- Steps to reproduce it
- Potential impact

I aim to respond within 72 hours and will keep you updated on the fix.

## Scope

This project is a locally-hosted proxy. The main security considerations are:

- **API keys** — never commit `.env` to Git; the `.gitignore` enforces this
- **Master key** — use a strong random value for `LITELLM_MASTER_KEY` in production
- **Network exposure** — the proxy binds to `localhost` by default; do not expose it to a public network without additional authentication
