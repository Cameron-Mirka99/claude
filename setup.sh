#!/usr/bin/env bash
# Links this repo into ~/.claude so its contents are what Claude Code reads.
# Linux/macOS counterpart to setup.ps1 (Windows). Safe to re-run any time
# (after `git pull`, after adding a new skill, or on a brand-new machine
# right after cloning this repo).
#
# - agents/, commands/, output-styles/  -> linked as whole-folder symlinks.
# - skills/<name>                       -> each skill folder is linked
#   individually into ~/.claude/skills/<name>. ~/.claude/skills/synced is
#   Anthropic's own managed bucket and is never touched.
# - settings.json, CLAUDE.md            -> linked individually (symlink;
#   no hardlink workaround needed here, unlike Windows).
#
# If a real (non-linked) file or folder already exists on the ~/.claude side
# with content, it is preserved: existing folder contents are merged into the
# repo copy before linking, and an existing file that differs from the
# repo's is backed up next to it rather than overwritten.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

merge_dir_into() {
    local source="$1" dest="$2"
    local item name
    for item in "$source"/* "$source"/.[!.]*; do
        [ -e "$item" ] || continue
        name="$(basename "$item")"
        if [ -e "$dest/$name" ]; then
            echo "  Skipping '$name': already exists in repo copy, leaving both - resolve manually." >&2
        else
            mv "$item" "$dest/"
            echo "  Moved existing '$name' into repo."
        fi
    done
}

link_path() {
    local claude_path="$1" repo_path="$2" label="$3"

    if [ -L "$claude_path" ]; then
        local current_target
        current_target="$(readlink "$claude_path")"
        if [ "$current_target" = "$repo_path" ]; then
            echo "[ok] $label already linked."
            return
        else
            echo "[!] $claude_path is a symlink to a different target ($current_target). Leaving it alone." >&2
            return
        fi
    fi

    if [ -e "$claude_path" ]; then
        if [ -d "$claude_path" ]; then
            echo "[*] $label exists as a real folder - merging its contents into the repo first."
            merge_dir_into "$claude_path" "$repo_path"
            rm -rf "$claude_path"
        elif ! diff -q "$claude_path" "$repo_path" >/dev/null 2>&1; then
            local backup="$claude_path.pre-link-backup"
            cp "$claude_path" "$backup"
            echo "[!] $label differed from the repo copy - backed up to $backup before linking." >&2
            rm -f "$claude_path"
        else
            rm -f "$claude_path"
        fi
    fi

    ln -s "$repo_path" "$claude_path"
    echo "[+] Linked $claude_path -> $repo_path"
}

link_folder() {
    local name="$1"
    mkdir -p "$REPO_ROOT/$name"
    link_path "$CLAUDE_DIR/$name" "$REPO_ROOT/$name" "~/.claude/$name"
}

link_skill() {
    local repo_path="$1"
    local name
    name="$(basename "$repo_path")"
    [ "$name" = "synced" ] && return
    link_path "$CLAUDE_DIR/skills/$name" "$repo_path" "skill '$name'"
}

link_file() {
    local name="$1"
    local repo_path="$REPO_ROOT/$name"
    if [ ! -f "$repo_path" ]; then
        echo "[!] No $name in repo to link from - skipping." >&2
        return
    fi
    link_path "$CLAUDE_DIR/$name" "$repo_path" "$name"
}

echo "Repo: $REPO_ROOT"
echo "Claude dir: $CLAUDE_DIR"
echo

mkdir -p "$CLAUDE_DIR"

for folder in agents commands output-styles; do
    link_folder "$folder"
done

mkdir -p "$REPO_ROOT/skills" "$CLAUDE_DIR/skills"
for skill_dir in "$REPO_ROOT"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    link_skill "${skill_dir%/}"
done

for file in settings.json CLAUDE.md; do
    link_file "$file"
done

echo
echo "Done."
