*================================================
*********COMPOSITION DES MENAGES

****RESPONSABLE: ABDOUL KADER
*=============================================
/*
clear

use "$datain_brute\membres.dta", clear 

cap drop _merge

merge m:1 interview__key using "$datain_brute\qx_eec_vf.dta", keepusing(M0__0 HH13 HH12 hh V1MODINTR V1interviewkey )

keep if _merge==3
*/
*******************************************

use "$datain_standard\QM_S1_composition_menage.dta", clear

cap drop _merge
merge m:1 interview__key using "$datain_standard\QM_S0_identification.dta", keepus(HH2 HH3 HH12 HH13 HH4 HH6 HH8B V1interviewkey V1MODINTR M0__0 rgmen )
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


// suppression préalable des doublons car il pourrait affecter les resultats
cap drop dup
sort interview__id membres__id M0
quietly by interview__id membres__id M0 : gen dup = cond(_N==1,0,_n) 

ta dup // aucun doublons


*drop if dup > 1

** restriction au interview consenti


******************Controle de la section, question par question ****************************************************

// M0. Donnez-moi s'il vous plaît les noms et prénoms des personnes qui vivent habituellement dans votre ménage et des visiteurs qui ont passé la nuit dernière ici, en commençant par le chef de ménage.

count if M0__0 == "" // Pas de valeurs manquantes


// M1A.Lors du passage à la date du %V1hha% , vous nous avez dressé la liste des membres de votre ménage, avez-vous des personnes qui sont parties de votre ménage ou venues dans votre ménage et qui ont l'intention de faire plus de 6 mois?

count if missing(M1A) & membre_id_v1 !="##N/A##" // 483 individu pour qui la question n'a pas été répondu. Il faut préciser que cette question concerne les réintérrogations, donc il s'agit potentiellement d'un problème au niveau des téléopérateurs


count if (M1A==.a) & membre_id_v1 !="##N/A##" // 483 individu en reinterrogation non interogé (pour qui la question n'a pas été répondu). Il faut préciser que cette question concerne les réintérrogations, donc il s'agit potentiellement d'un problème au niveau des téléopérateurs. Ceux sont des menages en reinterrogations non interrogé

replace commentaire="l'agent téléopérateurs devrait renseigner la question M1A, mais n'a pas renseigné. (Ces entretiens sont perdu)" if  (M1A==.a) & membre_id_v1 !="##N/A##"
**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M1A membre_id_v1 V1MODINTR rgmen AgeAnnee M4Confirm commentaire using "$folderpath/document/comp_menage_six_mois_reinterrogation" if  (M1A==.a) & membre_id_v1 !="##N/A##", firstrow(varl) replace
**

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if (M1A == .a) & membre_id_v1 != "##N/A##"

*******************************************

count if (M1A==.a) & membre_id_v1 =="##N/A##" // 0 individu pour qui la question n'a pas été répondu. Il faut préciser que cette question concerne les agents terrains qui n'ont pas renseigner la question



*count if (M1A == 1 | M1A == 2 | M1A == 3 ) & membre_id_v1 == "##N/A##" // tous ceux qui ont repondu avaient le droit de repondre
count if (M1A == 1 | M1A == 2 ) & membre_id_v1 == "##N/A##" // tous ceux qui ont repondu avaient le droit de repondre

// M1.Au cours des 12 derniers mois, durant combien de mois %rostertitle% a vécu dans le ménage ?

count   if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==1 // 9 individus de 1ere interrogation, pour qui la question n'a pas été repondu. Ces individus sont perdu pour de bon car l'âge n'est pas mentionné

*replace  commentaire="9 individus de 1ere interrogation, pour qui la question M1 n'a pas été repondu. Ces individus sont perdu pour de bon car l'âge n'est pas mentionné" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==1 

**Exportation des individus potentiellement concernés

*export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR rgmen AgeAnnee M4Confirm commentaire using "$folderpath/document/M1_terrain_perdu_sans_age1" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==1 , firstrow(varl) replace
**

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==1

*******************************************


*********************************************************************************************************************************

count   if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2 // 31 individus de 2ieme interrogation, pour qui la question n'a pas été repondu. Ces individus sont perdu pour de bon car l'âge n'est pas mentionné

*replace  commentaire="31 individus de 2eme interrogation, pour qui la question M1 n'a pas été repondu. Ces individus sont perdu pour de bon car l'âge n'est pas mentionné" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2 


**Exportation des individus potentiellement concernés

*export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR rgmen AgeAnnee M4Confirm commentaire rgmen using "$folderpath/document/M1_age_teleoperateur_perdu" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2 , firstrow(varl) replace

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2

*******************************************


count if missing(M1) & membre_id_v1 == "##N/A##" // 81 individu de 1ere et 2eme pour qui la question n'a pas été repondu. 

replace commentaire="l'agent terrain devrait renseigner la question M1, mais n'a pas renseigné" if  missing(M1) & membre_id_v1 == "##N/A##"



**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_six_mois_face" if missing(M1) & membre_id_v1 == "##N/A##", firstrow(varl) replace
**

count if (M1 == 1 | M1 == 2 ) & membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit de repondre


// M2.Si moins de 6 mois, pendant combien de mois, %rostertitle% compte-t'il/t'elle rester dans le ménage ?

count if missing(M2) & (M1==1 | M1A==1) // 1 personnes pour qui la question n'a pas été répondu

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if missing(M2) & (M1==1 | M1A==1) 

*******************************************


count if !missing(M2) & (M1!=1 & M1A !=1) // tous ceux qui devrait repondre à la question on répondu

** Analyse du statut de residence et restriction de la base qu'au menage resident

count if Statut_Res !=1 // 1555 non resident. C'est beaucoup trop, il se pourrait que les agents mettent intentionnellement

replace commentaire="individus non résident au nombre de 1555" if Statut_Res !=1


** Exportation des agents qui serait potentiellement concernés
 
export excel interview__key HH2 HH12 HH13 Statut_Res commentaire rgmen using "$folderpath/document/comp_menage_stat_res" if Statut_Res !=1, firstrow(varl) replace

*drop if Statut_Res !=1

// M3. %rostertitle% a t-il/t'elle passé la nuit dernière dans le ménage ?

count if missing(M3) & Statut_Res==1 & M5==.a // 3 individus residents pour qui la question n'a pas été repondu. Ils sont perdu car le sexe n'e'st pas renseignés 

replace commentaire="11 individus residents pour qui la question n'a pas été repondu. Ils sont perdu car le sexe n'e'st pas renseignés" if missing(M3) & Statut_Res==1 & M5==.a


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M3 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_passe_nuit" if missing(M3) & Statut_Res==1 & M5==.a, firstrow(varl) replace

**

count if !missing(M3) & Statut_Res!=1 // tous ceux qui devrait repondre à la question on répondu


// M4A. Lors du passage à la date du %V1hha% , vous nous avez indiqué que le lien de parenté de %rostertitle% avec le chef de ménage était %V1M4% , confirmez-vous cette information ?

count if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1 // 32 personnes pour qui la question M4A n'a pas été répondu 

replace commentaire="L'agent téléopérateur n'a pas renseigner la question M4A. L'âge n'est pas mentionné" if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M4A membre_id_v1 V1MODINTR commentaire rgmen AgeAnnee M4Confirm using "$folderpath/document/comp_menage_passe_lien_confirm" if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1, firstrow(varl) replace

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1

*******************************************


*On cherche ces individus dans la base T2 pour imputation

*Tous les individus dont le membre_id_v1==1 (Chef de ménage dans la base T3) et qui sont aussi chef de ménage dans la base T3 (membre__id==1), M4A=1


*preserve

*keep if  missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1

*destring membre_id_v1, gen(membre_id_v1_ent) force

*Puisque l'âge n'a pas été renseigné on ne fait d'imputation.
*replace M4A=1 if ( missing(M4A) & membre_id_v1 != "##N/A##" & V1M4!=.a & Statut_Res==1) & (membre_id_v1_ent==membres__id) 


*restore

********************************



**

count if !missing(M4A) & (membre_id_v1 == "##N/A##" | V1M4 ==.a | Statut_Res !=1) // tous ceux qui ont répondu y avait le droit 



// M4. Quel est le lien de parenté de %rostertitle% avec le chef de ménage ? (1ere interrogation)

*count if missing(M4) & Statut_Res==1 & (membre_id_v1=="##N/A##" | M4A==2 | V1M4==.a) // 7 personnes pour qui la variable n'a pas été repondu

*count if missing(M4) & Statut_Res==1 & (membre_id_v1=="##N/A##" | M4A==2 | V1M4==.a) // 1 personnes pour qui la question n'a pas été répondu


*replace commentaire="L'agent terrain n'a pas renseigner la question M4. L'âge n'est aps renseigner" if missing(M4) & Statut_Res==1 & (membre_id_v1=="##N/A##" | M4A==2 | V1M4==.a)


**Exportation des individus potentiellement concernés

*export excel interview__key HH2 HH12 HH13 M4 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_lien" if missing(M4) & Statut_Res==1 & (membre_id_v1=="##N/A##" | M4A==2 | V1M4==.a), firstrow(varl) replace

**

count if !missing(M4) & Statut_Res !=1 & membre_id_v1 !="##N/A##" & M4A == 1 & V1M4 !=.a // tous ceux qui ont répondu y avaient le droit

// M5. Quel est le sexe de %rostertitle% ?

count if missing(M5) & Statut_Res==1 // 13 personnes pour qui on a pas le sexe : agent teleoperateur

ta rgmen if missing(M5) & Statut_Res==1


*Nous avons retrouvée ces idividus du trimestre 3 (réinterrogation) au trimestre 2, puis nous avons fait correspondre les interview et membres__id. Dans la base du T3 il y a deux variables : membre_id_v1 V1interviewkey qui sont les interview et membres__id du ménage du T3 réintérrogé. 

