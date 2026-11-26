---
name: comment-api-change
description: "Change the FastAPI comments API while preserving its privacy, validation, sanitization, and thread behavior. Use when asked to add an endpoint, change a request or response, or modify comment creation or retrieval."
---

## When to Use This Skill

- Use when adding or changing a comments endpoint, request model, response model, or comment behavior.
- Trigger phrases include add an endpoint, change the comments API, update the request or response, and modify comment creation.

## Prerequisites

- Read the backend Python instructions and inspect the existing endpoint and SQLModel patterns.
- Identify whether the change affects the public API, database schema, or both; use the database migration skill when a schema migration is required.

## Step-by-Step

1. Define and validate request and response fields using the existing Pydantic/SQLModel patterns.
2. Use the existing database session dependency for database access.
3. Require Turnstile validation on every comment creation request.
4. Sanitize comment content with `nh3` before storage and retrieval.
5. Keep email only in the database model and `CommentCreate`; never expose it through `CommentResponse` or public payloads.
6. Preserve default approval of new comments and the public query behavior: approved top-level comments with nested replies.
7. Add focused tests when changing captcha validation, sanitization, or database queries; the repository currently has no unit tests.

## Gotchas

- Do not add a CAPTCHA bypass path.
- Do not expose email in responses.
- Keep comment sanitization in place at storage and retrieval boundaries.
- Do not change approval or nested-reply behavior unintentionally.
