
*================================================
*********AUTRE FORMES DE TRAVAIL

****RESPONSABLE: KOUADIO BROU YVES
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

gen commentaire =""
**************Fin appel de variables*****************


/********************* Control de la section variable par variable suivant les 4 points d'actions

1) Control des valeurs manquantes : Tous ceux qui devrait repondre on bel et bien répondu
2) Control de l'effectivement des sauts : seules ceux qui ont le droit de repondre ont répondu
3) Les valeurs renseignées sont dans le champs de définition de la variable
4) Les valeurs renseignées sont vraissembables
**************************************/

*=============================================================================
*FT1A1. Avez-vous rassemblé et/ou transformé, en vue du stockage, les produits de la mine ou forêt, y compris le bois à brûler et autres combustibles pour la consommation de votre ménage ?
*=============================================================================

* Probleme 1: Valeurs manquantes 
count if missing(FT1A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
// 13 non réponse
br if missing(FT1A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT1A1" if missing(FT1A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT1A1 using "$folderpath/document/Erreur_FT1A1_NA" if missing(FT1A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace


* Probleme 2: Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT1A1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) 
//RAS

* 3. Valeurs légales
count if !inlist(FT1A1,1,2) & !missing(FT1A1) //RAS

*=============================================================================
*FT1H. Combien d’heures par semaine consacrez-vous à cette activité ?
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT1H) & FT1A1 == 1 


* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1H) & FT1A1 != 1 
//RAS

* 3. Valeurs légales 
count if !missing(FT1H) & FT1A1 == 1 & FT1H <=0 & FT1H > 168 & FT1H != .
//RAS

*=============================================================================
*FT1M. %FT1H% Heure(s) et Combien de minute
*=============================================================================
//la question demande le nombre de minute par semaine consacré à l'activité par semaine. or les condition des cohérences se font sur le nombre de minute par heure accordé à l'activité. 

* 1. Valeurs manquantes
count if missing(FT1M) & FT1A1 == 1 

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1M) & FT1A1 != 1 
// RAS

* 3. Valeurs légales 
count if FT1M >=60 & FT1M !=. & FT1M !=.a 
br if FT1M >=60 & FT1M !=. & FT1M !=.a 

//1 cas de 180min revient au 3h declarer dans FT1H. ici le nombre de minute correspond exactement au nombre d'heure travaillé, on peut donc considerer que l'individu travaille 3h plein.

*Correction
replace FT1M = 00 if FT1M >60 & FT1M !=. & FT1M !=.a 

//toutes les minutes >= 60min, nous allons les ramener en heure.
 
br interview__key membres__id FT1H FT1M if FT1M ==60 & FT1M !=. & FT1M !=.a

cap drop FT1M_
gen FT1M_ = FT1M
replace FT1H = FT1H + 1 if FT1M_ ==60 & FT1M_ !=. & FT1M_ !=.a
drop FT1M_
replace FT1M = 0 if FT1M == 60

*4. Cohérence

count if FT1H == 0 & FT1M == 0 
// RAS. Pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas 
 
*=============================================================================
*FT1B1. Avez-vous collecté de l’eau de sources naturelles ou autres pour la consommation de votre ménage
*============================================================================= 
* 1. Valeurs manquantes 
count if missing(FT1B1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"
//13 non-réponse

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT1B1" if missing(FT1B1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT1B1 using "$folderpath/document/Erreur_FT1B1_NA" if missing(FT1B1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT1B1) & (M4Confirm <15 | missing(M4Confirm) | membre_id_v1_IND !="##N/A##")
// RAS, tous ceux qui ont répondu avaient droit de repondre.

* 3. Valeurs légales
count if !inlist(FT1B1,1,2) & !missing(FT1B1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"
// RAS

*=============================================================================
*FT1BH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT1BH) & FT1B1 == 1 
// RAS. tous ceux qui devaient répondre à la question ont répondu


* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1BH) & FT1B1 != 1 
//RAS

* 3. Valeurs légales 
ta FT1BH, miss
count if !missing(FT1BH) & FT1B1 == 1 & FT1BH <=0 & FT1BH > 168 & FT1BH != .
//RAS

*=============================================================================
* FT1BM.%FT1BH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ?
*============================================================================= 

* 1. Valeurs manquantes
count if missing(FT1BM) & FT1B1 == 1 
// RAS. tous ceux qui devaient répondre à la question ont répondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1BM) & FT1B1 != 1 
//RAS

