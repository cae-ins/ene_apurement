*******************************************************************************
*      VERIFICATION ET TRAITEMENT DE LA SECTION "IMMIGRATION" (IM)            *
*      ENQUETE EMPLOI - VOLET MENAGE (ENEM) - T3 2026                         *
*                                                                             *
*      RESPONSABLE : DIABATE BEN ISMAEL                                       *
*                                                                             *
*      Bases  : QM_S4_immigration.dta, QM_S0_identification.dta,             *
*               QM_S1_composition_menage.dta                                  *
*      Sortie : $standard_menage\QM_S4_immigration.dta                        *
*      Erreurs: $folderpath/document/Err_IM*.xlsx                             *
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
use "$datain_standard\QM_S4_immigration.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepusing(HH2 HH3 HH4 HH12 HH13 hha rgmen)
keep if _merge == 3
drop _merge

* NB : membre_id_v1 est déjà dans la base immigration, on ne le reprend pas
merge 1:1 interview__key membres__id using "$datain_standard\QM_S1_composition_menage.dta", keepusing(AgeAnnee Statut_Res M6_A)
keep if _merge == 3
drop _merge
// 24 502 individus après fusion (aucune perte)

*--- Année et mois de l'entretien (bornes des dates d'arrivée)
cap drop annee_hha mois_hha
gen annee_hha = real(substr(hha, 1, 4))
gen mois_hha  = real(substr(hha, 6, 2))
// Tous les entretiens du T3 sont en 2026

*--- Variables d'identification reprises dans tous les exports
local id interview__key membres__id M0 HH2 HH12 HH13 rgmen

