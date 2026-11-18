*******************************************************************************
*      VERIFICATION ET TRAITEMENT DE LA SECTION "EDUCATION ET FORMATION"      *
*      ENQUETE EMPLOI - VOLET MENAGE (ENEM) - T3 2026                         *
*                                                                             *
*      RESPONSABLE : DIABATE BEN ISMAEL                                       *
*                                                                             *
*      Bases  : QM_S2_education_formation.dta, QX_EEC_VF.dta, membres.dta    *
*      Sortie : $standard_menage\QM_S2_education_formation.dta                *
*      Erreurs: $folderpath/document/Erreur_*.xlsx                            *
*                                                                             *
*      Les effectifs notés en commentaire (//) sont ceux observés sur la      *
*      base T3 2026 au 06/11/2026.                                            *
*******************************************************************************

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

*--- Année de l'enquête (borne supérieure des années d'obtention de diplôme)
local annee_enq = 2026

*--- Ouverture et fusion des bases
use "$datain_standard\QM_S2_education_formation.dta", clear

merge m:1 interview__key using "$brute_menage_work", keepus(V1interviewkey rgmen HH01 HH2 HH2A HH4 HH8 HH12 HH13 rghab hh)
keep if _merge == 3
drop _merge

* NB : membre_id_v1 est déjà dans la base éducation, on ne le reprend pas
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(AgeAnnee Statut_Res M5 M6_A M7 M4Confirm)
keep if _merge == 3
drop _merge
// 24 502 individus après fusion (aucune perte)

*--- Variables d'identification reprises dans tous les exports
local id interview__key membres__id M0 HH2 HH12 HH13 rgmen

*--- Variable commentaire (les commentaires s'ajoutent les uns aux autres)
cap drop commentaire
gen commentaire = ""

*--- Nouveau membre (pas d'identifiant du passage précédent)
cap drop nouveau
gen nouveau = (membre_id_v1 == "##N/A##")

*--- Contrôle préalable de l'âge
count if (AgeAnnee < 0 | AgeAnnee > 120) & !missing(AgeAnnee)
// 3 individus avec un âge aberrant (-9998 et 1993) : à revoir dans la section membres
export_err `id' AgeAnnee M6_A M7 Statut_Res if (AgeAnnee < 0 | AgeAnnee > 120) & !missing(AgeAnnee), fichier(Erreur_Age_aberrant)


*==============================================================================*
*  EF1 : a-t-il/elle déjà fréquenté une école ?
*  Champ : AgeAnnee >= 3 & Statut_Res == 1
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF1) & AgeAnnee >= 3 & !missing(AgeAnnee) & Statut_Res == 1
// 216 individus pour qui la variable n'a pas été renseignée

replace commentaire = commentaire + "EF1 non renseigné; " if missing(EF1) & AgeAnnee >= 3 & !missing(AgeAnnee) & Statut_Res == 1
export_err `id' EF1 AgeAnnee Statut_Res commentaire if missing(EF1) & AgeAnnee >= 3 & !missing(AgeAnnee) & Statut_Res == 1, fichier(Erreur_EF1_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF1) & (AgeAnnee < 3 | missing(AgeAnnee) | Statut_Res != 1)
// RAS

** Problème 3 : valeurs s'écartant des valeurs prévues
count if !inlist(EF1, 1, 2) & !missing(EF1)
// RAS


*==============================================================================*
*  EF2 : type d'école fréquentée pour la dernière fois
*  Champ : EF1 == 1 & nouveau membre
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF2) & EF1 == 1 & nouveau == 1
// RAS

replace commentaire = commentaire + "EF2 non renseigné; " if missing(EF2) & EF1 == 1 & nouveau == 1
export_err `id' EF1 EF2 AgeAnnee membre_id_v1 commentaire if missing(EF2) & EF1 == 1 & nouveau == 1, fichier(Erreur_EF2_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF2) & (EF1 != 1 | nouveau != 1)
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF2, 1, 4) & !missing(EF2)
// RAS


*==============================================================================*
*  EF3 : plus haut niveau d'études atteint
*  Champ : EF1 == 1   -   Modalités : 0 (aucun niveau) à 12 (post doctorat)
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF3) & EF1 == 1
// 3 individus

replace commentaire = commentaire + "EF3 non renseigné; " if missing(EF3) & EF1 == 1
export_err `id' EF1 EF3 AgeAnnee Statut_Res commentaire if missing(EF3) & EF1 == 1, fichier(Erreur_EF3_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF3) & EF1 != 1
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF3, 0, 12) & !missing(EF3)
// RAS

