# agentic-lab

[![CI](https://github.com/ns408/agentic-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/ns408/agentic-lab/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python 3.12](https://img.shields.io/badge/python-3.12-blue.svg)](.mise.toml)
[![Ruff](https://img.shields.io/badge/lint-ruff-261230.svg)](https://docs.astral.sh/ruff/)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen.svg)](.pre-commit-config.yaml)

A lab exploring agentic AI for Cloud and DevOps, built as small, runnable demos.
**Work in progress.**

This started as scattered experiments to understand agentic systems. The lab pulls
them into one place: each app isolates a single idea so it is easy to see, run, and
reuse. The engineering around the apps (guardrails, typing, tests, CI) is treated as
part of the demonstration, not an afterthought.

## The distinction this explores

Most LLM projects blur two different things. This lab keeps them separate, following
the definitions in Anthropic's [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents):

- A **workflow** follows a fixed path. Same input, same steps, every time.
- An **agent** decides. Given a goal and tools, it chooses what to do and in what order.

## Status

Honest about what exists today versus what is planned.

| Area | State |
|---|---|
| Repo + engineering groundwork (guardrails, CI, typing, tests) | done |
| `apps/01-workflow-vs-agent` | in progress |
| `apps/02-raw-to-framework` | planned |
| `apps/03-platform-assistant` | planned |

There is no runnable app yet. What is in place now is the engineering foundation the
apps will be built on (see below).

## Engineering approach

The groundwork is deliberate, so anything here carries over to real production work:

- **Provider-neutral by design.** Apps will be OpenAI-compatible clients that bundle
  no model. Point them at Ollama or LM Studio locally, or a hosted endpoint, with one
  environment variable.
- **Guardrails for a public repo.** Secrets and sensitive paths are blocked by
  `.gitignore`, a commit/push guard, pre-commit, and CI secret scanning.
- **Typed and linted.** ruff for lint and format, mypy in strict mode, security rules
  via ruff `S` locally and bandit in CI.
- **Tests that fit LLM apps.** Deterministic logic is unit-tested; model behaviour will
  be checked by a separate eval set rather than flaky assertions on generated text.
- **CI gates everything.** Lint, types, tests, and secret scanning run on every push.

## Develop

Python is managed with [mise](https://mise.jdx.dev/); the version is pinned in
`.mise.toml`.

```bash
mise install                              # provisions Python 3.12
mise exec -- python -m venv .venv
.venv/bin/pip install -e ".[dev]"         # runtime + dev tools
.venv/bin/pytest                          # run the test suite
.venv/bin/ruff check . && .venv/bin/mypy . # lint and type-check
```

Optional, recommended once cloning: install the pre-commit hooks with
`pre-commit install` (or rely on CI, which runs the same checks).

## Layout

```
apps/      self-contained demo apps (each with its own README)
shared/    shared utilities (model client, prompt loading, telemetry)
docs/      design notes and architecture decision records
evals/     evaluation harness for model behaviour
tests/     unit tests
.github/   CI and Dependabot
```

## Roadmap

Planned, not yet built: the three apps above, plus MCP and agent-to-agent support,
human-in-the-loop approval flows, and safety and governance controls aligned to
recognised frameworks.

## Contributing

This is an early, solo demo repository. Issues and suggestions are welcome; please open
an issue to discuss before sending a pull request. Security reports: see
[SECURITY.md](SECURITY.md).

## Licence

[MIT](LICENSE).

## Credits

The workflow versus agent distinction follows Anthropic's
[Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents).
