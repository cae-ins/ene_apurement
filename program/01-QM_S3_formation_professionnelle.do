
*=========================================================
* FORMATION PROFESSIONNELLE ET APPRENTISSAGE

* RESPONSABLE: DIABATE BEN ISMAEL
*========================================================

**********************LES ETAPES DE L'APUREMENT**********************************
**======================================================================================
*Etape1: Valeurs manquantes : Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: vérification des sauts : Est ce qu'il y a des individus qui ne devaient pas répondre mais qui ont répondu ? 
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
*Etape4: Cohérence : Les reponses données sont elles coherentes au regard des autres réponses ?
*Etape5 : Correction des erreurs identifiées 
*=======================================================================================


use "$datain_standard\QM_S3_formation_professionnelle.dta", clear

merge m:1 interview__key using "$brute_menage_work" , keepus(V1interviewkey rgmen HH01 HH2A HH8 rghab rgmen HH2 HH4 HH12 HH13 hh)

keep if _merge == 3
drop  _merge 

merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus( membre_id_v1 AgeAnnee Statut_Res M6_A)
keep if _merge == 3
drop  _merge 

cap drop commentaire
g commentaire=""

*====================================================================
* FP1. A-t-il/elle suivi une formation professionnelle/apprentissage ?
*====================================================================

*1. Valeurs manquantes
count if missing(FP1) & AgeAnnee>=6 & Statut_Res==1 
//392 individus n'ont pas repondus 

replace commentaire="Il y a 392 individus qui n'ont pas repondus à la question FP1" if missing(FP1) & AgeAnnee>=6 & Statut_Res==1

*Exportation des agents concernés par les manquants 
count if missing(FP1) & AgeAnnee>=6 & Statut_Res==1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 FP1 commentaire rgmen using "$folderpath/document/Err_FP1" if missing(FP1) & AgeAnnee>=6 & Statut_Res==1, firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(FP1) & (AgeAnnee<6 | Statut_Res !=1 )
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(FP1,1,2) & !missing(FP1)
//RAS

*==================================================================================
* FP2. Qui a principalement formé  ?
*==================================================================================

*1. Valeurs manquantes
count if missing(FP2) & FP1==1 & membre_id_v1== "##N/A##"
//14 individus n'ont pas repondus 

replace commentaire="Il y a 14 individus qui n'ont pas repondus à FP2" if missing(FP2) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
count if missing(FP2) & FP1==1 & membre_id_v1== "##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 FP1 FP2 commentaire rgmen using "$folderpath/document/Err_FP2" if missing(FP2) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(FP2) & (FP1 !=1 | membre_id_v1!= "##N/A##" )
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(FP2,1,16) & !missing(FP2)
//RAS

*==================================================================================
*FP2_Aut: Autres 
*==================================================================================

*1. Valeurs manquantes
count if missing(FP2_Aut) & inlist(FP2,13,16)
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(FP2_Aut) & !inlist(FP2,13,16)
//RAS

*==================================================================================
* FP3.Dans quel métier ou filière a-t-il suivi la formation ?
*==================================================================================

*1. Valeurs manquantes
count if missing(FP3) & FP1==1 & membre_id_v1== "##N/A##"
//16 individus n'ont pas repondus 

replace commentaire="Il y a 16 individus qui n'ont pas repondu à FP3" if missing(FP3) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
*export excel interview__key HH2 HH12 HH13 FP1 FP3 commentaire rgmen using "$folderpath/document/Err_FP3" if missing(FP3) & FP1==1 & membre_id_v1== "##N/A##" , firstrow(varlabels) replace

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(FP3) & (FP1 !=1 | membre_id_v1 != "##N/A##")
//RAS


*3. Vraisemblance : les valeurs renseignées sont elles permises ?
count if !inrange(FP3,0,730) & !missing(FP3)
//RAS

*==================================================================================
*FP3_Aut: Autres 
*==================================================================================

*1. Valeurs manquantes
count if missing(FP3_Aut) & FP3 ==0
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(FP3_Aut) & FP3 !=0
//RAS

*==================================================================================
*FP4. Combien de temps a duré ou durera la formation 
*==================================================================================

*1. Valeurs manquantes
count if missing(FP4) & FP1==1 & membre_id_v1== "##N/A##" 
* 16 individus n'ont pas repondus 

replace commentaire="Il y a 16 individus qui n'ont pas repondu à FP4" if missing(FP4) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
count if missing(FP4) & FP1==1 & membre_id_v1== "##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 FP1 FP4 commentaire rgmen using "$folderpath/document/Err_FP4" if missing(FP4) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace
}


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(FP4) & (FP1 !=1 | membre_id_v1 != "##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
count  if (FP4 >=10 & FP4A ==2 | FP4<0) & !missing(FP4)
//4 observations ayant une durée de formation trop élevé

*5. Correction :
replace FP4 =9 if FP4 >=10 & FP4A ==2 & !missing(FP4)

*==================================================================================
*FP4A.Unité de Durée de la formation
*================================================================================== 


*1. Valeurs manquantes
count if missing(FP4A) & !missing(FP4)
//RAS 

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(FP4A) & missing(FP4)
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inlist(FP4A,1,2) & !missing(FP4A)
//RAS

*4. Cohérence :
count if FP4A == 1 & FP4 > 12
//RAS
count if FP4 >=10 & FP4A ==2
//RAS

*=======================================================================================
*FP5. Quelle est la méthode de formation/apprentissage/ apprentissage suivi pendant la formation ?
*=======================================================================================

*1. Valeurs manquantes 
count if missing(FP5) & FP1==1 & membre_id_v1== "##N/A##"  
*16 individus n'ont pas repondus

replace commentaire="Il y a 16 individus qui n'ont pas repondu à FP5" if missing(FP5) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
count if missing(FP5) & FP1==1 & membre_id_v1== "##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 FP1 FP5 commentaire rgmen using "$folderpath/document/Err_FP5" if missing(FP5) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre 
count if !missing(FP5) & (FP1 !=1 | membre_id_v1 != "##N/A##")
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(FP5,1,2) & !missing(FP5)
//RAS

*==========================================
*FP6. La formation de %rostertitle% est-elle en cours ou déjà achevée ?
*=========================================

*1. Valeurs manquantes 
count if missing(FP6) & FP1==1  
//RAS


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre 
count if !missing(FP6) & FP1 != 1
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(FP6,1,3) & !missing(FP6)
//RAS

*===============================================================================
*FP7. Quel est le mode de formation/apprentissage suivi pendant la formation ?
*===============================================================================

*1. Valeurs manquantes 
count if missing(FP7) & FP1==1 & membre_id_v1== "##N/A##"  
*10 individus n'ont pas repondus

replace commentaire="Il y a 10 individus qui n'ont pas repondu à FP5" if missing(FP7) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
count if missing(FP7) & FP1==1 & membre_id_v1== "##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 FP1 FP7 commentaire rgmen using "$folderpath/document/Err_FP7" if missing(FP7) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace
}

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre 
count if !missing(FP7) & (FP1 !=1 | membre_id_v1 != "##N/A##")
//RAS

*3. Vraisemblance : les valeurs renseignées sont elles permises ?
count if !inrange(FP7,1,3) & !missing(FP7)


********************* SAUVEGARDE DE LA BASE DE DONNEES APUREE**************************

drop HH01 HH2A HH2 HH4 HH8 rghab rgmen V1interviewkey HH13 hh Statut_Res M6_A AgeAnnee

save "$standard_menage\QM_S3_formation_professionnelle.dta", replace

