@echo off
title ??? Ultimate Windows Repair Tool - UltimatePCFix.bat
color 0B
set LOG_DIR=C:\FixPCLogs
set LOG_FILE=%LOG_DIR%\repair_log.txt
mkdir %LOG_DIR% >nul 2>&1

echo ============================================
echo        ??? Ultimate Windows Repair Tool      
echo ============================================

echo Logging output to: %LOG_FILE%
echo.

:: 1. Run DISM to fix Windows Image
echo [1/8] Running DISM RestoreHealth...
echo DISM RestoreHealth >> %LOG_FILE%
DISM /Online /Cleanup-Image /RestoreHealth >> %LOG_FILE% 2>&1

:: 2. Run System File Checker
echo [2/8] Running System File Checker (SFC)...
echo SFC Scan >> %LOG_FILE%
sfc /scannow >> %LOG_FILE% 2>&1

:: 3. Schedule chkdsk on next reboot
echo [3/8] Scheduling full disk check (chkdsk)...
echo chkdsk C: /f /r >> %LOG_FILE%
echo Y | chkdsk C: /f /r >> %LOG_FILE% 2>&1

:: 4. Clear temporary & junk files
echo [4/8] Cleaning temporary files...
del /f /s /q %TEMP%\*.* >nul 2>&1
del /f /s /q C:\Windows\Temp\*.* >nul 2>&1
echo Temp files cleared >> %LOG_FILE%

:: 5. Reset Windows Update Components
echo [5/8] Resetting Windows Update components...
net stop wuauserv >> %LOG_FILE% 2>&1
net stop cryptSvc >> %LOG_FILE% 2>&1
net stop bits >> %LOG_FILE% 2>&1
net stop msiserver >> %LOG_FILE% 2>&1
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old >> %LOG_FILE% 2>&1
ren C:\Windows\System32\catroot2 catroot2.old >> %LOG_FILE% 2>&1
net start wuauserv >> %LOG_FILE% 2>&1
net start cryptSvc >> %LOG_FILE% 2>&1
net start bits >> %LOG_FILE% 2>&1
net start msiserver >> %LOG_FILE% 2>&1
echo Windows Update components reset >> %LOG_FILE%

:: 6. Run Deep Disk Cleanup
echo [6/8] Running Disk Cleanup (silent)...
cleanmgr /sagerun:1 >> %LOG_FILE% 2>&1

:: 7. Generate System Health Report
echo [7/8] Generating System Health Report...
start perfmon /report

:: 8. Log complete
echo [8/8] All tasks completed. See log at %LOG_FILE%
echo Done >> %LOG_FILE%

echo.
echo ============================================
echo ? All Fixes Applied. Please Reboot Your PC.
echo ?? Full log saved at: %LOG_FILE%
echo ============================================
choice /M "Do you want to restart now?"
if errorlevel 2 goto end
if errorlevel 1 shutdown /r /t 10

:end
exit