
*================================================
*********AUTRE FORMES DE TRAVAIL

****RESPONSABLE: ABDOUL KADER 
*=============================================

********************
**********Importation 
*global datain_brute "C:\apurement_ENE\bases"
*display "$datain_brute"

use "$datain_standard\INDIV_S1_autres_formes_travail.dta", clear

*****Appel des autres variables 

merge 1:1 interview__key membres__id  using "$datain_standard\QM_S1_composition_menage.dta", keepus(AgeAnnee Statut_Res ) 

keep if _merge == 3
drop  _merge

merge m:1 interview__key  using "$datain_standard\QM_S0_identification.dta", keepusing(HH13 MODINTR )

keep if _merge == 3
drop  _merge


merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S3_emploi_principal.dta", keepus(EN_EMP)

keep if _merge == 3
drop  _merge

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND ) 

keep if _merge == 3
drop  _merge

*****La vriable hhaa est introuvable dans les bases standardisées, elle est plutot dans la base membres 
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(hhaa)
keep if _merge == 3
drop  _merge


**************Fin appel de variables*****************

*********************

/****** Control de la section variable par variable suivant les 4 points d'actions

1) Control des valeurs manquantes : Tous ceux qui devrait repondre on bel et bien répondu

2) Control de l'effectivement des sauts : seules ceux qui ont le droit de repondre ont répondu

3) Les valeurs renseignées sont dans le champs de définition de la variable

4) Les valeurs renseignées sont vraissembables

 **************************************/

//////M4Confir : Quel est votre âge ?

//1)

count if missing(M4Confirm) & (AgeAnnee >=13 & Statut_Res==1 & hhaa != "" & hhaa != "##N/A##") // 3 personne pour qui la question n'a pas été repondu

*br M4Confirm AgeAnnee hhaa if missing(M4Confirm) & (AgeAnnee >=13 & Statut_Res==1 & hhaa != "" & hhaa != "##N/A##" )

*exportation des individus potentiellement concernés

export excel interview__key HH13 M4Confirm AgeAnnee MODINTR using "$folderpath/document/autres_formes_trav_M4Confirm_NA" if missing(M4Confirm) & (AgeAnnee >=13 & Statut_Res==1 & hhaa != "" & hhaa != "##N/A##"), firstrow(varl) replace
**

******Correction: On ne peut corriger l'age manquantes
//2) 

count if !missing(M4Confirm) & (AgeAnnee <13 | Statut_Res==0 | hhaa == "" | hhaa == "##N/A##") // Il s'agit de deux personnes pour qui nous avions apuré la variable AgeAnnee. RAS

*br M4Confirm AgeAnnee hhaa if !missing(M4Confirm) & (AgeAnnee <13 | Statut_Res==0 | hhaa == "" | hhaa == "##N/A##") // Il s'agit de deux personnes pour qui nous avions apuré la variable AgeAnnee. RAS

//3)

ta M4Confirm,miss // Les valeurs renseignées sembles non abérantes avec un max de 101 ans




//4) 

ta M4Confirm,miss // il semblerait que quelques personnes ayant déclarées plus de 13 ans à AgeAnnee sont en réalité agée de moins de 13. // On note aussi un kink anormal à 14 ans. Cela impliquerait que les agents auraient potentiellement tendance à ramener certains individus de plus de 15 ans à 14 pour ne pas les intérrogés dans la section emploi. 

*hist M4Confirm

*exportation des individus potentiellement concernés

export excel interview__key HH13 M4Confirm AgeAnnee MODINTR using "$folderpath/document/autres_formes_trav_M4Confirm_14" if M4Confirm == 14, firstrow(varl) replace
**

///// FT1A1. Avez-vous rassemblé et/ou transformé, en vue du stockage, les produits de la mine ou forêt, y compris le bois à brûler et autres combustibles pour la consommation de votre ménage ?

//1) 
count if missing(FT1A1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT1A1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT1A1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT1A1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT1H. Combien d’heures par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT1H) & FT1A1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT1H) & FT1A1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1H, miss

count if FT1H >168 & FT1H !=. & FT1H !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT1M. %FT1H% Heure(s) et Combien de minute

//1)

*br if missing(FT1M) & FT1A1 == 1 // tous ceux qui devaient répondre à la question ont répondu

