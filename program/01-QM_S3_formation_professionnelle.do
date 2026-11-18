*******************************************************************************
*      VERIFICATION ET TRAITEMENT DE LA SECTION                               *
*      "FORMATION PROFESSIONNELLE ET APPRENTISSAGE"                           *
*      ENQUETE EMPLOI - VOLET MENAGE (ENEM) - T3 2026                         *
*                                                                             *
*      RESPONSABLE : DIABATE BEN ISMAEL                                       *
*                                                                             *
*      Bases  : QM_S3_formation_professionnelle.dta, QX_EEC_VF.dta,          *
*               membres.dta                                                   *
*      Sortie : $standard_menage\QM_S3_formation_professionnelle.dta          *
*      Erreurs: $folderpath/document/Err_FP*.xlsx                             *
*                                                                             *
*      Les effectifs notés en commentaire (//) sont ceux observés sur la      *
*      base T3 2026 au 06/11/2026.                                            *
*******************************************************************************

**********************LES ETAPES DE L'APUREMENT*********************************
*==============================================================================*
* Etape 1 : Valeurs manquantes : ceux qui devaient répondre ont-ils répondu ?
* Etape 2 : Vérification des sauts : des individus qui ne devaient pas répondre
*           ont-ils répondu ?
* Etape 3 : Les réponses données sont-elles celles qu'on attendait ?
* Etape 4 : Cohérence : les réponses sont-elles cohérentes avec les autres ?
* Etape 5 : Correction des erreurs identifiées
*==============================================================================*

*==============================================================================*
*  0. PREPARATION
*==============================================================================*

*--- Programme d'exportation : n'exporte que s'il y a au moins un cas
*    (évite l'erreur r(2000) de export excel quand la sélection est vide)
cap program drop export_err
program define export_err
	syntax varlist [if] , Fichier(string)
	quietly count `if'
	local n = r(N)
	if `n' > 0 {
		export excel `varlist' using "$folderpath/document/`fichier'.xlsx" `if', firstrow(varlabels) replace
		display as text "   -> `n' cas exportés dans `fichier'.xlsx"
	}
	else display as text "   -> RAS : aucun cas pour `fichier'"
end

*--- Ouverture et fusion des bases
use "$datain_standard\QM_S3_formation_professionnelle.dta", clear

merge m:1 interview__key using "$brute_menage_work", keepus(V1interviewkey rgmen HH01 HH2 HH2A HH4 HH8 HH12 HH13 rghab hh)
keep if _merge == 3
drop _merge

* NB : membre_id_v1 est déjà dans la base formation, on ne le reprend pas
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(AgeAnnee Statut_Res M6_A)
keep if _merge == 3
drop _merge
// 24 502 individus après fusion (aucune perte)

*--- Variables d'identification reprises dans tous les exports
local id interview__key membres__id M0 HH2 HH12 HH13 rgmen

*--- Variable commentaire (les commentaires s'ajoutent les uns aux autres)
cap drop commentaire
gen commentaire = ""

*--- Nouveau membre (pas d'identifiant du passage précédent)
*    FP2 à FP5 et FP7 ne sont posées qu'aux nouveaux membres
cap drop nouveau
gen nouveau = (membre_id_v1 == "##N/A##")


*==============================================================================*
*  FP1 : a-t-il/elle suivi une formation professionnelle/apprentissage ?
*  Champ : AgeAnnee >= 6 & Statut_Res == 1   -   Modalités : 1 Oui, 2 Non
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP1) & AgeAnnee >= 6 & !missing(AgeAnnee) & Statut_Res == 1
// 229 individus n'ont pas répondu

replace commentaire = commentaire + "FP1 non renseigné; " if missing(FP1) & AgeAnnee >= 6 & !missing(AgeAnnee) & Statut_Res == 1
export_err `id' FP1 AgeAnnee Statut_Res commentaire if missing(FP1) & AgeAnnee >= 6 & !missing(AgeAnnee) & Statut_Res == 1, fichier(Err_FP1_NA)

** 2. Vérification des sauts : ceux qui ont répondu devaient-ils répondre ?
count if !missing(FP1) & (AgeAnnee < 6 | missing(AgeAnnee) | Statut_Res != 1)
// RAS

** 3. Les valeurs renseignées sont-elles permises ?
count if !inrange(FP1, 1, 2) & !missing(FP1)
// RAS

** 4. Vraisemblance : formation professionnelle déclarée avant 10 ans
count if FP1 == 1 & AgeAnnee < 10
// 23 enfants de 6 à 9 ans déclarés en formation professionnelle / apprentissage

replace commentaire = commentaire + "Formation pro déclarée avant 10 ans; " if FP1 == 1 & AgeAnnee < 10
export_err `id' FP1 FP2 FP3 FP3_Aut FP6 AgeAnnee commentaire if FP1 == 1 & AgeAnnee < 10, fichier(Err_FP1_vraisemblance)


*==============================================================================*
*  FP2 : qui a principalement formé ?
*  Champ : FP1 == 1 & nouveau membre   -   Modalités : 1 à 16
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP2) & FP1 == 1 & nouveau == 1
// RAS

replace commentaire = commentaire + "FP2 non renseigné; " if missing(FP2) & FP1 == 1 & nouveau == 1
export_err `id' FP1 FP2 commentaire if missing(FP2) & FP1 == 1 & nouveau == 1, fichier(Err_FP2_NA)

** 2. Vérification des sauts
count if !missing(FP2) & (FP1 != 1 | nouveau != 1)
// RAS

** 3. Valeurs permises
count if !inrange(FP2, 1, 16) & !missing(FP2)
// RAS


*==============================================================================*
*  FP2_Aut : autre forme d'apprentissage à préciser
*  Champ : FP2 = 13 (autre apprentissage informel) ou 16 (autre fortuit)
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP2_Aut) & inlist(FP2, 13, 16)
// RAS

** 2. Vérification des sauts
count if !missing(FP2_Aut) & !inlist(FP2, 13, 16)
// RAS


*==============================================================================*
*  FP3 : métier ou filière de la formation
*  Champ : FP1 == 1 & nouveau membre   -   Modalités : 0 (autre filière) à 730
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP3) & FP1 == 1 & nouveau == 1
// RAS

replace commentaire = commentaire + "FP3 non renseigné; " if missing(FP3) & FP1 == 1 & nouveau == 1
export_err `id' FP1 FP3 commentaire if missing(FP3) & FP1 == 1 & nouveau == 1, fichier(Err_FP3_NA)

** 2. Vérification des sauts
count if !missing(FP3) & (FP1 != 1 | nouveau != 1)
// RAS

** 3. Valeurs permises
count if !inrange(FP3, 0, 730) & !missing(FP3)
// RAS


*==============================================================================*
*  FP3_Aut : autre filière à préciser   -   Champ : FP3 == 0
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP3_Aut) & FP3 == 0
// RAS

