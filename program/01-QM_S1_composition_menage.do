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

count if missing(M1A) & membre_id_v1 !="##N/A##" // 1223 individu pour qui la question n'a pas été répondu. Il faut préciser que cette question concerne les réintérrogations, donc il s'agit potentiellement d'un problème au niveau des téléopérateurs


count if (M1A==.a) & membre_id_v1 !="##N/A##" // 1223 individu en reinterrogation non interogé (pour qui la question n'a pas été répondu). Il faut préciser que cette question concerne les réintérrogations, donc il s'agit potentiellement d'un problème au niveau des téléopérateurs. Ceux sont des menages en reinterrogations non interrogé

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

replace  commentaire="9 individus de 1ere interrogation, pour qui la question M1 n'a pas été repondu. Ces individus sont perdu pour de bon car l'âge n'est pas mentionné" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==1 

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR rgmen AgeAnnee M4Confirm commentaire using "$folderpath/document/M1_terrain_perdu_sans_age1" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==1 , firstrow(varl) replace
**

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==1

*******************************************


*********************************************************************************************************************************

count   if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2 // 31 individus de 2ieme interrogation, pour qui la question n'a pas été repondu. Ces individus sont perdu pour de bon car l'âge n'est pas mentionné

replace  commentaire="31 individus de 2eme interrogation, pour qui la question M1 n'a pas été repondu. Ces individus sont perdu pour de bon car l'âge n'est pas mentionné" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2 


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M1 membre_id_v1 V1MODINTR rgmen AgeAnnee M4Confirm commentaire rgmen using "$folderpath/document/M1_age_teleoperateur_perdu" if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2 , firstrow(varl) replace

********** SUPPRESSION DES INDIVIDUS SANS AGE ********************

*cap drop if missing(M1) & membre_id_v1 == "##N/A##" & rgmen ==2

*******************************************


count if missing(M1) & membre_id_v1 == "##N/A##" // 114 individu de 1ere et 2eme pour qui la question n'a pas été repondu. 

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

count if Statut_Res !=1 // 2908 non resident. C'est beaucoup trop, il se pourrait que les agents mettent intentionnellement

replace commentaire="individus non résident au nombre de 2908" if Statut_Res !=1


** Exportation des agents qui serait potentiellement concernés
 
export excel interview__key HH2 HH12 HH13 Statut_Res commentaire rgmen using "$folderpath/document/comp_menage_stat_res" if Statut_Res !=1, firstrow(varl) replace

*drop if Statut_Res !=1

// M3. %rostertitle% a t-il/t'elle passé la nuit dernière dans le ménage ?

count if missing(M3) & Statut_Res==1 & M5==.a // 8 individus residents pour qui la question n'a pas été repondu. Ils sont perdu car le sexe n'e'st pas renseignés 

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

count if missing(M5) & Statut_Res==1 // 40 personnes pour qui on a pas le sexe : agent teleoperateur

ta rgmen if missing(M5) & Statut_Res==1


*Nous avons retrouvée ces idividus du trimestre 3 (réinterrogation) au trimestre 2, puis nous avons fait correspondre les interview et membres__id. Dans la base du T3 il y a deux variables : membre_id_v1 V1interviewkey qui sont les interview et membres__id du ménage du T3 réintérrogé. 

replace commentaire="Les agents n'ont pas renseigné  le sexe " if missing(M5) & Statut_Res==1 



**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M5 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_sexe" if missing(M5) & Statut_Res==1 , firstrow(varl) replace
**

*Incoherence sur le sexe entre T1-2025 (terrain) et T4-2024 (teleoperateur)


****Le principe de cette correction est de faire l'hypothèse que les sexe renseigné par l'agent terrain est plus correct que celui renseigne par le teleoperateur dans la situation ou le sexe renseigner par le teleoperateur est different de celui de l'agent terrain.

