
*********EMPLOI SECONDAIRE(ES) 

****RESPONSABLE: RENAUD HIVITES AKATTIA(PECHOUX )
*=============================================

use "$datain_standard\INDIV_S6_emploi_secondaire.dta", clear
cap drop _merge
merge m:1 interview__key using "$brute_menage_work", keepusing(HH2 HH3 HH4 HH12 HH13 HH3 annee)
drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$standard_individu\INDIV_S5_pluriactivite.dta", keepus(PL3)

drop if _merge!=3
cap drop _merge

* Normaliser uniquement les textes de la section ES.
* membre_id_v1_IND conserve sa sentinelle ##N/A## pour le filtre d'eligibilite.
ds ES*, has(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = ustrregexra(`var', "\s+$", "")
	replace `var' = strltrim(`var')
	replace `var' = "" if `var' == "##N/A##"
}

local eligible_es PL3 >= 1 & M4Confirm >= 15 & membre_id_v1_IND == "##N/A##" & !missing(PL3, M4Confirm)

*===========================
*ES1a. Quel est l’intitulé de votre poste ou quel type de travail avez-vous effectué pendant la semaine de reference dans le cadre de votre emploi secondaire (ou que vous avez l'habitude ’'exercer’’) ?
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES1a) & (`eligible_es')
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES1a) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES1b.Quelles sont vos principales tâches et fonctions dans votre emploi/activité secondaire ? (brève description des tâches et fonctions)
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES1b) & (`eligible_es')
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES1b) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*==================================
*ES1b1.Choisissez le code correspondant au poste de l’enquêté 
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES1b1) & (`eligible_es')

**Correction: elle necessite de revenir aux agents

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES1b1) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2a. Au cours de la période allant de %DateJ7% au %DateJ0% , quel était le domaine d'activité de l'entreprise dans laquelle vous travaillez dans le cadre de votre emploi secondaire
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES2a) & (`eligible_es')
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2a) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2b. Quels sont les principaux produits ou services réalisés dans l’entreprise dans laquelle vous travaillez (ou dans vos fonctions principales) dans votre emploi/activité secondaire ?
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES2b) & (`eligible_es')
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2b) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2b1. Choisissez le code correspondant aux produits ?
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES2b1) & (`eligible_es')

**Toute la section est vide pour cet individus

*drop if interview__key == "18-52-60-79" & interview__id == "6671768cf87c4277a4d6c1bfdd185ddd" & membres__id==1


*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2b1) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2c. Est-ce que l’unité de production, l’endroit où l’entreprise dans laquelle vous exercez votre emploi/activité secondaire à un nom ?
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES2c) & (`eligible_es')
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2c) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES2c,1,3)& !missing(ES2c)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2d Quel est le nom du lieu ou de l’entreprise où vous exercez votre emploi/activité secondaire ?
*==================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
count if missing(ES2d) & ES2c==1
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2d) & ES2c!=1

*RAS

*Problem 3: les valeurs renseignées sont elles permises

*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2e. Le lieu de travail votre emploi/activité secondaire se trouve-t-il dans votre commune/sous-préfecture de résidence ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES2e) & (`eligible_es')
*RAS
 



*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2e) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES2e,1,2)& !missing(ES2e)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2f. Dans quelle sous-préfecture est située le lieu de travail de votre emploi/activité secondaire ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES2f) & ES2e==2
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2f) & ES2e!=2
*RAS

*Problem 3: les valeurs renseignées sont elles permises

*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES2f_loc. Dans quelle sous-préfecture est située le lieu de travail de votre emploi/activité secondaire ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES2f_loc) & ES2e==2
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2f_loc) & ES2e!=2
*RAS

*Problem 3: les valeurs renseignées sont elles permises

*RAS

*Problem 4: Vraisemblance des reponses
*RAS



*===========================
*ES2g. L'unité de production dans laquelle vous exercez votre emploi secondaire (ou que vous dirigez) est-elle une :
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES2g) & (`eligible_es')
*22
*proposition de correction 
* br ES1a ES1b ES2g if missing(ES2g) & (`eligible_es') // toutes la section semble etre manquante 

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES2g) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES2g,1,8) & !missing(ES2g)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS
* 
* br ES1a ES1b ES2g if !inlist(ES2g,.,.a) // on observe la coherence entre le type de l'entreprise et les taches effectués

