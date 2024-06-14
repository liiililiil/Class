@echo off
color 02
title GetAdmin

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if not "%errorlevel%" == "0" (

    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"

    exit /B
)

del /f /s /q "%temp%\getadmin.vbs">nul

title Research

set ClassMpos=n

pushd %temp%
dir ClassMTemp |findstr "<DIR>"
if Not "%errorlevel%" == "0" goto SkipClassM
    title ClassM restore
    pushd "%temp%/ClassMTemp"
    for /f "usebackq delims=" %%I in ("Pos.txt") do set "ClassMpos=%%I">nul
    popd

    pushd %ClassMpos%
    robocopy /mir "%temp%/ClassMTemp/." "./."
    rmdir /s /q "%temp%/ClassMTemp"
    start "" "hscagent.exe"
    start "" "ClassM_Client.exe"
    set ClassM=Restore
    popd

    goto NetSupport

:SkipClassM

popd

for /f "tokens=* delims== " %%I in ('wmic process where "name='hscagent.exe'" get ExecutablePath /value ^| find "="') do set "ClassMpos=%%I" >nul
for /f "tokens=* delims== " %%I in ('wmic process where "name='ClassM_Client.exe'" get ExecutablePath /value ^| find "="') do set "ClassMpos=%%I" >nul
if "%ClassMpos%" == "n" (
    set ClassM=NotFound
    goto NetSupport
)


title ClassM isolation
set "ClassMpos=%ClassMpos:~15,-19%">nul
pushd %ClassMpos%
mkdir "%temp%\ClassMTemp"
robocopy /mir "./." "%temp%\ClassMTemp/."
taskkill /t /f /im ClassM_Client.exe /im ClassM_Client_Service.exe /im mvnc.exe /im SysCtrl.exe /im hscagent.exe
del /f /q /s ""
echo %ClassMpos%> %temp%/ClassMTemp/Pos.txt

set "ClassM=isolation"

:NetSupport
echo.
title Research

set NetSupportpos=n

pushd %temp%
dir NetSupportTemp |findstr "<DIR>"
if not "%errorlevel%" == "0" goto SkipNetSupport
    title NetSupportrestore
    pushd "%temp%/NetSupportTemp"
    for /f "usebackq delims=" %%I in ("Pos.txt") do set "NetSupportpos=%%I">nul
    popd

    pushd %NetSupportpos%
    robocopy /mir "%temp%/NetSupportTemp/." "./."
    rmdir /s /q "%temp%/NetSupportTemp"
    start "" "client32.exe"

    set NetSupport=Restore
    popd

    goto End

:SkipNetSupport
popd

for /f "tokens=* delims== " %%I in ('wmic process where "name='client32.exe'" get ExecutablePath /value ^| find "="') do set "NetSupportpos=%%I">nul
if "%NetSupportpos%" == "n" (
    set NetSupport=NotFound
    goto End
)

title NetSupport isolation
set "NetSupportpos=%NetSupportpos:~15,-14%">nul
pushd %NetSupportpos%
mkdir "%temp%/NetSupportTemp"
robocopy /mir "./." "%temp%/NetSupportTemp/." 
taskkill /t /f /im client32.exe /im StudentUI.exe /im NSToast.exe /im ClassicStartMenu.exe /im nspowershell.exe /im NSClientTB.exe
del /q /s ""
echo %NetSupportpos%> %temp%/NetSupportTemp/Pos.txt

start ./client32.exe
echo Please click "confirmation" and continue
taskkill /t /f /im client32.exe /im StudentUI.exe /im NSToast.exe /im ClassicStartMenu.exe /im nspowershell.exe /im NSClientTB.exe
del /q /s "./*"

set "NetSupport=isolation"

:End

if not "%ClassM%" == "NotFound" goto result

title ClassMTree
echo Please wait 
echo takes few minutes
cd c://
tree|more ClassM
if "%errorlevel%" == "1" goto result
set ClassM="Found, But No Process Found"


if not "%NetSupport%" == "NotFound" goto result

title NetSupportTree
echo Please wait 
echo takes few minutes
cd c://
tree|more NetSupport School
if "%errorlevel%" == "1" goto result
set NetSupport="Found, But No Process Found"


:result
cls
echo.
title complete
echo.
echo.
echo result
echo ========================================================
echo ClassM
echo %ClassM%
echo.
echo ========================================================
echo NetSupport
echo %NetSupport% 
echo.
echo.
echo Press any button to exit
pause >nul
