*=========================================================
* LOGEMENT (L)

* RESPONSABLE: RENAUD HIVITES AKATTIA (PECHOUX)
*========================================================


*use "$datain_brute\QX_EEC_VF.dta", clear

use "$datain_standard\QM_S7_logement.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH6 HH12 HH13 hha rgmen rghab)
drop if _merge!=3
cap drop _merge


*=================================
*L1.Typedeconstruction
*=================================

*Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L1) & (hha != "" & (rgmen == 1 | rghab == 4))
*707 individus ont été identifiés 
*br rghab rgmen hha L1 HH0 if missing(L1) & (hha != "" & (rgmen == 1 | rghab == 4))


*Identification des Agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 L1 using "$folderpath/document/Erreur_L1_NA" if L1==.a & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction

*br if missing(L1) & (hha != "" & (rgmen == 1 | rghab == 4))
*br  if HH8B == "DELBOH 2 BARRAGE"


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L1) & (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L1,1,8) & !missing(L1)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS
*=================================
*L1.Autre type de logement 
*=================================
*Problem 1: Ceux qui devaient repondre ont ils repondu 
count if missing(L1_Aut) & L1==8
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L1) & !missing(L2A) & (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*=================================
*L2A. Nombre total de pièces dans le logement
*=================================
*Problem 1: Ceux qui devaient repondre ont ils repondu 
count if missing(L2A) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*3 individus sont concernés 


*Identification des agents ayant fait des erreurs
export excel interview__key HH2 HH12 HH13 L2A using "$folderpath/document/Erreur_L2A_NA" if missing(L2A) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction
cap drop med_L2A
egen med_L2A=median(L2A) if L1 == 5
replace L2A = med_L2A if missing(L2A) & L1 == 5

cap drop med_L2A
egen med_L2A=median(L2A) if L1 == 4
replace L2A = med_L2A if missing(L2A) & L1 == 4
cap drop med_L2A


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L1) & !missing(L2A) & (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*Il est peu probable que le nombre de pièces depasse 50 .Par ailleurs la valeur renseignée ne doit pas etre négative
count if (L2A>50 | L2A<0)  & !inlist(L2A,.,.a,98)
*RAS

*Problem 4: Vraisemblance des reponses 
*Une villa doit faire au moins 3 pièces. C'est peu probable qu'une villa ait 2 pièces uniquement.
*count if L1==1 & L2A<3
*4 individus affirment qu'ils vivent dans une villa de 2 pièces ce qui semble peu probable
 
count if L1==1 & L2A<2
*2 personnes vivent dans une villa de moins de 2 pièces, cela est invraisemblable
*RAS


*Identifcation des agents ayant fait des erreurs
*export excel interview__key HH13 L2A using "$folderpath/document/Erreur_L2A_coh1" if L1==1 & L2A<2, firstrow(varlabels) replace 

*Correction 
*on remplace ses pseudo villas d'une pièce par une maison simple
*replace L1=5 if  L1==1 & L2A<2

*Un appartement dans un immeuble est en general une location, c'est peu probable que l'on ait dans ses cas plus de 5 pièces 
count if L2A>5 & L1==2
*1 individus concernés


*Identification des agents concernés 
export excel interview__key HH13 L2A using "$folderpath/document/Erreur_L2A_coh2" if L2A>5 & L1==2, firstrow(varlabels) replace 

*Correction
replace L1 = 1 if L2A>5 & L1==2 // Transformer l'appartement en villa



count if L2A==0 & !missing(L1)
*RAS




*Identificaion des agents ayant fait des erreurs
*export excel interview__key HH13 L2A using "$folderpath/document/Erreur_L2A_coh2" if L2A>5 & L1==3, firstrow(varlabels) replace 



*gen L1_=L1
*replace L1=8 if L2A>5 & L1==3 & L2A>9 & L2A==L2B // Pour un nombre de pièces superieur à 10 ou le nombre de piéces correspond au nombre de chambres, il n'y a pas de modalités s'y rapportant. Cela ressemble plus à une concession. 

*replace L1_Aut="CONCESSION" if L1_Aut=="" & L1_==3 & L1==8
*On remplace la valeur de L1_Aut par concession 

*drop L1_

*C'est peu probable qu'une personne habitant une cour commune ait plus de 5 pièces 
count if L2A>5 & L1==5 & L2A==L2B
*br if L2A>4 & L1==4 & L2A==L2B
*9 individus ont été identifiés et la plupart sont  propriétaires. Il semble que ceux ci ont plutot donné le nombre de portes dans la cour.


*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 L2A using "$folderpath/document/Erreur_L2A_coh3" if L2A>4 & L1==4 & L2A==L2B, firstrow(varlabels) replace 

*Correction
*replace L2A = 5 if L2A>5 & L1==5 & L2A==L2B // Le nombre de pièces supérieurs à 5 est ramené à 5


*Dans une case, on ne peut avoir plus de 3 pièces, cependant il peut d'une concession dans laquelle plusieurs cases sont occupées par le ménage 
count if L2A>3 & L1==6
*8 individus sont concernés



*Identification des agents ayant fait des erreurs 
export excel interview__key HH2 HH12 HH13 L2A using "$folderpath/document/Erreur_L2A_coh4" if L2A>3 & L1==6, firstrow(varlabels) replace 

*Dans une baraque c'est peu probable d'avoir plus de 3 pièces 
count if L2A>3 & L1==7
*2 individus sont concernés.

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH2 HH12 HH13 L2A using "$folderpath/document/Erreur_L2A_coh5" if L2A>3 & L1==7, firstrow(varlabels) replace 

*Correction 
*Le nombre de chambres correspond au nombre de piéces et la personne est propriétaire; Il est possible que ce soit une concession 
/*
gen L1_=L1
replace L1=8 if L2A>3 & L1==7 & L2A==L2B & L1>4

replace L1_Aut="CONCESSION" if L1_Aut==""& L1_==7 & L1==8

drop L1_
*/

*===================================
*L1_Aut: AUtres à peciser 
*==================================

*Problem1: Ceux qui devaient repondre ont ils repondu 
count if L1==8 & L1_Aut==""
*RAS

*export excel interview__key HH13 L1_Aut using "$folderpath/document/Erreur_L2A_NA" if L1==8 & L1_Aut=="", firstrow(varlabels) replace 

*Correction
*replace L1=1 if  L1==8 & L1_Aut==""


*Problem2: Ceux qui ont repondu devaient ils repondre 
count if L1_Aut!="" & inrange(L1,1,7)
*RAS

*Problem3: les valeurs renseignées sont elles permises 
levelsof L1_Aut
*Il apparait une modalité maison chacun chez soi que nous remplacons par maison en bande 



*===================================
*L2.B Nombre de pièce utilisé pour dormir dans le logement
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L2B) & !missing(L2A) & hha != "" & (rgmen == 1 | rghab == 4)
*1 cas


