*******************************************************************************
*      VERIFICATION ET TRAITEMENT DE LA SECTION "EMIGRATION" (ME)             *
*      ENQUETE EMPLOI - VOLET MENAGE (ENEM) - T3 2026                         *
*                                                                             *
*      RESPONSABLE : DIABATE BEN ISMAEL                                       *
*                                                                             *
*      Bases  : QM_S0_identification.dta (ME1, ME2A, ME2B : niveau ménage)   *
*               QM_S5_emmigration.dta    (ME3 à ME9 : un enregistrement par  *
*                                         émigré)                             *
*      Sortie : $standard_menage\QM_S5_emmigration.dta                        *
*      Erreurs: $folderpath/document/Err_ME*.xlsx                             *
*                                                                             *
*      Les effectifs notés en commentaire (//) sont ceux observés sur la      *
*      base T3 2026 au 06/11/2026 : 2 627 ménages en 1er passage,             *
*      24 ménages avec émigré(s), 28 émigrés.                                 *
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

*--- Nombre d'émigrés par ménage dans la base des émigrés (pour la cohérence ME2A)
use "$datain_standard\QM_S5_emmigration.dta", clear
gen nb_emigres = 1
collapse (sum) nb_emigres, by(interview__key)
tempfile nb_emig
save `nb_emig'


********************************************************************************
*  PARTIE A : NIVEAU MENAGE (ME1, ME2A, ME2B) - base QM_S0_identification
*  Champ de la section : ménage enquêté (hha renseigné) & 1er passage (rgmen == 1)
*  NB : l'ancien programme contrôlait ces questions dans la base des émigrés,
*  où ne figurent que les ménages ayant répondu "Oui" ; les ménages sans
*  réponse à ME1 ne pouvaient donc pas être détectés.
********************************************************************************

use "$datain_standard\QM_S0_identification.dta", clear

merge 1:1 interview__key using `nb_emig', keep(master match)
replace nb_emigres = 0 if _merge == 1
drop _merge

cap drop menage_enq
gen menage_enq = !inlist(hha, "", "##N/A##")

*--- Nombre de noms saisis dans la liste ME2B
cap drop nb_noms
gen nb_noms = 0
forvalues i = 0/59 {
	cap confirm string variable ME2B__`i'
	if !_rc replace nb_noms = nb_noms + !inlist(strtrim(ME2B__`i'), "", "##N/A##")
}

local idm interview__key HH2 HH12 HH13 rgmen hha

*==============================================================================*
*  ME1 : depuis 5 ans, des membres du ménage se sont-ils installés à l'étranger
*        et y résident-ils actuellement ?   -   Modalités : 1 Oui, 2 Non
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME1) & menage_enq == 1 & rgmen == 1
// 1 ménage (67-01-56-38, entretien non clôturé : HH14 vide)

export_err `idm' ME1 HH14 if missing(ME1) & menage_enq == 1 & rgmen == 1, fichier(Err_ME1_NA)

** 2. Vérification des sauts
count if !missing(ME1) & (menage_enq == 0 | rgmen != 1)
// RAS

** 3. Valeurs permises
count if !inlist(ME1, 1, 2) & !missing(ME1)
// RAS

count if ME1 == 1
// 24 ménages déclarent au moins un émigré

*==============================================================================*
*  ME2A : nombre de membres installés à l'étranger   -   Champ : ME1 == 1
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME2A) & ME1 == 1
// RAS

** 2. Vérification des sauts
count if !missing(ME2A) & ME1 != 1
// RAS

** 3. Valeurs permises (au moins 1 ; plus de 9 jugé peu probable par le questionnaire)
count if (ME2A < 1 | ME2A >= 10) & !missing(ME2A)
// RAS

*==============================================================================*
*  ME2B : liste des noms des émigrés   -   Champ : ME1 == 1
*==============================================================================*

** 1. Valeurs manquantes : aucun nom saisi
count if nb_noms == 0 & ME1 == 1
// RAS

** 2. Vérification des sauts
count if nb_noms > 0 & ME1 != 1
// RAS

** 4. Cohérence : nombre déclaré (ME2A) = nombre de noms (ME2B) = nombre de lignes
**    dans la base des émigrés (contrôle W2 du questionnaire)
count if ME1 == 1 & (nb_noms != ME2A | nb_emigres != ME2A)
// RAS (20 ménages avec 1 émigré, 3 avec 2, 1 avec 3)

count if nb_emigres > 0 & ME1 != 1
// RAS (pas d'émigré pour un ménage ayant répondu Non)

export_err `idm' ME1 ME2A nb_noms nb_emigres if (ME1 == 1 & (nb_noms != ME2A | nb_emigres != ME2A)) | (nb_emigres > 0 & ME1 != 1), fichier(Err_ME2A_coherence)

