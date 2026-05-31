*******************************************************************************
*      VERIFICATION ET TRAITEMENT DE LA SECTION "EDUCATION"                   *
*                                                                             *
*       RESPONSABLE : DIABATE BEN ISMAEL                                 *
*
*******************************************************************************

*==============================================================================*
use "$datain_standard\QM_S2_education_formation.dta", clear

merge m:1 interview__key using "$brute_menage_work" , keepus(V1interviewkey rgmen   HH01 HH2 HH12 HH2A HH8 rghab rgmen HH2 HH4 HH13 hh)

keep if _merge == 3
drop  _merge 

merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus( membre_id_v1 AgeAnnee Statut_Res M7 M6_A M4Confirm)
keep if _merge == 3
drop  _merge 

cap drop commentaire
g commentaire=""

*========================================
**** EF1 : a-t-il/elle déjà fréquenté une école ?
*=======================================

**Problème 1: cette instruction permet de voir si tous ceux qui devaient repondre ont repondu 

count if missing(EF1) & AgeAnnee >= 3 & !missing(AgeAnnee) & Statut_Res == 1 
// 339 individus pour qui la variable n'a pas été répondu.

replace commentaire = "Les individus qui devait reponse a EF1 mais n'ont pas repondu" if missing(EF1) & AgeAnnee >= 3 & !missing(AgeAnnee) & Statut_Res == 1 
 
*exportation des individus potentiellement concernées 
count if missing(EF1) & AgeAnnee >= 3 & !missing(AgeAnnee) & Statut_Res == 1 
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF1 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF1_NA" if missing(EF1) & AgeAnnee >= 3 & !missing(AgeAnnee) & Statut_Res == 1 , firstrow(varlabels) replace 
}

**problème 2: Ceux qui ont repondu devaient ils repondre?
count if !missing(EF1) & (AgeAnnee<3 | Statut_Res !=1) 
// RAS 

**problème 3: Valeurs s'écartant des valeurs prevues
count if !inlist(EF1,1,2) & !missing(EF1)
//RAS

 
*=======================================
****EF2 : type d'école a-t-il/elle fréquenté pour la dernière fois
*========================================

**Problème 1 : Ceux qui devaient repondre ont ils repondu
count if missing(EF2) & EF1==1 & membre_id_v1 == "##N/A##" 
// 75 individus n'ont pas réppndu à la question

*exportation des individus potentiellement concernées

replace commentaire="individu pour qui la question EF2 n'a pas été répondu" if missing(EF2) & EF1==1 & membre_id_v1 == "##N/A##"

count if missing(EF2) & EF1==1 & membre_id_v1 == "##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF1 EF2 AgeAnnee Statut_Res membre_id_v1 rgmen using "$folderpath/document/Erreur_EF2_NA" if missing(EF2) & EF1==1 & membre_id_v1 == "##N/A##", firstrow(varlabels) replace
}
*
**problème 2: Ceux qui ont repondus devaient ils repondre?
count if !missing(EF2) & (EF1 !=1 | membre_id_v1 != "##N/A##") 
//RAS

**Problème 3: les valeurs renseignées sont elles permises
count if !inrange(EF2, 1, 4) & !missing(EF2) 
//RAS

*========================================
****EF3 :  le plus haut niveau d'études  atteint ?
*========================================

**Problème1: Tous ceux qui devaient repondre ont ils repondus?
count if missing(EF3) & EF1==1 
// 11 individus pour qui la variable n'a pas été renseignée. 

*exportation des individus potentiellement concernées
replace commentaire="individu pour qui la question EF3 n'a pas été répondu" if missing(EF3) & EF1==1

count if missing(EF3) & EF1==1
if r(N)>0 {
    export excel interview__key HH13 EF1 EF3 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF3_NA" if missing(EF3) & EF1==1, firstrow(varlabels) replace
}

**Problème2: Ceux qui ont repondus devaient ils repondre 
count if !missing(EF3) & EF1!=1 
// RAS
 
**Problème3: les valeurs renseignées sont elles permises
count if !inrange(EF3,0,12) & !missing(EF3)


**Problème 4: Vraisemblance des reponses

count if inrange(EF3,3,12) & AgeAnnee <10 & !missing(AgeAnnee)
// 14 enfants de moins de 10 ans qui sont déjà au moins en classe de 2nd. Ce n'est pas normal.

replace commentaire="14 enfants de moins de 10 ans qui ont atteint un niveau d'étude supérieur au primaire. Ceci semblent inconsistent !" if inrange(EF3,3,12) & AgeAnnee <10 & !missing(AgeAnnee)

*exportation des individus potentiellement concernées

count if inrange(EF3,3,12) & AgeAnnee <10 & !missing(AgeAnnee)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF1 EF3 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF3_vraissenblance" if inrange(EF3,3,12) & AgeAnnee <10 & !missing(AgeAnnee), firstrow(varlabels) replace
}
*

*5. Correction :

// les enfants entre 4 ans et 6 ans ayant fréquenté et qui ont déclaré un niveau supérieur ou égale au sécondaire sont ramenés au primaire avec aucun diplome 

gen EF3_ = EF3

