*==============================================================================
* 00-nettoyage_individus_brute.do
*
* Supprime les individus non classables de la base membres.dta brute :
* 1. Sexe ou Âge manquant/invalide.
* 2. Absence de statut individuel (M4Confirm) pour les 15 ans et plus.
*==============================================================================

use "$datain_brute\membres.dta", clear

* ---- 1. Suppression si Âge ou Sexe manquant ----
* M5 : Sexe
* AgeAnnee : Âge
cap drop tag_invalid
gen tag_invalid = 0
replace tag_invalid = 1 if inlist(M5, ., .a)
replace tag_invalid = 1 if inlist(AgeAnnee, ., .a, 9898)

count if tag_invalid == 1
if r(N) > 0 {
    di as result "`r(N)' individus supprimés (Âge ou Sexe invalide)"
    drop if tag_invalid == 1
}
drop tag_invalid

* ---- 2. Suppression si M4Confirm manquant pour les 15 ans et plus ----
* (Individus qui auraient dû répondre au questionnaire individuel mais n'ont pas de statut)
count if missing(M4Confirm) & AgeAnnee >= 15 & !missing(AgeAnnee)
if r(N) > 0 {
    di as result "`r(N)' individus supprimés (M4Confirm manquant pour >= 15 ans)"
    drop if missing(M4Confirm) & AgeAnnee >= 15 & !missing(AgeAnnee)
}

save_brute_membres_safe