*--- Variable commentaire (les commentaires s'ajoutent les uns aux autres)
cap drop commentaire
gen commentaire = ""

*--- Nouveau membre (pas d'identifiant du passage précédent)
*    La section n'est posée qu'aux nouveaux membres résidents
cap drop nouveau
gen nouveau = (membre_id_v1 == "##N/A##")


*==============================================================================*
*  IM1 : a-t-il/elle vécu de manière continue dans une autre localité pendant
*        au moins six mois ?
*  Champ : Statut_Res == 1 & nouveau membre   -   Modalités : 1 Oui, 2 Non
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM1) & Statut_Res == 1 & nouveau == 1
// 6 individus n'ont pas répondu

replace commentaire = commentaire + "IM1 non renseigné; " if missing(IM1) & Statut_Res == 1 & nouveau == 1
export_err `id' IM1 Statut_Res membre_id_v1 AgeAnnee commentaire if missing(IM1) & Statut_Res == 1 & nouveau == 1, fichier(Err_IM1_NA)

** 2. Vérification des sauts
count if !missing(IM1) & (Statut_Res != 1 | nouveau != 1)
// RAS

** 3. Valeurs permises
count if !inrange(IM1, 1, 2) & !missing(IM1)
// RAS


*==============================================================================*
*  IM2A : depuis quelle année vit-il/elle dans cette localité ?
*  Champ : IM1 == 1   -   Valeurs : 1922 à l'année de l'entretien, ou 9998 (NSP)
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM2A) & IM1 == 1
// RAS

replace commentaire = commentaire + "IM2A non renseigné; " if missing(IM2A) & IM1 == 1
export_err `id' IM1 IM2A membre_id_v1 commentaire if missing(IM2A) & IM1 == 1, fichier(Err_IM2A_NA)

** 2. Vérification des sauts
count if !missing(IM2A) & IM1 != 1
// RAS

** 3. Valeurs permises
count if !inrange(IM2A, 1922, annee_hha) & IM2A != 9998 & !missing(IM2A)
// RAS

count if IM2A == 9998
// 97 individus ne connaissent pas l'année d'arrivée (IM3A est alors posée)

** 4. Cohérence
// Arrivée avant l'année de naissance
count if IM2A < M6_A & inrange(IM2A, 1922, annee_hha) & inrange(M6_A, 1900, annee_hha)
// 3 individus

// Durée de résidence (année entretien - IM2A) supérieure à l'âge (contrôle W2 du questionnaire)
count if (annee_hha - IM2A) > AgeAnnee & inrange(IM2A, 1922, annee_hha) & !missing(AgeAnnee)
// 5 individus (dont les 3 précédents)

replace commentaire = commentaire + "Année d'arrivée IM2A incompatible avec la naissance; " if ((IM2A < M6_A & inrange(M6_A, 1900, annee_hha)) | (annee_hha - IM2A) > AgeAnnee) & inrange(IM2A, 1922, annee_hha) & !missing(AgeAnnee)
export_err `id' IM1 IM2A IM2M M6_A AgeAnnee commentaire if ((IM2A < M6_A & inrange(M6_A, 1900, annee_hha)) | (annee_hha - IM2A) > AgeAnnee) & inrange(IM2A, 1922, annee_hha) & !missing(AgeAnnee), fichier(Err_IM2A_coherence)

// Pas de correction automatique : impossible de savoir si l'erreur est sur
// l'année d'arrivée ou sur l'année de naissance


*==============================================================================*
*  IM2M : depuis quel mois vit-il/elle dans cette localité ?
*  Champ : IM2A renseigné & IM2A != 9998   -   Modalités : 1 à 12, 9998 (NSP)
*  NB : l'étiquette de la variable dans la base ("date de naissance de nom,
*  mois?") est erronée ; elle est corrigée ci-dessous
*==============================================================================*

label variable IM2M "IM2M. Depuis quel mois vit-il/elle dans cette localité ?"

** 1. Valeurs manquantes
count if missing(IM2M) & !missing(IM2A) & IM2A != 9998
// RAS

replace commentaire = commentaire + "IM2M non renseigné; " if missing(IM2M) & !missing(IM2A) & IM2A != 9998
export_err `id' IM2A IM2M commentaire if missing(IM2M) & !missing(IM2A) & IM2A != 9998, fichier(Err_IM2M_NA)

** 2. Vérification des sauts
count if !missing(IM2M) & (missing(IM2A) | IM2A == 9998)
// RAS

** 3. Valeurs permises
count if !inrange(IM2M, 1, 12) & IM2M != 9998 & !missing(IM2M)
// RAS

count if IM2M == 9998
// 1 461 individus ne connaissent pas le mois d'arrivée (pour information)

** 4. Cohérence : arrivée cette année, à un mois postérieur à l'entretien
count if IM2A == annee_hha & inrange(IM2M, 1, 12) & IM2M > mois_hha & !missing(mois_hha)
// 3 individus

replace commentaire = commentaire + "Mois d'arrivée IM2M postérieur à l'entretien; " if IM2A == annee_hha & inrange(IM2M, 1, 12) & IM2M > mois_hha & !missing(mois_hha)
export_err `id' IM2A IM2M hha commentaire if IM2A == annee_hha & inrange(IM2M, 1, 12) & IM2M > mois_hha & !missing(mois_hha), fichier(Err_IM2M_coherence)

*--- Correction : mois inconnu
replace IM2M = 9998 if IM2A == annee_hha & inrange(IM2M, 1, 12) & IM2M > mois_hha & !missing(mois_hha)


*==============================================================================*
*  IM3A : depuis combien d'années vit-il/elle dans cette localité ?
*  Champ : IM2A == 9998   -   Valeurs : 0 à 90, <= AgeAnnee
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM3A) & IM2A == 9998
// RAS

replace commentaire = commentaire + "IM3A non renseigné; " if missing(IM3A) & IM2A == 9998
export_err `id' IM2A IM3A commentaire if missing(IM3A) & IM2A == 9998, fichier(Err_IM3A_NA)

** 2. Vérification des sauts
count if !missing(IM3A) & IM2A != 9998
// RAS

** 3. Valeurs permises
count if IM3A > 90 & !missing(IM3A) & IM3A != 9998
// RAS

** 4. Cohérence : durée de résidence supérieure à l'âge
count if IM3A > AgeAnnee & !missing(IM3A, AgeAnnee) & IM3A != 9998
// RAS


*==============================================================================*
*  IM3M : depuis combien de mois (en plus des IM3A années) ?
*  Champ : IM3A renseigné & IM3A != 9998   -   Valeurs : 0 à 11
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM3M) & !missing(IM3A) & IM3A != 9998
// RAS

** 2. Vérification des sauts
// (l'ancien programme testait IM3A au lieu de IM3M)
count if !missing(IM3M) & (missing(IM3A) | IM3A == 9998)
// RAS

** 3. Valeurs permises
count if !inrange(IM3M, 0, 11) & !missing(IM3M) & IM3M != 9998
// RAS


*==============================================================================*
*  IM4 : où habitait-il/elle avant ? (1 Côte d'Ivoire, 2 Hors Côte d'Ivoire)
*  Champ : IM1 == 1
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM4) & IM1 == 1
// RAS

