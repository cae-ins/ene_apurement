param(
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T4_2025" }),
    [string]$OrchestrationRoot = "C:\Users\f.migone\Desktop\ENE_MEDALLION_ORCHESTRATION",
    [string]$QualityDir,
    [switch]$SkipQualityReports,
    [switch]$DryRun,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ScriptPath = Join-Path $OrchestrationRoot "ene_medallion_io\02_upload_apurement_outputs.py"

$ArgsList = @($ScriptPath, "--quarter", $Quarter, "--base-dir", $ProjectRoot)
if ($QualityDir) { $ArgsList += @("--quality-dir", $QualityDir) }
if ($SkipQualityReports) { $ArgsList += "--skip-quality-reports" }
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
