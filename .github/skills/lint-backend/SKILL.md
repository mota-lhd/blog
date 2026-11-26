---
name: lint-backend
description: Lint and format the backend Python code with Ruff, applying safe and unsafe fixes. Use when asked to lint, format, or fix backend code style.
disable-model-invocation: true
---

# Lint backend

Run Ruff from `backend/`:

```sh
uv run ruff check --unsafe-fixes --fix
uv run ruff format
```
