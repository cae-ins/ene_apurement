
*=========================================================
* FORMATION PROFESSIONNELLE ET APPRENTISSAGE

* RESPONSABLE: RENAUD HIVITES AKATTIA (PECHOUX)
*========================================================
use "$datain_standard\QM_S3_formation_professionnelle.dta", clear

merge m:1 interview__key using "$datain_brute\qx_eec_vf.dta" , keepus(V1interviewkey rgmen HH01 HH2A HH8 rghab rgmen HH2 HH4 HH12 HH13 hh)

keep if _merge == 3
drop  _merge 

merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(  membre_id_v1 AgeAnnee Statut_Res M6_A)
keep if _merge == 3
drop  _merge 

cap drop commentaire
g commentaire=""
*===============================================
* FP1 a-t-il/elle suivi une formation professionnelle/apprentissage ?
*===============================================

*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP1) & AgeAnnee>=6 & Statut_Res==1 
*183 individus n'ont pas repondus 

replace commentaire="Il y a 168 individus qui n'ont pas repondus FP1" if missing(FP1) & AgeAnnee>=6 & Statut_Res==1

*Exportation des agents concernés par les manquants 
export excel interview__key HH2 HH12 HH13 FP1 commentaire rgmen using "$folderpath/document/Err_FP1" if missing(FP1) & AgeAnnee>=6 & Statut_Res==1, firstrow(varlabels) replace

*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP1) & (AgeAnnee<6 | Statut_Res==2 )

*problem 3: les variables renseignées sont elles permises 
count if !inrange(FP1,1,2) & !missing(FP1)
*RAS

*problem 4: vraisemblance des reponsees 
*il n'y a que deux modalités de reponses oui ou non, ce qui serait invraisemblable serait qu'un individu reponde alors qu'il n'est pas concerné ou qu'il y ait des valeurs non permises; Ce qui n'est pas le cas 


*===============================================
* FP2. Qui a principalement formé  ?
*==========================================

*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP2) & FP1==1 & membre_id_v1== "##N/A##"
*2 individus concernés

replace commentaire="Il y a 2 individus qui n'ont pas repondus à FP2" if missing(FP2) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
export excel interview__key HH2 HH12 HH13 FP2 commentaire rgmen using "$folderpath/document/Err_FP2" if missing(FP2) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace


*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP2) & (FP1==2 | membre_id_v1!= "##N/A##" )
*RAS

*problem 3: les variables renseignées sont elles permises 
count if !inrange(FP2,1,16) & !missing(FP2)
*RAS

*problem 4: vraisemblance des reponsees 
*RAS

*============================================
*FP2_Aut: Autres 
*=============================================

*Problem 1: Ceux qui devaient repondre ont is repondus
count if missing(FP2_Aut) & inlist(FP2,13,16)
*RAS

*Problem 2 : ceux qui ont repondus devaient ils repondre 
count if !missing(FP2_Aut) & !inlist(FP2,13,16)


*===============================================
* FP3.Dans quel métier ou filière a-t-il suivi la formation ?
*===============================================

*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP3) & FP1==1 & membre_id_v1== "##N/A##" 
// RAS

*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP3) & FP1==2 & membre_id_v1!= "##N/A##"
*RAS

replace commentaire="Il y a 13379 individus qui ont repondu à FP3 alors qu'ils ne le devraient pas" if !missing(FP3) & FP1==2 & membre_id_v1!= "##N/A##"

*Exportation des agents concernés par les manquants 
export excel interview__key HH2 HH12 HH13 FP3 commentaire rgmen using "$folderpath/document/Err_FP3" if !missing(FP3) & FP1==2 & membre_id_v1!= "##N/A##", firstrow(varlabels) replace



*Remplacer par un point le contenu de la variable FP3 pour ceux qui n'ont pas suivi de formation professionnelle/apprentissage
replace FP3 = . if !missing(FP3) & FP1==2 & membre_id_v1!= "##N/A##"

*problem 3: les variables renseignées sont elles permises 
count if !inrange(FP3,0,730) & !missing(FP3)
*RAS

*problem 4: vraisemblance des reponsees 
*RAS

*===========================
*FP4. Combien de temps a duré ou durera la formation 
*============================

*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP4) & FP1==1 & membre_id_v1== "##N/A##" 
// 3 individus concernés