replace M5 = 1 if interview__key == "90-16-61-28" & membres__id == 1
replace M5 = 2 if interview__key == "10-38-14-63" & membres__id == 4
replace M5 = 2 if interview__key == "05-48-61-32" & membres__id == 1
replace M5 = 2 if interview__key == "92-07-43-86" & membres__id == 2
replace M5 = 2 if interview__key == "06-84-60-07" & membres__id == 6
replace M5 = 1 if interview__key == "06-84-60-07" & membres__id == 9
replace M5 = 2 if interview__key == "06-84-60-07" & membres__id == 10
replace M5 = 2 if interview__key == "06-84-60-07" & membres__id == 13
replace M5 = 2 if interview__key == "06-84-60-07" & membres__id == 17
replace M5 = 2 if interview__key == "06-84-60-07" & membres__id == 21
replace M5 = 1 if interview__key == "00-83-53-93" & membres__id == 3
replace M5 = 1 if interview__key == "32-79-85-03" & membres__id == 6
replace M5 = 2 if interview__key == "62-44-98-24" & membres__id == 1
replace M5 = 2 if interview__key == "64-89-18-13" & membres__id == 3
replace M5 = 1 if interview__key == "06-96-53-61" & membres__id == 8
replace M5 = 2 if interview__key == "31-40-95-44" & membres__id == 3
replace M5 = 2 if interview__key == "39-41-21-61" & membres__id == 5
replace M5 = 1 if interview__key == "39-41-21-61" & membres__id == 6
replace M5 = 1 if interview__key == "98-30-54-11" & membres__id == 5
replace M5 = 2 if interview__key == "98-30-54-11" & membres__id == 6
replace M5 = 1 if interview__key == "98-30-54-11" & membres__id == 7
replace M5 = 2 if interview__key == "98-30-54-11" & membres__id == 8
replace M5 = 1 if interview__key == "98-30-54-11" & membres__id == 9
replace M5 = 2 if interview__key == "98-30-54-11" & membres__id == 11
replace M5 = 1 if interview__key == "98-30-54-11" & membres__id == 14
replace M5 = 1 if interview__key == "98-30-54-11" & membres__id == 15
replace M5 = 2 if interview__key == "98-30-54-11" & membres__id == 16
replace M5 = 1 if interview__key == "98-30-54-11" & membres__id == 18
replace M5 = 2 if interview__key == "86-97-64-77" & membres__id == 4
replace M5 = 1 if interview__key == "51-23-91-86" & membres__id == 5
replace M5 = 1 if interview__key == "99-48-58-36" & membres__id == 3
replace M5 = 2 if interview__key == "99-48-58-36" & membres__id == 6
replace M5 = 2 if interview__key == "18-19-18-40" & membres__id == 4
replace M5 = 2 if interview__key == "76-70-20-01" & membres__id == 3
replace M5 = 1 if interview__key == "76-70-20-01" & membres__id == 4
replace M5 = 2 if interview__key == "99-72-70-54" & membres__id == 5
replace M5 = 2 if interview__key == "74-72-98-32" & membres__id == 6
replace M5 = 1 if interview__key == "44-35-01-08" & membres__id == 4
replace M5 = 2 if interview__key == "44-35-01-08" & membres__id == 6
replace M5 = 2 if interview__key == "30-95-47-87" & membres__id == 3
replace M5 = 2 if interview__key == "89-49-43-00" & membres__id == 3
replace M5 = 1 if interview__key == "89-09-41-33" & membres__id == 7
replace M5 = 1 if interview__key == "72-19-74-12" & membres__id == 3
replace M5 = 2 if interview__key == "42-40-90-67" & membres__id == 4
replace M5 = 2 if interview__key == "10-78-56-90" & membres__id == 3
replace M5 = 1 if interview__key == "75-92-62-63" & membres__id == 3
replace M5 = 2 if interview__key == "75-92-62-63" & membres__id == 10
replace M5 = 1 if interview__key == "93-04-15-01" & membres__id == 6
replace M5 = 2 if interview__key == "22-80-50-86" & membres__id == 5
replace M5 = 2 if interview__key == "32-04-17-74" & membres__id == 4
replace M5 = 2 if interview__key == "79-59-67-71" & membres__id == 5
replace M5 = 2 if interview__key == "47-59-22-35" & membres__id == 3
replace M5 = 2 if interview__key == "47-96-40-81" & membres__id == 7
replace M5 = 2 if interview__key == "97-38-69-75" & membres__id == 15
replace M5 = 1 if interview__key == "26-39-27-89" & membres__id == 5
replace M5 = 1 if interview__key == "01-86-01-87" & membres__id == 8
replace M5 = 1 if interview__key == "98-38-04-03" & membres__id == 5
replace M5 = 2 if interview__key == "98-38-04-03" & membres__id == 6
replace M5 = 1 if interview__key == "60-07-65-03" & membres__id == 5
replace M5 = 1 if interview__key == "58-69-23-37" & membres__id == 5
replace M5 = 1 if interview__key == "74-10-51-35" & membres__id == 3
replace M5 = 1 if interview__key == "47-61-69-46" & membres__id == 2
replace M5 = 2 if interview__key == "49-36-75-45" & membres__id == 5
replace M5 = 1 if interview__key == "54-03-21-39" & membres__id == 1
replace M5 = 1 if interview__key == "81-03-08-54" & membres__id == 7
replace M5 = 1 if interview__key == "61-14-59-20" & membres__id == 7
replace M5 = 1 if interview__key == "39-40-26-09" & membres__id == 7
replace M5 = 2 if interview__key == "39-40-26-09" & membres__id == 9
replace M5 = 2 if interview__key == "57-78-17-43" & membres__id == 3
replace M5 = 2 if interview__key == "60-11-61-70" & membres__id == 3
replace M5 = 2 if interview__key == "60-11-61-70" & membres__id == 8
replace M5 = 2 if interview__key == "55-48-68-79" & membres__id == 4
replace M5 = 2 if interview__key == "35-73-35-53" & membres__id == 4
replace M5 = 1 if interview__key == "41-81-99-07" & membres__id == 3
replace M5 = 2 if interview__key == "70-91-46-99" & membres__id == 3
replace M5 = 1 if interview__key == "61-26-62-33" & membres__id == 5
replace M5 = 2 if interview__key == "61-26-62-33" & membres__id == 6
replace M5 = 1 if interview__key == "61-26-62-33" & membres__id == 7
replace M5 = 1 if interview__key == "80-39-54-25" & membres__id == 4
replace M5 = 2 if interview__key == "83-22-77-52" & membres__id == 1
replace M5 = 2 if interview__key == "96-99-86-12" & membres__id == 3
replace M5 = 2 if interview__key == "00-82-34-22" & membres__id == 5
replace M5 = 1 if interview__key == "20-36-53-59" & membres__id == 4
replace M5 = 2 if interview__key == "20-36-53-59" & membres__id == 5
replace M5 = 1 if interview__key == "20-36-53-59" & membres__id == 6
replace M5 = 2 if interview__key == "92-36-41-85" & membres__id == 6
replace M5 = 1 if interview__key == "29-47-30-60" & membres__id == 3
replace M5 = 2 if interview__key == "06-65-21-99" & membres__id == 4
replace M5 = 2 if interview__key == "59-44-69-62" & membres__id == 2
replace M5 = 2 if interview__key == "51-04-51-27" & membres__id == 8
replace M5 = 1 if interview__key == "38-67-34-86" & membres__id == 5
replace M5 = 2 if interview__key == "50-57-73-28" & membres__id == 4
replace M5 = 2 if interview__key == "49-70-92-67" & membres__id == 3
replace M5 = 2 if interview__key == "70-64-05-05" & membres__id == 4
replace M5 = 2 if interview__key == "33-29-23-33" & membres__id == 4
replace M5 = 1 if interview__key == "33-29-23-33" & membres__id == 7
replace M5 = 2 if interview__key == "33-29-23-33" & membres__id == 8
replace M5 = 1 if interview__key == "33-29-23-33" & membres__id == 10
replace M5 = 2 if interview__key == "33-29-23-33" & membres__id == 13
replace M5 = 1 if interview__key == "28-84-63-56" & membres__id == 3
replace M5 = 2 if interview__key == "26-82-11-37" & membres__id == 7
replace M5 = 1 if interview__key == "26-82-11-37" & membres__id == 8
replace M5 = 2 if interview__key == "26-82-11-37" & membres__id == 9
replace M5 = 2 if interview__key == "43-53-26-72" & membres__id == 1
replace M5 = 2 if interview__key == "60-25-05-52" & membres__id == 4
replace M5 = 2 if interview__key == "36-61-42-36" & membres__id == 4
replace M5 = 1 if interview__key == "36-61-42-36" & membres__id == 6
replace M5 = 2 if interview__key == "32-06-11-89" & membres__id == 5
replace M5 = 2 if interview__key == "14-30-50-04" & membres__id == 1
replace M5 = 2 if interview__key == "14-30-50-04" & membres__id == 2
replace M5 = 2 if interview__key == "36-44-18-45" & membres__id == 6
replace M5 = 1 if interview__key == "48-50-26-48" & membres__id == 6
replace M5 = 2 if interview__key == "15-07-06-26" & membres__id == 7
replace M5 = 1 if interview__key == "15-07-06-26" & membres__id == 10
replace M5 = 2 if interview__key == "15-07-06-26" & membres__id == 11
replace M5 = 1 if interview__key == "15-07-06-26" & membres__id == 15
replace M5 = 1 if interview__key == "19-09-79-54" & membres__id == 4
replace M5 = 1 if interview__key == "19-09-79-54" & membres__id == 6
replace M5 = 1 if interview__key == "09-50-37-53" & membres__id == 1
replace M5 = 1 if interview__key == "82-55-79-34" & membres__id == 3
replace M5 = 2 if interview__key == "74-90-31-37" & membres__id == 3
replace M5 = 2 if interview__key == "97-82-69-88" & membres__id == 5
replace M5 = 2 if interview__key == "26-23-82-61" & membres__id == 4
replace M5 = 2 if interview__key == "73-69-41-62" & membres__id == 6
replace M5 = 1 if interview__key == "73-69-41-62" & membres__id == 11
replace M5 = 2 if interview__key == "25-32-52-98" & membres__id == 4
replace M5 = 2 if interview__key == "11-77-83-10" & membres__id == 11
replace M5 = 2 if interview__key == "57-69-05-34" & membres__id == 10
replace M5 = 2 if interview__key == "54-71-73-10" & membres__id == 1
replace M5 = 1 if interview__key == "56-73-01-79" & membres__id == 3
replace M5 = 2 if interview__key == "56-73-01-79" & membres__id == 5
replace M5 = 1 if interview__key == "70-97-85-38" & membres__id == 3
replace M5 = 1 if interview__key == "87-78-16-88" & membres__id == 1
replace M5 = 2 if interview__key == "81-77-61-34" & membres__id == 6
replace M5 = 2 if interview__key == "92-71-96-69" & membres__id == 3
replace M5 = 1 if interview__key == "92-71-96-69" & membres__id == 4
replace M5 = 2 if interview__key == "73-46-91-31" & membres__id == 2
replace M5 = 1 if interview__key == "73-46-91-31" & membres__id == 3
replace M5 = 2 if interview__key == "73-46-91-31" & membres__id == 5
replace M5 = 2 if interview__key == "48-94-15-24" & membres__id == 3
replace M5 = 2 if interview__key == "83-53-55-79" & membres__id == 4
replace M5 = 2 if interview__key == "54-35-28-14" & membres__id == 8
replace M5 = 1 if interview__key == "54-35-28-14" & membres__id == 10
replace M5 = 1 if interview__key == "29-65-56-73" & membres__id == 5
replace M5 = 2 if interview__key == "25-06-09-68" & membres__id == 4
replace M5 = 2 if interview__key == "36-78-08-53" & membres__id == 7
replace M5 = 1 if interview__key == "36-78-08-53" & membres__id == 8
replace M5 = 2 if interview__key == "36-78-08-53" & membres__id == 13
replace M5 = 2 if interview__key == "90-82-23-26" & membres__id == 4
replace M5 = 1 if interview__key == "90-82-23-26" & membres__id == 5
replace M5 = 2 if interview__key == "11-66-86-83" & membres__id == 2
replace M5 = 2 if interview__key == "82-10-31-06" & membres__id == 4
replace M5 = 2 if interview__key == "89-31-05-24" & membres__id == 4
replace M5 = 1 if interview__key == "38-41-35-18" & membres__id == 3
replace M5 = 1 if interview__key == "38-41-35-18" & membres__id == 8
replace M5 = 1 if interview__key == "52-94-37-70" & membres__id == 2
replace M5 = 2 if interview__key == "95-12-75-85" & membres__id == 5
replace M5 = 1 if interview__key == "88-05-32-28" & membres__id == 3
replace M5 = 2 if interview__key == "00-85-06-04" & membres__id == 3
replace M5 = 1 if interview__key == "96-06-30-17" & membres__id == 6
replace M5 = 1 if interview__key == "95-39-01-41" & membres__id == 1
replace M5 = 1 if interview__key == "95-42-28-20" & membres__id == 4
replace M5 = 2 if interview__key == "05-37-10-09" & membres__id == 3
replace M5 = 1 if interview__key == "03-17-33-56" & membres__id == 5
replace M5 = 1 if interview__key == "05-60-50-87" & membres__id == 7
replace M5 = 1 if interview__key == "79-54-33-90" & membres__id == 8
replace M5 = 2 if interview__key == "22-78-10-95" & membres__id == 16
replace M5 = 1 if interview__key == "55-88-61-08" & membres__id == 8
replace M5 = 1 if interview__key == "20-01-01-89" & membres__id == 5
replace M5 = 2 if interview__key == "30-77-31-88" & membres__id == 4
replace M5 = 2 if interview__key == "65-52-29-28" & membres__id == 3
replace M5 = 2 if interview__key == "18-23-07-14" & membres__id == 3
replace M5 = 2 if interview__key == "28-84-96-48" & membres__id == 9
replace M5 = 2 if interview__key == "85-32-60-26" & membres__id == 4
replace M5 = 2 if interview__key == "13-73-88-20" & membres__id == 6
replace M5 = 1 if interview__key == "60-40-23-86" & membres__id == 2
replace M5 = 1 if interview__key == "60-40-23-86" & membres__id == 3
replace M5 = 2 if interview__key == "48-55-38-94" & membres__id == 3
replace M5 = 1 if interview__key == "79-78-64-33" & membres__id == 9
replace M5 = 1 if interview__key == "97-95-31-23" & membres__id == 3
replace M5 = 1 if interview__key == "72-20-36-27" & membres__id == 3
replace M5 = 1 if interview__key == "63-47-97-55" & membres__id == 6
replace M5 = 2 if interview__key == "08-34-56-64" & membres__id == 5
replace M5 = 1 if interview__key == "08-34-56-64" & membres__id == 6
replace M5 = 1 if interview__key == "08-34-56-64" & membres__id == 9
replace M5 = 2 if interview__key == "08-34-56-64" & membres__id == 10
replace M5 = 1 if interview__key == "34-86-18-90" & membres__id == 2
replace M5 = 2 if interview__key == "34-86-18-90" & membres__id == 6
replace M5 = 1 if interview__key == "34-86-18-90" & membres__id == 9
replace M5 = 2 if interview__key == "34-86-18-90" & membres__id == 10
replace M5 = 1 if interview__key == "34-86-18-90" & membres__id == 13
replace M5 = 1 if interview__key == "07-90-99-52" & membres__id == 4
replace M5 = 2 if interview__key == "07-90-99-52" & membres__id == 7
replace M5 = 1 if interview__key == "07-90-99-52" & membres__id == 8
replace M5 = 2 if interview__key == "38-85-80-22" & membres__id == 6
replace M5 = 2 if interview__key == "38-85-80-22" & membres__id == 9
replace M5 = 1 if interview__key == "22-14-29-37" & membres__id == 7
replace M5 = 1 if interview__key == "78-27-40-17" & membres__id == 4
replace M5 = 1 if interview__key == "61-43-67-28" & membres__id == 4
replace M5 = 2 if interview__key == "91-93-78-84" & membres__id == 6
replace M5 = 2 if interview__key == "01-55-40-32" & membres__id == 4
replace M5 = 2 if interview__key == "92-92-22-50" & membres__id == 9
replace M5 = 1 if interview__key == "92-92-22-50" & membres__id == 10
replace M5 = 1 if interview__key == "86-51-75-91" & membres__id == 5
replace M5 = 2 if interview__key == "76-55-58-79" & membres__id == 3
replace M5 = 2 if interview__key == "76-55-58-79" & membres__id == 5
replace M5 = 2 if interview__key == "56-73-66-30" & membres__id == 5
replace M5 = 1 if interview__key == "49-75-10-62" & membres__id == 3
replace M5 = 2 if interview__key == "49-75-10-62" & membres__id == 4
replace M5 = 2 if interview__key == "28-52-90-12" & membres__id == 3
replace M5 = 2 if interview__key == "41-39-30-85" & membres__id == 6
replace M5 = 2 if interview__key == "77-49-63-97" & membres__id == 6
replace M5 = 2 if interview__key == "57-01-69-02" & membres__id == 4
replace M5 = 1 if interview__key == "34-47-82-02" & membres__id == 3
replace M5 = 1 if interview__key == "01-71-73-69" & membres__id == 4
replace M5 = 2 if interview__key == "85-61-82-80" & membres__id == 2
replace M5 = 2 if interview__key == "27-36-40-16" & membres__id == 12
replace M5 = 2 if interview__key == "85-03-96-30" & membres__id == 1
replace M5 = 2 if interview__key == "15-15-00-46" & membres__id == 8
replace M5 = 2 if interview__key == "33-03-25-17" & membres__id == 6
replace M5 = 2 if interview__key == "06-68-90-11" & membres__id == 4
replace M5 = 2 if interview__key == "31-75-15-41" & membres__id == 5
replace M5 = 2 if interview__key == "31-75-15-41" & membres__id == 10
replace M5 = 2 if interview__key == "31-75-15-41" & membres__id == 12
replace M5 = 1 if interview__key == "21-66-99-01" & membres__id == 2
replace M5 = 2 if interview__key == "21-66-99-01" & membres__id == 4
replace M5 = 1 if interview__key == "21-66-99-01" & membres__id == 5
replace M5 = 1 if interview__key == "66-80-78-39" & membres__id == 4
replace M5 = 2 if interview__key == "33-59-36-33" & membres__id == 7
replace M5 = 2 if interview__key == "33-59-36-33" & membres__id == 13
replace M5 = 2 if interview__key == "33-59-36-33" & membres__id == 14
replace M5 = 1 if interview__key == "96-55-60-44" & membres__id == 5
replace M5 = 2 if interview__key == "35-74-59-09" & membres__id == 5
replace M5 = 2 if interview__key == "82-10-66-79" & membres__id == 1
replace M5 = 1 if interview__key == "02-21-54-62" & membres__id == 2
replace M5 = 2 if interview__key == "02-21-54-62" & membres__id == 4
replace M5 = 1 if interview__key == "02-21-54-62" & membres__id == 6
replace M5 = 2 if interview__key == "66-46-14-31" & membres__id == 3
replace M5 = 2 if interview__key == "45-93-34-85" & membres__id == 1
replace M5 = 2 if interview__key == "39-88-30-89" & membres__id == 5
replace M5 = 1 if interview__key == "68-16-69-17" & membres__id == 11
replace M5 = 2 if interview__key == "68-16-69-17" & membres__id == 14
replace M5 = 2 if interview__key == "86-34-07-82" & membres__id == 5
replace M5 = 2 if interview__key == "83-72-52-32" & membres__id == 1
replace M5 = 2 if interview__key == "67-98-51-17" & membres__id == 10
replace M5 = 1 if interview__key == "95-86-43-28" & membres__id == 8
replace M5 = 1 if interview__key == "95-86-43-28" & membres__id == 12
replace M5 = 2 if interview__key == "02-02-46-43" & membres__id == 2
replace M5 = 2 if interview__key == "17-16-91-25" & membres__id == 2
replace M5 = 1 if interview__key == "17-16-91-25" & membres__id == 4
replace M5 = 2 if interview__key == "17-16-91-25" & membres__id == 5
replace M5 = 1 if interview__key == "17-16-91-25" & membres__id == 7
replace M5 = 1 if interview__key == "51-26-62-31" & membres__id == 4
replace M5 = 1 if interview__key == "51-26-62-31" & membres__id == 6
replace M5 = 1 if interview__key == "45-95-40-15" & membres__id == 3
replace M5 = 2 if interview__key == "60-56-96-29" & membres__id == 11
replace M5 = 1 if interview__key == "67-77-26-01" & membres__id == 11
replace M5 = 1 if interview__key == "67-77-26-01" & membres__id == 13
replace M5 = 1 if interview__key == "49-08-01-90" & membres__id == 5
replace M5 = 1 if interview__key == "72-62-61-33" & membres__id == 1
replace M5 = 2 if interview__key == "42-85-55-04" & membres__id == 5
replace M5 = 2 if interview__key == "54-23-29-83" & membres__id == 11
replace M5 = 2 if interview__key == "76-82-60-07" & membres__id == 5
replace M5 = 1 if interview__key == "76-82-60-07" & membres__id == 6
replace M5 = 1 if interview__key == "19-44-43-15" & membres__id == 5
replace M5 = 1 if interview__key == "82-88-81-98" & membres__id == 3
replace M5 = 2 if interview__key == "82-88-81-98" & membres__id == 4
replace M5 = 1 if interview__key == "82-88-81-98" & membres__id == 6
replace M5 = 2 if interview__key == "82-30-74-94" & membres__id == 4
replace M5 = 1 if interview__key == "09-99-08-37" & membres__id == 9
replace M5 = 2 if interview__key == "74-87-79-80" & membres__id == 5
replace M5 = 2 if interview__key == "32-63-76-66" & membres__id == 4
replace M5 = 1 if interview__key == "84-13-77-70" & membres__id == 2
replace M5 = 2 if interview__key == "84-13-77-70" & membres__id == 4
replace M5 = 2 if interview__key == "58-20-69-38" & membres__id == 1
replace M5 = 2 if interview__key == "58-20-69-38" & membres__id == 3
replace M5 = 1 if interview__key == "58-20-69-38" & membres__id == 6
replace M5 = 1 if interview__key == "16-18-81-41" & membres__id == 1
replace M5 = 1 if interview__key == "95-99-35-35" & membres__id == 6
replace M5 = 1 if interview__key == "97-67-77-63" & membres__id == 5
replace M5 = 2 if interview__key == "16-89-25-30" & membres__id == 4
replace M5 = 1 if interview__key == "85-25-51-49" & membres__id == 1
replace M5 = 2 if interview__key == "32-75-43-88" & membres__id == 5
replace M5 = 1 if interview__key == "32-75-43-88" & membres__id == 7
replace M5 = 1 if interview__key == "59-04-55-16" & membres__id == 5
replace M5 = 1 if interview__key == "59-04-55-16" & membres__id == 7
replace M5 = 2 if interview__key == "59-04-55-16" & membres__id == 9
replace M5 = 1 if interview__key == "59-04-55-16" & membres__id == 12
replace M5 = 1 if interview__key == "69-09-86-04" & membres__id == 3
replace M5 = 1 if interview__key == "14-18-06-07" & membres__id == 3
replace M5 = 1 if interview__key == "14-18-06-07" & membres__id == 6
replace M5 = 1 if interview__key == "10-54-50-47" & membres__id == 8
replace M5 = 2 if interview__key == "90-17-27-71" & membres__id == 2
replace M5 = 2 if interview__key == "49-44-52-84" & membres__id == 1
replace M5 = 2 if interview__key == "49-44-52-84" & membres__id == 5
replace M5 = 2 if interview__key == "19-87-45-83" & membres__id == 3
replace M5 = 2 if interview__key == "87-01-32-85" & membres__id == 3
replace M5 = 2 if interview__key == "64-47-72-46" & membres__id == 6
replace M5 = 1 if interview__key == "08-42-42-95" & membres__id == 4
replace M5 = 2 if interview__key == "93-60-01-81" & membres__id == 1
replace M5 = 2 if interview__key == "80-59-36-87" & membres__id == 1
replace M5 = 2 if interview__key == "15-47-76-61" & membres__id == 5
replace M5 = 2 if interview__key == "89-18-98-22" & membres__id == 5
replace M5 = 1 if interview__key == "89-18-98-22" & membres__id == 7
replace M5 = 1 if interview__key == "33-70-52-13" & membres__id == 7
replace M5 = 1 if interview__key == "34-38-03-03" & membres__id == 1
replace M5 = 1 if interview__key == "93-20-82-19" & membres__id == 3
replace M5 = 2 if interview__key == "45-53-95-33" & membres__id == 17
replace M5 = 1 if interview__key == "26-12-60-17" & membres__id == 7
replace M5 = 1 if interview__key == "21-27-82-36" & membres__id == 3
replace M5 = 2 if interview__key == "81-92-15-12" & membres__id == 4
replace M5 = 1 if interview__key == "35-18-59-09" & membres__id == 3
replace M5 = 2 if interview__key == "93-37-33-17" & membres__id == 4
replace M5 = 2 if interview__key == "28-03-29-79" & membres__id == 3
replace M5 = 1 if interview__key == "78-35-05-15" & membres__id == 6
replace M5 = 2 if interview__key == "34-98-87-79" & membres__id == 3
replace M5 = 1 if interview__key == "06-43-70-86" & membres__id == 6
replace M5 = 2 if interview__key == "94-52-90-80" & membres__id == 4
replace M5 = 2 if interview__key == "56-87-24-48" & membres__id == 4
replace M5 = 1 if interview__key == "40-44-57-08" & membres__id == 5
replace M5 = 1 if interview__key == "40-44-57-08" & membres__id == 12
replace M5 = 2 if interview__key == "51-79-31-11" & membres__id == 3
replace M5 = 1 if interview__key == "88-91-41-61" & membres__id == 4
replace M5 = 2 if interview__key == "53-45-92-93" & membres__id == 4
replace M5 = 2 if interview__key == "27-32-83-22" & membres__id == 5
replace M5 = 1 if interview__key == "04-30-43-63" & membres__id == 5
replace M5 = 1 if interview__key == "22-96-46-27" & membres__id == 3
replace M5 = 2 if interview__key == "88-80-46-81" & membres__id == 6
replace M5 = 2 if interview__key == "21-35-18-68" & membres__id == 4
replace M5 = 1 if interview__key == "21-35-18-68" & membres__id == 7
replace M5 = 2 if interview__key == "82-86-97-09" & membres__id == 5
replace M5 = 2 if interview__key == "36-83-06-30" & membres__id == 11
replace M5 = 1 if interview__key == "85-69-41-49" & membres__id == 9
replace M5 = 2 if interview__key == "12-85-47-65" & membres__id == 11
replace M5 = 2 if interview__key == "38-38-29-19" & membres__id == 15
replace M5 = 2 if interview__key == "64-28-84-86" & membres__id == 3
replace M5 = 1 if interview__key == "53-84-72-44" & membres__id == 5
replace M5 = 1 if interview__key == "42-69-17-55" & membres__id == 5
replace M5 = 1 if interview__key == "67-85-57-70" & membres__id == 4
replace M5 = 1 if interview__key == "62-79-33-47" & membres__id == 4
replace M5 = 2 if interview__key == "25-98-37-93" & membres__id == 4
replace M5 = 2 if interview__key == "41-45-51-54" & membres__id == 4
replace M5 = 2 if interview__key == "41-45-51-54" & membres__id == 5
replace M5 = 2 if interview__key == "40-82-83-18" & membres__id == 5
replace M5 = 1 if interview__key == "70-76-62-86" & membres__id == 3
replace M5 = 2 if interview__key == "05-86-21-06" & membres__id == 4
replace M5 = 1 if interview__key == "16-29-28-35" & membres__id == 8
replace M5 = 2 if interview__key == "16-29-28-35" & membres__id == 10
replace M5 = 2 if interview__key == "16-29-28-35" & membres__id == 11
replace M5 = 2 if interview__key == "48-89-48-74" & membres__id == 5
replace M5 = 1 if interview__key == "52-45-76-94" & membres__id == 5
replace M5 = 2 if interview__key == "12-28-76-93" & membres__id == 9
replace M5 = 1 if interview__key == "96-59-42-21" & membres__id == 2
replace M5 = 2 if interview__key == "96-59-42-21" & membres__id == 4
replace M5 = 2 if interview__key == "53-48-38-70" & membres__id == 11
replace M5 = 1 if interview__key == "53-48-38-70" & membres__id == 13
replace M5 = 1 if interview__key == "40-79-52-06" & membres__id == 1
replace M5 = 1 if interview__key == "40-79-52-06" & membres__id == 2
replace M5 = 2 if interview__key == "98-19-57-42" & membres__id == 3
replace M5 = 2 if interview__key == "79-39-11-74" & membres__id == 13
replace M5 = 2 if interview__key == "86-73-23-49" & membres__id == 2
replace M5 = 1 if interview__key == "86-73-23-49" & membres__id == 4
replace M5 = 2 if interview__key == "22-39-83-48" & membres__id == 6
replace M5 = 1 if interview__key == "22-39-83-48" & membres__id == 8
replace M5 = 2 if interview__key == "22-39-83-48" & membres__id == 9
replace M5 = 1 if interview__key == "18-19-10-29" & membres__id == 5
replace M5 = 1 if interview__key == "49-67-58-70" & membres__id == 6
replace M5 = 1 if interview__key == "49-67-58-70" & membres__id == 8
replace M5 = 2 if interview__key == "49-67-58-70" & membres__id == 9
replace M5 = 1 if interview__key == "49-67-58-70" & membres__id == 10
replace M5 = 1 if interview__key == "25-97-18-63" & membres__id == 4
replace M5 = 2 if interview__key == "25-97-18-63" & membres__id == 5
replace M5 = 2 if interview__key == "02-54-07-50" & membres__id == 4
replace M5 = 1 if interview__key == "32-56-97-71" & membres__id == 9
replace M5 = 2 if interview__key == "87-07-68-44" & membres__id == 1
replace M5 = 2 if interview__key == "87-07-68-44" & membres__id == 2
replace M5 = 2 if interview__key == "97-88-20-94" & membres__id == 9
replace M5 = 2 if interview__key == "13-06-34-97" & membres__id == 5
replace M5 = 1 if interview__key == "32-62-99-93" & membres__id == 3
replace M5 = 2 if interview__key == "56-04-61-25" & membres__id == 4
replace M5 = 2 if interview__key == "56-04-61-25" & membres__id == 6
replace M5 = 1 if interview__key == "56-04-61-25" & membres__id == 7
replace M5 = 1 if interview__key == "56-04-61-25" & membres__id == 8
replace M5 = 1 if interview__key == "60-45-19-28" & membres__id == 6
replace M5 = 1 if interview__key == "60-45-19-28" & membres__id == 11
replace M5 = 1 if interview__key == "55-03-40-96" & membres__id == 3
replace M5 = 2 if interview__key == "55-03-40-96" & membres__id == 6
replace M5 = 1 if interview__key == "19-92-52-56" & membres__id == 5
replace M5 = 1 if interview__key == "35-65-22-47" & membres__id == 2
replace M5 = 2 if interview__key == "38-79-75-07" & membres__id == 1
replace M5 = 1 if interview__key == "62-78-17-39" & membres__id == 8
replace M5 = 1 if interview__key == "13-06-93-64" & membres__id == 4
replace M5 = 2 if interview__key == "18-67-47-44" & membres__id == 4
replace M5 = 1 if interview__key == "73-25-95-02" & membres__id == 4
replace M5 = 2 if interview__key == "40-67-81-94" & membres__id == 5
replace M5 = 2 if interview__key == "31-03-95-19" & membres__id == 5
replace M5 = 1 if interview__key == "88-02-98-90" & membres__id == 4
replace M5 = 2 if interview__key == "88-02-98-90" & membres__id == 5
replace M5 = 2 if interview__key == "88-02-98-90" & membres__id == 9
replace M5 = 2 if interview__key == "88-02-98-90" & membres__id == 10
replace M5 = 2 if interview__key == "94-27-96-39" & membres__id == 3
replace M5 = 1 if interview__key == "94-27-96-39" & membres__id == 4
replace M5 = 1 if interview__key == "61-81-73-72" & membres__id == 5
replace M5 = 2 if interview__key == "25-68-56-67" & membres__id == 6
replace M5 = 1 if interview__key == "25-68-56-67" & membres__id == 7
replace M5 = 2 if interview__key == "25-68-56-67" & membres__id == 8
replace M5 = 1 if interview__key == "25-68-56-67" & membres__id == 9
replace M5 = 2 if interview__key == "90-47-10-03" & membres__id == 3
replace M5 = 2 if interview__key == "87-27-16-31" & membres__id == 4
replace M5 = 2 if interview__key == "57-50-39-68" & membres__id == 3
replace M5 = 2 if interview__key == "11-06-46-65" & membres__id == 5
replace M5 = 1 if interview__key == "49-11-72-44" & membres__id == 11
replace M5 = 2 if interview__key == "45-38-71-25" & membres__id == 7
replace M5 = 1 if interview__key == "01-81-28-76" & membres__id == 4
replace M5 = 1 if interview__key == "36-20-58-23" & membres__id == 8
replace M5 = 2 if interview__key == "36-20-58-23" & membres__id == 25
replace M5 = 2 if interview__key == "68-87-05-07" & membres__id == 3
replace M5 = 2 if interview__key == "26-78-71-23" & membres__id == 5
replace M5 = 1 if interview__key == "44-56-03-85" & membres__id == 3
replace M5 = 2 if interview__key == "93-73-61-59" & membres__id == 7
replace M5 = 2 if interview__key == "36-71-04-15" & membres__id == 6
replace M5 = 2 if interview__key == "36-71-04-15" & membres__id == 7
replace M5 = 2 if interview__key == "36-71-04-15" & membres__id == 11
replace M5 = 1 if interview__key == "36-71-04-15" & membres__id == 12
replace M5 = 1 if interview__key == "38-71-16-76" & membres__id == 5
replace M5 = 2 if interview__key == "69-49-78-55" & membres__id == 5
replace M5 = 2 if interview__key == "43-43-84-91" & membres__id == 5
replace M5 = 2 if interview__key == "20-21-58-21" & membres__id == 3
replace M5 = 2 if interview__key == "10-52-90-76" & membres__id == 3
replace M5 = 2 if interview__key == "95-35-07-76" & membres__id == 5
replace M5 = 2 if interview__key == "09-49-81-04" & membres__id == 5
replace M5 = 1 if interview__key == "09-49-81-04" & membres__id == 6
replace M5 = 2 if interview__key == "84-69-67-04" & membres__id == 3
replace M5 = 1 if interview__key == "84-69-67-04" & membres__id == 4
replace M5 = 2 if interview__key == "84-69-67-04" & membres__id == 5
replace M5 = 1 if interview__key == "84-69-67-04" & membres__id == 7
replace M5 = 1 if interview__key == "98-55-83-03" & membres__id == 3
replace M5 = 1 if interview__key == "98-55-83-03" & membres__id == 5
replace M5 = 1 if interview__key == "18-68-97-66" & membres__id == 1
replace M5 = 1 if interview__key == "84-18-60-84" & membres__id == 6
replace M5 = 2 if interview__key == "84-18-60-84" & membres__id == 8
replace M5 = 1 if interview__key == "84-18-60-84" & membres__id == 10
replace M5 = 1 if interview__key == "84-18-60-84" & membres__id == 11
replace M5 = 2 if interview__key == "84-18-60-84" & membres__id == 13
replace M5 = 1 if interview__key == "45-76-21-33" & membres__id == 7
replace M5 = 2 if interview__key == "45-76-21-33" & membres__id == 10
replace M5 = 2 if interview__key == "45-76-21-33" & membres__id == 11
replace M5 = 2 if interview__key == "63-27-63-71" & membres__id == 4
replace M5 = 1 if interview__key == "60-51-32-48" & membres__id == 3
replace M5 = 2 if interview__key == "85-58-55-06" & membres__id == 3
replace M5 = 2 if interview__key == "02-68-99-89" & membres__id == 7
replace M5 = 1 if interview__key == "02-68-99-89" & membres__id == 9
replace M5 = 2 if interview__key == "56-17-68-03" & membres__id == 4
replace M5 = 1 if interview__key == "45-59-01-27" & membres__id == 2
replace M5 = 2 if interview__key == "74-55-60-74" & membres__id == 1
replace M5 = 1 if interview__key == "43-39-88-51" & membres__id == 7
replace M5 = 1 if interview__key == "82-91-21-58" & membres__id == 6
replace M5 = 2 if interview__key == "92-56-91-94" & membres__id == 3
replace M5 = 2 if interview__key == "70-87-80-62" & membres__id == 5
replace M5 = 1 if interview__key == "53-17-15-87" & membres__id == 8
replace M5 = 2 if interview__key == "91-83-11-66" & membres__id == 5
replace M5 = 1 if interview__key == "85-26-68-19" & membres__id == 3
replace M5 = 1 if interview__key == "39-45-78-34" & membres__id == 3
replace M5 = 2 if interview__key == "39-45-78-34" & membres__id == 4
replace M5 = 1 if interview__key == "98-44-80-39" & membres__id == 1
replace M5 = 1 if interview__key == "53-62-81-40" & membres__id == 3
replace M5 = 2 if interview__key == "60-19-67-45" & membres__id == 4
replace M5 = 2 if interview__key == "83-29-84-26" & membres__id == 4
replace M5 = 2 if interview__key == "49-03-27-54" & membres__id == 2
replace M5 = 1 if interview__key == "49-03-27-54" & membres__id == 4
replace M5 = 2 if interview__key == "49-03-27-54" & membres__id == 5
replace M5 = 1 if interview__key == "42-60-84-76" & membres__id == 2
replace M5 = 2 if interview__key == "19-30-67-83" & membres__id == 16
replace M5 = 2 if interview__key == "73-34-91-11" & membres__id == 3
replace M5 = 2 if interview__key == "38-36-65-83" & membres__id == 8
replace M5 = 1 if interview__key == "69-32-75-30" & membres__id == 2
replace M5 = 1 if interview__key == "73-61-54-45" & membres__id == 4
replace M5 = 1 if interview__key == "94-00-92-29" & membres__id == 3
replace M5 = 2 if interview__key == "24-01-90-31" & membres__id == 5
replace M5 = 2 if interview__key == "16-26-83-57" & membres__id == 6
replace M5 = 1 if interview__key == "33-35-70-13" & membres__id == 5
replace M5 = 1 if interview__key == "00-83-04-79" & membres__id == 3
replace M5 = 1 if interview__key == "00-83-04-79" & membres__id == 7
replace M5 = 2 if interview__key == "88-15-63-41" & membres__id == 4
replace M5 = 1 if interview__key == "88-15-63-41" & membres__id == 7
replace M5 = 1 if interview__key == "88-15-63-41" & membres__id == 9
replace M5 = 2 if interview__key == "15-24-00-01" & membres__id == 1
replace M5 = 2 if interview__key == "69-87-53-17" & membres__id == 3
replace M5 = 1 if interview__key == "77-57-13-93" & membres__id == 3
replace M5 = 2 if interview__key == "68-21-32-59" & membres__id == 13
replace M5 = 1 if interview__key == "68-21-32-59" & membres__id == 15
replace M5 = 1 if interview__key == "27-49-37-09" & membres__id == 4
replace M5 = 2 if interview__key == "35-70-60-78" & membres__id == 1
replace M5 = 2 if interview__key == "56-52-72-02" & membres__id == 4
replace M5 = 2 if interview__key == "56-52-72-02" & membres__id == 8
replace M5 = 2 if interview__key == "68-45-93-40" & membres__id == 3
replace M5 = 1 if interview__key == "96-92-77-21" & membres__id == 3
replace M5 = 1 if interview__key == "36-85-18-87" & membres__id == 4
replace M5 = 2 if interview__key == "11-67-27-86" & membres__id == 3
replace M5 = 2 if interview__key == "61-99-24-95" & membres__id == 6
replace M5 = 1 if interview__key == "61-99-24-95" & membres__id == 7
replace M5 = 2 if interview__key == "61-99-24-95" & membres__id == 9
replace M5 = 1 if interview__key == "61-99-24-95" & membres__id == 10
replace M5 = 1 if interview__key == "61-99-24-95" & membres__id == 11
replace M5 = 2 if interview__key == "14-60-16-94" & membres__id == 4
replace M5 = 1 if interview__key == "68-63-22-68" & membres__id == 3
replace M5 = 1 if interview__key == "75-25-42-53" & membres__id == 2
replace M5 = 2 if interview__key == "41-00-83-38" & membres__id == 4
replace M5 = 2 if interview__key == "69-16-08-03" & membres__id == 3
replace M5 = 2 if interview__key == "76-38-73-73" & membres__id == 3
replace M5 = 1 if interview__key == "76-38-73-73" & membres__id == 4
replace M5 = 2 if interview__key == "76-38-73-73" & membres__id == 5
replace M5 = 1 if interview__key == "76-38-73-73" & membres__id == 6
replace M5 = 2 if interview__key == "76-38-73-73" & membres__id == 8
replace M5 = 1 if interview__key == "76-38-73-73" & membres__id == 12
replace M5 = 2 if interview__key == "76-38-73-73" & membres__id == 13
replace M5 = 2 if interview__key == "62-48-87-07" & membres__id == 1
replace M5 = 2 if interview__key == "53-25-56-51" & membres__id == 3
replace M5 = 1 if interview__key == "96-02-98-87" & membres__id == 5
replace M5 = 2 if interview__key == "96-02-98-87" & membres__id == 7
replace M5 = 1 if interview__key == "96-02-98-87" & membres__id == 9
replace M5 = 1 if interview__key == "24-23-72-35" & membres__id == 7
replace M5 = 2 if interview__key == "24-23-72-35" & membres__id == 8
replace M5 = 1 if interview__key == "55-74-43-62" & membres__id == 3
replace M5 = 1 if interview__key == "55-74-43-62" & membres__id == 5
replace M5 = 1 if interview__key == "74-87-22-53" & membres__id == 5
replace M5 = 1 if interview__key == "58-86-09-05" & membres__id == 6
replace M5 = 2 if interview__key == "46-31-77-97" & membres__id == 2
replace M5 = 1 if interview__key == "33-45-09-93" & membres__id == 9
replace M5 = 1 if interview__key == "99-01-49-71" & membres__id == 5
replace M5 = 2 if interview__key == "21-90-60-50" & membres__id == 9
replace M5 = 1 if interview__key == "72-66-58-09" & membres__id == 3
replace M5 = 2 if interview__key == "86-17-24-10" & membres__id == 5
replace M5 = 1 if interview__key == "23-69-02-52" & membres__id == 3
replace M5 = 1 if interview__key == "88-95-16-97" & membres__id == 4
replace M5 = 2 if interview__key == "27-17-46-03" & membres__id == 6
replace M5 = 1 if interview__key == "27-17-46-03" & membres__id == 11
replace M5 = 2 if interview__key == "27-17-46-03" & membres__id == 12
replace M5 = 1 if interview__key == "27-17-46-03" & membres__id == 13
replace M5 = 2 if interview__key == "27-17-46-03" & membres__id == 14
replace M5 = 1 if interview__key == "27-17-46-03" & membres__id == 15
replace M5 = 2 if interview__key == "27-17-46-03" & membres__id == 16
replace M5 = 1 if interview__key == "27-17-46-03" & membres__id == 18
replace M5 = 2 if interview__key == "27-17-46-03" & membres__id == 19
replace M5 = 1 if interview__key == "27-17-46-03" & membres__id == 20
replace M5 = 2 if interview__key == "27-17-46-03" & membres__id == 23
replace M5 = 1 if interview__key == "27-17-46-03" & membres__id == 25
replace M5 = 1 if interview__key == "27-17-46-03" & membres__id == 27
replace M5 = 2 if interview__key == "27-17-46-03" & membres__id == 30
replace M5 = 2 if interview__key == "33-82-76-99" & membres__id == 7
replace M5 = 2 if interview__key == "13-55-97-93" & membres__id == 5
replace M5 = 2 if interview__key == "29-67-39-79" & membres__id == 3
replace M5 = 2 if interview__key == "29-67-39-79" & membres__id == 4
replace M5 = 1 if interview__key == "18-05-07-83" & membres__id == 4
replace M5 = 2 if interview__key == "36-09-02-75" & membres__id == 4
replace M5 = 2 if interview__key == "44-66-20-40" & membres__id == 2
replace M5 = 1 if interview__key == "40-29-70-48" & membres__id == 4
replace M5 = 1 if interview__key == "35-17-31-27" & membres__id == 3
replace M5 = 1 if interview__key == "35-17-31-27" & membres__id == 5
replace M5 = 2 if interview__key == "04-38-97-76" & membres__id == 3
replace M5 = 1 if interview__key == "03-46-21-64" & membres__id == 4
replace M5 = 2 if interview__key == "03-46-21-64" & membres__id == 6
replace M5 = 2 if interview__key == "22-66-83-34" & membres__id == 2
replace M5 = 1 if interview__key == "18-92-33-71" & membres__id == 10
replace M5 = 1 if interview__key == "18-92-33-71" & membres__id == 11
replace M5 = 1 if interview__key == "12-73-23-07" & membres__id == 3
replace M5 = 2 if interview__key == "71-11-78-09" & membres__id == 8
replace M5 = 1 if interview__key == "30-09-23-09" & membres__id == 1
replace M5 = 2 if interview__key == "54-67-23-49" & membres__id == 1
replace M5 = 1 if interview__key == "51-11-99-26" & membres__id == 4
replace M5 = 1 if interview__key == "51-11-99-26" & membres__id == 8
replace M5 = 2 if interview__key == "10-07-03-50" & membres__id == 6
replace M5 = 2 if interview__key == "43-68-07-17" & membres__id == 3
replace M5 = 1 if interview__key == "48-11-50-15" & membres__id == 8
replace M5 = 1 if interview__key == "48-11-50-15" & membres__id == 9
replace M5 = 1 if interview__key == "77-53-72-06" & membres__id == 6
replace M5 = 1 if interview__key == "85-97-17-81" & membres__id == 3
replace M5 = 2 if interview__key == "66-38-53-07" & membres__id == 3
replace M5 = 1 if interview__key == "45-14-80-02" & membres__id == 3
replace M5 = 2 if interview__key == "45-14-80-02" & membres__id == 5
replace M5 = 1 if interview__key == "69-01-23-14" & membres__id == 4
replace M5 = 2 if interview__key == "69-01-23-14" & membres__id == 7
replace M5 = 2 if interview__key == "09-40-98-88" & membres__id == 4
replace M5 = 1 if interview__key == "09-40-98-88" & membres__id == 6
replace M5 = 2 if interview__key == "09-40-98-88" & membres__id == 7
replace M5 = 1 if interview__key == "09-40-98-88" & membres__id == 9
replace M5 = 2 if interview__key == "55-17-06-96" & membres__id == 3
replace M5 = 1 if interview__key == "62-57-48-08" & membres__id == 5
replace M5 = 1 if interview__key == "41-68-02-91" & membres__id == 4
replace M5 = 2 if interview__key == "31-91-86-67" & membres__id == 4
replace M5 = 2 if interview__key == "60-47-78-17" & membres__id == 1
replace M5 = 2 if interview__key == "65-56-13-95" & membres__id == 7
replace M5 = 1 if interview__key == "65-56-13-95" & membres__id == 8
replace M5 = 2 if interview__key == "65-56-13-95" & membres__id == 9
replace M5 = 1 if interview__key == "65-56-13-95" & membres__id == 10
replace M5 = 2 if interview__key == "65-56-13-95" & membres__id == 11
replace M5 = 2 if interview__key == "65-56-13-95" & membres__id == 13
replace M5 = 1 if interview__key == "65-56-13-95" & membres__id == 14
replace M5 = 2 if interview__key == "65-56-13-95" & membres__id == 15
replace M5 = 1 if interview__key == "65-56-13-95" & membres__id == 17
replace M5 = 1 if interview__key == "65-56-13-95" & membres__id == 20
replace M5 = 2 if interview__key == "65-56-13-95" & membres__id == 21
replace M5 = 1 if interview__key == "65-56-13-95" & membres__id == 22
replace M5 = 2 if interview__key == "65-56-13-95" & membres__id == 23
replace M5 = 2 if interview__key == "96-53-79-13" & membres__id == 6
replace M5 = 1 if interview__key == "56-50-11-16" & membres__id == 1
replace M5 = 2 if interview__key == "04-12-83-47" & membres__id == 1
replace M5 = 1 if interview__key == "99-82-76-21" & membres__id == 6
replace M5 = 2 if interview__key == "91-89-45-44" & membres__id == 2
replace M5 = 1 if interview__key == "91-89-45-44" & membres__id == 3
replace M5 = 1 if interview__key == "94-94-85-16" & membres__id == 4
replace M5 = 2 if interview__key == "71-89-71-41" & membres__id == 3
replace M5 = 1 if interview__key == "93-50-75-69" & membres__id == 5
replace M5 = 1 if interview__key == "48-49-54-36" & membres__id == 5
replace M5 = 1 if interview__key == "58-66-45-77" & membres__id == 5
replace M5 = 1 if interview__key == "79-38-46-71" & membres__id == 6
replace M5 = 2 if interview__key == "07-89-73-38" & membres__id == 4
replace M5 = 2 if interview__key == "01-90-79-40" & membres__id == 8
replace M5 = 1 if interview__key == "20-15-18-05" & membres__id == 4
replace M5 = 2 if interview__key == "20-15-18-05" & membres__id == 11
replace M5 = 2 if interview__key == "64-33-18-97" & membres__id == 4
replace M5 = 2 if interview__key == "74-46-58-62" & membres__id == 1
replace M5 = 2 if interview__key == "12-00-37-35" & membres__id == 3
replace M5 = 1 if interview__key == "60-73-30-75" & membres__id == 9
replace M5 = 1 if interview__key == "09-20-46-85" & membres__id == 7
replace M5 = 1 if interview__key == "09-20-46-85" & membres__id == 9
replace M5 = 2 if interview__key == "76-86-58-21" & membres__id == 1
replace M5 = 1 if interview__key == "97-75-18-37" & membres__id == 5
replace M5 = 1 if interview__key == "59-22-70-40" & membres__id == 9
replace M5 = 1 if interview__key == "99-69-61-91" & membres__id == 1
replace M5 = 1 if interview__key == "66-03-87-19" & membres__id == 3
replace M5 = 1 if interview__key == "88-34-87-80" & membres__id == 3
replace M5 = 2 if interview__key == "05-83-06-30" & membres__id == 4
replace M5 = 1 if interview__key == "88-98-43-54" & membres__id == 3
replace M5 = 2 if interview__key == "47-05-44-89" & membres__id == 4
replace M5 = 2 if interview__key == "49-60-10-47" & membres__id == 4
replace M5 = 1 if interview__key == "41-61-65-49" & membres__id == 4
replace M5 = 2 if interview__key == "41-61-65-49" & membres__id == 6
replace M5 = 1 if interview__key == "33-57-53-30" & membres__id == 2
replace M5 = 2 if interview__key == "33-57-53-30" & membres__id == 5
replace M5 = 1 if interview__key == "33-57-53-30" & membres__id == 8
replace M5 = 2 if interview__key == "20-93-13-41" & membres__id == 5
replace M5 = 1 if interview__key == "90-27-71-64" & membres__id == 3
replace M5 = 1 if interview__key == "34-60-73-59" & membres__id == 3
replace M5 = 1 if interview__key == "65-58-80-88" & membres__id == 8
replace M5 = 2 if interview__key == "65-58-80-88" & membres__id == 9
replace M5 = 2 if interview__key == "59-08-87-36" & membres__id == 4
replace M5 = 2 if interview__key == "45-07-02-64" & membres__id == 7
replace M5 = 2 if interview__key == "45-07-02-64" & membres__id == 8
replace M5 = 2 if interview__key == "45-07-02-64" & membres__id == 9
replace M5 = 1 if interview__key == "97-93-41-42" & membres__id == 2
replace M5 = 2 if interview__key == "97-93-41-42" & membres__id == 4
replace M5 = 1 if interview__key == "97-93-41-42" & membres__id == 5
replace M5 = 2 if interview__key == "97-93-41-42" & membres__id == 7
replace M5 = 1 if interview__key == "97-93-41-42" & membres__id == 8
replace M5 = 2 if interview__key == "93-98-51-26" & membres__id == 5
replace M5 = 1 if interview__key == "25-71-47-73" & membres__id == 8
replace M5 = 2 if interview__key == "41-81-82-36" & membres__id == 4
replace M5 = 1 if interview__key == "41-81-82-36" & membres__id == 5
replace M5 = 2 if interview__key == "41-81-82-36" & membres__id == 7
replace M5 = 2 if interview__key == "62-13-87-69" & membres__id == 1
replace M5 = 1 if interview__key == "65-53-41-62" & membres__id == 5
replace M5 = 2 if interview__key == "65-53-41-62" & membres__id == 6
replace M5 = 1 if interview__key == "65-53-41-62" & membres__id == 7
replace M5 = 2 if interview__key == "06-15-53-06" & membres__id == 4
replace M5 = 2 if interview__key == "70-47-94-14" & membres__id == 6
replace M5 = 1 if interview__key == "70-47-94-14" & membres__id == 7
replace M5 = 2 if interview__key == "65-31-29-67" & membres__id == 11
replace M5 = 2 if interview__key == "20-77-84-65" & membres__id == 6
replace M5 = 1 if interview__key == "73-14-32-85" & membres__id == 4
replace M5 = 1 if interview__key == "70-82-59-03" & membres__id == 3
replace M5 = 1 if interview__key == "66-16-15-94" & membres__id == 3
replace M5 = 2 if interview__key == "88-60-86-11" & membres__id == 3
replace M5 = 2 if interview__key == "88-60-86-11" & membres__id == 6
replace M5 = 2 if interview__key == "28-78-83-16" & membres__id == 4
replace M5 = 1 if interview__key == "28-78-83-16" & membres__id == 5
replace M5 = 1 if interview__key == "81-31-98-12" & membres__id == 8
replace M5 = 2 if interview__key == "82-48-43-25" & membres__id == 5
replace M5 = 1 if interview__key == "53-03-72-53" & membres__id == 2
replace M5 = 1 if interview__key == "50-07-60-25" & membres__id == 5
replace M5 = 1 if interview__key == "07-27-78-24" & membres__id == 3
replace M5 = 2 if interview__key == "07-27-78-24" & membres__id == 6
replace M5 = 1 if interview__key == "66-94-24-77" & membres__id == 9
replace M5 = 1 if interview__key == "18-81-12-60" & membres__id == 14
replace M5 = 2 if interview__key == "18-81-12-60" & membres__id == 19
replace M5 = 2 if interview__key == "93-23-63-40" & membres__id == 6
replace M5 = 2 if interview__key == "92-49-96-70" & membres__id == 1
replace M5 = 2 if interview__key == "80-49-27-38" & membres__id == 2
replace M5 = 2 if interview__key == "01-29-25-15" & membres__id == 12
replace M5 = 1 if interview__key == "53-40-55-24" & membres__id == 7
replace M5 = 1 if interview__key == "63-79-37-08" & membres__id == 6
replace M5 = 2 if interview__key == "63-79-37-08" & membres__id == 8
replace M5 = 2 if interview__key == "63-79-37-08" & membres__id == 9
replace M5 = 1 if interview__key == "63-79-37-08" & membres__id == 11
replace M5 = 1 if interview__key == "63-79-37-08" & membres__id == 12
replace M5 = 2 if interview__key == "30-41-55-82" & membres__id == 2
replace M5 = 1 if interview__key == "30-41-55-82" & membres__id == 5
replace M5 = 2 if interview__key == "30-41-55-82" & membres__id == 6
replace M5 = 2 if interview__key == "43-68-99-19" & membres__id == 6
replace M5 = 2 if interview__key == "90-65-46-83" & membres__id == 5
replace M5 = 2 if interview__key == "16-43-13-86" & membres__id == 4
replace M5 = 2 if interview__key == "27-63-75-10" & membres__id == 1
replace M5 = 2 if interview__key == "33-80-67-33" & membres__id == 7
replace M5 = 2 if interview__key == "78-27-05-08" & membres__id == 4
replace M5 = 1 if interview__key == "04-78-93-30" & membres__id == 8
replace M5 = 2 if interview__key == "95-59-78-31" & membres__id == 4
replace M5 = 2 if interview__key == "19-91-26-87" & membres__id == 3
replace M5 = 1 if interview__key == "36-78-30-11" & membres__id == 3
replace M5 = 2 if interview__key == "00-15-77-83" & membres__id == 4
replace M5 = 1 if interview__key == "00-15-77-83" & membres__id == 5
replace M5 = 2 if interview__key == "00-15-77-83" & membres__id == 6
replace M5 = 2 if interview__key == "67-72-52-63" & membres__id == 6
replace M5 = 1 if interview__key == "52-86-81-95" & membres__id == 3
replace M5 = 2 if interview__key == "52-86-81-95" & membres__id == 5
replace M5 = 2 if interview__key == "87-94-01-76" & membres__id == 5
replace M5 = 1 if interview__key == "83-63-25-36" & membres__id == 3
replace M5 = 1 if interview__key == "04-35-02-64" & membres__id == 1
replace M5 = 1 if interview__key == "72-96-78-53" & membres__id == 5
replace M5 = 1 if interview__key == "27-89-79-04" & membres__id == 5
replace M5 = 1 if interview__key == "72-99-00-83" & membres__id == 8
replace M5 = 2 if interview__key == "67-28-35-90" & membres__id == 1
replace M5 = 2 if interview__key == "63-14-01-25" & membres__id == 7
replace M5 = 1 if interview__key == "05-50-73-71" & membres__id == 1
replace M5 = 2 if interview__key == "05-50-73-71" & membres__id == 5
replace M5 = 1 if interview__key == "05-50-73-71" & membres__id == 6
replace M5 = 2 if interview__key == "05-50-73-71" & membres__id == 10
replace M5 = 2 if interview__key == "05-50-73-71" & membres__id == 14
replace M5 = 2 if interview__key == "73-26-12-88" & membres__id == 2
replace M5 = 1 if interview__key == "73-26-12-88" & membres__id == 4
replace M5 = 2 if interview__key == "83-73-51-55" & membres__id == 3
replace M5 = 2 if interview__key == "86-14-19-12" & membres__id == 4
replace M5 = 1 if interview__key == "40-75-30-10" & membres__id == 5
replace M5 = 1 if interview__key == "40-75-30-10" & membres__id == 7
replace M5 = 1 if interview__key == "39-94-38-38" & membres__id == 3
replace M5 = 1 if interview__key == "39-94-38-38" & membres__id == 7
replace M5 = 2 if interview__key == "39-94-38-38" & membres__id == 8
replace M5 = 2 if interview__key == "96-21-25-91" & membres__id == 4
replace M5 = 2 if interview__key == "19-27-89-58" & membres__id == 12
replace M5 = 2 if interview__key == "29-30-69-02" & membres__id == 3
replace M5 = 2 if interview__key == "29-30-69-02" & membres__id == 4
replace M5 = 1 if interview__key == "29-30-69-02" & membres__id == 6
replace M5 = 1 if interview__key == "29-30-69-02" & membres__id == 8
replace M5 = 2 if interview__key == "65-64-10-01" & membres__id == 3
replace M5 = 1 if interview__key == "71-90-91-34" & membres__id == 5
replace M5 = 1 if interview__key == "71-90-91-34" & membres__id == 8
replace M5 = 2 if interview__key == "32-38-67-61" & membres__id == 10
replace M5 = 2 if interview__key == "54-83-98-62" & membres__id == 4
replace M5 = 1 if interview__key == "87-29-80-69" & membres__id == 3
replace M5 = 1 if interview__key == "78-41-84-27" & membres__id == 1
replace M5 = 1 if interview__key == "20-31-43-50" & membres__id == 3
replace M5 = 1 if interview__key == "83-98-86-31" & membres__id == 3
replace M5 = 2 if interview__key == "86-19-71-67" & membres__id == 4
replace M5 = 1 if interview__key == "86-19-71-67" & membres__id == 5
replace M5 = 2 if interview__key == "86-19-71-67" & membres__id == 6
replace M5 = 1 if interview__key == "86-19-71-67" & membres__id == 8
replace M5 = 2 if interview__key == "96-10-13-16" & membres__id == 2
replace M5 = 2 if interview__key == "96-10-13-16" & membres__id == 4
replace M5 = 1 if interview__key == "59-36-82-91" & membres__id == 7
replace M5 = 2 if interview__key == "00-92-38-60" & membres__id == 5
replace M5 = 2 if interview__key == "03-88-03-67" & membres__id == 3
replace M5 = 2 if interview__key == "03-88-03-67" & membres__id == 5
replace M5 = 1 if interview__key == "72-58-95-00" & membres__id == 5
replace M5 = 1 if interview__key == "15-69-13-54" & membres__id == 5
replace M5 = 1 if interview__key == "67-17-51-15" & membres__id == 2
replace M5 = 1 if interview__key == "17-62-89-31" & membres__id == 2
replace M5 = 2 if interview__key == "33-28-79-79" & membres__id == 2
replace M5 = 2 if interview__key == "24-51-86-63" & membres__id == 8
replace M5 = 1 if interview__key == "24-51-86-63" & membres__id == 10
replace M5 = 1 if interview__key == "31-10-94-43" & membres__id == 4
replace M5 = 1 if interview__key == "90-99-23-74" & membres__id == 12
replace M5 = 1 if interview__key == "59-52-36-40" & membres__id == 1
replace M5 = 1 if interview__key == "13-40-20-19" & membres__id == 6
replace M5 = 2 if interview__key == "58-26-62-24" & membres__id == 1
replace M5 = 1 if interview__key == "26-35-20-49" & membres__id == 3
replace M5 = 2 if interview__key == "26-35-20-49" & membres__id == 4
replace M5 = 1 if interview__key == "13-31-69-05" & membres__id == 2
replace M5 = 2 if interview__key == "00-39-83-29" & membres__id == 6
replace M5 = 2 if interview__key == "39-73-08-17" & membres__id == 1
replace M5 = 1 if interview__key == "86-85-72-41" & membres__id == 2
replace M5 = 2 if interview__key == "86-85-72-41" & membres__id == 4
replace M5 = 1 if interview__key == "86-85-72-41" & membres__id == 9
replace M5 = 1 if interview__key == "86-85-72-41" & membres__id == 10
replace M5 = 2 if interview__key == "82-31-61-12" & membres__id == 2
replace M5 = 2 if interview__key == "31-81-13-00" & membres__id == 1
replace M5 = 2 if interview__key == "30-55-21-47" & membres__id == 4
replace M5 = 2 if interview__key == "67-73-77-36" & membres__id == 5
replace M5 = 2 if interview__key == "67-73-77-36" & membres__id == 9
replace M5 = 2 if interview__key == "15-12-88-78" & membres__id == 7
replace M5 = 2 if interview__key == "52-09-23-03" & membres__id == 1
replace M5 = 1 if interview__key == "51-63-11-10" & membres__id == 3
replace M5 = 2 if interview__key == "51-63-11-10" & membres__id == 10
replace M5 = 2 if interview__key == "51-63-11-10" & membres__id == 14
replace M5 = 2 if interview__key == "85-62-23-32" & membres__id == 4
replace M5 = 2 if interview__key == "85-62-23-32" & membres__id == 5
replace M5 = 1 if interview__key == "85-62-23-32" & membres__id == 7
replace M5 = 1 if interview__key == "97-59-70-69" & membres__id == 3
replace M5 = 1 if interview__key == "80-01-23-20" & membres__id == 2
replace M5 = 2 if interview__key == "04-62-29-83" & membres__id == 9
replace M5 = 2 if interview__key == "11-57-29-25" & membres__id == 2
replace M5 = 2 if interview__key == "51-12-74-43" & membres__id == 4
replace M5 = 2 if interview__key == "27-99-09-86" & membres__id == 6
replace M5 = 1 if interview__key == "20-79-84-44" & membres__id == 8
replace M5 = 2 if interview__key == "65-66-63-67" & membres__id == 7
replace M5 = 2 if interview__key == "77-17-91-31" & membres__id == 1
replace M5 = 2 if interview__key == "41-28-24-81" & membres__id == 7
replace M5 = 2 if interview__key == "54-79-71-81" & membres__id == 8
replace M5 = 1 if interview__key == "54-79-71-81" & membres__id == 9
replace M5 = 1 if interview__key == "54-79-71-81" & membres__id == 10
replace M5 = 2 if interview__key == "54-79-71-81" & membres__id == 12
replace M5 = 2 if interview__key == "54-79-71-81" & membres__id == 13
replace M5 = 1 if interview__key == "54-79-71-81" & membres__id == 16
replace M5 = 1 if interview__key == "54-79-71-81" & membres__id == 19
replace M5 = 2 if interview__key == "54-79-71-81" & membres__id == 21
replace M5 = 1 if interview__key == "65-49-07-34" & membres__id == 3
replace M5 = 1 if interview__key == "89-04-43-44" & membres__id == 2
replace M5 = 2 if interview__key == "89-04-43-44" & membres__id == 4
replace M5 = 1 if interview__key == "89-04-43-44" & membres__id == 6
replace M5 = 2 if interview__key == "89-04-43-44" & membres__id == 7
replace M5 = 2 if interview__key == "50-17-25-32" & membres__id == 10
replace M5 = 2 if interview__key == "46-56-51-02" & membres__id == 3
replace M5 = 1 if interview__key == "89-12-94-79" & membres__id == 1
replace M5 = 2 if interview__key == "89-12-94-79" & membres__id == 2
replace M5 = 2 if interview__key == "52-84-79-03" & membres__id == 1
replace M5 = 2 if interview__key == "66-34-89-18" & membres__id == 3
replace M5 = 2 if interview__key == "37-97-42-14" & membres__id == 9
replace M5 = 2 if interview__key == "61-71-26-83" & membres__id == 1
replace M5 = 2 if interview__key == "25-54-78-67" & membres__id == 6
replace M5 = 1 if interview__key == "25-54-78-67" & membres__id == 7
replace M5 = 2 if interview__key == "25-54-78-67" & membres__id == 8
replace M5 = 1 if interview__key == "25-54-78-67" & membres__id == 9
replace M5 = 2 if interview__key == "25-54-78-67" & membres__id == 10
replace M5 = 1 if interview__key == "16-06-85-63" & membres__id == 7
replace M5 = 2 if interview__key == "32-68-59-74" & membres__id == 4
replace M5 = 2 if interview__key == "74-94-62-59" & membres__id == 4
replace M5 = 2 if interview__key == "94-68-34-31" & membres__id == 7
replace M5 = 1 if interview__key == "29-82-95-03" & membres__id == 3
replace M5 = 1 if interview__key == "35-67-39-85" & membres__id == 6
replace M5 = 1 if interview__key == "28-23-95-42" & membres__id == 8
replace M5 = 1 if interview__key == "30-88-37-58" & membres__id == 1
replace M5 = 1 if interview__key == "36-11-00-74" & membres__id == 5
replace M5 = 1 if interview__key == "56-58-21-61" & membres__id == 6
replace M5 = 2 if interview__key == "91-82-39-84" & membres__id == 5
replace M5 = 2 if interview__key == "34-82-89-86" & membres__id == 5
replace M5 = 1 if interview__key == "88-74-80-41" & membres__id == 9
replace M5 = 2 if interview__key == "02-89-81-45" & membres__id == 4
replace M5 = 1 if interview__key == "81-93-32-28" & membres__id == 4
replace M5 = 2 if interview__key == "81-93-32-28" & membres__id == 5
replace M5 = 1 if interview__key == "81-93-32-28" & membres__id == 6
replace M5 = 2 if interview__key == "81-93-32-28" & membres__id == 7
replace M5 = 1 if interview__key == "81-93-32-28" & membres__id == 8
replace M5 = 2 if interview__key == "23-42-93-82" & membres__id == 13
replace M5 = 1 if interview__key == "75-26-31-46" & membres__id == 6
replace M5 = 1 if interview__key == "96-32-35-09" & membres__id == 7
replace M5 = 1 if interview__key == "96-32-35-09" & membres__id == 10
replace M5 = 2 if interview__key == "96-32-35-09" & membres__id == 12
replace M5 = 2 if interview__key == "96-32-35-09" & membres__id == 13
replace M5 = 2 if interview__key == "64-76-20-08" & membres__id == 2
replace M5 = 1 if interview__key == "90-53-43-38" & membres__id == 5
replace M5 = 2 if interview__key == "88-97-35-85" & membres__id == 9
replace M5 = 2 if interview__key == "16-33-93-12" & membres__id == 6
replace M5 = 2 if interview__key == "16-33-93-12" & membres__id == 7
replace M5 = 2 if interview__key == "02-94-69-93" & membres__id == 5
replace M5 = 2 if interview__key == "57-11-50-32" & membres__id == 5
replace M5 = 1 if interview__key == "66-40-78-45" & membres__id == 2
replace M5 = 1 if interview__key == "51-96-44-89" & membres__id == 4
replace M5 = 2 if interview__key == "60-85-48-55" & membres__id == 3
replace M5 = 1 if interview__key == "87-37-71-24" & membres__id == 4
replace M5 = 2 if interview__key == "43-14-32-27" & membres__id == 5
replace M5 = 1 if interview__key == "79-56-62-07" & membres__id == 6
replace M5 = 2 if interview__key == "35-64-02-98" & membres__id == 1
replace M5 = 2 if interview__key == "34-31-34-15" & membres__id == 5
replace M5 = 1 if interview__key == "52-60-86-51" & membres__id == 13
replace M5 = 2 if interview__key == "65-36-15-11" & membres__id == 7
replace M5 = 2 if interview__key == "46-12-80-16" & membres__id == 5
replace M5 = 1 if interview__key == "30-97-84-47" & membres__id == 8
replace M5 = 1 if interview__key == "66-84-07-26" & membres__id == 3
replace M5 = 2 if interview__key == "15-06-79-55" & membres__id == 1
replace M5 = 1 if interview__key == "51-85-73-48" & membres__id == 3
replace M5 = 2 if interview__key == "51-85-73-48" & membres__id == 4
replace M5 = 2 if interview__key == "12-42-03-39" & membres__id == 6
replace M5 = 1 if interview__key == "94-91-47-68" & membres__id == 3
replace M5 = 1 if interview__key == "59-28-11-78" & membres__id == 7
replace M5 = 2 if interview__key == "59-28-11-78" & membres__id == 13
replace M5 = 2 if interview__key == "59-28-11-78" & membres__id == 14



