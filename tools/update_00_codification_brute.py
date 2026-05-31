import re

with open('program/00-codification_brute.do', 'r', encoding='utf-8') as f:
    codif_lines = f.readlines()

with open('program/Codification_T1_2026.do', 'r', encoding='utf-8') as f:
    old_codif_lines = f.readlines()

labels_and_branches = []

labels_and_branches.append('\n* ---- 5. Création des variables branches à partir de CodeCIAPactivité ----\n')
labels_and_branches.append('cap drop Code_1er\n')
labels_and_branches.append('gen Code_1er=substr(CodeCIAPactivité,1,1)\n\n')
labels_and_branches.append('cap drop branche2\n')
labels_and_branches.append('gen branche2=99 if Code_1er != ""\n')
labels_and_branches.append('replace branche2=1  if Code_1er=="A"\n')
labels_and_branches.append('replace branche2=2  if inlist(Code_1er, "B", "C", "D", "E", "F")\n')
labels_and_branches.append('replace branche2=3  if inlist(Code_1er, "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T")\n\n')
labels_and_branches.append('lab var branche2 "Branche d\'activité 2"\n')
labels_and_branches.append('cap label drop branche\n')
labels_and_branches.append('label define branche 1 "Secteur primaire" 2 "Secteur secondaire" 3 "Secteur tertiaire" 99 "Non-classés"\n')
labels_and_branches.append('label values branche2 branche\n\n')
labels_and_branches.append('cap drop branche1\n')
labels_and_branches.append('gen branche1=4 if Code_1er != ""\n')
labels_and_branches.append('replace branche1=1  if Code_1er=="A"\n')
labels_and_branches.append('replace branche1=2  if inlist(Code_1er, "B", "C")\n')
labels_and_branches.append('replace branche1=3  if Code_1er=="G"\n\n')
labels_and_branches.append('lab var branche1 "Branche d\'activité 1"\n')
labels_and_branches.append('cap label drop branche1\n')
labels_and_branches.append('label define branche1 1 "Agriculture" 2 "Industrie" 3 "Commerce" 4 "Autre service"\n')
labels_and_branches.append('label values branche1 branche1\n\n')

labels_and_branches.append('\n* ---- 6. Labels de la codification ----\n')
for i in range(48, 6590):
    if 'destring code_citp_emp_principal,replace' in old_codif_lines[i] or 'destring code_citp_emp_principal, replace force' in old_codif_lines[i]:
        labels_and_branches.append('cap destring code_citp_emp_principal, replace force\n')
        labels_and_branches.append('cap destring code_citp_emp_secondaire, replace force\n')
        labels_and_branches.append('cap destring pluriactivite1_codif, replace force\n')
        labels_and_branches.append('cap destring pluriactivite2_codif, replace force\n')
        labels_and_branches.append('cap destring pluriactivite3_codif, replace force\n')
        labels_and_branches.append('cap destring pluriactivite4_codif, replace force\n')
        labels_and_branches.append('cap destring pluriactivite5_codif, replace force\n')
    else:
        labels_and_branches.append(old_codif_lines[i])

final_lines = []
for line in codif_lines:
    if line.strip() == 'save_brute_membres_safe':
        final_lines.extend(labels_and_branches)
        final_lines.append('\n')
    final_lines.append(line)

with open('program/00-codification_brute.do', 'w', encoding='utf-8') as f:
    f.writelines(final_lines)
print('Updated 00-codification_brute.do')
