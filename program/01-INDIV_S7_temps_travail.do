
*********TEMPS DE TRAVAIL

****RESPONSABLE: SEKONGO
*=============================================
use "$datain_standard\INDIV_S7_temps_travail.dta", clear

****************
*****Appel des autres variables 

merge m:1 interview__key  using "$datain_standard\QM_S0_identification.dta", keepusing(HH13 HH12 )

keep if _merge == 3
drop  _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)

keep if _merge == 3
drop  _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP EP11  EP3) 

keep if _merge == 3
drop  _merge

*merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)


keep if _merge == 3
drop  _merge



merge 1:1 interview__key membres__id  using "$standard_individu\INDIV_S2_situation_emploi.dta", keepus( SE8)

keep if _merge == 3
drop  _merge


merge 1:1 interview__key membres__id  using "$standard_individu\INDIV_S5_pluriactivite.dta", keepus( PL1 PL2 PL3)

keep if _merge == 3
drop  _merge



*****************------------------------

///////////////SECTION TEMPS DE TRAVAIL///////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
///////////////////////////////////////////////////////////////////////////


//// *WKT1. Combien d’heures travaillez-vous habituellement par semaine dans votre emploi principal ?



***//////////////Etape1: Valeurs manquantes 
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT1) & !inlist(M4Confirm,.,.a) 

if r(N) > 0 {
export excel interview__key HH13 WKT1  using "$folderpath/document/E_WKT1_0.xlsx" if  EN_EMP == 1 & M4Confirm >= 15 & missing(WKT1) ,firstrow(variables) replace
}

**Correction (des vrais manquants):

   *** imputation par la mediane croisant Métier (CITP) et Secteur (Branche)
cap drop med_WKT1
egen med_WKT1 = median(WKT1) if !missing(EP3) & !missing(EP11), by(EP3 EP11 code_citp_emp_principal branche1)

* Si la médiane par métier/secteur est vide, on utilise une médiane plus large (Secteur uniquement)
cap drop med_WKT1_large
egen med_WKT1_large = median(WKT1) if !missing(EP3) & !missing(EP11), by(EP3 EP11 branche1)

replace WKT1 = med_WKT1 if missing(WKT1) & !missing(med_WKT1)
replace WKT1 = med_WKT1_large if missing(WKT1) & !missing(med_WKT1_large)


*replace WKT1 =.a if interview__key == "40-68-68-30" & membres__id == 1 // pour cet individu, toutes la section emploi est manquantes donc nous renvoyons sa valeurs WKT1 à une valeurs manquantes 


**Correction: RAS, la section est manquante pour ces individus

***////////////////Etape2: coherence des sauts
count if !missing(WKT1) & (EN_EMP == 0 |(M4Confirm<15 & !inlist(M4Confirm, ., .a))) // RAS car il s'agit des personnes qui n'était pas en emploi et qui ont été identifié dans la section emploi principal

*correction 
replace WKT1 =. if !missing(WKT1) & (EN_EMP == 0 |(M4Confirm<15 & !inlist(M4Confirm, ., .a)))


***Etape3: Coherence des reponses attendues 
count if !missing(WKT1) & WKT1==0 
*RAS

count if !missing(WKT1) & WKT1>168 & WKT1!=9998

*br EP3 EP11 WKT1 if !missing(WKT1) & WKT1==0
*exportation des individus concernées

if r(N) > 0 {
export excel interview__key HH13 WKT1  using "$folderpath/document/E_WKT1_Coherences.xlsx" if !missing(WKT1) & WKT1==0 ,firstrow(variables) replace
}
**Les individus ayant pour valeur 0 n'a pas aussi repondu aux autres question de la section, on affecte la valeur . à ces individus pour cette question 

*** Etape4: Vraisemblance 


////*WKT2. Combien de jours par semaine travaillez-vous habituellement dans votre emploi principal ?
***Etape1: Valeurs manquantes et corrrection

count if missing(WKT2) & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & EN_EMP==1 & WKT1 ==9998  

***COrrection: imputation par la mediane 

	*************Generalisation