replace ES2g = 4 if ES1b == "SEMER ENTRETIEN RECOLTER VENDRE" 
replace ES2g = 4 if ES1b == "PÊCHE ARTISANALE"
replace ES2g = 2 if ES2d == "ANADER"
replace ES2g = 4 if ES1b == "ELEVER ET VENDRE DES OVINS"
replace ES2g = 3 if ES1b == "MONTER MUR"
replace ES2g = 3 if ES1b == "ACHAT DE PRODUITS AGRICOLE"
replace ES2g = 4 if ES1a == "CULTIVATRICE DE HARICOT"
replace ES2g = 3 if ES1b == "ACHAT DE PRODUITS AGRICOLE"
replace ES2g = 3 if ES1b == "ACHAT DE PRODUITS AGRICOLE"
replace ES2g = 3 if ES1b == "VENTE DE BOISSONS"
replace ES2g = 3 if ES1b == "PREPARE ET VENDRE"
replace ES2g = 4 if ES1b == "ELEVER ET VENDRE DES POULETS"
replace ES2g = 3 if ES1b == "ACHETER ET REVENDRE"
replace ES2g = 4 if ES1b == "NOURRIR ET ENTRETENIR LES SUJETS"
replace ES2g = 3 if ES1b == "FAIRE CONGELER L'EAU ET VENDRE AUX CLIENTS"
replace ES2g = 4 if ES1b == "CULTUVER L'IGNAME ET LA BANANE"
replace ES2g = 4 if ES1a == "AGRICULTEUR DE CACAO"
replace ES2g = 4 if ES1b == "SUIVIS ET ENTRETIEN DU CHAMP"


*===========================
*ES3. L’unité économique que vous dirigez ou dans laquelle vous travaillez est-elle érigée est société ou a-t-elle une existence légale ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES3) & inlist(ES2g,3,4,6,7)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES3) & !inlist(ES2g,3,4,6,7)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES3,1,2,9998) & !missing(ES3)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES4. La production de biens ou services de votre entreprise est-elle destinée : Principalement à la vente Partiellement à la vente Pas à la vente
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES4) & inlist(ES2g,3,4,6,7)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES4) & !inlist(ES2g,3,4,6,7)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES4,1,3) & !missing(ES4)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=======================================
*ES4_2. Indiquez la forme principale de revenus parmi celles que vous avez citées ?
*======================================

