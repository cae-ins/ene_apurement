/*==============================================================================
  copy_to_cleaned.do
  Publie les bases fusionnees (Fusion_ENE.do) vers MinIO silver.
  ENE_SURVEY_WEIGHTS les recupere ensuite avec son wrapper medallion.
  A lancer apres Fusion_ENE.do.
==============================================================================*/

*-- Verification que les fichiers sources existent --*
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

*-- Publication vers MinIO --*
local uploader "$folderpath\scripts\medallion\02_upload_apurement_outputs.ps1"
cap confirm file "`uploader'"
if _rc {
    di as error "Wrapper MinIO introuvable : `uploader'"
    exit 601
}

di as text _newline ">>> Publication des sorties d'apurement vers MinIO silver..."
shell powershell -NoProfile -ExecutionPolicy Bypass -File "`uploader'"
if _rc {
    di as error "Echec de la publication MinIO."
    exit _rc
}

di as result _newline "=== Publication MinIO terminee ==="
di as text "Dans ENE_SURVEY_WEIGHTS, lancer scripts\medallion\03_download_weights_inputs.ps1."
