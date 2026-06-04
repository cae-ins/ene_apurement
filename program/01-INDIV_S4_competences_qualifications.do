
* COMPETENCES ET QUALIFICATIONS (CQ)

* RESPONSABLE: RENAUD HIVITES AKATTIA (PECHOUX)
*========================================================
/*
 
use "$datain_brute\membres.dta", clear
cap drop _merge
merge m:1 interview__key using "$brute_menage_work", keepusing(HH2 HH3 HH4 HH12 HH13 HH3 annee)
drop if _merge!=3
cap drop _merge
*/
*******************************************

use "$datain_standard\INDIV_S4_competences_qualifications.dta", clear

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(membre_id_v1_IND EF1 EF2 EF3 EF4 ) 
drop if _merge!=3
cap drop _merge



cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP EP2ka EP2k)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH2 HH3 HH12 HH13 HH4 HH6 HH8B rgmen)
drop if _merge!=3
cap drop _merge


cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EP1b1 EP1a1)
drop if _merge!=3
cap drop _merge


*** On garde uniquement les idividu en 1ere interrogation, car pour la reinterrogation la section n'est pas ouverte.

keep if rgmen==1

* Nous avons fait un merge à la ligne 

gen annee = 2026

*=================================
*CQ1.Selon vous,quel est le niveau d’études nécessaire pour mener à bien vos tâches dans le cadre de votre emploi principal
*=================================
cap drop commentaire_competence
gen commentaire_competence=""


*Problem 1: Ceux qui devaient repondre à la question et n'ont pas repondu
count if missing(CQ1) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
*1 individus sont concernés 

*replace commentaire_competence="Ceux qui devaient repondre à la question CQ1 et n'ont pas repondu" if  missing(CQ1) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)




*Identification des Agents ayant fait des erreurs 
*export excel interview__key membres__id HH12 HH13 CQ1 commentaire_competence using "$folderpath/document/Erreur_CQ1_NA" if missing(CQ1) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm), firstrow(varlabels) replace 

*Etape de correction 1
count if  missing(CQ1) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
/**
ta CQ1 if EP1b1==521103, matrow(unique_value)


ta CQ1 if EP1b1==521103, matrow(unique_value) // Vendeur de fruits

replace CQ1=unique_value[1,1] if EP1b1==521103 & CQ1==.a

ta CQ1 if EP1b1==521103, matrow(unique_value)

*Etape de correction 2
count if  missing(CQ1) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)

ta CQ1 if EP1b1==613001 , matrow(unique_value)


ta CQ1 if EP1b1==613001, matrow(unique_value) // Agriculteur culture vivrière

replace CQ1=unique_value[1,1] if EP1b1==613001 & CQ1==.a

ta CQ1 if EP1b1==613001, matrow(unique_value)
*/


*Problem 2: Ceux qui ont repondu devaient ils repondre 
**# Bookmark #2
count if !missing(CQ1) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1")

*br CQ1 EN_EMP M4Confirm if !missing(CQ1) & EN_EMP==0

*0 individus sont concernés 
*Identification des Agents ayant fait des erreurs 
*export excel interview__key membres__id HH12 HH13 CQ1 commentaire_competence using "$folderpath/document/Erreur_CQ1_NA" if !missing(CQ1) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  ), firstrow(varlabels) replace 

* Proposition de correction RAS
*replace CQ1=. if !missing(CQ1) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1")



*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ1,0,10)& !missing(CQ1)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*========================
*CQ2.Selon vous,quelest le domaine d’études nécessaire pour mener à bien vos tâches dans le cadre de votree mploi principal
*===========================

*Problem 1: CEux qui devaient repondre ont ils repondus 
count if missing(CQ2) & CQ1!=0 & !missing(CQ1)
*RAS
*replace CQ2=2 if EP1b1==541203 & CQ2==.a

* Pour CQ2, il ne devrait y avoir de réponse CQ2 que si CQ1 ≠ 0 et CQ1 n'est pas manquant.
count if !missing(CQ2) & (CQ1==0 | missing(CQ1))

