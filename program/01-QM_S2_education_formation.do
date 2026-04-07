*******************************************************************************
*      VERIFICATION ET TRAITEMENT DE LA SECTION "EDUCATION"                   *
*                                                                             *
*       RESPONSABLE : RENAUD AKATTIA                                  *
*
*******************************************************************************

*==============================================================================*
use "$datain_standard\QM_S2_education_formation.dta", clear

merge m:1 interview__key using "$datain_brute\qx_eec_vf.dta" , keepus(V1interviewkey rgmen   HH01 HH2 HH12 HH2A HH8 rghab rgmen HH2 HH4 HH13 hh)

keep if _merge == 3
drop  _merge 

merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus( membre_id_v1 AgeAnnee Statut_Res M7 M6_A)
keep if _merge == 3
drop  _merge 

cap drop commentaire
g commentaire=""

*========================================
**** EF1 : a-t-il/elle déjà fréquenté une école ?
*=======================================

**Problème 1: cette instruction permet de voir si tous ceux qui devaient repondre ont repondu 

count if missing(EF1) & AgeAnnee >= 3 & AgeAnnee!=.a & AgeAnnee!=.  & Statut_Res == 1 // 194 individus pour qui la variable n'a pas été répondu.

replace commentaire = "Les individus qui devait reponse a EF1 mais n'ont pas repondu" if missing(EF1) & AgeAnnee >= 3 & AgeAnnee!=.a & AgeAnnee!=.  & Statut_Res == 1
 
*exportation des individus potentiellement concernées 
export excel interview__key HH2 HH12 HH13 EF1 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF1_NA" if missing(EF1) & AgeAnnee >= 3 & AgeAnnee!=.a & AgeAnnee!=.  & Statut_Res == 1, firstrow(varlabels) replace 

**problème 2: Ceux qui ont repondu devaient ils repondre?
count if !missing(EF1) & (AgeAnnee<3 | Statut_Res==0) // RAS 

*br EF1 AgeAnnee Statut_Res if !missing(EF1) & (AgeAnnee<3 | Statut_Res==0) // *RAS

**problème 3: Valeurs s'écartant des valeurs prevues
count if !inlist(EF1,1,2) & !missing(EF1)
*RAS

**problème 4: les variables antérieures ne nous permettent pas de verifier la vraisemblance des données
 
*=======================================
****EF2 : type d'école a-t-il/elle fréquenté pour la dernière fois
*========================================

**Problème 1 : Ceux qui devaient repondre ont ils repondu
count if missing(EF2) & EF1==1 & membre_id_v1 == "##N/A##" // RAS
*exportation des individus potentiellement concernées

*replace commentaire="individu pour qui la question EF2 n'a pas été répondu" if missing(EF2) & EF1==1 & membre_id_v1 == "##N/A##"

*export excel interview__key HH2 HH12 HH13 EF1 EF2 AgeAnnee Statut_Res membre_id_v1 rgmen using "$folderpath/document/Erreur_EF2_NA" if missing(EF2) & EF1==1 & membre_id_v1 == "##N/A##", firstrow(varlabels) replace
*
**problème 2: Ceux qui ont repondus devaient ils repondre?

count if !missing(EF2) & (EF1==2 | membre_id_v1 != "##N/A##") //RAS

**Problème 3: les valeurs renseignées sont elles permises
count if !inrange(EF2, 1, 4) & !missing(EF2) //RAS

*Problème 4: Vraisemeblance des reponses 
*les variables précedentes ne nous permettent pas de vérifier la vraisemblance des données 

*========================================
****EF3 :  le plus haut niveau d'études  atteint ?
*========================================
**Problème1: Tous ceux qui devaient repondre ont ils repondus?
count if missing(EF3) & EF1==1 // 6 individus pour qui la variable n'a pas été répondu. 

*exportation des individus potentiellement concernées

replace commentaire="individu pour qui la question EF3 n'a pas été répondu" if missing(EF3) & EF1==1

export excel interview__key HH13 EF1 EF3 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF3_NA" if missing(EF3) & EF1==1, firstrow(varlabels) replace
*

**Problème2: Ceux qui ont repondus devaient ils repondre 
count if !missing(EF3) & EF1!=1 // RAS
 
**Problème3: les valeurs renseignées sont elles permises
count if !inrange(EF3,0,12) & !missing(EF3)

**Problème 4: Vraisemblance des reponses

count if inrange(EF3,3,12) & AgeAnnee <10 & AgeAnnee!=. & AgeAnnee!=.a

*br AgeAnnee  EF3 EF1 if inrange(EF3,3,12) & AgeAnnee <10 & AgeAnnee!=. & AgeAnnee!=.a // 27 enfants de moins de 10 ans qui ont atteint un niveau d'étude supérieur au primaire. Ceci semblent inconsistent ! 

replace commentaire="27 enfants de moins de 10 ans qui ont atteint un niveau d'étude supérieur au primaire. Ceci semblent inconsistent !" if inrange(EF3,3,12) & AgeAnnee <10 & AgeAnnee!=. & AgeAnnee!=.a

*exportation des individus potentiellement concernées

export excel interview__key HH2 HH12 HH13 EF1 EF3 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF3_vraissenblance" if inrange(EF3,3,12) & AgeAnnee <10 & AgeAnnee!=. & AgeAnnee!=.a, firstrow(varlabels) replace
*

*proposition de corrections


// les enfants d'au plus 3 ans ayant fréquenté et qui ont déclaré un niveau supérieur ou égale au sécondaire sont ramenés au prescolaire avec aucun diplome 
gen EF3_= EF3
replace EF3=1 if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12)) 
 
replace EF4 = 3 if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12))

replace EF4_1 = 0 if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_3a = "" if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12))
replace EF4_3 =. if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12))
replace EF4_4 =. if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12))

*cap drop EF3_

// les enfants entre 4 ans et 6 ans ayant fréquenté et qui ont déclaré un niveau supérieur ou égale au sécondaire sont ramenés au primaire avec aucun diplome 

replace EF3=2 if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 
 
replace EF4 = 6 if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_1 = 0 if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_3a = "" if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12))
replace EF4_3 =. if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 
replace EF4_4 =. if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 

// les enfants entre 6 ans et 9 ans ayant fréquenté et qui ont déclaré un niveau supérieur ou égale au sécondaire sont ramenés au primaire avec aucun diplome

replace EF3=2 if (inrange(AgeAnnee,6,9) & EF1==1 & inrange(EF3_,3,12)) 
 
