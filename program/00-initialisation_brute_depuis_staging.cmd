@echo off
setlocal

for %%I in ("%~1") do set "SOURCE=%%~fI"
for %%I in ("%~2") do set "DESTINATION=%%~fI"
for %%I in ("%~3") do set "TEMPDIR=%%~fI"
for %%I in ("%~4") do set "PROJECTROOT=%%~fI"
for %%I in ("%~5") do set "STANDARDINPUT=%%~fI"
for %%I in ("%~6") do set "GENERATEDOUTPUT=%%~fI"

if not exist "%TEMPDIR%" mkdir "%TEMPDIR%"
del /q "%TEMPDIR%\staging_to_brute.ok" 2>nul

if /I not "%SOURCE%"=="%PROJECTROOT%\datain\staging" exit /b 2
if /I not "%DESTINATION%"=="%PROJECTROOT%\datain\brute" exit /b 2
if /I not "%STANDARDINPUT%"=="%PROJECTROOT%\datain\standard" exit /b 2
if /I not "%GENERATEDOUTPUT%"=="%PROJECTROOT%\dataout" exit /b 2

robocopy.exe "%SOURCE%" "%DESTINATION%" /MIR /COPY:DAT /DCOPY:T /R:1 /W:1 /NFL /NDL /NJH /NJS /NP > "%TEMPDIR%\robocopy_staging_to_brute.log"
if errorlevel 8 exit /b 1

if exist "%STANDARDINPUT%" rmdir /s /q "%STANDARDINPUT%" >> "%TEMPDIR%\robocopy_staging_to_brute.log" 2>&1
if exist "%STANDARDINPUT%" exit /b 2

if exist "%GENERATEDOUTPUT%" rmdir /s /q "%GENERATEDOUTPUT%" >> "%TEMPDIR%\robocopy_staging_to_brute.log" 2>&1
if exist "%GENERATEDOUTPUT%" exit /b 2

type nul > "%TEMPDIR%\staging_to_brute.ok"
exit /b 0