count if !missing(M5) & Statut_Res== 0 // tous ceux qui ont repondu à la question M5 n'y avait pas le droit


*replace commentaire="tous ceux qui ont repondu à la question M5 n'y avait pas le droit car l'individu n'est pas resident" if !missing(M5) & Statut_Res== 0

*export excel interview__key HH2 HH12 HH13 M6_J membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_M5_nonresident" if !missing(M5) & Statut_Res== 0 , firstrow(varl) replace


**Pas de personnes pour qui la données sur le sexe est manquante

*drop if missing(M5) & Statut_Res==1 

// M6_J . Veuillez saisir le jour de naissance de %rostertitle% ?

count if missing(M6_J) & Statut_Res==1 // 37 personnes pour qui on a pas le  jour de naissance

replace commentaire="personnes pour qui on a pas le  jour de naissance" if missing(M6_J) & Statut_Res==1

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M6_J membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_jour_naiss" if missing(M6_J) & Statut_Res==1 , firstrow(varl) replace
**

count if !missing(M6_J) & Statut_Res== 0 // tous ceux qui ont repondu à la question y avait le droit

// M6_M. Mois de naissance de %rostertitle% ?

count if missing(M6_M) & Statut_Res==1 // 42 personnes pour qui on a pas le mois de naissance

