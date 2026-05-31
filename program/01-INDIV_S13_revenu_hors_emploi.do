*+==============================================================
*					SECTION REVENU HORS EMPLOI (RHE)
*+==============================================================
** BROU
*--------------------------------------------------------
* Condition d'entrer dans la section emploi antérieur
* membre_id_v1_IND == null && M4Confirm>=15 && C2 !=2
*------------------------------------------------------

clear

*use "$datain_brute\membres.dta", clear

*global datain_brute "E:\apurement ENE\bases" // (après vos tests, mettre cette ligne en texte ou supprimer)

*global dataout "E:\apurement ENE\erreur" // (après vos tests, mettre cette ligne en texte ou supprimer)


use "$datain_standard\INDIV_S13_revenu_hors_emploi.dta", clear


* Recherche des variables utiles pour la section revenu hors emploi et fusion
*---------------------------------------------------------------
**-----------

// EN_EMP (section emploi), M4Confirm (section aft), HH13 (identification), EP1a (section emploi), C2 (chomage)

cap drop _merge 
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP EP1a) 

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S11_chomage.dta", keepus(C2) 

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepusing(membre_id_v1_IND)
//CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire Utilisation de la base membres parce que la variable membre_id_v1_IND n'existe pas dans les bases standardiser

drop if _merge!=3
cap drop _merge

merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH13) 

drop if _merge!=3
cap drop _merge


cap drop _merge
merge m:1 interview__key using "$brute_menage_work", keepusing(HH2 HH3 HH4 HH12 HH13 HH3)
drop if _merge!=3
cap drop _merge



**--------------------------------------------------
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

*---------------------------------------------------

*merge 1:m interview__key membres__id using "$datain_brute\r_revenu_h_emp.dta", keepus(r_revenu_h_emp__id RHE1_2 label_RHE1_2 RHE1_3 RHE1_4 RHE1_5 RHE1_6)

*drop if _merge!=3
*cap drop _merge


* Initialisation fichier de sortie SECTION EMPLOI ANTERIEUR
*-------------------------------------------------------------------------

/*preserve
keep if _n == 1
drop _all
	save "$dataout\Erreur_a_corriger_rhe", replace emptyok
restore*/


* La condition d'entrée dans la section emploi antérieur dans une variables global nommé 'cond_entre_section_ea' 
*-------------------------------------------------------------------------