replace EF3=2 if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 
 
replace EF4 = 6 if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_1 = 0 if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_3a = "" if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12))
replace EF4_3 =. if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 
replace EF4_4 =. if (inrange(AgeAnnee,4,6) & EF1==1 & inrange(EF3_,3,12)) 

// les enfants entre 6 ans et 9 ans ayant fréquenté et qui ont déclaré un niveau supérieur ou égale au sécondaire sont ramenés au primaire avec aucun diplome

replace EF3=2 if (inrange(AgeAnnee,7,9) & EF1==1 & inrange(EF3_,3,12)) 
 
replace EF4 = 9 if (inrange(AgeAnnee,7,9) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_1 = 0 if (inrange(AgeAnnee,7,9) & EF1==1 & inrange(EF3_,3,12)) 

replace EF4_3a = "" if (inrange(AgeAnnee,7,9) & EF1==1 & inrange(EF3_,3,12))
replace EF4_3 =. if (inrange(AgeAnnee,7,9) & EF1==1 & inrange(EF3_,3,12)) 
replace EF4_4 =. if (inrange(AgeAnnee,7,9) & EF1==1 & inrange(EF3_,3,12))

cap drop EF3_

*==================================================================
****EF4 : la classe la plus élevée que  a achevé avec succès ?
*==================================================================

**Problème1: Ceux qui devaient repondre ont ils repondu?
count if missing(EF4) & EF1 == 1 & !missing(EF3) 
// 530 individus pour qui la variable EF4 n'a pas été répondu

replace commentaire ="530 individus pour qui la variable EF4 n'a pas été répondu" if missing(EF4) & EF1 == 1 & !missing(EF3)

*exportation des individus potentiellement concernées
count if missing(EF4) & EF1 == 1 & !missing(EF3)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF1 EF3 EF4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_NA" if missing(EF4) & EF1 == 1 & !missing(EF3), firstrow(varlabels) replace
}

**Problème2: ceux qui ont repondu devaient ils repondre
count if !missing(EF4) & (EF1 !=1 | missing(EF3)) 
// RAS

**Problème3: les valeurs renseignées sont prévues
count if !inrange(EF4,0,22) & EF1 == 1 & !missing(EF3) & !missing(EF4)
//RAS 


**Problème4 : Cohérence

count if !inrange(EF4,0,22) & !missing(EF4) 
/// RAS

count if inlist(EF3,1) & !inlist(EF4,1,2,3) & !missing(EF4) 
/// RAS

count if inlist(EF3,2) & !inlist(EF4,0,1,2,3,4,5,6,7,8,9) & !missing(EF4)
/// RAS

count if inlist(EF3,3,4) & !inlist(EF4,9,10,11,12,13) & !missing(EF4)
/// RAS

count if inlist(EF3,5,6) & !inlist(EF4,13,14,15,16) & !missing(EF4) 
/// RAS

count if inlist(EF3,7) & !inlist(EF4,16,17,18) & !missing(EF4) 
/// RAS

count if inlist(EF3,8) & !inlist(EF4,16,17,18,19) & !missing(EF4)
/// RAS

count if inlist(EF3,9) & !inlist(EF4,19,20) & !missing(EF4)
// 8 individu pour qui il y a une incohérence 

count if inlist(EF3,10) & !inlist(EF4,20,21) & !missing(EF4)
// 8 individu pour qui il y a une incohérence 

count if inlist(EF3,11,12) & !inlist(EF4,21,22) & !missing(EF4)
// RAS


*5 Correction :

replace EF4 = 19 if inlist(EF3,9) & !inlist(EF4,19,20) & !missing(EF4)
replace EF4 = 20 if inlist(EF3,10) & !inlist(EF4,20,21) & !missing(EF4)


*=========================================================
** EF4_1 : diplôme le plus élevé obtenu 
*=========================================================

* Problème1: Ceux qui devaient repondre ont ils repondus
count if missing(EF4_1) & !missing(EF4)
br EF4_1 EF4 if missing(EF4_1) & !missing(EF4)
*83 de ceux qui devaient repondre n'ont pas repondu. En realité ce sont des individu qui ont déclaré avoir fait aucune classe et 1 seul a fait la classe de CP1. La correction sera faite dans la partie "Correction"

**Problème2: ceux qui ont repndu etaient ils autorisés à le faire
count if !missing(EF4_1) & missing(EF4)
//RAS

**Problème3: Les valeurs renseignées sont elles permises 
count if !inrange(EF4_1,0,7) & !missing(EF4_1)
//RAS

**Problème4: Cohérence

count if EF4_1 != 0 & EF4 < 9 & !missing(EF4, EF4_1)
//RAS

count if EF4_1 ==1 & !inrange(EF4,9,15) & !missing(EF4, EF4_1)
br EF4_1 EF4 if EF4_1 ==1 & !inrange(EF4,9,15) & !missing(EF4, EF4_1)
//6 individus ayant achevés avec succès la classe de terminale ou le BAC+1 ont choisi le BEPC. Ce n'est pas normal