*--- Variables ménage nécessaires pour la partie B
keep interview__key HH2 HH12 HH13 rgmen hha ME1 ME2A ME1_date
tempfile menage_em
save `menage_em'


********************************************************************************
*  PARTIE B : NIVEAU EMIGRE (ME3 à ME9) - base QM_S5_emmigration
*  Champ : tous les émigrés listés en ME2B (la ligne n'existe que si ME1 == 1)
********************************************************************************

use "$datain_standard\QM_S5_emmigration.dta", clear

merge m:1 interview__key using `menage_em', keep(master match)
count if _merge == 1
// RAS (tous les émigrés retrouvent leur ménage)
drop _merge
// 28 émigrés

*--- Dates de référence
cap drop annee_hha mois_hha date_ref annee_ref mois_ref
gen annee_hha = real(substr(hha, 1, 4))
gen mois_hha  = real(substr(hha, 6, 2))

* ME1_date = date de l'entretien moins 5 ans (format jj-mm-aa) : début de la période
gen date_ref  = date(ME1_date, "DM20Y")
format date_ref %td
gen annee_ref = year(date_ref)
gen mois_ref  = month(date_ref)

local id interview__key emigration__id ME2B HH2 HH12 HH13 rgmen

cap drop commentaire
gen commentaire = ""

** Contrôle préalable : émigré listé alors que le ménage n'a pas répondu Oui à ME1
count if ME1 != 1
// RAS

*==============================================================================*
*  ME3 : sexe   -   Modalités : 1 Masculin, 2 Féminin
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME3)
// RAS

** 3. Valeurs permises
count if !inlist(ME3, 1, 2) & !missing(ME3)
// RAS

*==============================================================================*
*  ME4 : âge au départ   -   Valeurs : 0 à 99, 998 (ne sait pas)
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME4)
// RAS

replace commentaire = commentaire + "ME4 non renseigné; " if missing(ME4)
export_err `id' ME4 commentaire if missing(ME4), fichier(Err_ME4_NA)

** 3. Valeurs permises
count if !inrange(ME4, 0, 99) & ME4 != 998 & !missing(ME4)
// RAS

count if ME4 == 998
// 3 émigrés dont l'âge au départ est inconnu (pour information)

*==============================================================================*
*  ME5A1 : année de départ   -   Valeurs : 1960 à l'année de l'entretien, 9998
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME5A1)
// RAS

** 3. Valeurs permises
count if !inrange(ME5A1, 1960, annee_hha) & ME5A1 != 9998 & !missing(ME5A1)
// 1 émigré avec ME5A1 = 2 : l'agent a saisi le nombre d'années au lieu de l'année

replace commentaire = commentaire + "ME5A1 non valide (durée saisie au lieu de l'année); " if !inrange(ME5A1, 1960, annee_hha) & ME5A1 != 9998 & !missing(ME5A1)
export_err `id' ME5A1 ME5M1 ME5A ME5M hha commentaire if !inrange(ME5A1, 1960, annee_hha) & ME5A1 != 9998 & !missing(ME5A1), fichier(Err_ME5A1_valeurs)

*--- Correction : une durée de 0 à 5 ans est convertie en année de départ
replace ME5A1 = annee_hha - ME5A1 if inrange(ME5A1, 0, 5)
// ME5A1 = 2 devient 2024 (ME5M1 reste "Ne sait pas")

** 4. Cohérence avec la période de référence de ME1 (5 dernières années)
count if inrange(ME5A1, 1960, annee_hha) & (ME5A1 < annee_ref | (ME5A1 == annee_ref & inrange(ME5M1, 1, 12) & ME5M1 < mois_ref)) & !missing(annee_ref)
// 8 émigrés partis avant la période (2011, 2014, 2018, 4 en 2019, 2020) :
// ils sont hors champ de la question ME1. Exportés, pas supprimés.

