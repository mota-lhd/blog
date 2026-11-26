---
name: write-post
description: Create or edit a blog post for the Hugo frontend, with correct frontmatter, slugs, series conventions, and the author's voice. Use when asked to write a post, add an article, draft content, or update an existing post.
disable-model-invocation: true
---

# Write a blog post

## When to Use This Skill

- Use when creating a new blog post or editing an existing one in `frontend/src/content/posts/`.
- Trigger phrases include write a post, add an article, draft content, and update a post.

## Prerequisites

- Read the frontend instructions (`.github/instructions/frontend-hugo.instructions.md`).
- Look at an existing post in `frontend/src/content/posts/` to match the current style before writing.

## Step-by-Step

1. Create the file in `frontend/src/content/posts/` as Markdown with a `.md` extension. The filename defines the post slug used by the comments API, so choose a stable, lowercase, hyphenated name (for example `tech-blog-01.md`).
2. Start the file with YAML frontmatter matching the existing posts:

   ```yaml
   ---
   title: "post title"
   author: "elmouatassim"
   date: "YYYY-MM-DD"
   summary: "one-sentence summary shown in listings"
   tags: [
       "tag1",
       "tag2",
   ]
   categories: [
       "category",
   ]
   id: "unique-post-id"
   series: ["series title"]
   ---
   ```

3. Set `id` to a unique identifier (usually the filename without extension). Reuse the same `series` value across posts that belong to the same series.
4. Write the body in Markdown. Existing posts use lowercase prose, `##` section headings, fenced code blocks with a language tag, and images hosted on Cloudinary (`https://res.cloudinary.com/...`).
5. Hugo generates the site statically; no build step is needed for content-only changes. Run the CSS build only if styling changed.

## Voice and writing rules

Write like a person with a point of view, not generic AI prose. The existing posts are personal, first-person, and concrete.

1. Lead with the concrete thing: an anecdote, command, output, number, or code. Explain after the example, not before.
2. Keep sentences tight; use proof instead of adjectives.
3. Never invent facts, sources, or personal experiences. Factual claims must come from the user or cited sources.
4. Delete and rewrite these patterns if they appear: "in today's rapidly evolving landscape", "game-changer", "cutting-edge", "revolutionary", fake vulnerability arcs, a closing question added only for engagement, and generic throat-clearing that delays the point.
5. For technical guides: open with what the reader gets, use real commands and output in major sections, and end with actionable takeaways, not a soft recap.
6. For essays or opinion: start with tension or a specific observation, keep one argument thread per section, and make opinions answer to evidence.

## Gotchas

- Do not change the filename of an existing post: the slug is the key the comments backend uses, so renaming orphans existing comments.
- Keep frontmatter fields consistent with existing posts; do not invent new fields.
- The site is multilingual (English, Arabic, Spanish via `frontend/src/i18n/`), but posts are written in a single language per file.
- Hugo's `security.csp` restricts external scripts and connections; do not add external resources that the CSP would block.

## Quality gate

Before finishing, check that:

- every section adds something new and starts with proof, an example, or a concrete observation;
- no banned AI patterns remain;
- the voice matches the existing posts (personal, lowercase, first-person);
- frontmatter, slug, and series conventions are correct.