cap drop med_WKT2
egen med_WKT2 = median(WKT2), by(EP3 EP11)
*egen med_WKT2 = median(WKT2), by(EP3 EP11 code_citp_emp_principal)

replace WKT2 = med_WKT2 if WKT2 == .a
cap drop med_WKT2


***Etape2: coherence des sauts

count if !missing(WKT2) & ( M4Confirm < 15 | EN_EMP==0 | (!inlist(WKT1,9998,.,.a)))

replace WKT2=. if !missing(WKT2) & ( M4Confirm < 15 | EN_EMP==0 | (!inlist(WKT1,9998,.,.a)))

***Etape3: Coherence des reponses attendues 
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT2) &  WKT1 == 9998 & WKT2 > 7

count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT2) &  WKT1 == 9998 & WKT2 <= 0 

*WKT3. Combien d’heures par jour travaillez-vous habituellement dans votre emploi principal ?

***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT3) &  WKT1 == 9998 & !inlist(M4Confirm,.,.a) 

   ***Correction: imputation par la mediane 

	*************Generalisation
cap drop med_WKT3
egen med_WKT3 = median(WKT3), by(EP3 EP11 )
*egen med_WKT3 = median(WKT3), by(EP3 EP11 code_citp_emp_principal)

replace WKT3 = med_WKT3 if WKT3 == .a
cap drop med_WKT3


***Etape2: coherence des sauts
count if !missing(WKT3) & (EN_EMP==0 | M4Confirm < 15 | WKT1 != 9998 )


***Etape3: Coherence des reponses attendues
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT3) &  WKT1 == 9998 & WKT3 > 24
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT3) &  WKT1 == 9998 & WKT3 <= 0 
***Etape4: Vraisemblance 

*WKT4. Pour la semaine allant du %DateJ7% au %DateJ0% , avez-vous eu des absences ou pris congé de votre emploi principal pour une raison quelconque, par exemple, vacances, maladie, raisons familiales ?

***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT4) & !inlist(M4Confirm,.,.a) 

if r(N) > 0 {
export excel interview__key HH13 WKT4  using "$folderpath/document/WKT4_Manquants.xlsx" if EN_EMP==1 & M4Confirm >= 15 & missing(WKT4) & !inlist(M4Confirm,.,.a), firstrow(variables) replace
}

*Correction:

*replace WKT4 = 1 if (EN_EMP==1 & M4Confirm >= 15 & missing(WKT4) & !inlist(M4Confirm,.,.a))& !missing(WKT4A)

***Etape2: coherence des sauts

count if !missing(WKT4) & (EN_EMP == 0 | M4Confirm < 15 ) // RAS comme plus haut, il s'agit en réalité d'individu n'étant pas en emploi

replace WKT4=. if !missing(WKT4) & (EN_EMP == 0 | M4Confirm < 15 )

***Etape3: Coherence des reponses attendues 

***Etape4: vraisemblance des reponses 


*WKT4A.Pour la semaine allant du %DateJ7% au %DateJ0% , combien d’heures d’absence avez-vous cumulées dans votre emploi principal ?

***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT4A) & WKT4==1 // 1 personnes pour qui la question n'a pas été répondu

*exportation des individus concernées
if r(N) > 0 {
export excel interview__key HH13 WKT4 WKT4A using "$folderpath/document/WKT4A.xlsx" if EN_EMP==1 & M4Confirm >= 15 & missing(WKT4A) & WKT4==1, firstrow(variables) replace
}


***Etape2: cohérence des sauts
count if !missing(WKT4A) &  WKT4 != 1

***Etape3: Coherence des reponses attendues
count if !missing(WKT4A) & WKT4A <= 0 & WKT4==1 //le nombre d'heures ne peut etre nul

if r(N) > 0 {
export excel interview__key HH13 EP11 EP3  WKT4 WKT4A using "$folderpath/document/WKT4A_0.xlsx" if !missing(WKT4A) & WKT4A <= 0 & WKT4==1 ,firstrow(variables) replace
}

*proposition de correction

replace WKT4=0 if !missing(WKT4A) & WKT4A <= 0 & WKT4==1
replace WKT4A=. if WKT4==0

