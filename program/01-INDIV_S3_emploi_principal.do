

*================================================
*********EMPLOI PRINCIPALE 

****RESPONSABLE: ABDOUL KADER
*=============================================

use "$datain_standard\INDIV_S3_emploi_principal.dta", clear 

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)

cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S2_situation_emploi.dta", keepus(SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9)

cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)

cap drop _merge

merge m:1 interview__key using "$brute_menage_work", keepusing(annee HH13)
drop if _merge!=3
cap drop _merge






/****** Control de la section variable par variable suivant les 4 points d'actions

1) Control des valeurs manquantes : Tous ceux qui devrait repondre on bel et bien répondu

2) Control de l'effectivement des sauts : seules ceux qui ont le droit de repondre ont répondu

3) Les valeurs renseignées sont dans le champs de définition de la variable

4) Les valeurs renseignées sont vraissembables

 **************************************/
 
/////////EP1a.Quel est l’intitulé de votre poste ou quel type de travail avez-vous effectué pendant la se maine du %DateJ7% à %DateJ0% dans le cadre de votre emploi principal (ou que vous avez l'h abitude d'exercer) 

//1) 

count if  missing(EP1a) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // tous ceux qui devrait repondre ont répondus

//2)

count if  !missing(EP1a) & EN_EMP==0 & M4Confirm <15 // tous ceux qui ont répondu y avait droit.

//3)


ta EP1a,miss 

**
count if EP1a == "##N/A##" // Certains individu dans il est renseigné "##N/A##". 

br SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9 EN_EMP M4Confirm membre_id_v1_IND membre_id_v1  EP1a EP1b  EP2a EP3 EP11 if EP1a == "##N/A##" // il s'agirait d'individus pour qui une bonne partie de la section EP n'a pas été renseignées. 

*exportation des individus potentiellement concernés

count if EP1a == "##N/A##"
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b  EP1b1 EP2a EP3 EP11 using "$folderpath/document/Emploi_prin_EP1a" if EP1a == "##N/A##", firstrow(varl) replace
}
*

//4)

///// EP1b. Quelles sont vos principales taches et fonctions dans votre emploi/activite principal ? 

//1) 

count if  missing(EP1b) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // tous ceux qui devaient repondre ont répondu

//2)

count if  !missing(EP1b) & EN_EMP==0 & M4Confirm <15 // tous ceux qui ont répondu y avait droit.

//3) 

ta EP1b, miss

count if EP1b == "##N/A##" // Certains individus (09) dans il est encore renseigné "##N/A##". 

br SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9 EN_EMP M4Confirm membre_id_v1_IND membre_id_v1  EP1a EP1b  EP2a EP3 EP11 if EP1b == "##N/A##" // il s'agirait d'individus pour qui une bonne partie de la section EP n'a pas été renseignées. 

*exportation des individus potentiellement concernés

count if EP1b == "##N/A##" 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b  EP1b1 EP2a EP3 EP11 using "$folderpath/document/Emploi_prin_EP1b" if EP1b == "##N/A##" , firstrow(varl) replace
}
*

//4) 

//////// EP1b1.Choisissez le code correspondant au poste ?

//1)

count if missing(EP1b1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)  // 13 individus pour qui la question n'a pas été répondu

*exportation des individus potentiellement concernés

count if missing(EP1b1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b  EP1b1 EP2a EP3 EP11 using "$folderpath/document/Emploi_prin_EP1b1" if missing(EP1b1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) , firstrow(varl) replace
}
*

//2) 

count if !missing(EP1b1) & (EN_EMP==0 | M4Confirm < 15) // tous individus ayant répondu avaient le droit

//3)
//4)

count if EP1b1 >= 111101 & EP1b1 <= 111106

br EP1a EP1b EP1b1 if EP1b1 >= 111101 & EP1b1 <= 111106 

*exportation des individus potentiellement concernés

*export excel interview__key HH13 EP1a EP1b EP1b1 using "$folderpath/document/Emploi_prin_EP1b1_2" if EP1b1 >= 111101 & EP1b1 <= 111106 , firstrow(varl) replace

*

br EP1a EP1b EP1b1 if EP1b1 == 111202 | EP1b1 == 111207  // Directeur de Cabinet et Ambassadeur


///// EP2a. Au cours de la période allant de %DateJ7 % au %DateJ0% , quelle est le domaine d'activit é de l'entreprise dans laquelle vous travaillez d ans le cadre de votre emploi principal ?

//1)

count if missing(EP2a) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // tous ceux qui devraient répondre ont répondus

//2) 

count if !missing(EP2a) & (EN_EMP==0 | M4Confirm < 15) // tous individus ayant répondu avaient le droit

//3)

count if EP2a == "##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // Certains individu (45) dans il est renseigné "##N/A##". 

br SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9 EN_EMP M4Confirm membre_id_v1_IND membre_id_v1  EP1a EP1b  EP2a EP3 EP11 if EP2a == "##N/A##" // il s'agirait d'individus pour qui une bonne partie de la section EP n'a pas été renseignées. 


*exportation des individus potentiellement concernés

count if EP2a == "##N/A##" 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b EP1b1  EP2a EP3 EP11   using "$folderpath/document/Emploi_prin_EP2a" if EP2a == "##N/A##" , firstrow(varl) replace
}
*

//4) 


/////// EP2a1. Choisissez le code correspondant à l'activité


//1)

count if missing(EP2a1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // 55 individus pour qui la question n'a pas été répondu

*exportation des individus potentiellement concernés

count if missing(EP2a1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b  EP1b1 EP2a EP2a1 EP3 EP11 using "$folderpath/document/Emploi_prin_EP2a1" if missing(EP2a1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) , firstrow(varl) replace
}
*



//2) 

count if !missing(EP2a1) & (EN_EMP==0 | M4Confirm < 15) // tous individus ayant répondu avaient le droit

//3)

//4)


///////EP2b. Quels sont les principaux produits ou ser vices réalisés dans l’entreprise dans laquelle vo us travaillez ou dans vos fonctions principales ?

//1)

count if missing(EP2b) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // tous ceux qui devraient répondre ont répondus

//2) 

count if !missing(EP2b) & (EN_EMP==0 | M4Confirm < 15) // tous individus ayant répondu avaient le droit

//3)


count if EP2b == "##N/A##" // Certains individu (51) dans il est renseigné "##N/A##". 

br SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9 EN_EMP M4Confirm membre_id_v1_IND membre_id_v1   EP1a EP1b  EP2a EP2b EP3 EP11 if EP2b == "##N/A##" // il s'agirait d'individus pour qui une bonne partie de la section EP n'a pas été renseignées. 


*exportation des individus potentiellement concernés

count if EP2b == "##N/A##" 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b EP1b1  EP2a EP2b EP3 EP11   using "$folderpath/document/Emploi_prin_EP2b" if EP2b == "##N/A##" , firstrow(varl) replace
}
* 

//4)


/////// EP2b1. Choisissez le code correspondant au produit


//1)

count if missing(EP2b1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // 58 individus pour qui la question n'a pas été répondu

*exportation des individus potentiellement concernés

count if missing(EP2b1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b  EP1b1 EP2a EP2a1 EP2b1 EP3 EP11 using "$folderpath/document/Emploi_prin_EP2b1" if missing(EP2b1) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) , firstrow(varl) replace
}
*

//2) 

count if !missing(EP2b1) & (EN_EMP==0 | M4Confirm < 15) // tous individus ayant répondu avaient le droit


//3)

//4)

/////// EP2c. Est-ce que l’unité de production, l’endroit où l’entreprise dans laquelle vous travaillez a un nom ? 

//1) 

count if missing(EP2c) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // 40 individus pour qui la question n'a pas été répondu

*exportation des individus potentiellement concernés
count if missing(EP2c) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b  EP1b1 EP2a EP2a1 EP2b1 EP2c EP3 EP11 using "$folderpath/document/Emploi_prin_EP2c" if missing(EP2c) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) , firstrow(varl) replace
}
*

*proposition de correction
replace EP2c = 2 if missing(EP2c) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) 

//2)

count if !missing(EP2c) & (EN_EMP==0 | M4Confirm < 15) // tous individus ayant répondu avaient le droit

//3)
//4)

//// EP2d. Quel est le nom de l’entreprise (celui qui paye votre salaire) où vous travaillez dans le ca dre de votre emploi principal ?

//1) 

count if missing(EP2d) &  EP2c == 1 // tous les individus devant répondre ont répondus 

//2) 

count if !missing(EP2d) &  inlist(EP2c,2,3) // tous les individus ayant répondu y avait droit 

//3)
//4)

//////EP2e. Votre lieu de travail se trouve-t-il dans vo tre localité de résidence dans le cadre de votre emploi principal ?

//1)

count if missing(EP2e) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // 37 individus pour qui la variable n'a pas été répondu

*exportation des individus potentiellement concernés

count if missing(EP2e) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP1a EP1b  EP1b1 EP2a EP2a1 EP2b1 EP2c EP2e EP3 EP11 using "$folderpath/document/Emploi_prin_EP2e" if missing(EP2e) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) , firstrow(varl) replace
}
*
*proposition de correction 

replace EP2e = 1 if missing(EP2e) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)

//2)

count if !missing(EP2e) & (EN_EMP==0 | M4Confirm < 15) // tous individus ayant répondu avaient le droit

//3)
//4)

//////EP2f. Dans quelle sous-préfecture est situé vot re lieu de travail dans le cadre de votre emploi principal ?

//1) 

count if missing(EP2f) & EP2e==2 & membre_id_v1_IND =="##N/A##" // tous les individus devant répondre ont bien répondu

//2)

count if !missing(EP2f) & (EP2e==1 | (membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="" )) // tous les individus devant répondre on bien répondu

//3)
//4)

//////EP2f. Dans quelle sous-préfecture est situé vot re lieu de travail dans le cadre de votre emploi principal ?

//1) 

count if missing(EP2f) & EP2e==2 & membre_id_v1_IND =="##N/A##" // tous les individus devant répondre on bien répondu

//2)

count if !missing(EP2f) & (EP2e==1 | (membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="" )) // tous les individus devant répondre on bien répondu

//3)
//4)

////// EP2f_loc. Dans quelle localité / commune est sit ué votre lieu de travail dans le cadre de votre e mploi principale ? 

//1) 

count if missing(EP2f_loc) & !missing(EP2f) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) & EP2e==1 & membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !=""  

/////// EP2g1. Quels types de transport vous utilisez dans le cadre de votre déplacement (du lieu de r ésidence au lieu de travail) pour votre emploi/a ctivité principale ?


//1) 

count if missing(EP2g1) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // 346 individus pour qui la question n'a pas été répondu

* Exportation
count if missing(EP2g1) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP2h EP2g1 EP2e EP2i EP2i_unit using "$folderpath/document/Emploi_prin_EP2g1_miss" if missing(EP2g1) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a), firstrow(varl) replace
}
*

*Proposition de correction : remplacer par le mode selon l'emplacement du lieu ded travail
cap drop EP2g1_mod 
egen EP2g1_mod = mode(EP2g1), by(EP2e)
replace EP2g1 = EP2g1_mod if missing(EP2g1) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)
drop EP2g1_mod 


//2) 

count if !missing(EP2g1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") | EN_EMP==0 | M4Confirm <15) // seuls ceux qui devaient répondre on répondu

//3)
//4)


/////// EP2g1_Aut. Precisez l'autre

//1) 

count if missing( EP2g1_Aut) & EP2g1==6 // tous ceux qui devaient repondre ont répondu.

//2)

count if !missing( EP2g1_Aut) & inlist(EP2g1,1,2,3,4,5,7,8) // RAS


*proposition de correction (non ponctuelle)
replace EP2g1_Aut = "" if !missing( EP2g1_Aut) & inlist(EP2g1,1,2,3,4,5,7,8) // RAS

*

//3) & 4)) les autres à préciser ont déjà été checker et récoder

/////// EP2g. Par quel principal moyen de déplacemen t vous rendez-vous habituellement sur votre lie u de travail ? 

//1) 

count if missing(EP2g) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) & inlist(EP2g1,1,2,3,4,6) // tous ceux qui devraient repondre ont répondus

*Proposition de correction : remplacer par le mode selon l'emplacement du lieu de travail
cap drop EP2g_mod 
egen EP2g_mod = mode(EP2g), by(EP2e EP2g1)
replace EP2g = EP2g_mod if missing(EP2g) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) & inlist(EP2g1,1,2,3,4,6)
drop EP2g_mod 


//2) 

count if !missing(EP2g) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="") |EN_EMP==0 | M4Confirm <15 | !inlist(EP2g1,1,2,3,4,6)) // RAS


*proposition de correction (ponctuelle)
//RAS
count if EP2g1 == 5 & !missing(EP2g)
replace EP2g =. if EP2g1 == 5


//3)
//4)

count if EP2g1 == 4 & inlist(EP2g,1,7,8,9,10,11,12,13) // certaines personnes ont déclaré utiliser un transport personnel et ont déclaré des moyens de transport inconsistent avec cela (gbaka, taxi brousse,pirogue)

br EP2g1 EP2g if EP2g1 == 4 & inlist(EP2g,1,7,8,9,10,11,12,13)

*proposition de corrections(non ponctuelle)
replace EP2g1 = 2 if inlist(EP2g,1,7,9,10,11,12,13) & EP2g1==4    
*

/////////EP2g_aut. préciser l'autre principal moyen de d éplacement vous rendez-vous habituellement s ur votre lieu de travail

//1)
count if missing(EP2g_aut) & EP2g==16 & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // tous ceux qui devraient repondre à la question ont répondu

//2) 

count if !missing(EP2g_aut) & (EP2g !=16 | EN_EMP==0 | M4Confirm <15) // 1 individu pour qui il y a incoherence


//3) & //4) la variable a déjà été controlé pour les vraissemblances lors du récodage des autres à préciser. 


///////// EP2h. Combien de temps en moyenne (en minu tes) vous faut-il habituellement pour vous rend re de votre domicile à votre lieu de travail par ? 

//1) 

count if missing(EP2h) & inlist(EP2g1,1,2,3,4,5,6) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // 

*proposition de correction //imputation de la median de temps des individus avec les memes caractéristiques 

br EP1a EP1b EP2h EP2g EP2g1 EP2e if missing(EP2h) & inlist(EP2g1,1,2,3,4,5,6) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)

cap drop med_EP2h
egen med_EP2h = median(EP2h), by(EP2e EP2g1 EP2g)
replace EP2h = med_EP2h if missing(EP2h) & inlist(EP2g1,1,2,3,4,5,6) & membre_id_v1_IND =="##N/A##" & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)
drop med_EP2h 


//2)

count if !missing(EP2h) & (!inlist(EP2g1,1,2,3,4,5,6) | membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !=""  | EN_EMP==0 | M4Confirm <15) // tous ceux qui ont répondu avaient le droit de repondre 

//3) 

count if EP2h <= 0 // la valeur renseigné ne peut pas etre inférieure ou égale à zero. RAS

br EP2h EP2g1 EP2e EP2i if EP2h <=0 

//4) 

ta EP2h

* i-les personnes declarant plus de 120 min pour moins de 15km
count if EP2h > 120 & EP2i <=15 & !inlist(EP2h,.,.a) & EP2e == 1 & !inlist(EP2g1,5,.,.a) // RAS

br EP2h EP2g1 EP2e EP2i if EP2h > 120 & EP2i <=15 & !inlist(EP2h,.,.a) & EP2e == 1 & !inlist(EP2g1,5,.,.a) // un individu qui declare parcourir  plus de 120 min pour moins de 15 Km dans la meme localité

*exportation des individus potentiellement concernés
count if EP2h > 120 & EP2i <=15 & !inlist(EP2h,.,.a) & EP2e == 1 & !inlist(EP2g1,5,.,.a) 
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP2h EP2g1 EP2e EP2i EP2i_unit using "$folderpath/document/Emploi_prin_EP2h_120" if EP2h > 120 & EP2i <=15 & !inlist(EP2h,.,.a) & EP2e == 1 & !inlist(EP2g1,5,.,.a) , firstrow(varl) replace
}

*proposition de correction (non ponctuelle)
cap drop med_EP2h_1
egen med_EP2h_1 = median(EP2h) if EP2i <=15 & EP2g1 == 4 & EP2h < 120 & EP2e == 1 
ta med_EP2h_1
replace EP2h = 20 if EP2h > 120 & EP2i <=15 & !inlist(EP2h,.,.a) & EP2e == 1 & !inlist(EP2g1,5,.,.a)
drop med_EP2h_1



* ii-les personnes declarant plus de 180 min pour moins de 30km
count if EP2h >=180 & inrange(EP2i,16,30) & EP2e == 1 & !inlist(EP2g1,5,.,.a) //RAS

*br EP2h EP2g1 EP2e EP2i if EP2h >=180 & inrange(EP2i,16,30) & EP2e == 1 & !inlist(EP2g1,5,.,.a) // aucun individu qui declare faire plus de 180 min pour moins de 30 Km dans la meme localité

*exportation des individus potentiellement concernés

*export excel interview__key HH13 M4Confirm EP2h EP2g1 EP2e EP2i EP2i_unit using "$folderpath/document/Emploi_prin_EP2h_180" if EP2h >=180 & inrange(EP2i,16,30) & EP2e == 1 & !inlist(EP2g1,5,.,.a), firstrow(varl) replace
*

