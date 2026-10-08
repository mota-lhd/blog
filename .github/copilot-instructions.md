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
- `backend/src/main.py`: FastAPI app setup with SQLModel ORM, CORS middleware, and two endpoints
  - `POST /comments`: Create new comments with Turnstile captcha validation
  - `GET /comments?site_id=X&post_slug=Y`: Fetch approved comments for a post
- `backend/src/models.py`: SQLModel definitions with self-referential relationships for nested replies
  - `CommentBase`: Shared public fields (site_id, post_slug, author, content, parent_id)
  - `Comment`: ORM table model with recursive reply relationships
  - `CommentCreate`: Request model containing email and the Turnstile token
  - `CommentResponse`: API response model with nested replies
- `backend/src/settings.py`: Required Pydantic settings from `.env` (database_url, turnstile_secret, turnstile_api_url, service_name)

**Critical Patterns**:
- Comments are sanitized with `nh3` library before returning (removes XSS vectors)
- Self-referential relationships stored in DB with `parent_id` foreign key
- New comments are approved by default. The public `GET /comments` query selects approved top-level rows and includes their nested replies.
- Keep email in the database model and `CommentCreate` only; never add it to `CommentResponse` or public comment payloads
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
- Tailwind CSS post-processed from `frontend/src/` via `bun run build:css`

## Development Workflows

### Backend Workflows

**Code Quality**:
- From `backend/`, lint with `uv run ruff check --unsafe-fixes --fix` (checks E, F, UP, W, I, B rules)
- From `backend/`, format with `uv run ruff format` (80 char line length, double quotes, 2-space indent)
- Applied automatically on migration file generation via alembic post-write hooks

**Database Migrations**:
- Tool: Alembic
- Location: `backend/alembic/versions/`
- Run migration commands from `backend/`. Configure `.env` with the required settings:
  - `DATABASE_URL`
  - `TURNSTILE_SECRET`
  - `TURNSTILE_API_URL`
  - `SERVICE_NAME`
- For the local SQLite database, set `DATABASE_URL=sqlite:///comments.db` in `.env` and create the file first with `touch comments.db`. Then run `uv run alembic upgrade head` before generating revisions, so the database is at the current migration head.
- After changing models, generate a revision with `uv run alembic revision --autogenerate -m "describe the change"`, review it, then run `uv run alembic upgrade head` to apply it.
- Auto-format migrations with ruff (enforced in alembic.ini post_write_hooks)
- Run migrations on app startup via `entrypoint.sh`: `alembic upgrade head`

**Docker & Deployment**:
- Multi-stage Dockerfile using Python 3.14 and Alpine
- Dependencies managed with `uv` (fast package manager)
- Entrypoint runs migrations then starts uvicorn on port 80
- Non-root user (UID 1001) for security

### Frontend Workflows

**CSS Building**:
- From `frontend/src/`, run `bun run build:css` to regenerate `assets/main.css` from `assets/app.css`
- Uses Tailwind with typography plugin

**Dependency Management**:
- Tools: Bun, Prettier, PostCSS, and Tailwind CSS
- No complex build pipeline—Hugo handles static generation

## Project Conventions

### Python Code Style
- **Import ordering**: Single-line imports, grouped by: stdlib → third-party → local
- **Type hints**: Full type annotations required (Python 3.13+)
- **String style**: Double quotes
- **Naming**: snake_case for functions/variables, PascalCase for classes

### Commit & PR Process
- The PR workflow builds and scans backend/frontend images when those paths change; it runs Checkov on changed Dockerfiles and Grype image scans. It does not currently run Ruff linting or Trivy.
- All PRs trigger secret scanning (Trufflehog)
- Path-based job filtering: backend changes only run backend checks