/*
cap drop med_WKT4A_1
egen med_WKT4A_1 = median(WKT4A) if !missing(WKT4A) & WKT4A > 0 & inlist(EP3,EP11)
replace WKT4A = med_WKT4A_1 if !missing(WKT4A) & WKT4A <= 0 & WKT4==1
drop med_WKT4A_1
*/

/*
replace WKT4A = med_WKT4A_1 if !missing(WKT4A) & WKT4A <=0 & inlist(EP3,1,10)

cap drop med_WKT4A_2
egen med_WKT4A_2 = median(WKT4A) if !missing(WKT4A) & WKT4A > 0 & inlist(EP3,3)

replace WKT4A = 24 if !missing(WKT4A) & WKT4A <=0 & inlist(EP3,3)

cap drop med_WKT4A_3
egen med_WKT4A_3 = median(WKT4A) if !missing(WKT4A) & WKT4A > 0 & inlist(EP3,5)

replace WKT4A = 30 if !missing(WKT4A) & WKT4A <=0 & inlist(EP3,5)

drop med_WKT4A_1 med_WKT4A_2 med_WKT4A_3

replace WKT4A =. if !missing(WKT4A) & WKT4A <= 0
*/
*** Etape4: Vraisemblance


*WKT5. Pour la semaine allant du %DateJ7% au %DateJ0% , y a-t-il eu des jours où vous avez travaillé plus que d’habitude ou des heures supplémentaires dans votre emploi principal, rémunéré ou non ?

***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT5) 

if r(N) > 0 {
export excel interview__key HH13 WKT5  using "$folderpath/document/WKT5.xlsx" if EN_EMP==1 & M4Confirm >= 15 & missing(WKT5), replace firstrow(variables)
}

***Correction:  necessite de revenir aux agents 

*replace WKT5 = 1 if (EN_EMP==1 & M4Confirm >= 15 & missing(WKT5) )& !missing(WKT6)

***Etape2: coherence des sauts
count if !missing(WKT5) & (EN_EMP==0 | M4Confirm < 15) // RAS comme mentionné plus haut, il s'agit d'individus qui ne sont pas en emploi en réalité

replace WKT5=. if !missing(WKT5) & (EN_EMP==0 | M4Confirm < 15)

***Etape3: Coherence des reponses attendues RAS
count if !missing(WKT5) & !inrange(WKT5,1,2) 

***Etape4 : Vraisemblance


*WKT6. Pour la semaine allant du %DateJ7% au %DateJ0% , combien d’heures supplémentaires avez-vous travaillé dans votre emploi principal ?
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing(WKT6) & WKT5 == 1

***Etape2: coherence des sauts
count if (EN_EMP==0 | M4Confirm < 15 |   WKT5 != 1) & !missing(WKT6) 
***Etape3: Coherence des reponses attendues RAS
count if !missing(WKT6) & WKT6<=0 // RAS

* WKT7 : Heures habituelles travaillées la semaine dernière
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing( WKT7) &  WKT5==2 & WKT4==2

********Correction: 

cap drop med_WKT7
egen med_WKT7 = median(WKT7), by(EP3 EP11)
replace WKT7 = med_WKT7 if WKT7 ==.a
cap drop med_WKT7


***Etape2: coherence des sauts
count if !missing( WKT7) & (EN_EMP==0 | M4Confirm < 15 |  WKT5!=2 | WKT4!=2) // comme plus haut il s'agit des personnes n'étant pas en emploi

replace WKT7 =. if !missing( WKT7) & (EN_EMP==0 | M4Confirm < 15 |  WKT5!=2 | WKT4!=2)

***Etape3: Coherence des reponses attendues
count if !missing(WKT7) & !inrange(WKT7,1,2) 

 *WKT7A. Nombre d'heure travaillées pour la semaine allant du %DateJ7% au %DateJ0% ?
 ***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing( WKT7A) & WKT7==2
***Etape2: coherence des sauts
count if  !missing(WKT7A) & WKT4==1
***Etape3: Coherence des reponses attendues

