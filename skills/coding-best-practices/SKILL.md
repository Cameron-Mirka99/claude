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