count if EF4_1 ==2 & !inrange(EF4,13,15) & !missing(EF4, EF4_1)
br EF4_1 EF4 if EF4_1 ==2 & !inrange(EF4,13,15) & !missing(EF4, EF4_1)
//129 individus ayant achevés avec succès la classe de terminale ou le BAC+1 ont choisi le BEPC. Ce n'est pas normal

count if EF4_1 ==3 & !inrange(EF4,16,18) & !missing(EF4, EF4_1)
br EF4_1 EF4 if EF4_1 ==3 & !inrange(EF4,16,18) & !missing(EF4, EF4_1)
//5 individus ayant achevés avec succès le BAC+3 (4) ou le BAC+4 (1) ont choisi le BAC. Ce n'est pas normal

count if EF4_1 ==4 & EF4 !=18 & !missing(EF4, EF4_1)
br EF4_1 EF4 if EF4_1 ==4 & EF4 !=18 & !missing(EF4, EF4_1)
//2 individus ayant achevés avec succès le BAC+3 (1) ou le BAC+4 (1) ont choisi le BTS. Ce n'est pas normal

count if EF4_1 ==5 & !inrange(EF4,19,20) & !missing(EF4, EF4_1)
br EF4_1 EF4 if EF4_1 ==5 & !inrange(EF4,19,20) & !missing(EF4, EF4_1)
//5 individus ayant achevés avec succès le BAC+2 (4) ou le BAC+5 (1) ont choisi le BTS. Nous allons apporter une correction

count if EF4_1 ==6 & !inlist(EF4,21,20) & !missing(EF4, EF4_1)
br EF4_1 EF4 if EF4_1 ==6 & !inlist(EF4,21,20) & !missing(EF4, EF4_1)
//19 individus ayant achevés avec succès le BAC+2, le BAC+3 ou le doctorat comme classe la plus élevé achevé ont choisi le BAC+5 comme diplôme. Nous allons apporter une correction

count if EF4_1 ==7 & !inlist(EF4,22) & !missing(EF4, EF4_1)
//RAS

*5 correction
* Correction des valeurs manquantes
replace EF4_1 = 0 if missing(EF4_1) & !missing(EF4)

replace EF4_1 = 3 if EF4_1 ==1 & !inrange(EF4,9,15) & !missing(EF4, EF4_1)
replace EF4_1 = 3 if EF4_1 ==2 & !inrange(EF4,13,15) & !missing(EF4, EF4_1)
replace EF4_1 = 5 if EF4_1 ==3 & EF4 ==19 & !missing(EF4, EF4_1)
replace EF4_1 = 6 if EF4_1 ==3 & EF4 ==20 & !missing(EF4, EF4_1)
replace EF4_1 = 5 if EF4_1 ==4 & EF4 ==19 & !missing(EF4, EF4_1)
replace EF4_1 = 6 if EF4_1 ==4 & EF4 ==20 & !missing(EF4, EF4_1)
replace EF4_1 = 4 if EF4_1 ==5 & EF4 ==18 & !missing(EF4, EF4_1)
replace EF4_1 = 6 if EF4_1 ==5 & EF4 ==21 & !missing(EF4, EF4_1)
replace EF4_1 = 4 if EF4_1 ==6 & EF4 ==18 & !missing(EF4, EF4_1)
replace EF4_1 = 5 if EF4_1 ==6 & EF4 ==19 & !missing(EF4, EF4_1)
replace EF4_1 = 7 if EF4_1 ==6 & EF4 ==22 & !missing(EF4, EF4_1)


*=============================================================
** EF4_3 : spécialité du diplôme le plus élevé obtenu 
*=============================================================

* Problème1: Ceux qui devaient repondre ont ils tous repondu
count if missing(EF4_3) & EF1==1 & !inlist(EF3,1,2,3) & !missing(EF3) & !inlist(EF4_1,0,1) & !missing(EF4_1)
//7 individus sont concernés
*br if missing(EF4_3) & EF1==1 & !inlist(EF3,1,2,3) & !missing(EF3) & !inlist(EF4_1,0,1) & !missing(EF4_1)


*Identification des agents ayant fait des erreurs 
count if missing(EF4_3) & EF1==1 & !inlist(EF3,1,2,3) & !missing(EF3) & !inlist(EF4_1,0,1) & !missing(EF4_1)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF1 EF4_1 EF4_3 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_3_NA" if missing(EF4_3) & EF1==1 & !inlist(EF3,1,2,3) & !missing(EF3) & !inlist(EF4_1,0,1) & !missing(EF4_1),firstrow(varlabels) replace
}

*Problème2: ceux qui ont repondu devaient ils repondre
count if !missing(EF4_3) & (EF1 !=1 | inlist(EF3,1,2,3) | missing(EF3) | inlist(EF4_1,0,1) | missing(EF4_1))
//RAS

*Problème3: les valeurs renseignées sont elles permises 
count if !inrange(EF4_3, -1, 426) & !missing(EF4_3)
//RAS


*===================================================================
** EF4_4 : année d'obtention du diplôme le plus élevé obtenu 
*===================================================================

