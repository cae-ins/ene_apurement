
*********ACTIVITE DES PARENTS

****RESPONSABLE: KOUADIO BROU YVES
* [CORR 09/11/2026] Restructuration :
*   Partie A : roster père/mère (Activiteparent, TP1-TP6A)     -> $dataout\Activiteparent.dta
*   Partie B : questions individuelles TP7 + tuteur (TP1A-TP6AA) -> $standard_individu\INDIV_S14_activite_parents.dta (attendu par Fusion.do)
*   Filtre de section (CAPI) : membre_id_v1_IND == null && M4Confirm>=15  (pas de condition sur rgmen)
*   Dans les bases, membre_id_v1_IND "null" vaut "##N/A##" (et non "")
*=============================================

/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
/////////////////////////////////////////////////////////////////

*#############################################################################
* PARTIE A : ROSTER DES PARENTS BIOLOGIQUES (père / mère)
*#############################################################################

use "$datain_brute\Activiteparent.dta" , clear

cap drop _merge
merge m:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(M4Confirm membre_id_v1_IND)
keep if _merge == 3
cap drop _merge

merge m:1 interview__key using "$brute_menage_work" , keepus(MODINTR HH2 HH3 HH4 HH12 HH13)
keep if _merge == 3
cap drop _merge

cap drop champ_TP
gen champ_TP = membre_id_v1_IND =="##N/A##" & M4Confirm>=15 & !missing(M4Confirm)

**TP1.Lorsque vous aviez 15 ans, Votre %rostertitle% avait-il/elle un emploi ?

*Etape1: Valeurs manquantes
count if missing(TP1) & champ_TP==1
// T3-2026 : 26 lignes 
quietly count if missing(TP1) & champ_TP==1
if r(N)>0 {
export excel interview__key membres__id Activiteparent__id HH2 HH12 HH13 TP1 using "$folderpath/document/Erreur_TP1_NA" if missing(TP1) & champ_TP==1, firstrow(variables) replace
}

*Etape2: Coherence des sauts
count if !missing(TP1) & champ_TP==0

*Etape3: Valeurs permises
count if !missing(TP1) & !inlist(TP1,1,2,3,9998)

** TP2. ... pratiquait l'une des activités suivantes ... pour aider la famille ?
*Etape1
count if missing(TP2) & inlist(TP1,2,9998)
*Etape2
count if !missing(TP2) & !inlist(TP1,2,9998)
*Etape3
count if !missing(TP2) & !inrange(TP2,1,9) & TP2!=9998

** TP3a. Lorsque vous aviez 15 ans, quel était son statut dans emploi ?
*Etape1
count if missing(TP3a) & (TP1 == 1 | TP2 < 9) 
*Etape2
count if !missing(TP3a) & !(TP1 == 1 | TP2 < 9)
*Etape3
count if !missing(TP3a) & !inrange(TP3a,1,10) 

****TP3a_Aut. Veuillez préciser
count if missing(TP3a_Aut) & TP3a==10
count if !missing(TP3a_Aut) & TP3a!=10

** TP3. Lorsque vous aviez 15 ans, quelle était sa catégorie socioprofessionnelle ?
*Etape1
count if missing(TP3) & ((TP1 == 1 | inrange(TP2, 1,9)) & inlist(TP3a, 1, 8, 9))
*Etape2
count if !missing(TP3) & !((TP1 == 1 | inrange(TP2, 1,9) ) & inlist(TP3a, 1, 8, 9))
*Etape3
count if !missing(TP3) & !inrange(TP3,1,8)  &  TP3!=9998

**TP3_Aut. Veuillez préciser
count if missing(TP3_Aut) & TP3==8
count if !missing(TP3_Aut) & TP3!=8

** TP4. Lorsque vous aviez 15 ans, dans quel type d'entreprise travaillait-il/elle ?
*Etape1
count if missing(TP4) & (TP1 == 1 | TP2 < 9) 
*Etape2
count if !missing(TP4) & !(TP1 == 1 | TP2 < 9) 
*Etape3
count if !missing(TP4) & !inrange(TP4,1,8)  &  TP4!=9998

** TP5. Lorsque vous aviez 15ans, quel était son niveau d'instruction à cette période ?
*Etape1
count if missing(TP5) & (TP1 == 1 | TP2 < 9)  
*Etape2
count if !missing(TP5) & !(TP1 == 1 | TP2 < 9) 
*Etape3
count if !missing(TP5) & !inrange(TP5,0,12)  &  TP5!=9998 

