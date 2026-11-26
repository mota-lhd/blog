---
applyTo: "backend/alembic/**"
---

- Migration files live in `backend/alembic/versions/`; run Alembic commands from `backend/`.
- Configure `.env` with `DATABASE_URL`, `TURNSTILE_SECRET`, `TURNSTILE_API_URL`, and `SERVICE_NAME`.
- For local SQLite, set `DATABASE_URL=sqlite:///comments.db` and create `comments.db` with `touch comments.db`.
- Before generating a revision, run `uv run alembic upgrade head` so the database is at the current migration head.
- Review every autogenerate revision before applying it.
- Generate revisions with `uv run alembic revision --autogenerate -m "describe the change"`.
- Apply a reviewed revision with `uv run alembic upgrade head`.
- Alembic post-write hooks format generated migrations with Ruff.
- The backend container entrypoint also runs `alembic upgrade head` at startup.
