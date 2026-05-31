*================================================
*********ACTIVITE DES PARENTS

****RESPONSABLE: SEKONGO

**BROU
*=============================================

*use "$datain_brute\qx_eec_vf.dta", clear

use "$datain_brute\Activiteparent.dta" , clear

cap drop _merge

merge m:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(M4Confirm membre_id_v1_IND TP7  TP1A TP2A TP3aA TP4A TP5A TP6AA TP3A1 TP4A TP5A TP6AA)
keep if _merge == 3
cap drop _merge

merge m:1 interview__key using "$brute_menage_work" , keepus( rgmen MODINTR HH2 HH3 HH4 HH12 HH13 HH3)

*use "$datain_brute\qx_eec_vf.dta" ,clear

keep if _merge == 3
cap drop _merge

**********************************Activité des parents**********
/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
///////////////////////////////////////////////////////////////////////////

**# Supprimer les espaces au tour des variables textes dans la base
ds, has(type string)
foreach var of varlist `r(varlist)'{
	replace `var' = ustrregexra(`var', "\s+$", "")
	replace `var' = strltrim(`var')
}


**# Convertir les champs vides représentés par ##N/A## par ""

ds, has(type string)
foreach var of varlist `r(varlist)'{
	replace `var' = "" if `var' == "##N/A##"

}

/////////////////////////////////////////////////////////////////


**TP1.Lorsque vous aviez 15 ans, Votre %rostertitle% avait-il/elle un emploi ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
 
count if missing(TP1) & ( membre_id_v1_IND =="" & rgmen == 1 & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)))

br if missing(TP1) & ( membre_id_v1_IND =="" & rgmen == 1 & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)))
 
*Des personnes pour qui on a pas de reponse à la question, alors que cela devrait pas etre le cas.  individus concernés et pour lesquels toute la section n'est pas renseignée  


if r(N) > 0 {
export excel interview__key HH13 TP1  using "$folderpath/document/TP1_manquants" if missing(TP1) & ( membre_id_v1_IND =="" & rgmen == 1 & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))),firstrow(variables) replace
}


***** la section semble vide pour ces individus

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP1) & !(membre_id_v1_IND =="" | (M4Confirm>=15 | rgmen == 1 | !inlist(M4Confirm,.,.a)))

 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP1) & !inlist(TP1,1,2,3,9998)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


** TP2. Lorsque vous aviez 15 ans, bien que vous ayez déclaré que cette personne ne travaillait pas est-ce qu’elle/il pratiquait l'une des activités suivantes à domicile ou à l'extérieur, pour aider la famille ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
 
count if missing(TP2) & inlist(TP1,2,9998)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP2) & !inlist(TP1,2,9998)
 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP2) & !inrange(TP2,1,9) & TP2!=9998
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


** TP3a. Lorsque vous aviez 15 ans, quel était son statut dans emploi ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
 
count if missing(TP3a) & (TP1 == 1 | TP2 < 9) 


*br if missing(TP3a) & (TP1 == 1 | TP2 < 9) // Pas de problèmes detectés


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP3a) & !(TP1 == 1 | TP2 < 9)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP3a) & !inrange(TP3a,1,10) 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

****TP3a_Aut. Veuillez préciser
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP3a_Aut) & TP3a==10

br if !missing(TP3a_Aut) & TP3a==10

if r(N) > 0 {
export excel interview__key HH13 TP3a_Aut  using "$folderpath/document/TP3a_Aut" if !missing(TP3a_Aut) & TP3a==10,firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP3a_Aut) & TP3a!=10

** TP3. Lorsque vous aviez 15 ans, quelle était sa catégorie socioprofessionnelle ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
 
count if missing(TP3) & ((TP1 == 1 | TP2 < 9) & inlist(TP3a, 1, 8, 9))

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP3) & !((TP1 == 1 | TP2 < 9) & inlist(TP3a, 1, 8, 9))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP3) & !inrange(TP3,1,8)  &  TP3!=9998
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

**TP3_Aut. Veuillez préciser
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP3_Aut) & TP3==8

br if !missing(TP3_Aut) & TP3==8

if r(N) > 0 {
export excel interview__key HH13 TP3_Aut  using "$folderpath/document/TP3_Aut" if !missing(TP3_Aut) & TP3==8,firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP3_Aut) & TP3!=8

** TP4. Lorsque vous aviez 15 ans, dans quel type d'entreprise travaillait-il/elle ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
 
count if missing(TP4) & (TP1 == 1 | TP2 < 9) 

br if missing(TP4) & (TP1 == 1 | TP2 < 9)

if r(N) > 0 {
export excel interview__key HH13 TP4  using "$folderpath/document/TP4_manquants" if missing(TP4) & (TP1 == 1 | TP2 < 9),firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP4) & !(TP1 == 1 | TP2 < 9) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP4) & !inrange(TP4,1,8)  &  TP4!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

** TP5. Lorsque vous aviez 15ans, quel était son niveau d’instruction à cette période ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
 
