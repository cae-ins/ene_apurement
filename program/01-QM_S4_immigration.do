*=========================================================
* IMMIGRATION (IM)

* RESPONSABLE: DIABATE BEN ISMAEL
*========================================================

**********************LES ETAPES DE L'APUREMENT**********************************
**======================================================================================
*Etape1: Valeurs manquantes : Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: vérification des sauts : Est ce qu'il y a des individus qui ne devaient pas répondre mais qui ont répondu ? 
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
*Etape4: Cohérence : Les reponses données sont elles coherentes au regard des autres réponses ? 
*=======================================================================================

use "$datain_standard\QM_S4_immigration.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH12 HH13 HH3)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\QM_S1_composition_menage.dta", keepusing(AgeAnnee Statut_Res M6_A M1 M2)
drop if _merge!=3
cap drop _merge

gen commentaire =""
*=======================================================================================
*IM1.a-t-il vecu de manière continue dans une autre localité pendant au moins six mois ?
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM1) & Statut_Res==1 & membre_id_v1 =="##N/A##" 
*461 individus n'ont pas repondus 

replace commentaire="Il y a 461 individus qui n'ont pas repondus à la question IM1" if missing(IM1) & Statut_Res==1 & membre_id_v1 =="##N/A##"

*Exportation des agents concernés par les manquants 
count if missing(IM1) & Statut_Res==1 & membre_id_v1 =="##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 IM1 Statut_Res membre_id_v1 using "$folderpath/document/Err_IM1_NA" if missing(IM1) & Statut_Res==1 & membre_id_v1 =="##N/A##", firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM1) & (Statut_Res !=1 | membre_id_v1 !="##N/A##")
//RAS

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !inrange(IM1,1,2) & !missing(IM1)
//RAS

*=======================================================================================
*IM2A. Depuis quelle année vit-il/elle dans cette localité de manière continue
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM2A) & IM1==1
//3 individus n'ont pas repondus 

replace commentaire="Il y a 3 individus qui n'ont pas repondus à la question IM2A" if missing(IM2A) & IM1==1

*Exportation des agents concernés par les manquants 
count if missing(IM2A) & IM1==1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 IM2A IM1 membre_id_v1 using "$folderpath/document/Err_IM2A" if missing(IM2A) & IM1==1, firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM2A) & IM1 !=1
//RAS

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if IM2A>2026 & !missing(IM2A) & IM2A !=9998
//RAS

*4. Cohérence :
count if !inrange(IM2A,M6_A,2026) & !missing(IM2A, M6_A) & M6_A != 9998 & IM2A !=9998
//RAS
count if !missing(IM2A, AgeAnnee) & !inrange(IM2A, 2025 - AgeAnnee, 2026) & IM2A !=9998
//RAS
//Aucune incohérence détectée

*=======================================================================================
*IM2M. Depuis quel mois, %rostertitle% vit-il/elle dans cette localité de manière continue 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM2M) & !missing(IM2A) & IM2A != 9998
//RAS 

*replace commentaire="Il y a ... individus qui n'ont pas repondus à la question IM2M" if missing(IM2M) & !missing(IM2A) & IM2A != 9998

*Exportation des agents concernés par les manquants 
*export excel interview__key membre_id_v1 HH2 HH12 HH13 IM2A IM2M membre_id_v1 using "$folderpath/document/Err_IM2M" if missing(IM2M) & !missing(IM2A) & IM2A != 9998, firstrow(varlabels) replace

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM2M) & (missing(IM2A) | IM2A == 9998)
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(IM2M,1,12) & IM2M != 9998 & !missing(IM2M)
//RAS

*=======================================================================================
*IM3A. Depuis combien de temps (en nombre d’années) vit-il  dans cette localité de manière continue ?
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM3A) & IM2A ==9998
//RAS

*replace commentaire="Il y a ... individus qui n'ont pas repondus à la question IM3A" if missing(IM3A) & IM2A ==9998

*Exportation des agents concernés par les manquants 
*export excel interview__key membre_id_v1 HH2 HH12 HH13 IM2A IM3A membre_id_v1 using "$folderpath/document/Err_IM3A" if missing(IM2M) & !missing(IM2A) & IM2A != 9998, firstrow(varlabels) replace

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM3A) & IM2A != 9998
//RAS

