---
name: ci-failure-debug
description: "Diagnose failures in this repository's GitHub Actions checks and scans. Use when asked why CI failed, to debug a workflow run, or to investigate OpenGrep, Checkov, Grype, or Trufflehog results."
---

## When to Use This Skill

- Use when investigating a failed or unexpected GitHub Actions run.
- Trigger phrases include why did CI fail, debug the workflow, investigate an OpenGrep finding, and explain a Checkov or Grype result.

## Prerequisites

- Read the CI workflow instructions.
- Identify whether the run is a pull request or a push/scheduled main-branch scan.

## Step-by-Step

1. Inspect the failed job and its logs to identify the failing step and exact error or finding.
2. For pull requests, check the path-filter outputs and confirm which conditional jobs and scanners actually ran.
3. Distinguish the PR OpenGrep `ci` scan of changed files from the full main-branch OpenGrep scan that uploads SARIF.
4. For main-branch Code Scanning results, check the uploaded SARIF path, language category, and whether the result has an `inSource` suppression.
5. Trace Dockerfile findings to Checkov and image findings to the PR Grype configuration and severity/fix filters.
6. Make the smallest relevant fix and verify it with the workflow's corresponding check.

## Gotchas

- A skipped path-filtered job is not evidence that its scanner passed.
- PR OpenGrep checks do not upload SARIF and are not equivalent to a full scan.
- Preserve the main workflow's SARIF filter for in-source-suppressed results.
- Do not change workflow formatting or unrelated jobs while diagnosing a failure.