* 3. Valeurs légales 
ta FT1BM, miss
count if FT1BM >60 & !missing(FT1BM)
//RAS

count if FT1BM == 60 & !missing(FT1BM) 
// 51 valeurs sont égales à 60. ce qui est inconsistent.   Les valeurs égales à 60 minutes doivent etre convertir directement en une heure. 


*correction : 
gen FT1BM_ = FT1BM
replace FT1BH = FT1BH + 1 if FT1BM_ ==60 & FT1BM_ !=. & FT1BM_ !=.a
drop FT1BM_
replace FT1BM = 0 if FT1BM == 60

*4. Cohérence
count if FT1BH == 0 & FT1BM == 0 
// pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas

*============================================================================= 
*FT1C1. Avez-vous fabriqué des produits pour le ménage (meubles, textiles, habillement et chau ssures, poterie ou autres produits durables, y c ompris les bateaux et canoë) pour votre ména ge ?
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT1C1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
// 13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT1C1" if missing(FT1C1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT1C1 using "$folderpath/document/Erreur_FT1C1_NA" if missing(FT1C1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace


* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT1C1) & ((membre_id_v1_IND !="##N/A##" & membre_id_v1_IND != "")| M4Confirm<15) 
// RAS


* 3. Valeurs légales 
count if !inlist(FT1C1,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT1C1)
//RAS

*============================================================================= 
*FT1CH.Combien d’heures par semaine consacrez-vous à cette activité ?
*============================================================================= 

* 1. Valeurs manquantes
count if missing(FT1CH) & FT1C1 == 1 
// RAS. tous ceux qui devaient répondre à la question ont répondu


* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1CH) & FT1C1 != 1 
//RAS

* 3. Valeurs légales 
ta FT1CH, miss
count if FT1CH >60 & !missing(FT1CH)
//RAS

*=============================================================================
* FT1CM.%FT1CH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ?
*============================================================================= 

* 1. Valeurs manquantes
count if missing(FT1CM) & FT1C1 == 1 
// RAS. tous ceux qui devaient répondre ont répondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1CM) & FT1C1 != 1 
//RAS. tous ceux qui ont répondu avaient droit de repondre

* 3. Valeurs légales 
ta FT1CM, miss
count if FT1CM >60 & !missing(FT1CM) 
// les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT1CM == 60 & FT1CM !=. & FT1CM !=.a
br if FT1CM == 60 & FT1CM !=. & FT1CM !=.a 

// 1 valeurs en minutes sont égales à 60. ce qui est consistent.   
*proposition de correction : 
gen FT1CM_ = FT1CM
replace FT1CH = FT1CH + 1 if FT1CM_ ==60 & FT1CM_ !=. & FT1CM_ !=.a
drop FT1CM_
replace FT1CM = 0 if FT1CM == 60

*4. Cohérence
count if FT1CH == 0 & FT1CM == 0 
// pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas

*=============================================================================
*FT1D1. Avez-vous construit ou fait des réparations majeures d’habitation ou ferme appartenant à votre ménage
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT1D1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
// 13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT1D1" if missing(FT1D1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT1D1 using "$folderpath/document/Erreur_FT1D1_NA" if missing(FT1D1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace


* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT1D1) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS. tous ceux qui ont répondu avaient droit de repondre

* 3. Valeurs légales 
count if !inlist(FT1D1,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT1D1)
//RAS

*=============================================================================
* FT1DH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT1DH) & FT1D1 == 1 
//RAS. tous ceux qui devaient répondre à la question ont répondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1DH) & FT1D1 != 1 
//RAS. tous ceux qui ont répondu avaient droit de repondre

* 3. Valeurs légales 
ta FT1DH, miss
count if FT1DH >60 & !missing(FT1DH) 
//RAS. les valeurs renseignées semblent consistantes car inferieures au nombre total d'heures dans la semaine (60)

*=============================================================================
* FT1DM.%FT1DH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT1DM) & FT1D1 == 1 
//RAS. tous ceux qui devaient repondre ont répondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1DM) & FT1D1 != 1 
//RAS. tous ceux qui ont répondu avaient droit de repondre

* 3. Valeurs légales 
ta FT1DM, miss
count if FT1DM >60 & !missing(FT1DM)  
// les valeurs renseignées semblent consistantes car inferieures au nombre total de minute dans une heure (60)

count if FT1DM == 60 & !missing(FT1DM) 
// RAS   