### Environment Variables
Backend requires:
- `DATABASE_URL`: SQLAlchemy database URL (SQLite works with current dependencies; other database engines require their driver)
- `TURNSTILE_SECRET`: Cloudflare Turnstile secret key
- `TURNSTILE_API_URL`: Turnstile verification endpoint URL
- `SERVICE_NAME`: App title for FastAPI docs
- `ALLOWED_ORIGINS` (optional): JSON array of allowed CORS origins, for example `["https://example.com","https://admin.example.com"]`; defaults to `["*"]`
- `DEBUG` (optional): Enable debug mode (default False)

## Integration Points

**Frontend → Backend**:
- Frontend calls `params.commentsBackend` API (`https://comments.louhaidia.info`) with:
  - Query params: `site_id`, `post_slug`
  - Post body (create): `site_id`, `post_slug`, `author`, `email`, `content`, `turnstile_token`

**Security**:
- Backend CORS uses `settings.allowed_origins`; configure `ALLOWED_ORIGINS` as a JSON array in `.env` when restricting access, for example `ALLOWED_ORIGINS='["https://example.com"]'`
- All comment text sanitized before storage and retrieval
- Captcha validation required on creation
- Hugo's `security.csp` configuration defines `default-src`, `script-src`, `frame-src`, and `connect-src` policies

## When Making Changes

1. **Backend models**: Update `backend/src/models.py`, then from `backend/` create/upgrade `comments.db` as described above, generate a revision with `uv run alembic revision --autogenerate -m "describe the change"`, review it, and apply it with `uv run alembic upgrade head`
2. **New endpoints**: Follow GET/POST pattern, validate input, sanitize output, depend on session
3. **Frontend config**: Update `frontend/src/config.yml` if changing blog parameters or comment backend URL
4. **Content changes**: Edit Markdown in `frontend/src/content/posts/` — Hugo handles static generation
5. **Dependencies**: Use `uv` for Python; package.json for Node tools (pin versions)

## Testing & CI/CD

**Continuous Integration** (GitHub Actions):
- Secret scanning on every PR (Trufflehog)
- Dockerfile checks with Checkov and image vulnerability scans with Anchore Grype on backend/frontend changes
- Docker image build & caching for optimized builds
- `scan.yml` uses OpenGrep v1.30.0 with `--config auto` and `--taint-intrafile` for full scans.
- `scan.yml` uploads OpenGrep SARIF results for full scans; `pr.yml` does not upload results.
- `pr.yml` uses one blocking OpenGrep job with `opengrep ci`; it scans only changed files for backend Python, frontend JavaScript/HTML, and GitHub Actions/Dependabot YAML. It passes `GH_TOKEN: ${{ github.token }}`.
- Keep OpenGrep installation and conditional category scans in the shared PR OpenGrep step. Path-filter outputs determine which category scans run.

### Syft and Dependency-Track
- `.github/workflows/syft-dtrack.yml` is a reusable workflow. Its `images` input is a JSON string containing objects with `image`, `version`, and `dtrack_project_name` fields because `workflow_call` has no native array input type.
- The reusable workflow accepts `dtrack_url` and the required `DTRACK_API_KEY` secret.
- Syft is installed from `https://get.anchore.io/syft`, and each matrix entry generates a CycloneDX SBOM, adds a dependency root with `jq`, and publishes it to Dependency-Track.
- Derive the SHA-256 identity from the exact `image:version` reference before scanning. Use it in all generated filenames, such as `sbom-<sha256>.json` and `dtrack-payload-<sha256>.json`; do not add the identity as extra SBOM or payload fields.
- Docker images scanned by the reusable workflow must be pushed to GHCR first because reusable workflow jobs run on separate runners. Use the `latest` tag consistently when the caller specifies `version: latest`.

### Dependabot
- `.github/dependabot.yml` groups frontend Docker/npm updates as `front`, backend Docker/uv updates as `back`, and GitHub Actions updates as `actions`. Dependabot cannot combine different package ecosystems into one physical PR.

**Current Gap**: No unit tests yet—consider adding when modifying critical paths (captcha validation, sanitization, DB queries).
