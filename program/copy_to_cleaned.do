/*==============================================================================
  copy_to_cleaned.do
  Copie les bases fusionnées (Fusion_ENE.do) vers le projet ENE_SURVEY_WEIGHTS
  Trimestre : T4 2025
  À lancer APRÈS Fusion_ENE.do
==============================================================================*/

*-- Vérification que les fichiers sources existent --*
local src_menage   "$dataout_menage\menage.dta"
local src_individu "$dataout_individu\membres.dta"

foreach f in "`src_menage'" "`src_individu'" {
    cap confirm file "`f'"
    if _rc {
        di as error "Fichier source introuvable : `f'"
        di as error "Lancez Fusion_ENE.do avant ce script."
        exit 601
    }
}

*-- Chemins de destination --*
local dest_root "C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS\data\02_cleaned"
local dest_menage   "`dest_root'\Menage\T4_2025\menage_T4_2025.dta"
local dest_individu "`dest_root'\Individu\T4_2025\individu_T4_2025.dta"

*-- Copie via PowerShell (robuste avec OneDrive) --*
di as text _newline ">>> Copie menage..."
shell powershell -Command "Copy-Item -Path '`src_menage'' -Destination '`dest_menage'' -Force"
di as result "    OK : `dest_menage'"

di as text _newline ">>> Copie individu..."
shell powershell -Command "Copy-Item -Path '`src_individu'' -Destination '`dest_individu'' -Force"
di as result "    OK : `dest_individu'"

di as result _newline "=== Copie T4_2025 terminée ==="