replace EF4 = 9 if (inrange(AgeAnnee,6,9) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_1 = 0 if (inrange(AgeAnnee,6,9) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_3a = "" if (AgeAnnee<=3 & EF1==1 & inrange(EF3_,3,12))
replace EF4_3 =. if (inrange(AgeAnnee,6,9) & EF1==1 & inrange(EF3_,3,12)) 
replace EF4_4 =. if (inrange(AgeAnnee,6,9) & EF1==1 & inrange(EF3_,3,12))

cap drop EF3_
*=======================================
****EF4 : la classe la plus élevée que  a achevé avec succès ?
*========================================
**Problème1: Ceux qui devaient repondre ont ils repondu?
count if missing(EF4) & EF1 == 1 & !inlist(EF3,1,.,.a) // 37 individus pour qui la variable EF4 n'a pas été répondu

replace commentaire ="3 individus pour qui la variable EF4 n'a pas été répondu" if missing(EF4) & EF1 == 1 & !inlist(EF3,1,.,.a)
*exportation des individus potentiellement concernées

export excel interview__key HH2 HH12 HH13 EF1 EF3 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_NA" if missing(EF4) & EF1 == 1 & !inlist(EF3,1,.,.a), firstrow(varlabels) replace
*

**Problème2: ceux qui ont repondu devaient ils repondre
count if !missing(EF4) & (EF1 ==2 | inlist(EF3,.,.a)) // RAS



**Problème3: les valeurs renseignées sont elles prevues
/*count if !inrange(EF4,0,22) & !missing(EF4) 
count if inlist(EF3,1) & !inlist(EF4,1,2,3,.,.a)
count if inlist(EF3,2) & !inlist(EF4,4,5,6,7,8,9,.,.a)
294 personnes ayant declaré le primaire comme plus haut niveau d'études dont:
10 personnes qui ont comme dernière classe reussie la moyenne section
146 personnes qui comme dernière classe reussie la grande section
47 personnes qui n'ont fait aucune classes
10 personnes qui ont fait la petite section 

Pour tous ses individus, les âges sont compris entre 3 et 50 avec une part plus importante 5,6,7ans

Les  enfants(3 à 7 ans) qui ont comme dernière classe reussie aucun, ou entre la petite et la grande sections peuvent avoir sauté de classe pask jugés trop intelligents ou que les parents les aient directement inscrits à l'école primaire.

Pour les personnes adultes, ce dont l'âge est entre 32 et 50, il est possible qu'il n'est pas fait le prescolaire et qu'ils se soient inscrits direct au primaire. Il y a la possiblité qu'ils aient egalment fait l'ecole prescolaire pour finalement revenir bien plutard.

Par contre:
Il semble inconsistent que des enfants de 8 à 13ans aient comme niveau plus elevé primaire et dernière classe reussie le petite, moyenne ou la grande section 

cependant, il est difficile de le corriger parceque l'on ne sqit pas veritablment dans quelle classe du primaire on pourrait les mettre  



replace commentaire="27 personnes avec le niveau le plus élevé primaire et dont l'âge est compris entre 8 et 13ans ont comme dernière classe frequentée Aucun ou sont entre la petite et la grande section" if inlist(EF3,2) & !inlist(EF4,4,5,6,7,8,9,.,.a) & inrange(AgeAnnee ,8,13)

*identification des agents yant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh12" if inlist(EF3,2) & !inlist(EF4,4,5,6,7,8,9,.,.a) & inrange(AgeAnnee ,8,13), firstrow(varlabels) replace


br EF3 EF4 if inlist(EF3,3,4) & !inlist(EF4,10,11,12,13,.,.a)

count if inlist(EF3,3,4) & !inlist(EF4,10,11,12,13,.,.a)
*183 personnes ont comme classe la plus élevée le CM2 et niveau secondaire general 1

*368 personnes ont comme niveau la classe la plus élevée et le niveau secondaire (General et technique) 1

replace commentaire="il y a 368 personnes ont comme niveau la classe la plus élevée et le niveau secondaire (General et technique) 1" if inlist(EF3,3,4) & !inlist(EF4,10,11,12,13,.,.a)

*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh2" if inlist(EF3,3,4) & !inlist(EF4,10,11,12,13,.,.a), firstrow(varlabels) replace

*corrections
*On impute leur niveau d'études par le niveau primaire 
replace EF3=2 if inlist(EF3,3,4) & !inlist(EF4,10,11,12,13,.,.a)



count if inlist(EF3,5,6) & !inlist(EF4,14,15,16,.,.a)
*89 personnes ont comme classe la plus élevée la 3e et le niveau secondaire general II

*165 personnes ont comme classe la plus élevée la 3e et le niveau secondaire (general, technique) II

replace commentaire="il y a 165 personnes ont comme classe la plus élevée la 3e et le niveau secondaire (general, technique) II" if inlist(EF3,5,6) & !inlist(EF4,14,15,16,.,.a)

*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh3" if inlist(EF3,5,6) & !inlist(EF4,14,15,16,.,.a), firstrow(varlabels) replace

*Correction
*On impute leur niveau d'études par le niveau secondaire general I
replace EF3=3 if inlist(EF3,5,6) & !inlist(EF4,14,15,16,.,.a)



count if inlist(EF3,7) & !inlist(EF4,17,18,.,.a)
*13 individus ont comme classe la plus élevée terminale et comme plus haut niveau superieur cycle court 

*48 individus ont comme classe la plus élevée terminale et comme plus haut niveau superieur cycle court 


replace commentaire="il y a 48 individus qui ont déclaré que le plus haut niveau d'études atteint est le superieur cycle court et qui en meme temps declarent comme classe Tle" if inlist(EF3,7) & !inlist(EF4,17,18,.,.a)

*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh4" if inlist(EF3,7) & !inlist(EF4,17,18,.,.a), firstrow(varlabels) replace

*Correction
*On impute leur niveau d'études par le niveau secondaire general II
replace EF3=5 if inlist(EF3,7) & !inlist(EF4,17,18,.,.a)


count if inlist(EF3,8) & !inlist(EF4,19,.,.a)
**il y a 13 individus qui ont déclaré que le plus haut niveau d'études atteint est la licence et qui en meme temps declarent une autre classe que BAC+3

**il y a 18 individus qui ont déclaré que le plus haut niveau d'études atteint est la licence et qui en meme temps declarent une autre classe que BAC+3


replace commentaire="il y a 18 individus qui ont déclaré que le plus haut niveau d'études atteint est la licence et qui en meme temps declarent une autre classe que BAC+3" if inlist(EF3,8) & !inlist(EF4,19,.,.a)

*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh1" if inlist(EF3,8) & !inlist(EF4,19,.,.a), firstrow(varlabels) replace

*Correction
replace EF4= 19 if inlist(EF3,8) & !inlist(EF4,19,.,.a) 
*On impute par BAC+3 tous ceux qui ont declaré licence comme le plus haut niveau d'études et une classe differente de BAC+3


count if inlist(EF3,9) & !inlist(EF4,20,.,.a)
*il y a 16 individus qui ont déclaré que le plus haut niveau d'etudes est la maitrise et en meme temps declarent un niveau d'etudes different de BAC+4

*il y a 17 individus qui ont déclaré que le plus haut niveau d'etudes est la maitrise et en meme temps declarent un niveau d'etudes different de BAC+4

replace commentaire="il y a 17 individus qui ont déclaré que le plus haut niveau d'etudes est la maitrise et en meme temps declarent un niveau d'etudes different de BAC+4" if inlist(EF3,9) & !inlist(EF4,20,.,.a) 

*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh5" if  inlist(EF3,9) & !inlist(EF4,20,.,.a), firstrow(varlabels) replace

*Correction
replace EF4=20 if inlist(EF3,9) & !inlist(EF4,20,.,.a)
*On impute par BAC+4 tous ceux qui sont en erreur pour cette partie


count if inlist(EF3,10) & !inlist(EF4,21,.,.a)
*il y a 10 individus qui ont déclaré que le plus haut niveau d'etudes est le master2 et en meme temps declarent un niveau d'etudes different de BAC+5


*il y a 23 individus qui ont déclaré que le plus haut niveau d'etudes est le master2 et en meme temps declarent un niveau d'etudes different de BAC+5

replace commentaire ="il y a 23 individus qui ont déclaré que le plus haut niveau d'etudes est le master2 et en meme temps declarent un niveau d'etudes different de BAC+5" if inlist(EF3,10) & !inlist(EF4,21,.,.a)

*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh6" if  inlist(EF3,10) & !inlist(EF4,21,.,.a), firstrow(varlabels) replace


*Correction 
replace EF4=21 if inlist(EF3,10) & !inlist(EF4,21,.,.a)
* On impute par BAC+5 tous les individus qui sont en erreur pour cette partie 


count if inlist(EF3,11,12) & !inlist(EF4,22,.,.a)
*Il y a 4 individu qui déclare que le plus haut niveau d'etudes est le Doctorat et en meme temps declare un niveau d'etudes different de BAC+5

**Il y a 2 individu qui déclare que le plus haut niveau d'etudes est le Doctorat et en meme temps declare un niveau d'etudes different de BAC+5



replace commentaire="Il y a 2 individus qui déclare que le plus haut niveau d'etudes est le Doctorat et en meme temps declare un niveau d'etudes different de BAC+5" if inlist(EF3,11,12) & !inlist(EF4,22,.,.a)


*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh7" if  inlist(EF3,11,12) & !inlist(EF4,22,.,.a), firstrow(varlabels) replace

*Correction
replace EF4=22 if inlist(EF3,11,12) & !inlist(EF4,22,.,.a)
*/



count if !inrange(EF4,0,22) & !missing(EF4) /// RAS

count if inlist(EF3,1) & !inlist(EF4,1,2,3,.,.a) /// RAS

count if inlist(EF3,2) & !inlist(EF4,4,5,6,7,8,9,.,.a) /// RAS


count if inlist(EF3,3,4) & !inlist(EF4,10,11,12,13,.,.a) /// RAS


count if inlist(EF3,5,6) & !inlist(EF4,14,15,16,.,.a) /// RAS


count if inlist(EF3,8) & !inlist(EF4,17,18,19,.,.a) /// RAS


count if inlist(EF3,9) & !inlist(EF4,20,.,.a) // 

replace EF3 = 8 if EF3 == 9 & EF4 == 18 // Attribuer le niveau Licence aux personnes ayant achevé le BAC+2
replace EF3 = 10 if EF3 == 9 & EF4 == 21 // Attribuer le niveau Master 2 aux personnes ayant achevé le BAC+5

count if inlist(EF3,10) & !inlist(EF4,21,.,.a) // 
*br EF3 EF4 if inlist(EF3,10) & !inlist(EF4,21,.,.a) // 
replace EF3 = 9 if EF3 == 10 & EF4 == 19 // Attribuer le niveau MAster 1 aux personnes ayant achevé le BAC+3

count if inlist(EF3,11,12) & !inlist(EF4,22,.,.a) // Doctorat ou plus
*br EF3 EF4 if inlist(EF3,11,12) & !inlist(EF4,22,.,.a) // Doctorat ou plus




**Problème4: Vraisemblance des reponses

*1. Age qui cadre pas avec le niveau renseigné
count if AgeAnnee<=3 & EF4>5 & !missing(EF4) & EF1==1 // Il y a  8 enfants d'au plus 3ans qui sont au moins au CP2

*br EF3 EF4 AgeAnnee if AgeAnnee<=3 & EF4>=4 & !missing(EF4) & EF1==1
replace EF4 = 4 if  AgeAnnee<=3 & EF4>=4 & !missing(EF4) & EF1==1 // Attribuer la classe CP1 aux enfants de moins de 3 ans


*br EF3 EF4 if AgeAnnee<=3 & EF4>5 & !missing(EF4) & EF1==1 
* ses enfants sont au CE1, CE2, CM1 et 4e . Ce n'est pas normal

*replace commentaire="Il y a  9 enfants d'au plus 3ans qui sont au moins au CE1, CE2, CM1 et 4e " if AgeAnnee<=3 & EF4>5 & !missing(EF4) & EF1==1

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 EF1 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_coh8" if  AgeAnnee<=3 & EF4>5 & !missing(EF4) & EF1==1 , firstrow(varlabels) replace

*replace M6_A=2014 if interview__key=="45-00-76-27" & M6_A==2021 // il est au CM1 avec un age de 3 ans née en M6_A ==2021. On souhaite donc actualisé son année de naissance M6_A

//--------------------------------------------------------------------//
*Problème de cohérence entre l'âge et la classe la plus élevée 
count if AgeAnnee<=10 & EF4>=14 & EF1==1 & !missing(EF4)
*RAS

count if AgeAnnee<=15 & EF4>=16 & EF1==1 & !missing(EF4)
*br EF3 EF4 AgeAnnee if AgeAnnee<=15 & EF4>=16 & EF1==1 & !missing(EF4)
//--------------------------------------------------------------------//

/*
2. Mauvais  matching entre le niveau d'etudes et la classe actuelle

count if !inlist(EF3,2,.,.a) & inlist(EF4,4,5,6,7,8,9)


count if !inlist(EF3,3,4,.,.a) & inlist(EF4,10,11,12,13)

count if !inlist(EF3,5,6,.,.a) & inlist(EF4,14,15,16)



count if !inlist(EF3,7,.,.a) & inlist(EF4,17,18)
 


count if !inlist(EF3,8,.,.a) & inlist(EF4,19)



count if !inlist(EF3,9,.,.a) & inlist(EF4,20)

count if !inlist(EF3,10,.,.a) & inlist(EF4,21)
*/

*===================
** EF4_1 : diplôme le plus élevé obtenu 
*====================

* Problème1: Ceux qui devaient repondre ont ils repondus
count if missing(EF4_1) & EF1==1
*476 de ceux qui devaient repondre n'ont pas repondu
*br if missing(EF4_1) & EF1==1


replace commentaire="476 de ceux qui devaient repondre a la question EF4_1(diplôme le plus élevé obtenu) mais n'ont pas repondu" if missing(EF4_1) & EF1==1

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF1 EF4 EF4_1 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_1_NA" if missing(EF4_1) & EF1==1, firstrow(varlabels) replace


replace EF4_1 = 0 if missing(EF4_1) & EF1==1 & EF3 <= 1 // Pour les individus au préscolaire ou n'ayant auncun niveau nous imputons le diplôme le plus élevé obtenu=AUCUN

replace EF4_1 = 0 if missing(EF4_1) & EF1==1 & EF3==2 & EF4 <= 8 // Pour les individus du primaire n'ayant pas achevé le CM2 le plus haut diplôme est AUCUN

replace EF4_1=1  if missing(EF4_1) & EF1==1 & EF3==3 // Pour les individus au primaire et la classe la plus élevée==Secondaire général cycle I; nous imputons le diplôme le plus élevé obtenu=CEPE


**Problème2: ceux qui ont repndu etaient ils autorisés à le faire
count if EF1==2 & !missing(EF4_1)

**Problème3: Les valeurs renseignées sont elles permises 
count if !inrange(EF4_1,0,7) & !missing(EF4_1)
count if EF4_1 == 1 & EF4 < 9
count if EF4_1 == 2 & EF4 < 13
count if EF4_1 == 3 & EF4 < 16
count if EF4_1==4 & EF4 <18

count if EF4_1==5 & EF4<19 & !missing(EF4,EF4_1)
*8 individus dont le le diplôme le plus élevé obtenu== licence et la classe la plus élevée est en dessous de BAC+3

*br if EF4_1==5 & EF4<19 & !missing(EF4,EF4_1)



replace commentaire="8 individus dont le le diplôme le plus élevé obtenu== licence et la classe la plus élevée est en dessous du BAC+3" if EF4_1==5 & EF4<19 & !missing(EF4,EF4_1)

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF1 EF4 EF4_1 AgeAnnee Statut_Res rgmen commentaire using "$folderpath/document/Erreur_EF4_1_coh1" if EF4_1==5 & EF4<19, firstrow(varlabels) replace

*Correction
replace EF4_1=4 if EF4_1==5 & EF4<19 & !missing(EF4,EF4_1)

count if EF4_1==6 & EF4<21 & !missing(EF4,EF4_1)
*il y a 54 incoherences à ce niveau 

*br if EF4_1==6 & EF4<21 & !missing(EF4,EF4_1)


*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF1 EF4 EF4_1 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_1_coh2" if EF4_1==6 & EF4<21 & !missing(EF4,EF4_1), firstrow(varlabels) replace

*correction
replace EF4_1=5 if EF4_1==6 & EF4<21 & !missing(EF4,EF4_1)


* Doctorat
count if EF4_1==7 & EF4<22

count if EF4_1==0 & EF4>9 & !missing(EF4,EF4_1)
*158 personnes sont concernées


*Correction
replace EF4_1=1 if EF4_1==0  & EF4>9 & !missing(EF4,EF4_1) & inlist(EF4,10,11,12)

replace EF4_1=2 if EF4_1==0  & EF4>9 & !missing(EF4,EF4_1) & inlist(EF4,13,14,15)

replace EF4_1=1 if EF4_1==0  & EF4>9 & !missing(EF4,EF4_1) & inlist(EF4,10,11,12,13,14,15,16)

**Problème 4: Vraisemblance des reponses 

*Coherence d'age
count if AgeAnnee<=3 & !inlist(EF4_1,0,.,.a)
*br if AgeAnnee<=3 & !inlist(EF4_1,0,.,.a)


count if AgeAnnee<=10 & !inlist(EF4_1,0,1,.,.a)
*br if AgeAnnee<=10 & !inlist(EF4_1,0,1,.,.a)

*=================================
** EF4_3 : spécialité du diplôme le plus élevé obtenu 
*==================================

* Problème1: Ceux qui devaient repondre ont ils tous repondu
count if missing(EF4_3) & EF1==1 & !inlist(EF3,1,2,3,4,5,6,.,.a) & !inlist(EF4_1,0,1,.,.a) 
*24 individus sont concernés
*br if missing(EF4_3) & EF1==1 & !inlist(EF3,1,2,3,4,5,6,.,.a) & !inlist(EF4_1,0,1,.,.a) 


*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF1 EF4_1 EF4_3 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_3_NA" if missing(EF4_3) & EF1==1 & !inlist(EF3,1,2,3,.,.a) & !inlist(EF4_1,0,1,.,.a),firstrow(varlabels) replace

*Problème2: ceux qui ont repondu devaient ils repondre
count if (!missing(EF4_3) & EF1==2) & (inlist(EF3,1,2,3,4,5,6,.,.a) | inlist(EF4_1,0,1,.,.a) )


*Problème3: les valeurs renseignées sont elles permises 
count if !inrange(EF4_3, -1, 426) & !missing(EF4_3)

*Problème4: vraisemblance des données
**Rien à signaler 


*====================================
** EF4_4 : année d'obtention du diplôme le plus élevé obtenu 
*======================================

* Problème1: Ceux qui devient repondre ont ils repondu
count if !inlist(EF3,1,.,.a) & !inlist(EF4_1,0,.,.a) & missing(EF4_4)
*197 individus sont concernés

*112 individus sont concernés 

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF1 EF4_3 EF4_4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_4_NA" if !inlist(EF3,1,.,.a) & !inlist(EF4_1,0,.,.a) & missing(EF4_4),firstrow(varlabels) replace
 

*problème2: ceux qui ont repondu devaient ils repondre
count if !missing(EF4_4) & (inlist(EF3,1,.,.a) | inlist(EF4_1,0,.,.a) & missing(EF4_4))

*Problème3: Les valeurs renseignées sont elles permises
count if (EF4_4<1900 | EF4_4>2025) & !missing(EF4_4) & EF4_4!=9998 //RAS
*2 cas 

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF1 EF4_3 EF4_4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_4_coh" if  (EF4_4<1900 | EF4_4>2024) & !missing(EF4_4) & EF4_4!=9998,firstrow(varlabels) replace

*Corrections
replace EF4_4 = 9998 if (EF4_4<1900 | EF4_4>2025) & !missing(EF4_4) & EF4_4!=9998

*Problème4: Vraisemblance des reponses 

*1. Des personnes relativement jeunes qui disent ne pas savoir la date d'obtention de leur dernier diplome
count  if AgeAnnee<=60 & EF4_4==9998
*23 personnes concernées 

*RAS

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 EF1 EF4_3 EF4_4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_4_coh1" if AgeAnnee<=60 & EF4_4==9998,firstrow(varlabels) replace


*2. Des personnes dont la date d'obtention du dernier diplome est plus petite que l'année de naissance

count if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998
*15 personnes concernées 

*br EF4_4 M6_A if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998
*15 personnes concernées 

replace commentaire="Des personnes dont la date d'obtention du dernier diplome est plus petite que l'année de naissance" if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF1 EF4_3 EF4_4 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF4_4_coh2" if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998,firstrow(varlabels) replace


replace EF4_4=.  if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998
/*

interview__key
05-32-31-56
08-65-62-72
16-74-67-28
21-35-12-99
24-64-09-81
25-76-41-74
26-14-80-74
30-73-27-16
30-73-27-16
33-95-26-86
38-73-94-23
49-20-27-03
58-04-03-89
59-31-25-22
70-60-18-92
70-60-18-92
74-57-79-47
76-45-29-74
84-80-77-09
85-55-39-43
93-58-41-32
95-67-47-81

*/

*==============================
** EF5 : raisons de l'absence à l'école
*=======================================

* Problème1 Ceux qui devaient repondre ont ils repondus
count if missing(EF5) & EF1==2
*3 cas 

* Problème2: Ceux qui ont repondus devaient ils repondre
count if EF1==1 & !missing(EF5) // RAS

* Problème3: les valeurs renseignées sont elles permises 
count if !inrange(EF5, 1, 20) & !missing(EF5)

* Problème4: Vraisemblance des reponses 
*Rien à signaler 

*========================
*EF5 autres
*==========================

* Problème1 Ceux qui devaient repondre ont ils repondus
count if missing(EF5_AUTRE ) & EF5==20
*RAS

* Problème2: Ceux qui ont repondus devaient ils repondre
count if !missing(EF5_AUTRE ) & EF5!=20


*===================================
** EF6 : a-t-il /elle fréquenté l'école à n'importe quel moment durant l'année scolaire 
*=================================

* Problème1: Ceux qui devaient repondre ont ils repondus
count if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40
*9 individus sont concernés par cette situation



replace commentaire=" 2 personnes de Ceux qui devaient repondre a la question EF6 et n'ont pas  repondus" if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40

export excel interview__key HH2 HH12 HH13 EF1 EF6 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF6_NA" if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40,firstrow(varlabels) replace

* Probleme2: ceux qui ont repondus devaient ils repondre 
count if !missing(EF6) & (EF1==2 | AgeAnnee<3 | AgeAnnee>40)

*Problème3: Les valeurs renseignées sont elles permises 
count if !inrange(EF6,1,2)& !missing(EF6)

*Probleme4: Vraisemblance des reponses 
*RAS

*================================
** EF7: Quel est le niveau d’études actuel 
*=================================

* Problème1: Ceux qui devaient repondre ont ils repondu
count if EF6==1 & missing(EF7)
*Une personne identifiée

*identification des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 EF6 EF7 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF7" if EF6==1 & missing(EF7),firstrow(varlabels) replace

	 

* Problème2: Ceux qui ont repondu devaient ils repondre 
count if EF6==2 & !missing(EF7)

* Problème3: Les modalités sont elles permises 
count if !inrange(EF7, 0, 12) & !missing(EF7)

* Problème4: Vraisemblance des reponses 

*1.Le niveau actuel est plus elevé que le niveau d'études declaré 
count if EF7>EF3 & !missing(EF7,EF3)
*221 individus sont dans le cas 


replace commentaire=" 605 personnes dont Le niveau actuel durant l'année encour est plus elevé que le plus haut niveau d'études atteint en général" if EF7>EF3 & !missing(EF7,EF3)

*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF6 EF7 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF7_coh1" if EF7>EF3 & !missing(EF7,EF3),firstrow(varlabels) replace



*Correction
replace EF7=EF3 if EF7>EF3 & !missing(EF7,EF3)

*2.Coherence entre l'age et le niveau actuel
count if AgeAnnee<=3 & EF7>2 & !missing(EF7)


count if AgeAnnee<=10 & EF7>=5 & !missing(EF7)

*=======================================
**EF8:Quelle est la classe actuelle  pour l’année
*=======================================

* Problème1: Ceux qui devaient repondre ont ils repondu
count if missing(EF8) & EF6==1 

*1 personne concernée
*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8" if  missing(EF8) & EF6==1 , firstrow(varlabels) replace


* Problème2: Ceux qui ont repondu devaient ils repondre 
count if !missing(EF8) & EF6==2 

* Problème3: Les modalités sont elles permises 
count if !inrange(EF8, 0, 22) & !missing(EF8)

*RAS 

count if inlist(EF7,1) & !inlist(EF8,1,2,3,.,.a)
*51 individus sont concernés

ta AgeAnnee if inlist(EF7,1) & !inlist(EF8,1,2,3,.,.a)

*br AgeAnnee EF7 EF8 if inlist(EF7,1) & !inlist(EF8,1,2,3,.,.a)
* Le problème ici est que le niveau actuel ne correspond à la classe de l'individu. Ils ont un niveau prescolaire tandis que la classe actuelle est CP1. C'est incoherent. Par ailleurs ils ont pour la plupart un âge entre 5 et 13ans à l'exception de 5 d'entre eux. En l'occurence 4 ont 4ans et un seul a 3ans. La variable à corriger est donc la variable EF7 à laquelle faut faire correspondre le niveau primaire.

replace commentaire ="Le problème ici est que le niveau actuel ne correspond à la classe de l'individu. Ils ont un niveau prescolaire tandis que la classe actuelle est CP1. C'est incoherent. Par ailleurs ils ont pour la plupart un âge entre 5 et 13ans à l'exception de 5 d'entre eux. En l'occurence 4 ont 4ans et un seul a 3ans. La variable à corriger est donc la variable EF7 à laquelle faut faire correspondre le niveau primaire." if inlist(EF7,1) & !inlist(EF8,1,2,3,.,.a)

*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh1" if  inlist(EF7,1) & !inlist(EF8,1,2,.,.a), firstrow(varlabels) replace

*Correction
replace EF7=2 if inlist(EF7,1) & !inlist(EF8,1,2,3,.,.a)

count if inlist(EF7,2) & !inlist(EF8,4,5,6,7,8,9,.,.a) // dephasage entre le niveau declaré et la classe (Niveau primaire)
*65 individus identifiés


*br AgeAnnee EF7 EF8 if inlist(EF7,2) & !inlist(EF8,4,5,6,7,8,9,.,.a)

replace commentaire="dephasage entre le niveau declaré et la classe (Niveau primaire). La reponse donnée en EF7 ne correspond pas avec EF8" if inlist(EF7,2) & !inlist(EF8,4,5,6,7,8,9,.,.a)

*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res rgmen commentaire using "$folderpath/document/Erreur_EF8_coh2" if inlist(EF7,2) & !inlist(EF8,4,5,6,7,8,9,.,.a), firstrow(varlabels) replace

*Correction 
replace EF7=3 if inlist(EF7,2) & !inlist(EF8,4,5,6,7,8,9,.,.a)

count if inlist(EF7,3,4) & !inlist(EF8,10,11,12,13,.,.a)
*38 individus sont concernés  
// dephasage entre le niveau declaré et la classe (Niveau secondaire)


replace commentaire="dephasage entre le niveau declaré et la classe (Niveau secondaire). La reponse donnée en EF7 ne correspond pas avec EF8" if inlist(EF7,3,4) & !inlist(EF8,10,11,12,13,.,.a)


*br AgeAnnee EF7 EF8 if inlist(EF7,3,4) & !inlist(EF8,10,11,12,13,.,.a)
* ils disent etre au Secondaire cycle I alors qu'il sont en classe de seconde

*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen	using "$folderpath/document/Erreur_EF8_coh3" if  inlist(EF7,3,4) & !inlist(EF8,10,11,12,13,.,.a), firstrow(varlabels) replace


*correction
replace EF7=5 if inlist(EF7,3,4) & !inlist(EF8,10,11,12,13,.,.a) & AgeAnnee!=20

replace EF7=6 if inlist(EF7,3,4) & !inlist(EF8,10,11,12,13,.,.a) & AgeAnnee==20


count if inlist(EF7,5,6) & !inlist(EF8,14,15,16,.,.a) // // dephasage entre le niveau declaré et la classe (Niveau secondaire II)
*12 individus sont concernés


replace commentaire="dephasage entre le niveau declaré et la classe (Niveau secondaire II). La reponse donnée en EF7 ne correspond pas avec EF8" if inlist(EF7,5,6) & !inlist(EF8,14,15,16,.,.a)

*br AgeAnnee EF7 EF8 if inlist(EF7,5,6) & !inlist(EF8,14,15,16,.,.a)
* ils disent etre au Secondaire alors qu'il sont en post BAC

*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh4" if  inlist(EF7,5,6) &!inlist(EF8,14,15,16,.,.a), firstrow(varlabels) replace


*correction 
replace EF7=7 if inlist(EF7,5,6) & !inlist(EF8,14,15,16,.,.a) 


count if inlist(EF7,7) & !inlist(EF8,17,18,.,.a)
*3 personnes est concerné


*Identification des agents concernés 
export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF8_coh10" if  inlist(EF7,7) & !inlist(EF8,17,18,.,.a), firstrow(varlabels) replace

count if inlist(EF7,8) & !inlist(EF8,19,.,.a) // // dephasage entre le niveau declaré et la classe (Niveau licence II)
*10 personnes est concerné 


replace commentaire ="dephasage entre le niveau declaré et la classe (Niveau licence II).La reponse donnée en EF7 ne correspond pas avec EF8" if inlist(EF7,8) & !inlist(EF8,19,.,.a) 

export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh5" if inlist(EF7,8) & !inlist(EF8,19,.,.a) , firstrow(varlabels) replace


*br AgeAnnee EF7 EF8 if inlist(EF7,8) & !inlist(EF8,19,.,.a)
* Ils ont un niveau licence et sont dans des classes inferieures pur certains et superieurs pour d'autre 



*Correction
replace EF7=7 if inlist(EF7,8) & !inlist(EF8,19,.,.a) & inlist(EF8,17,18)

replace EF7=10 if inlist(EF7,8) & !inlist(EF8,19,.,.a) & EF8==21

replace EF7=9 if inlist(EF7,8) & !inlist(EF8,19,.,.a) & EF8==20

count if inlist(EF7,9) & !inlist(EF8,20,.,.a) // dephasage entre le niveau declaré et la classe (Niveau Maitrise)
*5 cas 

*1 personne concernée 
*Identification des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_co" if inlist(EF7,9) & !inlist(EF8,20,.,.a) , firstrow(varlabels) replace

*Correction 
replace EF7=8 if inlist(EF7,9) & !inlist(EF8,20,.,.a)


count if inlist(EF7,10) & !inlist(EF8,21,.,.a) //  dephasage entre le niveau declaré et la classe (Niveau Master 2)
*5 individus sont concernés

*3 individus sont concernés 
 


replace commentaire ="dephasage entre le niveau declaré et la classe (Niveau Master 2).La reponse donnée en EF7 ne correspond pas avec EF8" if inlist(EF7,10) & !inlist(EF8,21,.,.a)


*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh10" if inlist(EF7,10) & !inlist(EF8,21,.,.a) , firstrow(varlabels) replace

*br AgeAnnee EF7 EF8 if inlist(EF7,10) & !inlist(EF8,21,.,.a) 


*Correction
replace EF7=11 if inlist(EF7,10) & !inlist(EF8,21,.,.a) &  EF8==22

replace EF7 = 8 if inlist(EF7,10) & inlist(EF8,18,19)
replace EF7 = 9 if inlist(EF7,10) & inlist(EF8,20)
replace EF7=10 if inlist(EF7,9) & !inlist(EF8,20,.,.a)



* Problème4: Vraisemblance des reponses
*1. Age qui cadre pas avec le niveau renseigné
count if AgeAnnee<=3 & EF8>5 & !missing(EF8) & EF6==1 // Il y a  5 enfants d'au plus 3ans qui sont au moins au CP2

*2 individu concerné 

*br EF7 EF8 if AgeAnnee<=3 & EF8>5 & !missing(EF8) & EF6==1 
* ses enfants sont au CE2, CM1, CM2 et 3e . Ce n'est pas normal

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF6 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh4" if  AgeAnnee<=3 & EF8>5 & !missing(EF8) & EF6==1, firstrow(varlabels) replace
 
count if AgeAnnee<=10 & EF8>=14 & EF6==1 & !missing(EF8)
*1 individu est concerné

*4 individus sont concernés  

*2. Mauvais  matching entre le niveau d'etudes et la classe actuelle

count if !inlist(EF7,2,.,.a) & inlist(EF8,4,5,6,7,8,9)
*71 individus sont concernés 

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF6 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh10" if !inlist(EF7,2,.,.a) & inlist(EF8,4,5,6,7,8,9) , firstrow(varlabels) replace

*Coorection
replace EF7=2 if !inlist(EF7,2,.,.a) & inlist(EF8,4,5,6,7,8,9)


count if !inlist(EF7,3,4,.,.a) & inlist(EF8,10,11,12,13)


count if !inlist(EF7,5,6,.,.a) & inlist(EF8,14,15,16)


count if !inlist(EF7,7,.,.a) & inlist(EF8,17,18)
*1 individu est concerné
*RAS

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 EF6 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh10" if !inlist(EF7,7,.,.a) & inlist(EF8,17,18) , firstrow(varlabels) replace

*Correction
*replace EF8=19 if !inlist(EF7,7,.,.a) & inlist(EF8,17,18)

count if !inlist(EF7,8,.,.a) & inlist(EF8,19)
*3 individus est  concerné


*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF6 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh9" if !inlist(EF7,8,.,.a) & inlist(EF8,19) , firstrow(varlabels) replace

*Correction
replace EF8=18 if !inlist(EF7,8,.,.a) & inlist(EF8,19)

count if !inlist(EF7,9,.,.a) & inlist(EF8,20)


count if !inlist(EF7,10,.,.a) & inlist(EF8,21)
*RAS

*Identification des agents ayant fait des erreurs 
/*export excel interview__key HH2 HH12 HH13 EF6 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8_coh11" if !inlist(EF7,10,.,.a) & inlist(EF8,21) , firstrow(varlabels) replace */

*Correction
*replace EF8=20 if !inlist(EF7,10,.,.a) & inlist(EF8,21)

*======================================
**EF9. Pourquoi  a-t-il/elle arrêté les études pour l’année en cours
*=====================================

*Problème1: Ceux qui devaient repondre ont ils repondu
count if EF6==2 & missing(EF9)
*RAS

* Problème2: Ceux qui ont repondu devaient ils repondre 
count if EF6==1 & !missing(EF9)

* Problème3: Les modalités sont elles permises 
count if !inrange(EF9, 1, 20) & !missing(EF9)

* Problème4: Vraisemblance des reponses
*RAS: les variables autres ont été recodées de sorte à correspondre

*===================================
*EF9_Aut: Autres à preciser 
*===================================

*problème 1: CEux qui devaient repondre ont ils repondus 
count if missing(EF9_Aut ) & EF9==20
*RAS

* Problème2: Ceux qui ont repondus devaient ils repondre
count if !missing(EF9_Aut ) & EF9!=20
*RAS


*=======================================
**EF10: Frequetation aau cours de l'an dernier 
*=======================================

* Problème1: Ceux qui devaient repondre ont ils repondus
count if EF1==1 & AgeAnnee >=3 & AgeAnnee <=40 & missing(EF10)
*10 individus sont concernés 

replace commentaire ="Ceux qui devaient repondre à EF10 et n'ont pas repondus" if EF1==1 & AgeAnnee >=3 & AgeAnnee <=40 & missing(EF10) 

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF10 EF9 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF10_NA" if  EF1==1 & AgeAnnee >=3 & AgeAnnee <=40 & missing(EF10) , firstrow(varlabels) replace


* Problème2: Ceux qui ont repondu devaient ils repondre
count if !missing(EF10) & (EF1==2 |AgeAnnee<3 | AgeAnnee >40)

* Problème3 : Les modalités renseignées sont elles permises 
count if !inrange(EF10, 1, 2) & !missing(EF10)

* Problème4 : vraisemblance des reponses 
*Rien à signaler 


*========================================
**EF11: Quel était le niveau d’études durant l’année scolaire précédente 
*========================================
* Problème1: Ceux qui devaient repondre ont ils repondu
count if EF10==1 & missing(EF11)


* Problème2: Ceux qui ont repondu devaient ils repondre 
count if EF10==2 & !missing(EF11)

* Problème3: Les modalités sont elles permises 
count if !inrange(EF10, 1, 12) & !missing(EF10)

* Problème4: Vraisemblance des reponses 

*1.Le niveau d'études actuel ne doit pas exceder le precedent
count  if EF10==1 & EF11>EF7 & !missing(EF11) & !missing(EF7)
*Il y a 35 individus concernés


replace commentaire ="Le niveau d'études actuel ne doit pas exceder le precedent" if EF10==1 & EF11>EF7 & !missing(EF11) & !missing(EF7)

*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF10 EF9 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF10_NA" if  EF10==1 & EF11>EF7 & !missing(EF11) & !missing(EF7) , firstrow(varlabels) replace


*2.Coherence entre l'age et le niveau actuel

count if AgeAnnee<=3 & EF11>2 & !missing(EF11)
*1 individus de 3ans se retrouve au secondaire general I c'est invraisemblable
*RAS

*replace commentaire="individus de 3ans se retrouve au secondaire general I c'est invraisemblable" if AgeAnnee<=3 & EF11>2 & !missing(EF11)

*Identification des Agents ayant fait des erreurs
*export excel interview__key HH2 HH12 HH13 EF10 EF11 AgeAnnee Statut_Res rgmen commentaire  using "$folderpath/document/Erreur_EF11_coh1" if AgeAnnee<=3 & EF11>2 & !missing(EF11), firstrow(varlabels) replace

*Correction
*replace EF11=1 if AgeAnnee<=3 & EF11>2 & !missing(EF11)

count if AgeAnnee<=10 & AgeAnnee>3 & EF11>=5 & !missing(EF11)
*3 individus sont concernés 

*========================================
**EF12.  En quelle classe était durant l’année scolaire précédente
*========================================

* Problème1: Ceux qui devaient repondre ont ils repondu
count if EF10==1 & missing(EF12)
*5 individus sont concernés 

*Identification des agents concernés 
export excel interview__key HH2 HH12 HH13 EF10 EF12 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF12_co" if EF10==1 & EF12>EF8 & !missing(EF12) & !missing(EF8), firstrow(varlabels) replace



* Problème2: Ceux qui ont repondu devaient ils repondre 
count if !missing(EF12) & EF10==2 

* Problème3: Les modalités sont elles permises 
count if !inrange(EF12, 0, 22) & !missing(EF12)

* Problème4: Vraisemblance des reponses

*La classe actuelle ne doit pas exceder la précédente
count if EF10==1 & EF12>EF8 & !missing(EF12) & !missing(EF8)
*11 individus concernés 

replace commentaire="La classe actuelle ne doit pas exceder la précédente" if EF10==1 & EF12>EF8 & !missing(EF12) & !missing(EF8)


*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF10 EF12 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF11_coh1" if EF10==1 & EF12>EF8 & !missing(EF12) & !missing(EF8), firstrow(varlabels) replace

*correction 
replace EF12=EF8-1 if EF10==1 & EF12>EF8 & !missing(EF12) & !missing(EF8) 

*Coherence avec l'age

count if AgeAnnee<=3 & EF12>3 & !missing(EF12)
*8 individus sont concernés

replace commentaire="Individus de moins de 3 ans la classe est au moins CP1." if  AgeAnnee<=3 & EF12>3 & !missing(EF12)

*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12  HH13 EF12 EF11 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF12_coh1" if AgeAnnee<=3 & EF12>3 & !missing(EF12), firstrow(varlabels) replace

count if AgeAnnee<=10 & AgeAnnee>3 & EF12>13 & !missing(EF12)
*3 individus concernés 


*========================================
*EF14: . Quelle est la dernière classe suivie avec succès (passage en classe supérieur) durant l’année précédente
*========================================


* Problème1: Ceux qui devaient repondre ont ils repondu
count  if EF10==1 & missing(EF14)
*2 individuS concernéS

*RAS


* Problème2: Ceux qui ont repondu devaient ils repondre 
count if EF10==2 & !missing(EF14)

* Problème3: Les modalités sont elles permises 
count if !inrange(EF14, 0, 22) & !missing(EF14)

* Problème4: Vraisemblance des reponses


count if EF10==1 & EF14 > EF12 & EF12 != EF14
*291 individus sont concernés


replace commentaire="La classe actuelle année en cours (EF12) ne peut pas être inférieure à la dernière classe réussie l'année précédente sauf en cas de redoublement" if EF10==1 & EF14 > EF12 & EF12 != EF14

*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF12 EF14 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF14_coh1" if EF10==1 & EF14 > EF12 & EF12 != EF14,firstrow(varlabels) replace 

*correction
*replace EF14=EF12 if (EF8==EF12 + 1) & (EF10==1 & EF14 > EF12 & EF12 != EF14)



*Coherence avec l'age

count if AgeAnnee<=3 & EF14>3 & !missing(EF14)
*8 individus sont concernés


replace commentaire="Individus de moins de 3 ans la classe (l'année précédente) est au moins CP1." if AgeAnnee<=3 & EF14>3 & !missing(EF14)


*Identification des Agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF12 EF14 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF14_coh1" if AgeAnnee<=3 & EF14>3 & !missing(EF14),firstrow(varlabels) replace


count if AgeAnnee<=10 & AgeAnnee>3 & EF14>13 & !missing(EF14)
*3 individus sont concernés 

*========================================
**EF15:  a-t-il/elle arrêté les études pour l’année precedente 
*========================================

*Problème1: Ceux qui devaient repondre ont ils repondu
count if EF10==2 & missing(EF15)

* Problème2: Ceux qui ont repondu devaient ils repondre 
count if EF10==1 & !missing(EF15)
*RAS
 
*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 EF12 EF14 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF14_coh1" if AgeAnnee<=3 & EF14>3 & !missing(EF14),firstrow(varlabels) replace

*correction
replace EF15=. if EF10==1 & !missing(EF15)

* Problème3: Les modalités sont elles permises 
count  if !inrange(EF15, 0, 20) & !missing(EF15)

* Problème4: Vraisemblance des reponses
*RAS: les variables autres ont été recodées de sorte à correspondre 


*========================================
*EF15_Aut: AUtres Raisons
*========================================
* Problème1 Ceux qui devaient repondre ont ils repondus
count if missing(EF15_Aut ) & EF15==20
*RAS

* Problème2: Ceux qui ont repondus devaient ils repondre
count if !missing(EF15_Aut ) & EF15!=20


****ALPHABETISATION********


**EF16: 
*1.lecture en langue ivoirienne,francais,Arabe,Anglais, Autre langue

*Problème1: Ceux qui devaient repondre ont ils repondu
foreach var in EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 {
    count if `var' ==.a & AgeAnnee>=15 & !inlist(AgeAnnee,.,.a)
	
	*correction
	replace  `var' =0 if  `var' ==.a & AgeAnnee>=15 & !inlist(AgeAnnee,.,.a)
}


**Identifcation des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF16_1" if missing(EF16A__1, EF16B__1, EF16C__1, EF16D__1, EF16E__1) & AgeAnnee>=15, firstrow(varlabels) replace


* Problème2: Ceux qui ont repondu devaient ils repondre 
foreach var in EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 {
    count if !missing(`var') & AgeAnnee<15
}


* Problème3: Les modalités sont elles permises 
foreach var in EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 {
    count if !inrange(`var', 0, 1) & !missing(`var')
}


*2.Ecriture en langue ivoirienne,francais,Arabe,Anglais, Autre langue

*Problème1: Ceux qui devaient repondre ont ils repondu
foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
    count if `var'==.a & AgeAnnee>=15
}


**Identifcation des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF16_2" if (EF16A__1==.a| EF16B__1==.a |EF16C__1==.a | EF16D__1==.a | EF16E__1 ==.a) & AgeAnnee>=15 & !inlist(AgeAnnee,.,.a), firstrow(varlabels) replace

foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
	*corriger
	replace `var'=0  if `var'==.a & AgeAnnee>=15
}


* Problème2: Ceux qui ont repondu devaient ils repondre 
foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
    count if !missing(`var') & AgeAnnee<15
}


* Problème3: Les modalités sont elles permises 
foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
    count if !inrange(`var', 0, 1) & !missing(`var')
}