** Problème 4 : cohérence EF1 / EF3 (a fréquenté l'école mais "Aucun niveau")
count if EF3 == 0 & EF1 == 1
// 10 individus : à vérifier sur le terrain (EF4 n'est pas renseigné pour eux)

replace commentaire = commentaire + "EF1=Oui mais EF3=Aucun niveau; " if EF3 == 0 & EF1 == 1
export_err `id' EF1 EF3 EF4 AgeAnnee commentaire if EF3 == 0 & EF1 == 1, fichier(Erreur_EF3_aucun_niveau)

** Problème 5 : vraisemblance âge / niveau
count if inrange(EF3, 3, 12) & AgeAnnee < 10 & !missing(AgeAnnee)
// 30 enfants de moins de 10 ans déclarés au moins au secondaire. Ce n'est pas normal.

replace commentaire = commentaire + "Moins de 10 ans au secondaire ou plus (EF3); " if inrange(EF3, 3, 12) & AgeAnnee < 10 & !missing(AgeAnnee)
export_err `id' EF1 EF3 EF4 EF4_1 AgeAnnee commentaire if inrange(EF3, 3, 12) & AgeAnnee < 10 & !missing(AgeAnnee), fichier(Erreur_EF3_vraisemblance)

count if inrange(EF3, 7, 12) & AgeAnnee < 15 & !missing(AgeAnnee)
// RAS (aucun enfant de moins de 15 ans au supérieur)

*--- Correction :
// Les enfants de moins de 10 ans déclarés au secondaire ou plus sont ramenés au
// primaire, sans diplôme. La classe achevée est fixée selon l'âge théorique
// (entrée au CP1 à 6 ans) : 3-6 ans -> aucune classe ; 7 ans -> CP1 ; 8 ans -> CP2 ; 9 ans -> CE1

cap drop corr_EF3_age
gen corr_EF3_age = (inrange(EF3, 3, 12) & AgeAnnee < 10 & !missing(AgeAnnee) & EF1 == 1)

replace EF3   = 2 if corr_EF3_age == 1
replace EF4   = 0 if corr_EF3_age == 1 & inrange(AgeAnnee, 3, 6)
replace EF4   = 4 if corr_EF3_age == 1 & AgeAnnee == 7
replace EF4   = 5 if corr_EF3_age == 1 & AgeAnnee == 8
replace EF4   = 6 if corr_EF3_age == 1 & AgeAnnee == 9
replace EF4_1 = 0 if corr_EF3_age == 1
// Les variables EF4_3a, EF4_3, EF4_3_AUT et EF4_4 sont vidées dans la partie
// "Nettoyage des filtres" en fin de programme

drop corr_EF3_age


*==============================================================================*
*  EF4 : classe la plus élevée achevée avec succès
*  Champ : EF1 == 1 & EF3 renseigné & EF3 != 0   -   Modalités : 0 à 22
*  (0 Aucune classe, 1-3 préscolaire, 4 CP1 ... 9 CM2, 10 6ème ... 13 3ème,
*   14 2nde, 15 1ère, 16 Tle, 17 BAC+1, 18 BAC+2, 19 BAC+3, 20 BAC+4,
*   21 BAC+5, 22 Doctorat ou plus)
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF4) & EF1 == 1 & !missing(EF3) & EF3 != 0
// 5 individus

replace commentaire = commentaire + "EF4 non renseigné; " if missing(EF4) & EF1 == 1 & !missing(EF3) & EF3 != 0
export_err `id' EF1 EF3 EF4 AgeAnnee commentaire if missing(EF4) & EF1 == 1 & !missing(EF3) & EF3 != 0, fichier(Erreur_EF4_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF4) & (EF1 != 1 | missing(EF3) | EF3 == 0)
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF4, 0, 22) & !missing(EF4)
// RAS

** Problème 4 : cohérence entre le niveau (EF3) et la classe achevée (EF4)
// Bornes admises (classe achevée = classe du niveau, ou dernière classe du niveau précédent) :
//  EF3=1 Préscolaire        : 0-3      EF3=2 Primaire              : 0-9
//  EF3=3/4 Secondaire I     : 9-13     EF3=5/6 Secondaire II       : 13-16
//  EF3=7 Supérieur court    : 16-18    EF3=8 Licence               : 16-19
//  EF3=9 Master 1           : 18-20    EF3=10 Master 2/DEA/DESS    : 18-21
//  EF3=11/12 Doctorat/Post  : 20-22

cap drop EF4_min EF4_max
recode EF3 (1 2 = 0) (3 4 = 9) (5 6 = 13) (7 8 = 16) (9 10 = 18) (11 12 = 20) (else = .), gen(EF4_min)
recode EF3 (1 = 3) (2 = 9) (3 4 = 13) (5 6 = 16) (7 = 18) (8 = 19) (9 = 20) (10 = 21) (11 12 = 22) (else = .), gen(EF4_max)

count if !inrange(EF4, EF4_min, EF4_max) & !missing(EF4, EF4_min)
// 19 incohérences : 12 au préscolaire ayant achevé CP1-CE1, 5 en Master 1 avec BAC+5,
// 1 en Master 2 avec BAC+1, 1 au doctorat avec une classe trop basse

replace commentaire = commentaire + "Incohérence EF3/EF4; " if !inrange(EF4, EF4_min, EF4_max) & !missing(EF4, EF4_min)
export_err `id' EF3 EF4 AgeAnnee commentaire if !inrange(EF4, EF4_min, EF4_max) & !missing(EF4, EF4_min), fichier(Erreur_EF4_coherence)

*--- Correction :
// 1) préscolaire ayant achevé une classe du primaire -> niveau primaire
replace EF3 = 2 if EF3 == 1 & inrange(EF4, 4, 9)

// 2) recalcul des bornes puis classe ramenée dans les bornes du niveau
drop EF4_min EF4_max
recode EF3 (1 2 = 0) (3 4 = 9) (5 6 = 13) (7 8 = 16) (9 10 = 18) (11 12 = 20) (else = .), gen(EF4_min)
recode EF3 (1 = 3) (2 = 9) (3 4 = 13) (5 6 = 16) (7 = 18) (8 = 19) (9 = 20) (10 = 21) (11 12 = 22) (else = .), gen(EF4_max)

replace EF4 = EF4_min if EF4 < EF4_min & !missing(EF4, EF4_min)
replace EF4 = EF4_max if EF4 > EF4_max & !missing(EF4, EF4_max)

count if !inrange(EF4, EF4_min, EF4_max) & !missing(EF4, EF4_min)
// 0 après correction

drop EF4_min EF4_max


