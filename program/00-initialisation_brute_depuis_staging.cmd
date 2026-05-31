@echo off
setlocal

set "SOURCE=%~1"
set "DESTINATION=%~2"
set "TEMPDIR=%~3"

if not exist "%TEMPDIR%" mkdir "%TEMPDIR%"
del /q "%TEMPDIR%\staging_to_brute.ok" 2>nul

robocopy.exe "%SOURCE%" "%DESTINATION%" /MIR /COPY:DAT /DCOPY:T /R:1 /W:1 /NFL /NDL /NJH /NJS /NP > "%TEMPDIR%\robocopy_staging_to_brute.log"
if errorlevel 8 exit /b 1

type nul > "%TEMPDIR%\staging_to_brute.ok"
exit /b 0