* Problème1: Ceux qui devient repondre ont ils repondu
count if missing(EF4_4) & EF4_1 !=0 & !missing(EF4_1)
*br if missing(EF4_4) & EF4_1 !=0 & !missing(EF4_1)
//27 individus sont concernés

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 EF1 EF4_3 EF4_4 AgeAnnee Statut_Res rgmen using "$folderpath/document/Erreur_EF4_4_NA" if missing(EF4_4) & EF4_1 !=0 & !missing(EF4_1),firstrow(varlabels) replace
 

*problème2: ceux qui ont repondu devaient ils repondre
count if !missing(EF4_4) & (EF4_1 ==0 | missing(EF4_1))
//RAS

*Problème3: Les valeurs renseignées sont elles permises
count if (EF4_4<1924 | EF4_4>2026) & !missing(EF4_4) & EF4_4!=9998 
*br EF4_4 if (EF4_4<1924 | EF4_4>2026) & !missing(EF4_4) & EF4_4!=9998 
//40 individus pour qui l'année d'obtention du diplôme est mal saisie. Mais presque la totalité voulait écrire 9998


*Correction
replace EF4_4 = 9998 if (EF4_4<1924 | EF4_4>2026) & !missing(EF4_4) & EF4_4!=9998

*Problème4: Vraisemblance des reponses 


*2. Des personnes dont la date d'obtention du dernier diplome est plus petite que l'année de naissance

count if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998 & !missing(EF4_4)
*25 personnes concernées 

*br EF4_4 M6_A if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998 & !missing(EF4_4)
*25 personnes concernées 

replace commentaire="Des personnes dont la date d'obtention du dernier diplome est plus petite que l'année de naissance" if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998 & !missing(EF4_4)

*Identification des agents ayant fait des erreurs 
count if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998 & !missing(EF4_4)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF1 EF4_3 EF4_4 M6_A AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF4_4_coh2" if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998 & !missing(EF4_4),firstrow(varlabels) replace
}

*Correction
replace EF4_4=.  if EF4_4<=M6_A & !missing(M6_A) & M6_A!=9998


*===================================================================
** EF5 : raisons de l'absence à l'école
*===================================================================

* Problème1 Ceux qui devaient repondre ont ils repondus
count if missing(EF5) & EF1==2
//2 valeurs manquantes

* Problème2: Ceux qui ont repondus devaient ils repondre
count if !missing(EF5) & EF1 !=2 
// RAS

* Problème3: les valeurs renseignées sont elles permises 
count if !inrange(EF5,1,21) & !missing(EF5)
//RAS

*===================================================================
*EF5 autres
*===================================================================

* Problème1 Ceux qui devaient repondre ont ils repondus
count if missing(EF5_AUTRE) & EF5==20
//RAS

* Problème2: Ceux qui ont repondus devaient ils repondre
count if !missing(EF5_AUTRE) & EF5!=20
//RAS


*===================================================================
** EF6 : a-t-il /elle fréquenté l'école à n'importe quel moment durant l'année scolaire 
*===================================================================

* Problème1: Ceux qui devaient repondre ont ils repondus
count if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40
*br if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40
//9 individus sont concernés par cette situation

replace commentaire=" 2 personnes de Ceux qui devaient repondre a la question EF6 et n'ont pas  repondus" if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40

count if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF1 EF6 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF6_NA" if missing(EF6) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40,firstrow(varlabels) replace
}

* Probleme2: ceux qui ont repondus devaient ils repondre 
count if !missing(EF6) & (EF1 !=1 | AgeAnnee<3 | AgeAnnee>40)
//RAS

*Problème3: Les valeurs renseignées sont elles permises 
count if !inrange(EF6,1,2)& !missing(EF6)
//RAS


*===================================================================
** EF7: Quel est le niveau d’études actuel 
*===================================================================

* Problème1: Ceux qui devaient repondre ont ils repondu
count if missing(EF7) & EF6==1 
br if missing(EF7) & EF6==1 
//Une (1) personne identifiée

* Problème2: Ceux qui ont repondu devaient ils repondre 
count if !missing(EF7) & EF6 !=1 
//RAS

* Problème3: Les modalités sont elles permises 
count if !inrange(EF7,1,12) & !missing(EF7)
//RAS

* Problème4: Vraisemblance des reponses 

*1.Le niveau actuel est plus elevé que le niveau d'études declaré 
count if (EF7>EF3) & !missing(EF7,EF3)
*502 individus sont dans le cas 


replace commentaire=" 502 personnes dont Le niveau actuel durant l'année encour est plus elevé que le plus haut niveau d'études atteint en général" if EF7>EF3 & !missing(EF7,EF3)

*Identification des Agents ayant fait des erreurs
count if EF7>EF3 & !missing(EF7,EF3)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF6 EF7 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF7_coh1" if EF7>EF3 & !missing(EF7,EF3),firstrow(varlabels) replace
}



*Correction
replace EF7=EF3 if EF7>EF3 & !missing(EF7,EF3)

*2.Coherence entre l'age et le niveau actuel
count if AgeAnnee<=3 & EF7>2 & !missing(EF7)
//RAS


