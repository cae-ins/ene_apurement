*==============================================================================
* 00-suppression_non_residents.do
*
* Supprime les individus declares non residents avant la standardisation.
* Synchronise ensuite les bases : aucun individu sans menage et aucun menage
* sans individu restant. Les menages mixtes sont conserves.
*==============================================================================

use "$datain_brute\membres.dta", clear

count if Statut_Res == 0
if r(N) > 0 {
    di as result "`r(N)' individus non residents supprimes (Statut_Res == 0)"
    drop if Statut_Res == 0
}

save_brute_membres_safe

use "$brute_menage_work", clear

keep interview__key
isid interview__key
save "$datatemp\cles_menages_travail.dta", replace

use "$datain_brute\membres.dta", clear

cap drop _merge
merge m:1 interview__key using "$datatemp\cles_menages_travail.dta", keep(1 3)

count if _merge == 1
if r(N) > 0 {
    di as result "`r(N)' individus sans menage supprimes"
    drop if _merge == 1
}

drop _merge
preserve
    keep interview__key
    duplicates drop
    isid interview__key
    save "$datatemp\cles_menages_avec_individus.dta", replace
restore
save_brute_membres_safe

use "$brute_menage_work", clear

cap drop _merge
merge 1:1 interview__key using "$datatemp\cles_menages_avec_individus.dta", keep(1 3)

count if _merge == 1
if r(N) > 0 {
    di as result "`r(N)' menages sans individu supprimes de la copie menage"
    drop if _merge == 1
}

drop _merge
save_brute_menage_work_safe
