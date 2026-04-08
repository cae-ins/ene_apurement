use "$datain_brute\membres.dta", clear
/*
cap drop PAT
gen PAT= (M4Confirm>=15 & !missing(M4Confirm))
keep if PAT==1 

***   EMPLOI   ***
cap drop classement_emploi
gen classement_emploi = 1 if PAT==1

replace classement_emploi = 0 if SE1==. & SE2==. & SE3==. & SE4==. & SE5==. & SE7==. & SE8==. & SE9==. & SE9A==. & SE9B==. & SE10==. & SE11==. & PAT==1 // si toutes les variables sont vides, supprimer


*replace classement_emploi = 0 if SE1!=. | SE2!=. | SE3!=. | SE4!=. | SE5!=. | SE7!=. | SE8!=. | SE9!=. | SE9A!=. | SE9B!=. | SE10!=. | SE11!=.

lab define classement_emploi_lbl 1 "Classable" 0 "Inclassable"
label values classement_emploi classement_emploi_lbl

ta classement_emploi,m


***   CHOMAGE   ***
cap drop classement_chomage
gen classement_chomage = 1  if PAT==1

replace classement_chomage = 0 if SRH1==. & SRH2==. & SRH2A==. & SRH11==. & PAT==1 // si toutes les variables sont vides mais les SE sont non-vides

lab define classement_chomage_lbl 1 "Classable" 0 "Inclassable"
label values classement_chomage classement_chomage_lbl

ta classement_chomage


***   HORS MAIN D'OEUVRE   ***

cap drop hors_main_doeuvre
gen hors_main_doeuvre = 1 if PAT==1

replace hors_main_doeuvre = 0 if classement_emploi == 0 | classement_chomage == 0
*replace hors_main_doeuvre = 0 if SRH1 == . | SRH11 == .


cap drop a_supprimer
gen a_supprimer = 1 if PAT!=1 | (PAT==1 & classement_emploi==0) | (classement_emploi==0 & classement_chomage==0)
*/
/*
cap drop tag*
gen tag1 = 1 if M5==. | M5==.a
gen tag2 =1 if AgeAnnee ==. | AgeAnnee ==.a | AgeAnnee == 9898
gen tag = 0 if tag1 ==1 | tag2 == 1
replace tag = 1 if tag ==.
drop if tag==0
*/
drop if missing(M4Confirm) & AgeAnnee >= 15 & !missing(AgeAnnee)

save "$datain_brute\membres.dta", replace 