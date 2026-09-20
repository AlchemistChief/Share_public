@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: VSCode Portable Root & User-Data Cleanup Script
:: ============================================================

set "ROOT=%~dp0"
set "ROOT_CLEAN=%ROOT:~0,-1%"
set "USERDATA=%ROOT%user-data\"
set "TMP_DIR=%ROOT%tmp"

:: -----------------------------------------------------------------------
:: TARGET TABLE DEFINITION
:: -----------------------------------------------------------------------
set "TARGET[1]=Cache"
set "TARGET[2]=CachedData"
set "TARGET[3]=CachedConfigurations"
set "TARGET[4]=CachedExtensionVSIXs"
set "TARGET[5]=CachedProfilesData"
set "TARGET[6]=Code Cache"
set "TARGET[7]=DawnGraphiteCache"
set "TARGET[8]=DawnWebGPUCache"
set "TARGET[9]=GPUCache"
set "TARGET[10]=Crashpad"
set "TARGET[11]=logs"
set "TARGET[12]=VideoDecodeStats"
set "TARGET[13]=blob_storage"
set "TARGET[14]=shared_proto_db"
set "TARGET[15]=WebStorage"
set "TARGET[16]=User\workspaceStorage"
set "TARGET[17]=Service Worker/CacheStorage"
set "TARGET_COUNT=17"

echo.
echo =======================================================================
echo                         VSCode Cleanup Scan
echo =======================================================================
echo Root Path     : %ROOT_CLEAN%
echo User-Data Path: %USERDATA%
echo.
echo Scanning target paths... Please wait.
echo.

:: ── Fast PowerShell Scan with Running Totals ─────────────────────────────
powershell -NoProfile -Command "$r='%ROOT_CLEAN%'; $t=@('tmp','user-data\Cache','user-data\CachedData','user-data\CachedConfigurations','user-data\CachedExtensionVSIXs','user-data\CachedProfilesData','user-data\Code Cache','user-data\DawnGraphiteCache','user-data\DawnWebGPUCache','user-data\GPUCache','user-data\Crashpad','user-data\logs','user-data\VideoDecodeStats','user-data\blob_storage','user-data\shared_proto_db'); $tf=0; $tb=0; Write-Host ('{0,-35} | {1,-12} | {2}' -f 'Target Path','Files','Size'); Write-Host ('-' * 60); foreach($i in $t){$p=Join-Path $r $i; if(Test-Path $p){$f=Get-ChildItem -Path $p -Recurse -File -ErrorAction SilentlyContinue; $c=if($f){($f|Measure-Object).Count}else{0}; $b=if($f){($f|Measure-Object -Property Length -Sum).Sum}else{0}; $tf+=$c; $tb+=$b; $s=[string][math]::Round($b/1MB,2)+' MB'; Write-Host ('{0,-35} | {1,-12} | {2}' -f $i, ($c.ToString()+' files'), $s)}else{Write-Host ('{0,-35} | {1,-12} | {2}' -f $i,'Not found','0 MB')}}; Write-Host ('-' * 60); $ts=[string][math]::Round($tb/1MB,2)+' MB'; Write-Host ('{0,-35} | {1,-12} | {2}' -f 'TOTAL', ($tf.ToString()+' files'), $ts)"

echo ------------------------------------------------------------
echo.
pause

:: ── 1. Clear contents of /tmp (root level, preserve directory) ───────────
echo.
echo [1/2] Clearing tmp contents (%TMP_DIR%)...

if exist "%TMP_DIR%" (
    for /d %%i in ("%TMP_DIR%\*") do rd /s /q "%%i"
    for %%i in ("%TMP_DIR%\*") do del /f /q "%%i"
    echo [OK] Cleared tmp contents.
) else (
    echo [SKIP] tmp folder not found.
)

:: ── 2. Delete cache directories inside user-data ─────────────────────────
echo.
echo [2/2] Deleting user-data cache folders...

for /l %%i in (1,1,%TARGET_COUNT%) do (
    set "FOLDER_NAME=!TARGET[%%i]!"
    set "TARGET_PATH=%USERDATA%!FOLDER_NAME!"

    if exist "!TARGET_PATH!" (
        rd /s /q "!TARGET_PATH!"
        echo [DELETED] !FOLDER_NAME!
    ) else (
        echo [SKIP]    !FOLDER_NAME! (not found)
    )
)

echo.
echo Cleanup complete! Folders will regenerate automatically when VSCode starts.
echo.
pause