replace commentaire = commentaire + "Départ antérieur aux 5 dernières années (hors champ ME1); " if inrange(ME5A1, 1960, annee_hha) & (ME5A1 < annee_ref | (ME5A1 == annee_ref & inrange(ME5M1, 1, 12) & ME5M1 < mois_ref)) & !missing(annee_ref)
export_err `id' ME5A1 ME5M1 ME1_date hha commentaire if inrange(ME5A1, 1960, annee_hha) & (ME5A1 < annee_ref | (ME5A1 == annee_ref & inrange(ME5M1, 1, 12) & ME5M1 < mois_ref)) & !missing(annee_ref), fichier(Err_ME5A1_hors_periode)

// Départ postérieur à la date de l'entretien
count if ME5A1 == annee_hha & inrange(ME5M1, 1, 12) & ME5M1 > mois_hha
// RAS

*==============================================================================*
*  ME5M1 : mois de départ   -   Champ : ME5A1 != 9998   -   1 à 12, 9998
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME5M1) & !missing(ME5A1) & ME5A1 != 9998
// RAS

** 2. Vérification des sauts
count if !missing(ME5M1) & (missing(ME5A1) | ME5A1 == 9998)
// RAS

** 3. Valeurs permises
count if !inrange(ME5M1, 1, 12) & ME5M1 != 9998 & !missing(ME5M1)
// RAS

count if ME5M1 == 9998
// 11 émigrés dont le mois de départ est inconnu (pour information)

*==============================================================================*
*  ME5A : depuis combien d'années est-il parti ?   -   Champ : ME5A1 == 9998
*  Valeurs : 0 à 5 (contrôle du questionnaire), 98 ou 9998 = ne sait pas
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME5A) & ME5A1 == 9998
// RAS

** 2. Vérification des sauts
count if !missing(ME5A) & ME5A1 != 9998
// RAS

** 3. Valeurs permises
count if !inrange(ME5A, 0, 5) & !inlist(ME5A, 98, 9998) & !missing(ME5A)
// RAS (1 seul émigré concerné, parti depuis 3 ans)

*==============================================================================*
*  ME5M : nombre de mois en plus de ME5A
*  Champ : ME5A renseigné et connu   -   Codes 1 (0 mois) à 12 (11 mois), 9998
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME5M) & !missing(ME5A) & !inlist(ME5A, 98, 9998)
// RAS

** 2. Vérification des sauts
count if !missing(ME5M) & (missing(ME5A) | inlist(ME5A, 98, 9998))
// RAS

** 3. Valeurs permises
// (l'ancien programme ne contrôlait que les cas où ME5A était renseigné)
count if !inrange(ME5M, 1, 12) & ME5M != 9998 & !missing(ME5M)
// RAS

*==============================================================================*
*  ME6 : niveau d'enseignement au départ
*  Champ : ME4 > 3 (y compris âge inconnu 998)   -   Modalités : 0 à 12
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME6) & ME4 > 3 & !missing(ME4)
// RAS

replace commentaire = commentaire + "ME6 non renseigné; " if missing(ME6) & ME4 > 3 & !missing(ME4)
export_err `id' ME4 ME6 commentaire if missing(ME6) & ME4 > 3 & !missing(ME4), fichier(Err_ME6_NA)

** 2. Vérification des sauts
count if !missing(ME6) & ME4 <= 3
// RAS (les 2 enfants de 1 et 3 ans n'ont pas de niveau)

** 3. Valeurs permises
count if !inrange(ME6, 0, 12) & !missing(ME6)
// RAS

** 4. Cohérence âge au départ / niveau (filtre de modalités du questionnaire)
//  4 ans ou moins : préscolaire au plus ; 5-9 ans : primaire au plus ;
//  10-12 ans : secondaire 1er cycle au plus ; 13-15 ans : secondaire 2nd cycle au plus
count if ((ME4 <= 4 & ME6 > 1) | (inrange(ME4, 5, 9) & ME6 > 2) | (inrange(ME4, 10, 12) & ME6 > 4) | (inrange(ME4, 13, 15) & ME6 > 6)) & !missing(ME6, ME4)
// RAS

