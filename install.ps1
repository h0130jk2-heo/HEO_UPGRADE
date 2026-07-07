<#
.SYNOPSIS
    HEO_UPGRADE Framework Installer for Windows
.DESCRIPTION
    Copies skills and rules from this repo into ~/.claude/ so the framework
    is available globally in Claude Code on this machine.
#>

param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot
$FrameworkDir = Join-Path $RepoRoot 'framework'
$ClaudeDir = Join-Path $env:USERPROFILE '.claude'
$SkillsDst = Join-Path $ClaudeDir 'skills'
$RulesDst = Join-Path $ClaudeDir 'rules'
$ToolsDst = Join-Path $ClaudeDir 'tools'

if (-not (Test-Path $FrameworkDir)) {
    Write-Error "framework/ directory not found. Run this script from the repo root."
    exit 1
}

Write-Host "`n=== HEO_UPGRADE Framework Installer ===" -ForegroundColor Cyan
Write-Host "Source : $FrameworkDir"
Write-Host "Target : $ClaudeDir`n"

New-Item -ItemType Directory -Force $SkillsDst | Out-Null
New-Item -ItemType Directory -Force $RulesDst | Out-Null
New-Item -ItemType Directory -Force $ToolsDst | Out-Null

$skills = Get-ChildItem (Join-Path $FrameworkDir 'skills') -Directory
$installed = 0
foreach ($skill in $skills) {
    $dst = Join-Path $SkillsDst $skill.Name
    if ((Test-Path $dst) -and -not $Force) {
        Write-Host "  SKIP  $($skill.Name) (already exists, use -Force to overwrite)" -ForegroundColor Yellow
    } else {
        Copy-Item -Recurse -Force $skill.FullName $dst
        Write-Host "  OK    $($skill.Name)" -ForegroundColor Green
        $installed++
    }
}

# instincts.md / lessons-learned.md accumulate the user's learning data — NEVER overwrite them,
# even with -Force. They are created only on a fresh install where they don't yet exist.
$UserDataRules = @('instincts.md', 'lessons-learned.md')
$rules = Get-ChildItem (Join-Path $FrameworkDir 'rules') -File
$rulesInstalled = 0
foreach ($rule in $rules) {
    $dst = Join-Path $RulesDst $rule.Name
    if (($UserDataRules -contains $rule.Name) -and (Test-Path $dst)) {
        Write-Host "  KEEP  $($rule.Name) (user data preserved, never overwritten)" -ForegroundColor Cyan
    } elseif ((Test-Path $dst) -and -not $Force) {
        Write-Host "  SKIP  $($rule.Name) (already exists, use -Force to overwrite)" -ForegroundColor Yellow
    } else {
        Copy-Item -Force $rule.FullName $dst
        Write-Host "  OK    $($rule.Name)" -ForegroundColor Green
        $rulesInstalled++
    }
}

$toolsSrc = Join-Path $FrameworkDir 'tools'
$toolsInstalled = 0
$toolsTotal = 0
if (Test-Path $toolsSrc) {
    $tools = Get-ChildItem $toolsSrc -File
    $toolsTotal = $tools.Count
    foreach ($tool in $tools) {
        $dst = Join-Path $ToolsDst $tool.Name
        if ((Test-Path $dst) -and -not $Force) {
            Write-Host "  SKIP  $($tool.Name) (already exists, use -Force to overwrite)" -ForegroundColor Yellow
        } else {
            Copy-Item -Force $tool.FullName $dst
            Write-Host "  OK    $($tool.Name)" -ForegroundColor Green
            $toolsInstalled++
        }
    }
}

Write-Host "`n--- Result ---" -ForegroundColor Cyan
Write-Host "Skills : $installed / $($skills.Count) installed"
Write-Host "Rules  : $rulesInstalled / $($rules.Count) installed"
Write-Host "Tools  : $toolsInstalled / $toolsTotal installed"
Write-Host "`nDone. Restart Claude Code to pick up the new skills." -ForegroundColor Green
