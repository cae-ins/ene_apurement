/*                          *                      ENQUETE NATIONALE SUR L'EMPLOI  -  VOLET MENAGE                  *

							----------------------------------PHASE APUREMENT DES DONNEES T1   2026-------------------------------------------------------
							-------------------------DATE: MAI 2026  -------------------------------------------------------
							-----------------------------------------------------------------------------------------
																																						*/
clear all
********Paramétrages de départ*****************
set more off
*===============Racine du dépôt et trimestre=============*
* Aucun chemin propre au poste n'est écrit ici. La racine du dépôt est :
*   1. la variable d'environnement ENE_BASE_DIR si elle est définie ;
*   2. sinon le répertoire courant de Stata (racine du dépôt, ou son
*      sous-dossier program/ : on remonte alors d'un niveau).
* Les données ne sont pas dans le dépôt : elles sont téléchargées depuis MinIO
* dans <racine>/datain/staging et <racine>/document/codification par
*   python scripts/medallion/medallion.py download --quarter T1_2026
local root : env ENE_BASE_DIR
if `"`root'"' == "" {
	local root `"`c(pwd)'"'
	capture confirm file `"`root'/program/parentfile.do"'
	if _rc {
		capture confirm file `"`root'/../program/parentfile.do"'
		if !_rc {
			quietly cd ..
			local root `"`c(pwd)'"'
		}
	}
}
* Retire un séparateur final éventuel (...\ENE_APUREMENT\ -> ...\ENE_APUREMENT)
while inlist(substr(`"`root'"', -1, 1), "/", char(92)) {
	local root = substr(`"`root'"', 1, length(`"`root'"') - 1)
}
capture confirm file `"`root'/program/parentfile.do"'
if _rc {
	display as error "Racine du dépôt ENE_APUREMENT introuvable : `root'"
	display as error "Lancer Stata depuis la racine du dépôt (ou depuis program/), ou définir ENE_BASE_DIR."
	exit 601
}
global folderpath `"`root'"'
quietly cd "$folderpath"

* Trimestre traité : ENE_QUARTER (même variable que les scripts MinIO), sinon T1_2026.
global ene_quarter : env ENE_QUARTER
if "$ene_quarter" == "" global ene_quarter "T1_2026"
if !regexm("$ene_quarter", "^T[1-4]_[0-9][0-9][0-9][0-9]$") {
	display as error "ENE_QUARTER doit avoir la forme TX_YYYY (ex. T1_2026) : $ene_quarter"
	exit 198
}
display as text "Racine : $folderpath | trimestre : $ene_quarter"
****Création des dossiers de travail ( lancer uniquement la première fois)

/*
cap !mkdir "$folderpath/datain"
cap !mkdir "$folderpath/dataout"	
cap !mkdir "$folderpath/datatemp"		
cap !mkdir "$folderpath/document"	
cap !mkdir "$folderpath/docs"
cap !mkdir "$folderpath/program"
cap !mkdir "$folderpath/datain/compressed"
cap !mkdir "$folderpath/datain/decompressed"
cap !mkdir "$folderpath/datain/archive"
cap !mkdir "$folderpath/datain/standard"
cap !mkdir "$folderpath/datain/merged"
cap !mkdir "$folderpath/datain/standard/menage"
cap !mkdir "$folderpath/datain/standard/individu"
cap !mkdir "$folderpath/dataout/menage"
cap !mkdir "$folderpath/dataout/individu"
*/
local today=c(current_date)
local c_today= "`today'"
global date="`c_today'"

*global date=subinstr("`c_today'", " ", "",.)

global datain "$folderpath/datain"
global dataout "$folderpath/dataout"	
global datatemp "$folderpath/datatemp"		
global document "$folderpath/document"
global codification "$folderpath/document/codification"
global docs "$folderpath/docs"
global dofiles "$folderpath/program"
global datain_staging "$folderpath/datain/staging"
global datain_brute  "$folderpath/datain/brute"
* Export ménage Survey Solutions du trimestre : ENE_MENAGE_EXPORT si défini,
* sinon ENEM_<TX><YYYY>.dta (T1_2026 -> ENEM_T12026.dta).
global brute_menage_source_name : env ENE_MENAGE_EXPORT
if "$brute_menage_source_name" == "" {
	global brute_menage_source_name = "ENEM_" + subinstr("$ene_quarter", "_", "", .) + ".dta"
}
global brute_menage_source "$datain_brute/$brute_menage_source_name"
global brute_menage_work "$datain_brute/QX_EEC_VF.dta"
global datain_standard  "$folderpath/datain/standard"
global standard_menage  "$folderpath/dataout/standard/menage"
global standard_individu  "$folderpath/dataout/standard/individu"
global standard_annexe  "$folderpath/datain/standard/annexe"
global dataout_menage "$folderpath/dataout/menage"
global dataout_individu "$folderpath/dataout/individu"

*===============Configuration des Logs=============*
global logs "$folderpath/logs"
cap mkdir "$logs"

* Fermeture d'un éventuel log ouvert
cap log close

* Génération du nom de fichier log avec horodatage
local d = subinstr("`c(current_date)'", " ", "_", .)
local t = subinstr("`c(current_time)'", ":", "-", .)
global current_log "$logs/apurement_`d'_`t'.log"

log using "$current_log", replace text
display "Log de session démarré : $current_log"

*include "$dofiles/apurement.do"
*include "$dofiles/standard_db.do"