count if AgeAnnee<=10 & EF7>=5 & !missing(EF7)
*br EF7 AgeAnnee if AgeAnnee<=10 & EF7>=5 & !missing(EF7)
//1 individu de 10 ans affirme être au secondaire second cycle

replace EF7=3 if AgeAnnee<=10 & EF7>=5 & !missing(EF7)

*===================================================================
**EF8:Quelle est la classe actuelle  pour l’année
*===================================================================

* Problème1: Ceux qui devaient repondre ont ils repondu
count if missing(EF8) & EF6==1 
//2 personne concernée

*Identification des agents ayant fait des erreurs 
count if  missing(EF8) & EF6==1 
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF6 EF7 EF8 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF8" if  missing(EF8) & EF6==1 , firstrow(varlabels) replace
}


* Problème2: Ceux qui ont repondu devaient ils repondre 
count if !missing(EF8) & EF6 !=1 
//RAS

* Problème3: Les modalités sont elles permises 
count if !inrange(EF8,0,22) & !missing(EF8)
//RAS 

**Problème4 : Cohérence


count if !inlist(EF7,1) & inlist(EF8,1,2,3) & !missing(EF7)
br EF7 EF8 if !inlist(EF7,1) & inlist(EF8,1,2,3) & !missing(EF7) 
// 17
count if inlist(EF7,1) & !inlist(EF8,1,2,3) & !missing(EF8)
br EF7 EF8 if inlist(EF7,1) & !inlist(EF8,1,2,3) & !missing(EF8) 
// 119
*Correction
replace EF7 = 1 if !inlist(EF7,1) & inlist(EF8,1,2,3) & !missing(EF7)
replace EF7 = 2 if inlist(EF7,1) & inlist(EF8,4,5) & !missing(EF8)
replace EF7 = 0 if inlist(EF7,1) & EF8==0 & !missing(EF8)


count if inlist(EF7,2) & !inrange(EF8,4,9) & !missing(EF8)
br AgeAnnee EF7 EF8 if inlist(EF7,2) & !inrange(EF8,4,9) & !missing(EF8)
// 172
count if !inlist(EF7,2) & inrange(EF8,4,9) & !missing(EF7)
br AgeAnnee EF7 EF8 if !inlist(EF7,2) & inrange(EF8,4,9) & !missing(EF7)
// 65
*Correction
replace EF7 = 2 if !inlist(EF7,2) & inrange(EF8,4,9) & !missing(EF7)
replace EF8 = 6 if inlist(EF7,2) & !inrange(EF8,4,9) & !missing(EF8) & AgeAnnee <10
replace EF7 = 3 if inlist(EF7,2) & !inrange(EF8,4,9) & !missing(EF8) & AgeAnnee >=10


count if inlist(EF7,3,4) & !inrange(EF8,10,13) & !missing(EF8)
br AgeAnnee EF7 EF8 if inlist(EF7,3,4) & !inrange(EF8,10,13) & !missing(EF8)
// 88
count if !inlist(EF7,3,4) & inrange(EF8,10,13) & !missing(EF7)
//RAS
*Correction
replace EF7 = 5 if inlist(EF7,3,4) & !inrange(EF8,10,13) & !missing(EF8)


count if inlist(EF7,5,6) & !inrange(EF8,14,16) & !missing(EF8)
br AgeAnnee EF7 EF8 if inlist(EF7,5,6) & !inrange(EF8,14,16) & !missing(EF8) 
// 22
count if !inlist(EF7,5,6) & inrange(EF8,14,16) & !missing(EF7)
//RAS
*Correction
replace EF7 = 7 if inlist(EF7,5,6) & !inrange(EF8,14,16) & !missing(EF8)


count if inlist(EF7,7) & !inrange(EF8,17,18) & !missing(EF8)
br AgeAnnee EF7 EF8 if inlist(EF7,7) & !inrange(EF8,17,18) & !missing(EF8) 
//2
count if !inlist(EF7,7) & inrange(EF8,17,18) & !missing(EF7)
br AgeAnnee EF7 EF8 if !inlist(EF7,7) & inrange(EF8,17,18) & !missing(EF7)
//8
*Correction
replace EF7 = 8 if inlist(EF7,7) & !inrange(EF8,17,18) & !missing(EF8)
replace EF7 = 7 if !inlist(EF7,7) & inrange(EF8,17,18) & !missing(EF7)
 

count if inlist(EF7,8) & !inlist(EF8,19) & !missing(EF8)
br AgeAnnee EF7 EF8 if inlist(EF7,8) & !inlist(EF8,19) & !missing(EF8)
// 10
count if !inlist(EF7,8) & inlist(EF8,19) & !missing(EF7)
br AgeAnnee EF7 EF8 if !inlist(EF7,8) & inlist(EF8,19) & !missing(EF7)
//4
*Correction
replace EF8 = 19 if inlist(EF7,8) & !inlist(EF8,19) & !missing(EF8)
replace EF7 = 8 if !inlist(EF7,8) & inlist(EF8,19) & !missing(EF7)