replace commentaire = commentaire + "IM4 non renseigné; " if missing(IM4) & IM1 == 1
export_err `id' IM1 IM4 commentaire if missing(IM4) & IM1 == 1, fichier(Err_IM4_NA)

** 2. Vérification des sauts
count if !missing(IM4) & IM1 != 1
// RAS

** 3. Valeurs permises
count if !inrange(IM4, 1, 2) & !missing(IM4)
// RAS


*==============================================================================*
*  IM5 : pays de résidence antérieure   -   Champ : IM4 == 2   -   Codes 1 à 216
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM5) & IM4 == 2
// RAS

replace commentaire = commentaire + "IM5 non renseigné; " if missing(IM5) & IM4 == 2
export_err `id' IM4 IM5 commentaire if missing(IM5) & IM4 == 2, fichier(Err_IM5_NA)

** 2. Vérification des sauts
count if !missing(IM5) & IM4 != 2
// RAS

** 3. Valeurs permises
count if !inrange(IM5, 1, 216) & !missing(IM5)
// RAS


*==============================================================================*
*  IM5_Aut : précision du pays
*  Champ : IM5 = 28 Botswana, 36 Cameroun, 41 Chypre, 44 Comores, 47 Cuba,
*          48 Curaçao (filtre du questionnaire)
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM5_Aut) & inlist(IM5, 28, 36, 41, 44, 47, 48)
// RAS (aucun individu venant de ces pays)

** 2. Vérification des sauts
count if !missing(IM5_Aut) & !inlist(IM5, 28, 36, 41, 44, 47, 48)
// RAS


*==============================================================================*
*  IM7 : sous-préfecture de résidence antérieure
*  Champ : IM4 == 1   -   0 = Ne sait pas
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM7) & IM4 == 1
// RAS

replace commentaire = commentaire + "IM7 non renseigné; " if missing(IM7) & IM4 == 1
export_err `id' IM4 IM7 commentaire if missing(IM7) & IM4 == 1, fichier(Err_IM7_NA)

** 2. Vérification des sauts
count if !missing(IM7) & IM4 != 1
// RAS

count if IM7 == 0
// 3 individus ne connaissent pas la sous-préfecture (pour information)


*==============================================================================*
*  IM7A : localité de résidence antérieure (liste en cascade de IM7)
*  Champ : IM4 == 1 & IM7 connue (IM7 != 0)
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM7A) & IM4 == 1
// 3 individus : ce sont les 3 "Ne sait pas" de IM7, pour qui la liste est vide
count if missing(IM7A) & IM4 == 1 & IM7 != 0 & !missing(IM7)
// RAS

replace commentaire = commentaire + "IM7A non renseigné; " if missing(IM7A) & IM4 == 1 & IM7 != 0 & !missing(IM7)
export_err `id' IM4 IM7 IM7A commentaire if missing(IM7A) & IM4 == 1 & IM7 != 0 & !missing(IM7), fichier(Err_IM7A_NA)

** 2. Vérification des sauts
count if !missing(IM7A) & IM4 != 1
// RAS


*==============================================================================*
*  IM8 : pourquoi est-il venu dans cette localité ? (choix multiple)
*  IM8__1 famille, __2 études, __3 emploi, __4 affectation, __5 conflits,
*  __6 soins, __7 visite/tourisme, __8 activité agricole, __9 autre
*  Champ : IM1 == 1   -   Valeurs : 0/1
*==============================================================================*

cap drop nb_IM8_rens nb_IM8_oui
egen nb_IM8_rens = rownonmiss(IM8__1-IM8__9)
egen nb_IM8_oui  = anycount(IM8__1-IM8__9), values(1)

** 1. Valeurs manquantes
count if nb_IM8_rens == 0 & IM1 == 1
// RAS
count if nb_IM8_oui == 0 & nb_IM8_rens > 0 & IM1 == 1
// RAS (aucune raison cochée)

replace commentaire = commentaire + "IM8 aucune raison; " if nb_IM8_oui == 0 & IM1 == 1
export_err `id' IM1 IM8__1-IM8__9 commentaire if nb_IM8_oui == 0 & IM1 == 1, fichier(Err_IM8_NA)

** 2. Vérification des sauts
count if nb_IM8_rens > 0 & IM1 != 1
// RAS

** 3. Valeurs permises
foreach var of varlist IM8__1-IM8__9 {
	count if !inrange(`var', 0, 1) & !missing(`var')
}
// RAS

** 4. Vraisemblance âge / raison
count if IM8__2 == 1 & AgeAnnee < 5
// 6 enfants de moins de 5 ans venus pour suivre des études
count if IM8__3 == 1 & AgeAnnee < 12
// 1 enfant de moins de 12 ans venu chercher un emploi
count if IM8__4 == 1 & AgeAnnee < 18
// 3 mineurs venus suite à une affectation (souvent l'affectation d'un parent)

