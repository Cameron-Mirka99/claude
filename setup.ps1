<#
.SYNOPSIS
  Links this repo into ~/.claude so its contents are what Claude Code reads.

.DESCRIPTION
  Safe to re-run any time (after `git pull`, after adding a new skill, or on
  a brand-new machine right after cloning this repo).

  - agents/, commands/, output-styles/  -> linked as whole-folder directory
    junctions (no admin / Developer Mode required on Windows).
  - skills/<name>                       -> each skill folder is linked
    individually into ~/.claude/skills/<name>. ~/.claude/skills/synced is
    Anthropic's own managed bucket and is never touched.
  - settings.json, CLAUDE.md             -> hard-linked to their ~/.claude
    counterparts (junctions only work on directories, not files).

  If a real (non-linked) file or folder already exists on the ~/.claude side
  with content, it is preserved: existing folder contents are merged into the
  repo copy before linking, and an existing file that differs from the
  repo's is backed up next to it rather than overwritten.
#>

$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot
$ClaudeDir = Join-Path $HOME '.claude'

function Get-ReparseInfo($Path) {
    if (-not (Test-Path $Path)) { return $null }
    $item = Get-Item -Path $Path -Force
    if ($item.LinkType) {
        return [pscustomobject]@{ LinkType = $item.LinkType; Target = ($item.Target | Select-Object -First 1) }
    }
    return $null
}

function Merge-DirectoryInto($SourceDir, $DestDir) {
    Get-ChildItem -Path $SourceDir -Force | ForEach-Object {
        $destPath = Join-Path $DestDir $_.Name
        if (Test-Path $destPath) {
            Write-Warning "  Skipping '$($_.Name)': already exists in repo copy, leaving both - resolve manually."
        } else {
            Move-Item -Path $_.FullName -Destination $DestDir
            Write-Host "  Moved existing '$($_.Name)' into repo."
        }
    }
}

function Link-Folder($Name) {
    $claudePath = Join-Path $ClaudeDir $Name
    $repoPath = Join-Path $RepoRoot $Name

    New-Item -ItemType Directory -Path $repoPath -Force | Out-Null

    $reparse = Get-ReparseInfo $claudePath
    if ($reparse -and $reparse.LinkType -eq 'Junction') {
        if ($reparse.Target -eq $repoPath) {
            Write-Host "[ok] ~/.claude/$Name already linked."
            return
        } else {
            Write-Warning "[!] ~/.claude/$Name is a junction to a different target ($($reparse.Target)). Leaving it alone."
            return
        }
    }

    if (Test-Path $claudePath) {
        Write-Host "[*] ~/.claude/$Name exists as a real folder - merging its contents into the repo first."
        Merge-DirectoryInto -SourceDir $claudePath -DestDir $repoPath
        Remove-Item -Path $claudePath -Recurse -Force
    }

    New-Item -ItemType Junction -Path $claudePath -Target $repoPath | Out-Null
    Write-Host "[+] Linked ~/.claude/$Name -> $repoPath"
}

function Link-Skill($SkillDir) {
    $name = $SkillDir.Name
    if ($name -eq 'synced') { return }

    $claudePath = Join-Path $ClaudeDir "skills\$name"
    $repoPath = $SkillDir.FullName

    $reparse = Get-ReparseInfo $claudePath
    if ($reparse -and $reparse.LinkType -eq 'Junction') {
        if ($reparse.Target -eq $repoPath) {
            Write-Host "[ok] skill '$name' already linked."
            return
        } else {
            Write-Warning "[!] ~/.claude/skills/$name is a junction to a different target. Leaving it alone."
            return
        }
    }

    if (Test-Path $claudePath) {
        Write-Host "[*] ~/.claude/skills/$name exists as a real folder - merging its contents into the repo first."
        Merge-DirectoryInto -SourceDir $claudePath -DestDir $repoPath
        Remove-Item -Path $claudePath -Recurse -Force
    }

    New-Item -ItemType Junction -Path $claudePath -Target $repoPath | Out-Null
    Write-Host "[+] Linked ~/.claude/skills/$name -> $repoPath"
}

function Link-File($Name) {
    $claudePath = Join-Path $ClaudeDir $Name
    $repoPath = Join-Path $RepoRoot $Name

    if (Test-Path $claudePath) {
        $sameContent = (Test-Path $repoPath) -and
            ((Get-Content $claudePath -Raw) -eq (Get-Content $repoPath -Raw))
        $alreadyLinked = $false
        try {
            $claudeId = (fsutil file queryfileid $claudePath 2>$null)
            $repoId = (fsutil file queryfileid $repoPath 2>$null)
            $alreadyLinked = ($claudeId -and $repoId -and $claudeId -eq $repoId)
        } catch {}

        if ($alreadyLinked) {
            Write-Host "[ok] $Name already linked."
            return
        }

        if (-not $sameContent -and (Test-Path $repoPath)) {
            $backup = Join-Path $ClaudeDir "$Name.pre-link-backup"
            Copy-Item $claudePath $backup -Force
            Write-Warning "[!] ~/.claude/$Name differed from the repo copy - backed up to $backup before linking."
        }
        Remove-Item $claudePath -Force
    }

    if (-not (Test-Path $repoPath)) {
        Write-Warning "[!] No $Name in repo to link from - skipping."
        return
    }

    cmd /c "mklink /H `"$claudePath`" `"$repoPath`"" | Out-Null
    Write-Host "[+] Linked ~/.claude/$Name -> $repoPath"
}

Write-Host "Repo: $RepoRoot"
Write-Host "Claude dir: $ClaudeDir"
Write-Host ""

foreach ($folder in @('agents', 'commands', 'output-styles')) {
    Link-Folder $folder
}

New-Item -ItemType Directory -Path (Join-Path $RepoRoot 'skills') -Force | Out-Null
Get-ChildItem -Path (Join-Path $RepoRoot 'skills') -Directory | ForEach-Object { Link-Skill $_ }

foreach ($file in @('settings.json', 'CLAUDE.md')) {
    Link-File $file
}

Write-Host ""
Write-Host "Done."