count if !missing(WKT7A) & WKT7A <=0  & WKT7==1 // 0 personnes declarant 0 heures alors quelles ont mentionnées ne pas avoir été absent

*exportation des individus potentiellement concernées 

if r(N) > 0 {
export excel interview__key HH13 WKT4  WKT5 WKT7 WKT7A using "$folderpath/document/WKT.7Axlsx" if !missing(WKT7A) & WKT7A <=0 ,firstrow(variables) replace

}

*Correction : Imputation par la mediane

*br WKT4  WKT5 WKT7 WKT7A EP3 EP11 if !missing(WKT7A) & WKT7A <=0 

cap drop med_WKT7A_1
*egen  med_WKT7A_1 = median(WKT7A) if !missing(WKT7A) & WKT7A > 0 & inlist(EP3,3), by(code_citp_emp_principal)

*replace WKT7A = med_WKT7A_1 if !missing(WKT7A) & WKT7A <= 0 & inlist(EP3,3) & WKT7==1

cap drop med_WKT7A_2
*egen  med_WKT7A_2 = median(WKT7A) if !missing(WKT7A) & WKT7A > 0 & inlist(EP3,1,10), by(code_citp_emp_principal)

*replace WKT7A = med_WKT7A_2 if !missing(WKT7A) & WKT7A <= 0 & inlist(EP3,1,10) & WKT7==1

cap drop med_WKT7A_3
egen med_WKT7A_3 = median(WKT7A), by(EP3 EP11)
replace WKT7A = med_WKT7A_3 if WKT7A == 0 & WKT7==1
cap drop med_WKT7A_3


cap drop med_WKT7A_1 med_WKT7A_2 med_WKT7A_3

*WKT8.Plus tôt, vous m’avez dit que vous étiez absent de votre emploi, juste pour confirmer, la semaine dernière (( %DateJ7% au %DateJ0% )) n’avez-vous pas travaillé des heures du tout dans votre emploi principal ?
***Etape1: Valeurs manquantes et corrrection
count if missing(WKT8) & EN_EMP==1 & M4Confirm >= 15 & SE8 == 1

*exportation:
if r(N) > 0 {
export excel interview__key HH13 WKT8  using "$folderpath/document/WKT8.xlsx" if missing(WKT8) & EN_EMP==1 & M4Confirm >= 15 & SE8 == 1 ,firstrow(variables) replace
}

****Correction : elle necessite de revenir aux agents

*br WKT8 if missing(WKT8) & EN_EMP==1 & M4Confirm >= 15 & SE8 == 1
***Etape2: coherence des sauts: RAS
count if !missing(WKT8) & (EN_EMP==0 | M4Confirm < 15 | SE8 != 1)
***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT8) & !inrange(WKT8,1,2) 
***Etape4: 
*Verifier voir si l'individu n'a pas travaillé des heures du tout dans son emploi principal (WKT8) et affirme travailler effectivement travaillez au moins une heure la semaine


* WKT9 : Heures totales travaillées la semaine dernière
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP==1 & M4Confirm >= 15 & missing( WKT9) & WKT8==1 & !inlist(M4Confirm,.,.a) 
***Etape2: coherence des sauts
count if !missing(WKT9) & (M4Confirm < 15 | EN_EMP != 1 |  WKT8!=1)
***Etape3: Coherence des reponses attendues:
count if !missing(WKT9) & WKT9 <=0

***Correction: imputation
cap drop med_WKT9
*egen med_WKT9 = median(WKT9), by(EP3 EP11 code_citp_emp_principal)
*replace WKT9 = med_WKT9 if WKT9 ==0
cap drop med_WKT9

***Etape 4: Vraisemblence des reponses 
count if !missing(WKT9) & WKT6 > WKT9 & !inlist(WKT9,.,.a) & !inlist(WKT6,.,.a) // le nombre d'heures travaillées dans l'emploi principal (WKT6)ne peut etre superieur au nbre d’heures  travaillées au total dans  l'emploi principal en tenant  compte des heures supplémentaires ou des absences (WKT9). 