count if !missing(CQ3U) & (CQ3==9998 | missing(CQ3))



*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(CQ2) & CQ1==0 
*RAS

*Problem 3: les valeurs renseignées sont elles permises 
count if !inrange(CQ2,1,13) & !missing(CQ2)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*============================
*CQ2_aut. Autre à préciser
*==========================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(CQ2_aut) & CQ2==13
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(CQ2_aut) & CQ2!=13
*RAS

*Problem 3: les valeurs renseignées sont elles permises 
*RAS

*Problem 4: Vraisemblance des reponses 
*Variables à recoder 

*============================
*CQ3.Selon vous, quelle est la durée minimale d’expérience professionnelle nécessaire pour mener à bien vos tâches dans le cadre de votre emploi principal
*==========================

*Problem 1: ceux qui devaient repondre à la question CQ3 mais n'ont pas repondus 
count if missing(CQ3) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
*1 individus sont concernés 

*replace commentaire_competence="ceux qui devaient repondre à la question CQ3 mais n'ont pas repondus " if missing(CQ3) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)

*Identification des Agents ayant fait des erreurs 
*export excel interview__key HH12 HH13 CQ3 using "$folderpath/document/Erreur_CQ3_NA" if missing(CQ3) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm), firstrow(varlabels) replace 

*Etape de correction

count if missing(CQ3) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)

cap drop var_repl_CQ3_year

bysort EP1b1 : egen var_repl_CQ3_year = mean(CQ3) if CQ3U==3

*proposition de correction 

replace CQ3 = var_repl_CQ3_year if missing(CQ3) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##"  & .>M4Confirm  // 
*cap drop var_repl

*Une valeur extrême CQ3==2009

*replace CQ3U=.a if CQ3==2015
ta CQ3 if EN_EMP==1 & CQ3U==1,m

ta CQ3 if EN_EMP==1 & CQ3U==2,m

ta CQ3 if EN_EMP==1 & CQ3U==3,m


replace CQ3=anne - 1980 if CQ3==1980 
replace CQ3=anne - 2025 if CQ3==2025


*replace CQ3=. if CQ3==320 & CQ3U==3
ed CQ3 CQ3U  EN_EMP CQ1 if  CQ3==9998 & EN_EMP == 1 & M4Confirm >= 15
count if CQ3==9998



summarize CQ3 if EN_EMP ==1 & CQ3U==3, detail

summarize CQ3 if EN_EMP ==1 & CQ3U==2, detail

summarize CQ3 if EN_EMP ==1 & CQ3U==1, detail


**************************************
* Code STATA d'imputation CQ3 et CQ3U valeur manquante
**************************************

* ---------------------------------------------------------
*  1️ Homogénéiser les unités de CQ3 en années
gen CQ3_year = . 
replace CQ3_year = CQ3/365 if CQ3U == 1  & EN_EMP==1 & !inlist(CQ3,9998) // jours → années
replace CQ3_year = CQ3/12 if CQ3U == 2  &  EN_EMP==1 & !inlist(CQ3,9998) // mois → années
replace CQ3_year = CQ3 if CQ3U == 3  & EN_EMP==1 & !inlist(CQ3,9998)   // déjà en années

* ---------------------------------------------------------
* 2️ Calculer moyenne, écart type et médiane par EP1b1 (poste)
bysort HH6 EP1b1 : egen median_CQ3_year = mean(CQ3_year) if   EN_EMP==1 & !inlist(CQ3,9998)

* ---------------------------------------------------------
* 3️ Créer variable d'imputation
gen CQ3_year_impute = .
replace CQ3_year_impute = median_CQ3_year if EN_EMP==1 & !inlist(CQ3,9998)

* ---------------------------------------------------------
* 4️ Imputer CQ3_year si manquant et remplir CQ3
replace CQ3_year = CQ3_year_impute if missing(CQ3_year) & EN_EMP == 1 & M4Confirm >= 15  & !inlist(CQ3,9998)


*********************
* IMPUTATION YEAR	*
*					*
*********************


