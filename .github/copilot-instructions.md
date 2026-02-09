# AI Coding Agent Instructions for Blog Repository

## Repository Overview

This is a **full-stack personal blog** with:
- **Frontend**: Hugo static site generator with Tailwind CSS (located in `frontend/`)
- **Backend**: FastAPI comments service handling nested comment threads with Turnstile captcha verification (located in `backend/`)
- **Both components are containerized** and deployed separately

## Architecture & Key Components

### Backend (Python FastAPI)
**Purpose**: Multi-site comment system with HTML sanitization and captcha protection.

**Key Files & Patterns**:
- `backend/src/main.py`: FastAPI app setup with SQLModel ORM, CORS middleware, and three endpoints
  - `POST /comments`: Create new comments with Turnstile captcha validation
  - `GET /comments?site_id=X&post_slug=Y`: Fetch approved comments for a post
  - `GET /comments-to-approve`: Moderation endpoint for unapproved comments
- `backend/src/models.py`: SQLModel definitions with self-referential relationships for nested replies
  - `CommentBase`: Shared fields (site_id, post_slug, author, email, content, parent_id)
  - `Comment`: ORM table model with recursive reply relationships
  - `CommentResponse`: API response model with nested replies
- `backend/src/settings.py`: Pydantic settings from `.env` (database_url, turnstile_secret, turnstile_api_url)

**Critical Patterns**:
- Comments are sanitized with `nh3` library before returning (removes XSS vectors)
- Self-referential relationships stored in DB with `parent_id` foreign key
- All data queries must filter by `approved=True` and `parent_id=None` to get top-level comments
- Turnstile captcha token validation is **required** on comment creation

### Frontend (Hugo + Tailwind)
**Purpose**: Static blog with multi-language support (English, Arabic, Spanish).

**Key Files & Patterns**:
- `frontend/src/config.yml`: Hugo configuration with `commentsBackend` pointing to comments API
- `frontend/src/i18n/`: Language YAML files (ar.yaml, en.yaml, es.yaml)
- `frontend/src/assets/`: Tailwind CSS build output (main.css generated from app.css)
- `frontend/src/layouts/partials/comments.html`: Comments UI that calls backend API

**Critical Patterns**:
- Hugo Paper theme (trimmed version)
- All content in Markdown with YAML frontmatter
- Post slugs defined in `content/posts/` filenames (used by backend for comment queries)
- Tailwind CSS post-processed via `npm run css` command

## Development Workflows

### Backend Workflows

**Code Quality**:
- Linting: `ruff check --unsafe-fixes --fix` (checks E, F, UP, W, I, B rules)
- Formatting: `ruff format` (80 char line length, double quotes, 2-space indent)
- Applied automatically on migration file generation via alembic post-write hooks

**Database Migrations**:
- Tool: Alembic
- Location: `backend/alembic/versions/`
- Auto-format migrations with ruff (enforced in alembic.ini post_write_hooks)
- Run migrations on app startup via `entrypoint.sh`: `alembic upgrade head`

**Docker & Deployment**:
- Multi-stage Dockerfile using Python 3.14 and Alpine
- Dependencies managed with `uv` (fast package manager)
- Entrypoint runs migrations then starts uvicorn on port 80
- Non-root user (UID 1001) for security

### Frontend Workflows

**CSS Building**:
- Run `npm run css` to regenerate `assets/main.css` from `assets/app.css`
- Uses Tailwind with typography plugin

**Dependency Management**:
- Tools: prettier, stylelint, tailwindcss
- No complex build pipeline—Hugo handles static generation

## Project Conventions

### Python Code Style
- **Import ordering**: Single-line imports, grouped by: stdlib → third-party → local
- **Type hints**: Full type annotations required (Python 3.13+)
- **String style**: Double quotes
- **Naming**: snake_case for functions/variables, PascalCase for classes

### Commit & PR Process
- PR requires linting and dockerfile security scan (Trivy) to pass
- All PRs trigger secret scanning (Trufflehog)
- Path-based job filtering: backend changes only run backend checks

### Environment Variables
Backend requires:
- `DATABASE_URL`: SQLite or PostgreSQL connection string
- `TURNSTILE_SECRET`: Cloudflare Turnstile secret key
- `TURNSTILE_API_URL`: Turnstile verification endpoint URL
- `SERVICE_NAME`: App title for FastAPI docs
- `DEBUG` (optional): Enable debug mode (default False)

## Integration Points

**Frontend → Backend**:
- Frontend calls `params.commentsBackend` API (`https://comments.louhaidia.info`) with:
  - Query params: `site_id`, `post_slug`
  - Post body (create): `site_id`, `post_slug`, `author`, `email`, `content`, `turnstile_token`

**Security**:
- CORS configured to allow all origins (frontend deployed separately)
- All comment text sanitized before storage and retrieval
- Captcha validation required on creation
- CSP headers restrict script execution

## When Making Changes

1. **Backend models**: Update `models.py`, then run `alembic revision --autogenerate` to create migration
2. **New endpoints**: Follow GET/POST pattern, validate input, sanitize output, depend on session
3. **Frontend config**: Update `frontend/src/config.yml` if changing blog parameters or comment backend URL
4. **Content changes**: Edit Markdown in `frontend/src/content/posts/` — Hugo handles static generation
5. **Dependencies**: Use `uv` for Python; package.json for Node tools (pin versions)

## Testing & CI/CD

**Continuous Integration** (GitHub Actions):
- Secret scanning on every PR (Trufflehog)
- Dockerfile vulnerability scan (Trivy) on backend changes
- Docker image build & caching for optimized builds

**Current Gap**: No unit tests yet—consider adding when modifying critical paths (captcha validation, sanitization, DB queries).