/*proposition de correction (non ponctuelle)

cap drop med_EP2h_3
egen med_EP2h_3 = median(EP2h) if inrange(EP2i,16,30) & EP2g1 == 4 & EP2h < 180 & EP2e == 1 // la median est de 40 minutes pour les individus utilisant les memes moyens de transport et parcourant les memes nombres de Km

replace EP2h = 40 if inrange(EP2i,16,30) & EP2g1 == 4 & EP2h >= 180 & EP2e == 1 // nous imputons la median
*/


* iv-Pour les valeurs beaucoup trop grande
count if EP2h >= 180 & !inlist(EP2h,.,.a) //7 individus ont déclaré des valeurs trop grande

br EP2h EP2g1 EP2e EP2i EP2i_unit  if EP2h >= 180 & !inlist(EP2h,.,.a)

*exportation des individus potentiellement concernés

count if EP2h >= 180 & !inlist(EP2h,.,.a)
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP2h EP2g1 EP2e EP2i EP2i_unit using "$folderpath/document/Emploi_prin_EP2h_trop" if EP2h >= 180 & !inlist(EP2h,.,.a), firstrow(varl) replace
}
*

*proposition de correction (non ponctuelle)
//pour les personnes se deplaçant à pieds, elles ont quand meme declaré un nombre de km inferieure ou égale à 30km 

br EP2h EP2g1 EP2e EP2i EP2i_unit if EP2g1 == 5 & EP2h >= 180 & EP2h !=.a & EP2e == 1
  
cap drop med_EP2h_4
egen med_EP2h_4 = median(EP2h) if EP2g1 == 5 & EP2h < 180 & EP2e == 1 & inrange(EP2i,1,30) & EP2i_unit==1 //, by(code_citp_emp_principal) // la mediane est de 30 min pour les personnes se deplaçant à pieds dans la meme localité 
ta med_EP2h_4 

replace EP2h = 30 if EP2g1 == 5 & EP2h >= 180 & EP2e == 1 & inrange(EP2i,1,30) & EP2i_unit==1
replace EP2h = 30 if EP2g1 == 5 & EP2h >= 180 & EP2e == 1 & EP2i == 9998
drop med_EP2h_4


//pour les personnes se deplaçant en transport en commun 
cap drop med_EP2h_5
egen med_EP2h_5 = median(EP2h) if inlist(EP2g1,2,3) & EP2h < 180 & EP2e == 1 //, by(code_citp_emp_principal) // la mediane est de 10 min pour les personnes se deplaçant en transport commun dans la meme localité 

br EP2h EP2g1 EP2e EP2i EP2i_unit if EP2h >= 180 & !inlist(EP2h,.,.a) & inlist(EP2g1,2,3) & EP2e == 1 // RAS
ta med_EP2h_5
replace EP2h = 15 if EP2h >= 180 & !inlist(EP2h,.,.a) & inlist(EP2g1,2,3) & EP2e == 1

//pour les personnes travaillant dans une autre localite et se deplaçant en transport en commun

br EP2h EP2g1 EP2e EP2i if EP2h >= 180 & inlist(EP2g1,2,3,4) & EP2e == 2 // 

*cap drop med_EP2h_5
*egen med_EP2h_5 = median(EP2h) if inlist(EP2g1,2,3,4) & EP2e == 2 & EP2h < 180 //, by(code_citp_emp_principal) // la mediane est de 25 min pour les personnes se deplaçant dans une autre localité 
*ta med_EP2h_5
*replace EP2h = 30 if EP2h >= 180 & EP2e == 2 & inlist(EP2g1,2,3,4)
*drop med_EP2h_5


* Pour les personnes marchant plus de trois heures, on les ramènes à ttrois heures

br EP2h EP2g EP2g1 EP2e EP2i if EP2h >= 180 & !inlist(EP2h,.,.a) & EP2e == 1 & inlist(EP2g1,4,5)

*replace EP2h = 180 if EP2h >= 180 & !inlist(EP2h,.,.a) & EP2e == 1 & inlist(EP2g1,4,5)



/*
br EP2h EP2g1 EP2e EP2i if EP2h >= 180 & !inlist(EP2h,.,.a) & EP2e == 1

cap drop med_EP2h_5
egen med_EP2h_5 = mode(EP2h) if !inlist(EP2h,.,.a) & EP2e == 1 & EP2h < 180 & inlist(EP2g1,5) // la mediane est de 35 min pour les personnes se deplaçant dans une autre localité

replace EP2h = 35 if EP2h >= 180 & EP2e == 2 & !inlist(EP2h,.,.a)

ta med_EP2h_5
*/
cap drop med_EP2h_1 med_EP2h_2 med_EP2h_3 med_EP2h_4 med_EP2h_5







/////////EP2i. A quelle distance (en km ou Mètre) estime z-vous votre lieu de travail de votre lieu de rési dence dans le cadre de votre emploi principale ?

//1) 

count if missing(EP2i) & membre_id_v1_IND == "##N/A##" & inlist(EP2g1,1,2,3,4,5,6) // 12 les individus n'ont pas répondu

br EP1b EP2h EP2g EP2g1 EP2i EP2e if missing(EP2i) & membre_id_v1_IND == "##N/A##" & inlist(EP2g1,1,2,3,4,5,6)

*proposition de correction 
//imputation de la median de distance des individus avec les memes caractéristiques 


*personne se deplaçant à pieds en 20 minutes
cap drop med_EP2i_1
egen med_EP2i_1 = median(EP2i) if !inlist(EP2i,.,.a,9998) & EP2g1 == 5 & EP2h == 20 // la médiane est de 2 km
ta med_EP2i_1
replace EP2i = 2 if missing(EP2i) & EP2g1 == 5 & EP2h == 20
drop med_EP2i_1


*personne se deplaçant en transport personnel en bus à plus de 45 minutes
cap drop med_EP2i_2
egen med_EP2i_2 = median(EP2i) if !inlist(EP2i,.,.a,9998) & EP2e==2 & EP2g1 == 2 & EP2h == 45 
ta med_EP2i_2
replace EP2i = 20 if missing(EP2i) & EP2e==2 & EP2g1 == 2 & EP2h == 45
drop med_EP2i_2

*Personne se déplacant à moto pendant 15 minutes
cap drop med_EP2i_3
egen med_EP2i_3 = median(EP2i) if !inlist(EP2i,.,.a,9998) & EP2e==1 & EP2g1 == 4 & EP2h == 15 
ta med_EP2i_3
replace EP2i = 4 if missing(EP2i) & EP2e==1 & EP2g1 == 4 & EP2h == 15
drop med_EP2i_3

*Personne de deplaçant à vélo pendant 48 minutes
cap drop med_EP2i_4
egen med_EP2i_4 = median(EP2i) if !inlist(EP2i,.,.a,9998) & EP2e==1 & EP2g1 == 3 & EP2g == 4 
ta med_EP2i_4
replace EP2i = 2 if missing(EP2i) & EP2e==1 & EP2g1 == 3 & EP2h == 47.5
drop med_EP2i_4

ta EP2i if EN_EMP==1 & M4Confirm>=15,m


/*proposition de correction 
//imputation de la median de temps des individus avec les memes caractéristiques 

br EP1a EP1b EP2h EP2g EP2g1 EP2i EP2e if missing(EP2i) & membre_id_v1_IND == "##N/A##" & inlist(EP2g1,1,2,3,4,5,6)

cap drop med_EP2i

egen med_EP2i = median(EP2i) if EP2g1 == 2 & EP2g ==1 & EP2i_unit == 1

replace EP2i_unit = 1 if missing(EP2i) & membre_id_v1_IND == "##N/A##" & inlist(EP2g1,1,2,3,4,5,6)

replace EP2i = 3 if missing(EP2i) & membre_id_v1_IND == "##N/A##" & inlist(EP2g1,1,2,3,4,5,6)



drop med_EP2i*/


//2) 

count if !missing(EP2i) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "") | inlist(EP2g1,7,8)) // tous ceux qui ont repondu y avaient le droit

//3) Validité des valeurs renseignées : "Ne sait pas"

*Traitement des cas ayant déclaré : "Ne sait pas"
br EP2e EP2g1 EP2h EP2i EP2i_unit if !missing(EP2h) & EP2i==9998

ta EP2h if !missing(EP2h) & EP2i==9998

*Le traitement se fait au cas par cas selon le moyen de déplacement et le temps estimé du parcours.
*Porcédure : on remplace la distance par la mediane selon le moyen de déplacement et l'intervalle de temps.

cap drop med_EP2i
egen med_EP2i = median(EP2i) if !inlist(EP2i,.,9998) & EP2g1==1
ta med_EP2i
replace EP2i = 5 if EP2i==9998 & EP2g1==1

cap drop med_EP2i
egen med_EP2i = median(EP2i) if !inlist(EP2i,.,9998) & EP2g1==2
ta med_EP2i
replace EP2i = 5 if EP2i==9998 & EP2g1==2

cap drop med_EP2i
egen med_EP2i = median(EP2i) if !inlist(EP2i,.,9998) & EP2g1==3
ta med_EP2i
replace EP2i = 3 if EP2i==9998 & EP2g1==3

cap drop med_EP2i
egen med_EP2i = median(EP2i) if !inlist(EP2i,.,9998) & EP2g1==4
ta med_EP2i
replace EP2i = 5 if EP2i==9998 & EP2g1==4

cap drop med_EP2i
egen med_EP2i = median(EP2i) if !inlist(EP2i,.,9998) & EP2g1==5
ta med_EP2i
replace EP2i = 3 if EP2i==9998 & EP2g1==5

cap drop med_EP2i
egen med_EP2i = median(EP2i) if !inlist(EP2i,.,9998) & EP2g1==6
ta med_EP2i
replace EP2i = 5 if EP2i==9998 & EP2g1==6
cap drop med_EP2i



//4) Vraisemblance des valeurs

*Personne marchant plus de 50 km avec un temps invraisemblable
count if EP2i >=50 & EP2i_unit==1 & EP2g1 == 5

br EP2e EP2g1 EP2h EP2i EP2i_unit if EP2i >=50 & EP2i_unit==1 & EP2g1 == 5


*On remplace les valeurs invraisemblables du temps et de la distance par les médianes
cap drop med_EP2h_5
egen med_EP2h_5 = median(EP2h) if EP2i < 50 & EP2i_unit==1 & EP2g1 == 5 
ta med_EP2h_5
replace EP2h = 30 if EP2i >= 50 & EP2i_unit==1 & EP2g1 == 5
cap drop med_EP2h_5

cap drop med_EP2i_5
egen med_EP2i_5 = median(EP2i) if EP2i < 50 & EP2i_unit==1 & EP2g1 == 5 
ta med_EP2i_5
replace EP2i = 2 if EP2i >= 50 & EP2i_unit==1 & EP2g1 == 5
cap drop med_EP2i_5


***Les personnes parcourant plus de 75km en transport alors que le lieu de travail se trouve dans la meme localité   

count if EP2i >= 75 & EP2i_unit == 1 & EP2e == 1 & inlist(EP2g1,1,2,3,4) // 5 personnes qui declare parcourir plus de 75km pour retrouver leur lieu de travail dans la meme localité. 

br EP2e EP2i EP2h EP2g1 EP2i_unit if EP2i >= 75 & EP2i_unit == 1 & EP2e == 1 & inlist(EP2g1,1,2,3,4) // 


*exportation des individus potentiellement concernés
count if EP2i > 75 & EP2i_unit == 1 & EP2e == 1
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP2h EP2g1 EP2e EP2i EP2i_unit using "$folderpath/document/Emploi_prin_EP2i_75km" if EP2i > 75 & EP2i_unit == 1 & EP2e == 1, firstrow(varl) replace
}


*On remplace les valeurs invraisemblables du temps et de la distance par les médianes
cap drop med_EP2h_6
egen med_EP2h_6 = median(EP2h) if EP2i < 75 & EP2i_unit==1 & inlist(EP2g1,1,2,3,4) 
ta med_EP2h_6
replace EP2h = 20 if EP2i >= 75 & EP2i_unit==1 & inlist(EP2g1,1,2,3,4)
cap drop med_EP2h_6

cap drop med_EP2i_6
egen med_EP2i_6 = median(EP2i) if EP2i < 75 & EP2i_unit==1 & inlist(EP2g1,1,2,3,4) & EP2h==20
ta med_EP2i_6
replace EP2i = 5 if EP2i >= 75 & EP2i_unit==1 & inlist(EP2g1,1,2,3,4) & EP2h==20
cap drop med_EP2i_6



*certains individus pour qui les valeurs de la distance ou du temps parcouru sont visiblement des outliers
count if (EP2h>120 & !missing(EP2h) | EP2i >=200 & !missing(EP2i)) & EP2i_unit == 1


br EP2e EP2g1 EP2h EP2i EP2i_unit if (EP2h>120 & !missing(EP2h) | EP2i >=200 & !missing(EP2i)) & EP2i_unit == 1


*exportation des individus potentiellement concernés
count if (EP2h>120 & !missing(EP2h) | EP2i >=200 & !missing(EP2i)) & EP2i_unit == 1
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP2h EP2g1 EP2e EP2i EP2i_unit using "$folderpath/document/Emploi_prin_EP2i_metre" if (EP2h>120 & !missing(EP2h) | EP2i >=200 & !missing(EP2i)) & EP2i_unit == 1, firstrow(varl) replace
}

*proposition de correction 
cap drop med_EP2h
egen med_EP2h = median(EP2h) if !missing(EP2h) & EP2g1 == 5 & inrange(EP2i,3,8) & EP2i_unit == 1 //,  by(code_citp_emp_principal) // la median est de 30km pour les personnes avec les memes caractéristiques (à pieds)
ta med_EP2h
replace EP2h = 30 if inrange(EP2h,140,160) & EP2g1 == 5 & inrange(EP2i,3,8) & EP2i_unit == 1
cap drop med_EP2h



*Personne parcourant moins de 5km en 2heures
br EP2e EP2g1 EP2h EP2i EP2i_unit if EP2h>=120 & !missing(EP2h) & EP2g1 == 5 & inrange(EP2i,1,5) & EP2i_unit == 1

cap drop mean_EP2h
egen mean_EP2h = mean(EP2h) if EP2h<120 & !missing(EP2h) & EP2g1 == 5 & inrange(EP2i,1,4) & EP2i_unit == 1 // la median est de 30min pour les personnes avec les memes caractéristiques (à pieds)
ta mean_EP2h
replace EP2h = 30 if EP2h>=120 & !missing(EP2h) & EP2g1 == 5 & inrange(EP2i,1,5) & EP2i_unit == 1
cap drop mean_EP2h


**Personne se deplacant en transport et parcourant moins de 40km en plus de 2 heures
br EP2e EP2g1 EP2g EP2h EP2i EP2i_unit if EP2h>=120 & inrange(EP2i,2,40) & EP2i_unit == 1 & inlist(EP2g1,1,3,4)

cap drop med_EP2h
egen med_EP2h  = median(EP2h) if inrange(EP2i,2,40) & EP2i_unit == 1 & inlist(EP2g1,1,3,4) //, by(code_citp_emp_principal) // 20 minutes pour les personnes avec les memes caractéristiques
ta med_EP2h
replace EP2h = 20 if EP2h>=120 & inrange(EP2i,2,40) & EP2i_unit == 1 & inlist(EP2g1,1,3,4)
cap drop med_EP2h


*Personne parcourant plus de 10km à pieds pour se rendre au boulot
br EP2e EP2g1 EP2h EP2i EP2i_unit if EP2h<120 & !missing(EP2h) & EP2g1 == 5 & EP2i>10 & EP2i_unit == 1

* Que cela soit vrai ou faux, les distances supérieures à 10km sont extrêmes et seront ramenées à 10km. En moyenne un individu marche 5 ou 6km par heure. Ainsi, le temps de parcours sera également estimé à 2 heures.
replace EP2h = 120 if EP2h<120 & !missing(EP2h) & EP2g1 == 5 & inrange(EP2i,10,50) & EP2i_unit == 1 

replace EP2i = 10 if EP2h==120 & EP2g1 == 5 & inrange(EP2i,10,50) & EP2i_unit == 1 



////// EP2j.Comment avez-vous accédé à votre travail /emploi principal dans cette entreprise ? 
//1)

count if missing(EP2j) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) //  46 individus pour qui la question n'a pas été répondu

br EP1b EP2j if missing(EP2j) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)


*exportation des individus potentiellement concernés

count if missing(EP2j) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EP2j  using "$folderpath/document/Emploi_prin_EP2j_NA" if missing(EP2j) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a), firstrow(varl) replace
}
*



//2) 

count if !missing(EP2j) & (EN_EMP == 0 | M4Confirm < 15) // tous les individus ayant repondu y avaient droit

//3) 
//4)

br EP1a EP1b EP2a EP2b EP2j if EP2j == 8 // on essaie de voir si ceux qui ont mentionné avoir obtenir le travail par concours exerce un travail coherent avec cette information. Après control les infos semblent coherentes. 



/////// EP2j_aut. Précisez l'autre mode d'obtention de votre travail. 

//1) 

count if missing(EP2j_aut) & EP2j==12 // tout qui devaient repondre ont répondus

// 2)

count if !missing(EP2j_aut) & !inlist(EP2j,12,.a,.)

*br EP2j_aut EP2j if !missing(EP2j_aut) & !inlist(EP2j,12,.a,.) // il s'agit des individus pour qui nous avons recoder les autres à préciser, donc RAS

*replace EP2j_aut = "" if !missing(EP2j_aut) & !inlist(EP2j,12,.a,.)

//3 & 4 ) les informations renseignées avaient déjà été double checker lors du récodage des autres à préciser 