* Reconvertir en unité initiale (en années si CQ3U==3 ou plus simple: imputer CQ3U manquant en 3 - années)
replace CQ3U = 3 if CQ3==. & EN_EMP==1  & !inlist(CQ3,9998)  // On suppose que l'unité est en années si manquante

replace CQ3 = CQ3_year_impute*365 if CQ3U==1 & EN_EMP==1 & CQ3==. & !inlist(CQ3,9998)
replace CQ3 = CQ3_year_impute*12 if CQ3U==2 & EN_EMP==1 & CQ3==. & !inlist(CQ3,9998)
replace CQ3 = CQ3_year_impute if CQ3U==3 & EN_EMP==1 & CQ3==. & !inlist(CQ3,9998)

*On avait des CQ3_year_impute<1 pour CQ3U==3
replace CQ3 = CQ3_year_impute*12 if CQ3U==3 & EN_EMP==1 & CQ3_year_impute <1  & !inlist(CQ3,9998)

replace CQ3U = 2 if CQ3U==3 & EN_EMP==1 & CQ3_year_impute <1 & !inlist(CQ3,9998)

******  On a une observation qui a CQ3==0 pour CQ3U==3
replace CQ3 = CQ3_year_impute if CQ3==0 & CQ3U==3 & !inlist(CQ3,9998)

ta CQ3 if EN_EMP==1 & CQ3U==1 & !inlist(CQ3,9998),m

ta CQ3 if EN_EMP==1 & CQ3U==2 & !inlist(CQ3,9998),m

ta CQ3 if EN_EMP==1 & CQ3U==3 & !inlist(CQ3,9998),m

******** La avleur du 99ieme percentile est CQ3==12 pour CQ3U==3

replace CQ3=12  if EN_EMP ==1 & CQ3U==3 & CQ3 >= 12

*********************
* IMPUTATION MOIS	*
*					*
*********************


*On avait des CQ3=0 pour CQ3U==2

replace CQ3 = CQ3_year_impute*12 if  CQ3U==2 & EN_EMP==1 & CQ3==0 & !inlist(CQ3,9998)


replace CQ3 = CQ3_year_impute*365 if CQ3U==2 & EN_EMP==1 & CQ3_year_impute <1 & !inlist(CQ3,9998)

replace CQ3U = 1 if CQ3U==2 & EN_EMP==1 & CQ3_year_impute <1 & !inlist(CQ3,9998)

gen z =1 if 12<=CQ3 & CQ3<. & EN_EMP ==1 & CQ3U==2 & !inlist(CQ3,9998)

replace CQ3=CQ3/12 if z==1 & !inlist(CQ3,9998)

replace CQ3U=3 if z==1 & !inlist(CQ3,9998)

cap drop z  


*********************
* IMPUTATION JOUR	*
*					*
*********************


*Pour CQ3=0 et CQ3U=1 on impute par CQ3=1

replace CQ3 = CQ3_year_impute*365 if CQ3U==1 & CQ3==0 & EN_EMP==1 & !inlist(CQ3,9998)


*On a des CQ3 superieur a 31 avec CQ3U=1
g z = 1 if CQ3U==1 & EN_EMP==1 &  31 < CQ3 & CQ3<. & !inlist(CQ3,9998)

replace CQ3=CQ3/31 if CQ3U==1 & EN_EMP==1 &  31 < CQ3 & CQ3 & !inlist(CQ3,9998)

replace CQ3U=2 if z==1 & !inlist(CQ3,9998)

cap drop z

*Pour CQ3=0 et CQ3U=1 on impute par CQ3=1

replace CQ3 = 1 if CQ3U==1 & CQ3==0 & EN_EMP==1 & !inlist(CQ3,9998)


****************************************
*			Appurement pour CQ3==9998
*										
****************************************


count if CQ3==9998 & EN_EMP==1

* CQ3a = Moins de 1 mois
replace CQ3U =1 if CQ3==9998 & CQ3a == 1 & EN_EMP==1
replace CQ3 = 14 if CQ3==9998 & CQ3a == 1 & EN_EMP==1

