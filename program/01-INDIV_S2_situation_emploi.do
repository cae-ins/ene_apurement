*================================================
*********SITUATION EMPLOI

****RESPONSABLE: AMINE
*=============================================
**********Importation 
*global datain_brute "C:\apurement_ENE\bases"
*display "$datain_brute"

use "$datain_standard\INDIV_S2_situation_emploi.dta", clear
 
*****Appel des autres variables 

merge 1:1 interview__key membres__id  using "$datain_standard\QM_S1_composition_menage.dta", keepus(AgeAnnee Statut_Res ) 

keep if _merge == 3
drop  _merge

merge m:1 interview__key  using "$datain_standard\QM_S0_identification.dta", keepusing(HH13 HH12 MODINTR )

keep if _merge == 3
drop  _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)

keep if _merge == 3
drop  _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP  ) 

keep if _merge == 3
drop  _merge

*merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S15_disponibilite.dta", keepus(membre_id_v1 membre_id_v1_IND )

*keep if _merge == 3
*drop  _merge


**************Fin appel de variables*****************

*drop if Statut_Res != 1
/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
///////////////////////////////////////////////////////////////////////////
******SE1
***Etape1: Valeurs manquantes et corrrection
count if missing(SE1) & M4Confirm>=15 & !inlist(M4Confirm, ., .a) // 18 cas

*br if missing(SE1) & M4Confirm>=15 & !inlist(M4Confirm, ., .a)


* Exporter ces individus

if r(N) > 0 {
export excel interview__key HH13  SE1 M4Confirm using  "$folderpath/document/SE1" if missing(SE1) & M4Confirm>=15 & !inlist(M4Confirm, ., .a),firstrow(variables) replace
}
* Correction: Imputer SE1 en utilisant les réponses à la question suivantes SE2
 
*replace SE1 = 1 if SE1==.a & missing(SE2)

replace SE1 = 2 if missing(SE1) & !missing(SE2) & !inlist(SE2,.,.a)

***Etape2: coherence des sauts
count if !missing(SE1) & M4Confirm<15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues: RAS
count if !inrange(SE1,1,2) & !missing(SE1)


***Etape4: Vraisemblance 

********SE2
***Etape1: Valeurs manquantes 
count if missing(SE2) & SE1 == 2 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) // Une valeur manquante

**Exportation
if r(N) > 0 {
export excel interview__key SE1 SE2 SE3 HH12 HH13  using "$folderpath/document/SE2_Manquants" if missing(SE2) & SE1 == 2 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a), firstrow(variables) replace
}
**Correction: Impossible de corriger (la valeur de est aussi manquante au T2)
*replace SE2==

*br interview__key SE1 SE2 SE3 HH12 HH13 if missing(SE2) & SE1 == 2 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)


***Etape2: coherence des sauts
count if !missing(SE2) & SE1 ==1
***Etape3: Coherence des reponses attendues RAS
count if !(inrange(SE2, 1, 10)) & !missing(SE2)
***Etape4: vraisemblance 

**************SE3
***Etape1: Valeurs manquantes et corrrection
count if missing(SE3) & SE2 == 10 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)
*export excel interview__key HH13 SE3  using "$folderpath/document/SE3" if missing(SE3) & SE2 == 10 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a), firstrow(variables) replace

***Etape2: coherence des sauts
count if !missing(SE3) & SE2 != 10
count if !missing(SE3) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)

***Etape3: Coherence des reponses attendues RAS
count if !inrange(SE3,1,5) & !missing(SE3)



* Répéter pour SE4, SE5, SE6, SE7, SE8, SE9, SE10, et SE11
****SE4
***Etape1: Valeurs manquantes et corrrection
count if missing(SE4) & inlist(SE3,3,4,5) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)

***Etape2: coherence des sauts
count if !missing(SE4) & !inlist(SE3,3,4,5)
count if !missing(SE4) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)

***Etape3: Coherence des reponses attendues RAS
count if !missing(SE4) & !inlist(SE4,1,2)

*Etape4:  Verifier si des individus n'ont pas travaillés pour une activité remunérée au cours de la semaine SE2 et affirment avoir effectué une activité économique, agricole ou une autre activité pour générer un revenu, même si cela n’a duré qu’une heure ? SE4
count if !missing(SE4) & SE2!=10 
*br SE1 SE4 if !missing(SE4) & SE2!=10 


*****SE5
***Etape1: Valeurs manquantes et corrrection
count if missing(SE5) & SE4 ==2 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)

***Correction des valeurs manquantes
**On ne peut corriger cette valeur manquante 