* Pour WKT10
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT10) & (PL1 == 1 | PL2 == 1) & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH13 WKT10  using "$folderpath/document/WKT1O.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT10) & (PL1 == 1 | PL2 == 1) & !inlist(M4Confirm,.,.a) ,firstrow(variables) replace
}

***Corrrection
cap drop med_WKT10
*egen med_WKT10 = median(WKT10), by(EP3 EP11 code_citp_emp_principal)
*replace WKT10 = med_WKT10 if WKT10 == .a
cap drop med_WKT10

***Etape2: coherence des sauts

count if !missing(WKT10) & (PL1 == 2 & PL2 == 2)
***Etape3: Coherence des reponses attendues
count if  !missing(WKT10) & WKT10<=0  // le nombres d'heures habituel dans l'emploi secondaire ne peut etre nul. 


*proposition de correction 
* 
* br WKT10 EP3 EP11 if !missing(WKT10) & WKT10<=0 // on regarde d'abord les caractéristiques de l'individu

cap drop med_WKT10
egen med_WKT10 = median(WKT10) if !missing(WKT10) & WKT10>0 & inlist(EP3,3), by(EP3 EP11) // la median est de 16H pour les personnes à propre compte 

replace WKT10 = 16 if !missing(WKT10) & WKT10<=0 & inlist(EP3,3)

/*
cap drop med_WKT10_1
egen med_WKT10_1 = median(WKT10) if !missing(WKT10) & WKT10>0 & inlist(EP3,5)

replace WKT10 = med_WKT10_1 if !missing(WKT10) & WKT10<=0 & inlist(EP3,5)

drop med_WKT10_1 med_WKT10
*/

***Etape4 Vraisemblence

*WKT11. Est-ce le nombre d’heures dont vous av ez travaillé la semaine allant du %DateJ7% au % DateJ0% dans votre 1er emploi secondaire ? *******************************************
*Etape1: valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT11) & WKT10!=9998 & WKT10!=. & WKT10!=.a

***Corrrection
cap drop med_WKT11
*egen med_WKT11 = median(WKT11), by(EP3 EP11 code_citp_emp_principal)
egen med_WKT11 = median(WKT11), by(EP3 EP11 )
replace WKT11 = med_WKT11 if WKT11 ==.a
cap drop med_WKT11


***Etape2: coherence des sauts
count if !missing(WKT11) & (WKT10==9998 | WKT10==. | WKT10==.a )
***Etape3: Coherence des reponses attendues RAS
count if !missing(WKT11) & !inrange(WKT11,1,2)

* Pour WKT12
*Etape1: valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT12) & (WKT11 == 2 | WKT10==9998 ) 

***Etape:2 coherence des sauts
count if !missing(WKT12) & WKT11 != 2 & WKT10!=9998 
***Etape3: Coherence des reponses attendues 
count if !missing(WKT12) & WKT12 <0

* WKT13.Combien d’heures travaillez-vous habit uellement par semaine dans vos autre(s) empl oi(s) en dehors de l’emploi principal et du prem ier emploi secondaire ?

*Etape1: valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT13) & (PL3 >= 2 & (PL1 ==1 | PL2 == 1 ))

if r(N) > 0 {
export excel interview__key HH13 WKT13 PL3 PL1 PL2 using "$folderpath/document/WKT13.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT13) & ( PL3 >= 2 & (PL1 ==1 | PL2 == 1 )) ,firstrow(variables) replace
}

***Corection: Imputation

cap drop med_WKT13
egen med_WKT13 = median(WKT13), by(EP3 EP11 )
replace WKT13 = med_WKT13 if WKT13 == .a
cap drop med_WKT13

***Etape2: coherence des sauts
count if !missing(WKT13) & (PL3 < 2 & (PL1 != 1 & PL2 != 1))
***Etape: Coherence des reponses attendues RAS
count if !missing(WKT13) & WKT13 <=0

*WKT14 Est-ce le nombre d’heures travaillées qu e vous avez effectué la semaine allant du %Dat eJ7% au %DateJ0% dans (ses) autre(s) emploi(s) ?

*Etape1: valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT14) & WKT13!=. & WKT13!=.a & WKT13!=9998

