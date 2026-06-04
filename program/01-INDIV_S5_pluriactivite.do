
*********PLURIACTIVITE

****RESPONSABLE: SEKONGO 

***===========BROU
*=============================================

use "$datain_standard/INDIV_S5_pluriactivite.dta", clear

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard/INDIV_S3_emploi_principal.dta", keepus(EN_EMP) 

drop if _merge!=3
cap drop _merge

merge m:1 interview__key  using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH13)

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm) 

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)

drop if _merge!=3
cap drop _merge


*merge m:1 interview__key using "$datain_brute\qx_eec_vf.dta", keepus(HH2 HH3 HH13 HH4 HH6 HH8B)
*drop if _merge!=3
*cap drop _merge
////////////////////////////////////////////
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

////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
///////////////////////////////////////////

*****PL1.Au cours de la période du %DateJ7% au %DateJ0% , avez-vous eu d'autres emplois ou activités génératrices de revenus en dehors de votre activité/emploi principal ?


*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL1) & EN_EMP == 1
* 
* br if missing(PL1) & EN_EMP == 1
if r(N) > 0 {
export excel interview__key HH13 PL1  using "$folderpath/document/PL1_Manquants" if  missing(PL1) & EN_EMP == 1, firstrow(variables) replace
}

// La section semble vide pour ces individus

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL1) & EN_EMP ==0 // RAS car il s'agit des personnes qui sont en réalité pas en emploi et qui ont été identifiés dans la section emploi principal

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(PL1) & !inrange(PL1,1,2) 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 


*****PL2. Bien que vous n’ayez pas exercé d’autres emplois ou activités au cours de la période allant de la période du %DateJ7% au %DateJ0% , avez-vous l’habitude d’exercer d’autres emplois ou activités rémunérés de quelques types que ce soit en dehors de votre activité/emploi principal ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL2) & EN_EMP == 1 & PL1 == 2
* 
* br if missing(PL2) & EN_EMP == 1 & PL1 == 2

*correction 
replace PL2 = 2 if missing(PL2) & EN_EMP == 1 & PL1 == 2  
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
 count if !missing(PL2) & PL1==1
 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(PL2) & !inrange(PL2,1,2) 

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 


*****PL3. Combien d’emplois en dehors de votre emploi principal avez-vous ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL3) & (PL1 == 1 | PL2 == 1) & EN_EMP == 1 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL3) & (PL1 ==2 & PL2 == 2) 

*br if !missing(PL3) & (PL1 ==2  | PL2 == 2) 

*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
count if !missing(PL3) & PL3 <=0  
count if !missing(PL3) & PL3 > 10

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 


****PL3_B. Veuillez lister ces différentes activités secondaires (hormis l’activité principale) par ordre décroissant du nombre d’heures que vous leur consacrez par semaine.
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

* Générer une variable pour compter le nombre d'activités listées dans les colonnes PL3_B__0 à PL3_B__19


gen nb_activites_listees = 0

