<#
.SYNOPSIS
    Turbo Pipeline — Automated feature builder using claude -p
.DESCRIPTION
    Reads feature_list.json, builds dependency waves, and executes each feature
    in a fresh claude -p session. Independent features run in parallel.
.EXAMPLE
    .\turbo-pipeline.ps1 -Project "E:\my-project"
    .\turbo-pipeline.ps1 -Project "E:\my-project" -Count 3 -Model opus
    .\turbo-pipeline.ps1 -Project "E:\my-project" -DryRun
    .\turbo-pipeline.ps1 -Project "E:\my-project" -Parallel 3
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Project,

    [int]$Count = 999,

    [string]$Model = "sonnet",

    [int]$Parallel = 1,

    [int]$TimeoutMinutes = 10,

    [switch]$DryRun,

    [switch]$Sequential
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateFile = Join-Path $ScriptDir "turbo-prompt-template.md"
$StartTime = Get-Date

# --- Helpers ---

function Write-Status {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $Color
}

function Read-FileOrEmpty {
    param([string]$Path)
    if (Test-Path $Path) { Get-Content $Path -Raw -Encoding UTF8 } else { "(not found)" }
}

function Get-FeatureList {
    $path = Join-Path $Project "feature_list.json"
    if (-not (Test-Path $path)) {
        Write-Error "feature_list.json not found in $Project"
        exit 1
    }
    Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

# --- Step 1: Load project context ---

Write-Status "Loading project context from: $Project"

$FeatureData = Get-FeatureList
$ClaudeMd = Read-FileOrEmpty (Join-Path $Project "CLAUDE.md")
$ArchMd = Read-FileOrEmpty (Join-Path $Project "docs" "Architecture.md")
if ($ArchMd -eq "(not found)") {
    $ArchMd = Read-FileOrEmpty (Join-Path $Project "Architecture.md")
}
$LessonsLearned = Read-FileOrEmpty (Join-Path $HOME ".claude" "rules" "lessons-learned.md")
$Instincts = Read-FileOrEmpty (Join-Path $HOME ".claude" "rules" "instincts.md")
$Template = Get-Content $TemplateFile -Raw -Encoding UTF8

# --- Step 2: Build dependency graph & waves ---

$AllFeatures = $FeatureData.features
$Remaining = $AllFeatures | Where-Object { -not $_.passes }

if ($Remaining.Count -eq 0) {
    Write-Status "All features already pass. Nothing to build." "Green"
    exit 0
}

Write-Status "Remaining features: $($Remaining.Count)"

function Build-Waves {
    param($Features, $AllFeatures)

    $completed = @{}
    foreach ($f in $AllFeatures) {
        if ($f.passes) { $completed[$f.id] = $true }
    }

    $remaining = [System.Collections.ArrayList]@($Features)
    $waves = @()
    $failed = @{}

    while ($remaining.Count -gt 0) {
        $wave = @()
        $toRemove = @()

        foreach ($f in $remaining) {
            $deps = @()
            if ($f.PSObject.Properties['depends_on'] -and $null -ne $f.depends_on) {
                $deps = @($f.depends_on)
            }

            $depsBlocked = $false
            $depsMet = $true
            foreach ($d in $deps) {
                if ($failed.ContainsKey($d)) { $depsBlocked = $true; break }
                if (-not $completed.ContainsKey($d)) { $depsMet = $false; break }
            }

            if ($depsBlocked) {
                $failed[$f.id] = "dependency $d failed"
                $toRemove += $f
            }
            elseif ($depsMet) {
                $wave += $f
                $toRemove += $f
            }
        }

        if ($wave.Count -eq 0 -and $toRemove.Count -eq 0) {
            foreach ($f in $remaining) { $failed[$f.id] = "circular dependency or unresolvable" }
            break
        }

        foreach ($item in $toRemove) { $remaining.Remove($item) | Out-Null }

        if ($wave.Count -gt 0) {
            $waves += ,@($wave)
            foreach ($f in $wave) { $completed[$f.id] = $true }
        }
    }

    return @{ Waves = $waves; Failed = $failed }
}

$GraphResult = Build-Waves -Features $Remaining -AllFeatures $AllFeatures
$Waves = $GraphResult.Waves
$SkippedByDep = $GraphResult.Failed

Write-Status "Execution plan: $($Waves.Count) wave(s)"
for ($i = 0; $i -lt $Waves.Count; $i++) {
    $ids = ($Waves[$i] | ForEach-Object { $_.id }) -join ", "
    Write-Status "  Wave $($i+1): $ids" "DarkCyan"
}

if ($SkippedByDep.Count -gt 0) {
    Write-Status "Skipped (dependency issues): $($SkippedByDep.Keys -join ', ')" "Yellow"
}

# --- Step 3: Build prompt for a feature ---

function Build-Prompt {
    param($Feature)

    $steps = ""
    if ($Feature.PSObject.Properties['steps'] -and $null -ne $Feature.steps) {
        $stepList = @($Feature.steps)
        for ($i = 0; $i -lt $stepList.Count; $i++) {
            $steps += "$($i+1). $($stepList[$i])`n"
        }
    }
    else {
        $steps = "(no explicit steps — implement based on description)"
    }

    $decisions = ""
    if ($Feature.PSObject.Properties['decisions'] -and $null -ne $Feature.decisions) {
        $Feature.decisions.PSObject.Properties | ForEach-Object {
            $decisions += "- **$($_.Name)**: $($_.Value)`n"
        }
    }
    else {
        $decisions = "(none — use autonomous judgment)"
    }

    $depends = ""
    if ($Feature.PSObject.Properties['depends_on'] -and $null -ne $Feature.depends_on) {
        $depNames = @($Feature.depends_on) | ForEach-Object {
            $depId = $_
            $dep = $AllFeatures | Where-Object { $_.id -eq $depId }
            if ($dep) { "$depId ($($dep.name)) — completed" } else { "$depId — completed" }
        }
        $depends = ($depNames -join "`n")
    }
    else {
        $depends = "(none)"
    }

    $priority = if ($Feature.PSObject.Properties['priority']) { $Feature.priority } else { "Must" }
    $today = (Get-Date).ToString("yyyy-MM-dd")

    $prompt = $Template
    $prompt = $prompt -replace '\{\{CLAUDE_MD\}\}', $ClaudeMd
    $prompt = $prompt -replace '\{\{ARCHITECTURE_MD\}\}', $ArchMd
    $prompt = $prompt -replace '\{\{LESSONS_LEARNED\}\}', $LessonsLearned
    $prompt = $prompt -replace '\{\{INSTINCTS\}\}', $Instincts
    $prompt = $prompt -replace '\{\{FEATURE_ID\}\}', $Feature.id
    $prompt = $prompt -replace '\{\{FEATURE_NAME\}\}', $Feature.name
    $prompt = $prompt -replace '\{\{FEATURE_DESCRIPTION\}\}', $Feature.description
    $prompt = $prompt -replace '\{\{FEATURE_PRIORITY\}\}', $priority
    $prompt = $prompt -replace '\{\{FEATURE_STEPS\}\}', $steps
    $prompt = $prompt -replace '\{\{FEATURE_DECISIONS\}\}', $decisions
    $prompt = $prompt -replace '\{\{FEATURE_DEPENDS\}\}', $depends
    $prompt = $prompt -replace '\{\{TODAY\}\}', $today

    return $prompt
}

# --- Step 4: Execute features wave by wave ---

$Results = @{
    Passed  = @()
    Failed  = @()
    Skipped = @($SkippedByDep.Keys)
}

$BuiltCount = 0

foreach ($waveIndex in 0..($Waves.Count - 1)) {
    $wave = $Waves[$waveIndex]

    if ($BuiltCount -ge $Count) { break }

    $waveFeatures = @($wave | Select-Object -First ($Count - $BuiltCount))
    $waveIds = ($waveFeatures | ForEach-Object { $_.id }) -join ", "
    Write-Status "`n=== Wave $($waveIndex + 1): $waveIds ===" "White"

    if ($Sequential -or $Parallel -le 1 -or $waveFeatures.Count -le 1) {
        # Sequential execution
        foreach ($feature in $waveFeatures) {
            $BuiltCount++
            Write-Status "Building $($feature.id) - $($feature.name) [$BuiltCount]..." "Yellow"

            $prompt = Build-Prompt -Feature $feature

            if ($DryRun) {
                $promptFile = Join-Path $Project ".claude" "turbo-dry-run-$($feature.id).md"
                $promptDir = Split-Path $promptFile -Parent
                if (-not (Test-Path $promptDir)) { New-Item -ItemType Directory -Path $promptDir -Force | Out-Null }
                $prompt | Out-File -FilePath $promptFile -Encoding UTF8
                Write-Status "  [DRY-RUN] Prompt saved to: $promptFile" "DarkYellow"
                $Results.Passed += $feature.id
                continue
            }

            $promptFile = [System.IO.Path]::GetTempFileName()
            $prompt | Out-File -FilePath $promptFile -Encoding UTF8

            try {
                $output = ""
                $process = Start-Process -FilePath "claude" -ArgumentList @(
                    "-p", (Get-Content $promptFile -Raw),
                    "--model", $Model,
                    "--dangerously-skip-permissions",
                    "--allowedTools", "Bash,Edit,Read,Write,Glob,Grep"
                ) -WorkingDirectory $Project -NoNewWindow -PassThru -RedirectStandardOutput "$promptFile.out" -RedirectStandardError "$promptFile.err"

                $timedOut = -not $process.WaitForExit($TimeoutMinutes * 60 * 1000)

                if ($timedOut) {
                    $process.Kill()
                    Write-Status "  TIMEOUT after $TimeoutMinutes min" "Red"
                    $Results.Failed += "$($feature.id) (timeout)"
                    continue
                }

                $output = Get-Content "$promptFile.out" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue

                # Verify result
                $updatedData = Get-FeatureList
                $updatedFeature = $updatedData.features | Where-Object { $_.id -eq $feature.id }

                if ($updatedFeature.passes) {
                    Write-Status "  PASSED" "Green"
                    $Results.Passed += $feature.id
                }
                else {
                    $failReason = if ($output -match 'TURBO_RESULT:FAILED\s*[-—]\s*(.+)') { $Matches[1] } else { "passes not set to true" }
                    Write-Status "  FAILED: $failReason" "Red"
                    $Results.Failed += "$($feature.id) ($failReason)"
                }
            }
            catch {
                Write-Status "  ERROR: $_" "Red"
                $Results.Failed += "$($feature.id) (exception: $_)"
            }
            finally {
                Remove-Item $promptFile -Force -ErrorAction SilentlyContinue
                Remove-Item "$promptFile.out" -Force -ErrorAction SilentlyContinue
                Remove-Item "$promptFile.err" -Force -ErrorAction SilentlyContinue
            }
        }
    }
    else {
        # Parallel execution within wave
        $jobs = @()
        foreach ($feature in $waveFeatures) {
            $BuiltCount++
            Write-Status "Starting $($feature.id) — $($feature.name) [parallel]..." "Yellow"

            $prompt = Build-Prompt -Feature $feature
            $promptFile = Join-Path [System.IO.Path]::GetTempPath() "turbo-$($feature.id).md"
            $prompt | Out-File -FilePath $promptFile -Encoding UTF8

            if ($DryRun) {
                $dryFile = Join-Path $Project ".claude" "turbo-dry-run-$($feature.id).md"
                $dryDir = Split-Path $dryFile -Parent
                if (-not (Test-Path $dryDir)) { New-Item -ItemType Directory -Path $dryDir -Force | Out-Null }
                $prompt | Out-File -FilePath $dryFile -Encoding UTF8
                $Results.Passed += $feature.id
                continue
            }

            $job = Start-Job -ScriptBlock {
                param($PromptContent, $ProjectDir, $ModelName, $Timeout, $FeatureId)
                $tmpFile = [System.IO.Path]::GetTempFileName()
                $PromptContent | Out-File -FilePath $tmpFile -Encoding UTF8
                $outFile = "$tmpFile.out"

                $proc = Start-Process -FilePath "claude" -ArgumentList @(
                    "-p", (Get-Content $tmpFile -Raw),
                    "--model", $ModelName,
                    "--dangerously-skip-permissions",
                    "--allowedTools", "Bash,Edit,Read,Write,Glob,Grep"
                ) -WorkingDirectory $ProjectDir -NoNewWindow -PassThru -RedirectStandardOutput $outFile -RedirectStandardError "$tmpFile.err"

                $timedOut = -not $proc.WaitForExit($Timeout * 60 * 1000)

                $result = @{ Id = $FeatureId; TimedOut = $timedOut; ExitCode = $proc.ExitCode }
                if (-not $timedOut) {
                    $result.Output = Get-Content $outFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                }
                else {
                    $proc.Kill()
                }

                Remove-Item $tmpFile, $outFile, "$tmpFile.err" -Force -ErrorAction SilentlyContinue
                return $result
            } -ArgumentList $prompt, $Project, $Model, $TimeoutMinutes, $feature.id

            $jobs += @{ Job = $job; Feature = $feature }

            # Throttle parallel jobs
            while (($jobs | Where-Object { $_.Job.State -eq 'Running' }).Count -ge $Parallel) {
                Start-Sleep -Milliseconds 500
            }
        }

        # Wait for all jobs in wave
        $jobs | ForEach-Object { $_.Job | Wait-Job | Out-Null }

        # Collect results
        foreach ($entry in $jobs) {
            $jobResult = Receive-Job -Job $entry.Job
            Remove-Job -Job $entry.Job -Force

            if ($null -eq $jobResult -or $jobResult.TimedOut) {
                Write-Status "  $($entry.Feature.id): TIMEOUT" "Red"
                $Results.Failed += "$($entry.Feature.id) (timeout)"
                continue
            }

            # Re-read feature_list.json to check pass status
            $updatedData = Get-FeatureList
            $updatedFeature = $updatedData.features | Where-Object { $_.id -eq $entry.Feature.id }

            if ($updatedFeature.passes) {
                Write-Status "  $($entry.Feature.id): PASSED" "Green"
                $Results.Passed += $entry.Feature.id
            }
            else {
                Write-Status "  $($entry.Feature.id): FAILED" "Red"
                $Results.Failed += "$($entry.Feature.id)"
            }
        }
    }

    # Refresh context between waves (Architecture.md may have changed)
    $ArchMd = Read-FileOrEmpty (Join-Path $Project "docs" "Architecture.md")
    if ($ArchMd -eq "(not found)") {
        $ArchMd = Read-FileOrEmpty (Join-Path $Project "Architecture.md")
    }
}

# --- Step 5: Final Report ---

$Elapsed = (Get-Date) - $StartTime
Write-Host ""
Write-Host "===========================================" -ForegroundColor White
Write-Host " TURBO PIPELINE - FINAL REPORT" -ForegroundColor White
Write-Host "===========================================" -ForegroundColor White
Write-Host ""
Write-Host "  Passed:  $($Results.Passed.Count)" -ForegroundColor Green
Write-Host "  Failed:  $($Results.Failed.Count)" -ForegroundColor $(if ($Results.Failed.Count -gt 0) { "Red" } else { "Green" })
Write-Host "  Skipped: $($Results.Skipped.Count)" -ForegroundColor $(if ($Results.Skipped.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Elapsed: $($Elapsed.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan
Write-Host ""

if ($Results.Passed.Count -gt 0) {
    Write-Host "  [PASS] $($Results.Passed -join ', ')" -ForegroundColor Green
}
if ($Results.Failed.Count -gt 0) {
    Write-Host "  [FAIL] $($Results.Failed -join ', ')" -ForegroundColor Red
}
if ($Results.Skipped.Count -gt 0) {
    Write-Host "  [SKIP] $($Results.Skipped -join ', ')" -ForegroundColor Yellow
}

# --- Step 6: Decision Review ---

$DecisionsLog = Join-Path $Project ".claude" "decisions.log"
if (Test-Path $DecisionsLog) {
    $warnings = Get-Content $DecisionsLog -Encoding UTF8 | Where-Object { $_ -match 'WARNING' }
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "  [!] Decisions requiring review ($($warnings.Count)):" -ForegroundColor Yellow
        foreach ($w in $warnings) {
            Write-Host "    $w" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor White
