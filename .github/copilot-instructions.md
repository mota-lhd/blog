# Copilot Instructions

## Repository overview

This repository is a personal blog with a Hugo/Tailwind frontend in `frontend/` and a FastAPI comments service in `backend/`; they are built and deployed as separate containers.

## Hard invariants

- Keep email in the database model and `CommentCreate` only; never expose it in `CommentResponse` or public comment payloads.
- Require Turnstile validation for comment creation; do not add a bypass path.
- Sanitize comment text with `nh3` before storage and retrieval.
- New comments are approved by default; public queries return approved top-level comments with nested replies.
- Review Alembic autogenerate output before applying a migration.

## Testing gap

There are no unit tests yet; add focused tests when changing captcha validation, sanitization, or database queries.

## Where to look

- Path-specific rules: `.github/instructions/`
- Multi-step procedures: `.github/skills/`
