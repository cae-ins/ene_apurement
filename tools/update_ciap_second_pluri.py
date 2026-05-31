import os

with open('program/00-codification_brute.do', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.strip() == 'cap drop CodeCIAPactivitÃ©' or line.strip() == 'cap drop CodeCIAPactivité':
        # Insert the secondary and pluriactivity CIAP merges here
        new_lines.append('* ---- 3b. CIAP Emploi secondaire ----\n')
        new_lines.append('preserve\n')
        new_lines.append('    import excel "$codification\\\\Activite_secondaire_T126.xlsx", sheet("Feuil1") firstrow clear\n')
        new_lines.append('    cap rename Codeactivité CodeCIAPactivite_sec\n')
        new_lines.append('    cap rename CodeactivitÃ© CodeCIAPactivite_sec\n') # handle encoding
        new_lines.append('    keep interview__key membres__id CodeCIAPactivite_sec\n')
        new_lines.append('    destring membres__id, replace force\n')
        new_lines.append('    drop if missing(interview__key)\n')
        new_lines.append('    save "$datatemp\\\\codif_ciap_secondaire.dta", replace\n')
        new_lines.append('restore\n')
        new_lines.append('cap drop CodeCIAPactivite_sec\n')
        new_lines.append('cap drop _merge\n')
        new_lines.append('merge 1:1 interview__key membres__id using "$datatemp\\\\codif_ciap_secondaire.dta", keepus(CodeCIAPactivite_sec)\n')
        new_lines.append('drop if _merge == 2\n')
        new_lines.append('cap drop _merge\n\n')

        new_lines.append('* ---- 3c. CIAP Pluriactivité ----\n')
        new_lines.append('preserve\n')
        new_lines.append('    import excel "$codification\\\\Pluriactivite_AllT126.xls", sheet("Sheet1") firstrow clear\n')
        new_lines.append('    cap rename Code CodeCIAPactivite_pluri\n')
        new_lines.append('    keep interview__key membres__id r_activite_s__id CodeCIAPactivite_pluri\n')
        new_lines.append('    destring membres__id, replace force\n')
        new_lines.append('    drop if missing(interview__key)\n')
        new_lines.append('    reshape wide CodeCIAPactivite_pluri, i(interview__key membres__id) j(r_activite_s__id)\n')
        new_lines.append('    save "$datatemp\\\\codif_ciap_pluri.dta", replace\n')
        new_lines.append('restore\n')
        new_lines.append('cap drop CodeCIAPactivite_pluri*\n')
        new_lines.append('cap drop _merge\n')
        new_lines.append('merge 1:1 interview__key membres__id using "$datatemp\\\\codif_ciap_pluri.dta"\n')
        new_lines.append('drop if _merge == 2\n')
        new_lines.append('cap drop _merge\n\n')
        
    new_lines.append(line)

with open('program/00-codification_brute.do', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print('Added CIAP merges')