if r(N) > 0 {
export excel interview__key HH13 WKT14  using "$folderpath/document/WKT14_Manquants .xlsx" if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT14) & WKT13!=. & WKT13!=.a & WKT13!=9998 ,firstrow(variables) replace
}
***Correction: RAS

cap drop med_WKT14
egen med_WKT14 = median(WKT14), by(EP3 EP11 )
replace WKT14 = med_WKT14 if WKT14 == .a
cap drop med_WKT14



***Etape2: coherence des sauts
count if !missing(WKT14) & (WKT13==. | WKT13==.a | WKT13==9998)

***Etape3: Coherence des reponses attendues RAS
count if !missing(WKT14) & !inrange(WKT14,1,2)

* WKT15. Combien d’heures vous avez travaillé la semaine allant du %DateJ7% au %DateJ0% dans ses autres emplois ?
*Etape1: valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT15) & (WKT14 == 2 | WKT13 == 9998)
***Etape2: coherence des sauts

count if !missing(WKT15) & (WKT14 != 2 & WKT13 != 9998)
***Etape3: Coherence des reponses attendues

count if !missing(WKT15) & WKT15<0


* WKT16. Donc, au total, cela signifie que vous av ez travaillé habituellement %WTK_HABVF% heu res par semaine dans l’ensemble de vos emploi s, est-ce exact ?
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT16) & !inlist(WKT10,9998,.,.a)



***Corection: Imputation
/*
cap drop med_WKT16
egen med_WKT16 = median(WKT16), by(EP3 EP11)
replace WKT16 = med_WKT16 if WKT16 == .a
cap drop med_WKT16
*/


***Etape2: coherence des sauts

count if !missing(WKT16) & inlist(WKT10,9998)

***Etape3: Coherence des reponses attendues RAS
count if !missing(WKT16) & !inrange(WKT16,1,2)


* Pour WKT17
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT17) & WKT16==2
***Etape2: coherence des sauts

count if !missing(WKT17) & WKT16==1

***Etape3: Coherence des reponses attendues
count if EN_EMP == 1 & M4Confirm >= 15 & !missing(WKT17)  & WKT17==0

if r(N) > 0 {
export excel interview__key HH13 WKT17  using "$folderpath/document/WKT17.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & !missing(WKT17) & WKT16==2 & WKT17==0 ,firstrow(variables) replace
}


* Pour WKT17A
***Etape1: Valeurs manquantes et corrrection

count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT17A) & (!(WKT10==9998|WKT10==9998)& !(WKT6==9998|WKT4A==9998))

if r(N) > 0 {
export excel interview__key HH13 WKT17A  using "$folderpath/document/WKT17A.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT17A) & (!(WKT10==9998|WKT10==9998)& !(WKT6==9998|WKT4A==9998)) ,firstrow(variables) replace
}


**Correction pour NB_HEURE_TRAVAIL_TOTAL
* 
* br NB_HEURE_TRAVAIL_TOTAL if NB_HEURE_TRAVAIL_TOTAL > 168 & !missing(NB_HEURE_TRAVAIL_TOTAL) // visualisation des caractéristiques de l'individus

cap drop med_NB_HEURE_TRAVAIL_TOTAL
egen med_NB_HEURE_TRAVAIL_TOTAL = median(NB_HEURE_TRAVAIL_TOTAL) if NB_HEURE_TRAVAIL_TOTAL <= 168, by(EP3 EP11) // la median est de 54H pour les individus avec les memes caracteristiques



replace NB_HEURE_TRAVAIL_TOTAL = 54 if NB_HEURE_TRAVAIL_TOTAL > 168 & !missing(NB_HEURE_TRAVAIL_TOTAL) // il faut toujours actualiser cette ligne en fonction des individus problématiques
cap drop med_NB_HEURE_TRAVAIL_TOTAL



***Etape2: coherence des sauts

count if !missing(WKT17A) & (WKT10==9998|WKT10==9998) & (WKT6==9998 | WKT4A==9998)
***Etape3: Coherence des reponses attendues
count if !missing(WKT17A) & !inrange(WKT17A,1,2)