////////EP3. Quel est votre statut dans l'emploi ?

//1) 

count if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) // 15 individu pour qui la question n'a pas été répondu. il s'agit probablement des memes individus trouver depuis le début

*exportation des individus potentiellement concernés

count if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a)
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EN_EMP EP3 using "$folderpath/document/Emploi_prin_EP3_NA" if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a), firstrow(varl) replace
}
*

*proposition de correction 

br EP1a EP1b EP3 if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) 

replace EP3 = 1 if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) & inlist(EP1a,"OUVRIER DANS UNE BOULANGERIE", "INSTITUTRICE")

replace EP3 = 3 if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) & inlist(EP1a, "PLANTEUR DE PALMIER", "CULTIVATEUR DE IGNAME;MANIOC ET RIZ", "CULTUVATRICE DE IGNAME", "CULTIVATRICE D'IGNAME", "HEVEACULTEUR", "CULTIVATEUR D IGNAME,ANACARDE;PALMIER A L HUILE; MAIS", "CULTIVATEUR D IGNAME")

replace EP3 = 3 if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) & inlist(EP1a,"AGRICULTEUR DE MANIOC", "CULTIVATEUR D IGNAME;ARACHIDE,ANACARDE ET CAFE", "TAXI MOTO", "CULTIVATRICE D'ARRACHIDE", "PLANTEUR D HEVEA,ANACARDE,PALMIER A HUILE,ARACHIDE ET IGNAME", "COUTURE DAME", "CULTIVATEUR D ANACARDE ET IGNAME", "COMMERCANTE DE BOISSONS")

replace EP3 = 10 if missing(EP3) & EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a) & (EP1a =="##N/A##")


//2) 
count if !missing(EP3) & !(EN_EMP==1 & M4Confirm >=15 & !inlist(M4Confirm,.,.a))

//3) 



//4)

br EP1a EP2b EP3 if !inlist(EP3,.,.a) // les informations mentionnées concernant les taches effectuées semblent coherents avec le statut déclaré a l'exception de certaines correction à faire 
/*
replace EP3 = 3 if EP3_Aut == "PROPOSER PAR LE VILLAGE POUR AIDER L'INFIRMIER"

replace EP3 = 5 if EP3_Aut == "AIDE SON BEAU PERE DANS SON ENTREPRISE"

replace EP3 = 3 if EP2b == "VENTE DE MEDICAMENTS PARAMEDICAUX"

replace EP3 = 5 if EP3_Aut == "PERSONNE AIDANT UNE AUTRE PERSONNE QUI TRAVAILLE DANS SON EMPLOI PRINCIPAL"

replace EP3 = 3 if EP3_Aut == "INDEPENDENT"

replace EP3 = 3 if EP3_Aut == "PAIEMENT APRES VENTE"

replace EP3 = 1 if EP3_Aut == "Employé PAYÉ POUR LE SERVICES RENDUS"

replace EP3 = 1 if EP3_Aut == "MANOEUVRE OCCASIONNEL"

replace EP3 = 3 if EP3_Aut == "PERSONNE COLLABORANT AVEC UNE AUTRE PERSONNE"

replace EP3 = 1 if EP3_Aut == "PERSONNE AIDANT UNE AUTRE PERSONNE DANS SON EMPLOI PRINCIPAL"

replace EP3 = 1 if EP3_Aut == "ENSEIGNANT"

replace EP3 = 3 if EP3_Aut == "SOUTRAITANCE"

replace EP3 = 1 if EP3_Aut == "PERSONNE TRAVAILLANT POUR UN TIERCE"

replace EP3 = 1 if EP3_Aut == "JE SUIS PAYE EN FONCTION DES MARCHANDISES QUE JE DECHARGE"

replace EP3 = 3 if EP3_Aut == "PERSONNE EFFECTUANT UN TRAVAIL REMUNERE"

replace EP3 = 1 if EP3_Aut == "AIDE BOUTIQUIER"
replace EP3 = 3 if EP3_Aut == "Résumé par commission"
replace EP3 = 3 if EP3_Aut == "CONTRACTUEL PAR OCCASION"
replace EP3 = 3 if EP3_Aut == "JOURNALIER SANS JOUR DE TRAVAIL DEFINI"

replace EP3 = 5 if EP3_Aut == "J'AIDE MON PERE DANS SA PLANTATION"

replace EP3 = 5 if EP3_Aut == "J'AIDE MON PERE DANS SA PLANTATION"

replace EP3 = 1 if EP1a == "MANŒUVRE AGRICOLE"
replace EP3 = 5 if EP3_Aut == "PERSONNE AIDANT UN MEMBRE DE SA FAMILLE QUI TRAVAILLE POUR LUI MÊME"

replace EP3 = 5 if EP3_Aut == "AIDE SA TANTE DANS LA VENTE DU POISSON"

replace EP3 = 1 if EP1a == "CHAUFFEUR POIDS LOURDS"
replace EP3 = 1 if EP3_Aut == "PERSONNE AIDANT UNE VOISINE"
replace EP3 = 5 if EP3_Aut == "AIDE LE COMMERCE DE SA MERE"
replace EP3 = 3 if EP3_Aut == "DEMARCHEUR COMMERCIAL"
replace EP3 = 3 if EP3_Aut == "PAIEMENT APRES VENTE" & EP1a == "CULTUVATEUR DE CACAO"
replace EP3 = 3 if EP3_Aut == "CONDUCTEUR" & EP1a == "CHAUFFEUR PARTICULIER"
replace EP3 = 5 if interview__key =="00-91-52-32" & membres__id == 1

replace EP3_Aut = "" if !inlist(EP3,.,.a,10)

//////////EP3_Aut. Veuillez préciser
*/
//1) 

count if missing(EP3_Aut) & EP3==10 //RAS


// 2) 

count if !missing(EP3_Aut) & !inlist(EP3,.,.a,10) // RAS


// 3) la variable à déjà été regardée lors du recodage des autres à préciser. 

//4)


ta EP3_Aut // nous regardons chaque reponse pour s'assurer de la vraissemblance

br EP1a EP1b EP3_Aut if !missing(EP3_Aut) // il se trouve que en réalité, plusieurs personnes ne sont pas en emploi. On voit des reponses comme "stagiaire non payé". Nous corrigons alors toutes les autres informations renseignées précédemment. 



// nous les exportons d'abord pour correction

count if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") 
if r(N)>0 {
    export excel interview__key membres__id HH13 M4Confirm EN_EMP EP1a EP1b EP3 using "$folderpath/document/Emploi_prin_pas_emploi" if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") , firstrow(varl) replace
}

// ensuite Nous avons retirer toutes ces personnes de la population en emploi car elle ne le sont pas 


replace EN_EMP = 0  if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ")
 	

replace SE1 = 2  if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ")

replace SE2 = 10  if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ")

replace SE3 = 5  if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ")

replace SE4 = 2  if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") 

replace SE5 = 2  if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ")

replace SE8 = 2  if regexm(EP3_Aut,"APPRENT NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRETI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE SANS SALAIRE") | regexm(EP3_Aut,"APPRENTI SANS SALAIRE") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI COIFFEUSE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"apprentie coiffeuse") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYÉ") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APRRENTI NON PAYE") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ") | regexm(EP3_Aut,"APPRENTIE NON PAYE") | regexm(EP3_Aut,"APPRENTI MAÇON NON PAYER") | regexm(EP3_Aut,"APPRENTI NON PAYER") | regexm(EP3_Aut,"STAGIAIRE NON PAYE") | regexm(EP3_Aut,"APPRENTI NON-PAYE") | regexm(EP3_Aut,"APPRENTI NON PAYÉ")

replace EP3_Aut = "" if EN_EMP ==0



///////EP4.Qui prend habituellement les décisions concernant la gestion de l'entreprises

//1) 

count if missing(EP4) & EP3 == 5 // RAS car il s'agit des personnes pour qui nous avons récodé les informations dans EP3_Aut

*proposition de correction 

replace EP4 = 3 if missing(EP4) & EP3 == 5

//2)

count if !missing(EP4) & !inlist(EP3,.,.a,5)

//3)

ta EP4,miss 

//4) 


/////////  EP5. Est-ce que l’entreprise que vous dirigez ou avec laquelle vous travaillez embauche/utilise d es employés rémunérés sur une base régulière ?

//1)

count if missing(EP5) & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) // 41 individu pour qui la question est manquante

*exportation des individus potentiellement concernés
count if missing(EP5) & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a)
if r(N)>0 {
    export excel interview__key HH13 M4Confirm EN_EMP EP5 using "$folderpath/document/EP5_NA" if missing(EP5) & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a), firstrow(varl) replace
}
*

*proposition de correction


/*
br EP1a EP1b EP3 EP5 if EP5==.a
replace EP5 = 2 if regexm(EP1a,"JE SUIS INDEPANDANT") | regexm(EP1a,"CULTIVATEUR DE MAIS") | regexm(EP1a,"agriculteur de cacao") | regexm(EP1a,"VENDEUR DE PAGNE")

replace EP5 = 1 if regexm(EP1a,"VIGILE") | regexm(EP1a,"INFIRMIER") 
*/




//2)

count if !missing(EP5) & !(EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a) ) // RAS 

*correction 

replace EP5 =. if !missing(EP5) & !(EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a))


//3)

//4)


//////////EP5a. Combien de personnes au total travaillen t dans l’unité de production où vous exercez (y compris vous-même)

//1)

count if missing(EP5a) & ((EP5==1 | EP5==9998) &membre_id_v1_IND=="##N/A##") // RAS

//2) 

count if !missing(EP5a) & (!inlist(EP5,1,9998,.a,.) | membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !="" )

//3)

ta EP5a,miss

count if EP5a <=0 // le nombre de personne ne peut pas etre inferieure ou égale à zero. 

replace EP5a = 1 if EP5a <=0 // On remplace par 1 le nombre de personne égal à 0.

//4)

count if EP5a  > 100 & !inlist(EP5a,.,.a,9998) // 15 valeurs sont bien trop grandes : plus de 100 employers dans l'entreprises

*proposition de correction

br EP1a EP1b EP3 EP5a if EP5a  > 100 & !inlist(EP5a,.,.a,9998)

cap drop med_EP5a
egen med_EP5a = median(EP5a) if EP5a  <= 100 & EP3 == 1 & EP11== 1 //, by(code_citp_emp_principal) // la median est de 8 pour les personnes avec les memes caractéristiques

replace EP5a = 8 if  EP5a  > 100 & !inlist(EP5a,.,.a,9998) & inlist(EP3,1,9) & EP11== 1

cap drop med_EP5a_1
egen med_EP5a_1 = median(EP5a) if EP5a  <= 100 & EP3 == 1 & EP11== 3 //, by(code_citp_emp_principal) // la median est de 9 pour les personnes avec les memes caractéristiques

replace EP5a = 10 if  EP5a  > 100 & !inlist(EP5a,.,.a,9998) & EP3 == 1 & EP11== 3

cap drop med_EP5a_2
egen med_EP5a_2 = median(EP5a) if EP5a  <= 100 & EP3 == 1 & EP11== 2 //, by(code_citp_emp_principal) // la median est de 22 pour les personnes avec les memes caractéristiques

replace EP5a = 22 if  EP5a  > 100 & !inlist(EP5a,.,.a,9998) & EP3 == 1 & EP11== 2

cap drop med_EP5a_4
egen med_EP5a_4 = median(EP5a) if EP5a  <= 100 & EP3 == 1 & EP11== 4 //, by(code_citp_emp_principal) // la median est de 15 pour les personnes avec les memes caractéristiques

replace EP5a = 8 if  EP5a  > 100 & !inlist(EP5a,.,.a,9998) & EP3 == 1 & EP11== 4

cap drop med_EP5a_5
egen med_EP5a_5 = median(EP5a) if EP5a  <= 100 & EP3 == 1 & EP11== 6 //, by(code_citp_emp_principal)  // la median est de 7 pour les personnes avec les memes caractéristiques

replace EP5a = 7 if  EP5a  > 100 & !inlist(EP5a,.,.a,9998) & EP3 == 1 & EP11== 6

cap drop med_EP5a med_EP5a_1 med_EP5a_2 med_EP5a_4 med_EP5a_5

**ponctuelle

*replace EP5a = 9 if EP1a == "INFIRMIER"


///////// EP5b. Combien de personnes au total travaillen t dans l’unité de production où vous exercez (y compris vous-même) ? 

// 1)

count if missing(EP5b) & EP5a == 9998

br EP1a EP1b EP3 EP5a EP5b if missing(EP5b) & EP5a == 9998


//2)

count if !missing(EP5b) & !inlist(EP5a,9998,.,.a)

//3)



//4)


///////// EP6. Sous quelles formes êtes-vous payé, ou ob tenez-vous vos revenus, dans votre emploi principal ?

//1)

forvalues i = 1/12 {
    count if missing(EP6__`i') & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a)  

    * Si des individus correspondent à cette condition, exporter leurs données
    if r(N) > 0 {
        count if missing(EP6__`i') & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a)
        if r(N)>0 {
            export excel interview__key HH13 EP6__`i' using "$folderpath/document/EP6__`i'.xlsx" if missing(EP6__`i') & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a), firstrow(variables) replace
        }
        display "Exportation terminée pour EP6__`i avec " r(N) " individus"
    }
    else {
        display "Pas de résultats pour EP6__`i"
    }
} // 15 individus concernés

*proposition de correction 

br EP1a EP1b EP6__* if  inlist(EP6__1,.a)

/*
replace EP6__2 = 1 if EP1b == "JE SUIS UN AGENT COMMERCIAL INDEPANDANT"
replace EP6__1 = 1 if EP1a == "VIGILE"
replace EP6__1 = 1 if EP1a == "INFIRMIER"
replace EP6__8 = 1 if EP1a == "CULTIVATRICE  VIVRIERES"
*/



/*
forvalues i = 1/12 {
    replace EP6__`i' = 1 if missing(EP6__`i') & EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a)  
}
*/

// 2)


forvalues i = 1/12 {
    count if !missing(EP6__`i') & !(EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a))  

    if r(N) > 0 {
        count if !missing(EP6__`i') & !(EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a))
        if r(N)>0 {
            export excel interview__key HH13 EP6__`i' using "$folderpath/document/EP6__`i'_saut.xlsx" if !missing(EP6__`i') & !(EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a)), firstrow(variables) replace
        }
        display "Exportation terminée pour EP6__`i avec " r(N) " individus"
    }
    else {
        display "Pas de résultats pour EP6__`i"
    }
}

//RAS car il s'agit en réalité des individus n'étant pas en emploi que nous avons corrigé

/*
forvalues i=1/12 {

replace EP6__`i' =. if !missing(EP6__`i') & !(EN_EMP == 1 & M4Confirm >= 15 & !inlist(M4Confirm,.,.a))

}
*/

//ICICICICICI


//3)


//4)

count if EP6__1 == 1 & !inlist(EP3,.,.a,1,8,9,10) & EN_EMP == 1 // 15 personnes qui percoivent un salaire sans etre salarié

*exportation des individus potentiellement concernés
count if EP6__1 == 1 & !inlist(EP3,.,.a,1,8,9,10) & EN_EMP == 1
if r(N)>0 {
    export excel interview__key HH13 EP6__1 using "$folderpath/document/EP6__1.xlsx" if EP6__1 == 1 & !inlist(EP3,.,.a,1,8,9,10) & EN_EMP == 1, firstrow(variables) replace
}

*proposition de correction
br EP3 EP1a EP1b EP6__1 if EP6__1 == 1 & !inlist(EP3,.,.a,1,8,9,10) & EN_EMP == 1

gen EP6__1_ = EP6__1

replace EP6__1 = 0 if EP6__1_ == 1 & !inlist(EP3,.,.a,1,8,9,10) & EN_EMP == 1 & (EP3 == 4 | EP3==6 | EP3==5 | EP3==3)

replace EP6__8 = 1 if EP6__1_ == 1 & !inlist(EP3,.,.a,1,8,9,10) & EN_EMP == 1 & (EP3 == 4 | EP3 == 3)

replace EP6__10 = 1 if EP6__1_ == 1 & !inlist(EP3,.,.a,1,8,9,10) & EN_EMP == 1 & (EP3 == 6 | EP3==5)

drop EP6__1_

*
 
count if EP3 == 1 & EP6__1 == 0 // 166 déclare etre salarié sans recevoir de salaire.

br EP3 EP1a EP1b EP6__* EP6a if EP3 == 1 & EP6__1 == 0


*exportation des individus potentiellement concerné
count if EP3 == 1 & EP6__1 == 0
if r(N)>0 {
    export excel interview__key HH13 EP3 EP6__1 using "$folderpath/document/EP6__1_EP3.xlsx" if EP3 == 1 & EP6__1 == 0, firstrow(variables) replace
}

*
/*
*proposition de correction 

br EP1a EP1b EP3 EP6__1 if EP3 == 1 & EP6__1 == 0

count if !inlist(EP3,.,.a,5,6,10) & EP6__10 == 1 // aucun individu qui declare ne pas etre payé alors qu'il n'est pas un travailleur familiale. 

proposition de correction

br EP1a EP1b EP3 EP11 if !inlist(EP3,.,.a,5,6,10) & EP6__10 == 1 

gen EP6__10_ = EP6__10

replace EP6__10 = 0 if !inlist(EP3,.,.a,5,6,10) & EP6__10_== 1

replace EP6__8 = 1 if !inlist(EP3,.,.a,5,6,10) & EP6__10_== 1

drop EP6__10_
*/