*==============================================================================*
*  EF4_1 : diplôme le plus élevé obtenu
*  Champ : EF4 renseigné   -   Modalités : 0 Aucun, 1 CEPE, 2 BEPC/BEP/CAP,
*  3 BAC/BT, 4 BTS/DEUG 2, 5 Licence/Bachelor, 6 Master/DESS, 7 Doctorat
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF4_1) & !missing(EF4)
// 1 individu (classe achevée CE2) : correction "Aucun" plus bas

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF4_1) & missing(EF4)
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF4_1, 0, 7) & !missing(EF4_1)
// RAS

** Problème 4 : cohérence classe achevée (EF4) / diplôme (EF4_1)
// Diplôme maximum possible selon la classe achevée :
//  EF4 0-8 -> Aucun ; 9-12 -> CEPE ; 13-15 -> BEPC ; 16-17 -> BAC ; 18 -> BTS/DEUG ;
//  19-20 -> Licence ; 21 -> Master ; 22 -> Doctorat

cap drop EF4_1_max
recode EF4 (0/8 = 0) (9/12 = 1) (13/15 = 2) (16 17 = 3) (18 = 4) (19 20 = 5) (21 = 6) (22 = 7) (else = .), gen(EF4_1_max)

count if EF4_1 > EF4_1_max & !missing(EF4_1, EF4_1_max)
// 50 individus avec un diplôme supérieur à ce que permet la classe achevée

replace commentaire = commentaire + "Diplôme EF4_1 trop élevé pour la classe EF4; " if EF4_1 > EF4_1_max & !missing(EF4_1, EF4_1_max)
export_err `id' EF3 EF4 EF4_1 AgeAnnee commentaire if EF4_1 > EF4_1_max & !missing(EF4_1, EF4_1_max), fichier(Erreur_EF4_1_coherence)

// Contrôle du questionnaire (W1) : au-delà de la Terminale sans aucun diplôme
count if EF4_1 == 0 & EF4 > 16 & !missing(EF4)
// RAS

// Au supérieur (EF4 >= BAC+1) le BAC est forcément obtenu
count if EF4_1 < 3 & EF4 >= 17 & !missing(EF4, EF4_1)
// 2 individus

// Pour information : CM2 achevé avec succès sans le CEPE (pas corrigé)
count if EF4 == 9 & EF4_1 == 0
// 245 individus

*--- Correction :
replace EF4_1 = 0         if missing(EF4_1) & !missing(EF4)
replace EF4_1 = EF4_1_max if EF4_1 > EF4_1_max & !missing(EF4_1, EF4_1_max)
replace EF4_1 = 3         if EF4_1 < 3 & EF4 >= 17 & !missing(EF4, EF4_1)

drop EF4_1_max


*==============================================================================*
*  EF4_3a / EF4_3 : spécialité du diplôme le plus élevé  -  EF4_3_AUT : autre
*  Champ : EF1 == 1 & EF3 hors (1,2,3) & EF4_1 hors (0,1)
*==============================================================================*

cap drop filtre_EF4_3
gen filtre_EF4_3 = (EF1 == 1 & !inlist(EF3, 1, 2, 3) & !missing(EF3) & !inlist(EF4_1, 0, 1) & !missing(EF4_1))

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF4_3a) & filtre_EF4_3 == 1
// RAS
count if missing(EF4_3) & filtre_EF4_3 == 1
// 2 individus

replace commentaire = commentaire + "EF4_3 non renseigné; " if missing(EF4_3) & filtre_EF4_3 == 1
export_err `id' EF1 EF3 EF4_1 EF4_3a EF4_3 AgeAnnee commentaire if missing(EF4_3) & filtre_EF4_3 == 1, fichier(Erreur_EF4_3_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF4_3) & filtre_EF4_3 == 0
// 5 individus : conséquence des corrections de EF3/EF4_1 -> vidés dans le nettoyage final

** Problème 3 : valeurs permises (-1 Autre, 0 Pas concerné, 1 à 426)
count if !inrange(EF4_3, -1, 426) & !missing(EF4_3)
// RAS

// Pour information : "PAS CONCERNÉ" choisi alors que la personne a un diplôme >= BEPC
count if EF4_3 == 0 & filtre_EF4_3 == 1
// 1 228 individus (souvent diplômes de l'enseignement général)

** EF4_3_AUT : autre spécialité
count if missing(EF4_3_AUT) & EF4_3 == -1
// RAS
count if !missing(EF4_3_AUT) & EF4_3 != -1
// RAS


*==============================================================================*
*  EF4_4 : année d'obtention du diplôme le plus élevé
*  Champ : EF4_1 != 0   -   Valeurs : 1922 à 2026 ou 9998 (NSP)
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF4_4) & EF4_1 != 0 & !missing(EF4_1)
// 4 individus

replace commentaire = commentaire + "EF4_4 non renseigné; " if missing(EF4_4) & EF4_1 != 0 & !missing(EF4_1)
export_err `id' EF4_1 EF4_4 AgeAnnee commentaire if missing(EF4_4) & EF4_1 != 0 & !missing(EF4_1), fichier(Erreur_EF4_4_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF4_4) & (EF4_1 == 0 | missing(EF4_1))
// 30 individus : diplôme ramené à "Aucun" par les corrections -> vidés dans le nettoyage final

** Problème 3 : valeurs permises
count if (EF4_4 < 1922 | EF4_4 > `annee_enq') & !missing(EF4_4) & EF4_4 != 9998
// 20 individus (9999, 999999998, 998, 0, 23, 202) : l'agent voulait saisir 9998