replace commentaire="personnes pour qui on a pas le mois de naissance" if missing(M6_M) & Statut_Res==1

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M6_M membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_mois_naiss" if missing(M6_M) & Statut_Res==1 , firstrow(varl) replace
**

count if !missing(M6_M) & Statut_Res== 0 // tous ceux qui ont repondu à la question y avait le droit

// M6_A. Quelle est l'année de naissance de %rostertitle% ?

count if missing(M6_A) & Statut_Res==1 // 47 personnes pour qui on a pas l'année de naissance

replace commentaire="personnes pour qui on a pas l'année de naissance" if missing(M6_A) & Statut_Res==1


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M6_A membre_id_v1 V1MODINTR commentaire using "$folderpath/document/comp_menage_annee_naiss" if missing(M6_A) & Statut_Res==1 , firstrow(varl) replace



count if missing(M6_A) & Statut_Res==1 & membre_id_v1!="##N/A##" // 39 personnes pour qui on a pas l'année de naissance


count if !missing(M6_A) & Statut_Res== 0 // tous ceux qui ont repondu à la question y avait le droit

ta M6_A if Statut_Res==1


ta AgeAnnee if Statut_Res==1

* On constate qu'il a une valeur aberante qui vaut 112 pour interview__key =="10-08-99-68" & membres__id==1


