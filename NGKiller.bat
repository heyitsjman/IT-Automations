@echo off
echo NG Killer by Jesse Conklin
echo V1.1
echo Date 5.10.2024
set /p input= Type computer name:
echo Computer Name is: %input%
echo Press any key to confirm
Pause
echo Killing NG EMR Session
taskkill /s %input% /f /im NextGenEMR.exe
echo NG EMR Session Killed
echo Killing NG EPM Session
taskkill /s %input% /f /im NextGenEPM.exe
echo NG EPM Session Killed
echo Killing NG APP Launcher
taskkill /s %input% /f /im NGAppLauncher.exe
echo NG APP Launcher Cleared
echo All NG Apps Killed
Pause
