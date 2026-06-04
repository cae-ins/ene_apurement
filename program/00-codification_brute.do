*================================================
* 00-codification_brute.do
*
* Intègre les codes CIAP dans membres.dta brute
* AVANT standard_db.do, pour que les sections
* d'apurement (S3, S5, S6) puissent y accéder.
*
* Prérequis : les fichiers Excel de codification
* doivent être présents dans $codification
* (= $document/codification, sous-dossier dédié
* pour ne pas les mélanger aux exports d'erreurs).
* Noms attendus :
*   codification_emploi_principal_T1_2026_cp.xlsx
*   codification_emploi_secondaire_T1_2026_cp.xlsx
*   codification_autre_emploi_T1_2026_cp.xlsx
*   Activite_secondaire_T126.xlsx
*   Pluriactivite_AllT126.xls
*   referentiel_citp_codes.xlsx
*================================================

foreach fichier in ///
    "codification_emploi_principal_T1_2026_cp.xlsx" ///
    "codification_emploi_secondaire_T1_2026_cp.xlsx" ///
    "codification_autre_emploi_T1_2026_cp.xlsx" ///
    "Activite_secondaire_T126.xlsx" ///
    "Pluriactivite_AllT126.xls" ///
	"Codif_activite_principales_T126.xlsx" ///
    "referentiel_citp_codes.xlsx" {
    capture confirm file "$codification\\`fichier'"
    if _rc {
        display as error "Fichier de codification absent: $codification\`fichier'"
        exit 601
    }
}

use "$datain_brute\membres.dta", clear

capture program drop report_codif_merge
program define report_codif_merge
    args libelle
    quietly count if _merge == 1
    display as text "`libelle': " r(N) " observation(s) de membres sans correspondance codification."
    quietly count if _merge == 2
    display as text "`libelle': " r(N) " cle(s) de codification hors membres ignoree(s)."
end

* ---- 1. Emploi principal : code_citp_emp_principal ----

preserve
    import excel "$codification\codification_emploi_principal_T1_2026_cp.xlsx", ///
        sheet("Sheet1") firstrow clear

    rename InterviewkeyidentifierinXX interview__key
    rename Idinmembres membres__id
    destring membres__id, replace force
    drop if missing(interview__key)
    keep interview__key membres__id code_citp_emp_principal
    isid interview__key membres__id

    save "$datatemp\codif_emploi_principal.dta", replace
restore

cap drop code_citp_emp_principal
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\codif_emploi_principal.dta", ///
    keepus(code_citp_emp_principal)
report_codif_merge "CITP emploi principal"
drop if _merge == 2
cap drop _merge

* ---- 2. Emploi secondaire : code_citp_emp_secondaire ----

preserve
    import excel "$codification\codification_emploi_secondaire_T1_2026_cp.xlsx", ///
        sheet("Sheet1") firstrow clear

    rename InterviewkeyidentifierinXX interview__key
    rename Idinmembres membres__id
    destring membres__id, replace force
    drop if missing(interview__key)
    keep interview__key membres__id code_citp_emp_secondaire
    isid interview__key membres__id

    save "$datatemp\codif_emploi_secondaire.dta", replace
restore

cap drop code_citp_emp_secondaire
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\codif_emploi_secondaire.dta", ///
    keepus(code_citp_emp_secondaire)
report_codif_merge "CITP emploi secondaire"
drop if _merge == 2
cap drop _merge

* ---- 3. Pluriactivité : code_citp_autre_emploi → reshape wide ----

preserve
    import excel "$codification\codification_autre_emploi_T1_2026_cp.xlsx", ///
        sheet("Sheet1") firstrow clear

    rename InterviewkeyidentifierinXX interview__key
    rename Idinmembres membres__id
    destring membres__id, replace force
    drop if missing(interview__key)
    keep interview__key membres__id Idinr_activite_s code_citp_autre_emploi
    isid interview__key membres__id Idinr_activite_s

    reshape wide code_citp_autre_emploi, i(interview__key membres__id) j(Idinr_activite_s)

    cap rename code_citp_autre_emploi1 pluriactivite1_codif
    cap rename code_citp_autre_emploi2 pluriactivite2_codif
    cap rename code_citp_autre_emploi3 pluriactivite3_codif
    cap rename code_citp_autre_emploi4 pluriactivite4_codif
    cap rename code_citp_autre_emploi5 pluriactivite5_codif

    save "$datatemp\codif_pluriactivite.dta", replace
restore

cap drop pluriactivite1_codif pluriactivite2_codif pluriactivite3_codif ///
         pluriactivite4_codif pluriactivite5_codif
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\codif_pluriactivite.dta"
report_codif_merge "CITP pluriactivite"
drop if _merge == 2
cap drop _merge

* ---- 4. CIAP emploi secondaire ----
preserve
    import excel "$codification\Activite_secondaire_T126.xlsx", sheet("Feuil1") firstrow clear
    cap rename Codeactivité CodeCIAPactivite_sec
    cap rename CodeactivitÃ© CodeCIAPactivite_sec
    keep interview__key membres__id CodeCIAPactivite_sec
    destring membres__id, replace force
    drop if missing(interview__key)
    isid interview__key membres__id
    save "$datatemp\codif_ciap_secondaire.dta", replace
restore
cap drop CodeCIAPactivite_sec
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\codif_ciap_secondaire.dta", keepus(CodeCIAPactivite_sec)
report_codif_merge "CIAP emploi secondaire"
drop if _merge == 2
cap drop _merge

* ---- 5. CIAP pluriactivite ----
preserve
    import excel "$codification\Pluriactivite_AllT126.xls", sheet("Sheet1") firstrow clear
    cap rename Code CodeCIAPactivite_pluri
    keep interview__key membres__id r_activite_s__id CodeCIAPactivite_pluri
    destring membres__id, replace force
    drop if missing(interview__key)
    isid interview__key membres__id r_activite_s__id
    reshape wide CodeCIAPactivite_pluri, i(interview__key membres__id) j(r_activite_s__id)
    save "$datatemp\codif_ciap_pluri.dta", replace
restore
cap drop CodeCIAPactivite_pluri*
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\codif_ciap_pluri.dta"
report_codif_merge "CIAP pluriactivite"
drop if _merge == 2
cap drop _merge

* ---- 6. CIAP emploi principal a activer a reception du fichier ----
preserve
    import excel "$codification\Codif_activite_principales_T126.xlsx", sheet("Feuil1") firstrow clear
    cap rename Codeactivité CodeCIAPactivité // Ajuster le nom de la colonne si besoin
    keep interview__key membres__id CodeCIAPactivité
    destring membres__id, replace force
    drop if missing(interview__key)
    isid interview__key membres__id
    save "$datatemp\codif_ciap_principal.dta", replace
restore
* ---- 3b. CIAP Emploi secondaire ----
preserve
    import excel "$codification\\Activite_secondaire_T126.xlsx", sheet("Feuil1") firstrow clear
    cap rename Codeactivité CodeCIAPactivite_sec
    cap rename CodeactivitÃ© CodeCIAPactivite_sec
    keep interview__key membres__id CodeCIAPactivite_sec
    destring membres__id, replace force
    drop if missing(interview__key)
    save "$datatemp\\codif_ciap_secondaire.dta", replace
restore
cap drop CodeCIAPactivite_sec
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\\codif_ciap_secondaire.dta", keepus(CodeCIAPactivite_sec)
drop if _merge == 2
cap drop _merge

* ---- 3c. CIAP Pluriactivité ----
preserve
    import excel "$codification\\Pluriactivite_AllT126.xls", sheet("Sheet1") firstrow clear
    cap rename Code CodeCIAPactivite_pluri
    keep interview__key membres__id r_activite_s__id CodeCIAPactivite_pluri
    destring membres__id, replace force
    drop if missing(interview__key)
    reshape wide CodeCIAPactivite_pluri, i(interview__key membres__id) j(r_activite_s__id)
    save "$datatemp\\codif_ciap_pluri.dta", replace
restore
cap drop CodeCIAPactivite_pluri*
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\\codif_ciap_pluri.dta"
drop if _merge == 2
cap drop _merge

cap drop CodeCIAPactivité
cap drop _merge
merge 1:1 interview__key membres__id using "$datatemp\codif_ciap_principal.dta", keepus(CodeCIAPactivité)
report_codif_merge "CIAP emploi principal"
drop if _merge == 2
cap drop _merge


* ---- 7. Creation des variables branches a partir de CodeCIAPactivité ----
cap drop Code_1er
gen Code_1er=substr(CodeCIAPactivité,1,1)

cap drop branche2
gen branche2=99 if Code_1er != ""
replace branche2=1  if Code_1er=="A"
replace branche2=2  if inlist(Code_1er, "B", "C", "D", "E", "F")
replace branche2=3  if inlist(Code_1er, "G", "H", "I", "J", "K", "L", "M", "N") | inlist(Code_1er, "O", "P", "Q", "R", "S", "T")

lab var branche2 "Branche d'activité 2"
cap label drop branche
label define branche 1 "Secteur primaire" 2 "Secteur secondaire" 3 "Secteur tertiaire" 99 "Non-classés"
label values branche2 branche

cap drop branche1
gen branche1=4 if Code_1er != ""
replace branche1=1  if Code_1er=="A"
replace branche1=2  if inlist(Code_1er, "B", "C")
replace branche1=3  if Code_1er=="G"

lab var branche1 "Branche d'activité 1"
cap label drop branche1
label define branche1 1 "Agriculture" 2 "Industrie" 3 "Commerce" 4 "Autre service"
label values branche1 branche1


* ---- 8. Labels de la codification ----
cap label drop codification
preserve
    import excel "$codification\referentiel_citp_codes.xlsx", firstrow clear
    local n_obs = _N
    forvalues i = 1/`n_obs' {
        local val = code[`i']
        local lab = libelle[`i']
        label define codification `val' "`lab'", add
    }
restore

* ---- 9. Finalisation et sauvegarde ----
cap destring code_citp_emp_principal, replace force
cap destring code_citp_emp_secondaire, replace force
forvalues i=1/5 {
    cap destring pluriactivite`i'_codif, replace force
}

label values code_citp_emp_principal codification 
label values code_citp_emp_secondaire codification
label values pluriactivite*_codif codification

label var code_citp_emp_principal "Emploi principal codifié"
label var code_citp_emp_secondaire "Emploi secondaire codifié"
label var CodeCIAPactivite_sec "Activite secondaire codifiee (CIAP)"
forvalues i=1/5 {
    cap label var pluriactivite`i'_codif "Pluriactivité `i' codifiée"
    cap label var CodeCIAPactivite_pluri`i' "Activite `i' de pluriactivite codifiee (CIAP)"
}

save_brute_membres_safe