export_err `id' ME4 ME6 if ((ME4 <= 4 & ME6 > 1) | (inrange(ME4, 5, 9) & ME6 > 2) | (inrange(ME4, 10, 12) & ME6 > 4) | (inrange(ME4, 13, 15) & ME6 > 6)) & !missing(ME6, ME4), fichier(Err_ME6_coherence)

*==============================================================================*
*  ME7 : pays de résidence actuel   -   Codes 1 à 216
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME7)
// RAS

** 3. Valeurs permises
// (l'ancien programme comptait aussi les valeurs manquantes)
count if !inrange(ME7, 1, 216) & !missing(ME7)
// RAS (Burkina Faso 7, France 6, Mali 3, Italie, États-Unis, Ghana, Tunisie 2 chacun...)

*==============================================================================*
*  ME8 : raison principale du départ   -   Modalités : 1 à 9
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME8)
// RAS

** 3. Valeurs permises
count if !inrange(ME8, 1, 9) & !missing(ME8)
// RAS

** 4. Cohérence (contrôle V1 du questionnaire) : moins de 15 ans au départ ne peut
**    pas partir pour chercher un emploi ou suite à une affectation de travail
count if ME4 < 15 & inlist(ME8, 3, 4)
// RAS

export_err `id' ME4 ME8 if ME4 < 15 & inlist(ME8, 3, 4), fichier(Err_ME8_coherence)

*==============================================================================*
*  ME8_Aut : autre raison à préciser   -   Champ : ME8 == 9
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME8_Aut) & ME8 == 9
// RAS

** 2. Vérification des sauts
count if !missing(ME8_Aut) & ME8 != 9
// RAS

** 4. Cohérence : précision correspondant à une modalité existante
count if ME8 == 9 & ustrregexm(ustrupper(ME8_Aut), "GRANDS? ?PARENTS|REJOINDRE|RETROUVER")
// 1 émigré ("RETROUVER SES GRANDS PARENTS") -> regroupement familial

*--- Correction
replace ME8 = 1 if ME8 == 9 & ustrregexm(ustrupper(ME8_Aut), "GRANDS? ?PARENTS|REJOINDRE|RETROUVER")
replace ME8_Aut = "" if ME8 != 9

*==============================================================================*
*  ME9 : catégorie socio-économique avant le départ
*  Modalités : 1 à 11, 9998 (ne sait pas)
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME9)
// RAS

** 3. Valeurs permises
count if !inrange(ME9, 1, 11) & ME9 != 9998 & !missing(ME9)
// RAS

count if ME9 == 9998
// 3 émigrés (pour information)

** 4. Cohérence âge au départ / catégorie
// Enfants de moins de 15 ans classés comme actifs occupés (1 à 6)
count if ME4 < 15 & inrange(ME9, 1, 6)
// 1 émigré de 14 ans "Aide familial" (exporté, pas corrigé)

export_err `id' ME4 ME8 ME9 ME9_Aut if ME4 < 15 & inrange(ME9, 1, 6), fichier(Err_ME9_coherence)

*==============================================================================*
*  ME9_Aut : précision   -   Champ : ME9 = 10 (autres inactifs) ou 11 (autres)
*==============================================================================*

** 1. Valeurs manquantes
count if missing(ME9_Aut) & inlist(ME9, 10, 11)
// RAS

** 2. Vérification des sauts
count if !missing(ME9_Aut) & !inlist(ME9, 10, 11)
// RAS

** 4. Cohérence : précisions correspondant à une modalité existante
// Enfants en bas âge classés en "Autres" -> "Autres inactifs"
count if ME9 == 11 & ME4 < 15
// 2 émigrés ("TROP JEUNE", "IL ETAIT ENCORE NOURRISSON")

// Activité commerciale classée en "Autres" -> "Indépendant non agricole"
count if ME9 == 11 & ustrregexm(ustrupper(ME9_Aut), "VENDEUR|VENDEUSE|COMMER")
// 1 émigré ("VENDEUR DE TELEPHONE")

*--- Correction
replace ME9 = 10 if ME9 == 11 & ME4 < 15
replace ME9 = 5  if ME9 == 11 & ustrregexm(ustrupper(ME9_Aut), "VENDEUR|VENDEUSE|COMMER")

// La précision n'est conservée que pour les modalités 10 et 11 (filtre du questionnaire)
replace ME9_Aut = "" if !inlist(ME9, 10, 11)


********************* SAUVEGARDE DE LA BASE DE DONNEES APUREE ******************

drop commentaire annee_hha mois_hha date_ref annee_ref mois_ref
drop HH2 HH12 HH13 rgmen hha ME1 ME2A ME1_date

save "$standard_menage\QM_S5_emmigration.dta", replace
