*=========================================================
* LOGEMENT (L)

* RESPONSABLE: KOUADIO BROU YVES-BEVERLIN
*========================================================


*use "$datain_brute\QX_EEC_VF.dta", clear

use "$datain_standard\QM_S7_logement.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH12 HH13 HH3 hha rgmen rghab)
drop if _merge!=3
cap drop _merge

gen commentaire =""
*=================================
*L1.Typedeconstruction
*=================================

*Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
//1373 individus ont été identifiés 

replace commentaire="Il y a 1373 individus qui n'ont pas repondus à la question L1" if missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH2 HH12 HH13 L1 using "$folderpath/document/Erreur_L1_NA" if missing(L1) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L1) & (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L1,1,8) & !missing(L1)
//RAS

*=================================
*L1.Autre type de logement 
*=================================
*Problem 1: Ceux qui devaient repondre ont ils repondu 
count if missing(L1_Aut) & L1==8
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L1) & !missing(L2A) & (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*===================================================
*L2A. Nombre total de pièces dans le logement
*===================================================
*Problem 1: Ceux qui devaient repondre ont ils repondu 
count if missing(L2A) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L2A) & (missing(L1) | hha == "" | (rgmen != 1 & rghab != 4))


*Problem 3: Les valeurs renseignées sont elles permises 
//Il est peu probable que le nombre de pièces depasse 50 .Par ailleurs la valeur renseignée ne doit pas etre négative
count if (L2A>50 | L2A<0)  & !inlist(L2A,.,.a,98)


*Problem 4: Vraisemblance des reponses
 
//Une villa doit faire au moins 3 pièces. C'est peu probable qu'une villa ait 2 pièces uniquement.
count if L1==1 & L2A<3 & !missing(L2A)
br if L1==1 & L2A<3 & !missing(L2A)

//6 observations
*correction
replace L1 = 5 if L2A <3 & L1==1

//Un appartement dans un immeuble est en general une location, c'est peu probable que l'on ait dans ses cas plus de 5 pièces 
count if L2A>5 & L1==2 // RAS


//Cherchons s'il y a des logements avec 0 pièces
count if L2A==0 & !missing(L1)
//RAS

//Dans une case, on ne peut avoir plus de 3 pièces, cependant il peut d'une concession dans laquelle plusieurs cases sont occupées par le ménage 
count if L2A>3 & L1==6 & !missing(L2A)
br if L2A>3 & L1==6 & !missing(L2A)

//5 individus sont concernés
replace L2A = 3 if L2A>3 & L1==6 & !missing(L2A)


//Dans une baraque c'est peu probable d'avoir plus de 3 pièces 
count if L2A>3 & L1==7 & !missing(L2A) //RAS



*====================================================================
*L1_Aut: AUtres à peciser 
*===================================================================

*Problem1: Ceux qui devaient repondre ont ils repondu 
count if L1==8 & L1_Aut==""
//RAS


*Problem2: Ceux qui ont repondu devaient ils repondre 
count if L1_Aut!="" & L1 !=8
//RAS

*====================================================================
*L2.B Nombre de pièce utilisé pour dormir dans le logement
*===================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondu 
count if missing(L2B) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*br L1 L2A if missing(L2B) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L2B) & (missing(L1) | hha == "" | (rgmen != 1 & rghab != 4))
// RAS

*Problem 3: Les valeurs renseignées sont elles permises 
//Il est peu probable que le nombre de pièces depasse 50 .Par ailleurs la valeur renseignée ne doit pas etre négative
count if (L2B>50 | L2B<0)  & !inlist(L2B,.,.a,98)
// RAS

*Problem 4: Vraisemblance des reponses
 
//Nombre de pièce utilisé pour dormir dans le logement ne peut pas être supérieur au nombre de pièces (L2A)
count if L2B>L2A & !missing(L2A,L2B)
br if L2B>L2A & !missing(L2A,L2B)
//2 cas identifiés

*Correction
* Ramenons le nombre de pièces utilisé pour dormir au nombre de pièces total dans la maison.

replace L2B = L2A if  L2B>L2A & !missing(L2A,L2B)

*===================================================================
*L3. Principal matériau de construction des murs extérieurs
*===================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L3) & hha != "" & (rgmen == 1 | rghab == 4)

replace commentaire="Il y a 1373 individus qui n'ont pas repondus à la question L3" if missing(L3) & hha != "" & (rgmen == 1 | rghab == 4)

*Exportation des observations pour lesquelles la variable L3 n'a pas été renseignée 
export excel interview__key HH2 HH12 HH13 L1 using "$folderpath/document/Erreur_L3_NA"  if missing(L3) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

	
*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L3) &  (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L3,1,7) & !missing(L3)
//RAS

*Problem 4: Vraisemblance des reponses 

//Il est peu probable qu'une villa soit construite en pierres simples,paille,planche
count if inlist(L3,4,5,6) & L1==1
//RAS

//Il est peu probable qu'une baraque ou une case soit construite en ciment,brique,geo-béton
count if inlist(L3,1,2) & inlist(L1,6,7)
//2 logements sont concernés
 