* CQ3a = 1 à 3 mois
replace CQ3U =2 if CQ3==9998 & CQ3a == 2 & EN_EMP==1
replace CQ3 = 2 if CQ3==9998 & CQ3a == 2 & EN_EMP==1

* CQ3a = 3 à 12 mois
replace CQ3U =2 if CQ3==9998 & CQ3a == 3 & EN_EMP==1
replace CQ3 = 8 if CQ3==9998 & CQ3a == 3 & EN_EMP==1


* CQ3a = 1 à 3 ans
replace CQ3U =3 if CQ3==9998 & CQ3a == 4 & EN_EMP==1
replace CQ3 = 2 if CQ3==9998 & CQ3a == 4 & EN_EMP==1

* CQ3a = 3 à 6 ans
replace CQ3U =3 if CQ3==9998 & CQ3a == 5 & EN_EMP==1
replace CQ3 = 5 if CQ3==9998 & CQ3a == 5 & EN_EMP==1

* CQ3a = 6 ans et plus
replace CQ3U =3 if CQ3==9998 & CQ3a == 6 & EN_EMP==1
replace CQ3 = 8 if CQ3==9998 & CQ3a == 6 & EN_EMP==1



*count if missing(CQ4) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)

*cap drop var_repl_CQ4_year

*bysort EP1b1 : egen var_repl_CQ4_year = mean(CQ4) if CQ4U==3

*proposition de correction 

*replace CQ4 = var_repl_CQ4_year if missing(CQ4) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##"  & .>M4Confirm  // 
*cap drop var_repl

ta CQ4 if EN_EMP ==1 & CQ4U==1,m

ta CQ4 if EN_EMP ==1 & CQ4U==2,m


ta CQ4 if EN_EMP ==1 & CQ4U==3,m


count if CQ4==9998 & EN_EMP==1

summarize CQ4 if EN_EMP ==1 & CQ4U==3, detail

summarize CQ4 if EN_EMP ==1 & CQ4U==2, detail

summarize CQ4 if EN_EMP ==1 & CQ4U==1, detail



****************************************
*			Appurement pour CQ4==9998
*										
****************************************


count if CQ4==9998 & EN_EMP==1

* CQ4a = Moins de 1 mois
replace CQ4U =1 if CQ4==9998 & CQ4a == 1 & EN_EMP==1
replace CQ4 = 14 if CQ4==9998 & CQ4a == 1 & EN_EMP==1

* CQ4a = 1 à 3 mois
replace CQ4U =2 if CQ4==9998 & CQ4a == 2 & EN_EMP==1
replace CQ4 = 2 if CQ4==9998 & CQ4a == 2 & EN_EMP==1

* CQ4a = 3 à 12 mois
replace CQ4U =2 if CQ4==9998 & CQ4a == 3 & EN_EMP==1
replace CQ4 = 8 if CQ4==9998 & CQ4a == 3 & EN_EMP==1


* CQ4a = 1 à 3 ans
replace CQ4U =3 if CQ4==9998 & CQ4a == 4 & EN_EMP==1
replace CQ4 = 2 if CQ4==9998 & CQ4a == 4 & EN_EMP==1

* CQ4a = 3 à 6 ans
replace CQ4U =3 if CQ4==9998 & CQ4a == 5 & EN_EMP==1
replace CQ4 = 5 if CQ4==9998 & CQ4a == 5 & EN_EMP==1

* CQ4a = 6 ans et plus
replace CQ4U =3 if CQ4==9998 & CQ4a == 6 & EN_EMP==1
replace CQ4 = 8 if CQ4==9998 & CQ4a == 6 & EN_EMP==1



*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(CQ3) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  )
*0 individus concernés 

*Identification des Agents ayant fait des erreurs 
*export excel interview__key HH12 HH13 CQ3 using "$folderpath/document/Erreur_CQ3_NA" if !missing(CQ3) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  ), firstrow(varlabels) replace 



*Problem 3: les valeurs renseignées sont elles permises 
*Les valeurs ne doivent pas etre negatives 
count if CQ3<0
*RAS 

