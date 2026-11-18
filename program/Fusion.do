
/// FUSION DES BASES \\\

local fichiers_menage ///
	QM_S1_composition_menage ///
	QM_S2_education_formation ///
	QM_S3_formation_professionnelle ///
	QM_S4_immigration ///
	QM_S6_difficultes_fonctionnelles ///
	QM_S7_logement

local fichiers_individu ///
	INDIV_S1_autres_formes_travail ///
	INDIV_S2_situation_emploi ///
	INDIV_S3_emploi_principal ///
	INDIV_S4_competences_qualifications ///
	INDIV_S5_pluriactivite ///
	INDIV_S6_emploi_secondaire ///
	INDIV_S7_temps_travail ///
	INDIV_S8_emploi_inadequat ///
	INDIV_S9_recherche_emploi ///
	INDIV_S10_recherche_emploi_disponibilite ///
	INDIV_S11_chomage ///
	INDIV_S12_emploi_anterieur ///
	INDIV_S13_revenu_hors_emploi ///
	INDIV_S14_activite_parents

local fichiers_absents 0
foreach d of local fichiers_menage {
	capture confirm file "$standard_menage/`d'.dta"
	if _rc {
		display as error "Sortie menage absente avant fusion: $standard_menage/`d'.dta"
		local fichiers_absents = `fichiers_absents' + 1
	}
}
foreach d of local fichiers_individu {
	capture confirm file "$standard_individu/`d'.dta"
	if _rc {
		display as error "Sortie individu absente avant fusion: $standard_individu/`d'.dta"
		local fichiers_absents = `fichiers_absents' + 1
	}
}
if `fichiers_absents' > 0 {
	display as error "`fichiers_absents' sortie(s) requise(s) absente(s). Fusion interrompue."
	exit 601
}

*-------------* BASE MENAGE *--------------*
// QM_S0_identification : section contrôlée (01-QM_S0_identification.do) mais sans correction
use "$datain_standard\QM_S0_identification.dta", clear
cap drop _merge
merge 1:1 interview__key using "$standard_menage\QM_S7_logement.dta"

save "$dataout_menage\qx_eec_vf.dta", replace
*--------------------------------------------*

*-------------* BASE INDIVIDU *--------------*
use "$standard_menage\QM_S1_composition_menage.dta", clear

global menage QM_S2_education_formation QM_S3_formation_professionnelle QM_S4_immigration QM_S6_difficultes_fonctionnelles



foreach d of global menage {
	merge 1:1 interview__key membres__id using "$standard_menage/`d'.dta", keep(master match) nogen
}

// INDIV_S15_disponibilite retiré : section non apurée (T1 et T3 2026)
global individu INDIV_S1_autres_formes_travail INDIV_S2_situation_emploi INDIV_S3_emploi_principal INDIV_S4_competences_qualifications INDIV_S5_pluriactivite INDIV_S6_emploi_secondaire INDIV_S7_temps_travail INDIV_S8_emploi_inadequat INDIV_S9_recherche_emploi INDIV_S10_recherche_emploi_disponibilite INDIV_S11_chomage INDIV_S12_emploi_anterieur INDIV_S13_revenu_hors_emploi INDIV_S14_activite_parents


foreach d of global individu {
	merge 1:1 interview__key membres__id using "$standard_individu/`d'.dta", keep(master match) nogen
}

* Contrôle : EN_EMP final = formule du questionnaire sur les réponses SE finales (00-en_emploi.do)
include "$dofiles/00-en_emploi.do"
rename EN_EMP EN_EMP_sections
calcul_en_emploi
quietly count if EN_EMP != EN_EMP_sections
if r(N) > 0 {
	display as error r(N) " personne(s) dont EN_EMP ne correspond pas aux réponses SE finales. Fusion interrompue."
	exit 459
}
drop EN_EMP_sections



/*Suppression des personnes pour lesquels l'age et le sexe sont des valeurs manquantes
cap drop tag*
gen tag1 = 1 if M5==. | M5==.a
gen tag2 =1 if AgeAnnee ==. | AgeAnnee ==.a | AgeAnnee == 9898
gen tag = 0 if tag1 ==1 | tag2 == 1
replace tag = 1 if tag ==.
drop if tag==0*/

save "$dataout_individu\membres.dta", replace
*-----------------------------------------------*

*include "$dofiles\codif_emploi_principale.do"
*include "$dofiles\codif_emploi_secondaire.do"

*include "$dofiles\Codification_T1_2026.do"
 