** 2. Vérification des sauts
count if !missing(FP3_Aut) & FP3 != 0
// RAS

** 4. Cohérence : "Autre filière" alors que la filière existe dans la nomenclature
// 435 individus en "Autre filière". La plupart sont des métiers artisanaux absents
// de la nomenclature (couture 113, coiffure 41, menuiserie 20, maçonnerie 17...)
// et restent en "Autre". 23 réponses correspondent exactement à un libellé existant.

cap drop FP3_Aut_maj
gen FP3_Aut_maj = ustrupper(ustrtrim(FP3_Aut))

count if FP3 == 0 & inlist(FP3_Aut_maj, "MECANIQUE", "MÉCANIQUE", "MECANIQUE AUTO", "MÉCANIQUE AUTO", "COMMERCE", "ELECTRONIQUE", "ÉLECTRONIQUE")
count if FP3 == 0 & inlist(FP3_Aut_maj, "PEINTURE", "ELEVAGE", "ÉLEVAGE", "RESSOURCES HUMAINES ET COMMUNICATION")
// 19 + 3 = 22 individus à recoder (+1 "AUTRE FILIERE" qui reste en 0)

*--- Correction : recodage dans la nomenclature
replace FP3 = 500 if FP3 == 0 & inlist(FP3_Aut_maj, "MECANIQUE", "MÉCANIQUE")
replace FP3 = 501 if FP3 == 0 & inlist(FP3_Aut_maj, "MECANIQUE AUTO", "MÉCANIQUE AUTO")
replace FP3 = 145 if FP3 == 0 & FP3_Aut_maj == "COMMERCE"
replace FP3 = 237 if FP3 == 0 & inlist(FP3_Aut_maj, "ELECTRONIQUE", "ÉLECTRONIQUE")
replace FP3 = 556 if FP3 == 0 & FP3_Aut_maj == "PEINTURE"
replace FP3 = 246 if FP3 == 0 & inlist(FP3_Aut_maj, "ELEVAGE", "ÉLEVAGE")
replace FP3 = 603 if FP3 == 0 & FP3_Aut_maj == "RESSOURCES HUMAINES ET COMMUNICATION"

* La précision n'a plus lieu d'être pour les individus recodés
replace FP3_Aut = "" if FP3 != 0

drop FP3_Aut_maj


*==============================================================================*
*  FP4 : durée de la formation   -   FP4A : unité (1 Mois, 2 Année)
*  Champ : FP1 == 1 & nouveau membre
*  Règles du questionnaire : saisir 9 si la durée dépasse 9 ans ;
*                            saisir en années au-delà de 12 mois
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP4) & FP1 == 1 & nouveau == 1
// RAS
count if missing(FP4A) & FP1 == 1 & nouveau == 1
// RAS
count if missing(FP4A) & !missing(FP4)
// RAS