* Pour WKT18
***Etape1: Valeurs manquantes 
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT18) & WKT17A==2 

if r(N) > 0 {
export excel interview__key HH13 WKT18  using "$folderpath/document/WKT18.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT18) & WKT17A==2,firstrow(variables) replace
}
***Correction: imputation par la mediane croisant Métier (CITP) et Secteur (Branche)
cap drop med_WKT18
egen med_WKT18 = median(WKT18), by(EP3 EP11 code_citp_emp_principal branche1)

* Option de secours (Secteur uniquement)
cap drop med_WKT18_large
egen med_WKT18_large = median(WKT18), by(EP3 EP11 branche1)

replace WKT18 = med_WKT18 if WKT18 == .a & !missing(med_WKT18)
replace WKT18 = med_WKT18_large if WKT18 == .a & !missing(med_WKT18_large)
cap drop med_WKT18 med_WKT18_large

***Etape2: coherence des sauts
count if !missing(WKT18) & WKT17A ==1

***Etape3: Coherence des reponses attendues 
count if !missing(WKT18) & WKT18<=0 & WKT17A==2 // plus de 124 personnes pour qui la reponse est Zero, 
* 
* br NB_HEURE_TRAVAIL_TOTAL WKT17A WKT18 if !missing(WKT18) & WKT18<=0 & WKT17A==2


if r(N) > 0 {
export excel interview__key HH13 WKT18  using "$folderpath/document/WKT18_1.xlsx"  if !missing(WKT18) & WKT18<=0,firstrow(variables) replace
}

*correction

replace WKT17A = 1 if !missing(WKT18) & WKT18<=0 & WKT17A==2
replace WKT18 =. if WKT18<=0 & WKT17A ==1

*br  WKT17A WKT18 if  !missing(WKT18) & WKT18<=0

***Etape 4:

count if !missing(WKT18) & WKT18==0 & WKT15>0 & !inlist(WKT15,.,.a)

* Pour WKT18A
***Etape1: Valeurs manquantes et correction
count if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT18A) & (membre_id_v1_IND=="##N/A##")

if r(N) > 0 {
export excel interview__key HH13 WKT18A  using "$folderpath/document/WKT18A.xlsx"  if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT18A) & (membre_id_v1_IND=="##N/A##"),firstrow(variables) replace
}
***Correction: Elle necessite de revenir aux agents

***Etape2: coherence des sauts
count if !missing(WKT18A) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) // RAS car il s'agit des personnes n'étant pas en emploi identifié en EP

*
* br EN_EMP if !missing(WKT18A) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1))

replace WKT18A =. if !missing(WKT18A) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1))

***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT18A) & !inrange(WKT18A,1,2)

* Pour WKT18B
***Etape1: Valeurs manquantes et correction
count if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT18B) & (membre_id_v1_IND=="##N/A##")

if r(N) > 0 {
export excel interview__key HH13 WKT18B  using "$folderpath/document/WKT18B.xlsx"  if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT18B) & (membre_id_v1_IND=="##N/A##"),firstrow(variables) replace
}

***Correction: Elle necessite de revenir aux agents

***Etape2: coherence des sauts
count if !missing(WKT18B) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) // idem que WKT18B 

replace WKT18B =. if !missing(WKT18B) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) 

***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT18B) & !inrange(WKT18B,1,2)


* Pour WKT19
***Etape1: Valeurs manquantes et correction
count if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT19) & membre_id_v1_IND=="##N/A##" 

if r(N) > 0 {
export excel interview__key HH13 WKT18B  using "$folderpath/document/WKT19.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT19) & membre_id_v1_IND=="##N/A##"  ,firstrow(variables) replace
}

**Correction: Elle necessite de revenir aux agents

***Etape2: coherence des sauts
count if !missing(WKT19) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) // // idem que WKT18B 

replace WKT19=. if !missing(WKT19) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1))

***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT19) & !inrange(WKT19,1,2)

* Pour WKT20a
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT20a) & WKT19==1
***Etape2: coherence des sauts
count if !missing(WKT20a) &  WKT19!=1
***Etape3: Coherence des reponses attendues RAS
count if WKT20a<=0