replace commentaire="Les agents n'ont pas renseigné  le sexe " if missing(M5) & Statut_Res==1 



**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M5 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_sexe" if missing(M5) & Statut_Res==1 , firstrow(varl) replace
**

*Incoherence sur le sexe entre T1-2025 (terrain) et T4-2024 (teleoperateur)


****Le principe de cette correction est de faire l'hypothèse que les sexe renseigné par l'agent terrain est plus correct que celui renseigne par le teleoperateur dans la situation ou le sexe renseigner par le teleoperateur est different de celui de l'agent terrain.

*** Correction des Individus dont le sexe est renseigné Feminin par erreur pour la cohorte T2-2025

replace M5 = 1 if interview__key == "33-02-67-70" & membres__id == 3
replace M5 = 1 if interview__key == "90-39-94-42" & membres__id == 3
replace M5 = 1 if interview__key == "56-71-22-48" & membres__id == 4
replace M5 = 1 if interview__key == "29-85-06-55" & membres__id == 2
replace M5 = 1 if interview__key == "42-44-91-36" & membres__id == 6
replace M5 = 1 if interview__key == "23-58-76-12" & membres__id == 4
replace M5 = 1 if interview__key == "35-84-64-80" & membres__id == 3
replace M5 = 1 if interview__key == "31-49-85-41" & membres__id == 1
replace M5 = 1 if interview__key == "83-03-01-55" & membres__id == 5
replace M5 = 1 if interview__key == "72-19-28-91" & membres__id == 3
replace M5 = 1 if interview__key == "84-77-39-74" & membres__id == 4
replace M5 = 1 if interview__key == "62-20-59-43" & membres__id == 8
replace M5 = 1 if interview__key == "09-05-75-04" & membres__id == 4
replace M5 = 1 if interview__key == "13-84-26-78" & membres__id == 4
replace M5 = 1 if interview__key == "03-39-39-48" & membres__id == 5
replace M5 = 1 if interview__key == "01-34-72-47" & membres__id == 4
replace M5 = 1 if interview__key == "35-12-27-80" & membres__id == 5
replace M5 = 1 if interview__key == "79-16-19-01" & membres__id == 3
replace M5 = 1 if interview__key == "99-24-41-56" & membres__id == 4
replace M5 = 1 if interview__key == "89-19-33-85" & membres__id == 4
replace M5 = 1 if interview__key == "85-24-34-27" & membres__id == 3
replace M5 = 1 if interview__key == "28-41-71-34" & membres__id == 4
replace M5 = 1 if interview__key == "77-49-24-98" & membres__id == 3
replace M5 = 1 if interview__key == "77-49-24-98" & membres__id == 5
replace M5 = 1 if interview__key == "86-53-38-36" & membres__id == 1
replace M5 = 1 if interview__key == "50-80-59-34" & membres__id == 5
replace M5 = 1 if interview__key == "57-32-26-03" & membres__id == 28
replace M5 = 1 if interview__key == "11-53-67-51" & membres__id == 3
replace M5 = 1 if interview__key == "83-83-77-58" & membres__id == 7
replace M5 = 1 if interview__key == "06-23-70-48" & membres__id == 5
replace M5 = 1 if interview__key == "18-04-87-56" & membres__id == 3
replace M5 = 1 if interview__key == "90-99-23-45" & membres__id == 3
replace M5 = 1 if interview__key == "45-87-09-07" & membres__id == 2
replace M5 = 1 if interview__key == "52-35-07-13" & membres__id == 1
replace M5 = 1 if interview__key == "95-69-50-59" & membres__id == 10
replace M5 = 1 if interview__key == "87-97-44-14" & membres__id == 5
replace M5 = 1 if interview__key == "47-66-29-27" & membres__id == 8
replace M5 = 1 if interview__key == "39-76-84-15" & membres__id == 7
replace M5 = 1 if interview__key == "42-72-24-59" & membres__id == 4
replace M5 = 1 if interview__key == "88-94-90-44" & membres__id == 4
replace M5 = 1 if interview__key == "51-55-30-18" & membres__id == 4
replace M5 = 1 if interview__key == "66-77-16-09" & membres__id == 3
replace M5 = 1 if interview__key == "03-72-25-98" & membres__id == 9
replace M5 = 1 if interview__key == "48-92-39-90" & membres__id == 4
replace M5 = 1 if interview__key == "81-10-43-21" & membres__id == 7
replace M5 = 1 if interview__key == "25-16-02-03" & membres__id == 1
replace M5 = 1 if interview__key == "04-80-73-76" & membres__id == 6
replace M5 = 1 if interview__key == "84-35-31-53" & membres__id == 4
replace M5 = 1 if interview__key == "35-89-74-94" & membres__id == 5
replace M5 = 1 if interview__key == "73-58-72-34" & membres__id == 11
replace M5 = 1 if interview__key == "12-57-49-09" & membres__id == 3
replace M5 = 1 if interview__key == "52-18-39-59" & membres__id == 4
replace M5 = 1 if interview__key == "19-17-27-11" & membres__id == 4
replace M5 = 1 if interview__key == "31-95-19-05" & membres__id == 5
replace M5 = 1 if interview__key == "31-95-19-05" & membres__id == 6
replace M5 = 1 if interview__key == "07-73-09-90" & membres__id == 5
replace M5 = 1 if interview__key == "20-28-04-12" & membres__id == 9
replace M5 = 1 if interview__key == "58-09-45-63" & membres__id == 7
replace M5 = 1 if interview__key == "44-70-13-75" & membres__id == 3
replace M5 = 1 if interview__key == "40-33-50-46" & membres__id == 1
replace M5 = 1 if interview__key == "26-62-04-82" & membres__id == 4
replace M5 = 1 if interview__key == "26-62-04-82" & membres__id == 5
replace M5 = 1 if interview__key == "35-08-13-43" & membres__id == 3
replace M5 = 1 if interview__key == "27-07-92-16" & membres__id == 1
replace M5 = 1 if interview__key == "49-11-97-70" & membres__id == 5
replace M5 = 1 if interview__key == "08-61-65-27" & membres__id == 21
replace M5 = 1 if interview__key == "80-64-76-50" & membres__id == 4
replace M5 = 1 if interview__key == "24-67-14-87" & membres__id == 6
replace M5 = 1 if interview__key == "67-04-06-97" & membres__id == 4
replace M5 = 1 if interview__key == "66-01-27-83" & membres__id == 5
replace M5 = 1 if interview__key == "62-92-75-08" & membres__id == 2
replace M5 = 1 if interview__key == "53-41-77-84" & membres__id == 3
replace M5 = 1 if interview__key == "59-28-50-25" & membres__id == 2
replace M5 = 1 if interview__key == "18-45-98-96" & membres__id == 5
replace M5 = 1 if interview__key == "24-01-39-26" & membres__id == 4
replace M5 = 1 if interview__key == "67-43-54-61" & membres__id == 6
replace M5 = 1 if interview__key == "25-60-76-45" & membres__id == 4
replace M5 = 1 if interview__key == "98-95-75-95" & membres__id == 3
replace M5 = 1 if interview__key == "57-83-50-81" & membres__id == 3
replace M5 = 1 if interview__key == "57-83-50-81" & membres__id == 5
replace M5 = 1 if interview__key == "57-83-50-81" & membres__id == 10
replace M5 = 1 if interview__key == "57-83-50-81" & membres__id == 11
replace M5 = 1 if interview__key == "97-49-23-14" & membres__id == 4
replace M5 = 1 if interview__key == "97-49-23-14" & membres__id == 9
replace M5 = 1 if interview__key == "90-02-96-07" & membres__id == 5
replace M5 = 1 if interview__key == "95-21-03-95" & membres__id == 4
replace M5 = 1 if interview__key == "95-21-03-95" & membres__id == 7
replace M5 = 1 if interview__key == "68-87-66-14" & membres__id == 6
replace M5 = 1 if interview__key == "99-07-11-16" & membres__id == 7
replace M5 = 1 if interview__key == "93-19-89-96" & membres__id == 3
replace M5 = 1 if interview__key == "26-76-30-43" & membres__id == 3
replace M5 = 1 if interview__key == "66-99-77-45" & membres__id == 2
replace M5 = 1 if interview__key == "96-05-16-30" & membres__id == 2
replace M5 = 1 if interview__key == "28-32-64-92" & membres__id == 4
replace M5 = 1 if interview__key == "66-29-28-75" & membres__id == 3
replace M5 = 1 if interview__key == "32-36-61-95" & membres__id == 1
replace M5 = 1 if interview__key == "16-52-91-60" & membres__id == 1
replace M5 = 1 if interview__key == "67-00-39-07" & membres__id == 3
replace M5 = 1 if interview__key == "83-03-00-52" & membres__id == 4
replace M5 = 1 if interview__key == "70-59-54-24" & membres__id == 3
replace M5 = 1 if interview__key == "89-21-42-19" & membres__id == 1
replace M5 = 1 if interview__key == "00-02-73-78" & membres__id == 4
replace M5 = 1 if interview__key == "68-74-30-69" & membres__id == 3
replace M5 = 1 if interview__key == "98-93-55-05" & membres__id == 3
replace M5 = 1 if interview__key == "36-13-29-27" & membres__id == 2
replace M5 = 1 if interview__key == "69-02-76-45" & membres__id == 7
replace M5 = 1 if interview__key == "69-02-76-45" & membres__id == 8
replace M5 = 1 if interview__key == "13-33-07-58" & membres__id == 4
replace M5 = 1 if interview__key == "80-76-98-00" & membres__id == 4
replace M5 = 1 if interview__key == "69-42-54-96" & membres__id == 4
replace M5 = 1 if interview__key == "22-07-12-90" & membres__id == 4
replace M5 = 1 if interview__key == "35-06-60-79" & membres__id == 3
replace M5 = 1 if interview__key == "74-69-07-12" & membres__id == 3
replace M5 = 1 if interview__key == "01-11-90-58" & membres__id == 4
replace M5 = 1 if interview__key == "51-66-22-82" & membres__id == 5
replace M5 = 1 if interview__key == "04-71-62-81" & membres__id == 4
replace M5 = 1 if interview__key == "69-51-19-34" & membres__id == 4
replace M5 = 1 if interview__key == "12-87-03-05" & membres__id == 5
replace M5 = 1 if interview__key == "04-69-43-70" & membres__id == 4
replace M5 = 1 if interview__key == "23-51-19-00" & membres__id == 6
replace M5 = 1 if interview__key == "29-32-67-83" & membres__id == 5
replace M5 = 1 if interview__key == "54-13-09-97" & membres__id == 3
replace M5 = 1 if interview__key == "72-55-80-03" & membres__id == 1
replace M5 = 1 if interview__key == "05-74-83-55" & membres__id == 3
replace M5 = 1 if interview__key == "82-66-13-91" & membres__id == 10
replace M5 = 1 if interview__key == "37-23-13-64" & membres__id == 6
replace M5 = 1 if interview__key == "08-87-65-07" & membres__id == 6
replace M5 = 1 if interview__key == "21-81-74-30" & membres__id == 4
replace M5 = 1 if interview__key == "48-13-70-95" & membres__id == 3
replace M5 = 1 if interview__key == "24-69-84-27" & membres__id == 5
replace M5 = 1 if interview__key == "24-69-84-27" & membres__id == 10