replace AgeAnnee=2025-2007 if interview__key=="51-11-99-26" & membres__id==10
replace M6_A=2007 if interview__key=="51-11-99-26" & membres__id==10


replace AgeAnnee=2025-1987 if interview__key=="81-92-15-12" & membres__id==1
replace M6_A=1987 if interview__key=="81-92-15-12" & membres__id==1


replace AgeAnnee=0 if AgeAnnee==-9998





* On constate qu'il a des valeurs aberantes sur la variable AgeAnnee


//M7. Quel âge avait %rostertitle% à son dernier anniversaire?

count if missing(M7) & M6_A==9998 // 8 personnes pour qui on a pas l'age de naissance

br interview__key membres__id M6_A M7 AgeAnnee M4Confirm  if missing(M7) & M6_A==9998




count if missing(M7) & M6_A==.a // 47 personnes pour qui on a pas l'age et l'année de naissance sont non renseignées

count if missing(M7) & M6_A==9998 // 8 personnes pour qui on a pas l'age et l'année de naissance sont non renseignées


count if AgeAnnee==.a & Statut_Res==1 // 53 personnes pour qui on a pas l'age et l'année de naissance sont non renseignées : Tous des téléopérateurs

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

replace M7=2025-2007 if interview__key=="51-11-99-26" & membres__id==10
replace M7=2025-1987 if interview__key=="81-92-15-12" & membres__id==1