///////EP6_Aut. Veuillez préciser


//1) 

count if missing(EP6_Aut) & EP6__6 == 1 // RAS car il s'agit des individus pour qui nous venons d'imputer l'information à EP6__6

//2) 

count if !missing(EP6_Aut) & EP6__6==0 // 6 individus concerné

*proposition de correction
replace EP6_Aut = "" if !missing(EP6_Aut) & EP6__6==0 



//3 & //4) déjà regardé lors du recodage des autres à préciser. 


////////////EP6a. Indiquez la forme principale de revenus


//1)

count if missing(EP6a) & EP6__10 == 0 

*exportation des individus potentiellement concernés

*export excel interview__key HH13 EP3 EP6__10 EP6a using "$folderpath/document/EP6a.xlsx" if missing(EP6a) & EP6__10 == 0, firstrow(variables) replace

*proposition de correction 

br EP1a EP1b EP3 EP6a if missing(EP6a) & EP6__10 == 0 

replace EP6a = 1 if missing(EP6a) & EP6__10 == 0 & EP3==1


//2)

count if !missing(EP6a) & EP6__10 == 1 //RAS car il s'agit des individus, travailleur familiaux pour qui nous avons 

br EP1a EP1b EP3 EP6a EP6__10 if !missing(EP6a) & EP6__10 == 1

replace EP6a =. if !missing(EP6a) & EP6__10 == 1

// 3) 

//4) 

count if EP3==1 & EP6a !=1 // Des salariés dont la forme principale de remuneration n'est pas le salaire 

*exportation des individus potentiellement concernés

count if EP3==1 & EP6a !=1
if r(N)>0 {
    export excel interview__key HH13 EP3  EP6a using "$folderpath/document/EP6a_1.xlsx" if EP3==1 & EP6a !=1, firstrow(variables) replace
}


drop M4Confirm SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9 membre_id_v1_IND annee HH13

cap drop med_EP2h_1 med_EP2h_4 med_EP2h_5 med_EP2h



save "$datain_standard\INDIV_S3_emploi_principal.dta", replace





*******************                 *********************
// Pour les question EP7-EP9, l'on doit charger la base revenu 
use "$datain_brute\Revenu.dta" , clear 
cap drop _merge
merge m:1 interview__key using "$brute_menage_work", keepusing(annee HH13)

keep if _merge == 3
cap drop _merge

merge m:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(EP6__10 EP6__7 EP1a EP1b EP3 EP6a EP6__9)

keep if _merge == 3
cap drop _merge



///////////EP7. A quelle fréquence percevez-vous votre ré munération principale pour votre emploi principal

//1)

count if missing(EP7) & EP3!=5 & EP6__7 == 0 & EP6__10==0 // 0 individu pour qui l'information est manquante

*exportation des individus potentiellement concernés
*export excel interview__key HH13 EP6__7 EP6__10 EP7 using "$folderpath/document/EP7_NA.xlsx" if missing(EP7) & EP6__7 == 0 & EP6__10==0, firstrow(variables) replace

*proposition de correction 

/*br EP1a EP1b EP3 EP7 if missing(EP7) & EP6__7 == 0 & EP6__10==0 

replace EP7 = 7 if (EP1a == "VENDEUR DE CAOUTCHOUC" | EP1a == "CULTIVATEUR DE COTON" | EP1a == "CULTIVATEUR" | EP1a == "AGRICULTEUR DE MAÏS") & missing(EP7) & EP6__7 == 0 & EP6__10==0

replace EP7 = 1 if (EP1a == "COMMERCANTE") & missing(EP7) & EP6__7 == 0 & EP6__10==0

replace EP7 = 4 if (EP1a == "INSPECTEUR PÉDAGOGIQUE" | EP1a == "INSPECTEUR PÉDAGOGIQUE" )  & missing(EP7) & EP6__7 == 0 & EP6__10==0

replace EP7 = 1 if (EP1a == "VENDEUSE DE LÉGUMES") & missing(EP7) & EP6__7 == 0 & EP6__10==0*/



//2)

count if !missing(EP7) & (EP6__10==1) // RAS car il s'agit des personnes pour qui nous avons corriger la valeur à EP6


replace EP7=. if !missing(EP7) & (EP6__10==1)



//3) 

//4) 

count if EP3 == 1 & (EP7==9 | EP7==8) // 59 personnes qui sont salarié mais qui declarent recovoir leur revenu de façon occassionnelle

*exportation des individus concernés
count if EP3 == 1 & (EP7==9 | EP7==8)
if r(N)>0 {
    export excel interview__key HH13 EP3 EP7 using "$folderpath/document/EP7_EP3.xlsx" if EP3 == 1 & (EP7==9 | EP7==8), firstrow(variables) replace
}

*

////////// EP7B. combien de %EP7% %label_ep7% perceve z-vous votre rémunération PRINCIPALE pour vo tre emploi princale ? 


//1)

count if missing(EP7B) & EP7 < 8 // tous les individus ont répondus

*exportation des individus concernés 
count if missing(EP7B) & EP7 < 8
if r(N)>0 {
    export excel interview__key HH13 EP3 EP7 EP7B  using "$folderpath/document/EP7B.xlsx" if missing(EP7B) & EP7 < 8, firstrow(variables) replace
}

*proposition de correction 

br EP1a EP1b EP7 EP7B if missing(EP7B) & EP7 < 8


*replace EP7B = 12 if missing(EP7B) & EP7 < 8 & EP7==4
*replace EP7B = 2 if missing(EP7B) & EP7 < 8 & EP7==7
cap drop med_EP7B
egen med_EP7B = median(EP7B) if !missing(EP7B) & EP7==1
ta med_EP7B
replace EP7B = 6 if missing(EP7B) & EP7==1



//2)

count if !missing(EP7B) & inlist(EP7,9,10) 

//3) 

count if EP7B > 7 & !inlist(EP7B,.,.a) & EP7== 1 // les personnes qui ont declaré etre payé par jour ne peuvent pas repondre plus de 7 quand on leur demande combien de Jours par semaine 

count if EP7B > 4 & !inlist(EP7B,.,.a) & EP7== 2 // les personnes qui ont declaré etre payé par semaine ne peuvent pas repondre plus de 4 quand on leur demande combien de semaine par mois

count if EP7B > 2 & !inlist(EP7B,.,.a) & EP7== 3 // les personnes qui ont declaré etre payé par quinzaine ne peuvent pas repondre plus de 2 quand on leur demande combien de quinzaine par mois

count if EP7B > 12 & !inlist(EP7B,.,.a) &  EP7== 4 // les personnes qui ont declaré etre payé par mois ne peuvent pas repondre plus de 12 quand on leur demande combien de mois par an

count if EP7B > 6 & !inlist(EP7B,.,.a) &  EP7== 5 // les personnes qui ont declaré etre payé par bimensuel ne peuvent pas repondre plus de 6 quand on leur demande combien de bimensuel par an

count if EP7B > 4 & !inlist(EP7B,.,.a) &  EP7== 6 // les personnes qui ont declaré etre payé par trimestre ne peuvent pas repondre plus de 4 quand on leur demande combien de trimestre par an

count if EP7B > 2 & !inlist(EP7B,.,.a) &  EP7== 7 // les personnes qui ont declaré etre payé par semestre ne peuvent pas repondre plus de 2 quand on leur demande combien de semestre par an


//4)




///////////EP8. Par %EP7% , quel est le montant de ce paiement tiré de votre metier principale ? 

//1) 

count if missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a) // 2 individus pour qui la question n'a pas été repondu

*exportation des individus concernés

count if missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a)
if r(N)>0 {
    export excel interview__key HH13 EP3 EP6a EP7 EP7B  EP8 using "$folderpath/document/EP8_NA.xlsx" if missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a), firstrow(variables) replace
}


*proposition de correction 
br EP1b EP3 EP7 EP7B EP8 EP9 if missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a)


*proposition de correction 

cap drop med_EP8_1
egen med_EP8_1 = median(EP8) if EP7 == 1 & EP3 == 3 &  EP7B==6 & !missing(EP6a)
ta med_EP8_1

replace EP8 = 1000000 if missing(EP8) & EP7 == 1 & EP3 == 3 & !missing(EP6a)

cap drop med_EP8_2	
egen med_EP8_2 = median(EP8) if EP7 == 4 & EP3 == 1 & EP7B==12 & !missing(EP6a)
ta med_EP8_2
replace EP8 = 400000 if missing(EP8) & EP7 == 4 & EP3 == 1 & EP7B==12 & !missing(EP6a) 


/*
cap drop med_EP8_3
egen med_EP8_3 = median(EP8) if EP7 == 7 & EP3 == 1

cap drop med_EP8_4
egen med_EP8_4 = median(EP8) if EP7 == 2 & EP3 == 3

cap drop med_EP8_5
egen med_EP8_5 = median(EP8) if EP7 ==  9 & EP3 == 3

cap drop med_EP8_6
egen med_EP8_6 = median(EP8) if EP7 ==  4 & EP3 == 3

replace EP8 = 300000 if EP7 == 7 & EP3 == 3 & missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a) 

replace EP8 = 10000 if EP7 == 1 & EP3 == 3 & missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a) 

replace EP8 = 150000 if EP7 == 4 & EP3 == 1 & missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a) 

replace EP8 = 20000 if EP7 == 2 & EP3 == 3 & missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a) 

replace EP8 = 150000 if EP7 ==  9 & EP3 == 3 & missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a) 

replace EP8 = 200000 if EP7 ==  4 & EP3 == 3 & missing(EP8) & inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a) 


cap drop med_EP8_1 med_EP8_2 med_EP8_3 med_EP8_4 med_EP8_5 med_EP8_6
*/



//2)

count if !missing(EP8) & !(inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a)) // RAS

replace EP8 =. if !missing(EP8) & !(inlist(EP7,1,2,3,4,5,6,7,8,9) & !missing(EP6a))

///

//3) 

count if EP8 < 500 & !inlist(EP8,.,.a) // quelque soit la frequence, un montant de moins de 1000 est trop petit. 24 individus sont concernés

*
count if EP8 < 500 & !inlist(EP8,.,.a)
if r(N)>0 {
    export excel interview__key HH13 EP3 EP6a EP7 EP7B EP8 using "$folderpath/document/EP8_1.xlsx" if EP8 < 500 & !inlist(EP8,.,.a), firstrow(variables) replace
}

*proposition de correction

br EP8 EP8_1 if EP8 < 500 & !inlist(EP8,.,.a) // nous nous aidons de la valeur en lettre pour connaitre la vrai valeur

replace EP8 = 500000 if EP8_1== "CINQ CENT MILLE"
replace EP8 = 40000 if EP8_1== "QUARANTE MILLE"
replace EP8 = 90000 if EP8_1== "QUATRE VINGT DIX"
replace EP8 = 15000 if EP8_1== "QUINZE MILLE FRANCS"
replace EP8 = 20000 if EP8_1== "VINGT MILLE FRANCS"
replace EP8 = 20000 if EP8_1== "VINGT CINQ MILLE"
replace EP8 = 60000 if EP8_1== "SOIXANTE MILLE FRANC CFA"
replace EP8 = 90000 if EP8_1== "QUATRE VINGT DIX MILLE"
replace EP8 = 120000 if EP8_1== "CENT VINGT MILLE"
replace EP8 = 200000 if EP8_1== "DEUX CENT MILLE"
replace EP8 = 10000 if EP8_1== "DIX MILLE"
replace EP8 = 6000 if EP8_1== "SIX MILLE"
replace EP8 = 40000 if EP8_1== "QUARANTE MILLES"
replace EP8 = 1000000 if EP8_1== "UN MILLION"
replace EP8 = 60000 if EP8_1== "SOIXANTE MILLE"



*
count if inrange(EP8,500,999) & !inlist(EP8,.,.a) // pour les valeurs entre 500 et 1000(exclu) on essaie de cross checker avec la valeur en lettre

br EP7 EP8 EP8_1 EP3  if inrange(EP8,500,999) & !inlist(EP8,.,.a) // les valeurs en chiffre sont en phase avec la valeur en lettre.

*replace EP8 = 500000 if EP8_1== "CINQ CENT MILLE FRANCS"

/*cap drop med_EP8
egen med_EP8 = median(EP8) if EP8!=99999998 & EP8!= 99999999 & EP7==8 & EP3==3 // nous corrigeons la valeur zero en y imputant la medianne des individus avec qui ont les memes caractéristiques professionnelles

cap drop med_EP8

replace EP8 = 150000 if EP8==0 // nous corrigeons la valeur zero en y imputant la medianne des individus avec qui ont les memes caractéristiques professionnelles*/


//4)

count if EP8> 1000000 & !inlist(EP8,.,.a) & EP8!=99999998 & EP8!= 99999999   // pour les valeurs supérieur à 1000000 on essaie de cross checker avec la valeur en lettre

br EP7 EP8 EP8_1 EP3  if EP8> 1000000 & !inlist(EP8,.,.a) & EP8!=99999998 & EP8!= 99999999 // les valeurs en chiffre sont en phase avec la valeur en lettre à l'exception de ces deux




///////////////EP8a.Par %EP7% à combien évaluez-vous les pa iements en nature que vous recevez pour votre emploi principal 

//1) 

count if missing(EP8a) & (EP6__7 == 1 | EP6__9 == 1)

//2)

count if !missing(EP8a) & (EP6__7 == 0 & EP6__9 == 0) 


//3)

count if EP8a < 500 & !inlist(EP8a,.,.a) // les valeurs inferieures à 500 semblent très faible. nous double checker avec la valeur en lettre

*exportation des individus potentiellement concernés

*export excel interview__key HH13 EP7 EP8 EP8_1  EP8a EP8a_1 EP3 using "$folderpath/document/EP8a.xlsx" if EP8a < 500 & !inlist(EP8a,.,.a), firstrow(variables) replace

*
br EP7 EP8 EP8_1  EP8a EP8a_1 EP3 if EP8a < 500 & !inlist(EP8a,.,.a)

*nous utilisant la valeur en lettre pour corriger certaines valeurs

*replace EP8a= 100000 if interview__key =="94-90-16-59" & membres__id == 0


*nous corrigeons les autres valeurs 

/*
cap drop med_EP8a
egen med_EP8a = median(EP8a) if EP8a!=99999998 & EP8a!= 99999999 & EP8a!=. & EP8a!=.a 

cap drop med_EP8a

replace EP8a = 5000 if EP8a < 500 & !inlist(EP8a,.,.a)
*/


//4)


///////////////EP9. Pouvez-vous tout de meme nous indiquer dans quelle tranche de remuneration vous vous situez ? 


//1)
count if missing(EP9) & (inlist(EP8,99999998,99999999) |inlist(EP8a,99999998,99999999) | EP7==10) // 1 personne pour qui la question n'a pas été répondu. 

*exportation des individus potentiellement concernés

count if missing(EP9) & (inlist(EP8,99999998,99999999) |inlist(EP8a,99999998,99999999) | EP7==10)
if r(N)>0 {
    export excel interview__key HH13 EP9 EP8 EP8a EP7 using "$folderpath/document/EP9.xlsx" if missing(EP9) & (inlist(EP8,99999998,99999999) |inlist(EP8a,99999998,99999999) | EP7==10), firstrow(variables) replace
}

*proposition de correction 


br EP1a EP1b EP7 EP7B EP8 EP9 if missing(EP9) & (inlist(EP8,99999998,99999999) |inlist(EP8a,99999998,99999999) | EP7==10) // nous allons imputer les valeurs qui ont déjà été calculé plus haut en EP8

replace EP9 = 8 if EP7 == 1 & EP3 ==3 & missing(EP9) & (inlist(EP8,99999998,99999999) |inlist(EP8a,99999998,99999999) | EP7==10)

replace EP9 = 16 if EP7 == 4 & EP3 ==1 & missing(EP9) & (inlist(EP8,99999998,99999999) |inlist(EP8a,99999998,99999999) | EP7==10)

replace EP9 = 19 if EP7 == 10 & EP3 ==3 & missing(EP9) & (inlist(EP8,99999998,99999999) |inlist(EP8a,99999998,99999999) | EP7==10)






//2) 

count if !missing(EP9) & !(EP8==99999998 |EP8==99999999 | EP8a==99999998 |EP8a==99999999 | EP7==10) // RAS car il s'agit des individus pour qui nous avons corrigé la valeur à EP6

replace EP9 =.  if !missing(EP9) & !(EP8==99999998 |EP8==99999999 | EP8a==99999998 |EP8a==99999999 | EP7==10) 	

//3) 

//4)


********On revient à la base de données individus********

drop annee HH13 EP1a EP1b EP3 EP7 EP6__7 EP6__9 EP6__10 EP6a
cap drop med_EP8_5 med_EP8_6 med_EP8_2


save "$dataout\Revenu.dta" , replace

**********************************************************

use "$datain_standard\INDIV_S3_emploi_principal.dta", clear 

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)

cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S2_situation_emploi.dta", keepus(SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9)

cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND )

cap drop _merge

merge m:1 interview__key using "$brute_menage_work", keepusing(annee HH13)
drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND )

cap drop _merge

merge m:1 interview__key using "$brute_menage_work" , keepus(V1interviewkey)

keep if _merge == 3
drop  _merge 


///////////// EP10a. Qui vous rémunère pour ce travail ? 

//1) 

count if missing(EP10a) & (inlist(EP3,1,8,9) | (EP3==5 & inlist(1,EP6__1,EP6__2,EP6__3,EP6__4,EP6__5,EP6__9)))