*** Correction des Individus dont le sexe est renseigné Masculin par erreur pour la cohorte T3-2025

replace M5 = 2 if interview__key == "57-49-83-18" & membres__id == 6
replace M5 = 2 if interview__key == "42-44-91-36" & membres__id == 7
replace M5 = 2 if interview__key == "20-64-14-39" & membres__id == 4
replace M5 = 2 if interview__key == "29-37-30-37" & membres__id == 4
replace M5 = 2 if interview__key == "28-15-22-82" & membres__id == 6
replace M5 = 2 if interview__key == "08-99-99-18" & membres__id == 3
replace M5 = 2 if interview__key == "86-20-47-09" & membres__id == 5
replace M5 = 2 if interview__key == "41-41-72-91" & membres__id == 3
replace M5 = 2 if interview__key == "99-29-81-73" & membres__id == 6
replace M5 = 2 if interview__key == "62-20-59-43" & membres__id == 6
replace M5 = 2 if interview__key == "82-00-47-06" & membres__id == 3
replace M5 = 2 if interview__key == "59-78-90-41" & membres__id == 1
replace M5 = 2 if interview__key == "57-17-21-74" & membres__id == 5
replace M5 = 2 if interview__key == "66-36-79-19" & membres__id == 4
replace M5 = 2 if interview__key == "66-36-79-19" & membres__id == 6
replace M5 = 2 if interview__key == "67-62-26-38" & membres__id == 2
replace M5 = 2 if interview__key == "55-01-56-80" & membres__id == 5
replace M5 = 2 if interview__key == "16-69-35-92" & membres__id == 2
replace M5 = 2 if interview__key == "61-11-81-66" & membres__id == 4
replace M5 = 2 if interview__key == "61-11-81-66" & membres__id == 5
replace M5 = 2 if interview__key == "71-81-93-82" & membres__id == 5
replace M5 = 2 if interview__key == "29-75-52-66" & membres__id == 7
replace M5 = 2 if interview__key == "34-55-01-41" & membres__id == 7
replace M5 = 2 if interview__key == "74-60-19-33" & membres__id == 4
replace M5 = 2 if interview__key == "74-60-19-33" & membres__id == 7
replace M5 = 2 if interview__key == "77-49-24-98" & membres__id == 8
replace M5 = 2 if interview__key == "77-49-24-98" & membres__id == 9
replace M5 = 2 if interview__key == "01-95-20-03" & membres__id == 4
replace M5 = 2 if interview__key == "77-64-04-42" & membres__id == 3
replace M5 = 2 if interview__key == "95-57-91-14" & membres__id == 3
replace M5 = 2 if interview__key == "20-93-04-99" & membres__id == 1
replace M5 = 2 if interview__key == "65-40-13-33" & membres__id == 1
replace M5 = 2 if interview__key == "96-01-08-02" & membres__id == 4
replace M5 = 2 if interview__key == "59-91-07-87" & membres__id == 1
replace M5 = 2 if interview__key == "97-80-12-22" & membres__id == 2
replace M5 = 2 if interview__key == "88-48-09-55" & membres__id == 3
replace M5 = 2 if interview__key == "33-87-74-38" & membres__id == 7
replace M5 = 2 if interview__key == "39-99-41-49" & membres__id == 2
replace M5 = 2 if interview__key == "58-42-88-48" & membres__id == 6
replace M5 = 2 if interview__key == "60-82-45-71" & membres__id == 3
replace M5 = 2 if interview__key == "83-83-77-58" & membres__id == 1
replace M5 = 2 if interview__key == "14-13-28-78" & membres__id == 4
replace M5 = 2 if interview__key == "95-69-50-59" & membres__id == 9
replace M5 = 2 if interview__key == "47-11-48-42" & membres__id == 6
replace M5 = 2 if interview__key == "61-33-91-05" & membres__id == 3
replace M5 = 2 if interview__key == "55-73-73-83" & membres__id == 5
replace M5 = 2 if interview__key == "41-49-82-77" & membres__id == 1
replace M5 = 2 if interview__key == "10-70-13-66" & membres__id == 1
replace M5 = 2 if interview__key == "51-39-83-14" & membres__id == 1
replace M5 = 2 if interview__key == "70-32-17-33" & membres__id == 1
replace M5 = 2 if interview__key == "97-94-96-22" & membres__id == 4
replace M5 = 2 if interview__key == "30-82-98-78" & membres__id == 7
replace M5 = 2 if interview__key == "73-58-72-34" & membres__id == 17
replace M5 = 2 if interview__key == "15-96-08-80" & membres__id == 4
replace M5 = 2 if interview__key == "69-91-75-92" & membres__id == 5
replace M5 = 2 if interview__key == "25-45-86-02" & membres__id == 2
replace M5 = 2 if interview__key == "49-70-41-68" & membres__id == 5
replace M5 = 2 if interview__key == "35-55-76-90" & membres__id == 3
replace M5 = 2 if interview__key == "30-21-32-43" & membres__id == 4
replace M5 = 2 if interview__key == "39-76-39-74" & membres__id == 2
replace M5 = 2 if interview__key == "42-24-88-55" & membres__id == 4
replace M5 = 2 if interview__key == "42-24-88-55" & membres__id == 8
replace M5 = 2 if interview__key == "27-06-55-18" & membres__id == 4
replace M5 = 2 if interview__key == "91-71-74-61" & membres__id == 2
replace M5 = 2 if interview__key == "58-09-45-63" & membres__id == 6
replace M5 = 2 if interview__key == "25-26-76-74" & membres__id == 7
replace M5 = 2 if interview__key == "53-50-54-41" & membres__id == 7
replace M5 = 2 if interview__key == "20-83-74-41" & membres__id == 3
replace M5 = 2 if interview__key == "33-73-01-51" & membres__id == 13
replace M5 = 2 if interview__key == "26-62-04-82" & membres__id == 3
replace M5 = 2 if interview__key == "85-76-57-33" & membres__id == 8
replace M5 = 2 if interview__key == "81-26-18-16" & membres__id == 1
replace M5 = 2 if interview__key == "54-98-07-40" & membres__id == 10
replace M5 = 2 if interview__key == "21-95-91-63" & membres__id == 4
replace M5 = 2 if interview__key == "21-95-91-63" & membres__id == 8
replace M5 = 2 if interview__key == "27-68-62-35" & membres__id == 3
replace M5 = 2 if interview__key == "18-45-98-96" & membres__id == 4
replace M5 = 2 if interview__key == "86-99-44-98" & membres__id == 4
replace M5 = 2 if interview__key == "96-03-59-95" & membres__id == 4
replace M5 = 2 if interview__key == "55-62-60-72" & membres__id == 5
replace M5 = 2 if interview__key == "19-17-19-02" & membres__id == 1
replace M5 = 2 if interview__key == "79-74-09-43" & membres__id == 3
replace M5 = 2 if interview__key == "68-87-66-14" & membres__id == 5
replace M5 = 2 if interview__key == "15-35-05-34" & membres__id == 3
replace M5 = 2 if interview__key == "97-70-09-29" & membres__id == 5
replace M5 = 2 if interview__key == "58-86-04-90" & membres__id == 5
replace M5 = 2 if interview__key == "99-07-11-16" & membres__id == 10
replace M5 = 2 if interview__key == "57-17-43-49" & membres__id == 3
replace M5 = 2 if interview__key == "18-68-42-76" & membres__id == 5
replace M5 = 2 if interview__key == "15-66-36-46" & membres__id == 3
replace M5 = 2 if interview__key == "33-80-06-16" & membres__id == 4
replace M5 = 2 if interview__key == "26-24-38-06" & membres__id == 3
replace M5 = 2 if interview__key == "15-72-30-61" & membres__id == 4
replace M5 = 2 if interview__key == "11-30-32-53" & membres__id == 5
replace M5 = 2 if interview__key == "71-86-98-34" & membres__id == 8
replace M5 = 2 if interview__key == "54-98-84-38" & membres__id == 6
replace M5 = 2 if interview__key == "74-16-83-57" & membres__id == 4
replace M5 = 2 if interview__key == "74-16-83-57" & membres__id == 5
replace M5 = 2 if interview__key == "19-04-15-49" & membres__id == 1
replace M5 = 2 if interview__key == "67-74-97-66" & membres__id == 4
replace M5 = 2 if interview__key == "70-72-97-83" & membres__id == 3
replace M5 = 2 if interview__key == "56-16-01-36" & membres__id == 6
replace M5 = 2 if interview__key == "47-28-82-13" & membres__id == 5
replace M5 = 2 if interview__key == "28-32-64-92" & membres__id == 1
replace M5 = 2 if interview__key == "09-74-02-64" & membres__id == 1
replace M5 = 2 if interview__key == "93-71-53-29" & membres__id == 4
replace M5 = 2 if interview__key == "24-80-11-65" & membres__id == 3
replace M5 = 2 if interview__key == "33-72-96-67" & membres__id == 5
replace M5 = 2 if interview__key == "12-25-24-47" & membres__id == 2
replace M5 = 2 if interview__key == "71-11-91-52" & membres__id == 3
replace M5 = 2 if interview__key == "96-82-32-37" & membres__id == 10
replace M5 = 2 if interview__key == "37-39-82-06" & membres__id == 3
replace M5 = 2 if interview__key == "55-33-61-76" & membres__id == 4
replace M5 = 2 if interview__key == "56-06-77-90" & membres__id == 13
replace M5 = 2 if interview__key == "44-61-83-11" & membres__id == 4
replace M5 = 2 if interview__key == "13-65-69-90" & membres__id == 3
replace M5 = 2 if interview__key == "62-90-62-26" & membres__id == 10
replace M5 = 2 if interview__key == "91-74-43-49" & membres__id == 1
replace M5 = 2 if interview__key == "17-76-78-82" & membres__id == 4
replace M5 = 2 if interview__key == "17-76-78-82" & membres__id == 5
replace M5 = 2 if interview__key == "22-07-12-90" & membres__id == 6
replace M5 = 2 if interview__key == "73-49-21-95" & membres__id == 1
replace M5 = 2 if interview__key == "88-41-57-30" & membres__id == 1
replace M5 = 2 if interview__key == "57-38-43-58" & membres__id == 4
replace M5 = 2 if interview__key == "13-18-19-00" & membres__id == 4
replace M5 = 2 if interview__key == "17-38-99-47" & membres__id == 2
replace M5 = 2 if interview__key == "17-38-99-47" & membres__id == 4
replace M5 = 2 if interview__key == "08-57-47-78" & membres__id == 9
replace M5 = 2 if interview__key == "59-18-07-48" & membres__id == 7
replace M5 = 2 if interview__key == "38-02-12-26" & membres__id == 9
replace M5 = 2 if interview__key == "68-28-72-62" & membres__id == 1
replace M5 = 2 if interview__key == "69-54-59-82" & membres__id == 5
replace M5 = 2 if interview__key == "65-49-97-18" & membres__id == 7
replace M5 = 2 if interview__key == "77-26-47-81" & membres__id == 6
replace M5 = 2 if interview__key == "34-19-48-32" & membres__id == 10
replace M5 = 2 if interview__key == "34-19-48-32" & membres__id == 14
replace M5 = 2 if interview__key == "25-52-85-14" & membres__id == 4
replace M5 = 2 if interview__key == "36-77-73-05" & membres__id == 5
replace M5 = 2 if interview__key == "98-40-53-13" & membres__id == 3
replace M5 = 2 if interview__key == "98-40-53-13" & membres__id == 5
replace M5 = 2 if interview__key == "98-40-53-13" & membres__id == 6
replace M5 = 2 if interview__key == "33-15-54-48" & membres__id == 3
replace M5 = 2 if interview__key == "87-41-88-64" & membres__id == 4
replace M5 = 2 if interview__key == "76-25-04-76" & membres__id == 5
replace M5 = 2 if interview__key == "93-42-95-65" & membres__id == 5
replace M5 = 2 if interview__key == "67-71-25-34" & membres__id == 3