*exportation des individus potentiellement concernés
export excel interview__key HH13 FT1M using "$folderpath/document/autres_formes_trav_comb" if missing(FT1M) & FT1A1 == 1, firstrow(varl) replace

*Correction
replace FT1M = 0 if missing(FT1M) & FT1A1 == 1 & !missing(FT1H)

//2)

count if !missing(FT1M) & FT1A1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1M, miss

count if FT1M >60 & FT1M !=. & FT1M !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT1M ==60 & FT1M !=. & FT1M !=.a // 2 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 

*exportation des individus potentiellement concernés
export excel interview__key HH13 FT1M using "$folderpath/document/autres_formes_trav_comb" if FT1M ==60 & FT1M !=. & FT1M !=.a, firstrow(varl) replace
**

*proposition de correction : 
*br interview__key membres__id FT1H FT1M if FT1M ==60 & FT1M !=. & FT1M !=.a

gen FT1M_ = FT1M

replace FT1H = FT1H + 1 if FT1M_ ==60 & FT1M_ !=. & FT1M_ !=.a

drop FT1M_

replace FT1M = 0 if FT1M == 60


//4)

 

count if FT1H == 0 & FT1M == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas 
 

///// FT1B1. Avez-vous collecté de l’eau de sources n aturelles ou autres pour la consommation de v otre ménage 

//1) 
count if missing(FT1B1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT1B1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT1B1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT1A1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT1BH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT1BH) & FT1B1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT1BH) & FT1B1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1BH, miss

count if FT1BH >168 & FT1BH !=. & FT1BH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT1BM.%FT1BH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 

//1)

count if missing(FT1BM) & FT1B1 == 1 // 2 personnes pour qui la question n'a pas été répondu

//2)

count if !missing(FT1BM) & FT1B1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1BM, miss

count if FT1BM >60 & FT1BM !=. & FT1BM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT1BM == 60 & FT1BM !=. & FT1BM !=.a // 4 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 

*proposition de correction : 

*br interview__key membres__id FT1BH FT1BM if FT1BM == 60 & FT1BM !=. & FT1BM !=.a

gen FT1BM_ = FT1BM

replace FT1BH = FT1BH + 1 if FT1BM_ ==60 & FT1BM_ !=. & FT1BM_ !=.a

drop FT1BM_

replace FT1BM = 0 if FT1BM == 60

//4)

count if FT1BH == 0 & FT1BM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas


///// FT1C1. Avez-vous fabriqué des produits pour le ménage (meubles, textiles, habillement et chau ssures, poterie ou autres produits durables, y c ompris les bateaux et canoë) pour votre ména ge ? 

//1) 
count if missing(FT1C1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT1C1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT1C1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT1C1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 


//4)

///// FT1CH.Combien d’heures par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT1CH) & FT1C1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT1CH) & FT1C1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1CH, miss

count if FT1CH >168 & FT1CH !=. & FT1CH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT1CM.%FT1CH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 

//1)

count if missing(FT1CM) & FT1C1 == 1 // tous ceux qui devaient répondre ont répondu

//2)

count if !missing(FT1CM) & FT1C1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1CM, miss

count if FT1CM >60 & FT1CM !=. & FT1CM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT1CM == 60 & FT1CM !=. & FT1CM !=.a // 0 valeurs en minutes sont égales à 60. ce qui est consistent.   
*proposition de correction : 


//4)

count if FT1CH == 0 & FT1CM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas


///// FT1D1. Avez-vous construit ou fait des réparati ons majeures d’habitation ou ferme appartena nt à votre ménag 

//1) 
count if missing(FT1D1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT1D1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT1D1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT1D1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT1DH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT1DH) & FT1D1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT1DH) & FT1D1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1DH, miss

count if FT1DH >168 & FT1DH !=. & FT1DH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT1DM.%FT1DH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 

//1)

count if missing(FT1DM) & FT1D1 == 1 // tous ceux qui devaient repondre ont répondu

//2)

count if !missing(FT1DM) & FT1D1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1DM, miss

count if FT1DM >60 & FT1DM !=. & FT1DM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT1DM == 60 & FT1DM !=. & FT1DM !=.a // 1 valeurs égales à 60. ce qui est inconsistent.   

**correction 

replace FT1DH = FT1DH + 1 if FT1DM == 60 & FT1DM !=. & FT1DM !=.a

replace FT1DM = 0 if FT1DM == 60 & FT1DM !=. & FT1DM !=.a