*3.comprehension de langue ivoirienne,francais,Arabe,Anglais, Autre langue

*Problème1: Ceux qui devaient repondre ont ils repondu
foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    count if `var'==.a & AgeAnnee>=15 & !inlist(AgeAnnee,.,.a)
}
 

**Identifcation des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF16_1" if (EF16A__3==.a | EF16B__3 ==.a | EF16C__3 ==.a | EF16D__3 ==.a | EF16E__3==.a ) & AgeAnnee>=15, firstrow(varlabels) replace

foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    replace `var'=0 if `var'==.a & AgeAnnee>=15 & !inlist(AgeAnnee,.,.a)
}


* Problème2: Ceux qui ont repondu devaient ils repondre 
foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    count if !missing(`var') & AgeAnnee<15
}


* Problème3: Les modalités sont elles permises 
foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    count if !inrange(`var', 0, 1) & !missing(`var')
}


* Problème4: Vraisemblance des reponses

**Les gens qui sont au moins en 6e doivent en theorie  lire,ecrire et comprendre francais 
 
count  if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15
*19 individus sont concernés

*Identification des agents ayant fait des erreurs 
export excel interview__key HH13 EF17  AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF16_Coherence" if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15, firstrow(varlabels) replace 

*Correction
replace EF16B__1=1 if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15