*** Correction des Individus dont le sexe est renseigné Masculin par erreur pour la cohorte T3-2025

replace M5 = 1 if interview__key == "50-75-47-52" & membres__id == 2
replace M5 = 1 if interview__key == "03-94-91-09" & membres__id == 3
replace M5 = 1 if interview__key == "13-40-35-76" & membres__id == 2
replace M5 = 1 if interview__key == "40-52-43-29" & membres__id == 6
replace M5 = 1 if interview__key == "44-44-49-11" & membres__id == 6
replace M5 = 1 if interview__key == "23-19-36-52" & membres__id == 3
replace M5 = 1 if interview__key == "87-40-00-16" & membres__id == 2
replace M5 = 1 if interview__key == "00-77-53-05" & membres__id == 5
replace M5 = 1 if interview__key == "44-34-38-34" & membres__id == 8
replace M5 = 1 if interview__key == "71-85-59-79" & membres__id == 4
replace M5 = 1 if interview__key == "37-90-60-26" & membres__id == 4
replace M5 = 1 if interview__key == "13-11-07-61" & membres__id == 2
replace M5 = 1 if interview__key == "43-72-64-11" & membres__id == 6
replace M5 = 1 if interview__key == "54-13-15-25" & membres__id == 1
replace M5 = 1 if interview__key == "66-64-96-98" & membres__id == 9
replace M5 = 1 if interview__key == "42-54-95-29" & membres__id == 2
replace M5 = 1 if interview__key == "42-86-93-02" & membres__id == 2
replace M5 = 1 if interview__key == "59-90-68-26" & membres__id == 5
replace M5 = 1 if interview__key == "69-33-68-25" & membres__id == 3
replace M5 = 1 if interview__key == "61-98-38-65" & membres__id == 5
replace M5 = 1 if interview__key == "00-99-76-42" & membres__id == 7
replace M5 = 1 if interview__key == "39-87-12-32" & membres__id == 2
replace M5 = 1 if interview__key == "18-11-24-90" & membres__id == 5
replace M5 = 1 if interview__key == "02-07-73-16" & membres__id == 4
replace M5 = 1 if interview__key == "32-25-26-41" & membres__id == 4
replace M5 = 1 if interview__key == "90-39-55-98" & membres__id == 5
replace M5 = 1 if interview__key == "21-22-14-07" & membres__id == 3
replace M5 = 1 if interview__key == "57-00-41-16" & membres__id == 9
replace M5 = 1 if interview__key == "57-33-54-40" & membres__id == 4
replace M5 = 1 if interview__key == "15-15-46-85" & membres__id == 6
replace M5 = 1 if interview__key == "02-22-54-49" & membres__id == 5
replace M5 = 1 if interview__key == "82-82-95-18" & membres__id == 5
replace M5 = 1 if interview__key == "00-18-10-30" & membres__id == 5
replace M5 = 1 if interview__key == "93-39-14-88" & membres__id == 2
replace M5 = 1 if interview__key == "35-53-38-02" & membres__id == 3
replace M5 = 1 if interview__key == "24-59-87-46" & membres__id == 4
replace M5 = 1 if interview__key == "20-37-94-24" & membres__id == 4
replace M5 = 1 if interview__key == "20-37-94-24" & membres__id == 5
replace M5 = 1 if interview__key == "16-07-31-61" & membres__id == 3
replace M5 = 1 if interview__key == "06-97-03-85" & membres__id == 7
replace M5 = 1 if interview__key == "32-55-86-80" & membres__id == 8
replace M5 = 1 if interview__key == "38-80-49-55" & membres__id == 3
replace M5 = 1 if interview__key == "07-24-02-54" & membres__id == 5
replace M5 = 1 if interview__key == "64-23-50-15" & membres__id == 3
replace M5 = 1 if interview__key == "63-76-07-04" & membres__id == 5
replace M5 = 1 if interview__key == "53-64-35-57" & membres__id == 5
replace M5 = 1 if interview__key == "05-71-57-63" & membres__id == 4
replace M5 = 1 if interview__key == "73-69-62-95" & membres__id == 11
replace M5 = 1 if interview__key == "73-69-62-95" & membres__id == 14
replace M5 = 1 if interview__key == "41-79-45-99" & membres__id == 1
replace M5 = 1 if interview__key == "65-11-18-98" & membres__id == 1
replace M5 = 1 if interview__key == "26-69-95-06" & membres__id == 3
replace M5 = 1 if interview__key == "16-02-83-51" & membres__id == 3
replace M5 = 1 if interview__key == "54-72-68-85" & membres__id == 5
replace M5 = 1 if interview__key == "04-29-26-82" & membres__id == 3
replace M5 = 1 if interview__key == "60-95-88-13" & membres__id == 3
replace M5 = 1 if interview__key == "73-50-92-70" & membres__id == 6
replace M5 = 1 if interview__key == "28-33-62-47" & membres__id == 5
replace M5 = 1 if interview__key == "35-03-71-25" & membres__id == 7
replace M5 = 1 if interview__key == "82-88-02-98" & membres__id == 1
replace M5 = 1 if interview__key == "64-17-26-02" & membres__id == 6
replace M5 = 1 if interview__key == "58-31-09-76" & membres__id == 6
replace M5 = 1 if interview__key == "56-30-48-04" & membres__id == 8
replace M5 = 1 if interview__key == "34-87-84-99" & membres__id == 4
replace M5 = 1 if interview__key == "12-81-10-48" & membres__id == 3
replace M5 = 1 if interview__key == "77-01-94-70" & membres__id == 2
replace M5 = 1 if interview__key == "79-71-69-07" & membres__id == 7
replace M5 = 1 if interview__key == "60-13-06-72" & membres__id == 4
replace M5 = 1 if interview__key == "60-13-06-72" & membres__id == 11
replace M5 = 1 if interview__key == "42-75-30-82" & membres__id == 4
replace M5 = 1 if interview__key == "26-91-88-57" & membres__id == 3
replace M5 = 1 if interview__key == "70-13-51-76" & membres__id == 3
replace M5 = 1 if interview__key == "03-43-11-89" & membres__id == 6
replace M5 = 1 if interview__key == "03-43-11-89" & membres__id == 10
replace M5 = 1 if interview__key == "17-31-93-49" & membres__id == 2
replace M5 = 1 if interview__key == "35-00-04-83" & membres__id == 5
replace M5 = 1 if interview__key == "44-80-19-10" & membres__id == 9
replace M5 = 1 if interview__key == "22-47-03-02" & membres__id == 4
replace M5 = 1 if interview__key == "03-34-38-72" & membres__id == 7
replace M5 = 1 if interview__key == "69-96-32-43" & membres__id == 3
replace M5 = 1 if interview__key == "75-34-19-13" & membres__id == 5
replace M5 = 1 if interview__key == "75-34-19-13" & membres__id == 8
replace M5 = 1 if interview__key == "59-24-46-99" & membres__id == 6
replace M5 = 1 if interview__key == "77-85-23-13" & membres__id == 7
replace M5 = 1 if interview__key == "77-85-23-13" & membres__id == 8
replace M5 = 1 if interview__key == "37-05-11-38" & membres__id == 4
replace M5 = 1 if interview__key == "22-63-02-60" & membres__id == 4
replace M5 = 1 if interview__key == "66-04-82-34" & membres__id == 1
replace M5 = 1 if interview__key == "92-34-54-63" & membres__id == 3
replace M5 = 1 if interview__key == "97-69-71-38" & membres__id == 3
replace M5 = 1 if interview__key == "83-19-33-24" & membres__id == 5
replace M5 = 1 if interview__key == "64-80-11-58" & membres__id == 1
replace M5 = 1 if interview__key == "44-74-20-23" & membres__id == 4
replace M5 = 1 if interview__key == "26-78-98-10" & membres__id == 4
replace M5 = 1 if interview__key == "26-78-98-10" & membres__id == 5
replace M5 = 1 if interview__key == "26-78-98-10" & membres__id == 6
replace M5 = 1 if interview__key == "36-66-59-39" & membres__id == 5
replace M5 = 1 if interview__key == "28-87-35-90" & membres__id == 4
replace M5 = 1 if interview__key == "94-85-34-69" & membres__id == 5
replace M5 = 1 if interview__key == "03-34-21-41" & membres__id == 2
replace M5 = 1 if interview__key == "47-21-07-87" & membres__id == 3
replace M5 = 1 if interview__key == "61-19-48-13" & membres__id == 2
replace M5 = 1 if interview__key == "42-35-15-21" & membres__id == 3
replace M5 = 1 if interview__key == "79-46-84-01" & membres__id == 4
replace M5 = 1 if interview__key == "05-99-01-21" & membres__id == 4
replace M5 = 1 if interview__key == "48-45-72-24" & membres__id == 4
replace M5 = 1 if interview__key == "48-45-72-24" & membres__id == 12
replace M5 = 1 if interview__key == "48-45-72-24" & membres__id == 13
replace M5 = 1 if interview__key == "21-96-55-56" & membres__id == 3
replace M5 = 1 if interview__key == "21-45-83-58" & membres__id == 4
replace M5 = 1 if interview__key == "44-90-58-43" & membres__id == 4
replace M5 = 1 if interview__key == "66-84-82-91" & membres__id == 7
replace M5 = 1 if interview__key == "15-69-43-01" & membres__id == 6
replace M5 = 1 if interview__key == "30-61-14-99" & membres__id == 1
replace M5 = 1 if interview__key == "56-09-59-22" & membres__id == 5
replace M5 = 1 if interview__key == "52-57-14-67" & membres__id == 4
replace M5 = 1 if interview__key == "78-72-55-12" & membres__id == 3
replace M5 = 1 if interview__key == "15-72-24-14" & membres__id == 9
replace M5 = 1 if interview__key == "53-87-37-58" & membres__id == 3
replace M5 = 1 if interview__key == "37-47-58-42" & membres__id == 6
replace M5 = 1 if interview__key == "48-29-18-81" & membres__id == 4
replace M5 = 1 if interview__key == "80-20-10-76" & membres__id == 7
replace M5 = 1 if interview__key == "53-98-63-65" & membres__id == 5