*3. les valeurs renseignées sont elles permises ?
count if IM3A > 90 & !inlist(IM3A,.,.a,9998)
//RAS

*4. Cohérence :
count if (IM3A > AgeAnnee) & !inlist(AgeAnnee,.,.a,9998) & !inlist(IM3A,.,.a,9998)
//RAS

*=======================================================================================
*IM3M depuis combien de mois vit-il (elle) (%rostertitle%) dans cette localité 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM3M) & !missing(IM3A) & IM3A != 9998
//RAS 

*replace commentaire="Il y a ... individus qui n'ont pas repondus à la question IM3M" if missing(IM3M) & !missing(IM3A) & IM3A != 9998

*Exportation des agents concernés par les manquants 
*export excel interview__key membre_id_v1 HH2 HH12 HH13 IM3A IM3M membre_id_v1 using "$folderpath/document/Err_IM3M" if missing(IM3M) & !missing(IM3A) & IM3A != 9998, firstrow(varlabels) replace

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM3A) & (missing(IM3A) | IM3A == 9998)
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(IM3M,0,11) & !missing(IM3M) & IM3M != 9998
//RAS


*=======================================================================================
*IM4 Où habitait  avant de venir ou de revenir dans cette localité 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM4) & IM1==1
//2 individus n'ont pas repondus 

replace commentaire="Il y a 2 individus qui n'ont pas repondus à la question IM4" if missing(IM4) & IM1==1

*Exportation des agents concernés par les manquants 
count if missing(IM4) & IM1==1
if r(N)>0 {
    export excel interview__key membre_id_v1 HH2 HH12 HH13 IM1 IM4 membre_id_v1 using "$folderpath/document/Err_IM4" if missing(IM4) & IM1==1, firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM4) & IM1 !=1
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(IM4,1,2) & !missing(IM4)
//RAS

*=======================================================================================
*IM5.Dans quel pays habitaitavant de venir dans cette localité ? 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM5) & IM4==2
//RAS 

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM5) & IM4 !=2
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(IM5,1,216) & !missing(IM5)
//RAS

*=======================================================================================
*IM5_Aut. Autres à preciser 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM5_Aut) & inlist(IM5,28,36,41,44,47,48)
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM5_Aut) & !inlist(IM5,28,36,41,44,47,48)
//RAS

*=======================================================================================
*IM7.Dans quelle sous-préfecture habitait avant de venir dans cette localité 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM7) & IM4==1
//RAS 

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM7) & IM4 !=1
//RAS

*=======================================================================================
*IM7A.Dans quelle localité habitait avant de venir dans cette localité 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM7A) & IM4==1
//4 individus n'ont pas repondus 

replace commentaire="Il y a 4 individus qui n'ont pas repondus à la question IM7A" if missing(IM7A) & IM4==1
*Exportation des agents concernés par les manquants 
count if missing(IM7A) & IM4==1
if r(N)>0 {
    export excel interview__key membre_id_v1 HH2 HH12 HH13 IM4 IM7A membre_id_v1 using "$folderpath/document/Err_IM7A" if missing(IM7A) & IM4==1, firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM7A) & IM4 !=1
//RAS


*=======================================================================================
*IM8.Pourquoi est-il venu dans cette localité ?
*=======================================================================================

*1. Valeurs manquantes
egen nb_pas_manquant_IM8 = rownonmiss(IM8__1-IM8__9)
gen valeure_manquante1_IM8 = (nb_pas_manquant_IM8 == 0)
count if valeure_manquante1_IM8 ==1 & IM1==1 //Vérifie si aucun nom a été renseigné
//2 individus n'ont pas repondus 


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if valeure_manquante1_IM8 == 0 & IM1!=1
//RAS

*3. les valeurs renseignées sont elles permises ?
foreach var of varlist IM8__1-IM8__9{
count if !inrange(`var',0,1) & !missing(`var')
}
//RAS

*=======================================================================================
*IM8_Aut. Autres à preciser 
*=======================================================================================

*1. Valeurs manquantes
count if missing(IM8_Aut) & IM8__9==1
//RAS 

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(IM8_Aut)& IM8__9==2
//RAS


drop HH2 HH3 HH4 HH12 HH13 M1 M2 Statut_Res M6_A AgeAnnee


save "$standard_menage\QM_S4_immigration.dta", replace