*Probleme 1: Ceux qui devaient repondre ont ils repondu 
foreach var of varlist  RHE__1-RHE__10   {
    count if missing(`var') & (membre_id_v1_IND == "" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)))
	
	br if missing(`var') & (membre_id_v1_IND == "" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a)))
	
}

*****La correction des valeurs manquantes necessite de revenir aux agents

forvalues i = 1/10 {
    * Remplace les valeurs manquantes .a par 0 dans chaque variable RHE__`i'
    replace RHE__`i' = 0 if RHE__`i' == .a
}

	

* Problème2: Ceux qui ont repondu devaient ils repondre 
foreach var of varlist RHE__1-RHE__10{
    count if !missing(`var') & !(membre_id_v1_IND == "" & (M4Confirm>=15 & !inlist(M4Confirm,.,.a))) & membre_id_v1_IND != ""
}

foreach var of varlist RHE__1-RHE__10{
    count if !missing(`var') & (membre_id_v1_IND == "" & (M4Confirm<15 & !inlist(M4Confirm,.,.a)))
}


* Problème3: Les modalités sont elles permises 
foreach var of varlist RHE__1-RHE__10{
    count if !inrange(`var', 0, 1) & !missing(`var')
}

*RAS


*drop EN_EMP EP1a M4Confirm C2 membre_id_v1_IND HH13

save "$standard_individu\INDIV_S13_revenu_hors_emploi.dta",replace 


**================================================== Fusion avec la base rooster du revenu hors emplois=============

*use "$datain_brute/r_revenu_h_emp.dta", clear


cap drop _merge 
merge 1:m interview__key membres__id using "$datain_brute/r_revenu_h_emp.dta"
drop if _merge!=3
cap drop _merge


*========================
*RHE1_2. A quelle fréquence percevez-vous ce revenu ?
*===========================

*Problem 1: Ceux qui devaient repondre ont ils repondu 
count if missing(RHE1_2) & (membre_id_v1_IND == "" & (M4Confirm >= 15 & !inlist(M4Confirm,.,.a)))

/*
*Idebtification des agents ayant fait des erreurs 
if r(N) > 0 {
export excel interview__key HH13 RHE1_2 using "$folderpath/document/Erreur_RHE1_2_NA" if missing(RHE1_2), firstrow(varlabels) replace 
}
*/

* Problème2: Ceux qui ont repondu devaient ils repondre 
count if !missing(RHE1_2) & !(membre_id_v1_IND == "" | (M4Confirm >= 15 | !inlist(M4Confirm,.,.a)))

*Problem 3: les valeurs renseignées sont elles permises 
count if !inrange(RHE1_2,1,10) & !missing(RHE1_2)


*========================
*RHE1_3. combien de fois percevez-vous ce revenu
*=======================

*Problem 1: Ceux qui ont repondu devaient ils repondre 
count if missing(RHE1_3)& RHE1_2 < 8
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(RHE1_3)& RHE1_2>=8
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 

count if RHE1_2==1 & RHE1_3>7 & !missing(RHE1_3) // Sachant que le revenu est journalier, il ne peut exceder 7 sur une semaine 

count if RHE1_2==2 & RHE1_3>4 & !missing(RHE1_3) // Sachant que le revenu est hebdomadaire, il ne peut exceder 4 sur un mois 

count if RHE1_2==3 & RHE1_3>2 & !missing(RHE1_3) // Sachant que le revenu est percu par quinzaine, il ne peut exceder 2 sur un mois 

count if RHE1_2==4 & RHE1_3>12 & !missing(RHE1_3) // Sachant que le revenu est mensuel, il ne peut exceder 12 sur une année

count if RHE1_2==5 & RHE1_3>7 & !missing(RHE1_3) // Sachant que le revenu est BIMENSUEL, il ne peut exceder 6 sur une année 

count if RHE1_2==6 & RHE1_3>4 & !missing(RHE1_3) // Sachant que le revenu est trimestriel, il ne peut exceder 4 sur une année

count if RHE1_2==7 & RHE1_3>2 & !missing(RHE1_3) // Sachant que le revenu est semestriel, il ne peut exceder 2 sur une année

count if RHE1_2==8 & RHE1_3>1 & !missing(RHE1_3) // Sachant que le revenu est annuel, il ne peut exceder 1 sur une année

*Problem 4: Vraisemblance des reponses 
*RAS

*============================
*RHE1_4. quel est le montant (FCFA) de votre revenu ?
*============================
*Problem 1: ceux qui ont repondu devaient ils repondre 
count if missing(RHE1_4) & inlist(RHE1_2,1,2,3,4,5,6,7,8,9)
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(RHE1_4) & !inlist(RHE1_2,1,2,3,4,5,6,7,8,9)

*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*Les valeurs renseignées ne peuvent etre nulles ou negatives 
count if RHE1_4<=0  & inlist(RHE1_2,1,2,3,4,5,6,7,8,9)

/*
cap drop med_RHE1_4
egen med_RHE1_4 = median(RHE1_4), by(EP3 EP11)
replace RHE1_4 = med_RHE1_4 if missing(RHE1_4)
cap drop med_RHE1_4
*/

*RAS
*Les valeurs renseignées doivent depasser 100
count if RHE1_4<100  & inlist(RHE1_2,1,2,3,4,5,6,7,8,9)
*

br if RHE1_4<100  & inlist(RHE1_2,1,2,3,4,5,6,7,8,9)

***Correction des revenus déclarés en chiffre par rapport à ceux declarés en lettre

replace RHE1_4 = 50000 if RHE1_4<100  & inlist(RHE1_2,1,2,3,4,5,6,7,8,9) & RHE1_5 == "CINQUANTE MILLE FRANCS CFA"

replace RHE1_4 = 25000 if RHE1_4<100  & inlist(RHE1_2,1,2,3,4,5,6,7,8,9) & RHE1_5 == "VINGT CINQ MILLES"


*Probem 4: Vraisemblance des reponses
violin RHE1_4
graph box RHE1_4 
*RAS 

*============================
*RHE1_5. Ecrire le montant en toute lettre (FCFA)
*========================

*Problem 1 : Ceux qui devaient repondre ont ils repondu 
count if !missing(RHE1_4)& !inlist(RHE1_4,99999999,99999998) & missing(RHE1_5)
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if (missing(RHE1_4)| inlist(RHE1_4,99999999,99999998)) & !missing(RHE1_5)
*RAS

*br RHE1_4 RHE1_5 if !missing(RHE1_4) & !missing(RHE1_5)

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Problem 4: Vraisembalnce des reponses 
*RAS 

*==========================
*RHE1_6. Pouvez-vous tout de même nous indiquer dans quelle tranche de remunération vous vous situez
*===================================
*Problem 1:Ceux qui devaient repondre ont ils repondus 
count if (RHE1_4==99999998 |RHE1_4==99999999 |RHE1_2==10) & missing(RHE1_6)
*RAS


*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if (RHE1_4!=99999998 & RHE1_4!=99999999 & RHE1_2!=10) & !missing(RHE1_6)
*RAS

*Problem 3 : Les valeurs renseignées sont elles permises 
*RAS

*Problem 4 : Vraisemblance des reponses  
*RAS


drop HH2 HH3 HH4 HH12 HH13  label_RH1 RHE__1 RHE__2 RHE__3 RHE__4 RHE__5 RHE__6 RHE__7 RHE__8 RHE__9 RHE__10 EN_EMP EP1a M4Confirm C2 membre_id_v1_IND

save "$dataout\r_revenu_h_emp.dta" , replace