// AgeAnnee

count if missing(AgeAnnee) & Statut_Res == 1 // 53  personnes pour qui l'age est manquant

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

br interview__key  membres__id M6_A M6_J M6_M M7 AgeAnnee M4Confirm if AgeAnnee >99 & !missing(AgeAnnee)

br interview__key  membres__id M6_A M6_J M6_M M7 AgeAnnee M4Confirm if AgeAnnee <0

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

replace commentaire="individus pour qui la question M8 n'a pas été repondu" if missing(M8) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))

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

count if missing(M10) & M9 == 1 & membre_id_v1=="##N/A##" // 11 personnes pour qui la question n'a pas été repondu (1er passage) Ceci n'est pas imputable  

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

count if missing(M13) & M12 == 1 & membre_id_v1 == "##N/A##" // 14 personnes pour qui la question n'a pas été repondu. Ne peut être imputés

replace commentaire ="personnes pour qui la question n'a pas été repondu M13" if missing(M13) & M12 == 1 & membre_id_v1 == "##N/A##"
**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M12 M13 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_pere_qui" if missing(M13) & M12 == 1 & membre_id_v1 == "##N/A##", firstrow(varl) replace
**

// M14.Qui a la charge de %rostertitle% dans le ménage ?

count if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))) // 11 individus pour qui la question n'a pas été répondu.  Ne peut être imputés