* Correction
replace L3 = 6 if inlist(L3,1,2) & inlist(L1,6,7)

*================================================================
*L3_Aut: Autres à preciser
*================================================================

* Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L3_Aut) & L3==7
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L3_Aut) & L3!=7
//RAS

*================================================================
*L4. Principale source d'éclairage
*================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L4) & hha != "" & (rgmen == 1 | rghab == 4)

replace commentaire="Il y a 1373 individus qui n'ont pas repondus à la question L4" if missing(L4) & hha != "" & (rgmen == 1 | rghab == 4)

*Exportation des observations pour lesquelles la variable L4 n'a pas été renseignée 
export excel interview__key HH2 HH12 HH13 L4 using "$folderpath/document/Erreur_L4_NA" if missing(L4) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L4) & (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L4,1,7) & !missing(L4)
//RAS

*Problem 4: Vraisemblance des reponses 

//Il est peu probable qu'une villa soit éclairée par une lampa à pétrole,lampe à pile, parafine
count if inlist(L4,3,4,5) & L1==1
//RAS

*==================================================
*L4_Aut. Préciser l'autre Mode d'éclairage
*==================================================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L4_Aut) & L4==7
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L4_Aut) & L4!=7
//RAS

*Problem 4: vraisemblance des reponses 
levelsof L4_Aut


*============================================================================
*L5. Statut d'occupation
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L5) &  hha != "" & (rgmen == 1 | rghab == 4)
//929 observations. Parmi ces 929, il y a les réponses de 927 individus qui n'ont pas répondu à la question L1. Donc nous allons faire la différence
count if missing(L5) & !missing(L1) &  hha != "" & (rgmen == 1 | rghab == 4)
//2 observations

*Correction
cap drop mod_L5
egen mod_L5 = mode(L5) if missing(L5) & L1==4 &  hha != "" & (rgmen == 1 | rghab == 4)
replace L5 = mod_L5 if missing(L5) & L1==4 &  hha != "" & (rgmen == 1 | rghab == 4)
cap drop mod_L5

cap drop mod_L5
egen mod_L5 = mode(L5) if missing(L5) & L1==5 &  hha != "" & (rgmen == 1 | rghab == 4)
replace L5 = mod_L5 if missing(L5) & L1==5 &  hha != "" & (rgmen == 1 | rghab == 4)
cap drop mod_L5

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L5) & L4==.a & (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L5,1,8) & !missing(L5)
//RAS

*============================================================================
*L5_Aut. Préciser statut d'occupation
*============================================================================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L5_Aut) & L5==8
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L5_Aut) & L5!=8
//RAS

*Probleme 4: vraisemblance des reponses 
levelsof L5_Aut 

*============================================================================
*L6. Si locataire ou Location-vente, combien payez-vous par mois?
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L6) & inlist(L5,3,4)
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L6) & (L5!=3 & L5!=4)
//RAS

*Problem 3: les valeurs renseignées sont elles permises 
graph box L6, over(L1)
//il y a des loyers inférieurs à 1000f

*Problem 4: vraisemblance des reponses

//Remplacer les loyers inférieurs à 1000  par les médianes des maisons semblables