* Pour WKT20b
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT20b) & WKT19==1
***Etape2: coherence des sauts
count if !missing(WKT20b) &  WKT19!=1
***Etape3: Coherence des reponses attendues 
count if !missing(WKT20b) & !inrange(WKT20b,1,2)

* Pour WKT21
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT21) & WKT19==1
***Etape2: coherence des sauts
count if !missing(WKT21) &  WKT19!=1
***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT21) & !inrange(WKT21,1,4)


* Pour WKT22
***Etape1: Valeurs manquantes et corrrection
count if EN_EMP == 1 & M4Confirm >= 15 & missing(WKT22) & inlist(WKT21,1,2,3)

***Etape3: coherence des sauts
count if !missing(WKT22) & (M4Confirm < 15 | EN_EMP != 1)
count if !missing(WKT22) & !inlist(WKT21,1,2,3)
***Etape3: Coherence des reponses attendues RAS
count if !missing(WKT22) & !inrange(WKT22,1,3)

* Pour WKT24
***Etape1: Valeurs manquantes et correction
count if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT24) & membre_id_v1_IND=="##N/A##" 

if r(N) > 0 {
export excel interview__key HH13 WKT24  using "$folderpath/document/WKT24.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT24) & membre_id_v1_IND=="##N/A##", firstrow(variables) replace
}

**Correction: Elle necessite de revenir aux agents

***Etape2: coherence des sauts
count if !missing(WKT24) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) // // idem que WKT18B 

replace WKT24=. if !missing(WKT24) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1))


***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT24) & !inrange(WKT24,1,3)


* Pour WKT25
***Etape1: Valeurs manquantes et correction
count if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT25) & membre_id_v1_IND=="##N/A##"

if r(N) > 0 {
export excel interview__key HH13 WKT25  using "$folderpath/document/WKT25.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT25) & membre_id_v1_IND=="##N/A##", firstrow(variables) replace
}

****Correction Elle necessite de revenir aux agents


***Etape2: coherence des sauts
count if !missing(WKT25) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) // // idem que WKT18B  

replace WKT25=. if !missing(WKT25) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1))


***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT25) & !inrange(WKT25,1,3)


* Pour WKT26
***Etape1: Valeurs manquantes et correction
count if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT26) & membre_id_v1_IND=="##N/A##" 

if r(N) > 0 {
export excel interview__key HH13 WKT26  using "$folderpath/document/WKT26.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT26) & membre_id_v1_IND=="##N/A##", firstrow(variables) replace
}
****Correction: Elle necessite de revenir aux agents


***Etape2: Coherence des reponses attendues: RAS
count if !missing(WKT26) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) // idem que WKT18B  

replace WKT26=. if !missing(WKT26) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1))


***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT26) & !inrange(WKT26,1,3) 

*** Etape 4 : Vraisemblance

* Pour WKT27
***Etape1: Valeurs manquantes et correction

count if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT27) & membre_id_v1_IND=="##N/A##" 

if r(N) > 0 {
export excel interview__key HH13 WKT27  using "$folderpath/document/WKT27.xlsx" if EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) & missing(WKT27) & membre_id_v1_IND=="##N/A##", firstrow(variables) replace
}

****Correction: elle necessite de revenir aux agents

***Etape2: coherence des sauts
count if !missing(WKT27) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) // idem que WKT18B  

replace WKT27=. if !missing(WKT27) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | (M4Confirm < 15 )| (EN_EMP != 1)) 

***Etape3: Coherence des reponses attendues: RAS
count if !missing(WKT27) & !inrange(WKT27,1,3)


********Etape4: Verification de la vraisemblance: Coherance avec les autres sections 



*****Saving********************

cap drop HH12 HH13 M4Confirm EN_EMP EP3 EP11 membre_id_v1_IND SE8 PL1 PL2 PL3

cap drop med_WKT1 med_WKT7A_1 med_WKT7A_2 med_WKT10

save "$standard_individu\INDIV_S7_temps_travail.dta", replace 