count if missing(TP5) & (TP1 == 1 | TP2 < 9)  

br if missing(TP5) & (TP1 == 1 | TP2 < 9) 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP5) & !(TP1 == 1 | TP2 < 9) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP5) & !inrange(TP4,1,12)  &  TP4!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

** TP6A. Quel est le niveau d’instruction qu’il/elle a ou qu’il/elle avait atteint  ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP6A) & (TP1 == 1 | TP2 < 9)  // 2 cas où la réponse n'a pas été fournie alors qu'elle le devrait. Pas de correction possible.

br if missing(TP6A) & (TP1 == 1 | TP2 < 9)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP6A) & !(TP1 == 1 | TP2 < 9) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP6A) & !inrange(TP6A,0,12) & TP6A!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


** TP7. Avant l’âge de 15 ans, chez qui avez-vous vécu en grande partie ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP7) &  ( membre_id_v1_IND =="" & rgmen == 1 &  (M4Confirm>=15 & !inlist(M4Confirm,.,.a)))  

br if missing(TP7) &  ( membre_id_v1_IND =="" & rgmen == 1 &  (M4Confirm>=15 & !inlist(M4Confirm,.,.a))) 

if r(N) > 0 {
export excel interview__key HH13 TP7  using "$folderpath/document/TP7_manquants" if missing(TP7) &  ( membre_id_v1_IND =="" & rgmen == 1 &  (M4Confirm>=15 & !inlist(M4Confirm,.,.a))),firstrow(variables) replace
}

***Correction : ce sont les memes individus qu'a la question TP1A

replace TP7=. if TP7==.a &  ( membre_id_v1_IND =="" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))) 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP7) & !( membre_id_v1_IND =="" | rgmen == 1 | (M4Confirm>=15 | !inlist(M4Confirm,.,.a))) 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP7) & !inrange(TP7,1,7) 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


** TP1A.Lorsque vous aviez 15 ans, votre tuteur/tutrice avait-il/-elle un emploi ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?

count if missing(TP1A) &   inlist(TP7,4,5)
*br if !missing(TP1A) &   inlist(TP7,4,5)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP1A) & !inlist(TP7,4,5)


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP1A) & !inrange(TP1A,1,2) & TP1A!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

** TP2A. Lorsque vous aviez 15 ans, bien que vous ayez déclaré que cette personne ne travaillait pas est-ce qu’elle/il pratiquait l'une des activités suivantes à domicile ou à l'extérieur, pour aider la famille ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP2A) &   inlist(TP1A,2,9998)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP2A) & !inlist(TP1A,2,9998)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP2A) & !inrange(TP2A,1,9) & TP2A!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

** TP3aA. Lorsque vous aviez 15 ans, quel était son statut dans emploi ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP3aA) & (TP1A==1 | TP2A <9)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP3aA) & !(TP1A==1 | TP2A <9)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP3aA) & !inrange(TP3aA,1,10) 

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


** TP3A1. Lorsque vous aviez 15 ans, quelle était sa catégorie socioprofessionnelle ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP3A1) & ((TP1A==1 | TP2A <9) & inlist(TP3aA,1,8,9))

/*
if r(N) > 0 {
export excel interview__key HH13 TP7  using "$folderpath/document/TP3A1_manquants" if missing(TP3A1) & ((TP1A==1 | TP2A <9) & inlist(TP3aA,1,8,9) ) ,firstrow(variables) replace
}

**correction
replace TP3A1 = 7 if TP4A == 8 & missing(TP3A1) & ((TP1A==1 | TP2A <9) & inlist(TP3aA,1,8,9) )
*/

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP3A1) & !((TP1A==1 | TP2A <9) & inlist(TP3aA,1,8,9))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP3A1) & !inrange(TP3A1,1,8)  & TP3A1!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

** TP4A. Lorsque vous aviez 15 ans, dans quel type d'entreprise travaillait-il/elle ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP4A) & (TP1A==1 | TP2A <9)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP4A) & !(TP1A==1 | TP2A <9)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP4A) & !inrange(TP4A,1,8)  & TP4A!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS



** TP5A. Lorsque vous aviez 15ans, quel était son niveau d’instruction à cette période ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP5A) & (TP1A==1 | TP2A <9)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP5A) & !(TP1A==1 | TP2A <9)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP5A) & !inrange(TP5A,0,12)  & TP5A!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

** TP6AA. Quel est le niveau d’instruction qu’il/elle a ou qu’il/elle avait atteint  ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu?
count if missing(TP6AA) & (TP1A==1 | TP2A <9)

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(TP6AA) & !(TP1A==1 | TP2A <9)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(TP6AA) & !inrange(TP6AA,0,12)  & TP6AA!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


drop M4Confirm membre_id_v1_IND TP7  TP1A TP2A TP3aA TP4A TP5A TP6AA HH2 HH3 HH4 HH12 HH13 HH3 MODINTR

save "$standard_individu\INDIV_S14_activite_parents.dta" , replace
