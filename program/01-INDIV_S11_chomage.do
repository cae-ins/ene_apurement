*================================================
*********CHOMAGE

****RESPONSABLE: SEKONGO
*=============================================
*BROU
*=============================================
/*
use "$datain_brute\membres.dta", clear

merge m:1 interview__key using "$brute_menage_work", keepus(HH2 HH3 HH13 HH4 HH6 HH8B)
drop if _merge!=3
cap drop _merge

*/

****************************************
use "$datain_standard\INDIV_S11_chomage.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH2 HH3 HH12 HH13 HH4 HH6 HH8B)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP)
drop if _merge!=3
cap drop _merge


cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)
drop if _merge!=3
cap drop _merge
 

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S10_recherche_emploi_disponibilite.dta", keepus(SRH1 SRH2 SRH2A SRH11 )
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(membre_id_v1_IND) 
drop if _merge!=3
cap drop _merge


//////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
//////////////////////////////////////////////////////

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

**C2. Au cours de la période allant du %DateJ30% au %DateJ0% (30 jours), étiez-vous à la recherche d’un premier emploi ou avez-vous déjà travaillé pour une rémunération en espèce ou en nature (y compris le revenu obtenu de votre propre affaire ou champ ou celle ou celui de votre famille) ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C2) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & membre_id_v1_IND == "") & !inlist(M4Confirm, ., .a)

br if missing(C2) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & membre_id_v1_IND == "") & !inlist(M4Confirm, ., .a)


*Exportation 
if r(N) > 0 {
export excel interview__key HH12 HH13 C2  using "$folderpath/document/C2_Manquants" if missing(C2) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & membre_id_v1_IND == "") & !inlist(M4Confirm, ., .a),  firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C2) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C2) & !inrange(C2,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*****C6e. Si la durée de chômage venait à se prolonger, seriez-vous prêt à exercer une activité agricole (champ, élevage) ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C6e) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15  & membre_id_v1_IND == "") & !inlist(M4Confirm,.,.a)


*Exportation:
if r(N) > 0 {
export excel interview__key HH12 HH13 C6e  using "$folderpath/document/C6e_Manquants" if missing(C6e) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & membre_id_v1_IND == "") & !inlist(M4Confirm, ., .a),  firstrow(variables) replace
}

***Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C6e) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C6e) & !inrange(C6e,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

******C6e1. Si oui dans combien de mois ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C6e1) & C6e == 1 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C6e1) & C6e == 2

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if C6e1 ==0 // on peut supposer que l'individu est prêt à travailler immédiatement. 

br if C6e1 ==0

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

****C7a.Au cours de la période allant du %DateJ30% au %DateJ0% (30 jours), recherchiez-vous un emploi salarié ou indépendant ou peu importe ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C7a) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

br if missing(C7a) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

*Exportation: 
if r(N) > 0 {
export excel interview__key HH12 HH13 C7a  using "$folderpath/document/C7a_Manquants" if missing(C7a) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

**Correction: RAS  
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C7a) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C7a) & !inrange(C7a,1,3)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 

*Pour les individus qui on dit être à la recherche de leur premier emploi repondrons forcement à la question C7a
count if C2==2 & missing(C7a) //RAS

****C7b.Au cours de la période allant du %DateJ30% au %DateJ0% (30 jours) recherchiez-vous un emploi permanent ou temporaire ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C7b) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & ( M4Confirm>=15 & !inlist(M4Confirm, ., .a)) & membre_id_v1_IND == "")

br if missing(C7b) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & ( M4Confirm>=15 & !inlist(M4Confirm, ., .a)) & membre_id_v1_IND == "")


*Exportation
if r(N) > 0 {
export excel interview__key HH12 HH13 C7b  using "$folderpath/document/C7b_Manquants" if !missing(C7b) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & ( M4Confirm>=15 & !inlist(M4Confirm, ., .a)) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

**Correction: RAS
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C7b) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C7b) & !inrange(C7b,1,4)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
*Pour les individus qui on dit être à la recherche de leur premier emploi repondrons forcement à la question C7b
count if C2==2 & missing(C7b) //RAS


***C7c.Au cours de la période allant du %DateJ30% au %DateJ0% (30 jours), recherchiez-vous un emploi correspondant à votre métier ou pas ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C7c) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")


if r(N) > 0 {
export excel interview__key HH12 HH13 C7c  using "$folderpath/document/C7c_Manquants" if !missing(C7c) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}
****Correction: RAS 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C7c) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C7c) & !inrange(C7c,1,3)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
*Pour les individus qui on dit être à la recherche de leur premier emploi repondrons forcement à la question C7c
count if C2==2 & missing(C7c) //RAS



****C7c_A.Au cours de la période allant du %DateJ30% au %DateJ0% (30 jours), dans quel type d’organisation souhaitiez-vous travailler principalement ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C7c_A) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")



if r(N) > 0 {
export excel interview__key HH12 HH13 C7c_A  using "$folderpath/document/C7c_A_Manquants" if missing(C7c_A) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

***Correction: RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C7c_A) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C7c_A) & !inrange(C7c_A,1,11)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 