*Problem 4: Vraisemblace des reponses 
*RAS

*========================
*CQ3U.Préciser l’Unité detemps de la durée de l’expérience professionnelle
*=====================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(CQ3U) & CQ3!=9998 & !missing(CQ3)
*4 individus sont concernés 

*Identification des Agents ayant fait des erreurs 
*export excel interview__key HH12 HH13 CQ3U using "$folderpath/document/Erreur_CQ3_NA" if  missing(CQ3U) & CQ3!=9998 & !missing(CQ3), firstrow(varlabels) replace 

*Problem 2: ceux qui ont repondus devaient ils repondre 
count if !missing(CQ3U) & CQ3==9998
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ3U,1,3) & !missing(CQ3U)
*RAS

*Problem 4: Vraisemblance des reponses 
*La durée minimale pour bien exerer son travail ne peut exceder 10ans. Ce n'est pas tres raisonnable

count if CQ3U==3 & CQ3>5
*96 individus sont concernés. Nous pensons que la valeur entrée correspond à leur experience plutot 
* 

* br CQ1 CQ2 CQ3 CQ3U EP1b1 if CQ3U==3 & CQ3>5
ta CQ3 CQ3U
replace commentaire_competence="La durée minimale pour bien exerer son travail ne peut exceder 10ans. Ce n'est pas tres raisonnable" if CQ3U==3 & CQ3>10  

*Identification des agents ayant fait des erreurs 
count if CQ3U==3 & CQ3>10 
if r(N)>0 {
    export excel interview__key HH12 HH13 CQ3U  commentaire_competence using "$folderpath/document/Erreur_CQ3_coh" if CQ3U==3 & CQ3>10 , firstrow(varlabels) replace
}



 

*========================
*CQ3a.Selon vous, quelle est la durée minimale d’expérience professionnelle nécessaire pour mener à bien vos tâches dans le cadre de votre emploi principal 
*==========================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(CQ3a) & CQ3==9998 
*RAS

*Problem 2: Ceux qui ont repondus dvaient ils repondre 
count if !missing(CQ3a) & CQ3!=9998 
replace CQ3a=. if !missing(CQ3a) & CQ3!=9998 
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ3a,1,6) & !missing(CQ3a)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*================================
*CQ4. Au total, quelle est la durée d’expérience professionnelle que vous avez ?
*==============================

*Problem 1: ceux qui devaient repondre  à la question CQ4 et n'ont pas repondus 
count if missing(CQ4) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
*4 individus sont concernés 

replace commentaire_competence="ceux qui devaient repondre  à la question CQ4 et n'ont pas repondus " if missing(CQ4) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)

*Identification des Agents ayant fait des erreurs 
*export excel interview__key HH12 HH13 CQ4 commentaire_competence using "$folderpath/document/Erreur_CQ4_NA" if missing(CQ4) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm), firstrow(varlabels) replace 

*Etape de correction

count if missing(CQ4) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm) 

cap drop var_repl

bysort HH6 EP1b1 : egen var_repl = mean(CQ4)


replace CQ4 = var_repl if missing(CQ4) & EN_EMP==1 & M4Confirm>=15 & .>M4Confirm & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)   // Seulement 2 ont pu être imputés
cap drop var_repl

/*replace CQ4U=3 if (interview__key=="13-46-62-28" & membres__id==2) | (interview__key=="77-67-64-29" & membres__id==11) // rien*/

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(CQ4) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  )
*8 indidvidus sont concernés

*Identification des Agents ayant fait des erreurs 
*export excel interview__key HH12 HH13 CQ4 commentaire_competence using "$folderpath/document/Erreur_CQ4_NA" if!missing(CQ4) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  ), firstrow(varlabels) replace 

*Problem 3: les valeurs renseignées sont elles permises 
*Les valeurs ne doivent pas etre negatives 
count if CQ4<0
*RAS 

*Problem 4: Vraisemblace des reponses 
*RAS

*les valeurs ne doivent pas etre trop grande. (depasser 100)