count if inlist(EF7,9) & !inlist(EF8,20) & !missing(EF8)
br AgeAnnee EF7 EF8 if inlist(EF7,9) & !inlist(EF8,20) & !missing(EF8)
// 2 individu pour qui il y a incohérence 
count if !inlist(EF7,9) & inlist(EF8,20) & !missing(EF7)
br AgeAnnee EF7 EF8 if !inlist(EF7,9) & inlist(EF8,20) & !missing(EF7)
//3
*Correction
replace EF8 = 20 if inlist(EF7,9) & !inlist(EF8,20) & !missing(EF8)
replace EF7 = 9 if !inlist(EF7,9) & inlist(EF8,20) & !missing(EF7)

count if inlist(EF7,10) & !inlist(EF8,21) & !missing(EF8)
// RAS 
count if !inlist(EF7,10) & inlist(EF8,21) & !missing(EF7)
//RAS

count if inlist(EF7,11,12) & !inlist(EF8,22) & !missing(EF8)
// RAS
count if !inlist(EF7,11,12) & inlist(EF8,22) & !missing(EF7)
//RAS


*===========================================================================
**EF9. Pourquoi  a-t-il/elle arrêté les études pour l’année en cours
*===========================================================================

*Problème1: Ceux qui devaient repondre ont ils repondu
count if EF6==2 & missing(EF9)
//RAS

* Problème2: Ceux qui ont repondu devaient ils repondre 
count if EF6 !=2 & !missing(EF9)
//RAS

* Problème3: Les modalités sont elles permises 
count if !inrange(EF9,1,20) & !missing(EF9)

*Correction
replace EF9 =. if !inrange(EF9,1,20) & !missing(EF9)

*===========================================================================
*EF9_Aut: Autres à preciser 
*===========================================================================

*problème 1: CEux qui devaient repondre ont ils repondus 
count if missing(EF9_Aut ) & EF9==20
//RAS

* Problème2: Ceux qui ont repondus devaient ils repondre
count if !missing(EF9_Aut ) & EF9!=20
//RAS


*=======================================================================================
**EF10: Frequentation au cours de l'an dernier 
*=======================================================================================

*1. Valeurs manquantes
count if missing(EF10) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40
*9 individus n'ont pas repondus 

replace commentaire ="Ceux qui devaient repondre à EF10 et n'ont pas repondus" if missing(EF10) & EF1==1 & AgeAnnee >=3 & AgeAnnee <=40 

*Identification des agents ayant fait des erreurs 
count if missing(EF10) &  EF1==1 & AgeAnnee >=3 & AgeAnnee <=40 
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 AgeAnnee Statut_Res EF1 EF10 commentaire rgmen using "$folderpath/document/Erreur_EF10_NA" if missing(EF10) &  EF1==1 & AgeAnnee >=3 & AgeAnnee <=40 , firstrow(varlabels) replace
}


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(EF10) & (EF1 !=1 | AgeAnnee <3 | AgeAnnee >40)
//RAS 

*3. les valeurs renseignées sont elles permises ?
count if !inrange(EF10, 1, 2) & !missing(EF10)
//RAS


*=======================================================================================
**EF11: Quel était le niveau d’études durant l’année scolaire précédente 
*=======================================================================================

*1. Valeurs manquantes
count if missing(EF11) & EF10==1
*1 individus n'ont pas repondus 

replace commentaire ="Ceux qui devaient repondre à EF11 et n'ont pas repondus" if missing(EF11) & EF10==1 

*Identification des agents ayant fait des erreurs 
count if missing(EF11) & EF10==1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 AgeAnnee Statut_Res EF10 EF11 commentaire rgmen using "$folderpath/document/Erreur_EF11_NA" if missing(EF11) & EF10==1, firstrow(varlabels) replace
}


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(EF11) & EF10 !=1
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inrange(EF11,0,12) & !missing(EF11)
//RAS

*4. Cohérence :
*Ici nous vérifions si le niveau à l'année en cours est supérieur de 2 rang à l'année précédente

gen EF7_New = .
gen EF11_New = .

replace EF7_New = 0 if EF7==0
replace EF7_New = 1 if EF7==1
replace EF7_New = 2 if EF7==2
replace EF7_New = 3 if inlist(EF7,3,4)
replace EF7_New = 4 if inlist(EF7,5,6)
replace EF7_New = 5 if EF7==7
replace EF7_New = 6 if EF7==8
replace EF7_New = 7 if EF7==9
replace EF7_New = 8 if EF7==10
replace EF7_New = 9 if EF7==11
replace EF7_New = 10 if EF7==12

replace EF11_New = 0 if EF11==0
replace EF11_New = 1 if EF11==1
replace EF11_New = 2 if EF11==2
replace EF11_New = 3 if inlist(EF11,3,4)
replace EF11_New = 4 if inlist(EF11,5,6)
replace EF11_New = 5 if EF11==7
replace EF11_New = 6 if EF11==8
replace EF11_New = 7 if EF11==9
replace EF11_New = 8 if EF11==10
replace EF11_New = 9 if EF11==11
replace EF11_New = 10 if EF11==12

count if EF11_New +1 < EF7_New & !missing(EF7_New,EF11_New)
br EF11 EF7 if EF11_New +1 < EF7_New & !missing(EF7_New,EF11_New)
//Il y a une (1) seule incohérence

