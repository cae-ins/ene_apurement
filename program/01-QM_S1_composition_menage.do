*================================================
*********COMPOSITION DES MENAGES

****RESPONSABLE | AUTEUR: BEN ISMAEL
*=============================================
*******************************************

//Fusion de la base "Composotion_menage" avec les bases identification, membres et autres_formes_travail et récupération de variables clés
use "$datain_standard\QM_S1_composition_menage.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH2 HH3 HH12 HH13 HH4 HH6 HH8B V1interviewkey V1MODINTR M0__0 rgmen)
drop if _merge!=3
cap drop _merge

cap drop _merge
merge 1:1 interview__key membres__id using "$datain_brute\membres.dta", keepus( membre_id_v1_IND HH14a HH14a_Aut) 
drop if _merge!=3
cap drop _merge


cap drop _merge
merge 1:1 interview__key membres__id using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus( M4Confirm) 
drop if _merge!=3
cap drop _merge

cap drop commentaire
gen commentaire=""

**# Definir l'identifiant
global ID_MEN interview__id
global ID_MEMB_MEN $ID_MEN membres__id

**# suppression préalable des doublons car ils pourraient affecter les résultats
cap drop dup
sort $ID_MEMB_MEN M0
quietly by $ID_MEMB_MEN M0 : gen dup = cond(_N==1,0,_n) 

drop if dup > 1

ta dup // doublons supprimés de la base

**# supprimer les espaces au tour des variables textes dans la base
ds, has(type string)
foreach var of varlist `r(varlist)'{
	replace `var' =  ustrregexra(`var', "\s+$", "")
	replace `var' =  strltrim(`var')
}


**************************Controle de la section, question par question *************************************

*------------------------------------------------------------
* M0 : Noms et prénoms des membres des ménages
*------------------------------------------------------------

// M0 capte les noms et prénoms des membres de ménages et visiteurs. Nous allons donc vérifier si au moins un nom et prénoms dans tous les ménages enquêtés en nouservant de la question M0__0 qui capte le premier nom et prénoms des mémbres des ménages

count if M0__0 == "" // Pas de valeurs manquantes
*drop if M0__0 == ""// Supprimer les observations pour lesquelles ce champs est vide


*------------------------------------------------------------
* M1A : Individus en réinterrogation non interrogés
*------------------------------------------------------------
// M1A. Cette variable capte si des membres de ménages recensés sont partis du ménage ou si d'autres personnes sont venues dans le ménages et ont l'intention de faire plus de 6 mois (Cette question concerne les réintérrogations)

gen flag_M1A_missing = (M1A==.a & membre_id_v1!="##N/A##")

count if flag_M1A_missing
*1040 personnes n'ont pas répondu à cette question

replace commentaire = "Le téléopérateur devait renseigner la question M1A mais ne l'a pas fait (entretiens perdus)" if flag_M1A_missing

* Export des cas problématiques
count if flag_M1A_missing
if r(N)>0 {
export excel interview__key HH2 HH12 HH13 M1A membre_id_v1 V1MODINTR rgmen AgeAnnee M4Confirm commentaire ///
using "$folderpath/document/comp_menage_six_mois_reinterrogation" ///
if flag_M1A_missing, firstrow(varl) replace
}

* Suppression des observations problématiques (Ceux qui n'ont pas répondu)
*cap drop if flag_M1A_missing

* Vérifier qu'il ne reste aucun cas
count if M1A==.a & membre_id_v1!="##N/A##"

* Vérifier cohérence des réponses
count if !inlist(M1A,1,2,3) & membre_id_v1 !="##N/A##"

*------------------------------------------------------------
* M1 : Nombre de mois vécus dans le ménage au cours des 12 derniers mois
*------------------------------------------------------------

* 1. Individus de la 1ère interrogation

count if missing(M1) & membre_id_v1 == "##N/A##" & rgmen==1
*19 personnes n'ont pas répondu

replace commentaire = ///
"Individu de la 1ère interrogation pour lequel le nombre de mois vécus dans le ménage (M1) n'a pas été renseigné." ///
if missing(M1) & membre_id_v1 == "##N/A##" & rgmen==1

count if missing(M1) & membre_id_v1 == "##N/A##" & rgmen==1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR ///
    rgmen AgeAnnee M4Confirm commentaire ///
    using "$folderpath/document/M1_terrain_perdu_v1.xlsx" ///
    if missing(M1) & membre_id_v1 == "##N/A##" & rgmen==1 , firstrow(varl) replace
}

* 2. Individus de la 2ème, 3e ou 4e interrogation

count if missing(M1) & membre_id_v1 == "##N/A##" & rgmen>=2 & !missing(rgmen)
*167 personnes n'ont pas répondu

replace commentaire = ///
"Individu de la 2ème, 3e ou 4e interrogation pour lequel le nombre de mois vécus dans le ménage (M1) n'a pas été renseigné." ///
if missing(M1) & membre_id_v1 == "##N/A##" & rgmen>=2 & !missing(rgmen)

count if missing(M1) & membre_id_v1 == "##N/A##" & rgmen>=2 & !missing(rgmen)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR ///
    rgmen AgeAnnee M4Confirm commentaire ///
    using "$folderpath/document/M1_terrain_perdu_v2.xlsx" ///
    if missing(M1) & membre_id_v1 == "##N/A##" & rgmen>=2 & !missing(rgmen) , firstrow(varl) replace
}

* 3. Tous les individus concernés

count if missing(M1) & membre_id_v1 == "##N/A##"
*186 personnes n'ont pas répondu

replace commentaire = ///
"L'agent enquêteur devait renseigner la question M1 mais elle est restée vide." ///
if missing(M1) & membre_id_v1 == "##N/A##"

count if missing(M1) & membre_id_v1 == "##N/A##"
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR ///
    rgmen commentaire ///
    using "$folderpath/document/M1_non_renseigne.xlsx" ///
    if missing(M1) & membre_id_v1 == "##N/A##", firstrow(varl) replace
}

*** Suppression des individus pour lesquelles la durée dans le ménage n'est pas renseigné
cap drop if missing(M1) & membre_id_v1 == "##N/A##"

* Vérifier qu'il ne reste aucun cas
count if missing(M1) & membre_id_v1 == "##N/A##"

* 4. Vérification des réponses valides
count if inlist(M1,1,2,3) & membre_id_v1 != "##N/A##"


*------------------------------------------------------------
* M2 : Nombre de mois vécus dans le ménage, si moins de 6 mois
*------------------------------------------------------------

* 1. Individus qui devraient répondre mais M2 manquant
count if missing(M2) & (M1==1 | M1A==1)
*RAS

*replace commentaire = ///
*"M2 non renseigné alors que l'individu a déclaré vivre moins de 6 mois dans le ménage." ///
*if missing(M2) & (M1==1 | M1A==1)

* 2. Individus ayant répondu alors qu'ils ne devraient pas
count if !missing(M2) & !(M1==1 | M1A==1)
*RAS

*replace commentaire = ///
*"M2 renseigné alors que l'individu ne devrait pas répondre à cette question." ///
*if !missing(M2) & !(M1==1 | M1A==1)

* 3. Analyse du statut de résidence
count if Statut_Res != 1
*1713 individus déclarés nonn résidents

replace commentaire = ///
"Individu déclaré non résident (Statut_Res ≠ 1). Vérification nécessaire." ///
if Statut_Res != 1 & missing(commentaire)

* 4. Export des individus concernés
count if Statut_Res !=1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 Statut_Res commentaire rgmen ///
    using "$folderpath/document/comp_menage_stat_res.xlsx" ///
    if Statut_Res !=1, firstrow(varl) replace
}

* 5. Option : restriction aux ménages résidents
*drop if Statut_Res !=1

*------------------------------------------------------------
* M3 : %rostertitle% a-t-il/elle passé la nuit dernière dans le ménage ?
*-----------------------------------------------------------

* 1. Résidents pour lesquels M3 n'a pas été renseigné
count if missing(M3) & Statut_Res==1
*54 personnes n'ont pas répondu

replace commentaire = "Individu résident pour lequel la question M3 (présence la nuit dernière) n'a pas été renseignée." if missing(M3) & Statut_Res==1

* 2. Vérification : individus non résidents ayant répondu
count if !missing(M3) & Statut_Res!=1
*RAS

* 3. Valeurs légales
count if !inlist(M3,1,2) & !missing(M3)
*RAS

*replace commentaire = ///
*"M3 renseigné pour un individu non résident (question potentiellement non applicable, à vérifier)." ///
*if !missing(M3) & Statut_Res!=1

*------------------------------------------------------------
* M4A : Confirmation du lien de parenté des membres du ménage déjà enquêtés avec le CM
*------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1
*55 liend de parenté n'ont pas été confirmés

replace commentaire = "Individu pour lequel le lien de parenté () n'a pas été confirmé." if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1

*Exportation des individus potentiellement concernés
count if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M4A membre_id_v1 V1MODINTR commentaire rgmen AgeAnnee M4Confirm using "$folderpath/document/comp_menage_passe_lien_confirm" if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1, firstrow(varl) replace
}

* 2. Valeurs légales
count if !inlist(M4A,1,2) & !missing(M4A)
*RAS

* 3. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M4A) & (membre_id_v1 == "##N/A##" | V1M4 ==.a | Statut_Res !=1) 
// RAS
 
*replace commentaire = "Cet individu n'avait pas le droit de répondre à cette question." if !missing(M4A) & (membre_id_v1 == "##N/A##" | V1M4 ==.a | Statut_Res !=1)


*------------------------------------------------------------
* M4 : Lien de parenté avec le CM (Première interrogation)
*------------------------------------------------------------
* 1. Valeurs manquantes
count if missing(M4) & Statut_Res==1 & (membre_id_v1 == "##N/A##" | missing(V1M4) | M4A==2)
*66 personnes pour qui le lien de parenté avec le chef de ménage n'a pas été précisé

replace commentaire = "Individu pour lequel le lien de parenté () n'a pas été renseigné." if missing(M4) & Statut_Res==1 & (membre_id_v1 == "##N/A##" | V1M4==.a | M4A==2)

*Exportation des individus potentiellement concernés
count if missing(M4) & Statut_Res==1 & (membre_id_v1 == "##N/A##" | V1M4==.a | M4A==2)
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M4A membre_id_v1 V1MODINTR commentaire rgmen AgeAnnee M4 using "$folderpath/document/comp_menage_passe_lien_parente_Question_M4" if missing(M4) & Statut_Res==1 & (membre_id_v1 == "##N/A##" | V1M4==.a | M4A==2), firstrow(varl) replace
}

* 2. Valeurs légales
count if !inrange(M4,1,8) & !missing(M4)


* 3. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M4) & (Statut_Res !=1 | (membre_id_v1 != "##N/A##" & V1M4 !=.a & M4A !=2)) 
// RAS
 
*------------------------------------------------------------
* M5. Quel est le sexe de %rostertitle% ?
*------------------------------------------------------------

*1. Valeurs manquantes
count if missing(M5) & Statut_Res==1 
* 63 personnes pour qui on a pas le sexe : agent teleoperateur

ta rgmen if missing(M5) & Statut_Res==1
*Les personnes pour qui le sexe n'a pas été précisé sont en 2e, 3e et 4e interrogation.
replace commentaire="Les agents n'ont pas renseigné  le sexe " if missing(M5) & Statut_Res==1 

**Exportation des individus potentiellement concernés
count if missing(M5) & Statut_Res==1 
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M5 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_sexe" if missing(M5) & Statut_Res==1 , firstrow(varl) replace
}
**

*Incoherence sur le sexe entre T1-2025 (terrain) et T4-2024 (teleoperateur)

*5. CORRECTION :

*Récupérer le sexe du chef de ménage dans chaque ménage
bysort interview__key: egen sexe_chef = max(cond(V1M4==1, M5, .))
*Remplacer le sexe manquant des époux/se par le sexe opposé
replace M5 = 2 if missing(M5) & V1M4==2 & sexe_chef==1 & Statut_Res==1
replace M5 = 1 if missing(M5) & V1M4==2 & sexe_chef==2 & Statut_Res==1

