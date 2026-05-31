param(
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T1_2026" }),
    [string]$OrchestrationRoot = "C:\Users\f.migone\Desktop\ENE_MEDALLION_ORCHESTRATION",
    [switch]$DryRun,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ScriptPath = Join-Path $OrchestrationRoot "ene_medallion_io\01_download_apurement_inputs.py"

$ArgsList = @($ScriptPath, "--quarter", $Quarter, "--base-dir", $ProjectRoot)
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