count if CQ4 >= 80 &  .> CQ4 & !missing(CQ4) & CQ4 != 9998 & CQ4U==3 // 4 individus sont concernés. Il s'agit très potentiellement des individus pour qui il y a eu une confusion avec l'année

replace CQ4 = annee -  EP2ka if CQ4 > 100 & !missing(CQ4) & CQ4 != 9998


*===========================
*CQ4U. Précisez l’unité de la durée d’expérience professionnelle que vous avez ?
*=======================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(CQ4U) & !inlist(CQ4,9998,.,.a)
*4 individus sont concernés

*Identification des Agents ayant fait des erreurs  
*export excel interview__key HH12 HH13 CQ4 commentaire_competence using "$folderpath/document/Erreur_CQ4_NA" if missing(CQ4U) & !inlist(CQ4,9998,.,.a), firstrow(varlabels) replace 



*Problem 2: ceux qui ont repondus devaient ils repondre 
count if !missing(CQ4U) & inlist(CQ4,9998,.,.a)
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ4U,1,3) & !missing(CQ4U)
*RAS

*Problem 4: Vraisemblance des reponses 
*Les valeurs entrées en années doivent etre superieur ou egale à EP2k sinon "Incoherence"
*count if CQ4U==3 & !inlist(CQ4,9998) & CQ4 < EP2k & !missing(EP2k) & !missing(CQ4) & !inlist(EP2k,.,.a,9998)

*replace commentaire_competence="Les valeurs entrées en années doivent etre superieur ou egale à EP2k sinon "Incoherence"" if CQ4U==3 &!inlist(CQ4,9998) & CQ4 < EP2k & !missing(EP2k) & !missing(CQ4) & !inlist(EP2k,.,.a,9998)

*Identification des agents ayant fit des erreurs 
*export excel interview__key HH12 HH13 CQ4 CQ4U EP2k commentaire_competence using "$folderpath/document/Erreur_CQ4U_coh" if CQ4U==3 &!inlist(CQ4,9998) & CQ4 < EP2k & !missing(EP2k) & !missing(CQ4) & !inlist(EP2k,.,.a,9998), firstrow(varlabels) replace 

**# Bookmark #3
*Etape correction

replace CQ4 = EP2k if CQ4U==3 &!inlist(CQ4,9998) & CQ4 < EP2k & !missing(EP2k) & !missing(CQ4) & !inlist(EP2k,.,.a,9998) // on remplace CQ4 par EP2K


*on verifie que CQ4 est bien coherent avec l'age

count if CQ4 > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(CQ4,.,.a,9998) // 4 individu concernés

replace commentaire_competence="Le nombre d'année d'expérience est supérieur a son âge" if CQ4 > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(CQ4,.,.a,9998)

count if CQ4 > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(CQ4,.,.a,9998)
if r(N)>0 {
    export excel interview__key HH12 HH13 CQ4 CQ4U M4Confirm commentaire_competence using "$folderpath/document/Erreur_CQ4U_coh_2" if CQ4 > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(CQ4,.,.a,9998), firstrow(varlabels) replace 
}

*correction 

replace CQ4 = M4Confirm - 11  if CQ4 > M4Confirm & !inlist(M4Confirm,.,.a,9998) & !inlist(CQ4,.,.a,9998) // on remplace CQ4 par l'age moins 11 ans ( age considéré dans le HFCQ)


*=======================
*CQ4a. Au total, quelle est la durée d’expérience professionnelle que vous avez
*=======================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(CQ4a) & CQ4==9998
*RAS

*Problem 2:ceux qui ont repondu devaient ils repondre 
count if !missing(CQ4a) & CQ4!=9998
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ4a,1,6) & !missing(CQ4a)
*RAS

*Problem 4: Vraiseblance des reponses 
*RAS

*=======================
*CQ5. Lequel des énoncés suivants décrit le mieux vos compétences par rapport à ce qui est nécessaire pour votre emploi / entreprise
*=======================

**Problem 1: ceux qui devaient repondre à la question et n'ont pas repondus 
count if missing(CQ5) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
*1 individus sont concernés 