*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L2A using "$folderpath/document/Erreur_L2A_NA" if missing(L2B) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction
replace L2B=L2A if missing(L2B) & !missing(L2A) & hha != "" & (rgmen == 1 | rghab == 4)


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L2B)&  (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*Les valeurs entrées ne doivent pas etre negatives.Par ailleurs, elles ne doivent pas etre superieures au nombre de pièces de la maison 

count if L2B>L2A | L2B<0
*RAS

*Identification des agents ayant fait des erreurs
*export excel interview__key HH13 L2A using "$folderpath/document/Erreur_L2A_NA" if  L2B>L2A | L2B<0, firstrow(varlabels) replace 

*Correction
replace L2B=L2A if L2B>L2A | L2B<0


*Problem 4: Vraisemblance des reponses 
*RAS

*================================
*L3. Principal matériau de construction des murs extérieurs
*==============================
*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L3) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*3 cas

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L3 using "$folderpath/document/Erreur_L3_NA" if missing(L3) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 


*Correction
replace L3=1 if missing(L3) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L3)&  (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L3,1,7) & !missing(L3)
*RAS

*Problem 4: Vraisemblance des reponses 

*Il est peu probable qu'une villa soit construite en pierres simples,paille,planche
count if inlist(L3,4,5,6) & L1==1
*RAS

*Il est peu probable qu'une baraque ou une case soit construite en ciment,brique,geo-béton
count if inlist(L3,1,2) & inlist(L1,6,7)
*4 individus sont concernés


*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L3 using "$folderpath/document/Erreur_L3_coh" if inlist(L3,1,2) & inlist(L1,6,7), firstrow(varlabels) replace  
 
 
* Correction
replace L3 = 6 if inlist(L3,1,2) & inlist(L1,6,7)



*==============================
*L3_Aut: Autres à preciser
*=============================

* Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L3_Aut) & L3==7
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L3_Aut) & L3!=7
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS 



*=========================
*L4. Principale source d'éclairage
*========================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if L4==.a & L1!=.a & hha != "" & (rgmen == 1 | rghab == 4)
*3 cas

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L4 using "$folderpath/document/Erreur_L4_NA" if missing(L4) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction
replace L4=1 if L4==.a & L1 !=.a & hha != "" & (rgmen == 1 | rghab == 4)



*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L4) & (hha == "" | (rgmen != 1 & rghab != 4))
*RAS



*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L4,1,7) & !missing(L4)
*RAS

*Problem 4: Vraisemblance des reponses 

*Il est peu probable qu'une villa soit éclairée par une lampa à pétrole,lampe à pile, parafine
count if inlist(L4,3,4,5) & L1==1
*RAS


*Identification des agents ayant fait des erreurs
*export excel interview__key HH13 L4 using "$folderpath/document/Erreur_L3_coh" if inlist(L4,3,4,5) & L1==1, firstrow(varlabels) replace 

*===========================
*L4_Aut. Préciser l'autre Mode d'éclairage
*===========================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L4_Aut) & L4==7
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L4_Aut) & L4!=7
*RAS
*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 L4_Aut using "$folderpath/document/Erreur_L4Aut_coh" if !missing(L4_Aut) & L4!=7, firstrow(varlabels) replace 

*Correction
*replace L4_Aut="" if !missing(L4_Aut) & L4!=7

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS 

*Problem 4: vraisemblance des reponses 
levelsof L4_Aut
*Il n'y a aucune modalité pour cette variable

*============================
*L5. Statut d'occupation
*==========================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L5) & !missing(L1) &  hha != "" & (rgmen == 1 | rghab == 4)
*1 individu concerné

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L5 using "$folderpath/document/Erreur_L5_NA" if missing(L5) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction
cap drop mod_L5
egen mod_L5 = mode(L5) if !missing(L1) & L2A==3 & L3==1 & L4==1
replace L5 = mod_L5 if missing(L5) & !missing(L1) &  hha != "" & (rgmen == 1 | rghab == 4)
cap drop mod_L5

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L5) & L4==.a & (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L5,1,8) & !missing(L5)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*===============================
*L5_Aut. Préciser statut d'occupation
*===============================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L5_Aut) & L5==8
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L5_Aut) & L5!=8
*RAS

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 L5_Aut using "$folderpath/document/Erreur_L4Aut_coh" if !missing(L5_Aut) & L5!=8, firstrow(varlabels) replace 

*Correction
*replace L5_Aut="" if !missing(L5_Aut) & L5!=8

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Probleme 4: vraisemblance des reponses 
levelsof L5_Aut 

*Identification des agents ayant commis ces erreurs
*export excel interview__key HH13 L5 using "$folderpath/document/Erreur_L5_Aut_NA" if L5_Aut!="" & L5==8, firstrow(varlabels) replace 



*Vérification des modalités "Autre à préciser"
*count if L5_Aut!="" & L5==8
*2 modalités qu'il faut reverser


*Effacer les modalités de L5_Aut qui ont été reversé dans L5 
*replace L5_Aut="" if L5!=8



*Recodage des variables 
*Les variables restantes après remplacement sont "MAISON SON FILS DECEDE" et "COUR FAMILIALE"



*==============================
*L6. Si locataire ou Location-vente, combien payez-vous par mois?
*==============================

*Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L6) & !missing(L1) & inlist(L5,3,4)
*2 cas

*Identifcation des agents ayant fait des erreurs 
export excel interview__key HH13 L6 using "$folderpath/document/Erreur_L6_coh" if missing(L6) & inlist(L5,3,4), firstrow(varlabels) replace 


*Correction : On remplace les loyers manquants par la médiane des loyers des maisons ayant les mêmes caractéristiques
cap drop med_L6
egen med_L6=median(L6) if !missing(L1) & (L5==3 | L5==4)
replace L6 = med_L6 if missing(L6) & !missing(L1) & (L5==3 | L5==4)



*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L6) & (L5!=3 & L5!=4)
*RAS

*Problem 3: les valeurs renseignées sont elles permises 
count if L6<1000
*14 individus sont concernés


*Identification des Agents ayant fait des erreurs 
export excel interview__key HH13 L6 using "$folderpath/document/Erreur_L6_coh" if L6<1000, firstrow(varlabels) replace 