count if (inlist(C7a, 1,3) & missing(C7c_A)) | ((C7a == 2 & inrange(C7c_A, 1,3)) & (C7a == 2 & C7c_A == 7))

*Pour les individus qui on dit être à la recherche de leur premier emploi repondrons forcement à la question C7c_A
count if C2==2 & missing(C7c_A) //RAS


******C7d. Dans quel domaine d’activité souhaitiez-vous travailler principalement au cours de la période allant du %DateJ30% au %DateJ0% (30 jours) ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C7d) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm,.,.a) & membre_id_v1_IND == "")


if r(N) > 0 {
export excel interview__key HH12 HH13 C7d  using "$folderpath/document/C7d_Manquants" if missing(C7d) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

**Correction :RAS

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C7d) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C7d) & !inrange(C7d,1,5)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
*Pour les individus qui on dit être à la recherche de leur premier emploi repondrons forcement à la question C7d
count if C2==2 & missing(C7d) //RAS


******C7e. Quelle profession aimeriez-vous exercez principalement ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C7e) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

br  if missing(C7e) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

if r(N) > 0 {
export excel interview__key HH13  C7e  using "$folderpath/document/C7e_Manquant" if missing(C7e) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C7e) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C7e) & !inrange(C7b,1,4)


*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
*Pour les individus qui on dit être à la recherche de leur premier emploi repondrons forcement à la question C7e
count if C2==2 & missing(C7e) //RAS

***************************************************************
*****C9. Pendant combien d'heures désirez-vous travailler par semaine ? 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C9) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

*Afficher ces valeurs 
*br interview__key C9 if missing(C9) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

if r(N) > 0 {
export excel interview__key HH12 HH13 C9 using "$folderpath/document/C9" if missing(C9) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}
***Correction: RAS: Il s'agit du même individu

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C9) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if  !missing(C9) & C9 > 56 
count if !missing(C9) & C9 <=0
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


*****C10b1. Quel était le montant du salaire ou reve nu mensuel minimum acceptable (en FCFA) pour vous cours de la période allant du %DateJ30% au %DateJ0% (30 jours)?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C10b1) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")


*Afficher ces valeurs 

if r(N) > 0 {
export excel interview__key HH12 HH13 C10b1 using "$folderpath/document/C10b1" if missing(C10b1) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}
***Correction: RAS
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C10b1) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C10b1) & C10b1 <=0
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


*C10b1a. Quel était le montant du salaire ou rev enu mensuel minimum acceptable (en FCFA) po ur vous cours de la période allant du %DateJ30 % au %DateJ0% (30 jours)?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C10b1a) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C10b1a) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

**Correction: RAS

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

**** C10b. Etes-vous disposé à revoir à la baisse vos prétentions si la période de chômage se prolon ge ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C10b) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

if r(N) > 0 {
export excel interview__key HH13 C10b using "$folderpath/document/C10b" if missing(C10b) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

**Correction: RAS: Il s'agit du même individu dont les valeurs sont manquantes 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C10b) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "" ))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C10b) & !inrange(C10b,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

****C10c.Si vous deviez revoir vos prétentions à la baisse, quel serait le salaire ou revenu mensuel minimum acceptable ( en FCFA) ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C10c) & C10b == 1

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C10c) &  C10b == 2 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C10c)& C10c<=0

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS
count if C10c >= C10b1 & C10c != .

***C10c1. Si vous deviez revoir vos prétentions à l a baisse, quel serait le salaire ou revenu mensu el minimum acceptable ( en FCFA)

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C10c1) & C10b == 1

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C10c1) & C10b == 2

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 


*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*******C11. Avez-vous déjà eu de l'expérience par rapport à cet emploi? 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C11) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")


if r(N) > 0 {
export excel interview__key HH12 HH13 C11 using "$folderpath/document/C11_Manquants" if missing(C11) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C11) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != ""))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C11) & !inrange(C11,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS
count if !missing(C11) & missing(C7e)


*******C12a. Etes-vous inscrit auprès d’une structure de promotion de l'emploi ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C12a) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == "")

if r(N) > 0 {
export excel interview__key HH12 HH13 C12a using "$folderpath/document/C12a_Manquants" if missing(C12a) & (EN_EMP == 0 & (SRH1 == 1 | SRH2 == 1 | SRH2A == 1) & SRH11== 1 & M4Confirm>=15 & !inlist(M4Confirm, ., .a) & membre_id_v1_IND == ""),  firstrow(variables) replace
}

**Correction: RASS 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C12a) & (EN_EMP == 1 | (SRH1 != 1 & SRH2 != 1 & SRH2A != 1) | SRH11!= 1 | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != ""))

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C12a) & !inrange(C12a,1,2)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*****C12b. Auprès de quelles structures ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