**# Bookmark #4
**# Bookmark #5
replace commentaire_competence="ceux qui devaient repondre à la question et n'ont pas repondus " if missing(CQ5) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)

*Identification des Agents ayant fait des erreurs 
*export excel interview__key HH12  HH13 CQ5 commentaire_competence using "$folderpath/document/Erreur_CQ5_NA" if missing(CQ5) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm), firstrow(varlabels) replace 


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(CQ5) & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  )
*0 individu sont concernés 

*Identification des Agents ayant fait des erreurs 
*export excel interview__key HH12  HH13 CQ5 commentaire_competence using "$folderpath/document/Erreur_CQ5_NA" if missing(CQ5) & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm), firstrow(varlabels) replace 


*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ5,1,4) & !missing(CQ5)
*RAS

*Problem 4: Vraiseblance des reponses 
*RAS

*=======================
*CQ6. Est-ce que les compétences suivantes sont importance pour ce emploi
*=======================

**Problem 1: ceux qui devaient repondre ont ils repondus 
foreach var of varlist CQ6__1-CQ6__12{
	count if missing(`var') & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
}



*Identification des Agents ayant fait des erreurs 
foreach var of varlist CQ6__1-CQ6__12{ 
	count if missing(`var') & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
	if r(N)>0 {
	    export excel interview__key HH12 HH13 `var' using "$folderpath/document/Erreur_CQ6_NA" if missing(`var') & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm), firstrow(varlabels) replace 
	}
}

*proposition de correction 

foreach var of varlist CQ6__1-CQ6__12{
	replace `var'= 0 if missing(`var') & EN_EMP==1 & M4Confirm>=15 & membre_id_v1_IND=="##N/A##" & !missing(M4Confirm)
}

*Problem 2: Ceux qui ont repondu devaient ils repondre 
foreach var of varlist CQ6__1-CQ6__12{
	count if !missing(`var') & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  )
}
*plusieurs individus sont concernés 

*Identification des Agents ayant fait des erreurs 
/*
foreach var of varlist CQ6__1-CQ6__12{ 
	export excel interview__key HH12 HH13 `var' using "$folderpath/document/Erreur_CQ6_NA" if !missing(`var') & (EN_EMP==0 | M4Confirm<15 |membre_id_v1_IND=="1"  ), firstrow(varlabels) replace 
}
*/


*Problem 3: Les valeurs renseignées sont elles permises 
foreach var of varlist CQ6__1-CQ6__12{
	count if !inrange(`var',0,1) & !missing(`var')
}
*RAS

*Problem 4: Vraiseblance des reponses 
*RAS

*=======================
*CQ6_Autre. Autre à préciser
*=======================

**Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(CQ6_Autre) & CQ6__12==1
*RAS


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(CQ6_Autre) & CQ6__12==0
*RAS


*drop HH2 HH3 HH4 HH12 HH12 HH13 HH3
*save "$datain_brute\membres.dta", replace

/*
use "$datain_brute\r_competence_quali.dta", clear
cap drop _merge
merge m:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(CQ6__1 CQ6__2 CQ6__3 CQ6__4 CQ6__5 CQ6__6 CQ6__7 CQ6__8 CQ6__9 CQ6__10 CQ6__11 CQ6__12)

keep if _merge == 3

cap drop _merge

merge m:1 interview__key using "$brute_menage_work" , keepus(MODINTR HH13)

keep if _merge == 3

cap drop _merge


*/

drop M4Confirm membre_id_v1_IND EN_EMP EP2ka EP2k HH2 HH3 HH4 HH6 HH8B HH12 HH13 EP1b1 EP1a1 rgmen annee commentaire_competence 

save "$standard_individu\INDIV_S4_competences_qualifications.dta", replace 

use "$datain_brute\r_competence_quali.dta", clear
cap drop _merge
merge m:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(CQ6__1 CQ6__2 CQ6__3 CQ6__4 CQ6__5 CQ6__6 CQ6__7 CQ6__8 CQ6__9 CQ6__10 CQ6__11 CQ6__12 EN_EMP)

keep if _merge == 3

cap drop _merge

merge m:1 interview__key using "$brute_menage_work" , keepus(MODINTR HH13)

keep if _merge == 3

cap drop _merge


*=======================
*CQ7. Si oui, pensez-vous que son importance pour l’emploi est peu important ou important ou essentiel ?
*=======================

*Problem 1: ceux qui devaient repondre ont ils repondus 
foreach var of varlist CQ6__1-CQ6__12{
	count if `var'==1 & missing(CQ7)

}
*RAS



*Problem 2: Ceux qui ont repondu devaient ils repondre : Cette synthase est mal formulé
*count if CQ6__1 ==0 & !missing(CQ7) & EN_EMP==1 & r_competence_quali__id==1
foreach var of varlist CQ6__1-CQ6__12{
	count if `var'==0 & !missing(CQ7) & EN_EMP==1
}

*Des individus ont été identifiés 

*Identification des agents ayant fait des erreurs : Cette synthase est mal formulé
foreach var of varlist CQ6__1-CQ6__12{ 
	count if `var'==0 & !missing(CQ7)
	if r(N)>0 {
	    export excel interview__key HH13 `var' CQ7 using "$folderpath/document/Erreur_CQ7_coh" if `var'==0 & !missing(CQ7), firstrow(varlabels) replace 
	}
}

*Correction
/*
foreach var of varlist CQ6__1-CQ6__12{ 
	replace CQ7=. if `var'==0 & !missing(CQ7)
}
*/

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ7,1,3) & !missing(CQ7)
*RAS