****Le principe de cette correction est de faire l'hypothèse que les sexe renseigné par l'agent terrain est plus correct que celui renseigne par le teleoperateur dans la situation ou le sexe renseigner par le teleoperateur est different de celui de l'agent terrain.

replace M5 = 1 if interview__key=="65-46-32-44" & membres__id ==3
replace M5 = 2 if interview__key=="39-01-96-89" & membres__id ==4
replace M5 = 2 if interview__key=="39-01-96-89" & membres__id ==11
replace M5 = 2 if interview__key=="97-77-98-81" & membres__id ==1
replace M5 = 1 if interview__key=="27-46-08-57" & membres__id ==3
replace M5 = 2 if interview__key=="31-43-96-45" & membres__id ==6
replace M5 = 2 if interview__key=="46-39-89-02" & membres__id ==3
replace M5 = 2 if interview__key=="41-93-01-85" & membres__id ==3
replace M5 = 2 if interview__key=="36-93-29-81" & membres__id ==3
replace M5 = 1 if interview__key=="23-79-16-12" & membres__id ==5
replace M5 = 2 if interview__key=="47-46-21-55" & membres__id ==3
replace M5 = 2 if interview__key=="34-62-91-31" & membres__id ==6
replace M5 = 1 if interview__key=="47-36-83-09" & membres__id ==3
replace M5 = 2 if interview__key=="95-43-36-92" & membres__id ==3
replace M5 = 1 if interview__key=="90-47-87-14" & membres__id ==7
replace M5 = 2 if interview__key=="39-52-86-88" & membres__id ==2
replace M5 = 2 if interview__key=="39-52-86-88" & membres__id ==3
replace M5 = 1 if interview__key=="33-51-18-11" & membres__id ==9
replace M5 = 2 if interview__key=="02-97-02-48" & membres__id ==3
replace M5 = 2 if interview__key=="85-73-80-34" & membres__id ==7
replace M5 = 1 if interview__key=="21-73-82-76" & membres__id ==7
replace M5 = 2 if interview__key=="05-22-50-61" & membres__id ==5
replace M5 = 2 if interview__key=="67-86-52-63" & membres__id ==7
replace M5 = 2 if interview__key=="90-99-29-91" & membres__id ==6
replace M5 = 2 if interview__key=="90-99-29-91" & membres__id ==7
replace M5 = 2 if interview__key=="25-89-92-84" & membres__id ==4
replace M5 = 1 if interview__key=="66-64-27-66" & membres__id ==3
replace M5 = 1 if interview__key=="66-64-27-66" & membres__id ==6
replace M5 = 1 if interview__key=="27-36-90-29" & membres__id ==3
replace M5 = 1 if interview__key=="33-54-94-34" & membres__id ==3
replace M5 = 2 if interview__key=="42-55-23-55" & membres__id ==4
replace M5 = 2 if interview__key=="42-55-23-55" & membres__id ==5
replace M5 = 2 if interview__key=="98-26-71-49" & membres__id ==3
replace M5 = 2 if interview__key=="79-53-47-28" & membres__id ==7
replace M5 = 1 if interview__key=="89-99-84-88" & membres__id ==3
replace M5 = 1 if interview__key=="89-99-84-88" & membres__id ==6
replace M5 = 1 if interview__key=="58-17-14-39" & membres__id ==8
replace M5 = 1 if interview__key=="05-11-50-06" & membres__id ==4
replace M5 = 1 if interview__key=="40-61-54-89" & membres__id ==2
replace M5 = 2 if interview__key=="84-40-37-78" & membres__id ==3
replace M5 = 1 if interview__key=="20-80-23-94" & membres__id ==4
replace M5 = 1 if interview__key=="08-33-07-67" & membres__id ==4
replace M5 = 1 if interview__key=="49-16-99-90" & membres__id ==3
replace M5 = 1 if interview__key=="05-28-21-99" & membres__id ==2
replace M5 = 2 if interview__key=="05-28-21-99" & membres__id ==3
replace M5 = 1 if interview__key=="32-88-84-65" & membres__id ==4
replace M5 = 1 if interview__key=="22-41-69-34" & membres__id ==1
replace M5 = 1 if interview__key=="03-92-57-08" & membres__id ==1
replace M5 = 1 if interview__key=="67-41-83-85" & membres__id ==3
replace M5 = 1 if interview__key=="67-41-83-85" & membres__id ==4
replace M5 = 2 if interview__key=="99-77-04-87" & membres__id ==8
replace M5 = 2 if interview__key=="99-77-04-87" & membres__id ==12
replace M5 = 2 if interview__key=="75-77-71-77" & membres__id ==1
replace M5 = 1 if interview__key=="78-38-11-42" & membres__id ==4
replace M5 = 2 if interview__key=="78-38-11-42" & membres__id ==6
replace M5 = 1 if interview__key=="61-68-80-75" & membres__id ==6
replace M5 = 2 if interview__key=="77-18-60-99" & membres__id ==7
replace M5 = 2 if interview__key=="99-99-17-86" & membres__id ==4
replace M5 = 1 if interview__key=="11-74-78-63" & membres__id ==1
replace M5 = 2 if interview__key=="37-93-10-87" & membres__id ==8
replace M5 = 2 if interview__key=="18-35-81-09" & membres__id ==8
replace M5 = 1 if interview__key=="37-23-55-55" & membres__id ==1
replace M5 = 2 if interview__key=="37-23-55-55" & membres__id ==2
replace M5 = 1 if interview__key=="37-23-55-55" & membres__id ==4
replace M5 = 1 if interview__key=="38-96-83-41" & membres__id ==3
replace M5 = 2 if interview__key=="00-95-33-25" & membres__id ==1
replace M5 = 1 if interview__key=="48-44-71-45" & membres__id ==1
replace M5 = 1 if interview__key=="13-37-73-54" & membres__id ==2
replace M5 = 2 if interview__key=="73-34-48-76" & membres__id ==5
replace M5 = 1 if interview__key=="84-05-24-20" & membres__id ==4
replace M5 = 2 if interview__key=="68-29-86-09" & membres__id ==4
replace M5 = 1 if interview__key=="86-78-52-13" & membres__id ==5
replace M5 = 1 if interview__key=="09-92-12-91" & membres__id ==5
replace M5 = 1 if interview__key=="72-21-32-19" & membres__id ==3
replace M5 = 1 if interview__key=="28-10-51-94" & membres__id ==4
replace M5 = 2 if interview__key=="78-41-72-62" & membres__id ==1
replace M5 = 2 if interview__key=="40-08-28-21" & membres__id ==10
replace M5 = 1 if interview__key=="40-08-28-21" & membres__id ==12
replace M5 = 2 if interview__key=="26-42-92-74" & membres__id ==6
replace M5 = 2 if interview__key=="26-42-92-74" & membres__id ==12
replace M5 = 2 if interview__key=="20-62-14-10" & membres__id ==6
replace M5 = 1 if interview__key=="24-06-64-62" & membres__id ==3
replace M5 = 2 if interview__key=="86-51-00-52" & membres__id ==6
replace M5 = 2 if interview__key=="94-37-52-34" & membres__id ==9
replace M5 = 1 if interview__key=="60-96-75-93" & membres__id ==6
replace M5 = 2 if interview__key=="42-43-41-01" & membres__id ==3
replace M5 = 2 if interview__key=="42-43-41-01" & membres__id ==5
replace M5 = 2 if interview__key=="02-86-79-80" & membres__id ==19
replace M5 = 1 if interview__key=="27-60-77-79" & membres__id ==4
replace M5 = 2 if interview__key=="27-60-77-79" & membres__id ==5
replace M5 = 1 if interview__key=="45-18-05-36" & membres__id ==3
replace M5 = 2 if interview__key=="05-48-27-60" & membres__id ==4
replace M5 = 1 if interview__key=="58-15-32-89" & membres__id ==3
replace M5 = 2 if interview__key=="03-72-26-50" & membres__id ==8
replace M5 = 2 if interview__key=="95-03-47-77" & membres__id ==4
replace M5 = 1 if interview__key=="14-01-93-07" & membres__id ==8
replace M5 = 1 if interview__key=="87-65-65-77" & membres__id ==5
replace M5 = 2 if interview__key=="00-27-55-08" & membres__id ==5
replace M5 = 1 if interview__key=="81-16-22-87" & membres__id ==4
replace M5 = 2 if interview__key=="73-45-07-02" & membres__id ==4
replace M5 = 1 if interview__key=="63-73-25-47" & membres__id ==1
replace M5 = 2 if interview__key=="10-52-32-91" & membres__id ==11
replace M5 = 1 if interview__key=="01-51-69-17" & membres__id ==7
replace M5 = 2 if interview__key=="01-51-69-17" & membres__id ==8
replace M5 = 1 if interview__key=="84-51-35-01" & membres__id ==3
replace M5 = 1 if interview__key=="35-21-97-65" & membres__id ==1
replace M5 = 2 if interview__key=="01-50-44-68" & membres__id ==3
replace M5 = 2 if interview__key=="44-26-94-70" & membres__id ==4
replace M5 = 2 if interview__key=="11-06-99-85" & membres__id ==4
replace M5 = 2 if interview__key=="11-06-99-85" & membres__id ==5
replace M5 = 2 if interview__key=="07-69-47-65" & membres__id ==2
replace M5 = 2 if interview__key=="63-68-64-56" & membres__id ==3
replace M5 = 1 if interview__key=="64-83-36-02" & membres__id ==6
replace M5 = 1 if interview__key=="24-68-73-23" & membres__id ==3
replace M5 = 1 if interview__key=="58-80-53-13" & membres__id ==3
replace M5 = 2 if interview__key=="22-20-94-14" & membres__id ==3
replace M5 = 2 if interview__key=="54-90-12-21" & membres__id ==1
replace M5 = 1 if interview__key=="20-63-38-90" & membres__id ==4
replace M5 = 2 if interview__key=="93-63-74-80" & membres__id ==2
replace M5 = 2 if interview__key=="35-43-09-57" & membres__id ==7
replace M5 = 2 if interview__key=="89-94-28-38" & membres__id ==5
replace M5 = 1 if interview__key=="72-67-39-86" & membres__id ==5
replace M5 = 2 if interview__key=="23-27-36-27" & membres__id ==5
replace M5 = 1 if interview__key=="23-27-36-27" & membres__id ==6
replace M5 = 2 if interview__key=="73-81-00-26" & membres__id ==4
replace M5 = 2 if interview__key=="54-23-13-00" & membres__id ==6
replace M5 = 1 if interview__key=="77-05-76-45" & membres__id ==1
replace M5 = 1 if interview__key=="70-38-87-10" & membres__id ==11
replace M5 = 2 if interview__key=="21-45-43-29" & membres__id ==5
replace M5 = 2 if interview__key=="86-26-26-60" & membres__id ==3
replace M5 = 1 if interview__key=="13-76-79-69" & membres__id ==3
replace M5 = 2 if interview__key=="86-90-11-96" & membres__id ==4
replace M5 = 2 if interview__key=="86-90-11-96" & membres__id ==6
replace M5 = 2 if interview__key=="86-90-11-96" & membres__id ==10
replace M5 = 1 if interview__key=="42-38-92-79" & membres__id ==7
replace M5 = 1 if interview__key=="73-61-40-26" & membres__id ==3
replace M5 = 1 if interview__key=="32-01-95-57" & membres__id ==5
replace M5 = 2 if interview__key=="32-01-95-57" & membres__id ==6
replace M5 = 1 if interview__key=="32-01-95-57" & membres__id ==7
replace M5 = 1 if interview__key=="45-93-85-34" & membres__id ==8
replace M5 = 1 if interview__key=="31-88-44-09" & membres__id ==3
replace M5 = 1 if interview__key=="12-47-32-50" & membres__id ==1
replace M5 = 2 if interview__key=="00-39-44-95" & membres__id ==3
replace M5 = 1 if interview__key=="92-72-84-35" & membres__id ==13
replace M5 = 2 if interview__key=="92-72-84-35" & membres__id ==14
replace M5 = 2 if interview__key=="96-26-83-91" & membres__id ==2
replace M5 = 2 if interview__key=="96-26-83-91" & membres__id ==4
replace M5 = 2 if interview__key=="49-50-46-34" & membres__id ==8
replace M5 = 1 if interview__key=="36-42-09-14" & membres__id ==3
replace M5 = 2 if interview__key=="27-84-27-40" & membres__id ==16
replace M5 = 2 if interview__key=="17-45-05-73" & membres__id ==15
replace M5 = 1 if interview__key=="41-97-73-30" & membres__id ==2
replace M5 = 2 if interview__key=="07-95-23-37" & membres__id ==5
replace M5 = 2 if interview__key=="05-55-46-04" & membres__id ==4
replace M5 = 2 if interview__key=="05-55-46-04" & membres__id ==11
replace M5 = 2 if interview__key=="25-21-09-36" & membres__id ==3
replace M5 = 1 if interview__key=="85-53-01-57" & membres__id ==1
replace M5 = 1 if interview__key=="81-04-22-53" & membres__id ==5
replace M5 = 2 if interview__key=="10-47-61-59" & membres__id ==3
replace M5 = 1 if interview__key=="01-70-16-69" & membres__id ==5
replace M5 = 2 if interview__key=="31-06-14-02" & membres__id ==2
replace M5 = 1 if interview__key=="52-85-24-07" & membres__id ==4
replace M5 = 1 if interview__key=="52-85-24-07" & membres__id ==5
replace M5 = 2 if interview__key=="18-23-78-24" & membres__id ==4
replace M5 = 2 if interview__key=="18-23-78-24" & membres__id ==5
replace M5 = 2 if interview__key=="25-48-56-97" & membres__id ==1
replace M5 = 2 if interview__key=="23-07-57-69" & membres__id ==3
replace M5 = 2 if interview__key=="23-07-57-69" & membres__id ==4
replace M5 = 2 if interview__key=="32-45-60-54" & membres__id ==11
replace M5 = 2 if interview__key=="22-03-20-09" & membres__id ==4
replace M5 = 2 if interview__key=="25-76-82-71" & membres__id ==6
replace M5 = 1 if interview__key=="56-56-68-18" & membres__id ==2
replace M5 = 2 if interview__key=="74-95-50-17" & membres__id ==8
replace M5 = 2 if interview__key=="74-95-50-17" & membres__id ==15
replace M5 = 2 if interview__key=="10-01-98-57" & membres__id ==16
replace M5 = 2 if interview__key=="38-00-12-57" & membres__id ==2
replace M5 = 2 if interview__key=="35-65-28-37" & membres__id ==4
replace M5 = 2 if interview__key=="25-34-77-64" & membres__id ==3
replace M5 = 2 if interview__key=="60-83-28-65" & membres__id ==10
replace M5 = 1 if interview__key=="89-32-73-00" & membres__id ==4
replace M5 = 2 if interview__key=="02-17-28-94" & membres__id ==3
replace M5 = 2 if interview__key=="12-65-16-14" & membres__id ==1
replace M5 = 1 if interview__key=="94-48-45-38" & membres__id ==2
replace M5 = 2 if interview__key=="75-12-08-36" & membres__id ==8
replace M5 = 1 if interview__key=="61-16-30-94" & membres__id ==3
replace M5 = 2 if interview__key=="43-19-23-80" & membres__id ==4
replace M5 = 2 if interview__key=="90-65-77-08" & membres__id ==4
replace M5 = 1 if interview__key=="99-77-02-31" & membres__id ==3
replace M5 = 2 if interview__key=="99-77-02-31" & membres__id ==8
replace M5 = 2 if interview__key=="26-54-75-11" & membres__id ==5
replace M5 = 1 if interview__key=="33-96-91-36" & membres__id ==5
replace M5 = 1 if interview__key=="33-96-91-36" & membres__id ==6
replace M5 = 2 if interview__key=="85-96-46-46" & membres__id ==4
replace M5 = 2 if interview__key=="26-32-55-34" & membres__id ==11
replace M5 = 2 if interview__key=="17-31-60-58" & membres__id ==9
replace M5 = 1 if interview__key=="45-73-69-42" & membres__id ==5
replace M5 = 2 if interview__key=="10-40-09-62" & membres__id ==5
replace M5 = 2 if interview__key=="03-14-52-31" & membres__id ==3
replace M5 = 2 if interview__key=="84-58-35-54" & membres__id ==5
replace M5 = 1 if interview__key=="56-69-23-80" & membres__id ==3
replace M5 = 1 if interview__key=="06-61-47-57" & membres__id ==5
replace M5 = 1 if interview__key=="28-99-08-25" & membres__id ==4
replace M5 = 2 if interview__key=="28-99-08-25" & membres__id ==6
replace M5 = 1 if interview__key=="11-01-93-49" & membres__id ==2
replace M5 = 2 if interview__key=="40-59-80-61" & membres__id ==4
replace M5 = 2 if interview__key=="79-11-45-26" & membres__id ==3
replace M5 = 1 if interview__key=="82-18-07-48" & membres__id ==3
replace M5 = 2 if interview__key=="82-18-07-48" & membres__id ==4
replace M5 = 2 if interview__key=="55-21-71-58" & membres__id ==5
replace M5 = 2 if interview__key=="04-63-64-70" & membres__id ==7
replace M5 = 2 if interview__key=="89-46-00-99" & membres__id ==5
replace M5 = 1 if interview__key=="74-80-19-27" & membres__id ==5
replace M5 = 1 if interview__key=="49-86-39-26" & membres__id ==3
replace M5 = 1 if interview__key=="55-17-57-23" & membres__id ==4
replace M5 = 2 if interview__key=="34-63-31-92" & membres__id ==6
replace M5 = 2 if interview__key=="44-42-75-86" & membres__id ==1
replace M5 = 2 if interview__key=="04-60-60-57" & membres__id ==1
replace M5 = 1 if interview__key=="76-21-64-48" & membres__id ==5
replace M5 = 1 if interview__key=="47-15-70-98" & membres__id ==4
replace M5 = 1 if interview__key=="60-28-73-55" & membres__id ==5
replace M5 = 1 if interview__key=="47-81-27-63" & membres__id ==5
replace M5 = 1 if interview__key=="02-26-03-31" & membres__id ==3
replace M5 = 2 if interview__key=="25-50-05-34" & membres__id ==5
replace M5 = 1 if interview__key=="07-92-64-98" & membres__id ==2
replace M5 = 2 if interview__key=="07-22-93-08" & membres__id ==1
replace M5 = 1 if interview__key=="82-63-83-89" & membres__id ==3
replace M5 = 1 if interview__key=="85-39-14-46" & membres__id ==6
replace M5 = 1 if interview__key=="75-49-62-99" & membres__id ==1
replace M5 = 2 if interview__key=="08-35-47-22" & membres__id ==1
replace M5 = 1 if interview__key=="99-95-64-38" & membres__id ==4
replace M5 = 2 if interview__key=="03-49-78-55" & membres__id ==1
replace M5 = 1 if interview__key=="88-29-38-98" & membres__id ==1
replace M5 = 2 if interview__key=="45-86-45-64" & membres__id ==3
replace M5 = 1 if interview__key=="45-86-45-64" & membres__id ==4
replace M5 = 1 if interview__key=="87-73-85-84" & membres__id ==3
replace M5 = 1 if interview__key=="90-60-64-17" & membres__id ==6
replace M5 = 1 if interview__key=="08-75-89-33" & membres__id ==3
replace M5 = 2 if interview__key=="35-62-88-75" & membres__id ==4
replace M5 = 2 if interview__key=="68-83-86-98" & membres__id ==5
replace M5 = 1 if interview__key=="65-01-52-66" & membres__id ==7
replace M5 = 1 if interview__key=="65-01-52-66" & membres__id ==12
replace M5 = 2 if interview__key=="03-94-18-89" & membres__id ==4
replace M5 = 1 if interview__key=="07-50-05-16" & membres__id ==3
replace M5 = 2 if interview__key=="54-62-14-63" & membres__id ==5
replace M5 = 1 if interview__key=="15-90-33-13" & membres__id ==4
replace M5 = 1 if interview__key=="11-64-89-45" & membres__id ==3
replace M5 = 1 if interview__key=="88-10-78-00" & membres__id ==5
replace M5 = 1 if interview__key=="00-32-93-12" & membres__id ==5
replace M5 = 2 if interview__key=="49-04-62-96" & membres__id ==7
replace M5 = 1 if interview__key=="66-85-12-70" & membres__id ==9
replace M5 = 1 if interview__key=="87-06-42-75" & membres__id ==3
replace M5 = 1 if interview__key=="85-83-12-26" & membres__id ==3
replace M5 = 2 if interview__key=="00-77-38-39" & membres__id ==17
replace M5 = 1 if interview__key=="92-22-45-14" & membres__id ==4
replace M5 = 2 if interview__key=="32-35-34-68" & membres__id ==6
replace M5 = 2 if interview__key=="32-90-99-05" & membres__id ==3
replace M5 = 1 if interview__key=="56-25-59-46" & membres__id ==1
replace M5 = 2 if interview__key=="73-16-62-48" & membres__id ==4
replace M5 = 1 if interview__key=="31-67-21-24" & membres__id ==6
replace M5 = 1 if interview__key=="11-58-12-59" & membres__id ==8
replace M5 = 1 if interview__key=="59-95-36-73" & membres__id ==2
replace M5 = 1 if interview__key=="59-95-36-73" & membres__id ==3
replace M5 = 1 if interview__key=="67-66-43-40" & membres__id ==3
replace M5 = 1 if interview__key=="67-66-43-40" & membres__id ==4
replace M5 = 2 if interview__key=="09-31-60-60" & membres__id ==2
replace M5 = 1 if interview__key=="25-05-91-23" & membres__id ==1
replace M5 = 2 if interview__key=="47-87-37-48" & membres__id ==3
replace M5 = 1 if interview__key=="47-87-37-48" & membres__id ==8
replace M5 = 1 if interview__key=="44-78-89-06" & membres__id ==1
replace M5 = 1 if interview__key=="58-71-61-87" & membres__id ==3
replace M5 = 1 if interview__key=="48-46-76-71" & membres__id ==3
replace M5 = 2 if interview__key=="04-88-30-65" & membres__id ==4
replace M5 = 2 if interview__key=="12-44-53-51" & membres__id ==2
replace M5 = 1 if interview__key=="00-92-02-42" & membres__id ==5
replace M5 = 2 if interview__key=="06-65-94-78" & membres__id ==5
replace M5 = 1 if interview__key=="45-08-02-33" & membres__id ==6
replace M5 = 1 if interview__key=="94-97-78-84" & membres__id ==3
replace M5 = 1 if interview__key=="72-14-48-73" & membres__id ==3
replace M5 = 1 if interview__key=="46-54-49-25" & membres__id ==1
replace M5 = 2 if interview__key=="46-54-49-25" & membres__id ==2
replace M5 = 2 if interview__key=="55-10-53-10" & membres__id ==11
replace M5 = 2 if interview__key=="27-50-16-01" & membres__id ==4
replace M5 = 2 if interview__key=="53-01-57-02" & membres__id ==5
replace M5 = 1 if interview__key=="53-01-57-02" & membres__id ==13
replace M5 = 2 if interview__key=="83-11-85-12" & membres__id ==3
replace M5 = 2 if interview__key=="84-79-11-31" & membres__id ==2
replace M5 = 1 if interview__key=="84-79-11-31" & membres__id ==8
replace M5 = 2 if interview__key=="59-67-25-49" & membres__id ==3
replace M5 = 1 if interview__key=="49-97-95-95" & membres__id ==5
replace M5 = 2 if interview__key=="41-34-58-22" & membres__id ==3
replace M5 = 1 if interview__key=="82-01-62-43" & membres__id ==1
replace M5 = 1 if interview__key=="81-58-61-17" & membres__id ==5
replace M5 = 2 if interview__key=="62-55-66-86" & membres__id ==5
replace M5 = 1 if interview__key=="75-18-34-95" & membres__id ==1
replace M5 = 2 if interview__key=="77-65-16-46" & membres__id ==2
replace M5 = 2 if interview__key=="70-61-15-64" & membres__id ==5
replace M5 = 1 if interview__key=="54-70-25-43" & membres__id ==3
replace M5 = 2 if interview__key=="06-62-78-67" & membres__id ==11
replace M5 = 2 if interview__key=="06-62-78-67" & membres__id ==15
replace M5 = 2 if interview__key=="47-69-99-23" & membres__id ==4
replace M5 = 2 if interview__key=="40-65-66-84" & membres__id ==1
replace M5 = 2 if interview__key=="40-65-66-84" & membres__id ==3
replace M5 = 1 if interview__key=="88-86-33-34" & membres__id ==3
replace M5 = 2 if interview__key=="09-00-71-61" & membres__id ==3
replace M5 = 1 if interview__key=="09-00-71-61" & membres__id ==4
replace M5 = 1 if interview__key=="17-57-05-81" & membres__id ==5
replace M5 = 2 if interview__key=="00-68-81-50" & membres__id ==7
replace M5 = 2 if interview__key=="29-52-36-84" & membres__id ==2
replace M5 = 2 if interview__key=="91-44-74-72" & membres__id ==13
replace M5 = 1 if interview__key=="60-92-18-66" & membres__id ==5
replace M5 = 1 if interview__key=="31-72-88-97" & membres__id ==5
replace M5 = 2 if interview__key=="57-41-38-54" & membres__id ==1
replace M5 = 2 if interview__key=="64-06-91-19" & membres__id ==1
replace M5 = 2 if interview__key=="33-71-99-98" & membres__id ==5
replace M5 = 1 if interview__key=="69-77-65-90" & membres__id ==5
replace M5 = 2 if interview__key=="69-77-65-90" & membres__id ==7
replace M5 = 2 if interview__key=="47-74-38-04" & membres__id ==6
replace M5 = 2 if interview__key=="07-34-87-73" & membres__id ==2
replace M5 = 1 if interview__key=="07-34-87-73" & membres__id ==3
replace M5 = 1 if interview__key=="15-54-92-61" & membres__id ==6
replace M5 = 1 if interview__key=="84-72-89-07" & membres__id ==4
replace M5 = 1 if interview__key=="57-48-54-73" & membres__id ==7
replace M5 = 2 if interview__key=="20-34-97-31" & membres__id ==10
replace M5 = 1 if interview__key=="08-19-80-62" & membres__id ==5
replace M5 = 1 if interview__key=="08-19-80-62" & membres__id ==7
replace M5 = 2 if interview__key=="42-23-22-30" & membres__id ==4
replace M5 = 2 if interview__key=="62-71-35-99" & membres__id ==7
replace M5 = 2 if interview__key=="66-38-11-92" & membres__id ==4
replace M5 = 1 if interview__key=="66-38-11-92" & membres__id ==5
replace M5 = 2 if interview__key=="47-05-88-87" & membres__id ==3
replace M5 = 2 if interview__key=="47-05-88-87" & membres__id ==11
replace M5 = 1 if interview__key=="98-06-58-97" & membres__id ==5
replace M5 = 1 if interview__key=="79-65-56-49" & membres__id ==5
replace M5 = 1 if interview__key=="80-28-79-67" & membres__id ==6
replace M5 = 1 if interview__key=="59-52-80-80" & membres__id ==8
replace M5 = 2 if interview__key=="74-33-09-55" & membres__id ==3
replace M5 = 2 if interview__key=="74-33-09-55" & membres__id ==4
replace M5 = 1 if interview__key=="95-83-47-75" & membres__id ==3
replace M5 = 2 if interview__key=="62-17-17-23" & membres__id ==4
replace M5 = 1 if interview__key=="28-33-15-14" & membres__id ==6
replace M5 = 2 if interview__key=="57-25-10-05" & membres__id ==3
replace M5 = 2 if interview__key=="71-32-40-42" & membres__id ==6
replace M5 = 1 if interview__key=="24-43-11-33" & membres__id ==6
replace M5 = 2 if interview__key=="97-48-14-15" & membres__id ==5
replace M5 = 2 if interview__key=="97-48-14-15" & membres__id ==7
replace M5 = 2 if interview__key=="06-37-25-47" & membres__id ==4
replace M5 = 2 if interview__key=="88-39-94-73" & membres__id ==5
replace M5 = 2 if interview__key=="44-25-54-81" & membres__id ==4
replace M5 = 1 if interview__key=="55-19-15-29" & membres__id ==3
replace M5 = 2 if interview__key=="36-54-79-23" & membres__id ==4
replace M5 = 2 if interview__key=="36-54-79-23" & membres__id ==8
replace M5 = 2 if interview__key=="38-33-97-88" & membres__id ==3
replace M5 = 2 if interview__key=="56-00-80-73" & membres__id ==7
replace M5 = 2 if interview__key=="95-93-89-75" & membres__id ==3
replace M5 = 2 if interview__key=="14-35-58-38" & membres__id ==7
replace M5 = 2 if interview__key=="72-71-39-54" & membres__id ==5
replace M5 = 1 if interview__key=="29-22-75-34" & membres__id ==4
replace M5 = 1 if interview__key=="98-55-94-56" & membres__id ==3
replace M5 = 2 if interview__key=="38-84-80-74" & membres__id ==6
replace M5 = 1 if interview__key=="62-87-81-54" & membres__id ==8
replace M5 = 1 if interview__key=="88-68-40-51" & membres__id ==1
replace M5 = 2 if interview__key=="70-60-80-00" & membres__id ==9
replace M5 = 1 if interview__key=="63-27-93-47" & membres__id ==3
replace M5 = 2 if interview__key=="42-67-39-98" & membres__id ==2
replace M5 = 2 if interview__key=="42-67-39-98" & membres__id ==4
replace M5 = 2 if interview__key=="21-67-68-48" & membres__id ==3
replace M5 = 2 if interview__key=="21-67-68-48" & membres__id ==6
replace M5 = 2 if interview__key=="09-95-73-01" & membres__id ==2
replace M5 = 2 if interview__key=="17-65-95-46" & membres__id ==4
replace M5 = 1 if interview__key=="85-16-96-53" & membres__id ==7
replace M5 = 2 if interview__key=="17-71-50-99" & membres__id ==7
replace M5 = 2 if interview__key=="78-22-33-92" & membres__id ==1
replace M5 = 2 if interview__key=="09-22-66-63" & membres__id ==5
replace M5 = 1 if interview__key=="09-22-66-63" & membres__id ==6
replace M5 = 2 if interview__key=="08-11-02-36" & membres__id ==5
replace M5 = 1 if interview__key=="01-71-59-91" & membres__id ==1
replace M5 = 1 if interview__key=="66-55-33-04" & membres__id ==4
replace M5 = 1 if interview__key=="41-22-67-71" & membres__id ==3
replace M5 = 2 if interview__key=="27-04-10-00" & membres__id ==5
replace M5 = 2 if interview__key=="27-04-10-00" & membres__id ==6
replace M5 = 1 if interview__key=="68-10-38-03" & membres__id ==10
replace M5 = 1 if interview__key=="07-28-40-48" & membres__id ==3
replace M5 = 2 if interview__key=="68-99-66-29" & membres__id ==3
replace M5 = 1 if interview__key=="47-72-43-54" & membres__id ==1
replace M5 = 1 if interview__key=="47-72-43-54" & membres__id ==5
replace M5 = 2 if interview__key=="53-19-80-71" & membres__id ==5
replace M5 = 2 if interview__key=="13-36-23-94" & membres__id ==12
replace M5 = 1 if interview__key=="94-03-14-37" & membres__id ==3
replace M5 = 1 if interview__key=="77-08-81-22" & membres__id ==3
replace M5 = 2 if interview__key=="77-08-81-22" & membres__id ==4
replace M5 = 1 if interview__key=="34-58-31-60" & membres__id ==3
replace M5 = 2 if interview__key=="53-37-25-20" & membres__id ==4
replace M5 = 1 if interview__key=="60-32-45-09" & membres__id ==7
replace M5 = 2 if interview__key=="28-52-74-47" & membres__id ==6
replace M5 = 1 if interview__key=="06-65-52-61" & membres__id ==3
replace M5 = 2 if interview__key=="51-64-71-82" & membres__id ==16
replace M5 = 1 if interview__key=="88-23-28-24" & membres__id ==1
replace M5 = 1 if interview__key=="88-23-28-24" & membres__id ==4
replace M5 = 1 if interview__key=="20-59-55-75" & membres__id ==3
replace M5 = 2 if interview__key=="25-35-65-88" & membres__id ==5
replace M5 = 1 if interview__key=="39-45-91-62" & membres__id ==4
replace M5 = 1 if interview__key=="66-27-72-09" & membres__id ==6
replace M5 = 1 if interview__key=="66-27-72-09" & membres__id ==7
replace M5 = 2 if interview__key=="57-93-97-28" & membres__id ==5
replace M5 = 2 if interview__key=="44-98-54-21" & membres__id ==5
replace M5 = 1 if interview__key=="80-18-06-87" & membres__id ==7
replace M5 = 2 if interview__key=="17-75-75-02" & membres__id ==3
replace M5 = 2 if interview__key=="48-27-85-99" & membres__id ==5
replace M5 = 1 if interview__key=="20-76-31-26" & membres__id ==2
replace M5 = 1 if interview__key=="97-73-09-23" & membres__id ==4
replace M5 = 1 if interview__key=="20-77-72-48" & membres__id ==3
replace M5 = 2 if interview__key=="16-79-23-13" & membres__id ==6
replace M5 = 2 if interview__key=="02-02-57-77" & membres__id ==5
replace M5 = 2 if interview__key=="94-93-77-85" & membres__id ==8
replace M5 = 2 if interview__key=="18-35-68-74" & membres__id ==9
replace M5 = 2 if interview__key=="77-94-12-16" & membres__id ==5
replace M5 = 1 if interview__key=="14-37-00-18" & membres__id ==4
replace M5 = 2 if interview__key=="14-37-00-18" & membres__id ==6
replace M5 = 2 if interview__key=="15-67-83-30" & membres__id ==4
replace M5 = 1 if interview__key=="77-56-45-58" & membres__id ==4
replace M5 = 2 if interview__key=="26-32-91-14" & membres__id ==13
replace M5 = 1 if interview__key=="61-37-15-07" & membres__id ==4
replace M5 = 2 if interview__key=="54-21-25-50" & membres__id ==4
replace M5 = 1 if interview__key=="04-21-31-59" & membres__id ==1
replace M5 = 1 if interview__key=="55-26-05-74" & membres__id ==3
replace M5 = 1 if interview__key=="85-14-47-16" & membres__id ==3
replace M5 = 1 if interview__key=="85-14-47-16" & membres__id ==4
replace M5 = 2 if interview__key=="38-38-22-55" & membres__id ==2
replace M5 = 1 if interview__key=="85-87-84-44" & membres__id ==4
replace M5 = 1 if interview__key=="82-67-70-00" & membres__id ==2
replace M5 = 2 if interview__key=="37-67-24-52" & membres__id ==4
replace M5 = 2 if interview__key=="98-64-86-49" & membres__id ==4
replace M5 = 2 if interview__key=="78-13-65-90" & membres__id ==3
replace M5 = 2 if interview__key=="39-71-43-54" & membres__id ==5
replace M5 = 2 if interview__key=="42-83-71-01" & membres__id ==3
replace M5 = 2 if interview__key=="42-83-71-01" & membres__id ==5
replace M5 = 2 if interview__key=="64-94-15-26" & membres__id ==3
replace M5 = 2 if interview__key=="64-94-15-26" & membres__id ==4
replace M5 = 2 if interview__key=="92-69-75-01" & membres__id ==5
replace M5 = 1 if interview__key=="05-09-65-57" & membres__id ==3
replace M5 = 1 if interview__key=="05-09-65-57" & membres__id ==8
replace M5 = 2 if interview__key=="44-16-06-65" & membres__id ==3
replace M5 = 1 if interview__key=="57-95-91-10" & membres__id ==3
replace M5 = 2 if interview__key=="65-32-68-24" & membres__id ==4
replace M5 = 2 if interview__key=="37-63-35-04" & membres__id ==6
replace M5 = 2 if interview__key=="37-63-35-04" & membres__id ==8
replace M5 = 1 if interview__key=="01-91-19-38" & membres__id ==9
replace M5 = 2 if interview__key=="01-91-19-38" & membres__id ==11
replace M5 = 1 if interview__key=="66-33-47-67" & membres__id ==2
replace M5 = 1 if interview__key=="66-33-47-67" & membres__id ==3
replace M5 = 2 if interview__key=="79-61-74-42" & membres__id ==9
replace M5 = 2 if interview__key=="80-89-26-20" & membres__id ==6
replace M5 = 2 if interview__key=="93-32-46-17" & membres__id ==6
replace M5 = 1 if interview__key=="26-52-60-78" & membres__id ==3
replace M5 = 2 if interview__key=="83-91-35-97" & membres__id ==7
replace M5 = 2 if interview__key=="21-99-26-66" & membres__id ==4
replace M5 = 2 if interview__key=="93-44-84-27" & membres__id ==8
replace M5 = 2 if interview__key=="09-71-55-13" & membres__id ==7
replace M5 = 1 if interview__key=="89-14-35-36" & membres__id ==3
replace M5 = 2 if interview__key=="84-34-44-45" & membres__id ==2
replace M5 = 2 if interview__key=="35-97-03-02" & membres__id ==3
replace M5 = 1 if interview__key=="68-42-74-10" & membres__id ==3
replace M5 = 1 if interview__key=="68-42-74-10" & membres__id ==10
replace M5 = 2 if interview__key=="15-59-82-95" & membres__id ==4
replace M5 = 1 if interview__key=="15-59-82-95" & membres__id ==8
replace M5 = 2 if interview__key=="48-39-04-15" & membres__id ==8
replace M5 = 1 if interview__key=="67-04-76-15" & membres__id ==5
replace M5 = 1 if interview__key=="96-37-51-58" & membres__id ==4
replace M5 = 1 if interview__key=="53-55-53-03" & membres__id ==5
replace M5 = 1 if interview__key=="53-55-53-03" & membres__id ==6
replace M5 = 2 if interview__key=="95-60-36-30" & membres__id ==6
replace M5 = 1 if interview__key=="19-02-39-76" & membres__id ==8
replace M5 = 2 if interview__key=="37-28-92-27" & membres__id ==4
replace M5 = 2 if interview__key=="37-28-92-27" & membres__id ==5
replace M5 = 2 if interview__key=="81-94-14-05" & membres__id ==3
replace M5 = 2 if interview__key=="54-33-78-62" & membres__id ==1
replace M5 = 2 if interview__key=="90-50-87-49" & membres__id ==3
replace M5 = 2 if interview__key=="63-76-43-86" & membres__id ==4
replace M5 = 1 if interview__key=="43-60-94-02" & membres__id ==8
replace M5 = 2 if interview__key=="43-60-94-02" & membres__id ==10
replace M5 = 2 if interview__key=="78-81-71-28" & membres__id ==5
replace M5 = 2 if interview__key=="78-81-71-28" & membres__id ==6
replace M5 = 2 if interview__key=="66-42-98-93" & membres__id ==5
replace M5 = 1 if interview__key=="90-20-18-35" & membres__id ==8
replace M5 = 1 if interview__key=="90-20-18-35" & membres__id ==9
replace M5 = 1 if interview__key=="90-20-18-35" & membres__id ==12
replace M5 = 1 if interview__key=="00-18-54-59" & membres__id ==3
replace M5 = 2 if interview__key=="92-47-96-85" & membres__id ==3
replace M5 = 2 if interview__key=="92-47-96-85" & membres__id ==11
replace M5 = 1 if interview__key=="81-69-89-49" & membres__id ==10
replace M5 = 2 if interview__key=="34-94-77-58" & membres__id ==4
replace M5 = 2 if interview__key=="78-05-40-48" & membres__id ==1
replace M5 = 1 if interview__key=="64-91-76-77" & membres__id ==4
replace M5 = 2 if interview__key=="72-25-22-99" & membres__id ==3
replace M5 = 1 if interview__key=="98-97-53-63" & membres__id ==6
replace M5 = 2 if interview__key=="19-05-36-94" & membres__id ==5
replace M5 = 1 if interview__key=="77-00-95-16" & membres__id ==10
replace M5 = 1 if interview__key=="20-26-11-50" & membres__id ==2
replace M5 = 2 if interview__key=="29-68-68-09" & membres__id ==5
replace M5 = 2 if interview__key=="29-05-40-54" & membres__id ==1
replace M5 = 2 if interview__key=="71-42-28-22" & membres__id ==3
replace M5 = 2 if interview__key=="71-42-28-22" & membres__id ==6
replace M5 = 2 if interview__key=="32-52-98-91" & membres__id ==4
replace M5 = 2 if interview__key=="32-52-98-91" & membres__id ==5
replace M5 = 1 if interview__key=="16-38-22-17" & membres__id ==8
replace M5 = 2 if interview__key=="24-76-41-88" & membres__id ==1
replace M5 = 2 if interview__key=="65-71-80-04" & membres__id ==3
replace M5 = 2 if interview__key=="46-45-40-29" & membres__id ==3
replace M5 = 1 if interview__key=="91-44-46-34" & membres__id ==1
replace M5 = 2 if interview__key=="02-10-25-06" & membres__id ==3
replace M5 = 2 if interview__key=="74-89-05-00" & membres__id ==3
replace M5 = 2 if interview__key=="74-89-05-00" & membres__id ==5
replace M5 = 1 if interview__key=="06-13-71-77" & membres__id ==5
replace M5 = 1 if interview__key=="74-35-61-58" & membres__id ==3
replace M5 = 1 if interview__key=="53-60-29-01" & membres__id ==6
replace M5 = 1 if interview__key=="68-64-90-01" & membres__id ==5
replace M5 = 1 if interview__key=="80-47-31-11" & membres__id ==1
replace M5 = 2 if interview__key=="01-84-79-77" & membres__id ==2
replace M5 = 1 if interview__key=="56-01-48-17" & membres__id ==3
replace M5 = 2 if interview__key=="95-88-50-03" & membres__id ==3
replace M5 = 2 if interview__key=="41-36-47-33" & membres__id ==5
replace M5 = 1 if interview__key=="58-38-94-25" & membres__id ==3
replace M5 = 2 if interview__key=="69-66-24-03" & membres__id ==8
replace M5 = 1 if interview__key=="35-07-79-40" & membres__id ==5
replace M5 = 2 if interview__key=="50-32-37-39" & membres__id ==6
replace M5 = 1 if interview__key=="50-32-37-39" & membres__id ==7
replace M5 = 1 if interview__key=="49-03-40-23" & membres__id ==4
replace M5 = 1 if interview__key=="84-66-00-74" & membres__id ==3
replace M5 = 2 if interview__key=="84-66-00-74" & membres__id ==4
replace M5 = 2 if interview__key=="88-20-87-57" & membres__id ==12
replace M5 = 1 if interview__key=="34-27-78-98" & membres__id ==4
replace M5 = 2 if interview__key=="34-27-78-98" & membres__id ==5
replace M5 = 1 if interview__key=="47-42-86-49" & membres__id ==12
replace M5 = 2 if interview__key=="47-42-86-49" & membres__id ==18
replace M5 = 2 if interview__key=="47-42-86-49" & membres__id ==21
replace M5 = 2 if interview__key=="89-97-16-49" & membres__id ==10
replace M5 = 1 if interview__key=="66-28-52-51" & membres__id ==5
replace M5 = 2 if interview__key=="18-28-11-03" & membres__id ==3
replace M5 = 2 if interview__key=="88-50-54-11" & membres__id ==8
replace M5 = 1 if interview__key=="88-50-54-11" & membres__id ==13
replace M5 = 1 if interview__key=="84-66-98-23" & membres__id ==6
replace M5 = 2 if interview__key=="03-63-23-67" & membres__id ==1
replace M5 = 2 if interview__key=="54-75-17-66" & membres__id ==5
replace M5 = 2 if interview__key=="96-61-37-93" & membres__id ==5
replace M5 = 2 if interview__key=="16-59-05-25" & membres__id ==3
replace M5 = 2 if interview__key=="81-83-71-35" & membres__id ==6
replace M5 = 1 if interview__key=="31-45-65-69" & membres__id ==4
replace M5 = 2 if interview__key=="01-55-02-19" & membres__id ==6
replace M5 = 1 if interview__key=="42-70-84-10" & membres__id ==2
replace M5 = 2 if interview__key=="94-79-26-37" & membres__id ==2
replace M5 = 2 if interview__key=="50-72-38-61" & membres__id ==5
replace M5 = 2 if interview__key=="50-72-38-61" & membres__id ==7
replace M5 = 2 if interview__key=="52-48-31-39" & membres__id ==6
replace M5 = 1 if interview__key=="26-38-31-47" & membres__id ==1
replace M5 = 1 if interview__key=="26-38-31-47" & membres__id ==4
replace M5 = 2 if interview__key=="55-40-74-20" & membres__id ==3
replace M5 = 1 if interview__key=="77-57-49-98" & membres__id ==3
replace M5 = 1 if interview__key=="03-55-13-54" & membres__id ==1
replace M5 = 2 if interview__key=="62-25-42-89" & membres__id ==4
replace M5 = 2 if interview__key=="78-85-73-79" & membres__id ==6
replace M5 = 2 if interview__key=="24-42-58-19" & membres__id ==9
replace M5 = 2 if interview__key=="24-42-58-19" & membres__id ==23
replace M5 = 1 if interview__key=="24-42-58-19" & membres__id ==25
replace M5 = 1 if interview__key=="24-42-58-19" & membres__id ==28
replace M5 = 1 if interview__key=="71-58-03-86" & membres__id ==6
replace M5 = 2 if interview__key=="43-28-07-72" & membres__id ==6
replace M5 = 2 if interview__key=="21-53-42-23" & membres__id ==1
replace M5 = 1 if interview__key=="84-49-35-97" & membres__id ==3
replace M5 = 2 if interview__key=="84-49-35-97" & membres__id ==7
replace M5 = 2 if interview__key=="67-86-08-21" & membres__id ==4
replace M5 = 1 if interview__key=="58-86-87-27" & membres__id ==5
replace M5 = 2 if interview__key=="77-06-77-10" & membres__id ==1
replace M5 = 1 if interview__key=="77-06-77-10" & membres__id ==3
replace M5 = 2 if interview__key=="22-57-44-74" & membres__id ==10
replace M5 = 1 if interview__key=="70-10-68-34" & membres__id ==6
replace M5 = 2 if interview__key=="65-59-89-12" & membres__id ==1
replace M5 = 1 if interview__key=="35-44-06-63" & membres__id ==5
replace M5 = 2 if interview__key=="53-96-26-40" & membres__id ==4
replace M5 = 2 if interview__key=="53-96-26-40" & membres__id ==5
replace M5 = 2 if interview__key=="84-35-38-49" & membres__id ==3
replace M5 = 1 if interview__key=="99-62-30-62" & membres__id ==4
replace M5 = 1 if interview__key=="93-32-29-52" & membres__id ==3
replace M5 = 2 if interview__key=="32-03-40-65" & membres__id ==5
replace M5 = 2 if interview__key=="02-46-43-58" & membres__id ==5
replace M5 = 1 if interview__key=="20-22-14-80" & membres__id ==8
replace M5 = 1 if interview__key=="34-64-06-54" & membres__id ==5
replace M5 = 1 if interview__key=="95-46-42-68" & membres__id ==5
replace M5 = 1 if interview__key=="60-79-52-49" & membres__id ==2
replace M5 = 1 if interview__key=="77-70-60-92" & membres__id ==1
replace M5 = 2 if interview__key=="28-09-35-22" & membres__id ==3
replace M5 = 1 if interview__key=="40-57-04-75" & membres__id ==1
replace M5 = 1 if interview__key=="38-39-62-28" & membres__id ==4
replace M5 = 1 if interview__key=="38-39-62-28" & membres__id ==5
replace M5 = 2 if interview__key=="19-54-99-34" & membres__id ==4
replace M5 = 2 if interview__key=="19-54-99-34" & membres__id ==5
replace M5 = 1 if interview__key=="19-54-99-34" & membres__id ==6
replace M5 = 2 if interview__key=="53-36-38-99" & membres__id ==2
replace M5 = 2 if interview__key=="53-36-38-99" & membres__id ==3
replace M5 = 1 if interview__key=="84-66-78-82" & membres__id ==5
replace M5 = 1 if interview__key=="84-66-78-82" & membres__id ==7
replace M5 = 1 if interview__key=="49-23-43-54" & membres__id ==6
replace M5 = 1 if interview__key=="16-75-86-61" & membres__id ==4
replace M5 = 2 if interview__key=="16-75-86-61" & membres__id ==8
replace M5 = 2 if interview__key=="57-88-62-06" & membres__id ==3
replace M5 = 1 if interview__key=="24-22-99-78" & membres__id ==5
replace M5 = 1 if interview__key=="24-22-99-78" & membres__id ==8
replace M5 = 2 if interview__key=="64-15-45-25" & membres__id ==10
replace M5 = 2 if interview__key=="04-43-66-72" & membres__id ==4
replace M5 = 1 if interview__key=="04-43-66-72" & membres__id ==6
replace M5 = 2 if interview__key=="69-93-88-23" & membres__id ==3
replace M5 = 1 if interview__key=="39-39-24-97" & membres__id ==7
replace M5 = 2 if interview__key=="45-96-36-06" & membres__id ==4
replace M5 = 1 if interview__key=="55-98-25-22" & membres__id ==7
replace M5 = 1 if interview__key=="23-67-74-86" & membres__id ==6
replace M5 = 1 if interview__key=="96-31-20-09" & membres__id ==21
replace M5 = 2 if interview__key=="97-96-20-85" & membres__id ==1
replace M5 = 1 if interview__key=="36-97-23-97" & membres__id ==11
replace M5 = 1 if interview__key=="20-41-20-42" & membres__id ==5
replace M5 = 1 if interview__key=="22-45-99-35" & membres__id ==7
replace M5 = 1 if interview__key=="22-45-99-35" & membres__id ==10
replace M5 = 2 if interview__key=="15-09-23-72" & membres__id ==1
replace M5 = 2 if interview__key=="15-60-34-10" & membres__id ==1
replace M5 = 1 if interview__key=="86-18-45-92" & membres__id ==7
replace M5 = 1 if interview__key=="03-82-64-57" & membres__id ==7
replace M5 = 1 if interview__key=="91-14-66-01" & membres__id ==16
replace M5 = 1 if interview__key=="74-42-54-47" & membres__id ==6
replace M5 = 1 if interview__key=="98-47-75-89" & membres__id ==5
replace M5 = 2 if interview__key=="94-35-85-23" & membres__id ==6
replace M5 = 1 if interview__key=="19-37-08-30" & membres__id ==6
replace M5 = 1 if interview__key=="05-63-73-65" & membres__id ==5
replace M5 = 1 if interview__key=="08-96-26-07" & membres__id ==3
replace M5 = 2 if interview__key=="08-96-26-07" & membres__id ==4
replace M5 = 2 if interview__key=="09-24-45-47" & membres__id ==5
replace M5 = 1 if interview__key=="12-90-30-12" & membres__id ==3
replace M5 = 2 if interview__key=="91-91-26-68" & membres__id ==3
replace M5 = 1 if interview__key=="30-76-22-79" & membres__id ==6
replace M5 = 1 if interview__key=="85-84-49-87" & membres__id ==3
replace M5 = 2 if interview__key=="74-85-47-93" & membres__id ==5
replace M5 = 2 if interview__key=="59-17-66-84" & membres__id ==4
replace M5 = 2 if interview__key=="59-17-66-84" & membres__id ==5
replace M5 = 2 if interview__key=="98-80-28-87" & membres__id ==4
replace M5 = 2 if interview__key=="62-57-22-02" & membres__id ==10
replace M5 = 1 if interview__key=="96-59-06-04" & membres__id ==3
replace M5 = 2 if interview__key=="73-48-56-91" & membres__id ==2
replace M5 = 2 if interview__key=="77-64-91-17" & membres__id ==1
replace M5 = 1 if interview__key=="77-64-91-17" & membres__id ==2
replace M5 = 2 if interview__key=="43-21-35-05" & membres__id ==5
replace M5 = 2 if interview__key=="00-37-01-26" & membres__id ==3
replace M5 = 1 if interview__key=="42-07-34-35" & membres__id ==1
replace M5 = 1 if interview__key=="91-34-44-56" & membres__id ==8
replace M5 = 1 if interview__key=="65-78-26-91" & membres__id ==2
replace M5 = 1 if interview__key=="80-88-74-34" & membres__id ==3
replace M5 = 1 if interview__key=="59-80-69-91" & membres__id ==3
replace M5 = 2 if interview__key=="59-80-69-91" & membres__id ==4
replace M5 = 2 if interview__key=="59-80-69-91" & membres__id ==6
replace M5 = 2 if interview__key=="66-82-97-37" & membres__id ==3
replace M5 = 2 if interview__key=="66-82-97-37" & membres__id ==4
replace M5 = 2 if interview__key=="19-31-89-46" & membres__id ==1
replace M5 = 2 if interview__key=="42-92-17-20" & membres__id ==2
replace M5 = 2 if interview__key=="52-94-84-19" & membres__id ==5
replace M5 = 1 if interview__key=="64-49-95-20" & membres__id ==9
replace M5 = 1 if interview__key=="13-22-81-54" & membres__id ==2
replace M5 = 1 if interview__key=="91-34-70-65" & membres__id ==3
replace M5 = 1 if interview__key=="39-69-31-27" & membres__id ==3
replace M5 = 2 if interview__key=="35-52-67-68" & membres__id ==1
replace M5 = 2 if interview__key=="02-33-67-38" & membres__id ==5
replace M5 = 2 if interview__key=="06-71-55-35" & membres__id ==1
replace M5 = 2 if interview__key=="06-71-55-35" & membres__id ==2
replace M5 = 2 if interview__key=="35-68-68-23" & membres__id ==3
replace M5 = 2 if interview__key=="35-68-68-23" & membres__id ==5
replace M5 = 2 if interview__key=="11-92-67-06" & membres__id ==7
replace M5 = 1 if interview__key=="78-19-36-57" & membres__id ==3
replace M5 = 2 if interview__key=="02-46-66-08" & membres__id ==8
replace M5 = 1 if interview__key=="26-59-00-43" & membres__id ==6
replace M5 = 1 if interview__key=="79-12-55-96" & membres__id ==2
replace M5 = 2 if interview__key=="26-26-15-63" & membres__id ==7
replace M5 = 1 if interview__key=="20-73-75-59" & membres__id ==3
replace M5 = 2 if interview__key=="20-73-75-59" & membres__id ==5
replace M5 = 2 if interview__key=="20-73-75-59" & membres__id ==6
replace M5 = 1 if interview__key=="66-48-10-48" & membres__id ==3
replace M5 = 1 if interview__key=="44-40-22-23" & membres__id ==8
replace M5 = 2 if interview__key=="50-27-60-80" & membres__id ==7
replace M5 = 2 if interview__key=="28-71-10-54" & membres__id ==6
replace M5 = 2 if interview__key=="63-60-85-22" & membres__id ==9
replace M5 = 1 if interview__key=="28-02-52-59" & membres__id ==5
replace M5 = 1 if interview__key=="04-72-20-18" & membres__id ==4
replace M5 = 2 if interview__key=="87-29-35-66" & membres__id ==6
replace M5 = 2 if interview__key=="28-37-27-41" & membres__id ==4
replace M5 = 1 if interview__key=="66-48-78-64" & membres__id ==7
replace M5 = 1 if interview__key=="31-86-17-14" & membres__id ==6
replace M5 = 1 if interview__key=="19-10-75-17" & membres__id ==3
replace M5 = 2 if interview__key=="67-29-73-00" & membres__id ==9
replace M5 = 1 if interview__key=="45-85-21-60" & membres__id ==3
replace M5 = 1 if interview__key=="54-05-77-92" & membres__id ==7
replace M5 = 1 if interview__key=="32-54-48-72" & membres__id ==6
replace M5 = 1 if interview__key=="27-53-75-11" & membres__id ==1
replace M5 = 1 if interview__key=="31-89-44-47" & membres__id ==5
replace M5 = 2 if interview__key=="86-27-10-71" & membres__id ==6
replace M5 = 2 if interview__key=="86-27-10-71" & membres__id ==11
replace M5 = 2 if interview__key=="38-34-97-57" & membres__id ==5
replace M5 = 2 if interview__key=="81-06-38-23" & membres__id ==4
replace M5 = 2 if interview__key=="60-34-39-23" & membres__id ==3
replace M5 = 1 if interview__key=="84-32-83-93" & membres__id ==3
replace M5 = 2 if interview__key=="10-63-51-70" & membres__id ==5
replace M5 = 2 if interview__key=="10-63-51-70" & membres__id ==7
replace M5 = 2 if interview__key=="10-63-51-70" & membres__id ==10
replace M5 = 2 if interview__key=="83-94-73-68" & membres__id ==2
replace M5 = 2 if interview__key=="37-18-50-42" & membres__id ==1
replace M5 = 1 if interview__key=="37-18-50-42" & membres__id ==2
replace M5 = 1 if interview__key=="49-34-30-76" & membres__id ==6
replace M5 = 1 if interview__key=="49-34-30-76" & membres__id ==7
replace M5 = 1 if interview__key=="01-71-86-00" & membres__id ==7
replace M5 = 1 if interview__key=="01-71-86-00" & membres__id ==10
replace M5 = 2 if interview__key=="01-71-86-00" & membres__id ==12
replace M5 = 2 if interview__key=="01-71-86-00" & membres__id ==13
replace M5 = 1 if interview__key=="36-95-56-79" & membres__id ==3
replace M5 = 2 if interview__key=="80-86-49-62" & membres__id ==5
replace M5 = 2 if interview__key=="66-90-80-14" & membres__id ==3
replace M5 = 2 if interview__key=="94-07-42-32" & membres__id ==1
replace M5 = 2 if interview__key=="68-78-59-13" & membres__id ==4
replace M5 = 1 if interview__key=="43-70-29-16" & membres__id ==9
replace M5 = 1 if interview__key=="43-70-29-16" & membres__id ==10
replace M5 = 1 if interview__key=="43-70-29-16" & membres__id ==19
replace M5 = 1 if interview__key=="43-20-85-89" & membres__id ==2
replace M5 = 2 if interview__key=="12-03-26-95" & membres__id ==1
replace M5 = 1 if interview__key=="60-75-14-26" & membres__id ==4
replace M5 = 1 if interview__key=="76-43-89-93" & membres__id ==6
replace M5 = 1 if interview__key=="76-43-89-93" & membres__id ==8
replace M5 = 2 if interview__key=="62-71-43-87" & membres__id ==5
replace M5 = 1 if interview__key=="36-42-14-51" & membres__id ==3
replace M5 = 2 if interview__key=="12-64-57-89" & membres__id ==1
replace M5 = 2 if interview__key=="29-68-98-44" & membres__id ==3
replace M5 = 1 if interview__key=="29-68-98-44" & membres__id ==5
replace M5 = 2 if interview__key=="87-34-61-09" & membres__id ==3
replace M5 = 2 if interview__key=="46-42-87-25" & membres__id ==4
replace M5 = 2 if interview__key=="25-39-26-18" & membres__id ==3
replace M5 = 2 if interview__key=="16-32-27-86" & membres__id ==7
replace M5 = 2 if interview__key=="91-93-95-61" & membres__id ==1
replace M5 = 2 if interview__key=="24-83-37-11" & membres__id ==3
replace M5 = 1 if interview__key=="61-24-59-55" & membres__id ==1


