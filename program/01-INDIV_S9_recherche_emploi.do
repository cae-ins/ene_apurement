
*********RECHERCHE D'UN AUTRE EMPLOI

****RESPONSABLE: SEKONGO 
*=============================================

*********************************
**** BROU
**********Importation 
*global datain_brute "C:\apurement_ENE\bases"
*display "$datain_brute"

use "$datain_standard\INDIV_S9_recherche_emploi.dta",clear

*****Appel des autres variables
cap drop _merge 
merge m:1 interview__key  using "$datain_standard\QM_S0_identification.dta", keepusing(HH13)

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm) 

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP)

drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(membre_id_v1_IND) 
drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S8_emploi_inadequat.dta", keepus(WKI3)

drop if _merge!=3
cap drop _merge

************************************
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



*******************************************
***********|||RECHERCHE D’UN AUTRE EMPLOI POUR LES PERSONNES EN EMPLOI (R)******************

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Cohérence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 

/////////
*********R1. L’emploi que vous recherchez ou êtes dispo nible à exercer est –il un emploi salarié ou indé pendant ou peu importe?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(R1) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")
* 
* br if missing(R1) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")

count if missing(R1) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")
if r(N)>0 {
    export excel interview__key HH13 R1  using "$folderpath/document/WKI7_Aut_Incoherants" if missing(R1) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == ""), firstrow(variables) replace
}


*Etape2: Cohérence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(R1) & (EN_EMP == 0 | !inlist(WKI3,1,2) | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != ""))

*Etape3: Est ce que les reponses données sont celles qu'on attendait?
count if !missing(R1) & !inrange(R1,1,3) 

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

****R2.L’emploi que vous recherchez ou êtes dispo nible à exercer est –il un emploi permanent ou temporaire ou peu importe?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(R2) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")
* 
* br if missing(R2) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")

count if missing(R2) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")
if r(N)>0 {
    export excel interview__key HH13 R2  using "$folderpath/document/R2_Manquants" if missing(R2) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == ""), firstrow(variables) replace
}

*Etape2: Cohérence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(R2) & (EN_EMP == 0 | !inlist(WKI3,1,2) | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != ""))

*Etape3: Est ce que les reponses données sont celles qu'on attendait?
count if !missing(R2) & !inrange(R2,1,4) 

*Etape4: Les reponses données sont elles coherentes au regard des precedentes?: on devrait s'attendre 
count if R2 == 1 & WKI3 == 2


*****R3. Dans quel type d’organisation souhaitez-vous travailler? 
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(R3) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")
* 
* br if missing(R3) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")

count if missing(R3) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == "")
if r(N)>0 {
    export excel interview__key HH13 R3  using "$folderpath/document/R3_Manquants" if missing(R3) & (EN_EMP == 1 & inlist(WKI3,1,2) & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)) & membre_id_v1_IND == ""), firstrow(variables) replace
}

*Etape2: Cohérence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(R3) & (EN_EMP == 0 | !inlist(WKI3,1,2) | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != ""))

*Etape3: Est ce que les reponses données sont celles qu'on attendait?
count if !missing(R3) & !inrange(R3,1,11) 

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 

count if inlist(R1, 1,3) & !inrange(R3, 1, 11)
count if R1 ==  2 & (inrange(R3, 1,4) | R3 == 7)
 

***R4. Revenons sur vos démarches de recherche d’emploi du %DateJ30% au %DateJ0% . Qu’est-c e que vous avez fait pour trouver un autre emp loi?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

forvalues i = 1/19 {
    * Compter les réponses manquantes pour les personnes qui devaient répondre
    count if missing(R4__`i') & (EN_EMP == 1 & inlist(WKI3, 1, 2) & (M4Confirm >= 15 & !inlist(M4Confirm, ., .a)) & membre_id_v1_IND == "")
    
    * Si des réponses manquantes existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 R4__`i' using "$folderpath/document/R4__`i'_manquants.xlsx" if missing(R4__`i') & (EN_EMP == 1 & inlist(WKI3, 1, 2) & (M4Confirm >= 15 & !inlist(M4Confirm, ., .a)) & membre_id_v1_IND == ""), firstrow(variables) replace
        display "Exportation terminée pour R4__`i' avec " r(N) " réponses manquantes"
    }
    else {
        display "Toutes les réponses sont présentes pour R4__`i'"
    }
* br if missing(R4__`i') & (EN_EMP == 1 & inlist(WKI3, 1, 2) & (M4Confirm >= 15 & !inlist(M4Confirm, ., .a)) & membre_id_v1_IND == "")
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 

forvalues i = 1/19 {
    * Compter les réponses fournies par des personnes qui ne devaient pas répondre
    count if !missing(R4__`i') & (EN_EMP == 0 | !inlist(WKI3,1,2) | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != ""))
    
    * Si des réponses incohérentes existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 R4__`i' using "$folderpath/document/R4__`i'_coherence_sauts.xlsx" if !missing(R4__`i') & (EN_EMP == 0 | !inlist(WKI3,1,2) | (M4Confirm<15 & !inlist(M4Confirm,.,.a)) | (membre_id_v1_IND != "" & membre_id_v1_IND != "")), firstrow(variables) replace
        display "Exportation terminée pour R4__`i' avec " r(N) " réponses incohérentes"
    }
    else {
        display "Toutes les réponses sont cohérentes pour R4__`i'"
    }
}


*Etape3: Est ce que les reponses données sont celles qu'on attendait? 
forvalues i = 1/16 {
    * Compter les réponses inattendues, c'est-à-dire celles qui ne sont pas dans les valeurs attendues (par exemple, 1 à 16)
    count if !missing(R4__`i') & !inrange(R4__`i', 0, 1) 
    
    * Si des réponses inattendues existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 R4__`i' using "$folderpath/document/R4__`i'_reponses_inattendues.xlsx" if !missing(R4__`i') & !inrange(R4__`i', 1, 16) , firstrow(variables) replace
        display "Exportation terminée pour R4__`i' avec " r(N) " réponses inattendues"
    }
    else {
        display "Toutes les réponses sont correctes pour R4__`i'"
    }
}


*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS

*****R4_Aut. Veuillez préciser
**etape 1:  Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(R4_Aut) & R4__19 == 1

//Etape 2, 3, et 4 ne valent pas la peine d'être vérifiees car la variable est vides

drop HH13 M4Confirm EN_EMP membre_id_v1_IND WKI3

save "$standard_individu\INDIV_S9_recherche_emploi.dta", replace