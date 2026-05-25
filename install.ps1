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

if (-not (Test-Path $FrameworkDir)) {
    Write-Error "framework/ directory not found. Run this script from the repo root."
    exit 1
}

Write-Host "`n=== HEO_UPGRADE Framework Installer ===" -ForegroundColor Cyan
Write-Host "Source : $FrameworkDir"
Write-Host "Target : $ClaudeDir`n"

New-Item -ItemType Directory -Force $SkillsDst | Out-Null
New-Item -ItemType Directory -Force $RulesDst | Out-Null

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

$rules = Get-ChildItem (Join-Path $FrameworkDir 'rules') -File
$rulesInstalled = 0
foreach ($rule in $rules) {
    $dst = Join-Path $RulesDst $rule.Name
    if ((Test-Path $dst) -and -not $Force) {
        Write-Host "  SKIP  $($rule.Name) (already exists, use -Force to overwrite)" -ForegroundColor Yellow
    } else {
        Copy-Item -Force $rule.FullName $dst
        Write-Host "  OK    $($rule.Name)" -ForegroundColor Green
        $rulesInstalled++
    }
}

Write-Host "`n--- Result ---" -ForegroundColor Cyan
Write-Host "Skills : $installed / $($skills.Count) installed"
Write-Host "Rules  : $rulesInstalled / $($rules.Count) installed"
Write-Host "`nDone. Restart Claude Code to pick up the new skills." -ForegroundColor Green
