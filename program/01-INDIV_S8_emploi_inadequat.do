*================================================
*********SITUATION D'EMPLOI INADEQUATES

****RESPONSABLE: SEKONGO 
*=============================================

**********Importation 
*global datain_brute "C:\apurement_ENE\bases"
*display "$datain_brute"

use "$datain_standard\INDIV_S8_emploi_inadequat.dta", clear

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


**************Fin appel de variables*****************

********************************
**********************************Emploi inadéquat*****************************************
/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
///////////////////////////////////////////////////////////////////////////


***WKI1. Souhaitez-vous changer votre emploi actuel?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(WKI1) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH13 WKI1  using "$folderpath/document/WKI1" if missing(WKI1) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a), firstrow(variables) replace
}
***Correction:Toute la section est vide pour ces individus

/*
ed  interview__key interview__id membres__id if missing(WKI1) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)
*/


  

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI1) & (EN_EMP == 0 | M4Confirm<15) // RAS car il s'agit des personnes qui n'était pas en emploi et qui ont été identifié dans la section emploi principal

*correction
replace WKI1=. if !missing(WKI1) & (EN_EMP == 0 | M4Confirm<15)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI1) & !inrange(WKI1,1,3)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
***Verification pour voir si ceux qui veulent changer d'emploi actuel d'autre ne sont pas en emploi 


*WKI2. Quelles sont les principales raisons pour lesquelles vous voulez changer votre situation d’emploi ?
*************|||||Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*** Boucle pour vérifier les réponses manquantes pour chaque sous-question de WKI2 et les exporter si elles existent: 

forvalues i = 1/13 {
    * Compter combien de personnes devaient répondre mais n'ont pas répondu pour chaque sous-variable de WKI2
count if  missing(WKI2__`i') & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) & inlist(WKI1, 1, 2) 
    
    * Si il existe des réponses manquantes, les exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 WKI2__`i' using "$folderpath/document/WKI2__`i'.xlsx" if  EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) & inlist(WKI1, 1, 2) & missing(WKI2__`i'), firstrow(variables) replace
        display "Exportation terminée pour WKI2__`i' avec " r(N) " réponses manquantes"
    }
	*Si pas d'erreurs alors  le message suivant apparaittra
    else {
        display "Pas de réponses manquantes pour WKI2__`i'"
    }
}


**correction
/*
forvalues i = 1/13 {
    * Remplace les valeurs manquantes .a par 0 dans chaque variable WKI2__`i'
    replace WKI2__`i' = 0 if WKI2__`i' == .a
}
*/


*************Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
***Les identifier et les exporter s'ils existent apres identification____
forvalues i = 1/13 {
    * Vérification des individus qui ont répondu à WKI2 mais ne devaient pas y répondre
    *count if !inlist(WKI1, 1, 2) & !missing(WKI2__`i')
    
	count if !missing(WKI2__`i') & (EN_EMP ==0  | M4Confirm < 15 |  !inlist(WKI1, 1, 2)) & !inlist(M4Confirm, ., .a)
	
	
} // RAS car il s'agit des personnes qui n'était pas en emploi et qui ont été identifié dans la section emploi principal 


*correction

forvalues i = 1/13 {
   
	replace WKI2__`i' =. if !missing(WKI2__`i') & (EN_EMP ==0  | M4Confirm < 15 |  !inlist(WKI1, 1, 2)) & !inlist(M4Confirm, ., .a)
    	
}



*********Etape3: Est ce que les reponses données sont celles qu'on atendait? 

forvalues i = 1/13 {
    * Vérification des réponses données dans WKI2
    count if !missing(WKI2__`i') & !inrange(WKI2__`i', 0, 1)
    
    * Si des réponses inattendues existent, exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 WKI2__`i' using "$folderpath/document/WKI2_unexpected__`i'.xlsx" if !missing(WKI2__`i') & !inrange(WKI2__`i', 0, 1), firstrow(varlabels) replace
        display "Exportation terminée pour WKI2__`i' avec " r(N) " réponses inattendues"
    }
    else {
        display "Toutes les réponses sont correctes pour WKI2__`i'"
 }
}



*Etape4: Les reponses données sont elles coherentes au regard des precedentes?: RAS 

***WKI2_Aut. Veuillez préciser ?

**Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(WKI2_Aut) & WKI2__13 == 1

if r(N) > 0 {
export excel interview__key HH13 WKI2__13 WKI2_Aut using "$folderpath/document/WKI2_Aut_manquants" if missing(WKI2_Aut) & WKI2__13 == 1, firstrow(variables) replace
}
***Correction: necessite de revenir aux agents

**Etape2: Coherence des sauts
count if !missing(WKI2_Aut) & WKI2__13 == 0

**Correction
replace WKI2_Aut = "" if !missing(WKI2_Aut) & WKI2__13 == 0

** Etape3 et 4 : Dejà effectué lors du récodage des autres à préciser


******WKI3. Au cours de la période allant du %DateJ30% au %DateJ0% , avez-vous cherché un travail supplémentaire ou un autre travail rémunéré ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(WKI3) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH13 WKI3  using "$folderpath/document/WKI3" if missing(WKI3) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a), firstrow(variables) replace
}