*Correction : Remplacer les loyers inférieurs à 1000 par les médianes des maisons semblables (avec géographie)
cap drop med_L6
egen med_L6=median(L6) if  L1 ==2 & L3==1 & L4==1 & L5==3, by(HH6 HH12)
replace L6 = med_L6 if L6<1000 & L1 ==2 & L3==1 & L4==1 & L5==3 & !missing(med_L6)
cap drop med_L6
egen med_L6=median(L6) if  L1 ==2 & L3==1 & L4==1 & L5==3
replace L6 = med_L6 if L6<1000 & L1 ==2 & L3==1 & L4==1 & L5==3
cap drop med_L6

cap drop med_L6
egen med_L6=median(L6) if  L1 ==3 & L3==1 & L4==1 & L5==3, by(HH6 HH12)
replace L6 = med_L6 if L6<1000 & L1 ==3 & L3==1 & L4==1 & L5==3 & !missing(med_L6)
cap drop med_L6
egen med_L6=median(L6) if  L1 ==3 & L3==1 & L4==1 & L5==3
replace L6 = med_L6 if L6<1000 & L1 ==3 & L3==1 & L4==1 & L5==3
cap drop med_L6

cap drop med_L6
egen med_L6=median(L6) if L1 ==4 & inlist(L3,1,2,3) & L4 == 1 & L5==3, by(HH6 HH12)
replace L6 = med_L6 if L6<1000 & L1 ==4 & inlist(L3,1,2,3) & L4 == 1 & L5==3 & !missing(med_L6)
cap drop med_L6
egen med_L6=median(L6) if L1 ==4 & inlist(L3,1,2,3) & L4 == 1 & L5==3
replace L6 = med_L6 if L6<1000 & L1 ==4 & inlist(L3,1,2,3) & L4 == 1 & L5==3
cap drop med_L6

cap drop med_L6
egen med_L6=median(L6) if L1 ==5 & inlist(L3,2,3) & inlist(L4,1,2,6) & L5==3, by(HH6 HH12)
replace L6 = med_L6 if L6<1000 & L1 ==5 & inlist(L3,2,3) & inlist(L4,1,2,6) & L5==3 & !missing(med_L6)
cap drop med_L6
egen med_L6=median(L6) if L1 ==5 & inlist(L3,2,3) & inlist(L4,1,2,6) & L5==3
replace L6 = med_L6 if L6<1000 & L1 ==5 & inlist(L3,2,3) & inlist(L4,1,2,6) & L5==3
cap drop med_L6



*Problem 4: vraisemblance des reponses 

*C'est peu probable qu'une personne vivant dans une case ou une baraque ait un loyer qui depasse 15000F
count if L6>15000 & inlist(L6,6,7)
*RAS

*En tabulant la variable L6, il vient qu'il y ait des locataires qui ont repondu 9998 pour le loyer . Ce qui peut signifier qu'il ne savent pas leur loyer. C'est anormal 
count if L6==9998
*RAS

*br if L6==9998


*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 L6 using "$folderpath/document/Erreur_L6_coh1" if L6==9998, firstrow(varlabels) replace 

*cap drop med_L6
*egen med_L6=median(L6) if L1 ==2 & L2A == 2 & L3 == 1 & L4==1
*replace L6 = med_L6 if L6==9998 & L1 ==2 & L2A == 2 & L3 == 1 & L4==1

*cap drop med_L6
*egen med_L6=median(L6) if L1 ==5 & L2A == 2 & L4==1 & L7==4
*replace L6 = med_L6 if L6==9998 & L1 ==5 & L2A == 2 & L4==1 & L7==4





*===================================
*L7.Principal Source d’approvisionnement en eau de boisson
*===================================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L7) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*3 individus sont concernés

*Identification des agents ayant fait des erreurs
*export excel interview__key HH13 L7 using "$folderpath/document/Erreur_L7_NA" if missing(L7) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction : on remplace les valeurs manquantes par le mode du cluster
cap drop mod_L7
egen mod_L7 = mode(L7) if !missing(L1) & L1==5 & L3==1 & L4==1
replace L7 = mod_L7 if missing(L7) & !missing(L1) & L1==5 & L3==1 & L4==1 & L5==1