replace commentaire="individus pour qui la question M14  n'a pas été répondu" if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8)))

**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M14 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_charge_qui" if missing(M14) & Statut_Res==1 & membre_id_v1== "##N/A##" & AgeAnnee < 18 & ((inlist(M4,3,4,7,8)| inlist(V1M4,3,4,7,8))), firstrow(varl) replace
**

// M15. %rostertitle% est-il né en Côte d'Ivoire ?

count if missing(M15) & Statut_Res==1 & membre_id_v1=="##N/A##" // 11 personnes pour qui la question n'a pas été répondu.  Ne peut être imputés

count if !missing(M15) & membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit

// M16. Quelle est la sous-préfecture ou la commune du lieu de naissance de %rostertitle% ?

count if missing(M16) & M15==1 & membre_id_v1 == "##N/A##" // 4 individu pour qui la question n'a pas été répondu. Ne peux être imputés 

replace commentaire="individu pour qui la question M16 n'a pas été répondu " if missing(M16) & M15==1 & membre_id_v1 == "##N/A##"

export excel interview__key HH2 HH12  HH13 M14 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/sous_prefecture_maissan" if missing(M16) & M15==1 & membre_id_v1 == "##N/A##" , firstrow(varl) replace



count if !missing(M16) & M15 ==2 // tous ceux qui ont repondu avaient le droit

