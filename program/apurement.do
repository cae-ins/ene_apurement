************Lancement de tous les programmes d'apurement********************

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



//////////////////////////////////////////////////***SUPPRESSION DES ENTRETIENS INVALIDES***************************************//////////////////////

*** A executer en premier : supprime les entretiens vides et de trop de tous les fichiers bruts
include "$dofiles/Suppression_entretiens_T4-2025.do"

include "$dofiles/Suppression_entretiens_individuels_T4_2025.do"

///////////////////////////////////////////////***DOFILES DES BASES MENAGES***************************************//////////////////////

*** Dofile préalable

include "$dofiles/01-traitrement_autres.do" // Traitement des autres à préciser

include "$dofiles/Codification_T4_2025.do" // codification des activités et des emplois

include "$dofiles/Rename_label_var.do" //  labelisation des variables binaires découlant des variables à choix multiples

include "$dofiles/standard_db.do" // Stardisation de la base prenant en compte les autres à préciser 

***section 0:IDENTIFICATION ET RENSEIGNEMENTS DE CONTROLE

***section 1:COMPOSITION DU MÉNAGE ET CARACTÉRISTIQUES
include "$dofiles/01-QM_S1_composition_menage.do"

***section 2:EDUCATION ET FORMATION
include "$dofiles/01-QM_S2_education_formation.do"

***section 3:FORMATION PROFESSIONNELLE
include "$dofiles/01-QM_S3_formation_professionnelle.do"

***section 4: IMMIGRATION
include "$dofiles/01-QM_S4_immigration.do"

***section 5: EMMIGRATION
include "$dofiles/01-QM_S5_emmigration.do"

***section 6: DIFFICULTES FONCTIONNELLES
include "$dofiles/01-QM_S6_difficultes_fonctionnelles.do"

***section 7:CARACTERISTIQUES DU LOGEMENT ET POSSESSIONS DU MENAGE
include "$dofiles/01-QM_S7_logement.do"

///////////////////////////////////////////////******DOFILES DES BASES INDIVIDUS***************************************//////////////////////


***section 1:AUTRES FORMES DE TRAVAIL (FT)
include "$dofiles/01-INDIV_S1_autres_formes_travail.do"

***section 2:SITUATION D’EMPLOI (SE)
include "$dofiles/01-INDIV_S2_situation_emploi.do"

***section 3:EMPLOI PRINCIPAL (EP)
include "$dofiles/01-INDIV_S3_emploi_principal.do"

***section 4:COMPETENCES ET QUALIFICATIONS REQUISES POUR L’EMPLOI PRINCIPAL (CQ) : MODULE COMPLEMENTAIRE
include "$dofiles/01-INDIV_S4_competences_qualifications.do"

***section 5:PLURIACTIVITE (PL)
include "$dofiles/01-INDIV_S5_pluriactivite.do"

***section 6:EMPLOI SECONDAIRE (ES)
include "$dofiles/01-INDIV_S6_emploi_secondaire.do"

***section 7:TEMPS DE TRAVAIL DANS L’EMPLOI (WKT) ET ORGANISATION DU TRAVAIL
include "$dofiles/01-INDIV_S7_temps_travail.do"
***section 8:SITUATIONS D’EMPLOI INADÉQUATES (WKI)
include "$dofiles/01-INDIV_S8_emploi_inadequat.do"

***section 9:RECHERCHE D’UN AUTRE EMPLOI POUR LES PERSONNES EN EMPLOI (R)
include "$dofiles/01-INDIV_S9_recherche_emploi.do"
***section 10:RECHERCHE D’EMPLOI ET DISPONIBILITÉ (SRH)
include "$dofiles/01-INDIV_S10_recherche_emploi_disponibilite.do"
***section 11:CHÔMAGE (C)
include "$dofiles/01-INDIV_S11_chomage.do"

***section 12: EMPLOI ANTERIEUR
include "$dofiles/01-INDIV_S12_emploi_anterieur.do"

***section 13: REVENU HORS EMPLOI
include "$dofiles/01-INDIV_S13_revenu_hors_emploi.do"

***section 14: ACTIVITE DES PARENTS
include "$dofiles/01-INDIV_S14_activite_parents.do"

*include "$dofiles/01-INDIV_S15_disponibilite.do"