*--- Correction :
replace EF4_4 = 9998 if (EF4_4 < 1922 | EF4_4 > `annee_enq') & !missing(EF4_4) & EF4_4 != 9998

** Problème 4 : vraisemblance
// Diplôme obtenu avant ou l'année de la naissance
count if EF4_4 <= M6_A & inrange(M6_A, 1900, `annee_enq') & inrange(EF4_4, 1922, `annee_enq')
// 24 individus

replace commentaire = commentaire + "Année du diplôme <= année de naissance; " if EF4_4 <= M6_A & inrange(M6_A, 1900, `annee_enq') & inrange(EF4_4, 1922, `annee_enq')
export_err `id' EF4_1 EF4_4 M6_A AgeAnnee commentaire if EF4_4 <= M6_A & inrange(M6_A, 1900, `annee_enq') & inrange(EF4_4, 1922, `annee_enq'), fichier(Erreur_EF4_4_coh1)

*--- Correction : année inconnue (9998) plutôt que manquante pour rester dans le filtre
replace EF4_4 = 9998 if EF4_4 <= M6_A & inrange(M6_A, 1900, `annee_enq') & inrange(EF4_4, 1922, `annee_enq')

// Diplôme obtenu entre 1 et 8 ans (peu probable) : exporté pour vérification, pas corrigé
count if inrange(EF4_4 - M6_A, 1, 8) & inrange(M6_A, 1900, `annee_enq') & inrange(EF4_4, 1922, `annee_enq')
// 115 individus

export_err `id' EF4_1 EF4_4 M6_A AgeAnnee if inrange(EF4_4 - M6_A, 1, 8) & inrange(M6_A, 1900, `annee_enq') & inrange(EF4_4, 1922, `annee_enq'), fichier(Erreur_EF4_4_coh2)


*==============================================================================*
*  EF5 : raisons de la non-fréquentation scolaire
*  Champ : EF1 == 2   -   Modalités : 1 à 21 (21 = Madrassa, Dougoumakalan...)
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF5) & EF1 == 2
// RAS

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF5) & EF1 != 2
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF5, 1, 21) & !missing(EF5)
// RAS

** Problème 4 : vraisemblance
count if EF5 == 15 & EF1 == 2
// RAS ("Etudes achevées" alors que jamais scolarisé)

count if EF5 == 4 & AgeAnnee >= 12 & !missing(AgeAnnee)
// 34 individus de 12 ans ou plus déclarés "Trop jeune"

count if inlist(EF5, 5, 13) & M5 == 1
// 19 hommes avec la raison "Fille (pesanteur culturelle)" ou "Grossesse"

replace commentaire = commentaire + "EF5 invraisemblable (âge ou sexe); " if (EF5 == 4 & AgeAnnee >= 12 & !missing(AgeAnnee)) | (inlist(EF5, 5, 13) & M5 == 1)
export_err `id' EF1 EF5 AgeAnnee M5 commentaire if (EF5 == 4 & AgeAnnee >= 12 & !missing(AgeAnnee)) | (inlist(EF5, 5, 13) & M5 == 1), fichier(Erreur_EF5_vraisemblance)


*==============================================================================*
*  EF5_AUTRE : autre raison à préciser   -   Champ : EF5 == 20
*==============================================================================*

count if missing(EF5_AUTRE) & EF5 == 20
// RAS
count if !missing(EF5_AUTRE) & EF5 != 20
// RAS


*==============================================================================*
*  EF6 : a fréquenté l'école durant l'année scolaire en cours ?
*  Champ : EF1 == 1 & 3 <= AgeAnnee <= 40
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF6) & EF1 == 1 & inrange(AgeAnnee, 3, 40)
// 7 individus

replace commentaire = commentaire + "EF6 non renseigné; " if missing(EF6) & EF1 == 1 & inrange(AgeAnnee, 3, 40)
export_err `id' EF1 EF6 AgeAnnee commentaire if missing(EF6) & EF1 == 1 & inrange(AgeAnnee, 3, 40), fichier(Erreur_EF6_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF6) & (EF1 != 1 | !inrange(AgeAnnee, 3, 40))
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF6, 1, 2) & !missing(EF6)
// RAS


*==============================================================================*
*  EF7 : niveau d'études actuel (année en cours)
*  Champ : EF6 == 1   -   Modalités : 1 à 12
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF7) & EF6 == 1
// RAS

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF7) & EF6 != 1
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF7, 1, 12) & !missing(EF7)
// RAS

** Problème 4 : vraisemblance âge / niveau actuel (contrôles du questionnaire)
count if EF7 == 1 & AgeAnnee >= 7 & !missing(AgeAnnee)
// 8 individus de 7 ans ou plus au préscolaire
count if EF7 == 2 & AgeAnnee >= 15 & !missing(AgeAnnee)
// 85 individus de 15 ans ou plus au primaire
count if inrange(EF7, 2, 12) & AgeAnnee < 5
// 28 enfants de moins de 5 ans au primaire ou plus

