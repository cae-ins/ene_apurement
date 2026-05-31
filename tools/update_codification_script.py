import os

with open('program/Codification_T1_2026.do', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []

new_lines.append('*================================================\n')
new_lines.append('* Codification_T1_2026.do\n')
new_lines.append('* Appelé en fin de pipeline pour intégrer les codes et libellés\n')
new_lines.append('*================================================\n\n')

new_lines.append('use "$dataout_individu\\\\membres.dta", clear\n\n')

new_lines.append('* 1. Fusionner les codes CITP et pluriactivité préparés par 00-codification_brute.do\n')
new_lines.append('cap drop _merge\n')
new_lines.append('merge 1:1 interview__key membres__id using "$datatemp\\\\codif_emploi_principal.dta", keepus(code_citp_emp_principal)\n')
new_lines.append('drop if _merge == 2\n')
new_lines.append('cap drop _merge\n\n')

new_lines.append('merge 1:1 interview__key membres__id using "$datatemp\\\\codif_emploi_secondaire.dta", keepus(code_citp_emp_secondaire)\n')
new_lines.append('drop if _merge == 2\n')
new_lines.append('cap drop _merge\n\n')

new_lines.append('merge 1:1 interview__key membres__id using "$datatemp\\\\codif_pluriactivite.dta"\n')
new_lines.append('drop if _merge == 2\n')
new_lines.append('cap drop _merge\n\n')

new_lines.append('* 2. Création des variables branches à partir de CodeCIAPactivité\n')
new_lines.append('cap drop Code_1er\n')
new_lines.append('gen Code_1er=substr(CodeCIAPactivité,1,1)\n\n')

new_lines.append('cap drop branche2\n')
new_lines.append('gen branche2=99 if Code_1er != ""\n')
new_lines.append('replace branche2=1  if Code_1er=="A"\n')
new_lines.append('replace branche2=2  if inlist(Code_1er, "B", "C", "D", "E", "F")\n')
new_lines.append('replace branche2=3  if inlist(Code_1er, "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T")\n\n')

new_lines.append('lab var branche2 "Branche d\'activité 2"\n')
new_lines.append('cap label drop branche\n')
new_lines.append('label define branche 1 "Secteur primaire" 2 "Secteur secondaire" 3 "Secteur tertiaire" 99 "Non-classés"\n')
new_lines.append('label values branche2 branche\n\n')

new_lines.append('cap drop branche1\n')
new_lines.append('gen branche1=4 if Code_1er != ""\n')
new_lines.append('replace branche1=1  if Code_1er=="A"\n')
new_lines.append('replace branche1=2  if inlist(Code_1er, "B", "C")\n')
new_lines.append('replace branche1=3  if Code_1er=="G"\n\n')

new_lines.append('lab var branche1 "Branche d\'activité 1"\n')
new_lines.append('cap label drop branche1\n')
new_lines.append('label define branche1 1 "Agriculture" 2 "Industrie" 3 "Commerce" 4 "Autre service"\n')
new_lines.append('label values branche1 branche1\n\n')

new_lines.append('* 3. Application des labels de codification (CITP, etc.)\n')

for i in range(154, 6688):
    if 'destring code_citp_emp_principal,replace' in lines[i]:
        new_lines.append('cap destring code_citp_emp_principal, replace force\n')
        new_lines.append('cap destring code_citp_emp_secondaire, replace force\n')
        new_lines.append('cap destring pluriactivite1_codif, replace force\n')
        new_lines.append('cap destring pluriactivite2_codif, replace force\n')
        new_lines.append('cap destring pluriactivite3_codif, replace force\n')
        new_lines.append('cap destring pluriactivite4_codif, replace force\n')
        new_lines.append('cap destring pluriactivite5_codif, replace force\n')
    else:
        new_lines.append(lines[i])

new_lines.append('\n* 4. Sauvegarde finale\n')
new_lines.append('save "$dataout_individu\\\\membres.dta", replace\n')

with open('program/Codification_T1_2026.do', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print('Updated Codification_T1_2026.do')