br EP1b EP3 EP10a if missing(EP10a) & (inlist(EP3,1,8,9) | (EP3==5 & inlist(1,EP6__1,EP6__2,EP6__3,EP6__4,EP6__5,EP6__9)))


br EP1b EP3 EP10a if EP3==5 & !missing(EP10a)
*exportation des individus potentiellement concernés
count if missing(EP10a) & (inlist(EP3,1,8,9) | (EP3==5 & inlist(1,EP6__1,EP6__2,EP6__3,EP6__4,EP6__5,EP6__9)))
if r(N)>0 {
    export excel interview__key HH13 EP10a using "$folderpath/document/EP10a.xlsx" if missing(EP10a) & (inlist(EP3,1,8,9) | (EP3==5 & inlist(1,EP6__1,EP6__2,EP6__3,EP6__4,EP6__5,EP6__9))), firstrow(variables) replace
}

*proposition de correction


replace EP10a = 1 if missing(EP10a) & (inlist(EP3,1,8,9) | (EP3==5 & inlist(1,EP6__1,EP6__2,EP6__3,EP6__4,EP6__5,EP6__9)))



//2)

//3)
//4)


////////////EP10a_aut. Précisez l'autre personne qui vous rémunère pour ce travail 

//1)

count if missing(EP10a_aut) &  EP10a==3

//2)

count if !missing(EP10a_aut) & !inlist(EP10a,.,.a,3)

//3)

/*certaines valeur des autres à preciser sont inconsistentes, nous les recodons

replace EP10a = 1 if regexm(EP10a_aut,"LE MINISTÈRE DE L'EDUCATION NATIONALE") | regexm(EP10a_aut,"LE GOUVERNEMENT") | regexm(EP10a_aut,"L'ETAT") | regexm(EP10a_aut,"EGLISE AU PLAN NATIONAL") | regexm(EP10a_aut,"LE PATRON") | regexm(EP10a_aut,"L ETAT") | regexm(EP10a_aut,"L ETAT") | regexm(EP10a_aut,"ELLE RECOIS SON SALAIRE PAR ORANGE MONEY") | regexm(EP10a_aut,"chef maçon") | regexm(EP10a_aut,"ETAT IVOIRIENNE") | regexm(EP10a_aut,"Ministere de l'education nationale et de l'alphabétisation") | regexm(EP10a_aut,"BANQUE GENERAL") | regexm(EP10a_aut,"L’ETAT") | regexm(EP10a_aut,"L ETAT") | regexm(EP10a_aut,"L’ETAT") | regexm(EP10a_aut,"MINISTÈRE DE LA DEFENSE") | regexm(EP10a_aut,"LA FONCTION PUBLIQUE") | regexm(EP10a_aut,"LE PROPRIETAIRE DU CHAMP") | regexm(EP10a_aut,"CHEF DE MENAGE") | regexm(EP10a_aut,"L'ETAT") | regexm(EP10a_aut,"ÉDUCATION NATIONALE") | regexm(EP10a_aut,"GOUVERNEMENT") | regexm(EP10a_aut,"L'ETAT") | regexm(EP10a_aut,"L ETAT") | regexm(EP10a_aut,"employeur") | regexm(EP10a_aut,"ETAT") | regexm(EP10a_aut,"BANQUE") | regexm(EP10a_aut,"L ETAT DE COTE DI VOIRE") | regexm(EP10a_aut,"LA SOLDE") | regexm(EP10a_aut,"AGRICULTEUR") | regexm(EP10a_aut,"MINISTÈRE DE LA DEFENSE") | regexm(EP10a_aut,"LA FONCTION PUBLIC") | regexm(EP10a_aut,"GOUVERNEMENT") | regexm(EP10a_aut,"LA COMMUNAUTÉ") | regexm(EP10a_aut,"GOUVERNEMENT") | regexm(EP10a_aut,"LE MINISTÈRE DE L'EDUCATION NATIONALE") | regexm(EP10a_aut,"LE GOUVERNEMENT") | regexm(EP10a_aut,"CLIENT") | regexm(EP10a_aut,"L'ETAT") | regexm(EP10a_aut,"EGLISE AU PLAN NATIONAL") | regexm(EP10a_aut,"LE PATRON") | regexm(EP10a_aut,"L ETAT") | regexm(EP10a_aut,"ELLE RECOIS SON SALAIRE PAR ORANGE MONEY") | regexm(EP10a_aut,"LORSQU'ELLE TRESSE ELLE GAGNE DE L AREGENT EN FONCTION DES PERSONNES QU ELLE TRESSE") | regexm(EP10a_aut,"chef maçon") | regexm(EP10a_aut,"ETAT IVOIRIENNE") | regexm(EP10a_aut,"Ministere de l'education nationale et de l'alphabétisation") | regexm(EP10a_aut,"LE DIMANCHE IL CONDUIT POUR LUI DONC APRES AVOIR RETIRÉ LES DEPENSES LIÉES AU VÉHICULE LE RESTE QUI EST LE BÉNÉFICE FAIT OFFICE DE SA RÉMUNÉRATION") | regexm(EP10a_aut,"GENDARMERIE NATIONALE") | regexm(EP10a_aut,"LE PROPRIETAIRE") | regexm(EP10a_aut,"BANQUE GENERAL") | regexm(EP10a_aut,"MINISTÈRE DE LA DEFENSE") | regexm(EP10a_aut,"LA FONCTION PUBLIQUE") | regexm(EP10a_aut,"LE PROPRIETAIRE DU CHAMP") | regexm(EP10a_aut,"ÉDUCATION NATIONALE") | regexm(EP10a_aut,"employeur") | regexm(EP10a_aut,"ETAT") | regexm(EP10a_aut,"BANQUE") | regexm(EP10a_aut,"L ETAT DE COTE DI VOIRE") | regexm(EP10a_aut,"LA SOLDE") | regexm(EP10a_aut,"AGRICULTEUR") | regexm(EP10a_aut,"MINISTÈRE DE LA DEFENSE") | regexm(EP10a_aut,"LE RESPONSABLE DE LA VOITURE,  L’EMPLOYEUR") | regexm(EP10a_aut,"LA FONCTION PUBLIC") 


replace EP10a_aut ="" if !inlist(EP10a,.,.a,3) 

replace EP3 = 3 if EP10a_aut =="TRAVAILLEUR INDÉPENDANT" | EP10a_aut == "SOI MEME" 

replace EP3 = 5 if EP10a_aut == "CHEF DE MENAGE" | EP10a_aut == "MERE" */
//4)

//////////EP10b. Payez-vous l'impot sur le revenu dans le cadre de votre emploi principal ?


//1)
count if missing(EP10b) & inlist(EP3,2,3,4) & (inlist(1,EP6__1,EP6__2,EP6__3,EP6__4,EP6__5,EP6__6,EP6__7,EP6__8,EP6__9,EP6__11,EP6__12)|inlist(0,EP6__1,EP6__2,EP6__3,EP6__4,EP6__5,EP6__6,EP6__7,EP6__8,EP6__9,EP6__11,EP6__12))



*exportation des individus concernés 
*
count if missing(EP10b) & inlist(EP3,2,3,4) & !inlist(EP6__1,.,.a) & !inlist(EP6__2,.,.a) & !inlist(EP6__3,.,.a) & !inlist(EP6__4,.,.a) & !inlist(EP6__5,.,.a) & !inlist(EP6__6,.,.a) & !inlist(EP6__7,.,.a) & !inlist(EP6__8,.,.a) & !inlist(EP6__9,.,.a) & !inlist(EP6__10,.,.a,1) & !inlist(EP6__11,.,.a) & !inlist(EP6__12,.,.a)
if r(N)>0 {
    export excel interview__key HH13 EP10b using "$folderpath/document/EP10b.xlsx" if missing(EP10b) & inlist(EP3,2,3,4) & !inlist(EP6__1,.,.a) & !inlist(EP6__2,.,.a) & !inlist(EP6__3,.,.a) & !inlist(EP6__4,.,.a) & !inlist(EP6__5,.,.a) & !inlist(EP6__6,.,.a) & !inlist(EP6__7,.,.a) & !inlist(EP6__8,.,.a) & !inlist(EP6__9,.,.a) & !inlist(EP6__10,.,.a,1) & !inlist(EP6__11,.,.a) & !inlist(EP6__12,.,.a), firstrow(variables) replace
}

* 6 individus doivent faire l'objet d'une imputation

br EP1a EP1b EP3 EP6a EP10b if EP10b==.a 

*proposition de correction 
replace EP10b = 2 if EP10b==.a



//2)

count if !missing(EP10b) & !(inlist(EP3,2,3,4) & !inlist(EP6__1,.,.a) & !inlist(EP6__2,.,.a) & !inlist(EP6__3,.,.a) & !inlist(EP6__4,.,.a) & !inlist(EP6__5,.,.a) & !inlist(EP6__6,.,.a) & !inlist(EP6__7,.,.a) & !inlist(EP6__8,.,.a) & !inlist(EP6__9,.,.a) & !inlist(EP6__10,.,.a,1) & !inlist(EP6__11,.,.a) & !inlist(EP6__12,.,.a))

//3)
//4)

////////EP10c. Qui fait le versement des impôts sur le revenu dans le cadre de votre emploi principale ? 



//1) 

count if missing(EP10c) & EP10b==1 // la condition d'activation de la question est assez confuse. du coup nous n'arrivons pas à faire les checks. 


*proposition de correction
br EP1b EP3 EP6a EP10b EP10c if missing(EP10c) & EP10b==1

replace EP10c =1 if missing(EP10c) & EP10b==1


//2) 

count if !missing(EP10c) // la condition d'activation de la question est assez confuse. du coup nous n'arrivons pas à faire les checks 

//3) & 4) 

/////////////// EP11. L'unité de production dans laquelle vous exercez votre emploi principal (ou que vous diri gez) est-elle une : 


//1) 

count if missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15 // 42 individus pour qui la variable n'a pas été répondus

*exportation des individus concernés

count if missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15
if r(N)>0 {
    export excel interview__key HH13 EP11 using "$folderpath/document/EP11.xlsx" if missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15, firstrow(variables) replace
}

*on essaie de voir si on peut retrouver l'information de ses individus on se referent à leur information en EP1a EP1b etc 

br EP1a EP1b EP3 EP11 if missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15

replace EP11 = 3 if inlist(EP1a,"CHAUFFEUR DE TAXI","OUVRIER DANS UNE BOULANGERIE", "COIFFEUSE", "CHARBONNIER", "VENDEUSE DE JUS ET GÂTEAU", "VENDEUSE DE BEIGNET", "VENDEUSE DE PRODUIT COSMETIQUE") &  missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15

replace EP11 = 3 if inlist(EP1a, "AGENT DE SECURITE", "INSTITUTRICE", "VENDEUSE DE VIVRIER TOMATE OIGNON CHOUX AUBERGINE", "VENDEUSE D ATTIEKE ET POISSON") &  missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15


replace EP11 = 3 if inlist(EP1a, "VENDEUSE DE DRAP", "VENDEUSE DE BEIGNET", "EBENISTE", "AIDE-RAMASSEUR DE COCO", "VENDEUSE DE LEGUMES", "Vendeur de nourriture", "COURSIER") &  missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15

replace EP11 = 3 if inlist(EP1a, "VENDEUSE DE PAGNE", "VENDEUSE DE DRAP FRIPERIE", "vendeuse d'alloco", "COUTURE DAME", "PATISSIERE", "AUXILIAIRE DE SOIN") &  missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15

replace EP11=4 if inlist(EP1a, "HEVEACULTEUR", "AGRICULTRICE DE CACAO", "CULTIVATRICE D'HARICOTS", "ELEVEUR DE BOEUF", "CULTIVATEUR DE L'IGNAME", "PLANTEUR D HEVEA,ANACARDE,PALMIER A HUILE,ARACHIDE ET IGNAME") &  missing(EP11) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15


//2)

count if !missing(EP11) & (EN_EMP == 0 | M4Confirm <15) // RAS car il s'agit en réalité des individus qui n'était pas en emploi et dont nous avons changé le statut 



*correction
replace EP11 =. if !missing(EP11) & (EN_EMP == 0 | M4Confirm <15)

//3

//4

*nous faisons un check rapide pour les personnes ayant declaré administration public. Certains individus ne sont en réalité pas dans une administration publique ICICICIC

br EP11 EP1a EP1b EP3 EP2d if EP11==1

*proposition de correction

replace EP11 = 4 if EP1a == "AGRICULTEUR DR RIZ"
replace EP11 = 3 if EP1a == "VIGIL"
replace EP11 = 2 if EP2d == "PORT AUTONOME D’ABIDJAN"
replace EP11 = 2 if EP2d == "ECOMAF"
replace EP11 = 3 if EP2d == "AGENCE MTN"
replace EP11 = 3 if EP2d == "ZYDUS PHARMA"



count if EP3 == 3 & (EP11 == 1 | EP11 == 2 | EP11 == 5 | EP11 == 8 ) // les personnes à leurs propre compte ne peuvent pas etre dans une administration publique ou parapublique, une organisation internationale, un ménage etc

*exportation des individus concernés

count if EP3 == 3 & (EP11 == 1 | EP11 == 2 | EP11 == 5 | EP11 == 8 )
if r(N)>0 {
    export excel interview__key HH13 EP11 EP3 using "$folderpath/document/EP11_4.xlsx" if EP3 == 3 & (EP11 == 1 | EP11 == 2 | EP11 == 5 | EP11 == 8 ), firstrow(variables) replace
}

*

br EP3 EP11 EP1a EP1b if EP3 == 3 & (EP11 == 1 | EP11 == 2 | EP11 == 5 | EP11 == 8 )

*proposition de correction

replace EP11 = 4 if EP3==3 & EP11==8
replace EP11 = 3 if EP3 == 3 & EP11 == 2 & inlist(EP1a,"FERRONIER", "GERANT DE CABINE DE TRASFERT D’ARGENT")
replace EP11 = 8 if EP3==3 &  EP11 == 2 & EP1a == "VENDEUSE DE JUS"
replace EP3 = 1 if EP3 == 3 & inlist(EP11,1,2) & inlist(EP1a, "ENSEIGNEMENT", "ARTISANS", "MENUISIER", "AIDE-MENAGE", "OUVIER GRADEUR")



/////////////EP12. Etes-vous fonctionnaire dans votre emploi principale ? 

//1)


count if missing(EP12) & inlist(EP11,1,2) // RAS car il s'agit des gens dont nous avons corrigé l'info à EP11

//2

count if !missing(EP12) & !inlist(EP11,1,2,.,.a) // RAS car il s'agit bel et bien des individus dont nous avons corrigé l'info en EP11 

replace EP12 =. if !missing(EP12) & !inlist(EP11,1,2,.,.a)

//3 & //4)

///////////////EP13. Quelle est votre categorie socio-professionnelle en tant que salariés ?fonctionnaire) dans votre empl oi principal ? ICICICICICICICI


//1)

count if missing(EP13) & ((inlist(EP3,1,8,9) & inlist(EP11,1,2) & EP12==2) | (inlist(EP3,1,8,9) & inlist(EP11,3,4,5,6,7))) // RAS car il s'agit des personnes dont nous avons corriger l'information à EP11 ou EP3 

br EP13 EP3 EP11 if missing(EP13) & ((inlist(EP3,1,8,9) & inlist(EP11,1,2) & EP12==2) | (inlist(EP3,1,8,9) & inlist(EP11,3,4,5,6,7)))


*Correction
cap drop EP13_mod
egen EP13_mod = mode(EP13) if !missing(EP13) & EP3==1 & EP11==3
ta EP13_mod
replace EP13 = 3 if EP13==. & EP3==1 & EP11==3

cap drop EP13_mod
egen EP13_mod = mode(EP13) if !missing(EP13) & EP3==1 & EP11==4
ta EP13_mod
replace EP13 = 5 if EP13==. & EP3==1 & EP11==4

cap drop EP13_mod
egen EP13_mod = mode(EP13) if !missing(EP13) & EP3==1 & EP11==2
ta EP13_mod
replace EP13 = 5 if EP13==. & EP3==1 & EP11==2

cap drop EP13_mod
egen EP13_mod = mode(EP13) if !missing(EP13) & EP3==1 & EP11==7
ta EP13_mod
replace EP13 = 5 if EP13==. & EP3==1 & EP11==7

cap drop EP13_mod
egen EP13_mod = mode(EP13) if !missing(EP13) & EP3==1 & EP11==1
ta EP13_mod
replace EP13 = 4 if EP13==. & EP3==1 & EP11==1

replace EP13 = 6 if EP13==. & inlist(EP3,8,9)

cap drop EP13_mod

// 2)

count if !missing(EP13) & !((inlist(EP3,1,8,9) & inlist(EP11,1,2) & EP12==2) | (inlist(EP3,1,8,9) & inlist(EP11,3,4,5,6,7))) // RAS 

br EP13 EP3 EP11 if !missing(EP13) & !((inlist(EP3,1,8,9) & inlist(EP11,1,2) & EP12==2) | (inlist(EP3,1,8,9) & inlist(EP11,3,4,5,6,7)))

replace EP13=. if !missing(EP13) & !((inlist(EP3,1,8,9) & inlist(EP11,1,2) & EP12==2) | (inlist(EP3,1,8,9) & inlist(EP11,3,4,5,6,7)))


//3)

//4)

*les personnes ayant declaré stagiaire ou apprenti payé à EP3 ne doivent choisir que la modalité EP13 == 6