**correction 
replace FT1DH = FT1DH + 1 if FT1DM == 60 & FT1DM !=. & FT1DM !=.a
replace FT1DM = 0 if FT1DM == 60 & FT1DM !=. & FT1DM !=.a

*4. Cohérence
count if FT1DH == 0 & FT1DM == 0 
//RAS pour les personnes ayant mentionnés zero heure, le nombre de minutes doit etre supérieure à zero, ce qui est bien le cas. 


*=============================================================================
*FT1E1. Avez-vous fait des activités agricoles, d’élevage, de pêche, ou de chasse dont la destination principale de cette production est pour la consommation de votre ménage ?
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT1E1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
// 13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT1E1" if missing(FT1E1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT1E1 using "$folderpath/document/Erreur_FT1E1_NA" if missing(FT1E1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT1E1) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS

* 3. Valeurs légales 
count if !inlist(FT1E1,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT1E1)
//RAS

*=============================================================================
* FT1E1H.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT1E1H) & FT1E1 == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1E1H) & FT1E1 != 1 
//RAS

* 3. Valeurs légales 
ta FT1E1H, miss
count if FT1E1H >60 & !missing(FT1E1H) 
//RAS

*=============================================================================
* FT1E1M.%FT1E1H% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT1E1M) & FT1E1 == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT1E1M) & FT1E1 != 1 
//RAS

* 3. Valeurs légales 
ta FT1E1M, miss
count if FT1E1M >60 & !missing(FT1E1M) 
//RAS 

count if FT1E1M == 60 & !missing(FT1E1M)
//61 observations 

*correction 
replace FT1E1H = FT1E1H + 1 if FT1E1M == 60 & FT1E1M !=. & FT1E1M !=.a
replace FT1E1M = 0 if FT1E1M == 60 & FT1E1M !=. & FT1E1M !=.a

*4. Cohérence
count if FT1E1H == 0 & FT1E1M == 0 
//RAS


*=============================================================================
*FT2A1. Avez-vous effectué des activités de gestion (comptabilité, achat et/ou transport de biens) pour la consommation du ménage ?
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT2A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
//13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT2A1" if missing(FT2A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT2A1 using "$folderpath/document/Erreur_FT2A1_NA" if missing(FT2A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT2A1) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS

* 3. Valeurs légales 
count if !inlist(FT2A1,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT2A1)
//RAS

*=============================================================================
* FT2AH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2AH) & FT2A1 == 1
//RAS 

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2AH) & FT2A1 != 1 
//RAS

* 3. Valeurs légales 
ta FT2AH, miss
count if FT2AH >60 & !missing(FT2AH) 
//RAS

*=============================================================================
* FT2AM.%FT2AH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2AM) & FT2A1 == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2AM) & FT2A1 != 1 
//RAS

* 3. Valeurs légales 
ta FT2AM, miss
count if FT2AM >60 & !missing(FT2AM)  
//RAS

count if FT2AM == 60 & !missing(FT2AM) 
//RAS

**correction 
replace FT2AH = FT2AH + 1 if FT2AM == 60 & FT2AM !=. & FT2AM !=.a
replace FT2AM = 0 if FT2AM == 60 & FT2AM !=. & FT2AM !=.a

*4. Cohérence
count if FT2AH == 0 & FT2AM == 0 
//RAS


*=============================================================================
*FT2B1. Avez-vous effectué des travaux ménagers, dans la cour ou pour entretenir la maison pour ce ménage ou pour des membres de la famille vivant dans d’autres ménages, comme lapréparation et le service des repas,…
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT2B1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
//13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT2B1" if missing(FT2B1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT2B1 using "$folderpath/document/Erreur_FT2B1_NA" if missing(FT2B1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT2B1) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS

* 3. Valeurs légales 
count if !inlist(FT2B1,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT2B1)
//RAS

*=============================================================================
* FT2BH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2BH) & FT2B1 == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2BH) & FT2B1 != 1 
//RAS

* 3. Valeurs légales 
count if FT2BH >60 & !missing(FT2BH) 
//RAS

*=============================================================================
* FT2BM.%FT2BH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2BM) & FT2B1 == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2BM) & FT2B1 != 1 
//RAS

* 3. Valeurs légales 
count if FT2BM >60 & !missing(FT2BM) 
//RAS 

count if FT2BM == 60 & !missing(FT2BM) 
//31 observations pour lesquelles on a 60 minutes. On doit les convertir en heure