cap drop mod_L7
egen mod_L7 = mode(L7) if !missing(L1) & L1==4 & L3==1 & L4==1
replace L7 = mod_L7 if missing(L7) & !missing(L1) & L1==4 & L3==1 & L4==1 & inlist(L5,1,3)
cap drop mod_L7



*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L7) & !missing(L1) & (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L7,1,16) & !missing(L7)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*===============================
*L7_Aut. Autres à preciser 
*===============================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L7_Aut) & L7==16
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L7_Aut) & L7!=16
*RAS 

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 L7_Aut using "$folderpath/document/Erreur_L7_Aut_coh" if !!missing(L7_Aut) & L7!=16, firstrow(varlabels) replace 

*Correction
*replace L7_Aut="" if !missing(L7_Aut) & L7!=16

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Probleme 4: vraisemblance des reponses 
levelsof L7_Aut 

*Recodage des variables 
*Les variables restantes après remplacement sont "PACK D EAU", "POMPE PUBLIQUE", "PUITS FERME AILLEURS","PUITS FERME DANS LA CONCESSION","PUITS FERMÉ AILLEURS"




*=============================
*L8. Quel est le Mode principal d’évacuation des ordures ménagères ?
*==========================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L8) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*5 individus concernés

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L8 using "$folderpath/document/Erreur_L8_NA" if missing(L8) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 


*Correction : on remplace les valeurs manquantes par le mode du cluster
cap drop mod_L8
egen mod_L8 = mode(L8) if !missing(L1) & L1==4 & L3==1 & L4==1
replace L8 = mod_L8 if missing(L8) & !missing(L1) & L1==4 & L3==1 & L4==1

cap drop mod_L8
egen mod_L8 = mode(L8) if !missing(L1) & L1==4 & L3==2 & L4==1
replace L8 = mod_L8 if missing(L8) & !missing(L1) & L1==4 & L3==2 & L4==1

cap drop mod_L8
egen mod_L8 = mode(L8) if !missing(L1) & L1==5 & L3==1 & inlist(L4,1,6)
replace L8 = mod_L8 if missing(L8) & !missing(L1) & L1==5 & L3==1 & inlist(L4,1,6)
cap drop mod_8




*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L8)& (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L8,1,6) & !missing(L8)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*=============================
*L8_Aut. Préciser l'autre Mode d’évacuation des ordures ménagères
*==============================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L8_Aut) & L8==6
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L8_Aut) & L8!=6
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Probleme 4: vraisemblance des reponses 
levelsof L8_Aut 

*Recodage des variables 
*Les variables restantes après remplacement sont "DANS LA BROUSSE"' `"DANS LA NATURE"



*====================
*L9. Principal mode d’évacuation des eaux usées
*====================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L9) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*3 individus concernés 

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L9 using "$folderpath/document/Erreur_L9_NA" if missing(L9) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 


*Correction : remplacer les valeurs manquantes par le mode du cluster
cap drop mod_L9
egen mod_L9 = mode(L9) if !missing(L1) & L1==4 & L3==1 & L4==1
replace L9 = mod_L9 if missing(L9) & !missing(L1) & L1==4 & L3==1 & L4==1

cap drop mod_L9
egen mod_L9 = mode(L9) if !missing(L1) & L1==5 & L3==1 & L4==1
replace L9 = mod_L9 if missing(L9) & !missing(L1) & L1==5 & L3==1 & L4==1
cap drop mod_L9


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L9)& (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L9,1,6) & !missing(L9)
*RAS

*Problem 4: Vraisemblance des reponses 
*RAS

*=========================
*L9_Aut. Préciser l'autre Mode d’évacuation des eaux usées ?
*=========================

*Problem 1: ceux qui devaient repondre ont ils repondu 
count if missing(L9_Aut) & L9==6
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L9_Aut) & L9!=6
*RAS

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 L9 using "$folderpath/document/Erreur_L9Aut_coh" if !missing(L9_Aut) & L9!=6, firstrow(varlabels) replace 

*Correction
*replace L9_Aut="" if !missing(L9_Aut) & L9!=6


*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Probleme 4: vraisemblance des reponses 
levelsof L9_Aut 

*Recodage des variables 
*Les variables restantes après remplacement sont "DANS UN TROU"' `"DEVANT LA COUR"'




*===============================
*L10. Quel est le principal lieu d’aisance du ménage ?
*===============================