count if !missing(M5) & Statut_Res== 0 
// tous ceux qui ne devaient pas répondre n'ont pas repondu

*------------------------------------------------------------
* M6_J . Veuillez saisir le jour de naissance de %rostertitle% ?
*------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M6_J) & Statut_Res==1 
// 69 personnes pour qui on a pas le  jour de naissance

*replace commentaire="personne pour qui le jour de naissance n'a pas été renseignée" if missing(M6_J) & Statut_Res==1

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M6_J) & Statut_Res== 0 
// tous ceux qui ont repondu à la question y avait le droit

**Exportation des individus potentiellement concernés
*export excel interview__key HH2 HH12 HH13 M6_J membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_jour_naiss" if missing(M6_J) & Statut_Res==1 , firstrow(varl) replace

*3 Valeurs légales: 
count if !inrange(M6_J,1,31) & Statut_Res==1 & M6_J !=9998 & !missing(M6_J)
*RAS

*------------------------------------------------------------
* M6_M. Mois de naissance de %rostertitle% ?
*------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M6_M) & Statut_Res==1 
// 71 personnes pour qui on a pas le mois de naissance
replace commentaire="personnes pour qui on n'a pas le mois de naissance" if missing(M6_M) & Statut_Res==1

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M6_M) & Statut_Res== 0 
// tous ceux qui ont repondu à la question y avait le droit