*correction 
replace FT2BH = FT2BH + 1 if FT2BM == 60 & FT2BM !=. & FT2BM !=.a
replace FT2BM = 0 if FT2BM == 60 & FT2BM !=. & FT2BM !=.a

*4. Cohérence
count if FT2BH == 0 & FT2BM == 0 
//RAS


*=============================================================================
*FT2C1. Avez-vous effectué des travaux ménagers, dans la cour ou pour entretenir la maison pour ce ménage ou pour des membres de la famille vivant dans d’autres ménages, comme le nettoyage, la décoration, le jardinage,
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT2C1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT1A1" if missing(FT1A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT1A1 using "$folderpath/document/Erreur_FT1A1_NA" if missing(FT1A1) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT2C1) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 


* 3. Valeurs légales 
count if !inlist(FT2C1,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT2C1)
//RAS

*=============================================================================
* FT2CH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2CH) & FT2C1 == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2CH) & FT2C1 != 1 
//RAS

* 3. Valeurs légales 
ta FT2CH, miss
count if FT2CH >60 & !missing(FT2CH) 
//RAS

*=============================================================================
* FT2CM.%FT2CH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2CM) & FT2C1 == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2CM) & FT2C1 != 1 
//RAS

* 3. Valeurs légales 
count if FT2CM >60 & !missing(FT2CM) 
//RAS 

count if FT2CM == 60 & !missing(FT2CM) 
//30 observations

**correction 
replace FT2CH = FT2CH + 1 if FT2CM == 60 & FT2CM !=. & FT2CM !=.a
replace FT2CM = 0 if FT2CM == 60 & FT2CM !=. & FT2CM !=.a

*4. Cohérence
count if FT2CH == 0 & FT2CM == 0 
//RAS


*=============================================================================
*FT2D1a. Avez-vous effectué des travaux ménagers, dans la cour ou pour entretenir la maisonpour ce ménage ou pour des membres de la famille vivant dans d’autres ménages, comme donner des soins et instruction aux enfants ?
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT2D1a) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
//13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT2D1a" if missing(FT2D1a) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT2D1a using "$folderpath/document/Erreur_FT2D1a_NA" if missing(FT2D1a) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT2D1a) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS

* 3. Valeurs légales 
count if !inlist(FT2D1a,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT2D1a)
//RAS

*=============================================================================
* FT2D1aH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2D1aH) & FT2D1a == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2D1aH) & FT2D1a != 1 
//RAS

* 3. Valeurs légales 
ta FT2D1aH, miss
count if FT2D1aH >60 & !missing(FT2D1aH) 
//RAS

*=============================================================================
* FT2D1aM.%FT2D1aH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2D1aM) & FT2D1a == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2D1aM) & FT2D1a != 1 
//RAS

* 3. Valeurs légales 
count if FT2D1aM >60 & !missing(FT2D1aM)  
//RAS

count if FT2D1aM == 60 & !missing(FT2D1aM) 
//22 observations

**correction 
replace FT2D1aH = FT2D1aH + 1 if FT2D1aM == 60 & FT2D1aM !=. & FT2D1aM !=.a
replace FT2D1aM = 0 if FT2D1aM == 60 & FT2D1aM !=. & FT2D1aM !=.a

*4. Cohérence
count if FT2D1aH == 0 & FT2D1aM == 0 
//RAS


*=============================================================================
*FT2D1b. Avez-vous effectué des travaux ménagers, dans la cour ou pour entretenir la maison pour ce ménage ou pour des membres de la famille vivant dans d’autres ménages, comme transporter et donner des soins aux membres âgés,
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT2D1b) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
//13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT2D1b" if missing(FT2D1b) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT2D1b using "$folderpath/document/Erreur_FT2D1b_NA" if missing(FT2D1b) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT2D1b) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS

* 3. Valeurs légales 
count if !inlist(FT2D1b,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT2D1b)
//RAS

*=============================================================================
* FT2D1bH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2D1bH) & FT2D1b == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2D1bH) & FT2D1b != 1
//RAS 

* 3. Valeurs légales 
count if FT2D1bH >60 & !missing(FT2D1bH) 
//RAS

*=============================================================================
* FT2D1bM.%FT2D1bH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2D1bM) & FT2D1b == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2D1bM) & FT2D1b != 1 
//RAS

* 3. Valeurs légales 
count if FT2D1bM >60 & !missing(FT2D1bM)  
//RAS