*** Correction des Individus dont le sexe est renseigné Feminin par erreur pour la cohorte T3-2025


replace M5 = 2 if interview__key == "78-50-34-27" & membres__id == 10
replace M5 = 2 if interview__key == "45-46-22-74" & membres__id == 8
replace M5 = 2 if interview__key == "88-01-41-63" & membres__id == 6
replace M5 = 2 if interview__key == "82-16-55-05" & membres__id == 1
replace M5 = 2 if interview__key == "75-80-49-91" & membres__id == 4
replace M5 = 2 if interview__key == "69-74-39-48" & membres__id == 3
replace M5 = 2 if interview__key == "07-25-33-66" & membres__id == 5
replace M5 = 2 if interview__key == "47-54-20-79" & membres__id == 3
replace M5 = 2 if interview__key == "71-85-59-79" & membres__id == 5
replace M5 = 2 if interview__key == "17-35-68-04" & membres__id == 1
replace M5 = 2 if interview__key == "80-95-13-96" & membres__id == 3
replace M5 = 2 if interview__key == "16-05-27-88" & membres__id == 4
replace M5 = 2 if interview__key == "28-76-46-47" & membres__id == 1
replace M5 = 2 if interview__key == "66-64-96-98" & membres__id == 7
replace M5 = 2 if interview__key == "58-02-93-74" & membres__id == 5
replace M5 = 2 if interview__key == "01-37-41-75" & membres__id == 4
replace M5 = 2 if interview__key == "91-72-34-46" & membres__id == 3
replace M5 = 2 if interview__key == "12-98-48-07" & membres__id == 2
replace M5 = 2 if interview__key == "16-58-65-78" & membres__id == 3
replace M5 = 2 if interview__key == "00-99-76-42" & membres__id == 5
replace M5 = 2 if interview__key == "34-44-08-14" & membres__id == 3
replace M5 = 2 if interview__key == "02-78-33-39" & membres__id == 6
replace M5 = 2 if interview__key == "93-79-69-04" & membres__id == 3
replace M5 = 2 if interview__key == "36-87-08-87" & membres__id == 4
replace M5 = 2 if interview__key == "90-39-55-98" & membres__id == 4
replace M5 = 2 if interview__key == "90-39-55-98" & membres__id == 7
replace M5 = 2 if interview__key == "92-79-96-90" & membres__id == 3
replace M5 = 2 if interview__key == "57-33-54-40" & membres__id == 5
replace M5 = 2 if interview__key == "18-59-28-22" & membres__id == 3
replace M5 = 2 if interview__key == "91-09-71-85" & membres__id == 4
replace M5 = 2 if interview__key == "82-82-95-18" & membres__id == 3
replace M5 = 2 if interview__key == "55-03-23-60" & membres__id == 3
replace M5 = 2 if interview__key == "86-49-63-88" & membres__id == 3
replace M5 = 2 if interview__key == "31-65-52-34" & membres__id == 10
replace M5 = 2 if interview__key == "84-33-42-30" & membres__id == 4
replace M5 = 2 if interview__key == "93-39-14-88" & membres__id == 1
replace M5 = 2 if interview__key == "26-53-13-97" & membres__id == 6
replace M5 = 2 if interview__key == "31-57-89-86" & membres__id == 1
replace M5 = 2 if interview__key == "07-19-16-19" & membres__id == 4
replace M5 = 2 if interview__key == "79-93-28-32" & membres__id == 4
replace M5 = 2 if interview__key == "01-76-33-29" & membres__id == 2
replace M5 = 2 if interview__key == "46-54-79-55" & membres__id == 1
replace M5 = 2 if interview__key == "15-01-89-88" & membres__id == 9
replace M5 = 2 if interview__key == "56-59-22-03" & membres__id == 1
replace M5 = 2 if interview__key == "42-47-87-39" & membres__id == 7
replace M5 = 2 if interview__key == "25-58-99-39" & membres__id == 5
replace M5 = 2 if interview__key == "81-69-36-79" & membres__id == 2
replace M5 = 2 if interview__key == "07-24-02-54" & membres__id == 6
replace M5 = 2 if interview__key == "86-73-94-47" & membres__id == 3
replace M5 = 2 if interview__key == "24-18-44-54" & membres__id == 3
replace M5 = 2 if interview__key == "74-79-68-38" & membres__id == 3
replace M5 = 2 if interview__key == "53-50-63-64" & membres__id == 5
replace M5 = 2 if interview__key == "09-39-55-70" & membres__id == 2
replace M5 = 2 if interview__key == "99-97-17-83" & membres__id == 3
replace M5 = 2 if interview__key == "99-97-17-83" & membres__id == 4
replace M5 = 2 if interview__key == "27-10-28-63" & membres__id == 3
replace M5 = 2 if interview__key == "27-10-28-63" & membres__id == 6
replace M5 = 2 if interview__key == "60-80-68-36" & membres__id == 3
replace M5 = 2 if interview__key == "97-37-36-51" & membres__id == 7
replace M5 = 2 if interview__key == "13-28-47-81" & membres__id == 1
replace M5 = 2 if interview__key == "73-35-22-82" & membres__id == 3
replace M5 = 2 if interview__key == "84-09-39-97" & membres__id == 3
replace M5 = 2 if interview__key == "16-02-83-51" & membres__id == 1
replace M5 = 2 if interview__key == "63-97-70-41" & membres__id == 8
replace M5 = 2 if interview__key == "60-63-41-14" & membres__id == 5
replace M5 = 2 if interview__key == "03-46-40-08" & membres__id == 3
replace M5 = 2 if interview__key == "81-25-85-82" & membres__id == 4
replace M5 = 2 if interview__key == "11-73-56-43" & membres__id == 3
replace M5 = 2 if interview__key == "70-19-81-71" & membres__id == 1
replace M5 = 2 if interview__key == "28-33-62-47" & membres__id == 4
replace M5 = 2 if interview__key == "47-91-21-40" & membres__id == 2
replace M5 = 2 if interview__key == "58-31-09-76" & membres__id == 3
replace M5 = 2 if interview__key == "28-77-67-01" & membres__id == 1
replace M5 = 2 if interview__key == "00-27-90-78" & membres__id == 6
replace M5 = 2 if interview__key == "79-71-69-07" & membres__id == 4
replace M5 = 2 if interview__key == "08-25-03-52" & membres__id == 4
replace M5 = 2 if interview__key == "94-19-76-85" & membres__id == 5
replace M5 = 2 if interview__key == "67-00-16-55" & membres__id == 5
replace M5 = 2 if interview__key == "23-58-85-01" & membres__id == 5
replace M5 = 2 if interview__key == "00-63-03-89" & membres__id == 5
replace M5 = 2 if interview__key == "20-12-39-54" & membres__id == 7
replace M5 = 2 if interview__key == "55-93-31-14" & membres__id == 3
replace M5 = 2 if interview__key == "97-11-50-80" & membres__id == 4
replace M5 = 2 if interview__key == "89-85-22-99" & membres__id == 1
replace M5 = 2 if interview__key == "44-28-65-56" & membres__id == 5
replace M5 = 2 if interview__key == "50-11-50-36" & membres__id == 2
replace M5 = 2 if interview__key == "41-16-60-05" & membres__id == 10
replace M5 = 2 if interview__key == "11-41-38-02" & membres__id == 4
replace M5 = 2 if interview__key == "94-44-18-41" & membres__id == 3
replace M5 = 2 if interview__key == "17-66-68-73" & membres__id == 4
replace M5 = 2 if interview__key == "18-55-10-90" & membres__id == 1
replace M5 = 2 if interview__key == "03-43-11-89" & membres__id == 4
replace M5 = 2 if interview__key == "77-34-19-60" & membres__id == 1
replace M5 = 2 if interview__key == "45-89-81-02" & membres__id == 5
replace M5 = 2 if interview__key == "48-34-40-94" & membres__id == 3
replace M5 = 2 if interview__key == "37-63-94-20" & membres__id == 3
replace M5 = 2 if interview__key == "37-29-31-40" & membres__id == 3
replace M5 = 2 if interview__key == "03-25-25-28" & membres__id == 3
replace M5 = 2 if interview__key == "45-97-90-23" & membres__id == 5
replace M5 = 2 if interview__key == "62-23-58-88" & membres__id == 3
replace M5 = 2 if interview__key == "33-76-33-76" & membres__id == 3
replace M5 = 2 if interview__key == "33-76-33-76" & membres__id == 7
replace M5 = 2 if interview__key == "52-40-03-42" & membres__id == 10
replace M5 = 2 if interview__key == "08-73-95-53" & membres__id == 5
replace M5 = 2 if interview__key == "22-47-03-02" & membres__id == 2
replace M5 = 2 if interview__key == "92-87-39-91" & membres__id == 6
replace M5 = 2 if interview__key == "22-12-99-71" & membres__id == 4
replace M5 = 2 if interview__key == "35-10-69-75" & membres__id == 1
replace M5 = 2 if interview__key == "13-62-36-04" & membres__id == 1
replace M5 = 2 if interview__key == "23-27-09-80" & membres__id == 1
replace M5 = 2 if interview__key == "68-91-85-38" & membres__id == 3
replace M5 = 2 if interview__key == "37-21-09-56" & membres__id == 4
replace M5 = 2 if interview__key == "76-87-98-86" & membres__id == 6
replace M5 = 2 if interview__key == "66-04-82-34" & membres__id == 2
replace M5 = 2 if interview__key == "15-73-84-94" & membres__id == 3
replace M5 = 2 if interview__key == "21-53-41-39" & membres__id == 3
replace M5 = 2 if interview__key == "14-92-12-81" & membres__id == 3
replace M5 = 2 if interview__key == "52-72-04-00" & membres__id == 4
replace M5 = 2 if interview__key == "52-72-04-00" & membres__id == 6
replace M5 = 2 if interview__key == "44-74-20-23" & membres__id == 7
replace M5 = 2 if interview__key == "44-74-20-23" & membres__id == 10
replace M5 = 2 if interview__key == "72-00-66-49" & membres__id == 3
replace M5 = 2 if interview__key == "26-78-98-10" & membres__id == 7
replace M5 = 2 if interview__key == "50-86-51-78" & membres__id == 5
replace M5 = 2 if interview__key == "50-86-51-78" & membres__id == 11
replace M5 = 2 if interview__key == "54-83-28-12" & membres__id == 5
replace M5 = 2 if interview__key == "57-19-22-14" & membres__id == 3
replace M5 = 2 if interview__key == "86-68-71-02" & membres__id == 6
replace M5 = 2 if interview__key == "43-79-28-35" & membres__id == 3
replace M5 = 2 if interview__key == "70-72-22-42" & membres__id == 5
replace M5 = 2 if interview__key == "09-08-92-29" & membres__id == 3
replace M5 = 2 if interview__key == "18-26-28-08" & membres__id == 5
replace M5 = 2 if interview__key == "05-99-01-21" & membres__id == 3
replace M5 = 2 if interview__key == "48-45-72-24" & membres__id == 10
replace M5 = 2 if interview__key == "76-98-92-89" & membres__id == 6
replace M5 = 2 if interview__key == "76-98-92-89" & membres__id == 7
replace M5 = 2 if interview__key == "76-98-92-89" & membres__id == 11
replace M5 = 2 if interview__key == "61-49-67-22" & membres__id == 3
replace M5 = 2 if interview__key == "46-85-13-20" & membres__id == 4
replace M5 = 2 if interview__key == "82-57-85-07" & membres__id == 4
replace M5 = 2 if interview__key == "82-57-85-07" & membres__id == 5
replace M5 = 2 if interview__key == "20-23-66-44" & membres__id == 1
replace M5 = 2 if interview__key == "69-75-21-70" & membres__id == 1
replace M5 = 2 if interview__key == "69-75-21-70" & membres__id == 2
replace M5 = 2 if interview__key == "43-17-53-79" & membres__id == 3
replace M5 = 2 if interview__key == "05-69-93-97" & membres__id == 3
replace M5 = 2 if interview__key == "71-19-14-15" & membres__id == 6
replace M5 = 2 if interview__key == "26-09-99-45" & membres__id == 1
replace M5 = 2 if interview__key == "47-96-99-10" & membres__id == 4
replace M5 = 2 if interview__key == "39-71-94-40" & membres__id == 4
replace M5 = 2 if interview__key == "45-29-06-67" & membres__id == 4
replace M5 = 2 if interview__key == "88-77-31-70" & membres__id == 6
replace M5 = 2 if interview__key == "96-39-28-63" & membres__id == 4
replace M5 = 2 if interview__key == "00-45-17-85" & membres__id == 1
replace M5 = 2 if interview__key == "08-74-42-11" & membres__id == 5
replace M5 = 2 if interview__key == "08-74-42-11" & membres__id == 9
replace M5 = 2 if interview__key == "35-58-71-93" & membres__id == 3






