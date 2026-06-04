/*                          *                      ENQUETE NATIONALE SUR L'EMPLOI  -  VOLET MENAGE                  *

							----------------------------------PHASE APUREMENT DES DONNEES T1   2026-------------------------------------------------------
							-------------------------DATE: MAI 2026  -------------------------------------------------------
							-----------------------------------------------------------------------------------------
																																						*/
clear all
********Paramétrages de départ*****************
set more off
*===============Création du répertoire de travail=============*
global folderpath = "C:\Users\f.migone\GOUVCI\ENEM-Suite - Documents\ENE-M-T1_2026\apurement"
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
global brute_menage_source "$datain_brute/ENEM_T12026.dta"
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