replace commentaire = commentaire + "FP4/FP4A non renseigné; " if (missing(FP4) | missing(FP4A)) & FP1 == 1 & nouveau == 1
export_err `id' FP1 FP4 FP4A commentaire if (missing(FP4) | missing(FP4A)) & FP1 == 1 & nouveau == 1, fichier(Err_FP4_NA)

** 2. Vérification des sauts
count if !missing(FP4) & (FP1 != 1 | nouveau != 1)
// RAS
count if !missing(FP4A) & (FP1 != 1 | nouveau != 1)
// RAS

** 3. Valeurs permises
count if !inlist(FP4A, 1, 2) & !missing(FP4A)
// RAS

count if FP4 <= 0 & !missing(FP4)
// 3 individus avec une durée nulle (exportés, pas corrigés)

replace commentaire = commentaire + "Durée de formation nulle; " if FP4 <= 0 & !missing(FP4)
export_err `id' FP1 FP3 FP3_Aut FP4 FP4A FP6 AgeAnnee commentaire if FP4 <= 0 & !missing(FP4), fichier(Err_FP4_nulle)

count if FP4 >= 10 & FP4A == 2 & !missing(FP4)
// 4 individus avec 10 ans ou plus (dont une saisie de 2002 ans) alors que
// le questionnaire demande de saisir 9 au-delà de 9 ans

count if FP4 > 12 & FP4A == 1 & !missing(FP4)
// RAS

count if FP4 == 12 & FP4A == 1
// 2 individus avec 12 mois

*--- Correction :
replace FP4 = 9 if FP4 >= 10 & FP4A == 2 & !missing(FP4)

// 12 mois = 1 an
replace FP4A = 2 if FP4 == 12 & FP4A == 1
replace FP4  = 1 if FP4 == 12 & FP4A == 2

// Durée en mois > 12 : conversion en années (aucun cas au T3, conservé pour les autres trimestres)
replace FP4  = min(9, round(FP4 / 12)) if FP4 > 12 & FP4A == 1 & !missing(FP4)
replace FP4A = 2 if FP4 > 0 & FP4 <= 9 & FP4A == 1 & FP4 != . & FP4 < 1

** 4. Cohérence : durée de formation et âge
// La durée de formation ne doit pas dépasser l'âge moins 5 ans
cap drop duree_an
gen duree_an = cond(FP4A == 2, FP4, FP4 / 12) if !missing(FP4, FP4A)

count if duree_an > AgeAnnee - 5 & !missing(duree_an, AgeAnnee)
// 7 individus (exportés, pas corrigés)

replace commentaire = commentaire + "Durée de formation incompatible avec l'âge; " if duree_an > AgeAnnee - 5 & !missing(duree_an, AgeAnnee)
export_err `id' FP1 FP3 FP3_Aut FP4 FP4A FP6 AgeAnnee commentaire if duree_an > AgeAnnee - 5 & !missing(duree_an, AgeAnnee), fichier(Err_FP4_age)

drop duree_an


*==============================================================================*
*  FP5 : méthode de formation (1 simple/pratique, 2 duale théorie+pratique)
*  Champ : FP1 == 1 & nouveau membre
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP5) & FP1 == 1 & nouveau == 1
// RAS

replace commentaire = commentaire + "FP5 non renseigné; " if missing(FP5) & FP1 == 1 & nouveau == 1
export_err `id' FP1 FP5 commentaire if missing(FP5) & FP1 == 1 & nouveau == 1, fichier(Err_FP5_NA)

** 2. Vérification des sauts
count if !missing(FP5) & (FP1 != 1 | nouveau != 1)
// RAS

** 3. Valeurs permises
count if !inrange(FP5, 1, 2) & !missing(FP5)
// RAS


*==============================================================================*
*  FP6 : formation en cours ou achevée ?
*  Champ : FP1 == 1 (tous les membres, anciens et nouveaux)
*  Modalités : 1 inachevée, 2 en cours, 3 achevée et complète
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP6) & FP1 == 1
// RAS

replace commentaire = commentaire + "FP6 non renseigné; " if missing(FP6) & FP1 == 1
export_err `id' FP1 FP6 commentaire if missing(FP6) & FP1 == 1, fichier(Err_FP6_NA)

** 2. Vérification des sauts
count if !missing(FP6) & FP1 != 1
// RAS

** 3. Valeurs permises
count if !inrange(FP6, 1, 3) & !missing(FP6)
// RAS


*==============================================================================*
*  FP7 : mode de formation (1 présentiel, 2 à distance, 3 les deux)
*  Champ : FP1 == 1 & nouveau membre
*==============================================================================*

** 1. Valeurs manquantes
count if missing(FP7) & FP1 == 1 & nouveau == 1
// RAS

replace commentaire = commentaire + "FP7 non renseigné; " if missing(FP7) & FP1 == 1 & nouveau == 1
export_err `id' FP1 FP7 commentaire if missing(FP7) & FP1 == 1 & nouveau == 1, fichier(Err_FP7_NA)

** 2. Vérification des sauts
count if !missing(FP7) & (FP1 != 1 | nouveau != 1)
// RAS

** 3. Valeurs permises
count if !inrange(FP7, 1, 3) & !missing(FP7)
// RAS


********************* SAUVEGARDE DE LA BASE DE DONNEES APUREE ******************

drop nouveau commentaire
drop HH01 HH2 HH2A HH4 HH8 HH12 HH13 rghab rgmen hh V1interviewkey
drop AgeAnnee Statut_Res M6_A

save "$standard_menage\QM_S3_formation_professionnelle.dta", replace