replace commentaire="Il y a 3 individus qui n'ont pas repondu à FP4" if missing(FP4) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
export excel interview__key HH2 HH12 HH13 FP4 commentaire rgmen using "$folderpath/document/Err_FP4" if missing(FP4) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace


*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP4) & (FP1==2 | membre_id_v1!= "##N/A##"  )
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*la duree de la formation ne peut pas etre une valeur negative et ne peut pas depasser 10ans. C'est invraisemblable pour la durée d'une formation
count  if (FP4>=10 & FP4A==2 |FP4<0)& !missing(FP4)
*RAS

*Exportation des agents concernés par les manquants 
*export excel interview__key HH13 FP1 FP2_Aut FP4 using "$folderpath/document/Err_FP2_Aut" if (FP4>=10 |FP4<0)& !missing(FP4), firstrow(varlabels) replace

*problem 4: vraisemblance des reponsees 
*RAS



*===========================================
*FP4A.Unité de Durée de la formation
*======================================== 

*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP5) & !missing(FP4)
// RAS

*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP5) & (FP1==2 | membre_id_v1!= "##N/A##"  )
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*la duree de la formation ne peut pas etre une valeur negative et ne peut pas depasser 10ans. C'est invraisemblable pour la durée d'une formation
count  if !inrange(FP4A,1,2) & !missing(FP4A)
*RAS

*problem 4: vraisemblance des reponsees 
*RAS

*=======================================
*FP5. Quelle est la méthode de formation/apprentissage/ apprentissage suivi pendant la formation ?
*==================================

*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP5) & FP1==1 & membre_id_v1== "##N/A##" 
// 3 individus concernés

replace commentaire="Il y a 3 individus qui n'ont pas repondu à FP5" if missing(FP5) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
export excel interview__key HH2 HH12 HH13 FP5 commentaire rgmen using "$folderpath/document/Err_FP5" if missing(FP5) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace


*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP5) & (FP1==2 | membre_id_v1!= "##N/A##"  )
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*la duree de la formation ne peut pas etre une valeur negative et ne peut pas depasser 10ans. C'est invraisemblable pour la durée d'une formation
count  if !inrange(FP5,1,2) & !missing(FP5)
*RAS

*problem 4: vraisemblance des reponsees 
*RAS

*==========================================
*FP6. La formation de %rostertitle% est-elle en cours ou déjà achevée ?
*=========================================

*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP6) & FP1==1  

replace commentaire="Il y a 2 individus qui n'ont pas repondu à FP6" if missing(FP6) & FP1==1

*Exportation des agents concernés par les manquants 
export excel interview__key HH2 HH12 HH13 FP5 commentaire rgmen using "$folderpath/document/Err_FP6" if missing(FP6) & FP1==1, firstrow(varlabels) replace


*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP6) & FP1==2 
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*la duree de la formation ne peut pas etre une valeur negative et ne peut pas depasser 10ans. C'est invraisemblable pour la durée d'une formation
count  if !inrange(FP6,1,3) & !missing(FP6)
*RAS

*problem 4: vraisemblance des reponsees 
*RAS

*====================================
*FP7. Quel est le mode de formation/apprentissage suivi pendant la formation ?
*====================================
*Problem 1: ceux qui ont repondus devaient ils repondre 
count if missing(FP7) & FP1==1 & membre_id_v1== "##N/A##" // RAS

replace commentaire="Il y a 3 individus qui n'ont pas repondu à FP7" if missing(FP7) & FP1==1 & membre_id_v1== "##N/A##"

*Exportation des agents concernés par les manquants 
export excel interview__key HH2 HH12 HH13 FP5 commentaire rgmen using "$folderpath/document/Err_FP7" if missing(FP7) & FP1==1 & membre_id_v1== "##N/A##", firstrow(varlabels) replace

*problem 2: ceux qui ont repondu devaient ils repondre 
count if !missing(FP7) & (FP1==2 | membre_id_v1!= "##N/A##"  )
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*la duree de la formation ne peut pas etre une valeur negative et ne peut pas depasser 10ans. C'est invraisemblable pour la durée d'une formation
count  if !inrange(FP7,1,3) & !missing(FP7)
*RAS

*problem 4: vraisemblance des reponsees 
*RAS


drop HH01 HH2A HH2 HH4 HH8 rghab rgmen V1interviewkey HH13 hh Statut_Res M6_A AgeAnnee

save "$standard_menage\QM_S3_formation_professionnelle.dta", replace