***Etape2: coherence des sauts
count if !missing(SE5) & SE4 != 2
count if !missing(SE5) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues RAS
count if !missing(SE5) & !inlist(SE5,1,2)
***Etape 4: Vraisemblancce 

*****SE6
*****Etape1: Valeurs manquantes 
count if missing(SE6) & inlist(SE5, 1) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)
***Etape2: coherence des sauts
count if !missing(SE6) & SE5 != 1
count if !missing(SE6) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponse s attendues RAS
count if !missing(SE6) & !inrange(SE6,1,2)
****Etape4: Vraisemblance
*Verifier voir si des individus ont repondu faire une activité en rapport avec l'agriculture a la question SE2 et affirment a la question SE6 ne pas avoir fait une activité agricole 
count if SE6 == 1 & inlist(SE2,2,9)

*****SE7
*****Etape1: Valeurs manquantes 
count if missing(SE7) & inlist(SE5, 1) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)

***Etape2: coherence des sauts
count if !missing(SE7) & SE5 != 1
count if !missing(SE7) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues RAS
count if !missing(SE7) & !inrange(SE7,1,4) 

*******SE8
***Etape1: Valeurs manquantes et corrrection
count if missing(SE8) & (SE5== 2 | inlist(SE7,3,4)) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) 

**Exportation:
if r(N) > 0 {
export excel interview__key HH13 SE8  using "$folderpath/document/SE8" if missing(SE8) & (SE5== 2 | inlist(SE7,3,4)) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) , firstrow(variables) replace
}

*correction: Impossible de corriger (la valeur de est aussi manquante au T2)
*replace SE8=1 if !missing(SE9) ///RAS

*br SE8 if missing(SE8) & (SE5== 2 | inlist(SE7,3,4)) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) 

 
***Etape2: coherence des sauts
count if !missing(SE8) & SE5!= 2 & !inlist(SE7,3,4)
count if !missing(SE8) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues
count if !missing(SE8) & !inrange(SE8,1,2) 


****SE9 
*****Etape1: Valeurs manquantes 
count if missing(SE9) & inlist(SE8, 1) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)

***Etape2: coherence des sauts
count if !missing(SE9) & SE8 != 1
count if !missing(SE9) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues RAS
count if !missing(SE9) & !inrange(SE9,1,17) 


**** SE9A
***Etape1: Valeurs manquantes et corrrection
count if missing(SE9A) & !inlist(SE9,1,2,3,4) & inlist(SE9,10) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)

***Etape2: coherence des sauts
count if !missing(SE9A) & inlist(SE9,1,2,3,4) & inlist(SE9,10) 
count if !missing(SE9A) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues 
count if !missing(SE9A) & !inrange(SE9A,1,2) 

**** SE9B
***Etape1: Valeurs manquantes et corrrection
count if missing(SE9B) & !inlist(SE9,1,2,3,4) & SE9 == 14 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)
***Etape2: coherence des sauts
count if !missing(SE9B) & inlist(SE9,1,2,3,4) & !inlist(SE9,14) 
count if !missing(SE9B) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues 
count if !missing(SE9B) & !inrange(SE9B,1,2) 

**** SE10
***Etape1: Valeurs manquantes et corrrection
count if missing(SE10) & ( inlist(SE9,5,6,7,8,9,11,12,15,16,17) | (SE9A == 2| (SE9==14 & SE9B == 2)) ) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) 
***Etape2: coherence des sauts
count if !missing(SE10) & !inlist(SE9,5,6,7,8,9,11,12,15,16,17,.,.a) &  (SE9A == 1 & (!inlist(SE9,14,.,.a) ))
count if !missing(SE10) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues  
count if !missing(SE10) & !inrange(SE10,1,2) & SE10!=9998
**** SE11
***Etape1: Valeurs manquantes et corrrection
count if missing(SE11) & inlist(SE10,2,9998) & M4Confirm >= 15 & !inlist(M4Confirm, ., .a)
***Etape2: coherence des sauts
count if !missing(SE11) & !inlist(SE10,2,9998) 
count if !missing(SE11) & M4Confirm < 15 & !inlist(M4Confirm, ., .a)
***Etape3: Coherence des reponses attendues 
count if !missing(SE11) & !inrange(SE11,1,2) 
****Etape4: Verification de la vraisemblance des reponses:


drop  Statut_Res AgeAnnee HH12 HH13 MODINTR M4Confirm EN_EMP

*drop membre_id_v1_IND

save "$standard_individu\INDIV_S2_situation_emploi.dta", replace