**Exportation des individus potentiellement concernés
*export excel interview__key HH2 HH12 HH13 M6_M membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_mois_naiss" if missing(M6_M) & Statut_Res==1 , firstrow(varl) replace

*3 Valeurs légales: 
count if !inrange(M6_M,1,12) & Statut_Res==1 & M6_M !=9998 & !missing(M6_M)
*RAS

*4 Cohérence entre le jour de naissance et les mois :
//Mois de Février
count if M6_M==2 & inlist(M6_J,30,31)
//Mois de Mars, Juin, Septembre et Novembre
count if inlist(M6_M,4,6,9,11) & M6_J ==31
**RAS

*------------------------------------------------------------
* M6_A. Quelle est l'année de naissance de %rostertitle% ?
*------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M6_A) & Statut_Res==1 
// 28 personnes pour qui on a pas l'année de naissance
replace commentaire="personnes pour qui on n'a pas l'année de naissance" if missing(M6_A) & Statut_Res==1

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M6_A) & Statut_Res== 0 
//RAS

* 3. Valeurs légales
count if !missing(M6_A) & (M6_A > 2026 | M6_A < 1924) & Statut_Res==1 & M6_A !=9998
//RAS


*---------------------------------------------------------------
*M7. Quel âge avait %rostertitle% à son dernier anniversaire?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M7) & (M6_A==9998 | M6_A ==.a)
// 39 personnes pour qui on a pas l'age de naissance

