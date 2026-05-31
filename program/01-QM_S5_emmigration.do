*=========================================================
* EMMIGRATION (EM)

* RESPONSABLE: DIABATE BEN ISMAEL
*========================================================

**********************LES ETAPES DE L'APUREMENT**********************************
**==============================================================================================================
*Etape1: Valeurs manquantes : Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: vérification des sauts : Est ce qu'il y a des individus qui ne devaient pas répondre mais qui ont répondu ? 
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
*Etape4: Cohérence : Les reponses données sont elles coherentes au regard des autres réponses ?
*Etape5 : Correction des erreurs identifiées 
*===============================================================================================================

*use "$datain_brute\qx_eec_vf.dta", clear
*use "$datain_brute\QM_S0_identification.dta", clear
*52-28-83-18

use "$datain_standard\QM_S5_emmigration.dta", clear
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(hha rgmen HH13 ME1 ME2A ME2B__0-ME2B__59)
drop if _merge!=3
cap drop _merge

*======================================================================================
** ME1 : membres de votre ménage qui se sont installés à l'étranger et qui y résident actuellement
*======================================================================================

*1. Valeurs manquantes
count if missing(ME1) & !missing(hha) & rgmen==1 
//RAS 


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(ME1) & (missing(hha) | rgmen !=1)
//RAS

*3. Vraisemblance : les valeurs renseignées sont elles permises ?
count if !inlist(ME1,1,2) & !missing(ME1)
//RAS

*=======================================================================================
*ME2A SI OUI, combien de membres se sont installés à l’étranger et y résident actuellement
*=======================================================================================

*1. Valeurs manquantes
count if missing(ME2A) & ME1==1 
//RAS 

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(ME2A) & ME1 !=1
//RAS

*3. les valeurs renseignées sont elles permises ?
count if ME2A > 10
//RAS

*=======================================================================================
*ME2B. Nom des personnes ayant quitté le ménage
*=======================================================================================

