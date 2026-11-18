/*
Statut d'emploi (EN_EMP) reconstruit sur les reponses SE apurees.

EN_EMP n'est plus la variable calculee par Survey Solutions a la collecte : il est
recalcule avec la formule du questionnaire T3 2026 (variable EN_EMP) chaque fois que
les reponses SE changent. Source unique pour les sections : la sortie S2
($standard_individu\INDIV_S2_situation_emploi.dta), mise a jour par S3.

Commandes :
  calcul_en_emploi      recalcule EN_EMP sur les SE en memoire (manquant si M4Confirm < 15)
  nettoyer_sauts_se     vide les questions SE hors champ (filtres du questionnaire)
  reporter_se_dans_s2   reporte SE et EN_EMP en memoire dans la sortie S2
  charger_en_emploi     remplace EN_EMP en memoire par celui de la sortie S2
  vider_section         vide un bloc de questions pour les personnes hors champ
*/

capture program drop calcul_en_emploi
program define calcul_en_emploi
    foreach v in M4Confirm SE1 SE2 SE3 SE4 SE5 SE7 SE8 SE9 SE9A SE9B SE10 SE11 {
        capture confirm numeric variable `v'
        if _rc {
            display as error "calcul_en_emploi : variable `v' absente ou non numerique."
            exit 111
        }
    }
    capture confirm variable EN_EMP, exact // nom exact : sans ', exact' Stata supprimerait EN_EMP_collecte
    if !_rc drop EN_EMP
    gen byte EN_EMP = SE1 == 1 | inlist(SE2,1,2,3,4,5,6,7,8,9) | inlist(SE3,1,2) | SE4 == 1 ///
        | (SE5 == 1 & inlist(SE7,1,2)) ///
        | (SE8 == 1 & inlist(SE9,1,2,3,4)) ///
        | (SE8 == 1 & SE9 == 10 & SE9A == 1) ///
        | (SE8 == 1 & inlist(SE9,5,6,7,8,9,11,12,15,16,17) & SE10 == 1) ///
        | (SE8 == 1 & SE9 == 14 & SE9B == 1) ///
        | (SE8 == 1 & SE9 == 14 & SE9B == 2 & SE10 == 1) ///
        | (SE8 == 1 & SE9 == 10 & SE9A == 2 & SE10 == 1) ///
        | (SE8 == 1 & inlist(SE9,11,12,15,16,17) & inlist(SE10,2,9998) & SE11 == 1) ///
        | (SE8 == 1 & inlist(SE9,5,6,7,8,9) & inlist(SE10,2,9998) & SE11 == 1) ///
        | (SE8 == 1 & SE9 == 10 & SE9A == 2 & inlist(SE10,2,9998) & SE11 == 1) ///
        | (SE8 == 1 & SE9 == 14 & SE9B == 2 & inlist(SE10,2,9998) & SE11 == 1)
    replace EN_EMP = . if !(M4Confirm >= 15 & M4Confirm < .)
    label variable EN_EMP "En emploi (recalcule sur les reponses SE apurees)"
end

capture program drop vider_si
program define vider_si
    * Vide les variables citees (celles qui existent) sous la condition donnee.
    syntax anything [if]
    foreach v of local anything {
        capture confirm variable `v', exact
        if _rc continue
        capture confirm string variable `v'
        if !_rc replace `v' = "" `if'
        else replace `v' = . `if'
    }
end

capture program drop nettoyer_sauts_se
program define nettoyer_sauts_se
    * Filtres SE du questionnaire T3 2026, dans l'ordre des questions.
    * Ne modifie pas le statut : chaque terme de EN_EMP respecte deja ces filtres.
    vider_si SE2 if SE1 != 2
    vider_si SE3 if SE2 != 10
    vider_si SE4 if !inlist(SE3,3,4,5)
    vider_si SE5 if SE4 != 2
    vider_si SE6 SE7 if SE5 != 1
    vider_si SE8 if !(SE5 == 2 | inlist(SE7,3,4))
    vider_si SE9 if SE8 != 1
    vider_si SE9_Aut if SE9 != 17
    vider_si SE9A if SE9 != 10
    vider_si SE9B if SE9 != 14
    vider_si SE10 if !(inlist(SE9,5,6,7,8,9,11,12,15,16,17) | SE9A == 2 | (SE9 == 14 & SE9B == 2))
    vider_si SE11 if !inlist(SE10,2,9998)
end

capture program drop reporter_se_dans_s2
program define reporter_se_dans_s2
    * Remplace, pour les personnes en memoire, les SE et EN_EMP de la sortie S2
    * (valeurs manquantes comprises, contrairement a merge, update replace).
    local vars SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9 SE9A SE9B SE10 SE11 EN_EMP
    preserve
    keep interview__key membres__id `vars'
    foreach v of local vars {
        rename `v' `v'_maj
    }
    gen byte _maj = 1
    tempfile maj
    save `maj'
    use "$standard_individu\INDIV_S2_situation_emploi.dta", clear
    merge 1:1 interview__key membres__id using `maj', keep(master match) nogen
    foreach v of local vars {
        capture confirm variable `v', exact
        if _rc gen byte `v' = .
        replace `v' = `v'_maj if _maj == 1
        drop `v'_maj
    }
    drop _maj
    save "$standard_individu\INDIV_S2_situation_emploi.dta", replace
    restore
end

capture program drop charger_en_emploi
program define charger_en_emploi
    capture confirm variable EN_EMP, exact // nom exact : sans ', exact' Stata supprimerait EN_EMP_collecte
    if !_rc drop EN_EMP
    cap drop _merge
    merge m:1 interview__key membres__id using "$standard_individu\INDIV_S2_situation_emploi.dta", keepusing(EN_EMP) keep(master match) nogen
end

capture program drop vider_section
program define vider_section
    * Vide toutes les questions d'un bloc (hha_X-hhavf_X) sous la condition donnee.
    syntax varlist [if]
    foreach v of local varlist {
        capture confirm string variable `v'
        if !_rc quietly replace `v' = "" `if'
        else quietly replace `v' = . `if'
    }
    local premiere : word 1 of `varlist'
    local n : word count `varlist'
    local derniere : word `n' of `varlist'
    quietly count `if'
    display as text "vider_section : " r(N) " personne(s) hors champ, bloc `premiere'-`derniere' vide."
end
