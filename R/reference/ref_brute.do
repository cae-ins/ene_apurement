* =============================================================================
* ref_brute.do : produit les références intermédiaires Stata utilisées par le
* banc de parité R (états des bases brutes après chaque étape 00/01).
*
* À lancer DEPUIS un dossier de travail jetable (jamais le dépôt d'origine),
* qui contient datain/brute/ = copie de datain/staging/ :
*     cd <dossier_ref> ; StataMP-64.exe /e do <chemin>/ref_brute.do
* Variables d'environnement :
*     ENE_DATA_DIR  racine du dépôt Stata d'origine (lecture seule : program/,
*                   document/codification/)
*     ENE_QUARTER   trimestre (ex. T1_2026)
* Sorties : <dossier_ref>/snap/<etape>/{membres,QX_EEC_VF,r_activite_s,emigration}.dta
* (à désigner ensuite par ENE_REF_DIR=<dossier_ref>/snap).
* =============================================================================
clear all
set more off
global orig : env ENE_DATA_DIR
global ene_quarter : env ENE_QUARTER
if "$orig" == "" | "$ene_quarter" == "" {
    display as error "Définir ENE_DATA_DIR et ENE_QUARTER."
    exit 198
}
global folderpath "`c(pwd)'"
global datain "$folderpath/datain"
global dataout "$folderpath/dataout"
global datatemp "$folderpath/datatemp"
global document "$folderpath/document"
global codification "$orig/document/codification"
global dofiles "$orig/program"
global datain_brute "$folderpath/datain/brute"
global datain_standard "$folderpath/datain/standard"
global brute_menage_source_name = "ENEM_" + subinstr("$ene_quarter", "_", "", .) + ".dta"
global brute_menage_source "$datain_brute/$brute_menage_source_name"
global brute_menage_work "$datain_brute/QX_EEC_VF.dta"
cap mkdir "$datatemp"
cap mkdir "$document"
cap mkdir "$datain_standard"
cap mkdir "$dataout"
cap mkdir "$folderpath/snap"
capture program drop snap
program define snap
    args etape
    cap mkdir "$folderpath/snap/`etape'"
    foreach f in membres.dta QX_EEC_VF.dta r_activite_s.dta emigration.dta {
        cap copy "$datain_brute/`f'" "$folderpath/snap/`etape'/`f'", replace
    }
end
log using "$folderpath/trace_ref_brute.log", replace text
include "$dofiles/00-protections_sauvegarde_brute.do"
include "$dofiles/00-suppression_doublons.do"
snap 01_doublons
include "$dofiles/00-suppression_non_residents.do"
snap 02_non_residents
include "$dofiles/00-nettoyage_individus_brute.do"
snap 03_nettoyage
include "$dofiles/01-traitrement_autres.do"
snap 04_autres
include "$dofiles/Rename_label_var.do"
include "$dofiles/00-codification_brute.do"
snap 05_codification
log close