count if !missing(M5) & Statut_Res== 0 // tous ceux qui ont repondu à la question M5 n'y avait pas le droit


*replace commentaire="tous ceux qui ont repondu à la question M5 n'y avait pas le droit car l'individu n'est pas resident" if !missing(M5) & Statut_Res== 0

*export excel interview__key HH2 HH12 HH13 M6_J membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_M5_nonresident" if !missing(M5) & Statut_Res== 0 , firstrow(varl) replace


**Pas de personnes pour qui la données sur le sexe est manquante

*drop if missing(M5) & Statut_Res==1 

// M6_J . Veuillez saisir le jour de naissance de %rostertitle% ?

count if missing(M6_J) & Statut_Res==1 // 6 personnes pour qui on a pas le  jour de naissance

replace commentaire="personnes pour qui on a pas le  jour de naissance" if missing(M6_J) & Statut_Res==1

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M6_J membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_jour_naiss" if missing(M6_J) & Statut_Res==1 , firstrow(varl) replace
**

count if !missing(M6_J) & Statut_Res== 0 // tous ceux qui ont repondu à la question y avait le droit

// M6_M. Mois de naissance de %rostertitle% ?

count if missing(M6_M) & Statut_Res==1 // 6 personnes pour qui on a pas le mois de naissance

replace commentaire="personnes pour qui on a pas le mois de naissance" if missing(M6_M) & Statut_Res==1

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M6_M membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_mois_naiss" if missing(M6_M) & Statut_Res==1 , firstrow(varl) replace
**

count if !missing(M6_M) & Statut_Res== 0 // tous ceux qui ont repondu à la question y avait le droit

// M6_A. Quelle est l'année de naissance de %rostertitle% ?

count if missing(M6_A) & Statut_Res==1 // 3 personnes pour qui on a pas l'année de naissance

replace commentaire="personnes pour qui on a pas l'année de naissance" if missing(M6_A) & Statut_Res==1


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M6_A membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_annee_naiss" if missing(M6_A) & Statut_Res==1 , firstrow(varl) replace