*1. Valeurs manquantes
gen nb_pas_manquant = 0
foreach var of varlist ME2B__0-ME2B__59 {
    replace nb_pas_manquant = nb_pas_manquant + ///
        (!missing(`var'))
}

gen valeure_manquante1 = (nb_pas_manquant == 0)
*egen nb_variables_renseignees = rownonmiss(ME2B__0-ME2B__59)
count if valeure_manquante1 ==1 & ME1==1 //Vérifie si aucun nom a été renseigné
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if ME1 !=1 & valeure_manquante1 ==0
//RAS

*======================================================================================
*ME3. Quel est le sexe
*======================================================================================

*1. Valeurs manquantes
count if  missing(ME3) & ME1==1
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME3) & ME1!=1
//RAS

**3. les valeurs renseignées sont elles permises ?
count if !inlist(ME3,1,2) & ME1==1
//RAS

*======================================================================================
*ME4. Quel âge avait-t-il à son départ?
*======================================================================================

*1. Valeurs manquantes
count if  missing(ME4) & ME1==1
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME4) & ME1!=1
//RAS

**3. les valeurs renseignées sont elles permises ?
count if ME4>99 & ME1==1 & ME4 !=998
//RAS

*======================================================================================
*ME5A1. Depuis quelle Année  a quitté ce ménage pour l’extérieur ?
*======================================================================================

*1. Valeurs manquantes
count if missing(ME5A1) & ME1==1
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME5A1) & ME1!=1
//RAS

**3. les valeurs renseignées sont elles permises ?
count if (ME5A1 < 1960 | ME5A1 > 2026) & ME1==1 & ME5A1 !=9998
//RAS


*======================================================================================
*ME5M1. Depuis quel mois a quitté ce ménage pour l’extérieur 
*======================================================================================

*1. Valeurs manquantes
count if missing(ME5M1)& !missing(ME5A1)& ME5A1!=9998
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME5M1)& (missing(ME5A1) | ME5A1==9998)
//RAS

**3. les valeurs renseignées sont elles permises ?
count if !inrange(ME5M1,1,12) & ME5M1!=9998 & !missing(ME5A1) & ME5A1!=9998
//RAS

*======================================================================================
*ME5A.Depuis combien d'Année a quitté ce ménage pour l’extérieur ?
*======================================================================================

*1. Valeurs manquantes
count if missing(ME5A) & ME5A1==9998
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME5A) & ME5A1!=9998
//RAS

**3. les valeurs renseignées sont elles permises ?
count if ME5A > 5 & ME5A1==9998
//RAS

*======================================================================================
*ME5M. %rostertitle% a quitté ce ménage depuis %ME5A% an(s) combien de mois pour l’extérieur
*======================================================================================

*1. Valeurs manquantes
count if missing(ME5M) & !missing(ME5A) & ME5A !=9998
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME5M) & (missing(ME5A) | ME5A ==9998)
//RAS

**3. les valeurs renseignées sont elles permises ?
count if !inrange(ME5M,1,12) & ME5M !=9998 & !missing(ME5A) & ME5A !=9998
//RAS

*======================================================================================
*ME6. Quel niveau d’enseignement %rostertitle% avait-il atteint à son départ ?
*======================================================================================

*1. Valeurs manquantes
count if missing(ME6) & ME4>3
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME6) & ME4<=3
//RAS

**3. les valeurs renseignées sont elles permises ?
count if !inrange(ME6,0,12) & !missing(ME6)
//RAS

*======================================================================================
*ME7. Dans quel pays vit actuellement
*======================================================================================

*1. Valeurs manquantes
count if missing(ME7) & ME1 ==1
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME7) & ME1 !=1
//RAS

**3. les valeurs renseignées sont elles permises ?
count if !inrange(ME7,1,216) & ME1 ==1
//RAS

*======================================================================================
*ME8. Pour quelle principale raison %est parti à l’extérieur 
*======================================================================================

*1. Valeurs manquantes
count if missing(ME8) & ME1 ==1
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME8) & ME1 !=1
//RAS

**3. les valeurs renseignées sont elles permises ?
count if !inrange(ME8,1,9) & ME1 ==1
//RAS

*4. Cohérence :
*Selon le BIT, l'age legal pour travailler c'est 15ans. Un enfant de moins de cet age ne peut donc emigrer pour des raisons d'affectation de travail
count if ME4<15 & ME8==4
//RAS

*======================================================================================
*ME8_Aut. Veuillez préciser 
*======================================================================================

*1. Valeurs manquantes
count if missing(ME8_Aut) & ME8==9
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME8_Aut) & ME8 !=9
//RAS

*======================================================================================
*ME9. Quelle était la catégorie socio-économique avant son départ pour l’extérieur
*======================================================================================

*1. Valeurs manquantes
count if missing(ME9) & ME1==1
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME9) & ME1!=1
//RAS

**3. les valeurs renseignées sont elles permises ?
count if !inrange(ME9,1,11) & ME9 != 9998 & ME1 ==1
//RAS 

*======================================================================================
*ME9_Aut : Autres à preciser
*======================================================================================

*1. Valeurs manquantes
count if missing(ME9_Aut) & inlist(ME9,10,11)
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ?
count if !missing(ME9_Aut) & !inlist(ME9,10,11)
//RAS


drop rgmen HH13 hha ME1 ME2A ME2B__0 ME2B__1 ME2B__2 ME2B__3 ME2B__4 ME2B__5 ME2B__6 ME2B__7 ME2B__8 ME2B__9 ME2B__10 ME2B__11 ME2B__12 ME2B__13 ME2B__14 ME2B__15 ME2B__16 ME2B__17 ME2B__18 ME2B__19 ME2B__20 ME2B__21 ME2B__22 ME2B__23 ME2B__24 ME2B__25 ME2B__26 ME2B__27 ME2B__28 ME2B__29 ME2B__30 ME2B__31 ME2B__32 ME2B__33 ME2B__34 ME2B__35 ME2B__36 ME2B__37 ME2B__38 ME2B__39 ME2B__40 ME2B__41 ME2B__42 ME2B__43 ME2B__44 ME2B__45 ME2B__46 ME2B__47 ME2B__48 ME2B__49 ME2B__50 ME2B__51 ME2B__52 ME2B__53 ME2B__54 ME2B__55 ME2B__56 ME2B__57 ME2B__58 ME2B__59

save "$standard_menage\QM_S5_emmigration.dta", replace