*Problem 1: Ceux qui devaient repondre ont ils repondus
count if missing(L10) & !missing(L1) & hha != "" & (rgmen == 1 | rghab == 4)
*3 individus sont concernés 

*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L10 using "$folderpath/document/Erreur_L10_NA" if missing(L10) & hha != "" & (rgmen == 1 | rghab == 4), firstrow(varlabels) replace 

*Correction : remplacer les valeurs manquantes par le mode du cluster
cap drop mod_L10
egen mod_L10 = mode(L10) if !missing(L1) & L1==4 & L3==1 & L4==1
replace L10 = mod_L10 if missing(L10) & !missing(L1) & L1==4 & L3==1 & L4==1

cap drop mod_L10
egen mod_L10 = mode(L10) if !missing(L1) & L1==5 & L3==1 & L4==1
replace L10 = mod_L10 if missing(L10) & !missing(L1) & L1==5 & L3==1 & L4==1
cap drop mod_L10


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L10)& (hha == "" | (rgmen != 1 & rghab != 4))
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
count if !inrange(L10,1,12) & !missing(L10)
*RAS

*Problem 4: Vraisemblance des reponses 
*Une personne habitant une villa ou un appartement ne peut pas choisir les modalités 6,7,8,9,10 11
count if inrange(L10,6,11) & inlist(L1,1,2)
*6 personnes concernées


*Identification des agents ayant fait des erreurs
export excel interview__key HH13 L10 using "$folderpath/document/Erreur_L10_A_NA" if inrange(L10,6,11) & inlist(L1,1,2), firstrow(varlabels) replace 

*Correction
replace L10=1 if inrange(L10,6,11) & inlist(L1,1,2)


*Une personne habitant une baraque ou une case ne peut avoir les modalités 1,3,5,
count if inlist(L10,3,5) & inlist(L1,6,7)
*RAS
*1 individu concerné 

*Identification des agents ayant fait des erreurs
*export excel interview__key HH13 L10 using "$folderpath/document/Erreur_L10_A_NA" if inlist(L10,3,5) & inlist(L1,6,7), firstrow(varlabels) replace 

*Correction
replace L10=8 if inlist(L10,3,5) & inlist(L1,6,7)


*===============================
*Problem 1: ceux qui devaient repondre ont ils repondu 
*=================================

*Problem 1: Ceux qui devaient repondre ont ils repondu
count if missing(L10_Aut) & L10==12
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(L10_Aut) & L10!=12
*RAS 

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 L10 using "$folderpath/document/Erreur_L10Aut_coh" if !missing(L10_Aut) & L10!=12, firstrow(varlabels) replace 

*Correction
*replace L10_Aut="" if !missing(L10_Aut) & L10!=12


*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Probleme 4: vraisemblance des reponses 
levelsof L10_Aut 

*Recodage des variables 
*Les variables restantes après remplacement sont `"LATRINE DALLER COUVERT EXTERNE"' `"toillette ailleurs"'





*============================
*L11. lequel de ces biens, possède actuellement votre ménage ?
*=============================

*Problem 1: ceux qui ont devaient repondre ont ils repondu 

foreach var of varlist L11__1-L11__47{
	count if `var'==.a &(hha == "" | (rgmen != 1 & rghab != 4)) 
}
*RAS 

*Identification des agents ayant fait des erreurs 
*foreach var of varlist L11__1-L11__47{
		*export excel interview__key HH13 `var' using "$folderpath/document/Erreur_L11_NA" if missing(`var') &(hha == "" | (rgmen != 1 & rghab != 4)), firstrow(varlabels) replace 
*}

*Problem 2: ceux qui ont repondus devaient ils repondre 
foreach var of varlist L11__1-L11__47{
	count if !missing(`var') &(hha == "" & (rgmen == 1 | rghab == 4)) 
}

*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
foreach var of varlist L11__1-L11__47{
	count if !inrange(`var',0,1) & !missing(`var')
}
*RAS

*Problem 4: Vraisemblance des reponses 
*C'est peu probable qu'un individu qui vit dans une case ou une baraque ait un climatiseur 
count if L11__15==1 & inlist(L1,6,7)
*RAS

*C'est peu probable qu'un individu vivant dans une case ou une baraque ait une machine à laver 
count if L11__17==1 & inlist(L1,6,7)
*RAS

drop HH2 HH2 HH3 HH4 rghab rgmen HH12 HH13 hha

save "$standard_menage\QM_S7_logement.dta", replace

