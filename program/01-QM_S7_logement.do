* LOGEMENT (L)

* RESPONSABLE: KOUADIO BROU YVES-BEVERLIN
*========================================================


*use "$brute_menage_work", clear

use "$datain_standard\QM_S7_logement.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH6 HH12 HH13 hha rgmen rghab) // [CORR 09/11/2026 - validé] HH6 (milieu) pour la strate région x milieu
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
quietly count if missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
if r(N)>0 {
export excel interview__key HH2 HH12 HH13 L1 using "$folderpath/document/Erreur_L1_NA" if missing(L1) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 
}

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
count if !missing(L1_Aut) & L1!=8 // [CORR 09/11/2026] contrôle porté sur L1_Aut
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
* br if L1==1 & L2A<3 & !missing(L2A)

//6 observations
*correction : seules les villas de 1 pièce sont reclassées en maison simple
replace L1 = 5 if L2A <=2 & L1==1

//Un appartement dans un immeuble est en general une location, c'est peu probable que l'on ait dans ses cas plus de 5 pièces 
count if L2A>5 & L1==2 // RAS


//Cherchons s'il y a des logements avec 0 pièces
count if L2A==0 & !missing(L1)
//RAS

//Dans une case, on ne peut avoir plus de 3 pièces, cependant il peut d'une concession dans laquelle plusieurs cases sont occupées par le ménage 
count if L2A>3 & L1==6 & !missing(L2A)
* br if L2A>3 & L1==6 & !missing(L2A)

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
* br if L2B>L2A & !missing(L2A,L2B)
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
quietly count if missing(L3) & hha != "" & (rgmen == 1 | rghab == 4)
if r(N)>0 {
export excel interview__key HH2 HH12 HH13 L1 using "$folderpath/document/Erreur_L3_NA"  if missing(L3) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 
}

	
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
 
//correction 
replace L1 = 5 if inlist(L3,1,2) & inlist(L1,6,7)

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
quietly count if missing(L4) & hha != "" & (rgmen == 1 | rghab == 4)
if r(N)>0 {
export excel interview__key HH2 HH12 HH13 L4 using "$folderpath/document/Erreur_L4_NA" if missing(L4) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 
}

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

*============================================================================
*L5. Statut d'occupation
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L5) &  hha != "" & (rgmen == 1 | rghab == 4)

//1374 observations. Parmi ces 1374, il y a les réponses de 1373 individus qui n'ont pas répondu à la question L1. Donc nous allons faire la différence
count if missing(L5) & !missing(L1) &  hha != "" & (rgmen == 1 | rghab == 4)

* br if missing(L5) & !missing(L1) &  hha != "" & (rgmen == 1 | rghab == 4)

//1 observations

*Correction: imputation par le statut d'occupation le plus fréquent selon la région et le type de logement
cap drop mode_L5
egen mode_L5 = mode(L5) if !missing(L5), by(HH2 L1) minmode
bysort HH2 L1 (mode_L5): replace mode_L5 = mode_L5[1]
replace L5 = mode_L5 if missing(L5) & !missing(L1) &  hha != "" & (rgmen == 1 | rghab == 4) & !missing(mode_L5)
drop mode_L5

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L5) & (hha == "" | (rgmen != 1 & rghab != 4)) 
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

//Remplacer les loyers inférieurs à 1000 par la médiane de la strate (région x milieu), médiane calculée sur les seuls loyers valides (>= 1000 F), par strate HH2 x HH6

cap drop med_L6
egen med_L6 = median(L6) if L6 >= 1000 & !missing(L6), by(HH2 HH6)
bysort HH2 HH6 (med_L6): replace med_L6 = med_L6[1]

count if L6 < 1000 & !missing(L6)
replace L6 = med_L6 if L6 < 1000 & !missing(L6) & !missing(med_L6)
count if L6 < 1000 & !missing(L6) // doit être 0
drop med_L6

*Vérification
graph box L6, over(L1)

//C'est peu probable qu'une personne vivant dans une case ou une baraque ait un loyer qui depasse 25000F
count if L6>25000 & inlist(L1,6,7) & !missing(L6) 
* br if L6>25000 & inlist(L1,6,7) & !missing(L6) 

*============================================================================
*L7.Principal Source d’approvisionnement en eau de boisson
*============================================================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L7) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*br L1 L3 L4 if missing(L7) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L7) & (missing(L1) | hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L7,1,16) & !missing(L7)
//RAS

*Problem 4: vraisemblance
// il est peu probable qu'un individu qui vive dans un appartement dans immeuble ait pour source d'approvisionnement en eau Fleuve/rivière...

count if L7==12 & L1==2 ///
	& !missing(L7) ///
	& hha != "" & (rgmen == 1 | rghab == 4)
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


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L10) & (hha == "" | (rgmen != 1 & rghab != 4))
//RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L10,1,12) & !missing(L10)
//RAS

*Problem 4: Vraisemblance des reponses 
*Une personne habitant une villa ou un appartement ne peut pas choisir les modalités 6,7,8,9,10 11
count if inrange(L10,6,11) & inlist(L1,1,2)
//RAS

*Une personne habitant une baraque ou une case ne peut avoir les modalités 1,3,5,
count if inlist(L10,1,3,5) & inlist(L1,6,7)
//1 observations

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
	count if missing(`var') & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4) 
}
//RAS 

*Problem 2: ceux qui ont repondus devaient ils repondre 
foreach var of varlist L11__1-L11__47{
	count if !missing(`var') & (hha == "" | (rgmen != 1 & rghab != 4)) 
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

drop HH2 HH3 HH4 HH6 rghab rgmen HH12 HH13 hha

save "$standard_menage\QM_S7_logement.dta", replace