*Problem 1: Ceux qui devaient repondre ont ils repondus 
foreach var of varlist ES4_2__1-ES4_2__12{
	count if missing(`var') & (`eligible_es')
}

*Problem 2: Ceux qui ont repondus devaient ils repondre 
foreach var of varlist ES4_2__1-ES4_2__12{
	count if !missing(`var') & !(`eligible_es')
}
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
foreach var of varlist ES4_2__1-ES4_2__12{
	count if !inrange(`var',0,1) & !missing(`var')
}
*RAS

*Problem 4: Vraisemblance des reponses 
*Un individu ne peut etre non payé et percevoir un salaire en meme temps 
count if ES4_2__1==1 & ES4_2__10==1
*RAS 
count if ES4_2__2==1 & ES4_2__10==1
*RAS
count if ES4_2__6==1 & ES4_2__10==1
*RAS




* Retirer les variables ajoutees avant de recharger la section pour la suite des controles.
drop HH2 HH3 HH4 annee HH12 HH13 M4Confirm membre_id_v1 membre_id_v1_IND PL3

save "$datain_standard\INDIV_S6_emploi_secondaire.dta", replace


use "$datain_brute\Revenu_es.dta" , clear

cap drop _merge

merge m:1 interview__key membres__id using "$datain_brute\membres.dta", keepus(ES4_2__7 ES4_2__9 ES4_2__10 CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)

keep if _merge == 3

cap drop _merge

merge m:1 interview__key using "$brute_menage_work" , keepus(HH13 HH2)

keep if _merge == 3

cap drop _merge

* Le roster des revenus est charge separement : normaliser aussi ses textes ES.
ds ES*, has(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = ustrregexra(`var', "\s+$", "")
	replace `var' = strltrim(`var')
	replace `var' = "" if `var' == "##N/A##"
}

*============================
*ES4_3.Aquellefréquencepercevez-vous votrerémunérationPRINCIPALEpour votreemploi secondaire?
*==============================
local eligible_es43 ES4_2__7 != 1 & ES4_2__10 != 1

*Problem 1: Ceux qui ont repondus devaient ils repondre 
count if missing(ES4_3) & (`eligible_es43')
*RAS



*Problem 2: ceux qui ont repondus devaient ils repondre 
count if !missing(ES4_3) & !(`eligible_es43')



*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 ES4_3 using "$folderpath/document/Erreur_L1_NA" if !missing(ES4_3) & (ES4_2__7==0|  ES4_2__10==0), firstrow(varlabels) replace 

*Problem 3: les valeurs renseignées sont elles permises 
count if !inrange(ES4_3,1,10)& !missing(ES4_3)

*Vraisemblance des reponses : RAS 


*==================================
*ES4_3B.combiende %ES4_3% %label_ES4_3% percevez-vous votrerémunérationPRINCIPALEpour votreemploi secondaire?
*================================
*Problem 1: Ceux qui ont repondus devaient ils repondre 
count if missing(ES4_3B) & ES4_3<8
*RAS

*Problem 2: ceux qui ont repondus devaient ils repondre 
count if !missing(ES4_3B) & !(ES4_3<8)
  
*Identification des agents ayant fait des erreurs 
if r(N) > 0 {
export excel interview__key HH13 ES4_3B using "$folderpath/document/Erreur_L1_NA" if !missing(ES4_3B) & ES4_3>=8 & !missing(ES4_3B), firstrow(varlabels) replace 
}


*Correction
*replace ES4_3B=. if !missing(ES4_3B) & ES4_3>=8 

*Problem 3: les valeurs renseignées sont elles permises 
count if ES4_3B<=0
*RAS

*Vraisemblance des reponses :
count if ES4_3==1 & ES4_3B>7 & !missing(ES4_3B) // Sachant que le revenu est journalier, il ne peut exceder 7 sur une semaine 
count if ES4_3==2 & ES4_3B>4 & !missing(ES4_3B) // Sachant que le revenu est hebdomadaire, il ne peut exceder 4 sur un mois 

count if ES4_3==3 & ES4_3B>2 & !missing(ES4_3B) // Sachant que le revenu est percu par quinzaine, il ne peut exceder 2 sur un mois 
count if ES4_3==4 & ES4_3B>12 & !missing(ES4_3B) // Sachant que le revenu est mensuel, il ne peut exceder 12 sur une année
count if ES4_3==5 & ES4_3B>6 & !missing(ES4_3B) // Sachant que le revenu est BIMENSUEL, il ne peut exceder 6 sur une année 
count if ES4_3==6 & ES4_3B>4 & !missing(ES4_3B) // Sachant que le revenu est trimestriel, il ne peut exceder 4 sur une année
count if ES4_3==7 & ES4_3B>2 & !missing(ES4_3B) // Sachant que le revenu est semestriel, il ne peut exceder 2 sur une année
count if ES4_3==8 & ES4_3B>1 & !missing(ES4_3B) // Sachant que le revenu est annuel, il ne peut exceder 1 sur une année



*==============================
*ES4_4.Par %ES4_3% ,quelest le montantdecepaiement tirédevotreemploi secondaire?
*===========================
local eligible_es44 inlist(ES4_3,1,2,3,4,5,6,7,8,9) & ES4_2__7 != 1 & ES4_2__9 != 1

*Problem 1: ceux qui ont repondu devaient ils repondre 
count if missing(ES4_4) & (`eligible_es44')


*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if !missing(ES4_4) & !(`eligible_es44')
*RAS
*Problem 3: Les valeurs renseignées sont elles permises 
*Les valeurs renseignées ne peuvent etre negatives 
count if ES4_4<0
*RAS
*Les valeurs renseignées doivent depasser 100
count if ES4_4<100

*on corrige avec la valeur en lettre 
* br ES4_4 ES4_5 if ES4_4<100 // la valeur en lettre n'est pas non claire

*Correction confirmee a partir du montant renseigne en lettres
replace ES4_4 = 60000 if interview__key == "16-85-77-85" & membres__id == 2 & ES4_4 == 60 & ES4_5 == "SOIXANTE MILLE FRANCS CFA"


*Identification des agents ayant encore des montants inferieurs a 100
count if ES4_4<100
if r(N) > 0 {
export excel interview__key membres__id HH13 ES4_4 ES4_5 using "$folderpath/document/Erreur_RHE1_4_COH" if ES4_4<100, firstrow(varlabels) replace 
}
*Correction
*Les revenus  sont en general des multiples de  1000. Par ailleurs en jettant un coup d'oeil sur les revenus en lettres, il vient que ses valeurs 10 et 24,500 et 200 sont bien renseignées en milles 
/*
replace ES4_4=10000 if ES4_4==10
replace ES4_4=34000 if ES4_4==24
replace ES4_4=5000 if ES4_5=="CINQ MILLE  FRAN CFA" & ES4_4==500
replace ES4_4=2000 if ES4_4==200
*/
*Probem 4: Vraisemblance des reponses 
*RAS 

*============================
*ES4_5. Ecrire le montant en toute lettre (FCFA)
*========================

*Problem 1 : Ceux qui devaient repondre ont ils repondu 
count if !missing(ES4_4)& !inlist(ES4_4,99999999,99999998) & missing(ES4_5)
*RAS

*Problem 2: Ceux qui ont repondu devaient ils repondre 
count if (missing(ES4_4)| inlist(ES4_4,99999999,99999998)) & !missing(ES4_5)
*RAS

*Problem 3: Les valeurs renseignées sont elles permises 
*RAS

*Problem 4: Vraisembalnce des reponses 
*l'on regarde la vraisemblance entre les valeurs en lettres et les valeurs en chiffres et effectuons les corrections necessaire
* 
* br ES4_4 ES4_5 if !missing(ES4_4) & ES4_4 !=99999999 & ES4_4 !=99999998

replace ES4_4 = 150000 if ES4_5 == "CENT CINQUANTE MILLES"




*==========================
*ES4_6. Pouvez-vous tout de même nous indiquer dans quelle tranche de remunération vous vous situez
*===================================
local eligible_es46 inlist(ES4_4,99999998,99999999) | ES4_3 == 10

*Problem 1:Ceux qui devaient repondre ont ils repondus 
count if (`eligible_es46') & missing(ES4_6)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !(`eligible_es46') & !missing(ES4_6)
*RAS

*Identification des agents ayant fait des erreurs 
if r(N) > 0 {
export excel interview__key HH13 ES4_3 ES4_4 ES4_6 using "$folderpath/document/Erreur_ES4_6_COH" if !(`eligible_es46') & !missing(ES4_6), firstrow(varlabels) replace 
}
*Correction
*replace ES4_6=. if (ES4_4!=99999998 & ES4_4!=99999999 & ES4_3!=10) & !missing(ES4_6)


*Problem 3 : Les valeurs renseignées sont elles permises 
*RAS

*Problem 4 : Vraisemblance des reponses  
*RAS

drop ES4_2__7 ES4_2__9 ES4_2__10 HH2 HH13
save "$dataout\Revenu_es.dta" , replace

use "$datain_standard\INDIV_S6_emploi_secondaire.dta", clear
cap drop _merge
merge m:1 interview__key using "$brute_menage_work", keepusing(HH2 HH3 HH4 HH12 HH13 HH3 annee)
drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_standard\INDIV_S1_autres_formes_travail.dta", keepus(M4Confirm)

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$datain_brute\membres.dta", keepus(membre_id_v1 membre_id_v1_IND CodeCIAPactivité code_citp_emp_principal code_citp_emp_secondaire)

drop if _merge!=3
cap drop _merge

merge 1:1 interview__key membres__id  using "$standard_individu\INDIV_S5_pluriactivite.dta", keepus(PL3)

drop if _merge!=3
cap drop _merge



*===========================
*ES5. L'unité de production dans laquelle vous exercez votre emploi secondaire (ou que vous dirigez) a-t-elle un numéro de compte contribuable (DGI) ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES5) & inlist(ES2g,3,4,6,7)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES5) & !inlist(ES2g,3,4,6,7)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES5,1,2,9998) & !missing(ES5)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES6. L'unité de production dans laquelle vous exercez votre emploi secondaire (ou que vous dirigez) est-t-elle immatriculée au registre de commerce ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES6) & inlist(ES2g,3,4,6,7)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES6) & !inlist(ES2g,3,4,6,7)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES6,1,2,9998) & !missing(ES6)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES7. L'unité de production dans laquelle vous exercez votre emploi secondaire (ou que vous dirigez) est-elle immatriculée à la CNPS 
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES7) & inlist(ES2g,3,4,6,7)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES7) & !inlist(ES2g,3,4,6,7)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES7,1,2,9998) & !missing(ES7)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES8. Votre unité de production dispose-t-elle d’une déclaration fiscale d’existence (DFE) ou un numéro de la DGI ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES8) & inlist(ES2g,3,4,6,7)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES8) & !inlist(ES2g,3,4,6,7)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES8,1,2,9998) & !missing(ES8)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES9_Aut. Veuillez préciser l'Autre système comptable
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES9) & inlist(ES2g,3,4,6,7)
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES9) & !inlist(ES2g,3,4,6,7)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES9,1,2,3,4,5,9998) & !missing(ES9)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES9. Sous quel système votre comptabilité est-elle tenue ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES9_Aut) & ES9==4
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES9_Aut) & ES9 != 4
*RAS

*Problem 3: les valeurs renseignées sont elles permises

*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES10. Dans quel type de local exercez-vous votre emploi secondaire ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES10) & inlist(ES2g,3,4,6,7)
*proposition de correction 
* 
* br ES1a ES1b ES2g ES10 if missing(ES10) & inlist(ES2g,3,4,6,7)

replace ES10 = 1 if missing(ES10) & inlist(ES2g,3,4,6,7) & ES2g == 4 & ES1b=="TOUS TYPES DE TRAVEAUX"
*replace ES10 = 9 if ES1b == "VENTE DE BOISSONS"
*replace ES10 = 5 if ES1a == "MAÇON"


*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES10) & !inlist(ES2g,3,4,6,7)
*proposition de correction
* br ES1a ES1b ES2g ES10 if !missing(ES10) & !inlist(ES2g,3,4,6,7)
replace ES10 = . if !missing(ES10) & !inlist(ES2g,3,4,6,7)

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES10,1,13) & !missing(ES10)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS
* 
* br ES1a ES1b ES2g ES10 if !missing(ES10)

*===========================
*ES10_Aut. Veuillez préciser l'Autre système comptable
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES10_Aut) & ES10==13
*Correction necessite de revenir aux agents



*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES10_Aut) & ES10!=13
*2 individus sont concernés

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 ES10_Aut  using "$folderpath/document/Erreur_ES10_NA" if !missing(ES10_Aut) & ES10!=13, firstrow(varlabels) replace 

*Correction 
*replace ES10_Aut="" if !missing(ES10_Aut) & ES10!=13

*Problem 3: les valeurs renseignées sont elles permises

*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*===========================
*ES10_1. Quel est votre statut d'emploi secondaire ?
*==================================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES10_1) & (`eligible_es')
*RAS
* 
* br ES1a ES1b ES2g ES10 ES10_1 if missing(ES10_1) & (`eligible_es') // impossible de faire la correction car toutes les autres informations sont manquantes 

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES10_1) & !(`eligible_es')
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES10_1,1,10) & !missing(ES10_1)
*RAS


*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*nous faisons un check rapide pour les personnes ayant declaré administration public. Certains individus ne sont en réalité pas dans une administration publique ICICICIC
* 
* br ES1a ES1b ES2g  ES10_1 if ES2g==1 // RAS

*les personnes à leurs propre compte ne peuvent pas etre dans une administration publique ou parapublique, une organisation internationale, un ménage etc
* 
* br ES1a ES1b ES2g  ES10_1 if ES10_1==3 & (ES2g== 1 |ES2g== 2 | ES2g== 5 | ES2g== 8 ) // RAS

*=============================
*ES10_1_Aut.Veuillezpréciser l'Autresystèmecomptable
*======================
*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES10_1_Aut) & ES10_1==10
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES10_1_Aut) & ES10_1!=10
*3 individus ont été identifié

*Identification des agents ayant fait des erreurs 
*export excel interview__key HH13 ES10_1_Aut using "$folderpath/document/Erreur_ES10_1Aut_coh" if !missing(ES10_1_Aut) & ES10_1!=10, firstrow(varlabels) replace 

*Correcion
*replace ES10_1_Aut="" if !missing(ES10_1_Aut) & ES10_1!=10

*Problem 3: les valeurs renseignées sont elles permises

*RAS


*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES10_2. Quiprendhabituellement lesdécisionsconcernantlagestiondelentreprisefamiliale?
*======================
*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES10_2) & ES10_1==5
*RAS

*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES10_2) & ES10_1!=5
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES10_2,1,4) & !missing(ES10_2)

*RAS


*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES11.Pouvez-vous fixer leprixdesproduitsouservicesquevousoffrez ?
*======================
*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES11) & inlist(ES10_1,2,3,4)
*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES11) & !inlist(ES10_1,2,3,4)
*RAS

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES11,1,2) & !missing(ES11)