count if missing(M6_A) & Statut_Res==1 & membre_id_v1!="##N/A##" // 3 personnes pour qui on a pas l'année de naissance


count if !missing(M6_A) & Statut_Res== 0 // tous ceux qui ont repondu à la question y avait le droit

ta M6_A if Statut_Res==1


ta AgeAnnee if Statut_Res==1

* On constate qu'il a une valeur aberante qui vaut 112 pour interview__key =="39-95-24-84" & membres__id==1

cap drop zen
gen zen = 1993 if interview__key=="39-95-24-84" & membres__id==1 

replace AgeAnnee=2026 -zen if interview__key=="39-95-24-84" & membres__id==1
replace M6_A = zen if  interview__key=="39-95-24-84" & membres__id==1
replace M7 = 2026 -zen if  interview__key=="39-95-24-84" & membres__id==1

cap drop zen


replace M6_A=2025 if interview__key=="49-94-67-76" & membres__id == 3

replace AgeAnnee=2026 - M6_A if interview__key=="49-94-67-76" & membres__id == 3






* On constate qu'il a des valeurs aberantes sur la variable AgeAnnee


//M7. Quel âge avait %rostertitle% à son dernier anniversaire?

count if missing(M7) & M6_A==9998 // 8 personnes pour qui on a pas l'age de naissance

br interview__key membres__id M6_A M7 AgeAnnee M4Confirm  if missing(M7) & M6_A==9998




count if missing(M7) & M6_A==.a // 3 personnes pour qui on a pas l'age et l'année de naissance sont non renseignées

count if missing(M7) & M6_A==9998 // 8 personnes pour qui on a pas l'age et l'année de naissance sont non renseignées


count if AgeAnnee==.a & Statut_Res==1 // 2 personnes pour qui on a pas l'age et l'année de naissance sont non renseignées : Tous des téléopérateurs

br interview__key membres__id M6_A M7 AgeAnnee M4Confirm  if AgeAnnee==.a & Statut_Res==1



br interview__key membres__id M6_A M7 AgeAnnee M4Confirm  rgmen if AgeAnnee==.a & Statut_Res==1

ta HH2 if AgeAnnee==.a & Statut_Res==1

replace commentaire="personnes pour qui on a pas l'age de naissance" if AgeAnnee==.a & Statut_Res==1

replace commentaire="(53) personnes pour qui on a pas l'age et l'année de naissance sont non renseignées : Tous des téléopérateurs" if AgeAnnee==.a & Statut_Res==1


**Exportation des individus potentiellement concernés

export excel interview__key HH13 M6_A M7 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/Sans_Age" if AgeAnnee==.a & Statut_Res==1, firstrow(varl) replace

*export excel interview__key HH13 M6_A M7 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/Sans_Age_AGterrain_" if AgeAnnee==.a & Statut_Res==1 & rgmen==1, firstrow(varl) replace

export excel interview__key HH13 M6_A M7 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/Sans_Age_AGteleoperateur" if AgeAnnee==.a & Statut_Res==1 & rgmen==2, firstrow(varl) replace

/*
interview__key	membres__id


*/
**

count if !missing(M7) & M6_A !=9998 // tous ceux qui ont repondu à la question y avait le droit


// AgeAnnee

count if missing(AgeAnnee) & Statut_Res == 1 // 2  personnes pour qui l'age est manquant

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M6_A M6_J M6_M M7 AgeAnnee M5 membre_id_v1 V1MODINTR rgmen using "$folderpath/document/comp_menage_AgeAnnee" if missing(AgeAnnee) & Statut_Res == 1, firstrow(varl) replace
**

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if AgeAnnee==.a & Statut_Res==1 & rgmen==2

*******************************************


*suppression des individus pour qui l'age est manquant

*drop if AgeAnnee ==.a
*

*count if !missing(AgeAnnee) & Statut_Res !=1 // tous ceux qui ont repondu à la section avait le droit 

ta AgeAnnee if Statut_Res==1,miss // plusieurs valeurs aberrantes dans la variable AgeAnnee. 

*br interview__key  membres__id M6_A M6_J M6_M M7 AgeAnnee M4Confirm if AgeAnnee >99 & !missing(AgeAnnee)

*br interview__key  membres__id M6_A M6_J M6_M M7 AgeAnnee M4Confirm if AgeAnnee <0

replace AgeAnnee=0 if AgeAnnee <0

**Proposition de Correction des valeurs aberrantes dans AgeAnnee

*L'information de l'année de naissance a été reporté dans la variable Age (M7).
count if AgeAnnee >1000 & !missing(AgeAnnee)

*replace M6_A=M7 if AgeAnnee >1000 & !missing(AgeAnnee)
*replace AgeAnnee= 2015 - M6_A if inlist(M7,2004,2009,1995)
*replace M7 =. if inlist(M7,2004,2009,1995)


**

count if M4 ==1 & AgeAnnee < 15  // 1 chef  chef de menage agé de moins de 15. Mais il s'agit d'un menage où il est le seul membre

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

count if ecart_age1 < 11 & M4 == 5 // pas de CM dont le parent en est agé de moins de 11
count if ((ecart_age < 11 & M4 == 3 & M5 ==2) | (ecart_age < 14 & M4 == 3 & M5 ==1)) & agecm !=. // pas CM agé de moins 11/14 par rapport à son fils/filles

count if AgeAnnee != M4Confirm // M4Confirm est l'age confirmé au moment de l'entretien, c'est donc la vrai valeurs de l'age. la variable AgeAnnee et M4Confirm sont différentes pour 50% des individu. 


// M8. Est-ce que la mère biologique de %rostertitle% est encore en vie ? 

count if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))) // 3 individus pour qui la question n'a pas été repondu

*replace commentaire="individus pour qui la question M8 n'a pas été repondu" if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))

**Exportation des individus potentiellement concernés

*export excel interview__key HH13 M8 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_mere_en_vie" if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))), firstrow(varl) replace
**


count if !missing(M8) & Statut_Res==0 

count if !missing(M8) & membre_id_v1 != "##N/A##" 

count if !missing(M8) & AgeAnnee > 18  

count if !missing(M8) & AgeAnnee < 18 & !inlist(M4,3,4,7,8) & !inlist(V1M4,3,4,7,8) // tous les individus ayant répondu à la question y avait droit



// M9. La mère biologique de %rostertitle% vit-elle habituellement dans ce ménage ou était-elle en visite ici la nuit dernière ?

count if missing(M9) & M8==1 // les individus devant repondre à la question on bien repondu 

count if !missing(M9) & (M8==2 | M8==9998)  // les individus ayant repondu à la question y avait droit

ta M8 M9 // pas d'incoherence entre le fait que la mère soit vivante et qu'elle vive dans le menage


// M10.Qui est la mère biologique de %rostertitle% ?

count if missing(M10) & M9 == 1 & membre_id_v1=="##N/A##" // 4 personnes pour qui la question n'a pas été repondu (1er passage) Ceci n'est pas imputable  

replace commentaire="personnes pour qui la question M10 n'a pas été repondu" if missing(M10) & M9 == 1 & membre_id_v1=="##N/A##"

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M10 M9 membre_id_v1 V1MODINTR rgmen using "$folderpath/document/comp_menage_mere_qui" if missing(M10) & M9 == 1 & membre_id_v1=="##N/A##", firstrow(varl) replace
**

count if !missing(M10) & M9 == 2 // Tous les individu ayant repondy y avait droit

// M11.Est-ce que le père biologique de %rostertitle% est encore en vie ?

count if missing(M11) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))) // tous ceux qui devaient repondre ont repondu à la question n'a pas été repondu

/*Exportation des individus potentiellement concernés

export excel interview__key HH13 M8 membre_id_v1 V1MODINTR using "$folderpath/document/comp_menage_mere_en_vie" if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))), firstrow(varl) replace
*/


count if !missing(M11) & Statut_Res==0 

count if !missing(M11) & membre_id_v1 != "##N/A##" 

count if !missing(M11) & AgeAnnee > 18  

count if !missing(M11) & AgeAnnee < 18 & !inlist(M4,3,4,7,8) & !inlist(V1M4,3,4,7,8) // tous les individus ayant répondu à la question y avait droit


// M12. Le père biologique de %rostertitle% vit-il habituellement dans ce ménage ou était en visite ici la nuit dernière?

count if missing(M12) & M11==1 & membre_id_v1 == "##N/A##" // 1 individu devant repondre ne l'ont pas fait. 

count if !missing(M12) & (M11==2 | M11==9998)  // les individus ayant repondu à la question y avait droit. Ne peut être imputés

ta M11 M12 // pas d'incoherence entre le fait que 

// M13.Qui est le père biologique de %rostertitle% ?

count if missing(M13) & M12 == 1 & membre_id_v1 == "##N/A##" // 1 personnes pour qui la question n'a pas été repondu. Ne peut être imputés

replace commentaire ="personnes pour qui la question n'a pas été repondu M13" if missing(M13) & M12 == 1 & membre_id_v1 == "##N/A##"
**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M12 M13 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_pere_qui" if missing(M13) & M12 == 1 & membre_id_v1 == "##N/A##", firstrow(varl) replace
**

// M14.Qui a la charge de %rostertitle% dans le ménage ?

count if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))) // 1 individus pour qui la question n'a pas été répondu.  Ne peut être imputés

replace commentaire="individus pour qui la question M14  n'a pas été répondu" if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M14 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_charge_qui" if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))), firstrow(varl) replace
**

// M15. %rostertitle% est-il né en Côte d'Ivoire ?

count if missing(M15) & Statut_Res==1 & membre_id_v1=="##N/A##" // 11 personnes pour qui la question n'a pas été répondu.  Ne peut être imputés

count if !missing(M15) & membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit

// M16. Quelle est la sous-préfecture ou la commune du lieu de naissance de %rostertitle% ?

count if missing(M16) & M15==1 & membre_id_v1 == "##N/A##" // 2 individu pour qui la question n'a pas été répondu. Ne peux être imputés 

replace commentaire="individu pour qui la question M16 n'a pas été répondu " if missing(M16) & M15==1 & membre_id_v1 == "##N/A##"

export excel interview__key HH2 HH12  HH13 M14 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/sous_prefecture_maissan" if missing(M16) & M15==1 & membre_id_v1 == "##N/A##" , firstrow(varl) replace



count if !missing(M16) & M15 ==2 // tous ceux qui ont repondu avaient le droit

// M18. Précisez le pays de naissance de %rostertitle%

count if missing(M18) & M15==2 // Tous ceux qui devaient repondre on répondu


count if !missing(M18) & M15==1 // tous ceux qui ont repondu avaient le droit

ta M18,miss // les pays mentionné sont vraisembable. Ce sont pour la plupart des pays ayant une forte diaspora en CIV 

// M19. Quelle est la nationalité de %rostertitle% ??

count if missing(M19) & Statut_Res==1 & membre_id_v1=="##N/A##" // 1 individu pour qui la question n'a pas de réponse. Ne peut être imputés

replace commentaire="individu pour qui la question M19 n'a pas de réponse " if missing(M19) & Statut_Res==1 & membre_id_v1=="##N/A##"

export excel interview__key HH2 HH12 HH13 M14 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/nationalite" if missing(M19) & Statut_Res==1 & membre_id_v1=="##N/A##" , firstrow(varl) replace

count if !missing(M19) &  membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit

// M20. Indiquez le pays dont %rostertitle% a la nationalité .

count if missing(M20) & M19 == 2 // tous les individus devant repondre ont répondu


count if !missing(M20) &  M19 == 1 // tous ceux qui ont repondu avaient le droit

ta M20,miss // les pays mentionné sont vraisembable. Ce sont pour la plupart des pays ayant une forte diaspora en CIV 

// M21. Quelle est l'ethnie de %rostertitle% ?

count if missing(M21) & M19== 1 & membre_id_v1 == "##N/A##" // 9 individu pour qui la question n'a pas été répondu. Ne peux être imputés

replace commentaire="individu pour qui la question M21 (ethnie) n'a pas de réponse " if missing(M21) & M19== 1


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M19 M21 membre_id_v1 V1MODINTR commentaire rgmen  using "$folderpath/document/comp_menage_charge_qui" if missing(M21) & M19==1 , firstrow(varl) replace
**

count if !missing(M21) & M19== 2 // tous les individus devant répondre ont répondu


// M22. Quelle est la réligion de %rostertitle% ?

count if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##" // 1 individus pour qui la question n'a pas de réponse

replace commentaire="individu pour qui la question M22 n'a pas de réponse " if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##"


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M19 M21 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_charge_qui" if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##" , firstrow(varl) replace




count if !missing(M22) &  membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit


// M22_Aut. Veuillez préciser ?

count if missing(M22_Aut) & M22 == 13 // 3  individus devant repondre main n'ont pas répondu


count if !missing(M22_Aut) &  M22 != 13 //RAS

br M22_Aut M22 if !missing(M22_Aut) &  M22 != 13 

// M23A. Quel est le statut matrimonial de %rostertitle% ?

count if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##" // 1 individu pour qui la question n'a pas été repondu. NE peux être imputes

replace commentaire="individu pour qui la question M23A(statut matrimonial) n'a pas de réponse " if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##" 


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M19 M21 membre_id_v1 V1MODINTR rgmen commentaire using "$folderpath/document/stattut_matrimonial"  if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##"  , firstrow(varl) replace


count if !missing(M23A) & (AgeAnnee < 12 | Statut_Res==0 | membre_id_v1 != "##N/A##") // Tous les individus ayant répondu avaient le droit 

count if (AgeAnnee < 16 & M23A > 1 & !missing(M23A)) // 14 individu agés de moins de 15 et ne sont pas celibataire.

replace commentaire=" individu agés de moins de 13 ans et ne sont pas celibataire." if (AgeAnnee < 16 & M23A > 1 & !missing(M23A))


**Exportation des individus potentiellement concernés

export excel interview__key HH13 M19 M21 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/stattut_matrimonial_pour_jeune" if (AgeAnnee < 16 & M23A > 1 & !missing(M23A))  , firstrow(varl) replace

*Etape imputation
*replace M23A=1 if (AgeAnnee < 16 & M23A > 1 & !missing(M23A))



// M23B. Quel est le type de mariage de %rostertitle% ?



foreach var in M23B__1 M23B__2 M23B__3 M23B__9998 {
count if missing(`var') & inlist(M23A,3,4)
} // tous les individus ont répondus


* 12 les personnes Mariés (Polygame) qui sont mariés légalement : Incoherence
count if M23A == 4 & M23B__1 == 1 // Les 5 personnes 


// M24A. %rostertitle% a-t-il/elle une assurance maladie ?

count if missing(M24A) & Statut_Res==1 & membre_id_v1=="##N/A##" // 1 individus pour qui la question n'a pas de réponse

br M5 AgeAnnee M19 M23B__1 M23B__2 M23B__3 M23B__9998 M24A if missing(M24A) & Statut_Res==1 & membre_id_v1=="##N/A##" // il s'agirait du meme individu que pour les variables précédente. Nous pensons judicieux de ne pas le supprimer vu que l'age et le sexe sont non manquant

count if !missing(M24A) &  membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit

// M24B. Si oui, qui a souscrit à l'assurance ?

count if missing(M24B) & M24A==1 &  membre_id_v1 == "##N/A##" // Tous les individus devant répondre ont répondu

count if !missing(M24B) & M24A==2  // Tous les individus devant répondre ont répondu

count if M24B==1 & AgeAnnee <14 // 456 enfants de moins de 14 ont une assurance personnelle. Nous estimons que cela est une erreur. IL SE POURRAIT QUE LES AGENTS N'AIT PAS BIEN COMPRIS LE SENS DE LA QUESTION A CE NIVEAU 

replace commentaire="enfants de moins de 13 ont une assurance personnelle " if M24B==1 & AgeAnnee <14 


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M19 M21 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/assurance_maladie"  if M24B==1 & AgeAnnee <14  , firstrow(varl) replace

*Etape de correction 
replace M24B=3 if M24B==1 & AgeAnnee <14


count if M24B== 2  & M23A == 1 // 5 personnes declarent avoir l'assurance des conjoints alors qu'elles sont déclaré célibataire.

replace commentaire="personnes declarent avoir l'assurance des conjoints alors qu'elles sont déclaré célibataire. " if M24B== 2  & M23A == 1

replace M24B=1 if M24B== 2  & M23A == 1 // 1 personnes declarent avoir l'assurance des conjoints alors qu'elles sont déclaré célibataire.


**Exportation des individus potentiellement concernés

*export excel interview__key HH13 M19 M21 membre_id_v1 V1MODINTR commentaire using "$folderpath/document/assurance_maladie2"  if M24B== 2  & M23A == 1  , firstrow(varl) replace

*Etape correction
*replace M24B=1 if M24B== 2  & M23A == 1 



// M24C. Si oui, Quelles sont les couvertures dont %rostertitle% bénéficie ?

foreach var in M24C__1 M24C__2 M24C__3 M24C__4 M24C__7 M24C__8 {
count if missing(`var') & inlist(M24A,1)
} // RAS

foreach var in M24C__1 M24C__2 M24C__3 M24C__4 M24C__7 M24C__8 {
count if !missing(`var') & !inlist(M24A,1)
} //RAS. 

count if M24C__1 == 1 & (M24B==2 | M24B == 3 ) // 1512 personnes ayant répondu possédér la CMU et que cette CMU était l'assurance des parents ou l'assurance du conjoint. Ce qui est une grosse incoherence



*br M24C__1 M24B if M24C__1 == 1 & (M24B==2 | M24B == 3 )

replace commentaire="personnes ayant répondu possédér la CMU et que cette CMU était l'assurance des parents ou l'assurance du conjoint." if M24C__1 == 1 & (M24B==2 | M24B == 3 )
**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M24C__1 M24B membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_assurance_CMU" if M24C__1 == 1 & (M24B==2 | M24B == 3 ) , firstrow(varl) replace
**

***etape de correction 

replace M24B = 3 if M24C__1 == 1 & M24C__2==0 & M24C__3==0 & M24C__4==0 & M24C__7==0  & AgeAnnee<=16 // nous considerons que toutes les personnes agé de moins de 16 ans ayant une CMU sont sous assurance parent 



// M24B_Aut. Veuillez préciser l'autre Couverture en Assurance maladie ?

count if missing(M24B_Aut) & M24C__7 == 7 // tous les individus devant répondre ont répondus

count if !missing(M24B_Aut) & M24C__7 != 1 // les individus ayant répondu avait le droit de répondre. 

ta M24B_Aut, miss // certains agent on renseigné "Assurance Conjoint/parent" au lieu de mentionné l'assurance en question

**Exportation des individus potentiellement concernés

*export excel interview__key HH13 M24B_Aut M24C__7 membre_id_v1 V1MODINTR using "$folderpath/document/comp_menage_assurance_autre" if M24B_Aut !="" , firstrow(varl) replace
**

cap drop HH2 HH3 HH12 HH13 HH4 HH6 HH8B V1interviewkey V1MODINTR M0__0 rgmen membre_id_v1_IND M4Confirm 

cap drop dup commentaire cm agecm Age_Cm_men ecart_age ecart_age1 HH14a HH14a_Aut

save  "$standard_menage\QM_S1_composition_menage.dta", replace




**** J'AIME LA CAE :