count if inlist(EP3,8,9) & !inlist(EP13,.,.a,6) // un individu identifié 

*exportation 

count if inlist(EP3,8,9) & !inlist(EP13,.,.a,6)
if r(N)>0 {
    export excel interview__key HH13 EP13 EP3 using "$folderpath/document/EP13_6.xlsx" if inlist(EP3,8,9) & !inlist(EP13,.,.a,6), firstrow(variables) replace
}

*correction 

br EP3 EP13 EP1a EP1b EP11 if inlist(EP3,8,9) & !inlist(EP13,.,.a,6) 

replace EP13 = 6 if inlist(EP3,8,9) & !inlist(EP13,.,.a,6)

///////////////EP13a. Quelle est votre grade sociale-professionnel en tant que fonctionnaire dans votre empl oi principal ?

//1)

count if missing(EP13a) & inlist(EP3,1,8,9) & EP12 == 1 // des individus pour qui la question n'a pas été répondu

*exportation 

*export excel interview__key HH13 EP13a EP3 EP12 using "$folderpath/document/EP13a.xlsx" if missing(EP13a) & inlist(EP3,1,8,9) & EP12 == 1, firstrow(variables) replace

*proposition d'imputation

br EP3 EP13 EP1a EP1b EP11 EP12 EP13a if missing(EP13a) & inlist(EP3,1,8,9) & EP12 == 1


replace EP13a = 10 if inlist(EP1a, "ENSEIGNANT STAGIAIRE D'ÉCOLE PRIMAIRE", "ENSEIGNEMENT", "ENSEIGNANTE Du PRIMAIRE") & missing(EP13a) & inlist(EP3,1,8,9) & EP12 == 1

replace EP13a = 3 if EP1b == "INSPECTEUR DETECTEUR DE DROGUES ET STUPEFIANTS" & missing(EP13a) & inlist(EP3,1,8,9) & EP12 == 1

replace EP13a = 11 if EP1a == "AIDE SOIGNANT" & missing(EP13a) & inlist(EP3,1,8,9) & EP12 == 1


//2)

count if !missing(EP13a) & (!inlist(EP3,1,8,9,.,.a) | EP12 == 2) 

//3

//4

////////////////////EP2jb. Avez-vous obtenu ce poste par une pro motion/nomination/mutation depuis l'acquisiti on de ce poste ?


//1)

count if missing(EP2jb) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15 // 21 individus pour qui la question n'a pas été répondu



*exportation 

count if missing(EP2jb) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15
if r(N)>0 {
    export excel interview__key HH13 EP2jb using "$folderpath/document/EP2jb.xlsx" if missing(EP2jb) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15, firstrow(variables) replace
}

*



*proposition de correction 

br EP1a EP1b EP3 EP11 EP12 EP2jb if missing(EP2jb) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15  

replace EP2jb = 2 if missing(EP2jb) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15 // après check des autres caractéristiques, les personnes concernées sont plus susceptible de ne pas avoir eu une promotion au poste actuel car soit à leur propre compte ou ayant commencé à travailler depuis peu de temps. 


//2) 

count if !missing(EP2jb) & (EN_EMP == 0 | M4Confirm <15 ) // RAS car il s'agit des individus dont EN_EMP a été précédemment corrigé 

replace EP2jb =. if !missing(EP2jb) & (EN_EMP == 0 | M4Confirm <15 )


//3)
//4)


////////////////EP2ka.Depuis quelle année avez-vous commen cé à travailler dans cette entreprise ou cet endr oit dans le cadre de votre emploi principal ?

//1) 

count if missing(EP2ka) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15 // 23 individus pour qui l'info est manquante 

*exportation

count if missing(EP2ka) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15
if r(N)>0 {
    export excel interview__key HH13 EP2ka using "$folderpath/document/EP2ka.xlsx" if missing(EP2ka) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15, firstrow(variables) replace
}

*
*proposition de correction 

br EP1a EP1b EP3 EP11 EP2k EP2ka if missing(EP2ka) & EN_EMP == 1 & !inlist(M4Confirm,.,.a) & M4Confirm >=15 // 20 individus pour qui l'info est manquante, s'agissant tous d'individus en réintérrogation 

// On s'aide des infos données en T3 pour les individus en réintérrogation

replace EP2ka = 2010 if V1interviewkey == "21-29-23-96" & membre_id_v1 == "1"

replace EP2ka = 2023 if V1interviewkey == "98-18-66-84" & membre_id_v1 == "2"

replace EP2ka = 2021 if V1interviewkey == "26-27-28-98" & membre_id_v1 == "1"


*replace EP2ka = 9998 if EP2ka ==.a



//2)

count if !missing(EP2ka) & (EN_EMP == 0 | M4Confirm <15 ) // // RAS car il s'agit des individus dont EN_EMP a été précédemment corrigé 

replace EP2ka =. if !missing(EP2ka) & (EN_EMP == 0 | M4Confirm <15 )

//3) 

ta EP2ka

*l'information ne peut pas etre inferieure à zero ou superieure à 2024

count if (EP2ka < 1920 | EP2ka > 2026) & !inlist(EP2ka,.,.a,9998) // certaines valeurs sont trop petite pour etre des années il s'agirait potentiellement du nombre d'année qui a été renseigné plutot que depuis quelle année 

*exportation

count if (EP2ka < 1920 | EP2ka > 2025) & !inlist(EP2ka,.,.a,9998)
if r(N)>0 {
    export excel interview__key HH13 EP2ka using "$folderpath/document/EP2ka_1.xlsx" if (EP2ka < 1920 | EP2ka > 2025) & !inlist(EP2ka,.,.a,9998), firstrow(variables) replace
}


//4)

*l'année mentionné ne peut pas etre inférieur à la date de naissance 

cap drop annee_naiss
gen annee_naiss = annee - M4Confirm if EN_EMP == 1 & !inlist(M4Confirm,.,.a,9998) & M4Confirm >=15  

count if annee_naiss > EP2ka & !inlist(EP2ka,.,.a,9998) & !inlist(annee_naiss,.,.a,9998) // 2 individu pour qui l'année renseigné est inferieure à la date de naissance 

*exportation

count if annee_naiss > EP2ka & !inlist(EP2ka,.,.a,9998) & !inlist(annee_naiss,.,.a,9998)
if r(N)>0 {
    export excel interview__key HH13 EP2ka annee_naiss using "$folderpath/document/EP2ka_2.xlsx" if annee_naiss > EP2ka & !inlist(EP2ka,.,.a,9998) & !inlist(annee_naiss,.,.a,9998), firstrow(variables) replace
}

br EP2ka annee_naiss M4Confirm if annee_naiss > EP2ka & !inlist(EP2ka,.,.a,9998) & !inlist(annee_naiss,.,.a,9998)

*proposition de correction 
*nous remplaçons la valeur pour leur mettre à l'age minimum de debut de travail

replace EP2ka = annee_naiss + 16 if annee_naiss > EP2ka & !inlist(EP2ka,.,.a,9998) & !inlist(annee_naiss,.,.a,9998)


//////////////////////////EP2k1_m. Depuis quel mois avez-vous commen cé é à travailler dans cette entreprise ou cet en droit pour votre emploi principal ?

//1) 

count if missing(EP2k1_m) & !inlist(EP2ka,.,.a,9998) // un individu pour qui l'info est manquante 

*exportation

count if missing(EP2k1_m) & !inlist(EP2ka,.,.a,9998)
if r(N)>0 {
    export excel interview__key HH13 EP2ka EP2k1_m using "$folderpath/document/EP2k1_m.xlsx" if missing(EP2k1_m) & !inlist(EP2ka,.,.a,9998), firstrow(variables) replace
}

*proposition de correction 

replace EP2k1_m = 9998 if missing(EP2k1_m) & !inlist(EP2ka,.,.a,9998)


//2) 

count if !missing(EP2k1_m) & inlist(EP2ka,.,.a,9998) //RAS

replace EP2k1_m =. if !missing(EP2k1_m) & inlist(EP2ka,.,.a,9998) 

//3)
//4)

/////////////////EP2k. Depuis combien d’année avez-vous com mencé à travailler dans cette entreprise ou cet endroit dans votre emploi principal ? 

//1) 

count if missing(EP2k) &  EP2ka==9998 //RAS, car il s'agit des personnes dont nous venons d'imputer l'information à EP2ka

//2) 

count if !missing(EP2k) &  !inlist(EP2ka,9998,.,.a) //RAS


//3)

*l'information ne peut pas etre inferieure à Zero

count if EP2k <0 // RAS



//4)

*l'information ne peut pas etre supérieure à l'age de l'individu

count if EP2k > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(EP2k,.,.a,9998) // 9 individus sont concernés

*exportation

count if EP2k > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(EP2k,.,.a,9998)
if r(N)>0 {
    export excel interview__key HH13 EP2k M4Confirm using "$folderpath/document/EP2k.xlsx" if EP2k > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(EP2k,.,.a,9998), firstrow(variables) replace
}

*proposition de correction

br EP2k M4Confirm if EP2k > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(EP2k,.,.a,9998) // il s'agit donc des individus qui ont mentionné l'année plutot que le nombre d'année

replace EP2k = annee - EP2k  if EP2k > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(EP2k,.,.a,9998) & EP2k != 28

*replace EP2k = annee - EP2k  if EP2k == 1994 &  EP2k > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(EP2k,.,.a,9998) & EP2k != 28


*replace EP2k = M4Confirm - 11 if (EP2k == 66) & EP2k > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(EP2k,.,.a,9998)



/////////////EP2k_m. Depuis %EP2k% Année et combien de mois avez vous commencé à travailler dans cet te entreprise ou cet endroit ?

//1) 

count if missing(EP2k_m) & !inlist(EP2k,9998,.,.a)

//2) 

count if !missing(EP2k_m) & EP2k==9998

//3)
//4)



//////////////////EP2k2a. Depuis quelle année exercez-vous votre emploi actuel ?

//1) 

count if missing(EP2k2a) &  EP2jb==1  // RAS

*exportation

*export excel interview__key HH13 EP2k2a EP2jb using "$folderpath/document/EP2k2a.xlsx" if missing(EP2k2a) &  EP2jb==1, firstrow(variables) replace

*proposition de correction 

*replace EP2k2a = 9998 if missing(EP2k2a) &  EP2jb==1

//2) 

count if !missing(EP2k2a) &  EP2jb==2  

//3)

ta EP2k2a

*l'information ne peut pas etre inferieure à zero ou superieure à 2024

count if (EP2k2a < 1920 | EP2k2a > 2026) & !inlist(EP2k2a,.,.a,9998) //RAS


//4) 

*l'année mentionnée ne peut pas etre inférieur à la date de naissance 
 

count if annee_naiss > EP2k2a & !inlist(EP2k2a,.,.a,9998) & !inlist(annee_naiss,.,.a,9998) // RAS
*exportation

*l'année mentionnée ne peut pas etre inférieur à EP2ka


count if EP2ka > EP2k2a & !inlist(EP2ka,.,.a,9998) & !inlist(EP2k2a,.,.a,9998) // 25 individu concernés

*exportation

count if EP2ka > EP2k2a & !inlist(EP2ka,.,.a,9998) & !inlist(EP2k2a,.,.a,9998)
if r(N)>0 {
    export excel interview__key HH13 EP2k2a EP2ka EP2jb using "$folderpath/document/EP2k2a_1.xlsx" if EP2ka > EP2k2a & !inlist(EP2ka,.,.a,9998) & !inlist(EP2k2a,.,.a,9998), firstrow(variables) replace
}


br EP2ka EP2k2a EP2jb if EP2ka > EP2k2a & !inlist(EP2ka,.,.a,9998) & !inlist(EP2k2a,.,.a,9998)

*proposition de correction 

replace EP2k2a = EP2ka + 1 if EP2ka > EP2k2a & !inlist(EP2ka,.,.a,9998) & !inlist(EP2k2a,.,.a,9998)

///////////EP2k1a. Depuis quel mois exercez-vous votre e

//1)

count if missing(EP2k1a) &  EP2jb==1 & !inlist(EP2k2a,9998,.,.a) //RAS 

//2)

count if !missing(EP2k1a) &  (EP2jb==2 | inlist(EP2k2a,9998,.,.a)) //RAS

//3)
//4)

/////////////////EP2k2. Depuis combien d’année exercez-vous votre emploi actuel ?

//1) 

count if missing(EP2k2) & EP2k2a==9998 & EP2jb==1 //RAS

//2) 

count if !missing(EP2k2) & (!inlist(EP2k2a,9998,.,.a) & EP2jb==2)

//3)

ta EP2k2,miss // certaines valeurs sont incoherentes 

count if EP2k2 > 50 & !missing(EP2k2)

*exportation

count if EP2k2 < 1920
if r(N)>0 {
    export excel interview__key HH13 EP2k2 using "$folderpath/document/EP2k2.xlsx" if EP2k2 < 1920, firstrow(variables) replace
}

*proposition de correction 

replace EP2k2 = 1 if EP2k2 == 2024

//4) 

//////////EP2k1. Depuis %EP2k2% Année et combien de mois exercez-vous votre emploi actuel ?

//1) 

count if missing(EP2k1) & !inlist(EP2k2,9998,.,.a) & EP2jb==1 //RAS

//2) 

count if !missing(EP2k1) & (inlist(EP2k2,9998,.,.a) | EP2jb==2) // RAS car il s'agit des individus dont nous avons corrigé la valeur à EP2k2

replace EP2k1 =. if !missing(EP2k1) & (inlist(EP2k2,9998,.,.a) | EP2jb==2)


//3)

*le nombre de mois ne peut etre supérieure à 12 et inférieur à zero
count if (EP2k1 < 0 |EP2k1 > 12) & !inlist(EP2k1,.,.a,9998) // RAS 

//4)


////////////////////EP14B.L’unité économique que vous dirigez ou dans laquelle vous travaillez est-elle érigée en société ou a-t-elle une existence légale ?


//1) 

count if missing(EP14B) & inlist(EP11,3,4,6,7) // RAS car il s'agit pour la plupart des indivivus pour qui nous avons corrigé l'information a EP11

*exportation

count if missing(EP14B) & inlist(EP11,3,4,6,7)
if r(N)>0 {
    export excel interview__key HH13 EP14B using "$folderpath/document/EP14B.xlsx" if missing(EP14B) & inlist(EP11,3,4,6,7), firstrow(variables) replace
}

*proposition de correction 

br EP1a EP1b EP3 EP11 EP14B if missing(EP14B) & inlist(EP11,3,4,6,7) // nous nous aidons des informations à T2

replace EP14B = 2 if missing(EP14B) & inlist(EP11,3,4,6,7)


//2)

count if !missing(EP14B) & !inlist(EP11,3,4,6,7,.,.a)

//3)

//4)


////////////////EP15. Quelle est son statut juridique ?

//1)
count if missing(EP15) & EP14B == 1 & membre_id_v1_IND=="##N/A##"

br EP1a EP1b EP3 EP11 EP14B if missing(EP15) & EP14B == 1 & membre_id_v1_IND=="##N/A##"

replace EP14B = 2 if missing(EP15) & EP14B == 1 & membre_id_v1_IND=="##N/A##"

//2) 


count if !missing(EP15) & (inlist(EP14B,2,9998) |  (membre_id_v1_IND !="##N/A##" & membre_id_v1_IND !=""))

//3)


//4)

///////////////EP15_aut. Veuillez préciser

//1)

count if missing(EP15_aut) &  EP15 == 14

//2)


count if !missing(EP15_aut) &  !inlist(EP15,.,.a,14)

//3)

//4) la variable a déjà été checké lors du recodage des autres à préciser

////////////////////EP16. La gestion de l’entreprise/l’unité est-elle : Compte propre ou en association avec d’autres actionnaire ? 

//1)

count if missing(EP16) & ((!inlist(EP15,11,12,13,.,.a) |(inlist(EP14B,2,9998))) & membre_id_v1_IND== "##N/A##") //RAS

br EP1a EP1b EP3 EP11 EP16 if missing(EP16) & ((!inlist(EP15,11,12,13,.,.a) |(inlist(EP14B,2,9998))) & membre_id_v1_IND== "##N/A##") //RAS
//2) 

count if !missing(EP16) & ((inlist(EP15,11,12,13) & !inlist(EP14B,2,9998,.,.a)) | (membre_id_v1_IND!= "##N/A##" & membre_id_v1_IND!= "")) // RAS

//3)
//4)

  
//////////////////EP17. La production de biens ou services de vot re entreprise est-elle destinée : Principalement à la vente ; Partiellement à la vente ; Pas à la vente

//1)

count if missing(EP17) & inlist(EP11,3,4,6,7) // la plupart sont des individus pour qui nous avons corrigé l'information à EP11. Les vrais manquants sont corrigés 

*exportation

count if missing(EP17) & inlist(EP11,3,4,6,7)
if r(N)>0 {
    export excel interview__key HH13 EP17 using "$folderpath/document/EP17.xlsx" if missing(EP17) & inlist(EP11,3,4,6,7), firstrow(variables) replace
}

*proposition de correction 

br EP1a EP1b EP3 EP11 EP6a EP17 if EP17==.a // au vu des informations sur l'activité et le mode de revenu, la reponse à EP17 est sensé etre "entièrement à la vente"

replace EP17 = 1 if EP1a== "##N/A##" & EP17 ==.a
replace EP17 = 1 if EP1a== "agriculteur d'anacarde" & EP17 ==.a

br EP1a EP1b EP3 EP11 EP6a EP17 if EP17==3

//2) 

