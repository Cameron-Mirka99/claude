---
name: keep-readme-updated
description: "Keep a project's README.md in sync with the codebase. Load before finishing any task that adds/renames/removes an npm/build script, changes local dev setup steps, adds a new top-level directory or major dependency, or changes deploy/CI steps. Not for pure logic changes with no effect on how someone runs, builds, or navigates the project."
---

## What triggers a README update

Check the project's `README.md` (and update it in the same commit/response)
whenever a change touches anything a new contributor would need to know to
run, build, or navigate the project:

- **Scripts** (package.json, Makefile, etc.) added, renamed, or removed →
  update the relevant command list/section.
- **Local dev setup** changes (new required env var, new CLI tool, new
  prerequisite version) → update the setup/dev section.
- **Top-level layout** changes (new top-level directory, a directory's
  purpose changes) → update the layout/structure section.
- **Stack/dependency** changes that affect what the project is built with
  (new major library, swapped service, e.g. changing hosting provider) →
  update the stack/tech-overview section.
- **Deploy/CI steps** change (build spec, hosting config, pipeline steps) →
  update the deploy section.

## What does NOT need a README update

- Internal refactors, bug fixes, or logic changes with no visible effect on
  setup/run/deploy steps.
- Adding a new feature/module that already fits an existing, described
  pattern (e.g. "one folder per feature" is already documented).
- Test-only changes.
- Projects with no README yet and no indication one is wanted — don't create
  one unprompted, just note in your response that none exists.

## How to apply

1. After making the code change, re-read the project's current `README.md`
   (don't assume its prior contents — it may have drifted from the code).
2. Make the smallest edit that keeps it accurate: update the specific line/
   section affected, don't rewrite unrelated parts.
3. Match the README's existing style (tables, fenced code blocks, terseness
   level, heading structure already in use) — don't introduce a new section
   or format unless the change genuinely doesn't fit an existing one.
4. If a command's behavior has a non-obvious tradeoff (e.g. speed vs. cost,
   destructive vs. safe), note it in one line rather than leaving it implicit.