cap drop med_L6
gen med_L6 = .
forvalues i = 1/7 {

    * Calcul de la médiane sans prendre les valeurs manquantes
    egen temp_med = median(L6) if L1==`i' & !missing(L6)
    * Propager la médiane au groupe
    egen temp_med2 = max(temp_med), by(L1)
    * Stocker la médiane
    replace med_L6 = temp_med2 if L1==`i'
    * Remplacer uniquement les valeurs < 1000 et non manquantes
    replace L6 = med_L6 if L6 < 1000 & !missing(L6) & L1==`i'
    * Nettoyage
    drop temp_med temp_med2
}
drop med_L6

*Vérification
graph box L6, over(L1)

//C'est peu probable qu'une personne vivant dans une case ou une baraque ait un loyer qui depasse 15000F
count if L6>15000 & inlist(L6,6,7)
//RAS

*============================================================================
*L7.Principal Source d’approvisionnement en eau de boisson
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L7) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
br L1 L3 L4 if missing(L7) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
//3 individus sont concernés

*Correction : on remplace les valeurs manquantes par le mode du cluster
cap drop mod_L7
egen mod_L7 = mode(L7) if !missing(L1) & L1==4 & L3==1 & L4==1
replace L7 = mod_L7 if missing(L7) & !missing(L1) & L1==4 & L3==1 & L4==1 & hha != "" & (rgmen == 1 | rghab == 4)

cap drop mod_L7
egen mod_L7 = mode(L7) if !missing(L1) & L1==5
replace L7 = mod_L7 if missing(L7) & !missing(L1) & L1==5 & hha != "" & (rgmen == 1 | rghab == 4)
cap drop mod_L7

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L7) & (missing(L1) | hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L7,1,16) & !missing(L7)
//RAS

*============================================================================
*L7_Aut. Autres à preciser 
*============================================================================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L7_Aut) & L7==16
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L7_Aut) & L7!=16
//RAS 

*Probleme 4: vraisemblance des reponses 
levelsof L7_Aut 

*============================================================================
*L8. Quel est le Mode principal d’évacuation des ordures ménagères ?
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L8) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
//5 individus concernés

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L8 using "$folderpath/document/Erreur_L8_NA" if missing(L8) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction : on remplace les valeurs manquantes par le mode du cluster

cap drop mode_L8 mode_L8_final

egen mode_L8 = mode(L8) if !missing(L8), by(L1)
egen mode_L8_final = max(mode_L8), by(L1)
replace L8 = mode_L8_final if missing(L8) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4) & !missing(mode_L8_final)

count if missing(L8) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)

drop mode_L8 mode_L8_final

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L8)& (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L8,1,6) & !missing(L8)
//RAS

*============================================================================
*L8_Aut. Préciser l'autre Mode d’évacuation des ordures ménagères
*============================================================================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L8_Aut) & L8==6
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L8_Aut) & L8!=6
//RAS

*Probleme 4: vraisemblance des reponses 
levelsof L8_Aut 

*============================================================================
*L9. Principal mode d’évacuation des eaux usées
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L9) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
//5 individus concernés 

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L9 using "$folderpath/document/Erreur_L9_NA" if missing(L9) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction : remplacer les valeurs manquantes par le mode du cluster
cap drop mode_L9 mode_L9_final

egen mode_L9 = mode(L9) if !missing(L9), by(L1)
egen mode_L9_final = max(mode_L9), by(L1)
replace L9 = mode_L9_final if missing(L9) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4) & !missing(mode_L9_final)

count if missing(L9) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)

drop mode_L9 mode_L9_final

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L9) & (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L9,1,6) & !missing(L9)
//RAS

*============================================================================
*L9_Aut. Préciser l'autre Mode d’évacuation des eaux usées ?
*============================================================================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L9_Aut) & L9==6
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L9_Aut) & L9!=6
//RAS

*Probleme 4: vraisemblance des reponses 
levelsof L9_Aut 

*============================================================================
*L10. Quel est le principal lieu d’aisance du ménage ?
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L10) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
//6 individus sont concernés 

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L10 using "$folderpath/document/Erreur_L10_NA" if missing(L10) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction : remplacer les valeurs manquantes par le mode du cluster
cap drop mode_10 mode_10_final

egen mode_L10 = mode(L10) if !missing(L10), by(L1)
egen mode_L10_final = max(mode_L10), by(L1)
replace L10 = mode_L10_final if missing(L10) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4) & !missing(mode_L10_final)

count if missing(L10) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)

drop mode_L10 mode_L10_final


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L10) & (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L10,1,12) & !missing(L10)
//RAS

*Problem 4: Vraisemblance des reponses 
*Une personne habitant une villa ou un appartement ne peut pas choisir les modalités 6,7,8,9,10 11
count if inrange(L10,6,11) & inlist(L1,1,2)
//1 personnes concernées

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L10 using "$folderpath/document/Erreur_L10_A_NA" if inrange(L10,6,11) & inlist(L1,1,2), firstrow(varlabels) replace 

*Correction
replace L10=1 if inrange(L10,6,11) & inlist(L1,1,2)

*Une personne habitant une baraque ou une case ne peut avoir les modalités 1,3,5,
count if inlist(L10,1,3,5) & inlist(L1,6,7)
//3 observations

*Correction
replace L10=8 if inlist(L10,1,3,5) & inlist(L1,6,7)

*============================================================================
*L10_Aut. Préciser l'autre Type de Sanitaire utilisé par le ménage
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L10_Aut) & L10==12
//RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L10_Aut) & L10!=12
//RAS 

*Probleme 4: vraisemblance des reponses 
levelsof L10_Aut 

*============================================================================
*L11. lequel de ces biens, possède actuellement votre ménage ?
*============================================================================

*Problem 1: ceux qui devaient répondre ont ils répondu 

foreach var of varlist L11__1-L11__47{
	count if `var'==.a &(hha == "" | (rgmen != 1 & rghab != 4)) 
}
//RAS 

*Problem 2: ceux qui ont repondus devaient ils repondre 
foreach var of varlist L11__1-L11__47{
	count if !missing(`var') &(hha == "" & (rgmen == 1 | rghab == 4)) 
}
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
foreach var of varlist L11__1-L11__47{
	count if !inrange(`var',0,1) & !missing(`var')
}
//RAS

*Problem 4: Vraisemblance des reponses 

//C'est peu probable qu'un individu qui vit dans une case ou une baraque ait un climatiseur 
count if L11__15==1 & inlist(L1,6,7)
//RAS

//C'est peu probable qu'un individu vivant dans une case ou une baraque ait une machine à laver 
count if L11__17==1 & inlist(L1,6,7)
//RAS

drop HH2 HH2 HH3 HH4 rghab rgmen HH12 HH13 hha

save "$standard_menage\QM_S7_logement.dta", replace