forvalues i = 0/19 {
    replace nb_activites_listees = nb_activites_listees + (PL3_B__`i' != "" & PL3_B__`i' !="")
}
count if nb_activites_listees != PL3 & !missing(PL3)
drop nb_activites_listees


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
forvalues i = 0/19 {
    * Compter combien de personnes ont renseigné une activité alors que PL3 est inférieur à 1
    count if !missing(PL3_B__`i') & PL3 < 1

    * Si des individus correspondent à cette condition, exporter leurs données
    if r(N) > 0 {
        export excel interview__key HH13 PL1 PL3 PL3_B__`i' using "$folderpath/document/PL3_B_verif_`i'.xlsx"if !missing(PL3_B__`i') & PL3 < 1, firstrow(variables) replace
        display "Exportation terminée pour PL3_B__`i' avec " r(N) " individus"
    }
    else {
        display "Pas de résultats pour PL3_B__`i'"
    }
}


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
forvalues i = 0/19 {
    * Compter et vérifier les réponses avec moins de 3 caractères dans chaque sous-variable de la question PL3_B
    count if length(PL3_B__`i') < 3 & !missing(PL3_B__`i')
    
    * Si des réponses avec moins de 3 caractères existent, les exporter dans un fichier excel 
    if r(N) > 0 {
        export excel interview__key HH13 PL3_B__`i' using "$folderpath/document/PL3_B__`i'.xlsx" if length(PL3_B__`i') < 3 & !missing(PL3_B__`i'), firstrow(variables) replace
        display "Exportation terminée pour PL3_B__`i' avec " r(N) " réponses de moins de 3 caractères"
    }
	*Si non ce message apparaittra
    else {
        display "Pas de réponses de moins de 3 caractères pour PL3_B__`i'"
    }
}

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*cap drop EN_EMP HH13 M4Confirm membre_id_v1_IND 
drop HH2

save "$standard_individu\INDIV_S5_pluriactivite.dta", replace 



*********Roster:ACTIVITES SECONDAIRES - %rostertitle%

cap drop merge
merge 1:m  interview__key membres__id  using "$datain_brute\r_activite_s.dta"
drop if _merge != 3
cap drop _merge
/*
use "$datain_brute\r_activite_s.dta", clear
merge m:1 interview__key using "$brute_menage_work", keepus(HH2 HH3 HH13 HH4 HH6 HH8B)
drop if _merge!=3
cap drop _merge

merge m:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(EN_EMP EP3 EP11 CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)
drop if _merge!=3
cap drop _merge
*/

*****PL3_C. Profession/Intitulé de poste
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(PL3_C) & EN_EMP == 1

/*
if r(N) > 0 {
export excel interview__key HH13 PL3_C  using "$folderpath/document/PL3_C" if  missing(PL3_C) & EN_EMP == 1, firstrow(variables) replace
}
*/

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL3_C) & EN_EMP == 0

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

count if length(PL3_C) <2 & !missing(PL3_C) 
* br if length(PL3_C) <2 & !missing(PL3_C)

** informations pas claires
if r(N) > 0 {
export excel interview__key HH13 PL3_C  using "$folderpath/document/PL3_C_2" if length(PL3_C) < 2 & !missing(PL3_C), firstrow(variables) replace
}

/*
****Correction: 
replace PL3_C="" if length(PL3_C) <2 & !missing(PL3_C)
*/

***PL3_D. Tâches
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL3_D) & EN_EMP == 1
/*
if r(N) > 0 {
export excel interview__key HH13 PL3_C  using "$folderpath/document/PL3_D" if missing(PL3_C) & EN_EMP == 1, firstrow(variables) replace
}
*/

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL3_D) & EN_EMP == 0


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 

count if length(PL3_D) < 2 & !missing(PL3_D)


***PL3_D1a. Choisissez l'emploi ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if  missing(PL3_D1a) & EN_EMP==1
/*
if r(N) > 0 {
export excel interview__key HH13 PL3_D1a  using "$folderpath/document/PL3_D1a" if missing(PL3_D1a), firstrow(variables) replace
}
**Correction: RAS
*/

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(PL3_D1a) & EN_EMP==0


*Etape3: Est ce que les reponses données sont celles qu'on atendait?
count if !missing(PL3_D1a) & !inrange(PL3_D1a, 970, 962012)


*Etape4: RAS

*******PL3_E.Donnez le nom de l’entreprise dans lequel vous exercer ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL3_E) & EN_EMP == 1

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL3_E) & EN_EMP==0

*Etape3: Est ce que les reponses données sont celles qu'on atendait? RAS

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

***PL3_F. Activité principale de l’entreprise
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL3_F) & EN_EMP == 1

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL3_F) & EN_EMP==0

*Etape3: Est ce que les reponses données sont celles qu'on atendait? RAS


****PL3_F1a. Choisissez l'activité ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if  missing(PL3_F1a) & EN_EMP==1
* 
* br if missing(PL3_F1a) & EN_EMP==1

if r(N) > 0 {
export excel interview__key HH13 PL3_F1a  using "$folderpath/document/PL3_F1a_Manquants" if missing(PL3_F1a), firstrow(variables) replace
}

**Correction: RAS
replace PL3_F1a = 73 if missing(PL3_F1a) & EN_EMP==1


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre?
count if !missing(PL3_F1a) & EN_EMP==0

*Etape3: Est ce que les reponses données sont celles qu'on atendait? RAS

*****PL3_G. Statut dans l’emploi

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL3_G) & EN_EMP==1


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL3_G) & EN_EMP==0 //RAS

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(PL3_G) & !inrange(PL3_G,1,10)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*****PL3_H. Combien d'heure octroyez vous à cette activité par semaine ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(PL3_H) & EN_EMP==1

/*
if r(N) > 0 {
export excel interview__key HH13 EN_EMP PL3_H  using "$folderpath/document/PL3_H" if missing(PL3_H) & EN_EMP==1, firstrow(variables) replace
}

*correction: 
cap drop med_PL3_H
egen med_PL3_H = median(PL3_H), by(EP3 EP11 code_citp_emp_principal)
replace PL3_H = med_PL3_H if PL3_H == .a
cap drop med_PL3_H
*/ //Pas necessaire dans notre cas.

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(PL3_H) & EN_EMP==0 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(PL3_H) & PL3_H >168
count if !missing(PL3_H) & PL3_H ==0 

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

***************Effacement des variables ajoutées
cap drop HH2 HH3 HH4 HH6 HH8B HH13 EN_EMP EP11 EP3 CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire

save "$dataout\r_activite_s.dta", replace

