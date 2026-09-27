---
name: coding-best-practices
description: "House engineering conventions to apply whenever writing, editing, reviewing, or planning code changes in any project or language. Load before creating a new code file, before making a substantial edit to an existing one, and during code review. Not for prose/docs/config-only changes with no logic."
---

## How this skill works

This is a running checklist of conventions, not a one-off workflow. Read all
sections below and apply whichever ones are relevant to the code being
touched. New rules get appended here over time — treat every section as
active guidance, not history.

## 1. Keep source files small and single-purpose

Target: no source file over ~200 lines. Treat 200 as a trigger to stop and
reassess, not a hard cutoff to squeeze under with denser code.

- **Before editing an existing file**, check its current line count. If it's
  already near or over ~200 lines and the task adds meaningfully more, split
  it before piling on — don't be the edit that pushes a 190-line file to 350.
- **Before creating a new file**, if the planned content would clearly exceed
  ~200 lines, design it as multiple files from the start.
- Split along responsibility boundaries, not arbitrary line cuts: separate a
  class from its helpers, pull unrelated functions into their own modules,
  move types/interfaces/constants to their own file, isolate one pipeline
  step per file. Each resulting file should be describable in one sentence
  ("this file does X") — that's the test for whether a split is real or
  cosmetic.
- Use judgment: a single cohesive data table, a generated file, or one
  genuinely indivisible dense function is fine to leave alone even past 200
  lines. The goal is process-oriented, single-responsibility files — not
  hitting a number for its own sake. Don't split a cohesive unit just to
  satisfy the count.
- When a split happens, wire up imports/exports cleanly and don't leave the
  original file as a thin re-export shim unless the language/ecosystem
  idiomatically expects one (e.g. a package's public `index`).

## 2. Keep functions small and single-purpose

Target: no function/method over ~20 lines. Treat 20 as a trigger to stop and
reassess, not a hard cutoff to squeeze under by deleting whitespace or
cramming statements onto one line.

- **Before editing an existing function**, check its current length. If it's
  already near or over ~20 lines and the task adds meaningfully more logic,
  extract before piling on.
- **Before writing a new function**, if it's clearly going to run long,
  design it as a small orchestrating function calling out to smaller helpers
  from the start.
- Extract along responsibility boundaries, not arbitrary line cuts: a
  distinct step in a larger process, a repeated block, a validation/parsing
  chunk, a branch of a conditional that's really its own concern. Each
  extracted function should be nameable with a precise verb phrase that says
  exactly what it does ("validates X", "parses Y into Z") — if you can't name
  it concisely, it's not a clean extraction yet.
- Use judgment: a long-but-flat sequence with no real sub-steps (e.g. a
  straight-line list of similar field assignments, a big but simple switch/
  match), or a function that's long only because of language boilerplate, is
  fine to leave alone. The goal is functions that each do one clear thing —
  not hitting a number for its own sake. Don't fragment a single cohesive
  operation into artificial pieces just to satisfy the count.
- Name extracted helpers for what they do, not how they relate to the caller
  (`calculate_tax`, not `helper_1` or `do_part_of_process`), and keep their
  parameter lists honest — if an extraction needs eight parameters to work,
  the boundary was probably drawn in the wrong place.

## 3. Organize src by functionality, not by file type

`src/` should read as a table of contents for the app: each top-level folder
is one feature/functionality area, not a bucket like `components/`,
`services/`, or `handlers/` shared across unrelated features.

- Layout: `src/<feature>/...` for each distinct piece of functionality —
  someone should be able to tell what the app does just from the list of
  folders under `src/`.
- **Per-feature utilities**: inside a feature folder, put helper
  functions/types that only that feature uses in `src/<feature>/util/`
  (match the casing convention already used elsewhere in that codebase —
  don't introduce a new casing style just for this).
- **Shared utilities**: as soon as a second, unrelated feature needs the same
  helper, promote it out of the feature-local `util/` folder into the
  top-level `src/util/` — that top-level folder is for code genuinely shared
  across two or more features, not a dumping ground for anything vaguely
  "utility". A helper used by only one feature stays local to it, even if it
  feels generic.
- When promoting a util, update its imports at every call site and delete the
  now-unused feature-local copy — don't leave both versions around.
- Before adding a new top-level folder under `src/` that isn't a feature
  (e.g. another shared-concerns folder alongside `util/`), check whether the
  project already has a place for that concern; don't fragment shared code
  across multiple ad-hoc shared folders.