replace commentaire = commentaire + "Age peu compatible avec EF7; " if (EF7 == 1 & AgeAnnee >= 7 & !missing(AgeAnnee)) | (EF7 == 2 & AgeAnnee >= 15 & !missing(AgeAnnee)) | (inrange(EF7, 2, 12) & AgeAnnee < 5)
export_err `id' EF6 EF7 EF8 AgeAnnee commentaire if (EF7 == 1 & AgeAnnee >= 7 & !missing(AgeAnnee)) | (EF7 == 2 & AgeAnnee >= 15 & !missing(AgeAnnee)) | (inrange(EF7, 2, 12) & AgeAnnee < 5), fichier(Erreur_EF7_vraisemblance)

count if inrange(EF7, 5, 12) & AgeAnnee <= 10
// 5 enfants de 10 ans ou moins au secondaire 2nd cycle ou plus

*--- Correction : ramenés au secondaire 1er cycle (la classe EF8 est revue juste après)
replace EF7 = 3 if inrange(EF7, 5, 12) & AgeAnnee <= 10


*==============================================================================*
*  EF8 : classe actuelle (année en cours)
*  Champ : EF6 == 1   -   Modalités : 0 à 22
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF8) & EF6 == 1
// RAS

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF8) & EF6 != 1
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF8, 0, 22) & !missing(EF8)
// RAS

count if EF8 == 0 & EF6 == 1
// 1 individu scolarisé cette année avec "Aucune classe"
export_err `id' EF6 EF7 EF8 AgeAnnee if EF8 == 0 & EF6 == 1, fichier(Erreur_EF8_aucune_classe)

** Problème 4 : cohérence niveau actuel (EF7) / classe actuelle (EF8)
//  EF7=1 : 1-3    EF7=2 : 4-9    EF7=3/4 : 10-13   EF7=5/6 : 14-16
//  EF7=7 : 17-18  EF7=8 : 17-19  EF7=9 : 20        EF7=10 : 20-21   EF7=11/12 : 22

cap drop EF8_min EF8_max EF7_th
recode EF7 (1 = 1) (2 = 4) (3 4 = 10) (5 6 = 14) (7 8 = 17) (9 10 = 20) (11 12 = 22) (else = .), gen(EF8_min)
recode EF7 (1 = 3) (2 = 9) (3 4 = 13) (5 6 = 16) (7 = 18) (8 = 19) (9 = 20) (10 = 21) (11 12 = 22) (else = .), gen(EF8_max)

count if !inrange(EF8, EF8_min, EF8_max) & !missing(EF8, EF8_min) & EF8 != 0
// 5 individus (ceux ramenés au secondaire 1er cycle mais en 2nde/1ère)

replace commentaire = commentaire + "Incohérence EF7/EF8; " if !inrange(EF8, EF8_min, EF8_max) & !missing(EF8, EF8_min) & EF8 != 0
export_err `id' EF7 EF8 AgeAnnee commentaire if !inrange(EF8, EF8_min, EF8_max) & !missing(EF8, EF8_min) & EF8 != 0, fichier(Erreur_EF8_coherence)

*--- Correction : la classe (plus détaillée) fait foi, le niveau est déduit de la classe
recode EF8 (1/3 = 1) (4/9 = 2) (10/13 = 3) (14/16 = 5) (17 18 = 7) (19 = 8) (20 = 9) (21 = 10) (22 = 11) (else = .), gen(EF7_th)
replace EF7 = EF7_th if !inrange(EF8, EF8_min, EF8_max) & !missing(EF8, EF8_min, EF7_th) & EF8 != 0

drop EF8_min EF8_max EF7_th

** Problème 5 : cohérence niveau actuel (EF7) / plus haut niveau atteint (EF3)
count if EF7 > EF3 & !missing(EF7, EF3)
// 163 individus dont le niveau actuel dépasse le plus haut niveau déclaré
// (cas typique : élève en 6ème cette année, EF3 = primaire)

replace commentaire = commentaire + "Niveau actuel EF7 > plus haut niveau EF3; " if EF7 > EF3 & !missing(EF7, EF3)
export_err `id' EF3 EF4 EF6 EF7 EF8 AgeAnnee commentaire if EF7 > EF3 & !missing(EF7, EF3), fichier(Erreur_EF7_EF3_coherence)

*--- Correction : le plus haut niveau atteint est au moins le niveau actuel
replace EF3 = EF7 if EF7 > EF3 & !missing(EF7, EF3)

// Mise en cohérence de EF4 avec le nouveau niveau : la classe achevée est au moins
// la dernière classe du niveau précédent (ex. en 6ème -> CM2 achevé)
cap drop EF4_min
recode EF3 (1 2 = 0) (3 4 = 9) (5 6 = 13) (7 8 = 16) (9 10 = 18) (11 12 = 20) (else = .), gen(EF4_min)
count if EF4 < EF4_min & !missing(EF4, EF4_min)
// 23 individus
replace EF4 = EF4_min if EF4 < EF4_min & !missing(EF4, EF4_min)
drop EF4_min

** Problème 6 : classe achevée (EF4) supérieure à la classe actuelle (EF8)
count if EF4 > EF8 & !missing(EF4, EF8) & EF8 != 0
// 151 individus : exportés pour vérification (pas de correction automatique)

export_err `id' EF3 EF4 EF7 EF8 AgeAnnee if EF4 > EF8 & !missing(EF4, EF8) & EF8 != 0, fichier(Erreur_EF4_EF8_coherence)


*==============================================================================*
*  EF9 : raison de l'arrêt des études pour l'année en cours
*  Champ : EF6 == 2   -   Modalités : 1 à 21
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF9) & EF6 == 2
// RAS

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF9) & EF6 != 2
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF9, 1, 21) & !missing(EF9)
// RAS (NB : la modalité 21 existe, l'ancien programme la supprimait à tort)

** Problème 4 : vraisemblance
count if inlist(EF9, 5, 13) & M5 == 1
// 5 hommes avec la raison "Grossesse"

export_err `id' EF6 EF9 AgeAnnee M5 if inlist(EF9, 5, 13) & M5 == 1, fichier(Erreur_EF9_vraisemblance)

** EF9_Aut : autre raison  -  Champ : EF9 == 20
count if missing(EF9_Aut) & EF9 == 20
// RAS
count if !missing(EF9_Aut) & EF9 != 20
// RAS