forvalues i = 1/8 {
    * Compter combien de personnes avec C12a == 1 ont des réponses manquantes pour chaque sous-variable de C12b
    count if missing(C12b__`i') & C12a == 1 
    
    * Si des réponses manquantes existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 C12a C12b__`i' using "$folderpath/document/C12b_1__`i'.xlsx" if C12a == 1 & missing(C12b__`i'), firstrow(variables) replace
        display "Exportation terminée pour C12b__`i' avec " r(N) " réponses manquantes"
    }
    * Si pas de réponses manquantes, afficher un message
    else {
        display "Pas de réponses manquantes pour C12b__`i'"
    }
}


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 

forvalues i = 1/8 {
    * Compter les personnes qui ont répondu à C12b alors qu'elles ne devaient pas (C12a != 1)
    count if  !missing(C12b__`i') & C12a == 2 
    
    * Si des réponses existent alors qu'elles ne devaient pas, exporter ces individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 C12a C12b__`i' using "$folderpath/document/C12b_2__`i'.xlsx" if C12a != 1 & !missing(C12b__`i'), firstrow(variables) replace
        display "Exportation terminée pour C12b__`i' avec " r(N) " réponses inattendues"
    }
    * Si aucune réponse inattendue, afficher un message
    else {
        display "Pas de réponses inattendues pour C12b__`i'"
    }
}


*********Etape3: Est-ce que les réponses données sont celles qu'on attendait pour C12b?

forvalues i = 1/8 {
    * Vérification des réponses données dans C12b__`i'
    count if !missing(C12b__`i') & !inrange(C12b__`i', 0, 1)
    
    * Si des réponses inattendues existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 C12b__`i' using "$folderpath/document/C12b_3__`i'.xlsx" if !missing(C12b__`i') & !inrange(C12b__`i', 0, 1), firstrow(varlabels) replace
        display "Exportation terminée pour C12b__`i' avec " r(N) " réponses inattendues"
    }
    else {
        display "Toutes les réponses sont correctes pour C12b__`i'"
    }
}


*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*****C12b_Aut. Veuillez préciser 

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C12b_Aut) & C12b__8 ==1

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C12b_Aut) & C12b__8 ==0

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*count if !missing(C12b_Aut) & !inrange(C12b_Aut,1,0)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 


*****C12c Qu'attendez-vous de cette (ces) structure ? 

*********Étape 1: Vérification des réponses manquantes pour C12c

forvalues i = 1/4 {
    * Vérifier les réponses manquantes dans C12c__`i' sous la condition C12a == 1
    count if C12a == 1 & missing(C12c__`i')
    
    * Si des réponses manquantes existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 C12c__`i' using "$folderpath/document/C12c_manquant__`i'.xlsx" if C12a == 1 & missing(C12c__`i'), firstrow(varlabels) replace
        display "Exportation terminée pour C12c__`i' avec " r(N) " réponses manquantes"
    }
    else {
        display "Pas de réponses manquantes pour C12c__`i'"
    }
}


*********Étape 2: Vérification de la cohérence des sauts pour C12c

forvalues i = 1/4 {
    * Vérifier si ceux qui ont répondu à C12c__`i' devaient effectivement répondre (sous la condition C12a == 1)
    count if C12a != 1 & !missing(C12c__`i')
    
    * Si des réponses non prévues existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 C12c__`i' using "$folderpath/document/C12c_saut__`i'.xlsx" if C12a != 1 & !missing(C12c__`i'), firstrow(varlabels) replace
        display "Exportation terminée pour C12c__`i' avec " r(N) " réponses inattendues (cohérence des sauts)"
    }
    else {
        display "Toutes les réponses sont cohérentes pour C12c__`i'"
    }
}

*********Étape 3: Est-ce que les réponses données sont celles qu'on attendait pour C12c

forvalues i = 1/4 {
    * Vérifier les réponses données dans C12c__`i' sous la condition C12a == 1
    count if C12a == 1 & !missing(C12c__`i') & !inrange(C12c__`i', 0, 1)
    
    * Si des réponses inattendues existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 C12c__`i' using "$folderpath/document/C12c_unexpected__`i'.xlsx" if C12a == 1 & !missing(C12c__`i') & !inrange(C12c__`i', 0, 1), firstrow(varlabels) replace
        display "Exportation terminée pour C12c__`i' avec " r(N) " réponses inattendues"
    }
    else {
        display "Toutes les réponses sont correctes pour C12c__`i'"
    }
}


***** C12c_aut. Veuillez précise

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C12c_aut) & C12c__4 ==1

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C12c_aut) & C12c__4 ==0
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*count if !missing(C12c_aut) & !inrange(C12c_aut,1,0)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 



******C12d Pourquoi n'êtes vous  pas inscrit auprès d'une telle structure? 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C12d) & C12a==2

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C12d) & C12a!=2

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(C12d) & !inrange(C12d,1,4)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS


***** C12d_Aut. Veuillez précise

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(C12d_Aut) & C12d== 4

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(C12d_Aut) & C12d != 4

*Etape3: Est ce que les reponses données sont celles qu'on atendait? RAS
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 



cap drop HH2 HH3 HH4 HH6 HH8B HH12 HH13 EN_EMP M4Confirm SRH1 SRH2 SRH2A SRH11 membre_id_v1_IND

save "$standard_individu\INDIV_S11_chomage.dta", replace