//4)

count if FT1DH == 0 & FT1DM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 


///// FT1E1. Avez-vous fait des activités agricoles, d’é levage, de pêche, ou de chasse dont la destinat ion principale de cette production est pour la c onsommation de votre ménage 

//1) 
count if missing(FT1E1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT1E1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT1E1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT1E1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT1E1H.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT1E1H) & FT1E1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT1E1H) & FT1E1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1E1H, miss

count if FT1E1H >168 & FT1E1H !=. & FT1E1H !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT1E1M. %FT1E1H% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT1E1M) & FT1E1 == 1 // tous ceux qui devaient repondre ont répondu

*exportation des individus potentiellement concernés
export excel interview__key HH13 FT1M using "$folderpath/document/autres_formes_trav_comb" if missing(FT1E1M) & FT1E1 == 1, firstrow(varl) replace

*Correction
replace FT1E1M = 0 if missing(FT1E1M) & FT1E1 == 1 & !missing(FT1E1H)

//2)

count if !missing(FT1E1M) & FT1E1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT1E1M, miss

count if FT1E1M >60 & FT1E1M !=. & FT1E1M !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT1E1M == 60 & FT1E1M !=. & FT1E1M !=.a // 6 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 

*proposition de correction : 

*br interview__key membres__id FT1E1H FT1E1M if FT1E1M == 60 & FT1E1M !=. & FT1E1M !=.a

gen FT1E1M_ = FT1E1M

replace FT1E1H = FT1E1H + 1 if FT1E1M_ == 60 & FT1E1M_ !=. & FT1E1M_ !=.a

drop FT1E1M_

replace FT1E1M = 0 if FT1E1M == 60

//4)

count if FT1E1H == 0 & FT1E1M == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 

///// FT2A1. Avez-vous effectué des activités de gesti on (comptabilité, achat et/ou transport de bien s) pour la consommation du ménage ?

//1) 
count if missing(FT2A1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT2A1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT2A1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT2A1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT2AH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT2AH) & FT2A1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT2AH) & FT2A1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2AH, miss

count if FT2AH >168 & FT2AH !=. & FT2AH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT2AM. %FT2AH% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT2AM) & FT2A1 == 1 // tous ceux qui devaient repondre ont répondu

//2)

count if !missing(FT2AM) & FT2A1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2AM, miss

count if FT2AM >60 & FT2AM !=. & FT2AM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT2AM == 60 & FT2AM !=. & FT2AM !=.a // 3 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 

*proposition de correction : 

*br interview__key membres__id FT2AH FT2AM if FT2AM == 60 & FT2AM !=. & FT2AM !=.a

gen FT2AM_ = FT2AM

replace FT2AH = FT2AH + 1 if FT2AM_ == 60 & FT2AM_ !=. & FT2AM_ !=.a

drop FT2AM_

replace FT2AM = 0 if FT2AM == 60

//4)

count if FT2AH == 0 & FT2AM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 

///// FT2B1. Avez-vous effectué des travaux ménage rs, dans la cour ou pour entretenir la maison p our ce ménage ou pour des membres de la fa mille vivant dans d’autres ménages, comme la préparation et le service des repas, l’évacuatio n ou le recyclage de déchets…

//1) 
count if missing(FT2B1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT2B1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT2B1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT2B1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT2BH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT2BH) & FT2B1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT2BH) & FT2B1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2BH, miss

count if FT2BH >168 & FT2BH !=. & FT2BH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT2BM. %FT2BH% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT2BM) & FT2B1 == 1 // 1 cas

*Correction
replace FT2BM = 0 if missing(FT2BM) & FT2B1==1
//2)

count if !missing(FT2BM) & FT2B1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2BM, miss

count if FT2BM >60 & FT2BM !=. & FT2BM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT2BM == 60 & FT2BM !=. & FT2BM !=.a // 9 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 

*proposition de correction : 

*br interview__key membres__id FT2BH FT2BM if FT2BM == 60 & FT2BM !=. & FT2BM !=.a

gen FT2BM_ = FT2BM

replace FT2BH = FT2BH + 1 if FT2BM_ == 60 & FT2BM_ !=. & FT2BM_ !=.a

drop FT2BM_

replace FT2BM = 0 if FT2BM == 60

//4)

count if FT2BH == 0 & FT2BM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 

