---
applyTo: "**/{Dockerfile*,entrypoint.sh}"
---

- Backend and frontend are built and deployed as separate container images.
- Keep both Docker builds multi-stage; the backend image uses Python 3.15 Alpine 3.24.
- Backend dependencies are managed with `uv`; the production image runs as the non-root user with UID 1001.
- The backend entrypoint runs `alembic upgrade head`, then starts Uvicorn through `tini` on port 80.
- Preserve the backend SQLite volume at `/app/data` and its `/docs` health check.
- The frontend Docker build installs Hugo 0.170.1, builds with Bun, and serves generated `public/` files with Nginx.
- Keep image build contexts consistent with the relevant frontend or backend directory.
