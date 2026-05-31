*=========================================================
* DIFFICULTES FONCTIONNELLES

* RESPONSABLE: DIABATE BEN ISMAEL
*========================================================

**********************LES ETAPES DE L'APUREMENT**********************************
**======================================================================================
*Etape1: Valeurs manquantes : Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: vérification des sauts : Est ce qu'il y a des individus qui ne devaient pas répondre mais qui ont répondu ? 
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
*Etape4: Cohérence : Les reponses données sont elles coherentes au regard des autres réponses ? 
*=======================================================================================

use "$datain_standard\QM_S6_difficultes_fonctionnelles.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH12 HH13 HH3)
drop if _merge!=3
cap drop _merge


cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\QM_S1_composition_menage.dta", keepusing(AgeAnnee Statut_Res)
drop if _merge!=3
cap drop _merge

gen commentaire =""
*=======================================================================================
* DIF1A : problèmes de vue, même avec ses lunettes pharmaceutiques?
*=======================================================================================

*1. Valeurs manquantes
count if missing(DIF1A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"
//428 individus n'ont pas repondus 

replace commentaire="Il y a 428 individus qui n'ont pas repondus à la question DIF1A" if missing(DIF1A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"

*Exportation des agents concernés par les manquants 
count if missing(DIF1A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH3 HH4 HH12 HH13 AgeAnnee Statut_Res membre_id_v1 DIF1A using "$folderpath/document/Err_DIF1A" if missing(DIF1A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##", firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(DIF1A) & (AgeAnnee<5 & !missing(AgeAnnee) | Statut_Res !=1 | membre_id_v1 !="##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inlist(DIF1A,1,2,3,4,9997,9998) & !missing(DIF1A) 
//RAS

*=======================================================================================
***DIF2A. %rostertitle% a-t-il des difficultés à ente ndre ?, même avec une ou des prothèse(s) audi tive(s)? Diriez-vous...
*=======================================================================================

*1. Valeurs manquantes
count if missing(DIF2A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"
//428 individus n'ont pas repondus 

replace commentaire="Il y a 428 individus qui n'ont pas repondus à la question DIF2A" if missing(DIF2A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"

*Exportation des agents concernés par les manquants 
count if missing(DIF2A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH3 HH4 HH12 HH13 AgeAnnee Statut_Res membre_id_v1 DIF2A using "$folderpath/document/Err_DIF2A" if missing(DIF2A) & AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##", firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(DIF2A) & (AgeAnnee<5 & !missing(AgeAnnee) | Statut_Res !=1 | membre_id_v1 !="##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inlist(DIF2A,1,2,3,4,9997,9998) & !missing(DIF2A) 
//RAS

*=======================================================================================
****DIF3. %rostertitle% utilise-t-il/elle un équipement ou reçoit-il/elle de l’aide pour se déplacer : 
*=======================================================================================

*1. Valeurs manquantes
egen nb_pas_manquant_DIF3 = rownonmiss(DIF3__1-DIF3__9)
gen valeure_manquante1 = (nb_pas_manquant_DIF3 == 0)
count if valeure_manquante1 ==1 & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
*428 individus n'ont pas repondus 

replace commentaire="Il y a 428 individus qui n'ont pas repondus à la question DIF3" if valeure_manquante1 ==1 & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")

*Exportation des agents concernés par les manquants 
count if valeure_manquante1 ==1 & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
if r(N)>0 {
    export excel interview__key HH2 HH3 HH4 HH12 HH13 AgeAnnee Statut_Res membre_id_v1 DIF3__1-DIF3__9 using "$folderpath/document/Err_DIF3" if valeure_manquante1 ==1 & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"), firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if valeure_manquante1 ==0 & (AgeAnnee <5 | Statut_Res !=1 & membre_id_v1 !="##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
foreach var of varlist DIF3__1-DIF3__9{
count if !inrange(`var',0,1) & !missing(`var')
}
//RAS

*=======================================================================================
****DIF3_Aut. veuillez préciser ?
*=======================================================================================

*1. Valeurs manquantes
count if missing(DIF3_Aut) & DIF3__9==1
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(DIF3_Aut) & DIF3__9 !=1
//RAS

*=======================================================================================
**** DIF3B. %rostertitle% a t il des difficultés utiliser ses mains/bras comme par exemple souleve r une bouteille d’eau ou de soda de 2 litres du n iveau de la taille jusqua niveau des yeux, ramas ser des petits objects avec ses doigts, ouvrir ou fermer un recipients ? diriez vous…
*=======================================================================================

*1. Valeurs manquantes
count if missing(DIF3B) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
//428 individus n'ont pas repondus 

replace commentaire="Il y a 428 individus qui n'ont pas repondus à la question DIF3B" if missing(DIF3B) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")

*Exportation des agents concernés par les manquants 
count if missing(DIF3B) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
if r(N)>0 {
    export excel interview__key HH2 HH3 HH4 HH12 HH13 AgeAnnee Statut_Res membre_id_v1 DIF3B using "$folderpath/document/Err_DIF3B" if missing(DIF3B) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"), firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(DIF3B) & (AgeAnnee<5 | Statut_Res !=1 | membre_id_v1 !="##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inlist(DIF3B,1,2,3,4,9997,9998) & !missing(DIF3B)
//RAS

*=======================================================================================
****DIF3D. %rostertitle% a-t-il des difficultés à communiquer dans sa langue habituelle,à comprendre  les autres ou à se faire comprendre, y co mpris l’utilisation du langage des signes ? Dirie
*=======================================================================================

*1. Valeurs manquantes
count if missing(DIF3D) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
//428 individus n'ont pas repondus

replace commentaire="Il y a 428 individus qui n'ont pas repondus à la question DIF3B" if missing(DIF3D) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")

*Exportation des agents concernés par les manquants 
count if missing(DIF3D) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
if r(N)>0 {
    export excel interview__key HH2 HH3 HH4 HH12 HH13 AgeAnnee Statut_Res membre_id_v1 DIF3D using "$folderpath/document/Err_DIF3D" if missing(DIF3D) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"), firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(DIF3D) & (AgeAnnee<5 | Statut_Res !=1 | membre_id_v1 !="##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inlist(DIF3D,1,2,3,4,9997,9998) & !missing(DIF3D)
//RAS

*=======================================================================================
****DIF5. %rostertitle% a-t-il des problèmes psychique, trouble mentaux ? Diriez-vous…
*=======================================================================================

*1. Valeurs manquantes
count if missing(DIF5) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
//428 individus n'ont pas repondus

replace commentaire="Il y a 428 individus qui n'ont pas repondus à la question DIF5" if missing(DIF5) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")

*Exportation des agents concernés par les manquants 
count if missing(DIF5) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##")
if r(N)>0 {
    export excel interview__key HH2 HH3 HH4 HH12 HH13 AgeAnnee Statut_Res membre_id_v1 DIF5 using "$folderpath/document/Err_DIF5" if missing(DIF5) & (AgeAnnee>=5 & !missing(AgeAnnee) & Statut_Res==1 & membre_id_v1=="##N/A##"), firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(DIF5) & (AgeAnnee<5 | Statut_Res !=1 | membre_id_v1 !="##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inlist(DIF5,1,2,3,4,9997,9998) & !missing(DIF3B)
//RAS


drop HH2 HH3 HH4 HH12 HH13 Statut_Res AgeAnnee


save "$standard_menage\QM_S6_difficultes_fonctionnelles.dta", replace
