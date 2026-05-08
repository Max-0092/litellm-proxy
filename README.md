# litellm-proxy

A locally-hosted [LiteLLM](https://github.com/BerriAI/litellm) proxy that provides a single, unified API endpoint for multiple AI providers (Anthropic, OpenAI, Google Gemini, OpenRouter, and more).

Instead of configuring API keys and provider-specific SDKs in every project, all your apps point to `http://localhost:4000` and this proxy handles routing, authentication, and provider differences.

## Why this exists

- **One integration, many providers** — swap models without changing application code
- **Central key management** — API keys live in one place, not scattered across projects
- **OpenAI-compatible API** — works with any tool that supports OpenAI's API format, including Claude Code
- **Usage visibility** — all requests flow through one place, making it easy to see what's being used

## Architecture

```
Your apps / Claude Code
        │
        ▼
http://localhost:4000   ← LiteLLM Proxy (this repo)
        │
        ├─▶ Anthropic API   (Claude)
        ├─▶ OpenAI API      (GPT, o-series)
        ├─▶ Google AI API   (Gemini)
        └─▶ OpenRouter API  (300+ models)
```

## Prerequisites

- [UV](https://docs.astral.sh/uv/getting-started/installation/) — Python package manager
- Windows 10 or later (no admin rights required)

## Setup

**1. Clone the repository**
```powershell
git clone <your-repo-url>
cd litellm-proxy
```

**2. Install dependencies**
```powershell
uv sync
```

**3. Configure your API keys**
```powershell
Copy-Item .env.example .env
# Open .env in your editor and fill in your API keys
```

At minimum, set `LITELLM_MASTER_KEY` to a random string (this is the password your apps use to talk to the proxy).

**4. Start the proxy**
```powershell
.\scripts\start.ps1
```

The proxy is now running at `http://localhost:4000`. Visit `http://localhost:4000/ui` for the dashboard.

**5. (Optional) Start automatically at login**
```powershell
.\scripts\install-autostart.ps1
```

## Available models

| Alias | Provider | Actual model |
|---|---|---|
| `claude-sonnet` | Anthropic | claude-sonnet-4-5 |
| `claude-opus` | Anthropic | claude-opus-4-5 |
| `claude-haiku` | Anthropic | claude-haiku-4-5 |
| `gpt-4o` | OpenAI | gpt-4o |
| `gpt-4o-mini` | OpenAI | gpt-4o-mini |
| `o3` | OpenAI | o3 |
| `gemini-flash` | Google | gemini-2.0-flash |
| `gemini-pro` | Google | gemini-2.0-pro-exp |
| `openrouter/deepseek-r1` | OpenRouter | deepseek-r1 |
| `openrouter/llama-4-maverick` | OpenRouter | llama-4-maverick |

Add more models by editing `config.yaml`.

## Using with your applications

Set these environment variables in any project:

```bash
OPENAI_BASE_URL=http://localhost:4000
OPENAI_API_KEY=<your LITELLM_MASTER_KEY from .env>
```

Then use any model alias from the table above as the model name.

### Python example (OpenAI SDK)
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:4000",
    api_key="sk-local-dev-key",  # your LITELLM_MASTER_KEY
)

response = client.chat.completions.create(
    model="claude-sonnet",
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

### Claude Code

To use Claude Code with a different model via the proxy:
```powershell
$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_API_KEY  = "sk-local-dev-key"
claude --model claude-haiku
```

## Configuration

All model routing is defined in `config.yaml`. The proxy reads API keys and settings from `.env` at startup — changes to `.env` require a restart.

## Caching

Caching prevents identical requests from hitting the provider API twice, saving tokens and latency.

| Environment | `LITELLM_CACHE_TYPE` | Requires |
|---|---|---|
| Work (no admin rights) | `local` | Nothing — in-memory, lost on restart |
| Home (WSL + Podman) | `redis` | Redis running, `REDIS_URL` set |

## Home setup (WSL + Podman)

On a machine with WSL and Podman available, you can run Redis as a container for persistent caching:

```bash
# Start Redis container (runs in background, auto-restarts)
podman run -d \
  --name litellm-redis \
  --restart always \
  -p 6379:6379 \
  redis:alpine

# Verify it's running
podman ps
```

Then set these values in your `.env`:
```
LITELLM_CACHE_TYPE=redis
REDIS_URL=redis://localhost:6379
DATABASE_URL=sqlite:///./litellm.db
```

To start Redis automatically when WSL starts, add the `podman start litellm-redis` command to your `~/.bashrc` or use a systemd user service.

## Removing autostart

```powershell
.\scripts\uninstall-autostart.ps1
```