count if FT2D1bM == 60 & !missing(FT2D1bM) 
// 10 observation

**correction 
replace FT2D1bH = FT2D1bH + 1 if FT2D1bM == 60 & FT2D1bM !=. & FT2D1bM !=.a
replace FT2D1bM = 0 if FT2D1bM == 60 & FT2D1bM !=. & FT2D1bM !=.a

*4. Cohérence
count if FT2D1bH == 0 & FT2D1bM == 0 
//RAS


*=============================================================================
*FT2D1d. Avez-vous effectué des travaux ménagers, dans la cour ou pour entretenir la maisonpour ce ménage ou pour des membres de la famille vivant dans d’autres ménages, comme donner des soins aux animaux de compagnie ?
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT2D1d) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
//13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT2D1d" if missing(FT2D1d) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT2D1d using "$folderpath/document/Erreur_FT2D1d_NA" if missing(FT2D1d) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT2D1d) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS

* 3. Valeurs légales 
count if !inlist(FT2D1d,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT2D1d)
//RAS

*=============================================================================
* FT2DH.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2DH) & FT2D1d == 1 


* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2DH) & FT2D1d != 1 
//RAS

* 3. Valeurs légales 
count if FT2DH >60 & !missing(FT2DH) 
//RAS

*=============================================================================
* FT2DM.%FT2D1dH% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT2DM) & FT2D1d == 1

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT2DM) & FT2D1d != 1 
//RAS

* 3. Valeurs légales 
count if FT2DM >60 & !missing(FT2DM)  
//RAS

count if FT2DM == 60 & !missing(FT2DM) 
//RAS

**correction 
replace FT2DH = FT2DH + 1 if FT2DM == 60 & FT2DM !=. & FT2DM !=.a
replace FT2DM = 0 if FT2DM == 60 & FT2DM !=. & FT2DM !=.a

*4. Cohérence
count if FT2DH == 0 & FT2DM == 0 
//RAS


*=============================================================================
*FT3a. Durant la période allant du %DateJ7% au %DateJ0% , avez-vous réalisé une activité non rémunérée non obligatoire hors de votre ménage pour produire des biens ou fournir des services pour des tiers même si les charges occasionnées (transport, nourriture, etc.) vous sont remboursées ?
*============================================================================= 

* 1. Valeurs manquantes 
count if missing(FT3a) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" 
//13 non-réponses

replace commentaire="Il y a 13 individus qui n'ont pas repondus à la question FT3a" if missing(FT3a) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##"

*Exportation des observations pour lesquelles la variable L1 n'a pas été renseignée 
export excel interview__key HH13 FT3a using "$folderpath/document/Erreur_FT3a_NA" if missing(FT3a) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##", firstrow(varlabels) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre 
count if !missing(FT3a) & (membre_id_v1_IND !="##N/A##"| missing(M4Confirm)| M4Confirm<15) 
//RAS

* 3. Valeurs légales 
count if !inlist(FT3a,1,2) & M4Confirm>=15 & !missing(M4Confirm) & membre_id_v1_IND =="##N/A##" & !missing(FT3a)
//RAS

*=============================================================================
* FT3a1H.Combien d’heures par semaine consacrez-vous à cette activité
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT3a1H) & FT3a == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT3a1H) & FT3a != 1 
//RAS

* 3. Valeurs légales 
count if FT3a1H >60 & !missing(FT3a1H) 
//RAS

*=============================================================================
* FT3a1M.%FT3a1H% Heure et Combien de minutes par semaine consacrez-vous à cette activité ? 
*=============================================================================

* 1. Valeurs manquantes
count if missing(FT3a1M) & FT3a == 1 
//RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(FT3a1M) & FT3a != 1 
//RAS

* 3. Valeurs légales 
count if FT3a1M >60 & !missing(FT3a1M)  
//RAS

count if FT3a1M == 60 & !missing(FT3a1M) 
//RAS

**correction 
replace FT3a1H = FT3a1H + 1 if FT3a1M == 60 & FT3a1M !=. & FT3a1M !=.a
replace FT3a1M = 0 if FT3a1M == 60 & FT3a1M !=. & FT3a1M !=.a

*4. Cohérence
count if FT3a1H == 0 & FT3a1M == 0 
//RAS


*****Saving********************

drop Statut_Res AgeAnnee HH13 MODINTR EN_EMP membre_id_v1_IND hhaa


save "$standard_individu\INDIV_S1_autres_formes_travail.dta", replace  