replace commentaire = commentaire + "Raison IM8 peu compatible avec l'âge; " if (IM8__2 == 1 & AgeAnnee < 5) | (IM8__3 == 1 & AgeAnnee < 12) | (IM8__4 == 1 & AgeAnnee < 18)
export_err `id' IM1 IM8__1-IM8__9 IM8_Aut AgeAnnee commentaire if (IM8__2 == 1 & AgeAnnee < 5) | (IM8__3 == 1 & AgeAnnee < 12) | (IM8__4 == 1 & AgeAnnee < 18), fichier(Err_IM8_vraisemblance)

drop nb_IM8_rens nb_IM8_oui


*==============================================================================*
*  IM8_Aut : autre raison à préciser   -   Champ : IM8__9 == 1
*==============================================================================*

** 1. Valeurs manquantes
count if missing(IM8_Aut) & IM8__9 == 1
// RAS

** 2. Vérification des sauts
// (l'ancien programme testait IM8__9 == 2, valeur qui n'existe pas)
count if !missing(IM8_Aut) & IM8__9 != 1
// RAS

** 4. Cohérence : précisions qui correspondent à une modalité existante
cap drop IM8_Aut_maj recode_IM8
gen IM8_Aut_maj = ustrupper(ustrtrim(IM8_Aut))
gen recode_IM8 = 0

// Études / formation / école coranique -> IM8__2
count if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "FORMATION|APPRENDRE|ETUDE|ÉTUDE|MADRASSA|CORAN")
// 11 individus
replace IM8__2 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "FORMATION|APPRENDRE|ETUDE|ÉTUDE|MADRASSA|CORAN")
replace recode_IM8 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "FORMATION|APPRENDRE|ETUDE|ÉTUDE|MADRASSA|CORAN")

// Affectation -> IM8__4
count if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "AFFECTATION")
// 1 individu
replace IM8__4 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "AFFECTATION")
replace recode_IM8 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "AFFECTATION")

// Fuir la guerre -> IM8__5 (conflits armés)
count if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "GUERRE")
// 2 individus
replace IM8__5 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "GUERRE")
replace recode_IM8 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "GUERRE")

// Rejoindre son mari -> IM8__1 (rejoindre la famille)
count if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "REJOINDRE SON MARI|JOINDRE SONT MARIE")
// 2 individus
replace IM8__1 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "REJOINDRE SON MARI|JOINDRE SONT MARIE")
replace recode_IM8 = 1 if IM8__9 == 1 & ustrregexm(IM8_Aut_maj, "REJOINDRE SON MARI|JOINDRE SONT MARIE")

*--- La modalité "Autre" n'a plus lieu d'être pour les individus recodés
replace IM8__9  = 0  if recode_IM8 == 1
replace IM8_Aut = "" if recode_IM8 == 1
// 16 individus recodés au total
// NB : le "mariage" (une vingtaine de cas) n'a pas de modalité propre ; il reste
// en "Autre". A signaler pour la mise à jour du questionnaire.

** 5. Cohérence avec IM1 : individus qui disent vivre dans la localité depuis leur naissance
count if IM1 == 1 & ustrregexm(IM8_Aut_maj, "DEPUIS LA NAISSANCE|EST NE A|EST NÉ A|NEE SUR PLACE|NÉE SUR PLACE")
// 23 individus : s'ils n'ont jamais quitté la localité, IM1 devrait être "Non".
// Leur année d'arrivée (IM2A) étant souvent postérieure à la naissance, on ne
// corrige pas automatiquement : exportés pour vérification sur le terrain.

replace commentaire = commentaire + "IM1=Oui mais vit dans la localité depuis la naissance (IM8_Aut); " if IM1 == 1 & ustrregexm(IM8_Aut_maj, "DEPUIS LA NAISSANCE|EST NE A|EST NÉ A|NEE SUR PLACE|NÉE SUR PLACE")
export_err `id' IM1 IM2A M6_A IM4 IM8_Aut AgeAnnee commentaire if IM1 == 1 & ustrregexm(IM8_Aut_maj, "DEPUIS LA NAISSANCE|EST NE A|EST NÉ A|NEE SUR PLACE|NÉE SUR PLACE"), fichier(Err_IM1_naissance)

drop IM8_Aut_maj recode_IM8


********************* SAUVEGARDE DE LA BASE DE DONNEES APUREE ******************

drop nouveau commentaire annee_hha mois_hha
drop HH2 HH3 HH4 HH12 HH13 hha rgmen
drop AgeAnnee Statut_Res M6_A

save "$standard_menage\QM_S4_immigration.dta", replace
