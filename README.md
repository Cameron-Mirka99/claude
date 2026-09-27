# claude

Shared Claude Code config, synced across devices via this repo.

Holds the parts of `~/.claude` that are safe and useful to version-control
and share between machines:

- `skills/` — custom skills (each linked individually into `~/.claude/skills/<name>`)
- `agents/` — custom subagents (linked as `~/.claude/agents`)
- `commands/` — custom slash commands (linked as `~/.claude/commands`)
- `output-styles/` — custom output styles (linked as `~/.claude/output-styles`)
- `settings.json` — shared settings (hard-linked to `~/.claude/settings.json`)
- `CLAUDE.md` — global instructions applied on every project, every machine
  (hard-linked to `~/.claude/CLAUDE.md`)

Deliberately **excluded**: credentials, session history, transcripts, cache,
and anything else in `~/.claude` that's per-machine or sensitive. Those stay
local and are never touched by this repo.

## Setup on a (new) machine

```powershell
git clone https://github.com/Cameron-Mirka99/claude.git
cd claude
.\setup.ps1
```

`setup.ps1` is idempotent — re-run it any time (after `git pull`, after adding
a new skill/agent/command, or when first setting up a machine). It merges in
any pre-existing real files/folders under `~/.claude` rather than overwriting
them, and uses directory junctions + a file hardlink so no admin rights or
Developer Mode are required on Windows.

After adding or editing anything here, commit and push as usual — other
machines pick it up on their next `git pull` (folders are picked up
immediately; a first-time link on a brand-new machine still needs
`.\setup.ps1`).
