# Contributing

## Core principle

The `main` branch always contains working, production-ready code. No exceptions.

## Branching

Never commit directly to `main`. All work happens on a branch.

**Branch naming:**

| Prefix | When to use | Example |
|---|---|---|
| `feat/` | New model, new provider, new script | `feat/add-mistral-provider` |
| `fix/` | Something broken | `fix/env-loading-on-windows` |
| `docs/` | README, comments, CONTRIBUTING | `docs/add-setup-guide` |
| `chore/` | Dependency updates, config tweaks | `chore/bump-litellm-version` |

```powershell
# Start new work
git switch main
git pull
git switch -c feat/your-feature-name

# When done, push and open a PR
git push -u origin feat/your-feature-name
gh pr create
```

## Commits

Follow the [Conventional Commits](https://www.conventionalcommits.org/) standard.

```
<type>: <short description in present tense>

# Examples
feat: add Mistral provider to config
fix: load .env before starting proxy
docs: document Claude Code integration
chore: update litellm to 1.58.0
```

**Rules:**
- Present tense, lowercase — `add thing`, not `Added thing` or `Adds thing`
- No period at the end
- Keep the first line under 72 characters
- If you need to explain *why*, add a blank line and a body paragraph

## Pull Requests

Open a PR for every change, even when working solo. It builds the habit and gives you a clean history on GitHub.

- Title follows the same Conventional Commits format
- Describe *what* changed and *why* in the PR body
- Merge with **Squash and merge** to keep `main` history clean

## What goes on `main`

- Fully working configuration
- No API keys or secrets (enforced by `.gitignore`)
- Updated README if the setup or usage changed