///// FT2C1. Avez-vous effectué des travaux ménage rs, dans la cour ou pour entretenir la maison p our ce ménage ou pour des membres de la fa mille vivant dans d’autres ménages, comme le nettoyage, la décoration, le jardinage, l’entretie n ou les petites réparations de l’habitation ou d es locaux du ménage, des produits durables du ménage…

//1) 
count if missing(FT2C1) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT2C1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT2C1 M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT2C1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT2CH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT2CH) & FT2C1 == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT2CH) & FT2C1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2CH, miss

count if FT2CH >168 & FT2CH !=. & FT2CH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT2CM. %FT2CH% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT2CM) & FT2C1 == 1 // tous ceux qui devaient repondre ont répondu

*Correction
replace FT2CM = 0 if missing(FT2CM) & FT2C1==1

//2)

count if !missing(FT2CM) & FT2C1 != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2CM, miss

count if FT2CM >60 & FT2CM !=. & FT2CM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT2CM == 60 & FT2CM !=. & FT2CM !=.a // 6 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 

*proposition de correction : 

*br interview__key membres__id FT2CH FT2CM if FT2CM == 60 & FT2CM !=. & FT2CM !=.a

gen FT2CM_ = FT2CM

replace FT2CH = FT2CH + 1 if FT2CM_ == 60 & FT2CM_ !=. & FT2CM_ !=.a

drop FT2CM_

replace FT2CM = 0 if FT2CM == 60

//4)

count if FT2CH == 0 & FT2CM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 


///// FT2D1a. Avez-vous effectué des travaux ménag ers, dans la cour ou pour entretenir la maison pour ce ménage ou pour des membres de la fa mille vivant dans d’autres ménages, comme do nner des soins et instruction aux enfants ?

//1) 
count if missing(FT2D1a) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT2D1a) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT2D1a M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT2D1a) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT2D1aH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT2D1aH) & FT2D1a == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT2D1aH) & FT2D1a != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2D1aH, miss

count if FT2D1aH >168 & FT2D1aH !=. & FT2D1aH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT2D1aM. %FT2D1aH% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT2D1aM) & FT2D1a == 1 // tous ceux qui devaient repondre ont répondu

*Correction
replace FT2D1aM = 0 if missing(FT2D1aM) & FT2D1a==1

//2)

count if !missing(FT2D1aM) & FT2D1a != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2D1aM, miss

count if FT2D1aM >60 & FT2D1aM !=. & FT2D1aM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT2D1aM == 60 & FT2D1aM !=. & FT2D1aM !=.a // 

*proposition de correction : 

*br interview__key membres__id FT2D1aH FT2D1aM if FT2D1aM == 60 & FT2D1aM !=. & FT2D1aM !=.a

gen FT2D1aM_ = FT2D1aM

replace FT2D1aH = FT2D1aH + 1 if FT2D1aM_ == 60 & FT2D1aM_ !=. & FT2D1aM_ !=.a

drop FT2D1aM_

replace FT2D1aM = 0 if FT2D1aM == 60

//4)

count if FT2D1aH == 0 & FT2D1aM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 


/////  FT2D1b.Avez-vous effectué des travaux ménagers, dans la cour ou pour entretenir la maison pour ce ménage ou pour des membres de la fa mille vivant dans d’autres ménages, comme tra nsporter et donner des soins aux membres âg és, dépendants ou autres membres du ménag e ?

//1) 
count if missing(FT2D1b) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT2D1b) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT2D1b M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT2D1b) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT2D1bH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT2D1bH) & FT2D1b == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT2D1bH) & FT2D1b != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2D1bH, miss

count if FT2D1bH >168 & FT2D1bH !=. & FT2D1bH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT2D1bM. %FT2D1aH% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT2D1bM) & FT2D1b == 1 // tous ceux qui devaient repondre ont répondu

//2)

count if !missing(FT2D1bM) & FT2D1b != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2D1bM, miss

count if FT2D1bM >60 & FT2D1bM !=. & FT2D1bM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT2D1bM == 60 & FT2D1bM !=. & FT2D1bM !=.a // 

*proposition de correction : 

*br interview__key membres__id FT2D1bH FT2D1bM if FT2D1bM == 60 & FT2D1bM !=. & FT2D1bM !=.a

gen FT2D1bM_ = FT2D1bM

