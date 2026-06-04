///////////////////////////////////////////////***standardiser les bases du questioinnaire menage***************************************//////////////////////
*Initialisation*
/* use "$datain_brute\membres.dta", clear

 Suppression des personnes pour lesquels l'age et le sexe sont des valeurs manquantes
cap drop tag*
gen tag1 = 1 if M5==. | M5==.a
gen tag2 =1 if AgeAnnee ==. | AgeAnnee ==.a | AgeAnnee == 9898
gen tag = 0 if tag1 ==1 | tag2 == 1
replace tag = 1 if tag ==.
drop if tag==0


save "$datain_brute\membres.dta", replace */



*******

local variables_nomenclature CodeCIAPactivité CodeCIAPactivite_sec ///
	CodeCIAPactivite_pluri* code_citp_emp_principal code_citp_emp_secondaire ///
	pluriactivite1_codif pluriactivite2_codif pluriactivite3_codif ///
	 branche1 branche2

use "$brute_menage_work",clear
*merge 1:m interview__key using "$datain_brute\membres.dta",keepusing(interview__key)
*drop if _merge==1
*duplicates drop interview__key, force
*save "$datain_brute/QX_EEC_VF.dta", replace

***section 0:IDENTIFICATION ET RENSEIGNEMENTS DE CONTROLE
preserve
	drop hha_LOG - hhavf_LOG
	save "$datain_standard/QM_S0_identification.dta", replace
restore

***section 7:CARACTERISTIQUES DU LOGEMENT ET POSSESSIONS DU MENAGE
preserve
	drop HH2A - hhavf_EM
	keep interview__key - hhavf_LOG
	save "$datain_standard/QM_S7_logement.dta", replace
restore

use "$datain_brute\membres.dta", clear

***section 1:COMPOSITION DU MÉNAGE ET CARACTÉRISTIQUES
preserve
	keep interview__key - hhavf_COMP `variables_nomenclature'
	save "$datain_standard/QM_S1_composition_menage.dta",replace
restore

***section 2:EDUCATION ET FORMATION
preserve
	drop hha_COMP - M24B_Aut
	keep interview__key -hhavf_ED `variables_nomenclature'
	save "$datain_standard/QM_S2_education_formation.dta",replace
restore

***section 3:FORMATION PROFESSIONNELLE
preserve
	drop hha_COMP - EF18_aut
	keep interview__key -hhavf_FP `variables_nomenclature'
	save "$datain_standard/QM_S3_formation_professionnelle.dta",replace
restore

***section 4: IMMIGRATION
preserve
	drop hha_COMP - FP7
	keep interview__key -hhavf_IM `variables_nomenclature'
	save "$datain_standard/QM_S4_immigration.dta",replace
restore

***section 6: DIFFICULTES FONCTIONNELLES
preserve
	drop hha_COMP - IM8_Aut
	keep interview__key -hhavf_HAND `variables_nomenclature'
	save "$datain_standard/QM_S6_difficultes_fonctionnelles.dta",replace
restore

use "$datain_brute\emigration.dta",clear 
***section 5: EMMIGRATION
	save "$datain_standard/QM_S5_emmigration.dta",replace
	

///////////////////////////////////////////////***standardiser les bases individus***************************************//////////////////////

use "$datain_brute\membres.dta", clear

***section 1:AUTRES FORMES DE TRAVAIL (FT)
preserve
	drop hha_COMP - Q1_16b__4
	keep interview__key - hhavf_FT `variables_nomenclature'
	save "$datain_standard/INDIV_S1_autres_formes_travail.dta",replace
restore

***section 2:SITUATION D’EMPLOI (SE)
preserve
	drop hha_COMP - hhavf_FT
	keep interview__key - hhavf_SE `variables_nomenclature'
	save "$datain_standard/INDIV_S2_situation_emploi.dta",replace
restore

***section 3:EMPLOI PRINCIPAL (EP)
preserve
	drop hha_COMP -hhavf_SE
	keep interview__key - hhavf_EMP `variables_nomenclature'
	save "$datain_standard/INDIV_S3_emploi_principal.dta",replace
restore

***section 4:COMPETENCES ET QUALIFICATIONS REQUISES POUR L’EMPLOI PRINCIPAL (CQ) : MODULE COMPLEMENTAIRE
preserve
	drop hha_COMP - hhavf_EMP
	keep interview__key - hhavf_CQ `variables_nomenclature'
	save "$datain_standard/INDIV_S4_competences_qualifications.dta",replace
restore

***section 5:PLURIACTIVITE (PL)
preserve
	drop hha_COMP - hhavf_CQ
	keep interview__key - hhavf_PL `variables_nomenclature'
	save "$datain_standard/INDIV_S5_pluriactivite.dta",replace
restore

***section 6:EMPLOI SECONDAIRE (ES)
preserve
	drop hha_COMP - hhavf_PL
	keep interview__key - hhavf_ES `variables_nomenclature'
	save "$datain_standard/INDIV_S6_emploi_secondaire.dta",replace
restore

***section 7:TEMPS DE TRAVAIL DANS L’EMPLOI (WKT) ET ORGANISATION DU TRAVAIL
preserve
	drop hha_COMP - hhavf_ES
	keep interview__key - hhavf_WKT `variables_nomenclature'
	save "$datain_standard/INDIV_S7_temps_travail.dta",replace
restore

***section 8:SITUATIONS D’EMPLOI INADÉQUATES (WKI)
preserve
	drop hha_COMP - hhavf_WKT
	keep interview__key - hhavf_WKI `variables_nomenclature'
	save "$datain_standard/INDIV_S8_emploi_inadequat.dta",replace
restore


***section 9:RECHERCHE D’UN AUTRE EMPLOI POUR LES PERSONNES EN EMPLOI (R)
preserve
	drop hha_COMP - hhavf_WKI
	keep interview__key - hhavf_R `variables_nomenclature'
	save "$datain_standard/INDIV_S9_recherche_emploi.dta",replace
restore

***section 10:RECHERCHE D’EMPLOI ET DISPONIBILITÉ (SRH)
preserve
	drop hha_COMP - hhavf_R
	keep interview__key - hhavf_SRH `variables_nomenclature'
	save "$datain_standard/INDIV_S10_recherche_emploi_disponibilite.dta",replace
restore

***section 11:CHÔMAGE (C)
preserve
	drop hha_COMP - hhavf_SRH
	keep interview__key - hhavf_C `variables_nomenclature'
	save "$datain_standard/INDIV_S11_chomage.dta",replace
restore

***section 12:EMPLOI ANTERIEUR (P)
preserve
	drop hha_COMP - hhavf_C
	keep interview__key - hhavf_P `variables_nomenclature'
	save "$datain_standard/INDIV_S12_emploi_anterieur.dta",replace
restore

***section 13:REVENUS HORS EMPLOI (RHE)
preserve
	drop hha_COMP - hhavf_P
	keep interview__key - hhavf_RHE `variables_nomenclature'
	save "$datain_standard/INDIV_S13_revenu_hors_emploi.dta",replace
restore


***section 14:ACTIVITE DES PARENTS (TP)
preserve
	drop hha_COMP - hhavf_RHE
	keep interview__key - hhavf_TP `variables_nomenclature'
	save "$datain_standard/INDIV_S14_activite_parents.dta",replace
restore

***section 15:DISPONIBILITE DES INDIVIDUS (DI)
preserve
	drop hha_COMP - hhavf_TP
	keep interview__key - st_ind `variables_nomenclature'
	save "$datain_standard/INDIV_S15_disponibilite.dta",replace
restore