*RAS


*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES12. La famille peut elle fixer les prix des produits offerts par l'entreprise 
*======================
*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES12) & inlist(ES10_2,1,2) & ES10_1 == 5 
*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES12) & !(inlist(ES10_2,1,2) & ES10_1 == 5) 

*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES12,1,2) & !missing(ES12)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES13.Pourquoivousnepouvez-vouspas fixer leprix?
*======================
*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES13) & ES11==2
*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES13) & ES11!=2
*RAS


*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES13,1,5) & !missing(ES13)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES14Pourquoi lafamillenepouvez-vouspas fixer leprix?
*======================
*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES14) & ES12==2
*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 
count if !missing(ES14) & ES12!=2
*COrrection: imputation
*replace ES14=. if !missing(ES14) & ES12!=2


*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES14,1,5) & !missing(ES14)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES15.Etes-vous déclaré à la CNPS ou  à la CGRAE (fonctionnaires)? 
*=============================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES15) & inlist(ES10_1,1,8,9) // Stagiaires, salariés et apprenti

count if missing(ES15) & inlist(ES10_1,5) & (ES4_2__2==1 | ES4_2__3==1 |ES4_2__6==1 & ES4_2__5==1 | ES4_2__9==1) // Travailleurs familiaux percevant un salaire 