*Problem 4: Vraiseblance des reponses 
*RAS

*=======================
*CQ8.Pensez-vous que le niveau de compétences qu’il faut avoir pour cet emploi doit-être basique ou intermédiaire ou avancé ?
*=======================

*Problem 1: ceux qui devaient repondre ont ils repondus 
foreach var of varlist CQ6__1-CQ6__12{
	count if `var'==1 & missing(CQ8)

}
*RAS


*Problem 2: Ceux qui ont repondu devaient ils repondre 
foreach var of varlist CQ6__1-CQ6__12{
	count if `var'==0 & !missing(CQ8)
}
*Des individus ont été identifiés 

*Identification des agents ayant fait des erreurs 
foreach var of varlist CQ6__1-CQ6__12{ 
	count if `var'==0 & !missing(CQ8)
	if r(N)>0 {
	    export excel interview__key HH13 `var' CQ8 using "$folderpath/document/Erreur_CQ7_coh" if `var'==0 & !missing(CQ8), firstrow(varlabels) replace 
	}
}

/*
*Correction
foreach var of varlist CQ6__1-CQ6__12{ 
	replace CQ8=. if `var'==0 & !missing(CQ8)
}
*/

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ8,1,3) & !missing(CQ8)
*RAS

*Problem 4: Vraiseblance des reponses 
*RAS

*=======================
*CQ9a.Pour cet emploi, le niveau de compétence que vous-avez est-il basique ou intermédiaire ou avancé ou bien vous n’avez pas ces compétences 
*=======================

**Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(CQ9a) & r_cq_index < 6
*RAS


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(CQ9a) & r_cq_index >= 6
*RAS


*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ9a,1,4) & !missing(CQ9a)
*RAS

*Problem 4: Vraiseblance des reponses 
*RAS

*===========================
*CQ9b.Pour cet emploi pensez-vous que vos compétences sont adéquates ou plus élevées ou doivent être développées ?
*=======================

**Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(CQ9b) & r_cq_index >= 6
*RAS


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(CQ9b) & r_cq_index < 6 
*RAS


*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(CQ9b,1,3) & !missing(CQ9b)
*RAS

*Problem 4: Vraiseblance des reponses 
*RAS



drop CQ6__1 CQ6__2 CQ6__3 CQ6__4 CQ6__5 CQ6__6 CQ6__7 CQ6__8 CQ6__9 CQ6__10 CQ6__11 CQ6__12 MODINTR HH13 EN_EMP

save "$dataout\r_competence_quali.dta", replace









 