*correction
replace EF11 = 7 if EF11_New +1 < EF7_New & !missing(EF7_New,EF11_New) & EF11==4

*=======================================================================================
**EF12.  En quelle classe était durant l’année scolaire précédente
*=======================================================================================

*1. Valeurs manquantes
count if missing(EF12) & EF10==1 
//9 individus n'ont pas repondus 

replace commentaire="Il y a ... individus qui n'ont pas repondus à la question EF12" if missing(EF12) & EF10==1

*Exportation des agents concernés par les manquants 
count if missing(EF12) & EF10==1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 AgeAnnee Statut_Res EF10 EF12 using "$folderpath/document/Erreur_EF12" if missing(EF12) & EF10==1, firstrow(varlabels) replace 
}


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(EF12) & EF10 !=1 
//RAS

*3. les valeurs renseignées sont elles permises ?
count if !inlist(EF12,0,22) & !missing(EF12) & EF10==1 
//RAS

*4. Cohérence :

*Cohérence entre la classe la plus élevée de l'année en cours (EF8) et celle de l'année précédente (EF12)
count if (EF8 > EF12 +1) & !missing(EF8,EF12)
br EF8 EF12 if (EF8 > EF12 +1) & !missing(EF8,EF12)

*5. Correction :
replace EF12 = EF8-1 if (EF8 > EF12 +1) & !missing(EF8,EF12)

*=======================================================================================
*EF14: . Quelle est la dernière classe suivie avec succès (passage en classe supérieur) durant l’année précédente
*=======================================================================================

*1. Valeurs manquantes
count if missing(EF14) & EF10 ==1
//3 individus n'ont pas repondus 

replace commentaire="Il y a 3 individus qui n'ont pas repondus à la question EF14" if missing(EF14) & EF10==1

*Exportation des agents concernés par les manquants 
count if missing(EF14) & EF10==1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 AgeAnnee Statut_Res EF10 EF14 using "$folderpath/document/Erreur_EF14" if missing(EF14) & EF10==1, firstrow(varlabels) replace 
}


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(EF14) & EF10 !=1 
//RAS 

*3. Vraisemblance : les valeurs renseignées sont elles permises ?
count if !inlist(EF14,0,22) & EF10 ==1 & !missing(EF14)
//RAS

*4. Cohérence :

*Cohérence entre F12 et F14 : Vérifier si la classe faite l'année précédente est différente de celle validée l'année précédente
count if (EF12> EF14 +1) & !missing(EF12,EF14)
//223
count if (EF12 < EF14) & !missing(EF12,EF14)
//62

*5. Correction :

replace EF14 = EF12 if (EF12 < EF14) & !missing(EF12,EF14)
replace EF14 = EF12 -1 if (EF12> EF14 +1) & !missing(EF12,EF14)

*=======================================================================================
**EF15:  a-t-il/elle arrêté les études pour l’année precedente 
*=======================================================================================


*1. Valeurs manquantes
count if missing(EF15) & EF10 ==2
//RAS 

*replace commentaire="Il y a ... individus qui n'ont pas repondus à la question EF15" if missing(EF15) & EF10==2

*Exportation des agents concernés par les manquants 
*export excel interview__key HH2 HH12 HH13 AgeAnnee Statut_Res EF10 EF15 using "$folderpath/document/Erreur_EF15" if missing(EF15) & EF10==2, firstrow(varlabels) replace 


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(EF15) & EF10 !=2 
//RAS

*3. Vraisemblance : les valeurs renseignées sont elles permises ?
count if !inlist(EF15,1,20) & !missing(EF15)
//RAS

*=======================================================================================
*EF15_Aut: AUtres Raisons
*=======================================================================================
*1. Valeurs manquantes
count if missing(EF15_Aut ) & EF15==20
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(EF15_Aut ) & EF15!=20
//RAS 


*************ALPHABETISTION**************



*=======================================================================================
*EF16: 
*=======================================================================================

**EF16: 
*1.lecture en langue ivoirienne,francais,Arabe,Anglais, Autre langue

*Problème1: Ceux qui devaient repondre ont ils repondu
foreach var in EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 {
    count if `var' ==.a & AgeAnnee>=15 & !missing(AgeAnnee)
}


**Identifcation des agents ayant fait des erreurs 
count if missing(EF16A__1, EF16B__1, EF16C__1, EF16D__1, EF16E__1) & AgeAnnee>=15 & !missing(AgeAnnee)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF16_1" if missing(EF16A__1, EF16B__1, EF16C__1, EF16D__1, EF16E__1) & AgeAnnee>=15 & !missing(AgeAnnee), firstrow(varlabels) replace
}

foreach var in EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 {
    *correction
    replace `var'=0 if `var'==.a & AgeAnnee>=15 & !missing(AgeAnnee)
}


* Problème2: Ceux qui ont repondu devaient ils repondre 
foreach var in EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 {
    count if !missing(`var') & AgeAnnee<15
}
//RAS

* Problème3: Les modalités sont elles permises 
foreach var in EF16A__1 EF16B__1 EF16C__1 EF16D__1 EF16E__1 {
    count if !inrange(`var', 0, 1) & !missing(`var')
}

