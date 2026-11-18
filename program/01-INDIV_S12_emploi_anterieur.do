
*						SECTION EMPLOI ANTERIEUR
*+============================================================== KOUADIO BROU YVES
*--------------------------------------------------------
* Condition d'entrer dans la section emploi antérieur
* membre_id_v1_IND == null && M4Confirm>=15 && C2 !=2
*------------------------------------------------------

use "$datain_standard\INDIV_S12_emploi_anterieur.dta", clear

* Recherche des variables utiles pour la section emploi antérieur et fusion
*-------------------------------------------------------------

// EN_EMP (section emploi), M4Confirm (section aft), HH13 (identification), EP1a (section emploi), C2 (chomage)

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP EP1a EP2ka) nogen
* EN_EMP reconstruit (sortie S2, 00-en_emploi.do) à la place de la variable de collecte
charger_en_emploi

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm) nogen

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S11_chomage.dta", keepus(C2) nogen

merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(membre_id_v1_IND) nogen // Utilisation de la base membres parce que la variable membre_id_v1_IND n'existe pas dans les bases standardiser

cap drop _merge

merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH13)

keep if _merge == 3 


cap drop _merge


merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S4_competences_qualifications.dta", keepus(CQ4) 

keep if _merge == 3 

gen commentaire =""

*condition eligible pour avoir accès à la section
cap drop champ_P
gen champ_P = membre_id_v1_IND =="##N/A##" & M4Confirm>=15 & !missing(M4Confirm) & C2!=2

/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
//////////////////////////////////////////////////////////


* P2. Actuelement vous étes en emploi comme % EP1a%. Avant cet emploi, aviez vous travaillé en échange d’un salaire, traitement, profit, commi ssion, pourboire ou autre rémunération, en es pèce ou en nature...

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(P2) & EN_EMP==1 & champ_P==1 
// 6 cas au T3-2026
replace commentaire="6 individus n'ont pas repondu à la question P2'" if missing(P2) & EN_EMP==1 & champ_P==1
quietly count if missing(P2) & EN_EMP==1 & champ_P==1
if r(N)>0 {
export excel interview__key membres__id HH13 EN_EMP P2 using "$folderpath/document/Erreur_P2_NA" if missing(P2) & EN_EMP==1 & champ_P==1, firstrow(variables) replace
}


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 

count if !missing(P2) & !(EN_EMP==1 & champ_P==1) 


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

count if !missing(P2) & !inrange(P2,1,2) 


*P2a. Pendant la semaine du %DateJ7% à %DateJ 0%, vous étiez sans emploi. Avant de connaître cette situation, aviez vous travaillé en échange d’un salaire, traitement, profit, commission, po urboire ou autre rémunération, en espèce ou e n nature, même si cela


*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(P2a) & EN_EMP==0 & champ_P==1 
// 6 cas au T3-2026
replace commentaire="6 individus n'ont pas repondu à la question P2a" if missing(P2a) & EN_EMP==0 & champ_P==1
quietly count if missing(P2a) & EN_EMP==0 & champ_P==1
if r(N)>0 {
export excel interview__key membres__id HH13 EN_EMP C2 P2a using "$folderpath/document/Erreur_P2a_NA" if missing(P2a) & EN_EMP==0 & champ_P==1, firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 

count if !missing(P2a) & !(EN_EMP==0 & champ_P==1) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

count if !missing(P2a) & !inlist(P2a,1,2)

***P2bM. À quel mois avez-vous commencé cette 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P2bM) & ( P2a==1|P2==1) 
*br if missing(P2bM) & ( P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P2bM) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P2bM) & P2bM != 9998 & !inrange(P2bM,1,12)


* P2bA: A quelle année avez-vous commencé cette activité

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(P2bA) & (P2a==1|P2==1)
*br if missing(P2bA) & (P2a==1|P2==1) 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(P2bA) & !(P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P2bA) & (P2bA==0 | P2bA > 2026) & P2bA!=9998

*P4:‐ Laquelle des situations suivantes correspo nd le mieux à ce que vous faisiez ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(P4) & (P2a==1|P2==1)
*br if missing(P4) & (P2a==1|P2==1) 

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
*br if missing(P5) & ( P2a==1|P2==1)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P5) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P5) & !inrange(P5,1,12)

***P5_aut. Veuillez préciser
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P5_aut) & P5 == 12

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P5_aut) & P5 != 12

**P7M ez-vous arrêtez cette activit  mois avez-vous arrêtez cette activit 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P7M) & ( P2a==1|P2==1)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P7M) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P7M) & !inrange(P7M,1,12) & P7M!= 9998


*P7A ez-vous arrêtez cette activit  mois avez-vous arrêtez cette activit 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P7A) & ( P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P7A) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P7A) & (P7A==0 | P7A > 2026) & P7A != 9998


***P8 Quel était l'intitulé du métier que vous aviez/occupiez ? 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P8) & ( P2a==1|P2==1)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P8) & !( P2a==1|P2==1)

***P9  Quelles étaient vos principales tâches ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P9) & ( P2a==1|P2==1)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P9) & !( P2a==1|P2==1)

***P10. Quels sont les principaux produits ou services réalisés dans l'entreprise dans laquelle vous aviez travaillé ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P10) & ( P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P10) & !( P2a==1|P2==1)

**P11. L'unité de production dans laquelle vous e xerciez cet emploi (ou que vous dirigez) était-ell e une :

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P11) & ( P2a==1|P2==1)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P11) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P11) & !inrange(P11,1,8)

