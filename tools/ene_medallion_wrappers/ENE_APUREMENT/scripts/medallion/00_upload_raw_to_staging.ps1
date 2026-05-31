param(
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T1_2026" }),
    [string]$OrchestrationRoot = "C:\Users\f.migone\Desktop\ENE_MEDALLION_ORCHESTRATION",
    [string]$CodificationDir,
    [string[]]$OtherRawFile = @(),
    [switch]$DryRun,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ScriptPath = Join-Path $OrchestrationRoot "ene_medallion_io\00_upload_raw_to_staging.py"

$ArgsList = @($ScriptPath, "--quarter", $Quarter, "--base-dir", $ProjectRoot)
if ($CodificationDir) { $ArgsList += @("--codification-dir", $CodificationDir) }
foreach ($File in $OtherRawFile) { $ArgsList += @("--other-raw-file", $File) }
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
