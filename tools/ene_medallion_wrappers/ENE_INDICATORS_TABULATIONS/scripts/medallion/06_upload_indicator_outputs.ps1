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

$EnvFiles = @(
    (Join-Path (Get-Location).Path ".env"),
    (Join-Path $ProjectRoot ".env")
) | Select-Object -Unique
foreach ($EnvFile in $EnvFiles) {
    if (Test-Path -LiteralPath $EnvFile) {
        Get-Content -LiteralPath $EnvFile | ForEach-Object {
            $Line = $_.Trim()
            if (-not $Line -or $Line.StartsWith("#") -or -not $Line.Contains("=")) { return }
            $Name, $Value = $Line.Split("=", 2)
            $Name = $Name.Trim()
            $Value = $Value.Trim()
            if ($Name -and -not [Environment]::GetEnvironmentVariable($Name, "Process")) {
                [Environment]::SetEnvironmentVariable($Name, $Value, "Process")
            }
        }
    }
}
$MinioEndpoint = [Environment]::GetEnvironmentVariable("MINIO_ENDPOINT", "Process")
if ($MinioEndpoint) {
    try {
        $EndpointHost = ([Uri]$MinioEndpoint).Host
        if ($EndpointHost) {
            $NoProxy = [Environment]::GetEnvironmentVariable("NO_PROXY", "Process")
            $Hosts = @($NoProxy -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            if ($Hosts -notcontains $EndpointHost) {
                $Hosts += $EndpointHost
                $NoProxyValue = ($Hosts -join ",")
                [Environment]::SetEnvironmentVariable("NO_PROXY", $NoProxyValue, "Process")
                [Environment]::SetEnvironmentVariable("no_proxy", $NoProxyValue, "Process")
            }
        }
    } catch {}
}

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
