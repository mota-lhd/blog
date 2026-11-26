---
applyTo: "frontend/**"
---

- The frontend is a Hugo static site using a trimmed Paper theme and Tailwind CSS.
- Hugo configuration is in `frontend/src/config.yml`; the comments API base is configured with `commentsBackend`.
- Translation files for Arabic, English, and Spanish are in `frontend/src/i18n/`.
- Blog content in `frontend/src/content/posts/` is Markdown with YAML frontmatter; post filenames define the slugs used by the comments API.
- `frontend/src/layouts/partials/comments.html` implements the comments UI and calls the comments backend.
- The comments API uses `site_id` and `post_slug` query parameters; creation sends `site_id`, `post_slug`, `author`, `email`, `content`, and `turnstile_token`, with `parent_id` for replies.
- Keep email out of public comment responses and payloads.
- Tailwind source is `frontend/src/assets/app.css`; generated output is `frontend/src/assets/main.css`.
- Run `bun run build:css` from `frontend/src/` after changing CSS sources.
- Frontend assets use Bun, Prettier, PostCSS, and Tailwind with the typography plugin.
- Manage frontend Node dependencies in `package.json` and pin versions.
- Hugo handles static generation without a separate complex build pipeline.
- Preserve the Hugo `security.csp` directives for `default-src`, `script-src`, `frame-src`, and `connect-src` when changing the site configuration.