replace EF16B__2=1 if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15

replace EF16B__3=1 if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15


*===================================
* EF17. Quelle langue parle principalement à la maison ?
*===================================

*Problème1: Ceux qui devaient repondre ont ils repondu
count if missing(EF17) & AgeAnnee>=4 & membre_id_v1=="##N/A##"

*533 individus sont concernés 

replace commentaire="Individus devant repondre a la question EF17(Quelle langue parle principalement à la maison ?) mais non repondu" if missing(EF17) & AgeAnnee>=4 & membre_id_v1=="##N/A##"

*Identifcation des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF17  AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF17_NA" if missing(EF17) & AgeAnnee>=4 & membre_id_v1=="##N/A##", firstrow(varlabels) replace


* Problème2: Ceux qui ont repondu devaient ils repondre 
count if AgeAnnee<4 & !missing(EF17)

* Problème3: Les modalités sont elles permises 
count  if !inrange(EF17, 1, 5) & !missing(EF17)

* Problème4: Vraisemblance des reponses
*Si la langue est parlée à la maison, l'individu doit comprendre la langue au moins. Donc l'incohérence viendra du fait qu'il ait repondu non aux questions EF16A__3, EF16B__3,EF16C__3 alors que c'est la langue principalement parlée à la maison. On s'interesse au francais 