*br interview__key membres__id M6_A M7 AgeAnnee M4Confirm  if missing(M7) & (M6_A==9998 | M6_A ==.a)


count if missing(AgeAnnee) & Statut_Res==1
// 39 personnes pour qui on a pas l'age et l'année de naissance sont non renseignées : Tous des téléopérateurs

*br interview__key membres__id M6_A M7 AgeAnnee M4Confirm  if missing(AgeAnnee) & Statut_Res==1

*ta HH2 if missing(AgeAnnee) & Statut_Res==1

replace commentaire=" 39 personnes pour qui on a pas l'age de naissance" if missing(AgeAnnee) & Statut_Res==1

**Exportation des individus potentiellement concernés

count if missing(AgeAnnee) & Statut_Res==1
if r(N)>0 {
    export excel interview__key HH13 M6_A M7 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/Sans_Age" if missing(AgeAnnee) & Statut_Res==1, firstrow(varl) replace
}

*2. Vérification des sauts

count if !missing(M7) & M6_A !=9998 
// RAS


count if !missing(AgeAnnee) & Statut_Res !=1
// 248 personnes n'ayant pas le droit de répondre aux questions (car ils ne sont pas résidents) ont répondu et nous remarquons après avoir exécuté le code suivant que l'Age de tous ces individu est égal à 0. Nous allons remplacer leur âge par la une valeur manquante
br AgeAnnee Statut_Res if !missing(AgeAnnee) & Statut_Res !=1