*==============================================================================*
*  EF10 : a fréquenté l'école durant l'année scolaire précédente ?
*  Champ : EF1 == 1 & 3 <= AgeAnnee <= 40
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF10) & EF1 == 1 & inrange(AgeAnnee, 3, 40)
// 7 individus (les mêmes que EF6)

replace commentaire = commentaire + "EF10 non renseigné; " if missing(EF10) & EF1 == 1 & inrange(AgeAnnee, 3, 40)
export_err `id' EF1 EF10 AgeAnnee commentaire if missing(EF10) & EF1 == 1 & inrange(AgeAnnee, 3, 40), fichier(Erreur_EF10_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF10) & (EF1 != 1 | !inrange(AgeAnnee, 3, 40))
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF10, 1, 2) & !missing(EF10)
// RAS


*==============================================================================*
*  EF11 : niveau d'études durant l'année scolaire précédente
*  Champ : EF10 == 1   -   Modalités : 1 à 12
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF11) & EF10 == 1
// 1 individu

replace commentaire = commentaire + "EF11 non renseigné; " if missing(EF11) & EF10 == 1
export_err `id' EF10 EF11 AgeAnnee commentaire if missing(EF11) & EF10 == 1, fichier(Erreur_EF11_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF11) & EF10 != 1
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF11, 1, 12) & !missing(EF11)
// 2 individus avec "Aucun niveau" alors qu'ils étaient scolarisés l'an dernier
export_err `id' EF10 EF11 EF12 AgeAnnee if !inrange(EF11, 1, 12) & !missing(EF11), fichier(Erreur_EF11_valeurs)


*==============================================================================*
*  EF12 : classe durant l'année scolaire précédente
*  Champ : EF10 == 1   -   Modalités : 0 à 22
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF12) & EF10 == 1
// 3 individus

replace commentaire = commentaire + "EF12 non renseigné; " if missing(EF12) & EF10 == 1
export_err `id' EF10 EF11 EF12 AgeAnnee commentaire if missing(EF12) & EF10 == 1, fichier(Erreur_EF12_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF12) & EF10 != 1
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF12, 0, 22) & !missing(EF12)
// RAS (NB : l'ancien programme utilisait inlist(EF12,0,22) au lieu de inrange)

count if EF12 == 0 & EF10 == 1
// 4 individus scolarisés l'an dernier avec "Aucune classe"
export_err `id' EF10 EF11 EF12 AgeAnnee if EF12 == 0 & EF10 == 1, fichier(Erreur_EF12_aucune_classe)

** Problème 4 : cohérence classe actuelle (EF8) / classe de l'an dernier (EF12)
count if EF8 > EF12 + 1 & !missing(EF8, EF12)
// 52 individus qui ont sauté au moins une classe en un an

replace commentaire = commentaire + "Saut de classe EF12->EF8; " if EF8 > EF12 + 1 & !missing(EF8, EF12)
export_err `id' EF8 EF11 EF12 EF14 AgeAnnee commentaire if EF8 > EF12 + 1 & !missing(EF8, EF12), fichier(Erreur_EF12_EF8_coherence)

*--- Correction : la classe de l'an dernier est la classe précédant la classe actuelle
replace EF12 = EF8 - 1 if EF8 > EF12 + 1 & !missing(EF8, EF12)

count if EF12 > EF8 & !missing(EF8, EF12)
// 15 individus dont la classe de l'an dernier dépasse la classe actuelle (exportés, pas corrigés)
export_err `id' EF7 EF8 EF11 EF12 AgeAnnee if EF12 > EF8 & !missing(EF8, EF12), fichier(Erreur_EF12_superieur_EF8)

** Problème 5 : cohérence niveau (EF11) / classe (EF12) de l'an dernier
cap drop EF12_min EF12_max EF11_th
recode EF11 (1 = 1) (2 = 4) (3 4 = 10) (5 6 = 14) (7 8 = 17) (9 10 = 20) (11 12 = 22) (else = .), gen(EF12_min)
recode EF11 (1 = 3) (2 = 9) (3 4 = 13) (5 6 = 16) (7 = 18) (8 = 19) (9 = 20) (10 = 21) (11 12 = 22) (else = .), gen(EF12_max)

count if !inrange(EF12, EF12_min, EF12_max) & !missing(EF12, EF12_min) & EF12 != 0
// 6 individus (tous issus de la correction précédente de EF12)

*--- Correction : le niveau est déduit de la classe (on garde la filière technique 4/6)
recode EF12 (1/3 = 1) (4/9 = 2) (10/13 = 3) (14/16 = 5) (17 18 = 7) (19 = 8) (20 = 9) (21 = 10) (22 = 11) (else = .), gen(EF11_th)
replace EF11_th = 4 if EF11_th == 3 & EF11 == 4
replace EF11_th = 6 if EF11_th == 5 & EF11 == 6
replace EF11 = EF11_th if !inrange(EF12, EF12_min, EF12_max) & !missing(EF12, EF12_min, EF11_th) & EF12 != 0

drop EF12_min EF12_max EF11_th

** Problème 6 : cohérence niveau de l'an dernier (EF11) / niveau actuel (EF7)
count if EF11 > EF7 & !missing(EF11, EF7)
// 9 individus : niveau de l'an dernier supérieur au niveau actuel (contrôle W2 du questionnaire)

* Progression de plus d'un niveau en un an
cap drop EF7_New EF11_New
recode EF7  (0 = 0) (1 = 1) (2 = 2) (3 4 = 3) (5 6 = 4) (7 = 5) (8 = 6) (9 = 7) (10 = 8) (11 = 9) (12 = 10) (else = .), gen(EF7_New)
recode EF11 (0 = 0) (1 = 1) (2 = 2) (3 4 = 3) (5 6 = 4) (7 = 5) (8 = 6) (9 = 7) (10 = 8) (11 = 9) (12 = 10) (else = .), gen(EF11_New)

count if EF11_New + 1 < EF7_New & !missing(EF7_New, EF11_New)
// 10 individus

replace commentaire = commentaire + "Incohérence EF11/EF7; " if (EF11 > EF7 & !missing(EF11, EF7)) | (EF11_New + 1 < EF7_New & !missing(EF7_New, EF11_New))
export_err `id' EF7 EF8 EF11 EF12 AgeAnnee commentaire if (EF11 > EF7 & !missing(EF11, EF7)) | (EF11_New + 1 < EF7_New & !missing(EF7_New, EF11_New)), fichier(Erreur_EF11_EF7_coherence)

