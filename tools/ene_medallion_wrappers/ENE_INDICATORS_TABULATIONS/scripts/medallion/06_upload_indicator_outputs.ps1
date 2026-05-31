param(
    [string]$Period = $(if ($env:ENE_PERIOD) { $env:ENE_PERIOD } else { "quarterly" }),
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T4_2025" }),
    [string]$Year = $(if ($env:ENE_YEAR) { $env:ENE_YEAR } else { "2025" }),
    [string]$ResultsDir,
    [string]$OrchestrationRoot = "C:\Users\f.migone\Desktop\ENE_MEDALLION_ORCHESTRATION",
    [switch]$DryRun,
    [switch]$Overwrite,
    [switch]$IncludeArchives,
    [switch]$IncludeTemplates,
    [switch]$IncludeGraphs,
    [switch]$IncludeDrafts
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ScriptPath = Join-Path $OrchestrationRoot "ene_medallion_io\06_upload_indicator_outputs.py"

$ArgsList = @($ScriptPath, "--period", $Period, "--quarter", $Quarter, "--year", $Year, "--base-dir", $ProjectRoot)
if ($ResultsDir) { $ArgsList += @("--results-dir", $ResultsDir) }
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }
if ($IncludeArchives) { $ArgsList += "--include-archives" }
if ($IncludeTemplates) { $ArgsList += "--include-templates" }
if ($IncludeGraphs) { $ArgsList += "--include-graphs" }
if ($IncludeDrafts) { $ArgsList += "--include-drafts" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