*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 

*count if !missing(ES15) & !inlist(ES10_1,1,8,9)

*Cette question est detinée aux Stagiaires, salariés, apprenti et Travailleurs familiaux percevant un salaire . Par aillaurs des individus n'étant pas dans cette tranche ont repondu à la question 



count if !missing(ES15) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0)
*Cette categrorie concerne les travailleurs familiaux qui ne percoivent aucune forme de salaire. Ceux ci ne sont pas eligibles pour repondre à la question mais l'ont quand meme fait. 

*Identification des agents ayant fait des erreurs 
if r(N) > 0 {
export excel interview__key HH13 ES15 using "$folderpath/document/Erreur_ES15_coh2" if !missing(ES15) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0), firstrow(varlabels) replace 
}
*replace ES15=. if !missing(ES15) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0)


*Problem 3: les valeurs renseignées sont elles permises
count if !inrange(ES15,1,2) & !missing(ES15)
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES16.Bénéficiez-vous de congés annuels payés ou des vacances ? 
*=============================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES16) & inlist(ES10_1,1,8,9) // Stagiaires, salariés et apprenti

count if missing(ES16) & inlist(ES10_1,5) & (ES4_2__2==1 | ES4_2__3==1 |ES4_2__6==1 & ES4_2__5==1 | ES4_2__9==1) // Travailleurs familiaux percevant un salaire 