replace AgeAnnee= . if !missing(AgeAnnee) & Statut_Res !=1

*3. Valeurs légales
ta AgeAnnee if Statut_Res==1,miss // plusieurs valeurs aberrantes dans la variable AgeAnnee. 

br interview__key  membres__id M6_A M6_J M6_M M7 AgeAnnee M4Confirm if AgeAnnee <0
//Tous ceux dont l'âge est négatif sont, en réalité, nés en 2026 (variable M6_A)

replace AgeAnnee=0 if AgeAnnee <0

br interview__key  membres__id M6_A M6_J M6_M M7 AgeAnnee M4Confirm if AgeAnnee >99 & !missing(AgeAnnee)
//Plusieurs valeurs sont en réalités l'année de naissance. Nous allons calculer l'âge pour ces individus concernés. Il y a un indivi pour qui l'âge saisi est 106 mais c'est une observation de l'enquêteur. Nous allons remplacer cette valeur par l'âge maximal 102.

replace AgeAnnee=102 if AgeAnnee ==106
replace AgeAnnee=2026 - AgeAnnee if AgeAnnee >1930 & !missing(AgeAnnee)

*4. Cohérence

**l'âge du chef de ménage
count if M4 ==1 & AgeAnnee < 15  
// RAS

** Age et lien de parenté
// creation de variable 
cap drop cm
gen cm = M4==1
cap drop agecm
gen agecm = cm * AgeAnnee if M4==1
bysort interview__key : egen Age_Cm_men = total( agecm)
cap drop ecart_age
gen ecart_age = Age_Cm_men - AgeAnnee
cap drop ecart_age1
gen ecart_age1 = AgeAnnee - Age_Cm_men

