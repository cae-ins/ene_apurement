*+==============================================================
*						SECTION EMPLOI ANTERIEUR
*+==============================================================
*--------------------------------------------------------
* Condition d'entrer dans la section emploi antérieur
* membre_id_v1_IND == null && M4Confirm>=15 && C2 !=2
*------------------------------------------------------

use "$datain_standard\INDIV_S12_emploi_anterieur.dta", clear

* Recherche des variables utiles pour la section emploi antérieur et fusion
*-------------------------------------------------------------

// EN_EMP (section emploi), M4Confirm (section aft), HH13 (identification), EP1a (section emploi), C2 (chomage)

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP EP1a EP2ka) nogen

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm) nogen

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S11_chomage.dta", keepus(C2) nogen

merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(membre_id_v1_IND) nogen // Utilisation de la base membres parce que la variable membre_id_v1_IND n'existe pas dans les bases standardiser

cap drop _merge

merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH13)

keep if _merge == 3 


cap drop _merge


merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S4_competences_qualifications.dta", keepus(CQ4) 

keep if _merge == 3 

/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
///////////////////////////////////////////////////////////////////////////



* P2. Actuelement vous étes en emploi comme % EP1a%. Avant cet emploi, aviez vous travaillé en échange d’un salaire, traitement, profit, commi ssion, pourboire ou autre rémunération, en es pèce ou en nature...

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(P2) & EN_EMP==1 & ( membre_id_v1_IND =="##N/A##" & C2!=2 & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))) // 315 valeurs manquantes

*Exportation: 
if r(N) > 0 {
export excel interview__key HH13 P2  using "$folderpath/document/P2_manquants" if missing(P2) & EN_EMP==1 & ( membre_id_v1_IND =="##N/A##" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))),firstrow(variables) replace
}

***Correction des manquant : elle necessite de revenir aux agents

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 

count if !missing(P2) & !(EN_EMP==1 & ( membre_id_v1_IND =="##N/A##" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))))


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

count if !missing(P2) & !inrange(P2,1,2) 


*P2a. Pendant la semaine du %DateJ7% à %DateJ 0%, vous étiez sans emploi. Avant de connaître cette situation, aviez vous travaillé en échange d’un salaire, traitement, profit, commission, po urboire ou autre rémunération, en espèce ou e n nature, même si cela


*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(P2a) & C2!=2 & EN_EMP==0 & ( membre_id_v1_IND =="##N/A##" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)))

count if P2a ==.a

**Exportation: 
if r(N) > 0 {
export excel interview__key HH13 P2a  using "$folderpath/document/P2a_manquants" if missing(P2a) & C2!=2 & EN_EMP==0 & ( membre_id_v1_IND =="##N/A##" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))),firstrow(variables) replace
}

***Correction: elle necessite de revenir aux agents 


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 

count if !missing(P2a) & !(C2!=2 & EN_EMP==0 & ( membre_id_v1_IND =="##N/A##" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

count if !missing(P2a) & !inlist(P2a,1,2)

***P2bM. À quel mois avez-vous commencé cette 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P2bM) & ( P2a==1|P2==1)

*Correction: RAS
replace P2bM=. if missing(P2bM) & ( P2a==1|P2==1)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P2bM) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P2bM) & !inlist(P2bM,9998) & !inrange(P2bM,1,12)


* P2bA: A quelle année avez-vous commencé cette activité

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(P2bA) & (P2a==1|P2==1)

**Correction: 
replace P2bA=. if missing(P2bA) & (P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(P2bA) & !(P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P2bA) & (P2bA==0 | P2bA > 2025) & P2bA!=9998


*P4:‐ Laquelle des situations suivantes correspo nd le mieux à ce que vous fa


*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(P4) & (P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(P4) & !(P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P4) & !inrange(P4,1,10)


***P4_aut.Veuillez préciser

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(P4_aut) &  P4==10

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(P4_aut) &  P4!=10

****** P5. Comment aviez-vous obtenu cet emploi


*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P5) & ( P2a==1|P2==1)

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P5) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P5) & !inrange(P5,1,12)



**P7M ez-vous arrêtez cette activit  mois avez-vous arrêtez cette activit 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P7M) & ( P2a==1|P2==1)

*Correction: RAS
replace P7M=. if missing(P7M) & (P2a==1|P2==1)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P7M) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P7M) & !inrange(P7M,1,12) & P7M!= 9998