*** P12A. Savez-vous si l'unité de production dans laquelle vous exerciez cet emploi (ou que vous dirigez) était enregistrée avec un N° de compte Contribuable ?
 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P12A) & ((P2a==1|P2==1) & inlist(P4, 2,3,4,5) & !missing(P11) & !inlist(P11, 1,2,5,8))


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P12A) & !((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & !inlist(P11, 1,2,5,8))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P12A) & !inrange(P12A,1,2) & P12A != 9998


** P12B aquelle vous exerciez cet emploi (ou que vous dirigez) était enregistrée avec un Registre de c ommerce ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P12B) & ((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & !inlist(P11, 1,2,5,8))


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P12B) & !((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & !inlist(P11, 1,2,5,8))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P12B) & !inrange(P12B,1,2) & P12B != 9998


**P12C. Savez-vous si l'unité de production dans laquelle vous exerciez cet emploi (ou que vous dirigez) était enregistrée à la CNPS ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P12C) & ((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & !inlist(P11, 1,2,5,8))

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P12C) & !((P2a==1|P2==1)& inlist(P4, 2,3,4,5)& !missing(P11) & !inlist(P11, 1,2,5,8))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P12C) & !inrange(P12C,1,2) & P12C != 9998

**** P13. Exerciez-vous votre emploi sur la base 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P13) & ( P2a==1|P2==1)



*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P13) & !( P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P13) & !inrange(P13,1,3)

***P14. Votre contrat ou accord était ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P14) &  (P13==1 |P13==2)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P14) & !(P13==1|P13==2)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P14) & !inrange(P14,1,2)

**P15 rat ou accord était-il d 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P15) &  (P13==1|P13==2 ) & P14==2

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P15) & !((P13==1|P13==2 ) & P14==2)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P15) & !inrange(P15,1,9)


** P15_Aut. Autre raison (à préciser
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P15_Aut) &   P15==9


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P15_Aut) & P15!=9

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

****P16 agissait-il d'un emploi à temps partiel ou p
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P16) &  (P13==1 |P13==2)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P16) &  !(P13==1 |P13==2)


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P16) &  !inlist(P16,1,2)

*** P17A; P17B; P17C; P17D
foreach var in P17A P17B P17C P17D {
	di "---------------------------------------"
	di "Contrôle de la variable `var'"
	*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
	count if missing(`var') & inlist(P13, 1,2)
	
	***Exportation: 
	if r(N) > 0 {
		export excel interview__key HH13 `var'  using "$folderpath/document/`var'_Manquants" if missing(`var') & inlist(P13, 1,2),firstrow(variables) replace
	}
	
	*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
	
	 count if !missing(`var') & !inlist(P13,1,2) 
	
	*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
	count if !missing(`var') & !inlist(`var', 1,2,9998) & inlist(P13, 1,2)
		 
}


***P18. Quelle était la durée de votre contrat ou accord 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P18) &   (P13==1 |P13==2 ) & P14==2


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P18) &  !((P13==1 |P13==2 ) & P14==2 )

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P18) &  !inlist(P18,1,2,3)



***P19 Dans quelle mesure étiez-vous satisfait de cet emploi ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P19) &   (P2a==1|P2==1 )

*br if missing(P19) &   (P2a==1|P2==1 )


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P19) &  !(P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P19) &  !inrange(P19,1,6)


***P20. Parmi les propositions suivantes, laquelle correspond le mieux à la raison de votre départ ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P20) &   (P2a==1|P2==1 )


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P20) &  !(P2a==1|P2==1)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(P20) &  !inrange(P20,1,19)


**P20_Aut. Autre raison (à préciser
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(P20_Aut) &   P20==18


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(P20_Aut) &  P20!=18

*=============================================================================
* Cohérence des dates de l'emploi antérieur (détection uniquement)
*=============================================================================
merge 1:1 interview__key membres__id using "$datain_standard\QM_S1_composition_menage.dta", keepus(AgeAnnee) keep(1 3) nogen
cap drop d_deb d_fin err_date
gen d_deb = P2bA*12 + P2bM if P2bA<9000 & inrange(P2bM,1,12)
gen d_fin = P7A*12 + P7M  if P7A<9000  & inrange(P7M,1,12)
gen err_date = ""
replace err_date = "Fin avant début"              if d_fin < d_deb & !missing(d_deb, d_fin)
replace err_date = "Fin après la collecte"        if d_fin > 2026*12+9 & !missing(d_fin)
replace err_date = "Début avant 5 ans"            if P2bA < (2026 - AgeAnnee + 5) & P2bA<9000 & !missing(AgeAnnee, P2bA) & err_date==""
replace err_date = "Année antérieure à 1950"      if (P2bA<1950 | P7A<1950) & !missing(P2bA) & err_date==""
tab err_date if err_date!=""

//seuil de 5 ans conservé : un début entre 5 et 14 ans est plausible (travail précoce), seul un début avant 5 ans est jugé impossible

// T3-2026 : 13 fin avant début, 2 fin après collecte, 9 début avant 5 ans, 4 années < 1950
cap export excel interview__key membres__id HH13 AgeAnnee P2bM P2bA P7M P7A err_date using "$folderpath/document/Erreur_P_dates" if err_date!="", firstrow(variables) replace

// Correction : années aberrantes -> 9998 (NE SAIT PAS)
* Année de début antérieure à 1950 ou à l'âge de 5 ans ; année de fin antérieure à 1950 ou postérieure à 2026
replace P2bA = 9998 if P2bA<9000 & (P2bA<1950 | (P2bA < (2026 - AgeAnnee + 5) & !missing(AgeAnnee)))
replace P7A  = 9998 if P7A<9000  & (P7A<1950 | P7A>2026)

drop d_deb d_fin err_date AgeAnnee champ_P

drop EN_EMP EP1a EP2ka M4Confirm C2 membre_id_v1_IND HH13 CQ4 _merge

save "$standard_individu\INDIV_S12_emploi_anterieur.dta", replace


