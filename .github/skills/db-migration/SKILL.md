---
name: db-migration
description: "Create and apply reviewed Alembic database migrations for the comments backend. Use when asked to add a column, change a model, update the schema, or generate a migration."
---

## When to Use This Skill

- Use when a backend model change requires a database schema migration.
- Use for requests to add a column, change a model, update the schema, or generate a migration.

## Prerequisites

- Read the backend Python and backend migration instructions.
- Make the required settings available in `backend/.env`.
- For local SQLite, create `backend/comments.db` and set `DATABASE_URL=sqlite:///comments.db`.

## Step-by-Step

1. Update the relevant SQLModel model.
2. From `backend/`, run `uv run alembic upgrade head` before generating a revision.
3. Generate a revision with `uv run alembic revision --autogenerate -m "describe the change"`.
4. Review the generated migration for correctness; do not apply unreviewed autogenerate output.
5. Apply the reviewed migration with `uv run alembic upgrade head`.
6. Confirm the migration is formatted by the Alembic Ruff post-write hook.

## Gotchas

- Alembic commands must run from `backend/`.
- Autogenerate compares models with the database, so upgrade the local database to the current head first.
- The backend entrypoint also runs migrations at container startup.
