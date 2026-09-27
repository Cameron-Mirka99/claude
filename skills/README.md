# Custom skills

Drop custom skill folders here (each with its own `SKILL.md`), e.g.:

```
skills/
  my-skill/
    SKILL.md
```

Run `.\setup.ps1` afterward (on this or any other machine, after `git pull`) to
link each skill folder into `~/.claude/skills/<name>` so Claude Code picks it up.

Note: `~/.claude/skills/synced` is Anthropic's own managed bucket for built-in
skills (pdf, docx, pptx, etc.) — it lives only on `~/.claude` and is never
touched by this repo or `setup.ps1`.