replace FT2D1bH = FT2D1bH + 1 if FT2D1bM_ == 60 & FT2D1bM_ !=. & FT2D1bM_ !=.a

drop FT2D1bM_

replace FT2D1bM = 0 if FT2D1bM == 60

//4)

count if FT2D1bH == 0 & FT2D1bM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 


/////  FT2D1d. Avez-vous effectué des travaux ménagdans la cour ou pour entretenir la maison pour ce ménage ou pour des membres de la fa mille vivant dans d’autres ménages, comme do nner des soins aux animaux de compagn

//1) 
count if missing(FT2D1d) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT2D1d) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT2D1d M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT2D1d) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT2DH.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT2DH) & FT2D1d == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT2DH) & FT2D1d != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2DH, miss

count if FT2DH >168 & FT2DH !=. & FT2DH !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT2DM. %FT2D1aH% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT2DM) & FT2D1d == 1 // tous ceux qui devaient repondre ont répondu

//2)

count if !missing(FT2DM) & FT2D1d != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT2DM, miss

count if FT2DM >60 & FT2DM !=. & FT2DM !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT2DM == 60 & FT2DM !=. & FT2DM !=.a // 

*proposition de correction : 

*br interview__key membres__id FT2DH FT2DM if FT2DM == 60 & FT2DM !=. & FT2DM !=.a

gen FT2DM_ = FT2DM

replace FT2DH = FT2DH + 1 if FT2DM_ == 60 & FT2DM_ !=. & FT2DM_ !=.a

drop FT2DM_

replace FT2DM = 0 if FT2DM == 60

//4)

count if FT2DH == 0 & FT2DM == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 



///// FT3a. Durant la période allant du %DateJ7% au %DateJ0% , avez-vous réalisé une activité non r émunérée non obligatoire hors de votre ména ge pour produire des biens ou fournir des serv ices pour des tiers même si les charges occasio nnées (transport,nourriture,etc)

//1) 
count if missing(FT3a) & M4Confirm>=15 & M4Confirm==. & M4Confirm==.a & membre_id_v1_IND =="##N/A##" // tous ceux qui devaient répondre à la question ont répondu

//2) 

count if !missing(FT3a) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) // tous ceux qui ont répondu avaient droit de repondre

*br FT3a M4Confirm membre_id_v1 membre_id_v1_IND MODINTR if !missing(FT3a) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15)

//3) 

//4)

///// FT3a1H.Combien d’heures par semaine consacrez-vous à cette activité

//1)

count if missing(FT3a1H) & FT3a == 1 // tous ceux qui devaient répondre à la question ont répondu

//2)

count if !missing(FT3a1H) & FT3a != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT3a1H, miss

count if FT3a1H >168 & FT3a1H !=. & FT3a1H !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (168)

//4)

/// FT3a1M. %FT3a1H% Heure et Combien de minu tes par semaine consacrez-vous à cette activité ?

//1)

count if missing(FT3a1M) & FT3a == 1 // tous ceux qui devaient repondre ont répondu

//2)

count if !missing(FT3a1M) & FT3a != 1 // tous ceux qui ont répondu avaient droit de repondre

//3) 

ta FT3a1M, miss

count if FT3a1M >60 & FT3a1M !=. & FT3a1M !=.a // les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT3a1M == 60 & FT3a1M !=. & FT3a1M !=.a // 2 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 

*proposition de correction : 

*br interview__key membres__id FT3a1H FT3a1M if FT3a1M == 60 & FT3a1M !=. & FT3a1M !=.a

gen FT3a1M_ = FT3a1M

replace FT3a1H = FT3a1H + 1 if FT3a1M_ == 60 & FT3a1M_ !=. & FT3a1M_ !=.a

drop FT3a1M_

replace FT3a1M = 0 if FT3a1M == 60

//4)

count if FT3a1H == 0 & FT3a1M == 0 // pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 






ta FT1A1,miss 

count if FT1A1==.a & M4Confirm>=15 & M4Confirm!=. & MODINTR ==1  // 174 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 


** nombre d'heure par et minutes semaine consacrez à une activité de transformation : doit etre supérieure à zero 

count if M4Confirm>=15 & MODINTR ==1 & FT1H ==0 & FT1A1 == 1 & FT1M == 0 // pas de cas d'incoherence

** collecté de l'eau

ta FT1B1,miss 