drop EF7_New EF11_New


*==============================================================================*
*  EF14 : dernière classe suivie avec succès durant l'année précédente
*  Champ : EF10 == 1   -   Modalités : 0 à 22
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF14) & EF10 == 1
// 1 individu

replace commentaire = commentaire + "EF14 non renseigné; " if missing(EF14) & EF10 == 1
export_err `id' EF10 EF12 EF14 AgeAnnee commentaire if missing(EF14) & EF10 == 1, fichier(Erreur_EF14_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF14) & EF10 != 1
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF14, 0, 22) & !missing(EF14)
// RAS

** Problème 4 : cohérence classe suivie (EF12) / classe réussie (EF14)
// La classe réussie l'an dernier est soit la classe suivie (passage), soit la
// classe précédente (échec/redoublement). 0 = aucune classe validée est accepté.
count if EF14 > EF12 & !missing(EF14, EF12)
// 266 individus : l'agent a souvent saisi la classe d'admission au lieu de la classe réussie

count if EF12 > EF14 + 1 & !missing(EF14, EF12) & EF14 != 0
// 13 individus

count if EF14 == 0 & EF12 > 0 & !missing(EF12)
// 105 individus sans classe validée (pour information)

replace commentaire = commentaire + "Incohérence EF12/EF14; " if (EF14 > EF12 & !missing(EF14, EF12)) | (EF12 > EF14 + 1 & !missing(EF14, EF12) & EF14 != 0)
export_err `id' EF8 EF12 EF14 AgeAnnee commentaire if (EF14 > EF12 & !missing(EF14, EF12)) | (EF12 > EF14 + 1 & !missing(EF14, EF12) & EF14 != 0), fichier(Erreur_EF14_coherence)

*--- Correction :
replace EF14 = EF12     if EF14 > EF12 & !missing(EF14, EF12)
replace EF14 = EF12 - 1 if EF12 > EF14 + 1 & !missing(EF14, EF12) & EF14 != 0


*==============================================================================*
*  EF15 : raison de l'arrêt des études l'année précédente
*  Champ : EF10 == 2   -   Modalités : 1 à 21
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF15) & EF10 == 2
// RAS

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF15) & EF10 != 2
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF15, 1, 21) & !missing(EF15)
// RAS (NB : l'ancien programme utilisait inlist(EF15,1,20) au lieu de inrange)

** Problème 4 : vraisemblance
count if inlist(EF15, 5, 13) & M5 == 1
// 2 hommes avec la raison "Grossesse"
export_err `id' EF10 EF15 AgeAnnee M5 if inlist(EF15, 5, 13) & M5 == 1, fichier(Erreur_EF15_vraisemblance)

** EF15_Aut : autre raison  -  Champ : EF15 == 20
count if missing(EF15_Aut) & EF15 == 20
// RAS
count if !missing(EF15_Aut) & EF15 != 20
// RAS


*************************** ALPHABETISATION ***********************************

*==============================================================================*
*  EF16A-E : sait lire (__1), écrire (__2) et comprendre (__3) une phrase en
*  langue ivoirienne (A), français (B), arabe (C), anglais (D), autre langue (E)
*  Champ effectif dans les données : nouveaux membres de 15 ans et plus résidents
*  Modalités : 0 Non / 1 Oui
*==============================================================================*

cap drop filtre_EF16
gen filtre_EF16 = (AgeAnnee >= 15 & !missing(AgeAnnee) & nouveau == 1 & Statut_Res == 1)

local alpha EF16A__1 EF16A__2 EF16A__3 EF16B__1 EF16B__2 EF16B__3 EF16C__1 EF16C__2 EF16C__3 EF16D__1 EF16D__2 EF16D__3 EF16E__1 EF16E__2 EF16E__3

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
foreach var of local alpha {
	display as result "`var'"
	count if missing(`var') & filtre_EF16 == 1
}
// Cases non cochées (.a) : A 48/74/1 ; B 11/13/2 ; C 0/7/2 ; D 1/10/6 ; E 14/17/7

export_err `id' `alpha' AgeAnnee if filtre_EF16 == 1 & (missing(EF16A__1, EF16A__2, EF16A__3, EF16B__1, EF16B__2, EF16B__3, EF16C__1, EF16C__2) | missing(EF16C__3, EF16D__1, EF16D__2, EF16D__3, EF16E__1, EF16E__2, EF16E__3)), fichier(Erreur_EF16_NA)

*--- Correction : une case Oui/Non non cochée est considérée comme "Non"
foreach var of local alpha {
	replace `var' = 0 if missing(`var') & filtre_EF16 == 1
}

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
foreach var of local alpha {
	count if !missing(`var') & filtre_EF16 == 0
}
// RAS

** Problème 3 : valeurs permises
foreach var of local alpha {
	count if !inrange(`var', 0, 1) & !missing(`var')
}
// RAS

** Problème 4 : vraisemblance
// Sait écrire mais ne sait pas lire
foreach L in A B C D E {
	display as result "EF16`L'"
	count if EF16`L'__2 == 1 & EF16`L'__1 == 0
}
// A : 4 ; B : 22 ; C : 2 ; D : 12 ; E : 4

export_err `id' `alpha' AgeAnnee if (EF16A__2 == 1 & EF16A__1 == 0) | (EF16B__2 == 1 & EF16B__1 == 0) | (EF16C__2 == 1 & EF16C__1 == 0) | (EF16D__2 == 1 & EF16D__1 == 0) | (EF16E__2 == 1 & EF16E__1 == 0), fichier(Erreur_EF16_ecrire_sans_lire)

// Celui qui sait écrire sait lire
foreach L in A B C D E {
	replace EF16`L'__1 = 1 if EF16`L'__2 == 1 & EF16`L'__1 == 0
}

// Les personnes ayant atteint au moins le secondaire doivent lire, écrire et comprendre le français
count if inrange(EF3, 3, 12) & (EF16B__1 == 0 | EF16B__2 == 0 | EF16B__3 == 0) & filtre_EF16 == 1
// 66 individus

replace commentaire = commentaire + "Secondaire+ mais ne lit/écrit/comprend pas le français; " if inrange(EF3, 3, 12) & (EF16B__1 == 0 | EF16B__2 == 0 | EF16B__3 == 0) & filtre_EF16 == 1
export_err `id' EF3 EF4 EF16B__1 EF16B__2 EF16B__3 AgeAnnee commentaire if inrange(EF3, 3, 12) & (EF16B__1 == 0 | EF16B__2 == 0 | EF16B__3 == 0) & filtre_EF16 == 1, fichier(Erreur_EF16_coherence)

*--- Correction
foreach var in EF16B__1 EF16B__2 EF16B__3 {
	replace `var' = 1 if inrange(EF3, 3, 12) & `var' == 0 & filtre_EF16 == 1
}

