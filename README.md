# claude

Shared Claude Code config, synced across devices via this repo.

Holds the parts of `~/.claude` that are safe and useful to version-control
and share between machines:

- `skills/` — custom skills (each linked individually into `~/.claude/skills/<name>`)
- `agents/` — custom subagents (linked as `~/.claude/agents`)
- `commands/` — custom slash commands (linked as `~/.claude/commands`)
- `output-styles/` — custom output styles (linked as `~/.claude/output-styles`)
- `settings.json` — shared settings (linked to `~/.claude/settings.json`)
- `CLAUDE.md` — global instructions applied on every project, every machine
  (linked to `~/.claude/CLAUDE.md`)

Deliberately **excluded**: credentials, session history, transcripts, cache,
and anything else in `~/.claude` that's per-machine or sensitive. Those stay
local and are never touched by this repo.

Also excluded, structurally: Claude Code's per-project **memory**
(`~/.claude/projects/<project>/memory/`). It's keyed off the project's
absolute path, which never matches across a Windows machine and a Linux
machine (different `$HOME`, different path format) — so it can't be synced
this way. Anything that needs to apply everywhere belongs in `CLAUDE.md`
instead.

## Setup on a (new) machine

Windows (PowerShell):

```powershell
git clone https://github.com/Cameron-Mirka99/claude.git
cd claude
.\setup.ps1
```

Uses directory junctions + a file hardlink, so no admin rights or Developer
Mode are required.

Linux/macOS (bash):

```bash
git clone https://github.com/Cameron-Mirka99/claude.git
cd claude
./setup.sh
```

Uses plain symlinks throughout — no special permissions needed there either.

Both scripts are idempotent — re-run either any time (after `git pull`, after
adding a new skill/agent/command, or when first setting up a machine). They
merge in any pre-existing real files/folders under `~/.claude` rather than
overwriting them, backing up anything that would otherwise be lost.

After adding or editing anything here, commit as usual — but **do not
push**; that step is always left for manual review (see `CLAUDE.md`). Other
machines pick changes up on their next `git pull` (folders are picked up
immediately; a first-time link on a brand-new machine still needs the setup
script).