// test des ecarts entre l'age de l'indivu et celui de ses parents
count if ecart_age1 < 11 & M4 == 5 
// pas de CM dont le parent en est agé de moins de 11

count if ((ecart_age < 11 & M4 == 3 & M5 ==2) | (ecart_age < 14 & M4 == 3 & M5 ==1)) & agecm !=. 
// pas CM agé de moins 11/14 par rapport à son fils/filles

count if AgeAnnee != M4Confirm & !missing(AgeAnnee, M4Confirm) 
// M4Confirm est l'age confirmé au moment de l'entretien, c'est donc la vrai valeurs de l'age. la variable AgeAnnee et M4Confirm sont différentes pour 5 776 individus 

*---------------------------------------------------------------
* M8. Est-ce que la mère biologique de %rostertitle% est encore en vie ?
*--------------------------------------------------------------- 

* 1. Valeurs manquantes
count if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))) 
// 79 individus pour qui la question n'a pas été repondu

*replace commentaire="individus pour qui la question M8 n'a pas été repondu" if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))

*export excel interview__key HH13 M8 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_mere_en_vie" if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))), firstrow(varl) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M8) & ( Statut_Res !=1 | membre_id_v1 != "##N/A##" | AgeAnnee >= 18 | (!inlist(M4,3,4,7,8) & !inlist(V1M4,3,4,7,8)) )
//RAS

* 3. Valeurs légales
count if !inlist(M8,1,2,9998) & !missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))
//RAS

*---------------------------------------------------------------
* M9A. Lors du passage à la date %V1hha%, vous nous avez indiqué que La mère biologique de %rostertitle% %V1M9% habituellement dans ce ménage [ou était en vis
*--------------------------------------------------------------- 

* 1. Valeurs manquantes
count if missing(M9A) & M8==1 & membre_id_v1 != "##N/A##" &  !missing(V1M9)
// RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M9A) & ( Statut_Res !=1 | membre_id_v1 == "##N/A##" | missing(V1M9) )
//RAS

* 3. Valeurs légales
count if !inlist(M9A,1,2) & !missing(M9A) & Statut_Res==1 & membre_id_v1 != "##N/A##" &  !missing(V1M9)
//RAS

*---------------------------------------------------------------
*M9. La mère biologique de %rostertitle% vit-elle habituellement dans ce ménage ou était-elle en visite ici la nuit dernière ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M9) & M8==1 
// 2 individus pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M9) & M8!=1  
// RAS

* 3. Valeurs légales
count if !inlist(M9,1,2) & !missing(M9) & M8==1
//RAS 

*4. Cohérence entre M8 et M9
ta M8 M9 
// pas d'incoherence entre le fait que la mère soit vivante et qu'elle vive dans le menage

*---------------------------------------------------------------
*M10.Qui est la mère biologique de %rostertitle% ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M10) & M9 == 1
// 17 individus pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M10) & M9!=1  
// RAS


*---------------------------------------------------------------
*M11.Est-ce que le père biologique de %rostertitle% est encore en vie ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M11) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))
// 81 individus pour qui la question n'a pas été repondu

*replace commentaire="individus pour qui la question M11 n'a pas été repondu" if missing(M11) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))

*export excel interview__key HH13 M11 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_mere_en_vie" if missing(M11) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))), firstrow(varl) replace

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M11) & ( Statut_Res !=1 | membre_id_v1 != "##N/A##" | AgeAnnee >= 18 | (!inlist(M4,3,4,7,8) & !inlist(V1M4,3,4,7,8)) )
// RAS

* 3. Valeurs légales
count if !inlist(M11,1,2,9998) & !missing(M11)
//RAS 


*---------------------------------------------------------------
* M12A. Lors du passage à la date %V1hha%, vous nous avez indiqué que le père biologique de %rostertitle% %V1M12% habituellement dans ce ménage [ou était en visite ici la nuit dernière], est-ce toujours le cas ?
*--------------------------------------------------------------- 

* 1. Valeurs manquantes
count if missing(M12A) & M11==1 & membre_id_v1 != "##N/A##" &  !missing(V1M12)
// RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M12A) & ( M11 !=1 | membre_id_v1 == "##N/A##" | missing(V1M12) )
//RAS

* 3. Valeurs légales
count if !inlist(M12A,1,2) & !missing(M12A) & M11==1 & membre_id_v1 != "##N/A##" &  !missing(V1M12)
//RAS


*---------------------------------------------------------------
*M12. Le père biologique de %rostertitle% vit-il habituellement dans ce ménage ou était en visite ici la nuit dernière?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M12) & M11==1 & membre_id_v1 == "##N/A##"
// 1 individu pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M12) & (M11 !=1 | membre_id_v1 != "##N/A##")
// RAS

* 3. Valeurs légales
count if !inlist(M12,1,2) & !missing(M12) & M11==1 & membre_id_v1 == "##N/A##"
//RAS 

*4. Cohérence entre M11 et M12
ta M11 M12
// pas d'incoherence entre le fait que le père soit vivant et qu'elle vive dans le menage

*---------------------------------------------------------------
*M13.Qui est le père biologique de %rostertitle% ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M13) & M12 == 1
// 11 individus pour qui la question n'a pas été repondu

replace commentaire ="personnes pour qui la question n'a pas été repondu M13" if missing(M13) & M12 == 1
**Exportation des individus potentiellement concernés

count if missing(M13) & M12 == 1
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M12 M13 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_pere_qui" if missing(M13) & M12 == 1, firstrow(varl) replace
}

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M13) & M12!=1  
// RAS


*---------------------------------------------------------------
*M14.Qui a la charge de %rostertitle% dans le ménage ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))
// 94 individu pour qui la question n'a pas été repondu

replace commentaire="individus pour qui la question M14  n'a pas été répondu" if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))