** EF16E_Aut : autre langue à préciser  -  Champ : au moins une case de EF16E cochée
count if missing(EF16E_Aut) & (EF16E__1 == 1 | EF16E__2 == 1 | EF16E__3 == 1)
// RAS
count if !missing(EF16E_Aut) & !(EF16E__1 == 1 | EF16E__2 == 1 | EF16E__3 == 1)
// RAS


*==============================================================================*
*  EF17 : langue principalement parlée à la maison
*  Champ : nouveau membre & AgeAnnee >= 4   -   Modalités : 1 à 5
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF17) & AgeAnnee >= 4 & !missing(AgeAnnee) & nouveau == 1
// RAS

replace commentaire = commentaire + "EF17 non renseigné; " if missing(EF17) & AgeAnnee >= 4 & !missing(AgeAnnee) & nouveau == 1
export_err `id' EF17 AgeAnnee membre_id_v1 commentaire if missing(EF17) & AgeAnnee >= 4 & !missing(AgeAnnee) & nouveau == 1, fichier(Erreur_EF17_NA)

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF17) & (AgeAnnee < 4 | missing(AgeAnnee) | nouveau != 1)
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF17, 1, 5) & !missing(EF17)
// RAS


*==============================================================================*
*  EF18 : langue locale ivoirienne parlée à la maison
*  Champ : EF17 == 1   -   Modalités : 1 à 89, 98 (autre)
*==============================================================================*

** Problème 1 : ceux qui devaient répondre ont-ils répondu ?
count if missing(EF18) & EF17 == 1
// RAS

** Problème 2 : ceux qui ont répondu devaient-ils répondre ?
count if !missing(EF18) & EF17 != 1
// RAS

** Problème 3 : valeurs permises
count if !inrange(EF18, 1, 89) & EF18 != 98 & !missing(EF18)
// RAS

** EF18_aut : autre langue  -  Champ : EF18 == 98
count if missing(EF18_aut) & EF18 == 98
// RAS
count if !missing(EF18_aut) & EF18 != 98
// RAS


*==============================================================================*
*  NETTOYAGE DES FILTRES APRES CORRECTIONS
*  (les corrections ont pu modifier des questions filtres : on vide les
*   questions qui ne devaient plus être posées)
*==============================================================================*

* Spécialité du diplôme
drop filtre_EF4_3
gen filtre_EF4_3 = (EF1 == 1 & !inlist(EF3, 1, 2, 3) & !missing(EF3) & !inlist(EF4_1, 0, 1) & !missing(EF4_1))

replace EF4_3     = .  if filtre_EF4_3 == 0
replace EF4_3a    = "" if filtre_EF4_3 == 0
replace EF4_3_AUT = "" if EF4_3 != -1

* Année du diplôme
replace EF4_4 = . if EF4_1 == 0 | missing(EF4_1)

* Vérification finale des filtres
count if !missing(EF4_3) & filtre_EF4_3 == 0
count if !missing(EF4_4) & (EF4_1 == 0 | missing(EF4_1))
count if !missing(EF8) & EF6 != 1
count if !missing(EF12) & EF10 != 1
// RAS attendu partout


*==============================================================================*
*  SAUVEGARDE
*==============================================================================*

drop filtre_EF4_3 filtre_EF16 nouveau
drop HH01 HH2 HH2A HH4 HH8 HH12 HH13 rghab rgmen hh V1interviewkey
drop AgeAnnee Statut_Res M5 M6_A M7 M4Confirm
drop commentaire

save "$standard_menage\QM_S2_education_formation.dta", replace