*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 

count if !missing(ES16) & !inlist(ES10_1,1,8,9)
* 454 individus sont concernés: tous les individus repondre finalement à cette question. Il semblerait que une décision a été prise pour ne pas les exclus dans le questionnaire contrairement à ce qui est indicateurs en commentaire dans le questionnaire

*Identification des agents ayant fait des erreurs
if r(N) > 0 {
export excel interview__key  ES16 using "$folderpath/document/Erreur_ES16_coh1" if !missing(ES16) & !inlist(ES10_1,1,8,9,5), firstrow(varlabels) replace 
}

*Correction 
*replace ES16=. if !missing(ES16) & !inlist(ES10_1,1,8,9)

count if !missing(ES16) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0)
*39 individus sont concernés 

*Identification des agents ayant fait des erreurs 
if r(N) > 0 {
export excel interview__key HH13  ES16 using "$folderpath/document/Erreur_ES16_coh2" if !missing(ES16) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0), firstrow(varlabels) replace 
}
*replace ES16=. if !missing(ES16) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0)


*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES16,1,2,9998) & !missing(ES16) 
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES17.Bénéficiez-vousdecongés maladiepayésencasde maladieoudeblessures ? 
*=============================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES17) & inlist(ES10_1,1,8,9) // Stagiaires, salariés et apprenti