count if missing(FT1B1) & M4Confirm>=15 & M4Confirm!=. & MODINTR ==1 // 837 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à la collecte d'eau : doit etre supérieure à zero

count if FT1B1 ==1 & FT1BH == 0 & FT1BM == 0 & M4Confirm>=15 & MODINTR ==1 // Pas d'incoherences

** fabrication des produits pour le ménage

ta FT1C1,miss 

count if FT1C1==.a & M4Confirm>=15 & MODINTR ==1 // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à la fabrication des produits pour le ménage : doit etre supérieure à zero

count if FT1C1 ==1 & FT1CH == 0 & FT1CM == 0 & M4Confirm>=15 & MODINTR ==1 // Pas d'incoherences

** Faire des reparations 

ta FT1D1,miss 

count if FT1D1==.a & M4Confirm>=15 & MODINTR ==1 // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire des reparations : doit etre supérieure à zero

count if FT1D1 ==1 & FT1DH == 0 & FT1DM == 0 & M4Confirm>=15 & MODINTR ==1 // Pas d'incoherences

** Faire une activité agricole  

ta FT1E1,miss 

count if FT1E1==.a & M4Confirm>=15 & MODINTR ==1 // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire une activité agricole  : doit etre supérieure à zero

count if FT1E1 ==1 & FT1E1H == 0 & FT1E1M == 0 & M4Confirm>=15 & MODINTR ==1 // Pas d'incoherences

** Faire une activité de gestion 

ta FT2A1,miss 

count if FT2A1==.a & M4Confirm>=15 & MODINTR ==1 // 5 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire une activité de gestion : doit etre supérieure à zero

count if FT2A1 ==1 & FT2AH == 0 & FT2AM == 0 & M4Confirm>=15 & MODINTR ==1 // Pas d'incoherences

** Faire des travaux ménagers (preparation)

ta FT2B1,miss 

count if FT2B1==.a & M4Confirm>=15 & MODINTR ==1 // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire des travaux ménagers : doit etre supérieure à zero

count if FT2B1 ==1 & FT2BH == 0 & FT2BM == 0 & M4Confirm>=15 & MODINTR ==1 // 

** Faire des travaux ménagers (decoration)

ta FT2C1,miss 

count if FT2C1==.a & M4Confirm>=15 & MODINTR ==1 // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire des travaux ménagers : doit etre supérieure à zero

count if FT2C1 ==1 & FT2CH == 0 & FT2CM == 0 & M4Confirm>=15 & MODINTR ==1 // pas d'incoherences

** Faire des travaux ménagers (autres menages enfant)

ta FT2D1a,miss 

count if FT2D1a==.a & M4Confirm>=15 & MODINTR ==1  // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire des travaux ménagers : doit etre supérieure à zero

count if FT2D1a ==1 & FT2D1aH == 0 & FT2D1aM == 0 & M4Confirm>=15 & MODINTR ==1 // pas d'incoherences

** Faire des travaux ménagers (autres menages, personnes agées)

ta FT2D1b,miss 

count if FT2D1b==.a & M4Confirm>=15 & MODINTR ==1 // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire des travaux ménagers : doit etre supérieure à zero

count if FT2D1b ==1 & FT2D1bH == 0 & FT2D1bM == 0 // pas d'incoherences

** Faire des travaux ménagers (autres menages,animaux)

ta FT2D1d,miss 

count if FT2D1d==.a & M4Confirm>=15 & MODINTR ==1  // 2 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas 

** nombre d'heure et minutes par semaine consacrez à Faire des travaux ménagers : doit etre supérieure à zero

count if FT2D1d ==1 & FT2DH == 0 & FT2DM == 0 // pas d'incoherences

** à fait activité non-remunerée 

ta FT3a,miss 

count if FT3a==.a & M4Confirm>=15 & MODINTR ==1 // 5 personnes pour qui la question n'a pas été repondu alors que cela devrait etre le cas

** nombre d'heure et minutes par semaine consacrez à Faire des travaux ménagers : doit etre supérieure à zero

count if FT3a ==1 & FT3a1H == 0 & FT3a1M == 0 & M4Confirm>=15 & MODINTR ==1 // pas d'incoherences




*****Saving********************

drop Statut_Res AgeAnnee HH13 MODINTR EN_EMP membre_id_v1_IND hhaa


save "$standard_individu\INDIV_S1_autres_formes_travail.dta", replace  


