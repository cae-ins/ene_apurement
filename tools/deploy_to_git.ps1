# ==============================================================================
# Script de déploiement vers le dépôt Git local
# ==============================================================================
# Ce script copie uniquement les fichiers de code et de configuration 
# vers le dossier de bureau destiné à être poussé sur GitHub.
# ==============================================================================

$Source = Get-Location
$Destination = "C:\Users\f.migone\Desktop\ENE_APUREMENT"

# Vérification de l'existence du dossier de destination
if (-not (Test-Path $Destination)) {
    Write-Host "ERREUR : Le dossier de destination $Destination n'existe pas." -ForegroundColor Red
    Write-Host "Veuillez vérifier le chemin ou créer le dossier avant de continuer."
    exit
}

Write-Host "--- Préparation du déploiement vers Git ---" -ForegroundColor Cyan
Write-Host "Source      : $Source"
Write-Host "Destination : $Destination"

# Liste des dossiers et extensions à ignorer (données et fichiers temporaires)
$ExcludeDirs = @("datain", "dataout", "datatemp", ".git", "__pycache__", "archive")
$ExcludeFiles = @("*.dta", "*.bak", "*.log", "*.smcl", "Thumbs.db", ".DS_Store")

# Commande Robocopy pour une copie propre et efficace
# /MIR : Miroir (attention, supprime dans destination ce qui n'est pas dans source)
# /XF  : Exclure fichiers
# /XD  : Exclure dossiers
# /R:0 /W:0 : Ne pas rééssayer en cas de fichier verrouillé
$params = @(
    $Source,
    $Destination,
    "/MIR",
    "/R:0",
    "/W:0",
    "/XD"
) + $ExcludeDirs + @("/XF") + $ExcludeFiles

Write-Host "`nExécution de la synchronisation..." -ForegroundColor Yellow
& robocopy.exe @params

if ($LASTEXITCODE -lt 8) {
    Write-Host "`nSUCCÈS : La synchronisation est terminée." -ForegroundColor Green
    Write-Host "Vous pouvez maintenant ouvrir un terminal dans '$Destination' pour faire votre commit Git."
} else {
    Write-Host "`nAVERTISSEMENT : Robocopy a retourné un code d'erreur ($LASTEXITCODE)." -ForegroundColor Yellow
}
