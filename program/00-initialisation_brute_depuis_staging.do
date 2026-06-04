/*
Reinitialise la copie de travail Stata avant chaque apurement.

datain/staging reste immuable. Les do-files metier peuvent ensuite modifier
datain/brute sans detruire l'export Survey Solutions original.

Les sections standardisees et les sorties d'une execution precedente sont
supprimees pour eviter de publier un melange de resultats anciens et nouveaux
si l'apurement s'interrompt en cours de route.
*/

capture which violin
if _rc {
    display as text "Installation de la dependance Stata violin depuis SSC..."
    capture noisily ssc install violin
    if _rc {
        display as error "Impossible d'installer la dependance Stata violin depuis SSC."
        display as error "Verifier la connexion internet ou installer manuellement avec: ssc install violin"
        exit 499
    }
}

capture confirm file "$datain_staging\membres.dta"
if _rc {
    display as error "Export Survey Solutions absent: $datain_staging\membres.dta"
    display as error "Telecharger les fichiers MinIO vers datain/staging avant de lancer l'apurement."
    exit 601
}

capture mkdir "$datatemp"
capture mkdir "$datain_brute"
capture mkdir "$dataout"
capture mkdir "$dataout\standard"
capture mkdir "$standard_menage"
capture mkdir "$standard_individu"
capture mkdir "$dataout_menage"
capture mkdir "$dataout_individu"
capture mkdir "$datain_standard"
capture mkdir "$standard_annexe"
capture erase "$datatemp\staging_to_brute.ok"

shell cmd.exe /d /c call "$dofiles\00-initialisation_brute_depuis_staging.cmd" "$datain_staging" "$datain_brute" "$datatemp" "$folderpath" "$datain_standard" "$dataout"

capture confirm file "$datatemp\staging_to_brute.ok"
if _rc {
    display as error "Echec de la reinitialisation de datain/brute depuis datain/staging."
    display as error "Consulter $datatemp\robocopy_staging_to_brute.log"
    exit 603
}

capture erase "$datatemp\staging_to_brute.ok"
capture mkdir "$dataout"
capture mkdir "$dataout\standard"
capture mkdir "$standard_menage"
capture mkdir "$standard_individu"
capture mkdir "$dataout_menage"
capture mkdir "$dataout_individu"
capture mkdir "$datain_standard"
capture mkdir "$standard_annexe"
display as result "Copie de travail et sorties generees reinitialisees."