count if !missing(EP17) & !inlist(EP11,3,4,6,7,.,.a) // RAS

//3) 

//4)

*la question a été mal comprise par bon nombre d'agent. Ils ne considèrent pas les services comme des produits destinés à la vente. nous corrigeons cela 

replace EP17 = 1 if EP17 == 3 & (inlist(EP3,1,2,3,8,9) | inlist(EP11,1,2,3,5,6,8)) 

replace EP17 = 1 if EP1a == "APPRENTIE COIFFEUSE"
replace EP17 = 1 if EP1a == "COIFFEUSE"
replace EP17 = 1 if EP1a == "PASTEUR"
replace EP17 = 1 if EP1a == "PASTEURE"
replace EP17 = 1 if EP1a == "PASTEUR"
replace EP17 = 1 if EP1a == "COMMISSION DU FONCIER A LA CHEFERIE"
replace EP17 = 1 if EP1a == "APPRENTIE CHAUFFEUR POIDS LOURDS"
replace EP17 = 1 if EP1a == "GUIDE RELIGIEUX"
replace EP17 = 1 if EP1a == "CONDUCTEUR DE TRICYCLE"
replace EP17 = 1 if EP1a == "MECANICIEN"


//au vu des autres valeurs, certains individus sont checké un à un pour mieux comprendre leur situation

*exportation prealable 

*exportation

count if EP17==3
if r(N)>0 {
    export excel interview__key membres__id HH13 EP1a EP1b EP3 EP11 EP6a EP17 using "$folderpath/document/EP17_incoherent.xlsx" if EP17==3, firstrow(variables) replace
}



/*replace EN_EMP = 0 if (interview__key == "02-08-16-11" & membres__id==1)   // au vu des autres informations il s'agit de personnes n'étant pas en emploi

replace SE1 = 2 if (interview__key == "02-08-16-11" & membres__id==1)

replace SE2 = 10 if (interview__key == "02-08-16-11" & membres__id==1) 

replace SE3 = 5 if (interview__key == "02-08-16-11" & membres__id==1) 

replace SE4 = 2 if (interview__key == "02-08-16-11" & membres__id==1) 

replace SE5 = 2 if (interview__key == "02-08-16-11" & membres__id==1)

replace SE8 = 2 if (interview__key == "02-08-16-11" & membres__id==1)*/


replace EN_EMP = 0 if EP17 == 3 & EP11 == 4 & (EP3==5 | EP3==6)   // au vu des autres informations il s'agit de "travailleur familiaux" n'étant pas en emploi 

replace SE1 = 2 if EP17 == 3 & EP11 == 4 & (EP3==5 | EP3==6) & EP6a ==.

replace SE2 = 10 if EP17 == 3 & EP11 == 4 & (EP3==5 | EP3==6) & EP6a ==.

replace SE3 = 5 if EP17 == 3 & EP11 == 4 & (EP3==5 | EP3==6) & EP6a ==.

replace SE4 = 2 if EP17 == 3 & EP11 == 4 & (EP3==5 | EP3==6) & EP6a ==.

replace SE5 = 2 if EP17 == 3 & EP11 == 4 & (EP3==5 | EP3==6) & EP6a ==.

replace SE8 = 2 if EP17 == 3 & EP11 == 4 & (EP3==5 | EP3==6) & EP6a ==.

br EP1a EP1b EP3 EP11 EP6a EP17 if EP17==3 & EN_EMP ==1

*replace EP17 = 1 if (interview__key == "07-66-72-75" & membres__id==2) 


///////////////////EP18. A quel régime fiscal votre unité de production est-elle assujettie

//1)

count if missing(EP18) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7) // RAS car il s'agit des individus dont nous avons corrigé l'info à EP11 

//2)

count if !missing(EP18) & ((membre_id_v1_IND != "##N/A##" & membre_id_v1_IND != "")  | !inlist(EP11,3,4,6,7,.,.a))

//3)

//4)

////////////////////EP19 - EP23


//1) 

foreach var of varlist EP19 - EP23 {

count if missing(`var') & inlist(EP11,3,4,6,7) // RAS car il s'agit des individus pour qui nous avons corrigé l'information à EP11

}

count if EP19 ==.a
count if EP20 ==.a // RAS

br EP1a EP1b EP3 EP11 EP6a EP17 EP20 if EP20 ==.a // nous nous aidons des informations à T3 2025

*replace EP20 = 2 if EP20 ==.a

count if EP21 ==.a // necessite des imputations
*proposition

br EP1a EP1b EP3 EP11 EP6a EP17 EP21 V1interviewkey membre_id_v1 if EP21 ==.a // nous nous aidons des informations à T3 2025

*replace EP21 = 2 if EP21 ==.a

count if EP22 ==.a // necessite des imputations
*proposition

br EP1a EP1b EP3 EP11 EP6a EP17 EP22 V1interviewkey membre_id_v1 if EP22 ==.a // nous nous aidons des informations à T2

*replace EP22 = 2 if EP22 ==.a 

count if EP23 ==.a // necessite des imputations
*proposition

br EP1a EP1b EP3 EP11 EP6a EP17 EP23 V1interviewkey membre_id_v1 if EP23 ==.a // nous nous aidons des informations à T3 2025

*replace EP23 = 2 if EP23 ==.a 


//2) 

foreach var of varlist EP19 - EP23 {

count if !missing(`var') & !inlist(EP11,3,4,6,7,.,.a) // RAS 

}

/////////////EP24. Sous quel système votre comptabilité est

//1) 

foreach var of varlist EP24__1-EP24__9998 {

count if missing(`var') & inlist(EP11,3,4,6,7) //// RAS car il s'agit des individus pour qui nous avons corrigé l'information à EP11 // certains necessite des corrections


}

*proposition de correction 

foreach var of varlist EP24__1 EP24__2 EP24__3 EP24__4 EP24__9998  {

count if missing(`var') & inlist(EP11,3,4,6,7) //// RAS car il s'agit des individus pour qui nous avons corrigé l'information à EP11 // certains necessite des corrections

*replace `var' = 0 if missing(`var') & inlist(EP11,3,4,6,7) & `var' ==.a


}

*replace EP24__5 = 1 if EP24__5 ==.a


//2)

foreach var of varlist EP24__1-EP24__9998 {

count if !missing(`var') & !inlist(EP11,3,4,6,7,.,.a) //RAS

}

//3
//4

//////////////////EP24_Aut. Veuillez préciser

//1)

count if missing(EP24_Aut) & EP24__4 == 1 // RAS

//2)

count if !missing(EP24_Aut) & EP24__4 == 0 // RAS

//3
//4 les informations ont été déjà checké lors du récodage des autres à préciser


//////////////EP25. Dans quel type de local exercez-vous votre emploi principal ?

//1)

count if missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7) // RAS car il s'agit des individus pour qui nous avons corrigé l'information à EP11 

br EP25 EP1a EP1b EP3 EP11 if missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7) // RAS car il s'agit des individus pour qui nous avons corrigé l'information à EP11 


*proposition de correction 
replace EP25 = 10 if missing(EP25) & membre_id_v1_IND == "##N/A##" & EP11==4



replace EP25=6 if EP1a=="VENDEUSE DE JUS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE VÊTEMENTS DE FEMME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCE DE PIMENT EN POUDRE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PRODUITS COSMETIQUES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="PROFESSEUR D HISTOIRE GEOGRAPHIE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE TAXI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE RIZ" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUR DE KARITÉ,SORGHO,MIL ET IGNAME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE  SUCRE,LAIT ET THÉ" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUR DE KARITÉ,SORGHO,MIL ET IGNAME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE KABATO ACCOMPAGNÉ DE SAUCE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUR D ANACRDE,BEURRE DE KARITÉ,SORGHO,MIL ET IGNAME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE POISSON FUMEE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="MACONNERIE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="ELECTRICIEN INDUSTRIEL" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE LEGUMES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PARFUM NATUREL" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="ACCOMPAGNEMENT D'ENTREPRISE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="OUVRIER DANS UNE BOULANGERIE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PLACALI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUSE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERÇANT DE BŒUFS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE GLACES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUSE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="CHARBONNIER" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CONDUCTEUR DE POIDS LOURD" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE JUS LOCAL" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE JUS ET GÂTEAU" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE CONDIMENTS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="VIGILE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCE DE PIMENT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=6 if EP1a=="PRODUCTRICE DE JUS DE FRUIT ET GLACE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="APPRENTI ELECTRICIEN AUTO" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE BEIGNET" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE CANARI ET MEDICAMENT TRADITIONNEL" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE CHARBON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE POISSON FRAIS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCANTE DE CHARBON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="OUVRIERE D'USINE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="FERRONIER" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PRODUIT COSMETIQUE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE BOISSONS ALCOOLISEES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PORC AU FOUR" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCIAL DANS DEPOT SOLIBRA" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PORC AU FOUR" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PLACALI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D ALIMENTS PRÉPARÉS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE BOISSONS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="FABRICATION D'ATIEKE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="TRANSFORMATION DE MANIOC" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE POISSON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="vendeuse de legumes" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="PASTEUR DE L'EGLISE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="AGENT DE SECURITE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COUTURE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE POISSON SEC" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="ENSEIGNANT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUSE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="STANDARDISTE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="INSTITUTRICE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PAIN" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="GERANT DE CYBER" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="AIDE VENDEUSE DE PAIN" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE CHAUSSURES, SACS ET PAGNES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PAIN ET CONDIMENTS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE TAXI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="MACON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE GALETTE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE BEIGNET" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D'ATTIEKE ET POISSON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE VETEMENTS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PLACALI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="SERVICE DE NETTOYAGE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE VIVRIER TOMATE OIGNON CHOUX AUBERGINE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="Servir les médicaments à la pharmacie" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D'ATTIEKE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="ENSEIGNANT A DOMICILE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D ATTIEKE ET POISSON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE POMMADES ET CHAUSSURES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUR DE VETEMENTS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR PERSONNEL PRIVÉ" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCE DE VETEMENT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="GERANTE DE BOUTIQUE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="FABRIQUANT DE KOUTOUKOU" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE DRAP" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCE DE DRAPS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE GROS CAMION" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="EBENISTE DE MEUBLE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="TRANSFORMATION DE MANIOC EN ATTIEKE ET PLACALI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENTE D'ESCARGOTS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCANT DE SACHET" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="MAÇON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE MEDICAMENTS TRADITIONNELS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE TAXI MOTO" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUR" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="restauratrice" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D ATTIEKE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="vendeuse de condiments" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="mécanicien" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE GROS CAMION" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE LEGUMES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE TAXI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUSE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE LEGUME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PAGNE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE PETIT CAMION" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERÇANT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERÇANTE DE CHAINES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D'HABITS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D'HABITS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERÇANTE DE PAGNES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE NOURRITURE (FOUTOU)" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="LAVEUR DE MOTO" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCANTE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="ENTREPRENEUR EN ELECTRICITE BATIMENT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE TCHAPALO" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="BIJOUTIER" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="AIDE MAÇON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE BEIGNET" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PRODUITS COSMETIQUE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="OUVRIER DE PRODUCTION" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="PRODUCTION D'ATTIEKE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE POISSON" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE POISSONS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="CAISSIER" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE LEGUMES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE CONDIMENTS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUR D'HABITS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCANTE DE PLACALI" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUR D�HUILE AMBULANT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENTE DE LEGUMES AU MARCHE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="PREPARATRICE D'ATTIEKE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE JUS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE GOMBOS,AUBERGINES, PIMENTS...." & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUR HOMME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCANT DE PRODUITS PHYTOSANITAIRES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="GERANTE DE POINT DE DEPOT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="ELECTRICIEN" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="Vendeur de nourriture" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="COURSIER" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PAGNE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE PAIN" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="INSTITUTRICE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="RAFISTOLEUR" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE DRAP FRIPERIE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE CAMION" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE SOUMARA ET BEURRE DE KARITE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="COMMERCE FRUIT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="APPRENTI MECANICIEN" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="GERANT DE SALON DE COIFFURE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUSE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="vendeuse d'alloco" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COUTURE DAME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="PATISSIERE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE FRIPPERIE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="APPRENTI MECANICIEN MOTO" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE D'HUILE ROUGE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE BEIGNEIT" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=4 if EP1a=="CHAUFFEUR DE POIDS LOURD" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="CUISINIERE" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="AGENT DE CONSTRUCTION" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="MECANICIEN AUTO" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE POMMADE ET PARFUM" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="AUXILIAIRE DE SOIN" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="COIFFEUSE DAME" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE VETEMENTS" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=5 if EP1a=="LAVEUSE DE LINGES SALES" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=8 if EP1a=="VENDEUSE DE BANANE PLANTAIN" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)
replace EP25=9 if EP1a=="AGENT COMMERCIAL" & missing(EP25) & membre_id_v1_IND=="##N/A##" & inlist(EP11,3,4,6,7)


replace EP25 = 10 if EP1a == "AGRICULTRICE D ANACARDE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATRICE D'IGNAME" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1b == "AIDE VENDEUR D ANACARDRE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "AIDE VENDEUR D ANACARDRE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1b == "FRIGORISTE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)


replace EP25 = 8 if EP1a == "VENDEUSE DE POISSON FUME" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR D'HEVEA" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR D'HEVEA" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR DE CACAO" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR DE CACAO" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR D'HEVEA" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATRICE DE MANIOC" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "AGRICULTEUR D ANACARDE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR D ANACARDE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "PRODUCTRICE D'ATTIEKE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "GERANTE DE CAVE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "GERANTE  DE BOUTIQUE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "VENDEUSE EN BOUTIQUE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "AGRICULTEUR DE CACAO" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR DE CACAO" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "HORTICULTEUR" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "MANOEUVRE AGRICOLE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR DE CACAO" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATEUR CACAO" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "CULTIVATRICE CACAO" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "ENSEIGNANT DANS ECOLE PRIVÉE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "PREPARATEUR GESTIONNAIRE DE PHARMACIE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 9 if EP1a == "AGRICULTEUR D ANACARDE" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "PLANTEUR" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 10 if EP1a == "PLANTEUR" & missing(EP25) & membre_id_v1_IND == "##N/A##" & inlist(EP11,3,4,6,7)

replace EP25 = 13 if EP25 ==.a

//2)

count if !missing(EP25) & ((membre_id_v1_IND != "##N/A##" & membre_id_v1_IND != "")  | !inlist(EP11,3,4,6,7,.,.a)) //RAS

//3

//4

count if !inlist(EP25,.,.a,10) & EP11==4 // les personnes ayant repondu EP11 = 4 ne peuvent repondre que EP25 == 10


*exportation

count if !inlist(EP25,.,.a,10) & EP11==4
if r(N)>0 {
    export excel interview__key HH13 EP25 EP11 using "$folderpath/document/EP25.xlsx" if !inlist(EP25,.,.a,10) & EP11==4, firstrow(variables) replace
}

*correction 

replace EP25 = 10 if !inlist(EP25,.,.a,10) & EP11==4

////////////////////EP25_Aut. Veuillez préciser

//1)

count if missing(EP25_Aut) &  EP25 == 13 // RAS

//2)

count if !missing(EP25_Aut) &  !inlist(EP25,.,.a,13) // RAS


//3
//4 les informations ont été déjà checké lors du récodage des autres à préciser


//////////////////EP26A. Pouvez-vous fixer le prix des services que vous offrez ? 

//1)

count if missing(EP26A) & inlist(EP3,2,3,4) // certains indivivu concernés

*exportation

count if missing(EP26A) & inlist(EP3,2,3,4)
if r(N)>0 {
    export excel interview__key HH13 EP26A EP3 using "$folderpath/document/EP26A.xlsx" if missing(EP26A) & inlist(EP3,2,3,4), firstrow(variables) replace
}

*proposition de correction 

br EP1a EP1b EP3 EP11 EP6a  EP26A V1interviewkey membre_id_v1 if EP26A==.a // nous nous aidons des informations à T3


replace EP26A = 2 if (V1interviewkey=="21-29-23-96" & membre_id_v1 == "1")

replace EP26A = 1 if (V1interviewkey=="40-12-12-42" & membre_id_v1 == "2")

replace EP26A = 2 if (V1interviewkey=="98-18-66-84" & membre_id_v1 == "1")




/*replace EP26A = 2 if (V1interviewkey=="40-61-11-89" & membre_id_v1 == "1")

replace EP3 = 1 if (V1interviewkey=="41-85-28-20" & membre_id_v1 == "2")

replace EP26A =. if (V1interviewkey=="41-85-28-20" & membre_id_v1 == "2")*/
 


//2)

count if !missing(EP26A) & !inlist(EP3,2,3,4,.,.a) // RAS car il s'agit des individus pour qui nous avons corrigé l'information à EP3

replace EP26A=. if !missing(EP26A) & !inlist(EP3,2,3,4,.,.a)

//3)
//4)

/////////////////EP26B . La famille peut-elle fixer le prix des produits ou services offerts par l'entreprise. 

//1)

count if missing(EP26B) & EP3==5 & inlist(EP4,1,2) // RAS

*exportation

*export excel interview__key HH13 EP26B EP3 EP4 using "$folderpath/document/EP26B.xlsx" if missing(EP26B) & EP3==5 & inlist(EP4,1,2), firstrow(variables) replace

//2)

count if !missing(EP26B) & (!inlist(EP3,5,.,.a) |!inlist(EP4,1,2,.,.a)) //RAS

//3
//4


////////////EP27A.Pourquoi ne pouvez-vous pas fixer le pri x des produits ou services offerts par l’entreprise ? 


//1)

count if missing(EP27A) & EP26A == 2 //RAS

//2)

count if !missing(EP27A) & EP26A == 1

//3)
//4)

///////////// EP27A_Aut. Veuillez préciser

//1)

count if missing(EP27A_Aut) & EP27A == 6 //RAS

//2)

count if !missing(EP27A_Aut) & !inlist(EP27A,.,.a,6) //RAS

//3)
//4) la variable a déjà été checké lors du récodage des autres à préciser. Certains individus on mentionné que les produits ne sont pas destinée à la vente, ils ne sont pas en emploi au sens de la définition. CEPENDANT ce n'est pas le cas ici pour le T1 2025

br EP27A_Aut EP27A EP1a EP1b EP3 EP11 if !missing(EP27A_Aut) & EN_EMP

/*
export excel interview__key membres__id HH13 EP1a EP1b EP3 EP11 EP6a EP27A EP27A_Aut using "$folderpath/document/EP27A_pas_emploi.xlsx" if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE"), firstrow(variables) replace


replace EN_EMP = 0 if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE")
 	

replace SE1 = 2 if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE")  

replace SE2 = 10 if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE")  

replace SE3 = 5 if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE")  

replace SE4 = 2 if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE")  

replace SE5 = 2 if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE")  

replace SE8 = 2 if regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE") | regexm(EP27A_Aut,"PAS EN VENTE") | regexm(EP27A_Aut,"PAS A LA VENTE")  


br EP27A_Aut EP27A EP1a EP1b EP3 EP11 if !missing(EP27A_Aut) & EN_EMP == 1*/


////////////// EP27B. Pourquoi la famille ne peut pas fixer les prix ?

//1)

count if missing(EP27B) & EP26B == 2
//RAS

//2)

count if !missing(EP27B) & EP26B == 1

//3)
//4)


///////////EP27B_Aut. Veuillez préciser

//1)

count if missing(EP27B_Aut) & EP27B == 6 //RAS

//2)

count if !missing(EP27B_Aut) & !inlist(EP27B,.,.a,6) //RAS

//3)
//4) la variable a déjà été checké lors du récodage des autres à préciser. Certains individus on mentionné que les produits ne sont pas destinée à la vente, ils ne sont pas en emploi au sens de la définition

br EP27B_Aut EP27B EP1a EP1b EP3 EP11 if !missing(EP27B_Aut) & EN_EMP ==1

*replace EP27B = 3 if EP27B_Aut == "le prix est homologué" 

*replace EP27B_Aut = "" if EP27B_Aut == "le prix est homologué" 

/*
export excel interview__key membres__id HH13 EP1a EP1b EP3 EP11 EP6a EP27B EP27B_Aut using "$folderpath/document/EP27B_pas_emploi.xlsx" if regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE"), firstrow(variables) replace


replace EN_EMP = 0 if (regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE"))
 	

replace SE1 = 2 if regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE")  

replace SE2 = 10 if regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE")  

replace SE3 = 5 if regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE")  

replace SE4 = 2 if regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE")  

replace SE5 = 2 if regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE")  

replace SE8 = 2 if regexm(EP27B_Aut,"UNIQUEMENT POUR LA CONSOMMATION") | regexm(EP27B_Aut,"JUSTE POUR CONSOMMER") | regexm(EP27B_Aut,"USAGE FAMILIALE") | regexm(EP27B_Aut,"AGRICULTURE DE SUBSISTANCE") |regexm(EP27B_Aut,"N'EST PAS À VENDRE") | regexm(EP27B_Aut,"PAS A VENDRE") 
*/


/////////////////EP28. Dans le cas de votre activité avez vous un contrat écrit ou un accord verbal (%rostertitle)

//1)

count if missing(EP28) & ((inlist(EP3,1,8,9) | ( inlist(EP3,5,6)  & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1)) | EP12 == 2 ))

*exportation

count if missing(EP28) & ((inlist(EP3,1,8,9) | ( inlist(EP3,5,6)  & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1)) | EP12 == 2 ))
if r(N)>0 {
    export excel interview__key HH13 EP28 EP3 EP6__1 EP6__2 EP6__3 EP6__5 EP6__6 EP6__7 EP6__9 EP6__11 EP6__12 EP12 using "$folderpath/document/EP28.xlsx" if missing(EP28) & ((inlist(EP3,1,8,9) | ( inlist(EP3,5,6)  & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1)) | EP12 == 2 )), firstrow(variables) replace
}

*proposition de correction 

br EP1a EP1b EP3 EP11 EP28 if EP28 ==.a  //


replace EP28 = 1 if EP28 ==.a & EP3==1 & EP11 == 1

replace EP28 = 1 if EP28 ==.a & EP1b == "SURVEILLANCE DE SOCIETE"
**/



//2)

count if !missing(EP28) & !((inlist(EP3,1,8,9) | ( inlist(EP3,5,6)  & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1)) | EP12 == 2 )) //RAS



//3
//4

///////////EP29. Votre contrat écrit ou votre accord verbal ou votre entente est-elle ....?

//1) 

count if missing(EP29) & inlist(EP28,1,2) // 


br EP1a EP1b EP3 EP11 EP29 if missing(EP29) & inlist(EP28,1,2) //

*Correction
replace EP29 = 3 if missing(EP29) & inlist(EP1b, "INSPECTEUR DETECTEUR DE DROGUES ET STUPEFIANTS", "SURVEILLANCE DE SOCIETE")
 
//2)

count if !missing(EP29) & !inlist(EP28,1,2,.,.a) //RAS

//3
//4

/////////////EP29a. Ce contrat est-il occasionnel à la journée occasionnel saisonnier

//1)

count if missing(EP29a) & inlist(EP29,1,2,4) //RAS

//2)

count if !missing(EP29a) & !inlist(EP29,1,2,4,.,.a) //RAS

//3)
//4)

////////////////EP30. Quelle est la durée de travail selon l’accord actuel ? *


//1)

count if missing(EP30) & inlist(EP29,1,2) //RAS

//2)

count if !missing(EP30) & !inlist(EP29,1,2,.,.a) //RAS


//3)

count if EP30 <=0 & !missing(EP30) // la durée du contrat ne peut pas etre negative ou égal à zero

//4)


///////////////////EP30b. Choisir l'unité ?

//1)

count if missing(EP30b) & EP30 != 9998 & !missing(EP30) //RAS

//2)

count if !missing(EP30b) & EP30 == 9998 //RAS

//3)

//4)

count if EP30b == 2 & EP30 > 10 & !inlist(EP30,.,.a,9998) // la durée du contrat ne doit pas etre trop longue. Il est peut probable que la durée du contrat soit superieure à 10 ans. RAS

count if EP30b == 3 & EP30 < 10 & !inlist(EP30,.,.a,9998) // il est peut probable que la durée du contrat soit inférieure à 10 jours // 10 individus concernés




*exportation

count if EP30b == 3 & EP30 < 10 & !inlist(EP30,.,.a,9998)
if r(N)>0 {
    export excel interview__key HH13 EP30b EP30 using "$folderpath/document/EP30b.xlsx" if EP30b == 3 & EP30 < 10 & !inlist(EP30,.,.a,9998), firstrow(variables) replace
}



//////////////EP30c. Si vous avez du mal à indiquer une durée précise, pouvez-vous specifier s'il s'agit...

//1) 

count if missing(EP30c) & (inlist(EP29,4) | EP30 == 9998) //RAS

//2)

count if !missing(EP30c) & !inlist(EP29,4,.,.a) & !inlist(EP30,9998,.,.a) //RAS

//3)
//4)

/////////////////EP31. Lequel des éléments suivants s’applique à votre situation pour votre emploi principale 


//1)

foreach var of varlist EP31__1 EP31__2 EP31__3 EP31__4 EP31__5 {

count if missing(`var') & inlist(EP29,1,2,4) //RAS 

}

//2) 

foreach var of varlist EP31__1 EP31__2 EP31__3 EP31__4 EP31__5 {

count if !missing(`var') & !inlist(EP29,1,2,4,.,.a) //RAS 

}

//3)

//4)


//////////////EP31_Aut. Veuillez préciser ?

//1)

count if missing(EP31_Aut) & EP31__5 == 1 // il s'agit des individus pour lesquels nous avons récodé leurs informations à EP31_Aut 

  
br EP31_Aut EP31__1 EP31__2 EP31__3 EP31__4 EP31__5 if missing(EP31_Aut) & EP31__5 == 1

replace EP31__5 = 0 if missing(EP31_Aut) & EP31__5 == 1 


//2)

count if !missing(EP31_Aut) & EP31__5 == 0 // RAS


//3)

//4) Variable déjà checkée et récodée 

////////////EP32. Le contrat actuel est-il une étape dans un processus d’obtention d’un contrat à durée ind éterminée 

//1) 

count if missing(EP32) & (EP29==1 & (EP31__2 == 1 | EP31__3 == 1 | EP31__4 ==1 | EP31__5 == 1)) //RAS

//2)

count if !missing(EP32) & (!inlist(EP29,.,.a,1) | (EP31__2 == 0 & EP31__3 == 0 & EP31__4 ==0 & EP31__5 == 0)) //RAS car il s'agit des personnes dont nous avons corrigé la valeur à EP31__5 

replace  EP32=. if !missing(EP32) & (!inlist(EP29,.,.a,1) | (EP31__2 == 0 & EP31__3 == 0 & EP31__4 ==0 & EP31__5 == 0))

//3)

//4)

////////////EP33. Avez-vous convenu d’un nombre d’heures de travail avec votre employeur ? 

//1)

count if missing(EP33) & ((inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))) & EP12==2) //RAS car il s'agit des individus pour lequel nous avons corrigé les info à EP3 et EP6

*proposition de correction 
replace EP33 = 2 if missing(EP33) & ((inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))) & EP12==2)


//2

count if !missing(EP33) & ((!inlist(EP3,1,8,9,.,.a) & (!inlist(EP3,5,6,.,.a) | (EP6__1 == 0 & EP6__2 == 0 & EP6__3 == 0 & EP6__5 == 0 & EP6__6 == 0 & EP6__7 == 0 &  EP6__9 == 0 & EP6__11 == 0 & EP6__12 == 0 )))  | EP12==1) //RAS

//3)
//4)

/////////////////////////EP34.Combien d'heures de travail convenues ou contractuelles par semaine dans ce travail. 

//1)

count if missing(EP34) & EP33 == 1 //RAS

//2) 

count if !missing(EP34) & EP33 == 2 //RAS


//3)

count if EP34 <=0 // le nombre d'heure convenues ne peut pas etre négatif ou égal à zero. RAS

count if EP34 > 168 & !missing(EP34) // le nombre d'heure ne peut pas etre supérieure à 168

//4)


/////////////////EP35. %rostertitle%, avez vous un minimum d’heures garanties

//1)

count if missing(EP35) & EP33 == 2

*Correction
replace EP35 = 2 if missing(EP35) & EP33 == 2

//2)

count if !missing(EP35) & EP33 == 1

//3)

//4)

/////////////////EP36a. Y a-t-il au moins un syndicat dans l’entreprise où vous excercer votre emploi principal ?

//1)

br EP1a EP3 EP11 EP36a if missing(EP36a) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) // RAS car il s'agit des individus dont nous avons corrigé l'info à EP6__

//2)

count if !missing(EP36a) & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !="" // RAS 

//3)

//4)

/////////////////// EP36b. Etes vous membres d’un de ces syndicat ? 


//1)

count if missing(EP36b) &  EP36a == 1 //RAS

//2)

count if !missing(EP36b) &  EP36a == 2 //RAS

//3)
//4)

//////////////////EP37-EP39


//1)

foreach var of varlist EP37-EP39 {

count if missing(`var') & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))) //il s'agit pour certains des individus pour qui nous avons corrigé l'info à EP3

*exportation

count if missing(`var') & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))
if r(N)>0 {
    export excel interview__key HH13 `var' EP3 using "$folderpath/document/`var'.xlsx" if missing(`var') & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))), firstrow(variables) replace
}

}

*proposition de correction 

/*
br EP1a EP1b EP3 EP11 EP37-EP39 if (EP37==.a | EP38==.a | EP39==.a)

replace EP37 =1 if EP37==.a & EP1a == "PROFESSEUR DE FRANCAIS"
replace EP38 =1 if EP38==.a & EP1a == "PROFESSEUR DE FRANCAIS"
replace EP39 =1 if EP39==.a & EP1a == "PROFESSEUR DE FRANCAIS"

replace EP37 =2 if EP37==.a & EP1a == "MENUSIER"
replace EP38 =2 if EP38==.a & EP1a == "MENUSIER"
replace EP39 =2 if EP39==.a & EP1a == "MENUSIER"
*/



//2)

foreach var of varlist EP37-EP39 {

count if !missing(`var') & !(inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))) //RAS

*exportation

*export excel interview__key HH13 `var' EP3 using "$folderpath/document/`var'.xlsx" if !missing(`var') & !(inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))), firstrow(variables) replace

}

//3)
//4)

////////////////////EP40

//1)

count if missing(EP40) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 ))))

*exportation

count if missing(EP40) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 ))))
if r(N)>0 {
    export excel interview__key HH13 EP40 EP3 using "$folderpath/document/`var'.xlsx" if missing(EP40) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 )))), firstrow(variables) replace
}