count if !missing(EF17) & EF16B__3==0 & EF17==2
*21 Individus sont concernés // la langue principalement parlée à la maison est le francais mais ils déclarent ne pas comprendre le francais

 

replace commentaire="la langue principalement parlée à la maison est le francais mais ils déclarent ne pas comprendre le francais" if !missing(EF17) & EF16B__3==0 & EF17==2

*Identifcation des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 EF17  AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF17_coh1" if !missing(EF17) & EF16B__3==0 & EF17==2, firstrow(varlabels) replace

*Correction
replace EF16B__3=1 if !missing(EF17) & EF16B__3==0 & EF17==2



*================================
*EF18. Quelle est la langue locale ivoirienne que principalement à la maison 
*================================

*Problème1: Ceux qui devaient repondre ont ils repondu
count if EF17==1 & missing(EF18)

* Problème2: Ceux qui ont repondu devaient ils repondre 
count if EF17==2 & !missing(EF18)

* Problème3: Les modalités sont elles permises 
count if !inrange(EF18, 1, 98) & !missing(EF18)

**Problème4: vraisemblance des reponses 
*Rien à signaler 


drop HH01 HH2A HH2 HH4 HH8 rghab rgmen V1interviewkey HH12 HH13 hh Statut_Res M6_A M7 AgeAnnee commentaire

save"$standard_menage\QM_S2_education_formation.dta", replace