count if missing(ES17) & inlist(ES10_1,5) & (ES4_2__2==1 | ES4_2__3==1 |ES4_2__6==1 & ES4_2__5==1 | ES4_2__9==1) // Travailleurs familiaux percevant un salaire 

*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 
*
*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES17,1,2,9998) & !missing(ES17) 
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES18.Bénéficiez-vousdePrimes ?
*=============================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES18) & inlist(ES10_1,1,8,9) // Stagiaires, salariés et apprenti

count if missing(ES18) & inlist(ES10_1,5) & (ES4_2__2==1 | ES4_2__3==1 |ES4_2__6==1 & ES4_2__5==1 | ES4_2__9==1) // Travailleurs familiaux percevant un salaire 

*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 


*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES18,1,2,9998) & !missing(ES18) 
*RAS

*Problem 4: Vraisemblance des reponses
*RAS

*=============================
*ES19.Bénéficiez-vousdeService médicalparticulier ?
*=============================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES19) & inlist(ES10_1,1,8,9) // Stagiaires, salariés et apprenti

count if missing(ES19) & inlist(ES10_1,5) & (ES4_2__2==1 | ES4_2__3==1 |ES4_2__6==1 & ES4_2__5==1 | ES4_2__9==1) // Travailleurs familiaux percevant un salaire 

*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 

/*count if !missing(ES19) & inlist(ES10_1,2,3,4,6,10)
* 485 individus sont concernés  

*Identification des agents ayant fait des erreurs
if r(N) > 0 {
export excel interview__key HH13 ES19 using "$folderpath/document/Erreur_ES18_coh1" if !missing(ES19) & !inlist(ES10_1,1,8,9,5), firstrow(varlabels) replace 
}
*/

*Correction 
*replace ES19=. if !missing(ES19) & !inlist(ES10_1,1,8,9,5)


*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES19,1,2,9998) & !missing(ES19) 
*RAS

*Problem 4: Vraisemblance des reponses
*RAS


*=============================
*ES20.Bénéficiez-vous d’une assurance maladie fournie par l’entreprise?
*=============================

*Problem 1: ceux qui devaient repondre ont ils repondus 
count if missing(ES20) & inlist(ES10_1,1,8,9) // Stagiaires, salariés et apprenti

count if missing(ES20) & inlist(ES10_1,5) & (ES4_2__2==1 | ES4_2__3==1 |ES4_2__6==1 & ES4_2__5==1 | ES4_2__9==1) // Travailleurs familiaux percevant un salaire 

*RAS
*Problem 2: Ceux qui ont repondus devaient ils repondre 

count if !missing(ES20) & inlist(ES10_1,2,3,4,6,10)
* 485 individus sont concernés : tous les individus repondre finalement à cette question. Il semblerait que une décision a été prise pour ne pas les exclus dans le questionnaire contrairement à ce qui est indicateurs en commentaire dans le questionnaire 

*Identification des agents ayant fait des erreurs
if r(N) > 0 {
export excel interview__key HH13 ES20 using "$folderpath/document/Erreur_ES20_coh1" if !missing(ES20) & !inlist(ES10_1,1,8,9,5), firstrow(varlabels) replace 
}

*Correction 
*replace ES20=. if !missing(ES20) & !inlist(ES10_1,1,8,9,5)
/*
count if !missing(ES20) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0)
*39 individus sont concernés 

*Identification des agents ayant fait des erreurs
if r(N) > 0 { 
export excel interview__key HH13 ES20 using "$folderpath/document/Erreur_ES20_coh2" if !missing(ES20) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0), firstrow(varlabels) replace 
}
*replace ES20=. if !missing(ES20) & inlist(ES10_1,5) & (ES4_2__2==0 & ES4_2__3==0 & ES4_2__6==0 & ES4_2__5==0 & ES4_2__9==0)

*/

*Problem 3: les valeurs renseignées sont elles permises
count if !inlist(ES20,1,2,9998) & !missing(ES20) 
*RAS

*Problem 4: Vraisemblance des reponses
*RAS


drop HH2 HH3 HH4 annee HH12 HH13 M4Confirm membre_id_v1_IND PL3

save "$standard_individu\INDIV_S6_emploi_secondaire.dta", replace
