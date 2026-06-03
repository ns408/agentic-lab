# CLAUDE.md

Guidance for Claude Code (and any contributor) working in this repository.

## Project

`agentic-lab` is a Python monorepo of small, self-contained build artifacts that
demonstrate agentic AI concepts for a Cloud and DevOps audience. Each app under
`apps/` runs on its own and shares the stack, conventions, and utilities in
`shared/`. The first app contrasts a deterministic LLM workflow with a tool-using
agent over the same task.

This repository is **public**. Treat everything in it as published.

## Layout

```
apps/        self-contained demo apps (each with its own README + compose)
shared/      shared utilities (model client, prompt loading, telemetry)
docs/        design notes (model choice, deployment, observability)
evals/       cross-app evaluation harness (later phase)
scripts/     repo scripts
```

## Toolchain

- Python 3.12, managed by **mise** (`.mise.toml` pins it). Never call system
  `python3`/`pip`. Use `mise exec -- ...` or the project `.venv`.
- Set up: `mise install && mise exec -- python -m venv .venv && .venv/bin/pip install -e ".[dev]"`.

## LLM access

The app is a pure **OpenAI-compatible client**. It never bundles or manages a
model. It talks to whatever `LLM_BASE_URL` points at, selected by env
(`LLM_BASE_URL`, `MODEL_NAME`, `LLM_API_KEY`):

- local: Ollama (`http://localhost:11434/v1`) or LM Studio (`http://localhost:1234/v1`)
- hosted: any OpenAI-compatible endpoint (OpenAI, Anthropic via its OpenAI-compat
  endpoint, Groq, etc.)

Copy `.env.example` to `.env` (gitignored) and set values there. Never hardcode
keys or commit `.env`.

## Code style

- Lint and format with **ruff**; type-check with **mypy** (strict where practical).
  Security rules run via ruff `S`; full bandit runs in CI.
- Functions under ~40 lines, files under ~300. No abstractions until needed.
- Write the minimum code that solves the task. Only edit what is necessary.

## Copy rules (user-facing text: READMEs, docs, app copy)

- No em-dashes. Use commas, colons, or full stops.
- UK English.
- No fabricated stats or claims. Every specific number must trace to real repo
  state (count tests by counting them, time runs by timing them).

## Commit conventions

- Imperative mood, subject under 70 chars; explain why, not what, in the body.
- No `Co-Authored-By` trailers. No references to AI tools or AI assistance.

## Guardrails

- Secrets and local-only files are gitignored: `.env`, `*.pem`/`*.key`, `TEMP/`,
  `.dev/`, `*secret*`/`*token*`/`*credentials*`.
- A `PreToolUse` git guard (`.claude/hooks/pre-git-guard.sh`) blocks commits/pushes
  that would stage those paths or contain secrets (via gitleaks). It only fires
  when Claude runs git; manual commits are covered by the global git hooks and CI.
- `.pre-commit-config.yaml` drives CI and manual `pre-commit run --all-files`.
- Some leak checks and operator notes are intentionally local-only and not part of
  this repository.

## Never commit

`.env`, key material, `TEMP/`, `.dev/`, anything named like a secret/token/
credential. When in doubt, do not commit it.