// M18. Précisez le pays de naissance de %rostertitle%

count if missing(M18) & M15==2 // Tous ceux qui devaient repondre on répondu


count if !missing(M18) & M15==1 // tous ceux qui ont repondu avaient le droit

ta M18,miss // les pays mentionné sont vraisembable. Ce sont pour la plupart des pays ayant une forte diaspora en CIV 

// M19. Quelle est la nationalité de %rostertitle% ??

count if missing(M19) & Statut_Res==1 & membre_id_v1=="##N/A##" // 5 individu pour qui la question n'a pas de réponse. Ne peut être imputés

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

count if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##" // 13 individus pour qui la question n'a pas de réponse

replace commentaire="individu pour qui la question M22 n'a pas de réponse " if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##"


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M19 M21 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/comp_menage_charge_qui" if missing(M22) & Statut_Res==1 & membre_id_v1=="##N/A##" , firstrow(varl) replace




count if !missing(M22) &  membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit


// M22_Aut. Veuillez préciser ?

count if missing(M22_Aut) & M22 == 13 // 3  individus devant repondre main n'ont pas répondu


count if !missing(M22_Aut) &  M22 != 13 //RAS

br M22_Aut M22 if !missing(M22_Aut) &  M22 != 13 

// M23A. Quel est le statut matrimonial de %rostertitle% ?

count if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##" // 11 individu pour qui la question n'a pas été repondu. NE peux être imputes

replace commentaire="individu pour qui la question M23A(statut matrimonial) n'a pas de réponse " if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##" 


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M19 M21 membre_id_v1 V1MODINTR rgmen commentaire using "$folderpath/document/stattut_matrimonial"  if missing(M23A) & AgeAnnee >= 12 & Statut_Res==1 & membre_id_v1=="##N/A##"  , firstrow(varl) replace


count if !missing(M23A) & (AgeAnnee < 12 | Statut_Res==0 | membre_id_v1 != "##N/A##") // Tous les individus ayant répondu avaient le droit 

count if (AgeAnnee < 16 & M23A > 1 & !missing(M23A)) // 23 individu agés de moins de 15 et ne sont pas celibataire.

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
count if M23A == 4 & M23B__1 == 1 // Les personnes 


// M24A. %rostertitle% a-t-il/elle une assurance maladie ?

count if missing(M24A) & Statut_Res==1 & membre_id_v1=="##N/A##" // 16 individus pour qui la question n'a pas de réponse

br M5 AgeAnnee M19 M23B__1 M23B__2 M23B__3 M23B__9998 M24A if missing(M24A) & Statut_Res==1 & membre_id_v1=="##N/A##" // il s'agirait du meme individu que pour les variables précédente. Nous pensons judicieux de ne pas le supprimer vu que l'age et le sexe sont non manquant

count if !missing(M24A) &  membre_id_v1 != "##N/A##" // tous ceux qui ont repondu avaient le droit

// M24B. Si oui, qui a souscrit à l'assurance ?

count if missing(M24B) & M24A==1 &  membre_id_v1 == "##N/A##" // Tous les individus devant répondre ont répondu

count if !missing(M24B) & M24A==2  // Tous les individus devant répondre ont répondu

count if M24B==1 & AgeAnnee <14 // 347 enfants de moins de 14 ont une assurance personnelle. Nous estimons que cela est une erreur. IL SE POURRAIT QUE LES AGENTS N'AIT PAS BIEN COMPRIS LE SENS DE LA QUESTION A CE NIVEAU 

replace commentaire="enfants de moins de 13 ont une assurance personnelle " if M24B==1 & AgeAnnee <14 


**Exportation des individus potentiellement concernés

export excel interview__key HH2 HH12 HH13 M19 M21 membre_id_v1 V1MODINTR commentaire rgmen using "$folderpath/document/assurance_maladie"  if M24B==1 & AgeAnnee <14  , firstrow(varl) replace

*Etape de correction 
replace M24B=3 if M24B==1 & AgeAnnee <14


count if M24B== 2  & M23A == 1 // 1 personnes declarent avoir l'assurance des conjoints alors qu'elles sont déclaré célibataire.

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

count if M24C__1 == 1 & (M24B==2 | M24B == 3 ) // 1178 personnes ayant répondu possédér la CMU et que cette CMU était l'assurance des parents ou l'assurance du conjoint. Ce qui est une grosse incoherence



br M24C__1 M24B if M24C__1 == 1 & (M24B==2 | M24B == 3 )

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