count if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M14 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_charge_qui" if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))), firstrow(varl) replace
}

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M14) & (Statut_Res !=1 | membre_id_v1 != "##N/A##" | AgeAnnee >= 18 | (!inlist(M4,3,4,7,8) & !inlist(V1M4,3,4,7,8)) )
// RAS


*---------------------------------------------------------------
*M15. %rostertitle% est-il né en Côte d'Ivoire ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M15) & Statut_Res==1 & membre_id_v1=="##N/A##"
// 248 individu pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M15) & (Statut_Res==1 !=1 | membre_id_v1 != "##N/A##")
// RAS

* 3. Valeurs légales
count if !inlist(M15,1,2) & !missing(M15) & Statut_Res==1 & membre_id_v1=="##N/A##" 
//RAS 

*Correction : remplacer les valeurs manquantes par le mode du ménage

bysort interview__key: egen mode_M15 = mode(M15)
replace M15 = mode_M15 if missing(M15) & Statut_Res==1 & membre_id_v1=="##N/A##"

* Vérification
count if missing(M15) & Statut_Res==1 & membre_id_v1=="##N/A##"
**221 valeurs n'ont pas pu être remplacé

drop mode_M15

*---------------------------------------------------------------
*M16. Quelle est la sous-préfecture ou la commune du lieu de naissance de %rostertitle% ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M16) & M15==1 
// 35 individu pour qui la question n'a pas été repondu

replace commentaire="individu pour qui la question M16 n'a pas été répondu " if missing(M16) & M15==1

count if missing(M16) & M15==1 
if r(N)>0 {
    export excel interview__key HH2 HH12  HH13 M14 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/sous_prefecture_maissan" if missing(M16) & M15==1 , firstrow(varl) replace
}

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M16) & M15 !=1 
// RAS

*---------------------------------------------------------------
*M18. Précisez le pays de naissance de %rostertitle%
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M18) & M15==2 
// 6 individu pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M18) & M15 !=2
// RAS

* 3. Valeurs légales
count if !inrange(M18,1,2016) & M15 ==2 & !missing(M18)
//RAS

*---------------------------------------------------------------
*M19. Quelle est la nationalité de %rostertitle% ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M19) & Statut_Res==1 & membre_id_v1=="##N/A##"
// 255 individu pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M19) & (Statut_Res==1 !=1 | membre_id_v1 != "##N/A##")
// RAS

* 3. Valeurs légales
count if !inlist(M19,1,2,3) & !missing(M19) & Statut_Res==1 & membre_id_v1=="##N/A##" 
//RAS 

*5 Correction :

* =============
* Règles :
* - Si M19 est manquant pour un enfant du CM (M4==3)
*   et que le CM est masculin (M5==1),
*   alors prendre la nationalité du CM.
*
* - Si M19 est manquant pour un enfant du conjoint (M4==4)
*   et que le conjoint est masculin (M5==1),
*   alors prendre la nationalité du conjoint.
* =============

*Nationalité du chef de ménage masculin
gen nat_cm_homme = M19 if M4==1 & M5==1 & !missing(M19)
bysort interview__key: egen nat_cm_homme_final = max(nat_cm_homme)

*Nationalité du conjoint masculin
gen nat_conjoint_homme = M19 if M4==2 & M5==1 & !missing(M19)

bysort interview__key: egen nat_conjoint_homme_final = max(nat_conjoint_homme)

*Remplacement : enfant du CM
replace M19 = nat_cm_homme_final ///
    if missing(M19) ///
    & M4==3 ///
    & !missing(nat_cm_homme_final)

* Remplacement : enfant du conjoint
replace M19 = nat_conjoint_homme_final ///
    if missing(M19) ///
    & M4==4 ///
    & !missing(nat_conjoint_homme_final)

* Vérification
count if missing(M19) & Statut_Res==1 & membre_id_v1=="##N/A##"
*Le nombre de valeurs manquantes a été réduite à 244

* Suppression des variables temporaires
drop nat_cm_homme nat_cm_homme_final nat_conjoint_homme nat_conjoint_homme_final


*---------------------------------------------------------------
*M20. Indiquez le pays dont %rostertitle% a la nationalité .
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M20) & M19 == 2 
// 4 individu pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M20) & M19 != 2 
// RAS

* 3. Valeurs légales
count if !inrange(M20,1,2016) & M19 ==2 & !missing(M20)
//RAS


ta M20,miss // les pays mentionné sont vraisembable. Ce sont pour la plupart des pays ayant une forte diaspora en CIV 

*---------------------------------------------------------------
*M21. Quelle est l'ethnie de %rostertitle% ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M21) & M19 ==1
// 16 individus pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M21) & M19 != 1
// RAS

* 3. Valeurs légales
count if !inrange(M21,1,89) & M19 ==1 & !missing(M21) & M21 != 98
//RAS 

*---------------------------------------------------------------
*M22. Quelle est la réligion de %rostertitle% ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##"
// 260 individus pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M22) & (Statut_Res !=1 | membre_id_v1 !="##N/A##")
// RAS

* 3. Valeurs légales
count if !inrange(M22,1,14) & Statut_Res==1 & membre_id_v1=="##N/A##" & !missing(M22) & M22 != 9998
//RAS 

*5 Correction :

* Calcul du mode de M22 par ménage
bysort interview__key: egen mode_M22 = mode(M22) if !missing(M22)

* Propager le mode à tous les membres du ménage
bysort interview__key: egen mode_M22_final = max(mode_M22)

* Remplacement des valeurs manquantes
replace M22 = mode_M22_final if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##" & !missing(mode_M22_final)

* Vérification
count if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##"
*Nombre de valeurs manquantes réduit à 248

drop mode_M22 mode_M22_final
*---------------------------------------------------------------
*M22_Aut. Veuillez préciser ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M22_Aut) & M22 == 13 
// RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M22_Aut) &  M22 != 13 
//RAS

*---------------------------------------------------------------
*M23A. Quel est le statut matrimonial de %rostertitle% ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##"
// 182 individus pour qui la question n'a pas été repondu

replace commentaire="individu pour qui la question M23A(statut matrimonial) n'a pas de réponse " if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##" 

count if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##"  
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M19 AgeAnnee M23A membre_id_v1 Statut_Res commentaire using "$folderpath/document/stattut_matrimonial"  if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##"  , firstrow(varl) replace
}

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M23A) & (AgeAnnee < 12 | Statut_Res !=1 | membre_id_v1 !="##N/A##")
// 1 personne a répondu à cette question alors qu'elle ne le devrait pas

*br if !missing(M23A) & (AgeAnnee < 12 | Statut_Res !=1 | membre_id_v1 !="##N/A##")

* 3. Valeurs légales
count if !inrange(M23A,1,6) & !missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##"
//RAS 

*5 Correction :

* ======
* APUREMENT DE M23A (Statut matrimonial)
* Remplacer la valeur manquante du CM/conjoint
* par la valeur de l'autre lorsqu'elle existe
* ======

* Récupérer le statut matrimonial du CM

gen M23A_cm = M23A if M4==1 & !missing(M23A)
bysort interview__key: egen M23A_cm_final = max(M23A_cm)

* Récupérer le statut matrimonial du conjoint

gen M23A_conjoint = M23A if M4==2 & !missing(M23A)
bysort interview__key: egen M23A_conjoint_final = max(M23A_conjoint)

* 4. Apurement

* Cas 1 : CM manquant mais conjoint renseigné
replace M23A = M23A_conjoint_final ///
    if missing(M23A) ///
    & M4==1 ///
    & AgeAnnee >= 12 ///
    & Statut_Res==1 ///
    & membre_id_v1=="##N/A##" ///
    & !missing(M23A_conjoint_final)

* Cas 2 : Conjoint manquant mais CM renseigné
replace M23A = M23A_cm_final ///
    if missing(M23A) ///
    & M4==2 ///
    & AgeAnnee >= 12 ///
    & Statut_Res==1 ///
    & membre_id_v1=="##N/A##" ///
    & !missing(M23A_cm_final)

* Vérification
count if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##"
// Nombre de valeurs manquantes reduit à 179

drop M23A_cm M23A_conjoint M23A_cm_final M23A_conjoint_final

*---------------------------------------------------------------
*M23B. Quel est le type de mariage de %rostertitle% ?
*---------------------------------------------------------------

foreach var in M23B__1 M23B__2 M23B__3 M23B__9998 {
count if missing(`var') & inlist(M23A,3,4)
} 
// 2 individus n'ont répondu

*---------------------------------------------------------------
*M24A. %rostertitle% a-t-il/elle une assurance maladie ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M24A) & Statut_Res==1 & membre_id_v1=="##N/A##"
// 241 individus pour qui la question n'a pas été repondu

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M24A) & (Statut_Res !=1 | membre_id_v1 !="##N/A##")
// RAS

* 3. Valeurs légales
count if !inrange(M24A,1,2) & Statut_Res==1 & membre_id_v1=="##N/A##" & !missing(M24A)
//RAS 

*---------------------------------------------------------------
*M24B. Si oui, qui a souscrit à l'assurance ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M24B) & M24A==1
// RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M24B) & M24A !=1
// RAS

* 3. Valeurs légales
count if !inrange(M24B,1,3) & M24A ==1
//RAS 

*---------------------------------------------------------------
*M24C. Si oui, Quelles sont les couvertures dont %rostertitle% bénéficie ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
foreach var in M24C__1 M24C__2 M24C__3 M24C__4 M24C__7 M24C__8 {
count if missing(`var') & inlist(M24A,1)
} // RAS

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
foreach var in M24C__1 M24C__2 M24C__3 M24C__4 M24C__7 M24C__8 {
count if !missing(`var') & !inlist(M24A,1)
} //RAS. 

count if M24C__1 == 1 & (M24B==2 | M24B == 3 ) // 1090 personnes ayant répondu possédér la CMU et que cette CMU était l'assurance des parents ou l'assurance du conjoint. Ce qui est une grosse incoherence

replace commentaire="personnes ayant répondu possédér la CMU et que cette CMU était l'assurance des parents ou l'assurance du conjoint." if M24C__1 == 1 & (M24B==2 | M24B == 3 )
**Exportation des individus potentiellement concernés

count if M24C__1 == 1 & (M24B==2 | M24B == 3 ) 
if r(N)>0 {
    export excel interview__key HH2 HH12 HH13 M24C__1 M24B membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_assurance_CMU" if M24C__1 == 1 & (M24B==2 | M24B == 3 ) , firstrow(varl) replace
}
**

***etape de correction 

replace M24B = 3 if M24C__1 == 1 & M24C__2==0 & M24C__3==0 & M24C__4==0 & M24C__7==0  & AgeAnnee<=16 // nous considerons que toutes les personnes agé de moins de 16 ans ayant une CMU sont sous assurance parent 


*---------------------------------------------------------------
*M24B_Aut. Veuillez préciser l'autre Couverture en Assurance maladie ?
*---------------------------------------------------------------

* 1. Valeurs manquantes
count if missing(M24B_Aut) & M24C__7 == 7 // tous les individus devant répondre ont répondus

* 2. Vérifier que tous ceux qui ont répondu avait le droit de répondre
count if !missing(M24B_Aut) & M24C__7 != 1 // les individus ayant répondu avait le droit de répondre. 

ta M24B_Aut, miss // certains agent on renseigné "Assurance Conjoint/parent" au lieu de mentionné l'assurance en question

**Exportation des individus potentiellement concernés

*export excel interview__key HH13 M24B_Aut M24C__7 membre_id_v1 V1MODINTR using "$folderpath/document/comp_menage_assurance_autre" if M24B_Aut !="" , firstrow(varl) replace
**

cap drop HH2 HH3 HH12 HH13 HH4 HH6 HH8B V1interviewkey V1MODINTR M0__0 rgmen membre_id_v1_IND M4Confirm 

cap drop dup commentaire cm agecm Age_Cm_men ecart_age ecart_age1 HH14a HH14a_Aut

save  "$standard_menage\QM_S1_composition_menage.dta", replace











