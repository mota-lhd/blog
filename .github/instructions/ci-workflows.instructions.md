---
applyTo: ".github/{workflows/**,dependabot.yml,file_and_dir_filters.yml,grype.yaml}"
---

- `pr.yml` runs Trufflehog on every pull request and uses `.github/file_and_dir_filters.yml` to select backend, frontend, Dockerfile, and workflow checks.
- On changed Dockerfiles, the PR workflow runs Checkov; on changed backend or frontend paths, it builds the corresponding image with GitHub Actions caching and runs Grype using `.github/grype.yaml`, a high severity cutoff, and fixed vulnerabilities only.
- The PR workflow does not run Ruff or Trivy.
- The single blocking PR OpenGrep job uses v2.1.0 `opengrep ci`, runs conditionally for changed Python, JavaScript/HTML, or workflow/Dependabot files, and passes `GH_TOKEN: ${{ github.token }}`.
- `opengrep ci` checks changed files and does not upload SARIF; its results are not equivalent to the full main-branch scan.
- `scan.yml` runs on pushes to `main` and on its daily schedule; it builds and pushes frontend and backend images to GHCR, runs Checkov on their Dockerfiles, and uploads Checkov SARIF with soft-fail enabled.
- The main-branch OpenGrep scan uses v2.1.0 with `opengrep scan --config auto --taint-intrafile` and uploads one SARIF file per language.
- Preserve the SARIF filter before upload: remove results marked with an `inSource` suppression while retaining unsuppressed results and other suppression kinds, because GitHub code scanning does not honor OpenGrep's in-source suppression metadata in uploaded SARIF.
- OpenGrep accepts `noopengrep`, `nosemgrep`, and `nosem` inline suppression directives; for example, HTML can use `<!-- noopengrep: rule-id -->`.
- Keep OpenGrep installation and conditional category scans in the shared PR OpenGrep step; path-filter outputs determine which category scans run.
- `.github/dependabot.yml` groups frontend Docker/npm updates as `front`, backend Docker/uv updates as `back`, and GitHub Actions updates as `actions`; all run daily with a seven-day default cooldown.
- Dependabot cannot combine different package ecosystems into one physical pull request.
