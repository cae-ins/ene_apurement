*================================================
*********SITUATION D'EMPLOI INADEQUATES

****RESPONSABLE: KOUADIO BROU YVES
*=============================================
**********Importation 
*global datain_brute "C:\apurement_ENE\bases"
*display "$datain_brute"

use "$datain_standard\INDIV_S8_emploi_inadequat.dta", clear

*****Appel des autres variables 
cap drop _merge 
merge m:1 interview__key  using "$datain_standard\QM_S0_identification.dta", keepusing(HH1 HH2 HH3 HH13)

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

gen commentaire =""

**************Fin appel de variables*****************

********************************
**********************************Emploi inadéquat*****************************************
/////////////////////////////////////////////////////////////////////////
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
///////////////////////////////////////////////////////////////////////////


**#WKI1. Souhaitez-vous changer votre emploi actuel?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(WKI1) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)
//11 CAS, Toute la section est vide pour ces individus

br if missing(WKI1) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

replace commentaire="Il y a 11 individus qui n'ont pas repondus à la question WKI1" if missing(WKI1) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 WKI1 using "$folderpath/document/Erreur_WKI1_NA" if missing(WKI1) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a), firstrow(varlabels) replace

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI1) & (EN_EMP == 0 | M4Confirm<15) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI1) & !inrange(WKI1,1,3)

*Etape4: Les reponses données sont elles coherentes au regard des precedentes? 
***Verification pour voir si ceux qui veulent changer d'emploi actuel d'autre ne sont pas en emploi 
count if !missing(WKI1) & EN_EMP != 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

*WKI2. Quelles sont les principales raisons pour lesquelles vous voulez changer votre situation d’emploi ?
*************|||||Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
*** Boucle pour vérifier les réponses manquantes pour chaque sous-question de WKI2 et les exporter si elles existent: 

forvalues i = 1/13 {
    * Compter combien de personnes devaient répondre mais n'ont pas répondu pour chaque sous-variable de WKI2
count if  missing(WKI2__`i') & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) & inlist(WKI1, 1, 2) 
    
    * Si il existe des réponses manquantes, les exporter les individus dans un fichier Excel
    if r(N) > 0 {
        export excel interview__key HH13 WKI2__`i' using "$folderpath/document/WKI2__`i'_NA.xlsx" if  EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) & inlist(WKI1, 1, 2) & missing(WKI2__`i'), firstrow(variables) replace
        display "Exportation terminée pour WKI2__`i' avec " r(N) " réponses manquantes"
    }
	*Si pas d'erreurs alors  le message suivant apparaittra
    else {
        display "Pas de réponses manquantes pour WKI2__`i'"
    }
br 	if  EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm, ., .a) & inlist(WKI1, 1, 2) & missing(WKI2__`i')	
}


**correction

forvalues i = 1/13 {
    * Remplace les valeurs manquantes .a par 0 dans chaque variable WKI2__`i'
    replace WKI2__`i' = 0 if WKI2__`i' == .a
}



*************Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
***Les identifier et les exporter s'ils existent apres identification
forvalues i = 1/13 {
    * Vérification des individus qui ont répondu à WKI2 mais ne devaient pas y répondre
    *count if !inlist(WKI1, 1, 2) & !missing(WKI2__`i')
    
	count if !missing(WKI2__`i') & (EN_EMP ==0  | M4Confirm < 15 |  !inlist(WKI1, 1, 2)) & !inlist(M4Confirm, ., .a)	
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


***WKI2_Aut. Veuillez préciser ?

**Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(WKI2_Aut) & WKI2__13 == 1

**Etape2: Coherence des sauts
count if !missing(WKI2_Aut) & WKI2__13 == 0

******WKI3. Au cours de la période allant du %DateJ30% au %DateJ0% , avez-vous cherché un travail supplémentaire ou un autre travail rémunéré ?

*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(WKI3) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)


replace commentaire="Il y a 11 individus qui n'ont pas repondus à la question WKI3" if missing(WKI3) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 WKI3 using "$folderpath/document/Erreur_WKI3_NA" if missing(WKI3) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a), firstrow(varlabels) replace


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI3) & (EN_EMP == 0 |  M4Confirm<15) 


*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI3) & !inrange(WKI3,1,3)

*****WKI4. Dans la période allant du %DateJ30% à %DateJ0% , vouliez-vous travailler plus d’heures par semaine que d’habitude, à condition que les heures supplémentaires soient payées ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(WKI4) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

replace commentaire="Il y a 11 individus qui n'ont pas repondus à la question WKI4" if missing(WKI4) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 WKI4 using "$folderpath/document/Erreur_WKI4_NA" if missing(WKI4) & EN_EMP == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a), firstrow(varlabels) replace

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI4) & (EN_EMP == 0 |  M4Confirm<15) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI4) & !inlist(WKI4,1,2)

*****WKI5. Auriez-vous pu commencer à travailler plus d’heures au cours des deux semaines suivantes, c’est-à-dire du %DateJ_1% à %DateJ_14% ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 

count if missing(WKI5) & EN_EMP == 1 & WKI4 == 1 &  M4Confirm>=15 & !inlist(M4Confirm,.,.a)


*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if !missing(WKI5) & (EN_EMP == 0 |  M4Confirm<15 | WKI4 ==2) 

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI5) & !inlist(WKI5,1,2)
*Etape4: Les reponses données sont elles coherentes au regard des precedentes? RAS 

***WKI6. Combien d’heures supplémentaires par semaine pourriez-vous travailler ?
*Etape1: Valeurs manquantes: Est ce que ceux qui devaient repondre ont veritablement repondu? 
count if missing(WKI6) & WKI5==1 & membre_id_v1_IND== "##N/A##" 

*br membre_id_v1_IND WKI5 WKI6 if missing(WKI6) & WKI5==1 & membre_id_v1_IND== "##N/A##" 

*Etape2: Coherence des sauts: Est ce que ceux qui ont repondu devaient repondre? 
count if missing(WKI6) & WKI5==1 & membre_id_v1_IND== "##N/A##"

*Etape3: Est ce que les reponses données sont celles qu'on atendait? 
count if !missing(WKI6) & WKI6 >= 70 & WKI6 != 9998
count if !missing(WKI6) & WKI6 <= 0

***WKI7. Pourquoi n’avez-vous pas cherché un autre emploi ou pourquoi ne souhaitez-vous pas chercher un nouvel emploi ? 

*Etape1

count if missing(WKI7) & ((WKI3 == 3 |  WKI1==3) & membre_id_v1_IND == "##N/A##")


*Etape2 
count if !missing(WKI7) & ((WKI3 != 3 &  WKI1!=3) | membre_id_v1_IND != "" & membre_id_v1_IND !="##N/A##")

*Etape3  
count if !missing(WKI7) & !inlist(WKI7, 1,2,3,4,5,6,7)

*****WKI7_Aut. Veuillez préciser ?

**Etape1

count if missing(WKI7_Aut) & WKI7 == 7

**Etape2
count if !missing(WKI7_Aut) & WKI7 != 7



export excel interview__key HH13 WKI7 WKI7_Aut  using "$folderpath/document/WKI7_Aut" if !missing(WKI7_Aut) & WKI7 == 7, firstrow(variables) replace


**Etape3 & Etape1 : dejà regardé lors du recodage des autres à préciser. 


drop HH13 M4Confirm EN_EMP membre_id_v1_IND HH2 HH1 HH2 HH3

save "$standard_individu\INDIV_S8_emploi_inadequat.dta", replace