***Correction : elle necessite de revenir aux agents

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI3) & (EN_EMP == 0 |  M4Confirm<15) // RAS car il s'agit des personnes qui n'était pas en emploi et qui ont été identifié dans la section emploi principal 

replace WKI3 =. if !missing(WKI3) & (EN_EMP == 0 |  M4Confirm<15)

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI3) & !inrange(WKI3,1,3)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 


*****WKI4. Dans la période allant du %DateJ30% à %DateJ0% , vouliez-vous travailler plus d’heures par semaine que d’habitude, à condition que les heures supplémentaires soient payées ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(WKI4) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH13 WKI4  using "$folderpath/document/WKI4" if missing(WKI4) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a), firstrow(variables) replace
}

***Correction : Les reponses données sont elles coherentes au regard des precedentes?


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI4) & (EN_EMP == 0 |  M4Confirm<15) // RAS car il s'agit des personnes qui n'était pas en emploi et qui ont été identifié dans la section emploi principal 

replace WKI4=. if !missing(WKI4) & (EN_EMP == 0 |  M4Confirm<15)


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI4) & !inrange(WKI4,1,2)

*****WKI5. Auriez-vous pu commencer à travailler plus d’heures au cours des deux semaines suivantes, c’est-à-dire du %DateJ_1% à %DateJ_14% ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(WKI5) & EN_EMP == 1 & WKI4 == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

if r(N) > 0 {
export excel interview__key HH13 WKI5  using "$folderpath/document/WKI5" if missing(WKI5) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a), firstrow(variables) replace
}

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI5) & (EN_EMP == 0 |  M4Confirm<15 | WKI4 ==2) 

replace WKI5=. if !missing(WKI5) & (EN_EMP == 0 |  M4Confirm<15 | WKI4 ==2) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI5) & !inrange(WKI5,1,2)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 

***WKI6. Combien d’heures supplémentaires par semaine pourriez-vous travailler ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(WKI6) & WKI5==1 & membre_id_v1_IND== "##N/A##" 

/*
if r(N) > 0 {
export excel interview__key HH13 WKI6  using "$folderpath/document/WKI6" if missing(WKI6) & WKI5==1 & membre_id_v1 == "##N/A## " & EN_EMP == 1, firstrow(variables) replace
}
*/

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI6) & (WKI5==2 | (membre_id_v1_IND != "##N/A##" & membre_id_v1_IND !=""))

*export excel interview__key HH13 WKI6  using "$folderpath/document/WKI6_1" if !missing(WKI6) & (WKI5==2 | membre_id_v1 == "##N/A## " | membre_id_v1 == ""), firstrow(variables) replace

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI6) & WKI6<=0
count if !missing(WKI6) & WKI6>168 & WKI6!=9998

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
*Verifier voir si un individu affirme pouvoir commencer à travailler plus d’heures au cours des deux semaines suivantes (WKI5) et viens affirmer qu'il ne peut pas travailler des heures supplémentaires c'est dire WKI6 =0
count if WKI5==1 & WKI6<=0

***WKI7. Pourquoi n’avez-vous pas cherché un aut re emploi ou pourquoi ne souhaitez-vous pas c hercher un nouvel emploi ? 

*Etape1

count if missing(WKI7) & ((WKI3 == 3 |  WKI1==3) & membre_id_v1_IND == "##N/A##")

*Etape2 

count if !missing(WKI7) & ((WKI3 != 3 &  WKI1!=3) | membre_id_v1_IND != "##N/A##" & membre_id_v1_IND !="") // RAS car il s'agit des personnes n'étant pas en emploi identifié dans la section EP

*correction 

replace WKI7=. if EN_EMP ==0


*Etape3 & Etape4 RAS


*****WKI7_Aut. Veuillez préciser ?

**Etape1

count if missing(WKI7_Aut) & WKI7 == 7

**Etape2
count if !missing(WKI7_Aut) & WKI7 != 7

*Des individus ont repondu pourtant ils ne devaient pas le faire 
*br WKI7_Aut WKI7 if !missing(WKI7_Aut) & WKI7 != 7

/*
export excel interview__key HH13 WKI7 WKI7_Aut  using "$folderpath/document/WKI7_Aut_Incoherants" if !missing(WKI7_Aut) & WKI7 != 7, firstrow(variables) replace
*/

**Etape3 & Etape1 : dejà regardé lors du recodage des autres à préciser. 


drop HH13 M4Confirm EN_EMP membre_id_v1_IND

save "$standard_individu\INDIV_S8_emploi_inadequat.dta", replace