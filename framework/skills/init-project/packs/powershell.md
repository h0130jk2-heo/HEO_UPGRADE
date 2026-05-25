# PowerShell Rules

## Language Conventions
- Use `Verb-Noun` naming for functions (e.g., `Get-InvoiceData`, `Send-Report`). Run `Get-Verb` for approved verbs.
- Naming: `PascalCase` for functions/cmdlets/parameters, `$PascalCase` for variables (PowerShell convention).
- Use full cmdlet names in scripts, not aliases (`Get-ChildItem` not `gci`, `ForEach-Object` not `%`).
- Use single quotes for literal strings, double quotes only when variable expansion is needed.
- Prefer `[CmdletBinding()]` and `param()` blocks for all non-trivial functions.

## Error Handling
- Set `$ErrorActionPreference = 'Stop'` at script top to make errors terminating by default.
- Use `try/catch/finally` for operations that can fail (file I/O, COM, network).
- Use `-ErrorAction Stop` on individual cmdlets when script-wide Stop is too aggressive.
- Log errors with `Write-Error` or `Write-Warning`, not `Write-Host` (which bypasses pipeline).

## Patterns
- Prefer pipeline (`|`) for data transformations; use `ForEach-Object` for side effects.
- Use `[PSCustomObject]@{}` for structured output, not hashtables meant for consumption.
- Use `Test-Path` before file operations. Use `New-Item -Force` only when overwrite is intended.
- For COM automation (Outlook, Excel): always release COM objects with `[System.Runtime.Interopservices.Marshal]::ReleaseComObject()` and call `[GC]::Collect()`.

## Common Pitfalls
- Comparison operators are `-eq`, `-ne`, `-gt`, `-lt`, `-like`, `-match` — not `==`, `!=`, `>`, `<`.
- `$null` comparisons: put `$null` on the left side (`$null -eq $var`) to avoid array coercion.
- Single-element arrays: `@()` wrapper ensures array type (`$items = @(Get-ChildItem)`).
- Return values: PowerShell returns ALL uncaptured output, not just explicit `return` values. Capture or `$null =` unwanted output.

## Dependencies
- Prefer built-in modules over external ones. Check `Get-Module -ListAvailable` first.
- For Windows automation, leverage .NET classes directly via `[System.Net.WebClient]` etc.
- Use `#Requires -Version 5.1` or `#Requires -Modules` at script top to declare dependencies.