*P7A ez-vous arrêtez cette activit  mois avez-vous arrêtez cette activit 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P7A) & ( P2a==1|P2==1)

*Correction: 
replace P7A=. if missing(P7A) & ( P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P7A) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P7A) & P7A==0


***P8 tait l’intitulé du métier que vous aviez 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P8) & ( P2a==1|P2==1)

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P8) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? : RAS


***P9

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P9) & ( P2a==1|P2==1)

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P9) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? : RAS



***P10

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P10) & ( P2a==1|P2==1)

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P10) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? : RAS


**P11. L'unité de production dans laquelle vous e xerciez cet emploi (ou que vous dirigez) était-ell e une :

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P11) & ( P2a==1|P2==1)

*Correction: RAS


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P11) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P11) & !inrange(P11,1,8)


*** P12A. Savez-vous si l'unité de production dans l aquelle vous exerciez cet emploi (ou que vous dirigez) était enregistrée avec un N° de compte Contribuable ?
 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P12A) & ((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & P11!=1 & P11!=2 & P11!=5 & P11!=8)

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P12A) & !((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & P11!=1 & P11!=2 & P11!=5 & P11!=8)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P12A) & !inrange(P12A,1,2) & !inlist(P12A,9998)


** P12B aquelle vous exerciez cet emploi (ou que vous dirigez) était enregistrée avec un Registre de c ommerce ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P12B) & ((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & P11!=1 & P11!=2 & P11!=5 & P11!=8)

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P12B) & !((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & P11!=1 & P11!=2 & P11!=5 & P11!=8)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P12B) & !inrange(P12B,1,2) & !inlist(P12B,9998)


**P12C
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P12C) & ((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & P11!=1 & P11!=2 & P11!=5 & P11!=8)

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P12C) & !((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & P11!=1 & P11!=2 & P11!=5 & P11!=8)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P12C) & !inrange(P12C,1,2) & !inlist(P12C,9998)


**** P13. Exerciez-vous votre emploi sur la base 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P13) & ( P2a==1|P2==1)

*Correction: RAS
*br if missing(P13) & ( P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P13) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P13) & !inrange(P13,1,3)

***P14. Votre contrat ou accord était ?


*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P14) &  (P13==1 |P13==2 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P14) & ! (P13==1|P13==2 )

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P14) & !inrange(P14,1,2)



**P15 rat ou accord était-il d 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P15) &   (P13==1|P13==2 ) & P14==2

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P15) & !((P13==1|P13==2 ) & P14==2)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P15) & !inrange(P15,1,9)



** P15_Aut. Autre raison (à préciser


*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P15_Aut) &   P15==9

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P15_Aut) & P15!=9

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P15_Aut) & P15!=9


****P16 agissait-il d'un emploi à temps partiel ou p

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P16) &  (P13==1 |P13==2 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P16) &  !(P13==1 |P13==2 )


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P16) &  !inlist(P16,1,2)

***P17A v antes dans cet e

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P17A) &  (P13==1 |P13==2 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P17A) &  !(P13==1 |P13==2 )

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P17A) &  !inlist(P17A,1,2,9998)


***P17B v antes dans cet e

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P17B) &  (P13==1 |P13==2 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P17B) &  !(P13==1 |P13==2 )


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P17B) &  !inlist(P17B,1,2,9998)


***P17C

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P17C) &  (P13==1 |P13==2 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P17C) &  !(P13==1 |P13==2 )


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P17C) &  !inlist(P17C,1,2,9998)


***P17D

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P17D) &  (P13==1 |P13==2 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P17D) &  !(P13==1 |P13==2 )

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P17D) &  !inlist(P17D,1,2,9998)


***P18

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P18) &   (P13==1 |P13==2 ) & P14==2

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P18) &  !((P13==1 |P13==2 ) & P14==2 )

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P18) &  !inlist(P18,1,2,3)



***P19

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P19) &   (P2a==1|P2==1 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P19) &  !(P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P19) &  !inrange(P19,1,6)


***P20

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P20) &   (P2a==1|P2==1 )

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P20) &  !(P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P20) &  !inrange(P20,1,19)


**P20_Aut. Autre raison (à préciser
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P20_Aut) &   P20==18

*Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P20_Aut) &  P20!=18

*Etape3: Est ce que les reponses données sont celles qu'on atendait? RAS



save "$standard_individu\INDIV_S12_emploi_anterieur.dta", replace