//2)

count if !missing(EP40) & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !=""

*exportation

*export excel interview__key HH13 EP40 EP3 using "$folderpath/document/`var'.xlsx" if !missing(EP40) & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !="", firstrow(variables) replace

//3)
//4)

/////////////////EP41-EP43

//1)

foreach var of varlist EP41-EP43 {

count if missing(`var') & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))))

*exportation

count if missing(`var') & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))))
if r(N)>0 {
    export excel interview__key HH13 `var' EP3 using "$folderpath/document/`var'.xlsx" if missing(`var') & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))), firstrow(variables) replace
}

}

//2)

foreach var of varlist EP41-EP43 {

count if !missing(`var') & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !=""

*exportation

*export excel interview__key HH13 `var' EP3 using "$folderpath/document/`var'.xlsx" if !missing(`var') & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !="", firstrow(variables) replace

}

//3)
//4)


/////////////////////EP43a. Précisez le pourcentage de la couverture maladie fournie par l'entreprise


//1)

count if missing(EP43a) & EP43 == 1 //RAS

//2)

count if !missing(EP43a) & inlist(EP43,2,9998) //RAS

//3)

count if EP43a <=0 // le pourcentage ne peut pas etre inférieure ou égale à 0

count if EP43a > 100 & !missing(EP43a) // le pourcentage ne peut pas etre supérieure à 100 

//4)

//////////////////EP44. Recevez-vous vos bulletins de paie dans l

//1)



count if missing(EP44) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))))

*exportation

count if missing(EP44) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))))
if r(N)>0 {
    export excel interview__key HH13 EP44 EP3 using "$folderpath/document/EP44.xlsx" if missing(EP44) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))), firstrow(variables) replace
}



//2)



count if !missing(EP44) & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !=""

*exportation

*export excel interview__key HH13 EP44 EP3 using "$folderpath/document/EP44.xlsx" if !missing(EP44) & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !="", firstrow(variables) replace


//3)
//4)

///////////////////////////////EP45.Quelles sont les avantages en nature ou d

//1) 

foreach var of varlist EP45__1 EP45__2 EP45__3 EP45__4 EP45__5 {

count if missing(`var') & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))))

*exportation

count if missing(`var') & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))))
if r(N)>0 {
    export excel interview__key HH13 `var' EP3 using "$folderpath/document/EP44.xlsx" if missing(`var') & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))), firstrow(variables) replace
}


} 


//2) 

foreach var of varlist EP45__1 EP45__2 EP45__3 EP45__4 EP45__5 {

count if !missing(`var') & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !=""

*exportation

*export excel interview__key HH13 `var' EP3 using "$folderpath/document/EP44.xlsx" if !missing(`var') & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !="", firstrow(variables) replace


} 


////////////////////EP45_autre : Autres (à préciser)


//1)

count if missing(EP45_autre) & EP45__5 == 1 // RAS

//2)

count if !missing(EP45_autre) & EP45__5 == 0 // RAS

//3)

//4)déjà checké lors du récodage

///////////////////EP47. êtes-vous sujet à des épisodes de stress mentaux ou de dépression liés à votre emploi p rincipal 

//1)

count if missing(EP47) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) 

count if missing(EP47) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 ))))
if r(N)>0 {
    export excel interview__key HH13 EP47 EP3 using "$folderpath/document/EP44.xlsx" if missing(EP47) & (membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))), firstrow(variables) replace
}



//2)

count if !missing(EP47) & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !=""

*export excel interview__key HH13 EP47 EP3 using "$folderpath/document/EP44.xlsx" if !missing(EP47) & !(membre_id_v1_IND =="##N/A##" & (inlist(EP3,1,8,9) | (inlist(EP3,5,6) & (EP6__1 == 1 | EP6__2 == 1 | EP6__3 == 1 | EP6__5 == 1 | EP6__6 == 1 | EP6__7 == 1 |  EP6__9 == 1 | EP6__11 == 1 | EP6__12 == 1 )))) & membre_id_v1_IND !="", firstrow(variables) replace
 
//3)
//4)


drop M4Confirm SE1 SE2 SE3 SE4 SE5 SE6 SE7 SE8 SE9 annee HH13 V1interviewkey annee_naiss 
order hhavf_EMP, after(membre_id_v1_IND)

save "$standard_individu\INDIV_S3_emploi_principal.dta", replace