//RAS

*2.Ecriture en langue ivoirienne,francais,Arabe,Anglais, Autre langue

*Problème1: Ceux qui devaient repondre ont ils repondu
foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
    count if `var'==.a & AgeAnnee>=15 & !missing(AgeAnnee)
}


**Identifcation des agents ayant fait des erreurs 
count if missing(EF16A__2, EF16B__2, EF16C__2, EF16D__2, EF16E__2) & AgeAnnee>=15 & !missing(AgeAnnee)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF16_2" if missing(EF16A__2, EF16B__2, EF16C__2, EF16D__2, EF16E__2) & AgeAnnee>=15 & !missing(AgeAnnee), firstrow(varlabels) replace
}

foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
	*corriger
	replace `var'=0 if `var'==.a & AgeAnnee>=15 & !missing(AgeAnnee)
}


* Problème2: Ceux qui ont repondu devaient ils repondre 
foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
    count if !missing(`var') & AgeAnnee<15
}
//RAS

* Problème3: Les modalités sont elles permises 
foreach var in EF16A__2 EF16B__2 EF16C__2 EF16D__2 EF16E__2 {
    count if !inrange(`var', 0, 1) & !missing(`var')
}
//RAS


*3.comprehension de langue ivoirienne,francais,Arabe,Anglais, Autre langue

*Problème1: Ceux qui devaient repondre ont ils repondu
foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    count if `var'==.a & AgeAnnee>=15 & !missing(AgeAnnee)
}
 

**Identifcation des agents ayant fait des erreurs 
count if missing(EF16A__3, EF16B__3, EF16C__3, EF16D__3, EF16E__3) & AgeAnnee>=15 & !missing(AgeAnnee)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF16_3" if missing(EF16A__3, EF16B__3, EF16C__3, EF16D__3, EF16E__3) & AgeAnnee>=15 & !missing(AgeAnnee), firstrow(varlabels) replace
}

foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    replace `var'=0 if `var'==.a & AgeAnnee>=15 & !missing(AgeAnnee)
}


* Problème2: Ceux qui ont repondu devaient ils repondre 
foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    count if !missing(`var') & AgeAnnee<15
}
//RAS

* Problème3: Les modalités sont elles permises 
foreach var in EF16A__3 EF16B__3 EF16C__3 EF16D__3 EF16E__3 {
    count if !inrange(`var', 0, 1) & !missing(`var')
}
//RAS

* Problème4: Vraisemblance des reponses

**Les gens qui sont au moins en 6e doivent en theorie  lire,ecrire et comprendre francais 
 
count if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15 & !missing(AgeAnnee)
*34 individus sont concernés

*Identification des agents ayant fait des erreurs 
if r(N)>0 {
    export excel interview__key HH13 EF17 AgeAnnee Statut_Res using "$folderpath/document/Erreur_EF16_Coherence" if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15 & !missing(AgeAnnee), firstrow(varlabels) replace
}

*Correction
replace EF16B__1=1 if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15

replace EF16B__2=1 if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15

replace EF16B__3=1 if EF8>9 & (EF16B__1==0 | EF16B__2==0 | EF16B__3==0) & !missing(EF8) & AgeAnnee>=15



*=======================================================================================
* EF17. Quelle langue parle principalement à la maison ?
*=======================================================================================

*1. Valeurs manquantes
count if missing(EF17) & AgeAnnee>=4 & membre_id_v1=="##N/A##" & !missing(AgeAnnee)
*224 individus sont concernés 

replace commentaire="Individus devant repondre a la question EF17(Quelle langue parle principalement à la maison ?) mais non repondu" if missing(EF17) & AgeAnnee>=4 & membre_id_v1=="##N/A##"

*Identifcation des agents ayant fait des erreurs 
count if missing(EF17) & AgeAnnee>=4 & membre_id_v1=="##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 EF17  AgeAnnee Statut_Res commentaire rgmen using "$folderpath/document/Erreur_EF17_NA" if missing(EF17) & AgeAnnee>=4 & membre_id_v1=="##N/A##", firstrow(varlabels) replace
}


*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if !missing(EF17) & (AgeAnnee <4 | membre_id_v1 !="##N/A##")
//RAS

*3. Les valeurs renseignées sont elles permises ? 
count  if !inrange(EF17,1,5) & !missing(EF17)
//RAS

*=======================================================================================
*EF18. Quelle est la langue locale ivoirienne que principalement à la maison 
*=======================================================================================

*1. Valeurs manquantes
count if EF17==1 & missing(EF18)
//RAS

*2. Vérification des sauts : Ceux qui ont repondu devaient ils repondre ? 
count if EF17 !=1 & !missing(EF18)
//RAS

*3. les valeurs renseignées sont elles permises ? 
count if !inrange(EF18,1,89) & !missing(EF18) & EF18 !=98
//RAS

drop HH01 HH2A HH2 HH4 HH8 rghab rgmen V1interviewkey HH12 HH13 hh Statut_Res M6_A M7 AgeAnnee commentaire

save"$standard_menage\QM_S2_education_formation.dta", replace
