

use "$standard_menage\QM_S0_identification.dta", clear
cap drop _merge
merge 1:1  interview__key using "$standard_menage\QM_S7_logement.dta"

cap drop _merge

save "$dataout_menage\menage.dta", replace

global menage QM_S2_education_formation QM_S3_formation_professionnelle QM_S4_immigration QM_S6_difficultes_fonctionnelles

use "$standard_menage\QM_S1_composition_menage.dta", clear

foreach d of global menage {
	merge 1:1 interview__key membres__id using "$standard_menage/`d'.dta", nogen
	cap drop _merge
}

global individu INDIV_S1_autres_formes_travail INDIV_S2_situation_emploi INDIV_S3_emploi_principal INDIV_S4_competences_qualifications INDIV_S5_pluriactivite INDIV_S6_emploi_secondaire INDIV_S7_temps_travail INDIV_S8_emploi_inadequat INDIV_S9_recherche_emploi INDIV_S10_recherche_emploi_disponibilite INDIV_S11_chomage INDIV_S12_emploi_anterieur INDIV_S13_revenu_hors_emploi INDIV_S14_activite_parents


foreach d of global individu {
	merge 1:1 interview__key membres__id using "$standard_individu/`d'.dta", nogen
	cap drop _merge
}
	



/*Suppression des personnes pour lesquels l'age et le sexe sont des valeurs manquantes
cap drop tag*
gen tag1 = 1 if M5==. | M5==.a
gen tag2 =1 if AgeAnnee ==. | AgeAnnee ==.a | AgeAnnee == 9898
gen tag = 0 if tag1 ==1 | tag2 == 1
replace tag = 1 if tag ==.
drop if tag==0*/

save "$dataout_individu\membres.dta", replace

*include "$dofiles\codif_emploi_principale.do"
*include "$dofiles\codif_emploi_secondaire.do"

*-- Publication MinIO pour ENE_SURVEY_WEIGHTS --*
include "$dofiles\copy_to_cleaned.do"