** TP6A. Quel est le niveau d'instruction qu'il/elle a ou qu'il/elle avait atteint ?
*Etape1
count if missing(TP6A) & (TP1 == 1 | TP2 < 9)
*Etape2
count if !missing(TP6A) & !(TP1 == 1 | TP2 < 9) 
*Etape3
count if !missing(TP6A) & !inrange(TP6A,0,12) & TP6A!=9998
*Etape4: le niveau atteint ne peut être inférieur au niveau à 15 ans de l'enquêté
count if !missing(TP6A) & TP5 > TP6A & TP5<9998 & TP6A<9998 & (TP1 == 1 | TP2 < 9) 

drop champ_TP M4Confirm membre_id_v1_IND HH2 HH3 HH4 HH12 HH13 MODINTR

save "$dataout\Activiteparent.dta" , replace


*#############################################################################
* PARTIE B : QUESTIONS INDIVIDUELLES (TP7 et tuteur/tutrice)
*#############################################################################

use "$datain_standard\INDIV_S14_activite_parents.dta", clear

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(M4Confirm membre_id_v1_IND)
keep if _merge == 3
cap drop _merge

merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH2 HH12 HH13)
keep if _merge == 3
cap drop _merge

cap drop champ_TP
gen champ_TP = membre_id_v1_IND =="##N/A##" & M4Confirm>=15 & !missing(M4Confirm)

** Individus éligibles sans aucune ligne dans le roster des parents
preserve
	keep if champ_TP==1
	keep interview__key membres__id
	merge 1:m interview__key membres__id using "$dataout\Activiteparent.dta", keepus(TP1)
	count if _merge==1
restore

** TP7. Avant l'âge de 15 ans, chez qui avez-vous vécu en grande partie ?
*Etape1
count if missing(TP7) & champ_TP==1
quietly count if missing(TP7) & champ_TP==1
if r(N)>0 {
export excel interview__key membres__id HH2 HH12 HH13 TP7 using "$folderpath/document/Erreur_TP7_NA" if missing(TP7) & champ_TP==1, firstrow(variables) replace
}
*Etape2
count if !missing(TP7) & champ_TP==0
*Etape3
count if !missing(TP7) & !inrange(TP7,1,7) 

** TP1A.Lorsque vous aviez 15 ans, votre tuteur/tutrice avait-il/-elle un emploi ?
count if missing(TP1A) &   inlist(TP7,4,5)
count if !missing(TP1A) & !inlist(TP7,4,5)
count if !missing(TP1A) & !inrange(TP1A,1,2) & TP1A!=9998

** TP2A. ... pratiquait l'une des activités suivantes ... ?
count if missing(TP2A) &   inlist(TP1A,2,9998)
count if !missing(TP2A) & !inlist(TP1A,2,9998)
count if !missing(TP2A) & !inrange(TP2A,1,9) & TP2A!=9998

** TP3aA. Lorsque vous aviez 15 ans, quel était son statut dans emploi ?
count if missing(TP3aA) & (TP1A==1 | TP2A <9)
count if !missing(TP3aA) & !(TP1A==1 | TP2A <9)
count if !missing(TP3aA) & !inrange(TP3aA,1,10) 

** TP3A1. Lorsque vous aviez 15 ans, quelle était sa catégorie socioprofessionnelle ?
count if missing(TP3A1) & ((TP1A==1 | TP2A <9) & inlist(TP3aA,1,8,9))
count if !missing(TP3A1) & !((TP1A==1 | TP2A <9) & inlist(TP3aA,1,8,9))
count if !missing(TP3A1) & !inrange(TP3A1,1,8)  & TP3A1!=9998

** TP4A. Lorsque vous aviez 15 ans, dans quel type d'entreprise travaillait-il/elle ?
count if missing(TP4A) & (TP1A==1 | TP2A <9)
count if !missing(TP4A) & !(TP1A==1 | TP2A <9)
count if !missing(TP4A) & !inrange(TP4A,1,8)  & TP4A!=9998

** TP5A. Lorsque vous aviez 15ans, quel était son niveau d'instruction à cette période ?
count if missing(TP5A) & (TP1A==1 | TP2A <9)
count if !missing(TP5A) & !(TP1A==1 | TP2A <9)
count if !missing(TP5A) & !inrange(TP5A,0,12)  & TP5A!=9998

** TP6AA. Quel est le niveau d'instruction qu'il/elle a ou qu'il/elle avait atteint ?
count if missing(TP6AA) & (TP1A==1 | TP2A <9)
count if !missing(TP6AA) & !(TP1A==1 | TP2A <9)
count if !missing(TP6AA) & !inrange(TP6AA,0,12)  & TP6AA!=9998
count if !missing(TP6AA) & TP5A > TP6AA & TP5A<9998 & TP6AA<9998 & (TP1A==1 | TP2A <9)

drop champ_TP M4Confirm membre_id_v1_IND HH2 HH12 HH13

save "$standard_individu\INDIV_S14_activite_parents.dta", replace
