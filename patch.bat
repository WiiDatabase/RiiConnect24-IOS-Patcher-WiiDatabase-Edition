@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:top
CLS
COLOR 1F
set currentversion=v1.0.3
set header=echo			RiiConnect24 IOS Patcher %currentversion% by WiiDatabase.de
mode con cols=85 lines=30
TITLE RiiConnect24 IOS Patcher %currentversion%

:check
if not exist Support\IOS31.diff goto:missing
if not exist Support\IOS80.diff goto:missing
if not exist Support\nusd.exe goto:missing
if not exist Support\sfk.exe goto:missing
if not exist Support\xdelta3.exe goto:missing
goto:start

:missing
CLS
%header%
echo.
echo.
echo		    ERROR: One or more support files are missing.
echo		    Please check the download and redownload
echo		    if necessary.
echo.
echo		    Also, do not run the patcher as an administrator.
echo.
echo		    Press any key to close the patcher.
pause >NUL
exit

:start
CLS
%header%
echo.
if /i "%false%" EQU "1" Support\sfk echo -spat \x20 \x20 \x20 \x20 \x20 \x20 [Red] Not a valid input, please try again.
set false=
set islatest=
echo.
echo		Welcome to the RiiConnect24 IOS Patcher!
echo.
Support\sfk echo -spat \x20 \x20 \x20 \x20 \x20 \x20 [Yellow] PLEASE NOTE: This patcher will ONLY work on the Wii^^!
Support\sfk echo -spat \x20 \x20 \x20 \x20 \x20 \x20 [Yellow] Do not install these IOS on a Wii U^^!
echo.
echo		Do you have System Menu 4.3 installed and want to use Wii Mail?
echo		In this case, IOS80 will also be patched.
echo.
echo.
echo		[Y] Yes
echo		[N] No
echo		[0] Exit
echo.
set /p islatest=	Input:	

if /i "%islatest%" EQU "Y" (set ios31=*) && (set ios80=*) && (set nof=2) && (goto:downloadios)
if /i "%islatest%" EQU "N" (set ios31=*) && (set ios80=) && (set nof=1) && (goto:downloadios)
if /i "%islatest%" EQU "0" exit

set false=1
goto:start

:downloadios
CLS
%header%
echo.
echo.
set failed=0
:setvariables
set attempt=1
if /i "%ios31%" EQU "*" goto:ios31
if /i "%ios80%" EQU "*" goto:ios80
goto:alldownloadsfinished


:: Set variables for downloads
::
:: name = Name of the WAD (will append "-patched" for patched WADs)
:: namedl = Shown name of the download
:: titleid = TitleID of the IOS from NUS
:: titleversion = TitleID of the IOS (do not leave it blank!)
:: md5 = MD5 of the download - please use NUSD 1.9 Mod, not the NUSD Command Line 0.2 from ModMii!
:: patched_md5 = MD5 of the patched WAD
:: variable = Variable of the download (which is set to "*" earlier)

:ios31
set name=IOS31
set namedl=IOS31 Latest Version
set titleid=000000010000001F
set titleversion=3608
set md5=7908ce72ed970b9610d817dd71807a84
set patched_md5=a4dfbb1c46fdd815eefbd9c463f6ed63
set variable=ios31
goto:startdownload

:ios80
set name=IOS80
set namedl=IOS80 v6944
set titleid=0000000100000050
set titleversion=6944
set md5=a845fbe6d788f3a5c65ce624096150f4
set patched_md5=2514cfb7e9c6b566d8db4fe165e711c6
set variable=ios80
goto:startdownload


:startdownload
if /i "%attempt%" EQU "4" goto:failed

if /i "%attempt%" EQU "1" Support\sfk echo -spat \x20 \x20 [Magenta] Downloading %namedl%...
if /i "%attempt%" NEQ "1" Support\sfk echo -spat \x20 \x20 [Magenta] Redownloading %namedl%...
if /i "%existsbutinvalid%" EQU "*" (set /a attempt=%attempt%-1) && (set existsbutinvalid=)

if not exist copy-to-device\%name%-patched.wad goto:notexistpatched
:: Verify MD5, if patched WAD already exists
set md5check=
support\sfk md5 -quiet -verify %patched_md5% copy-to-device\%name%-patched.wad
if errorlevel 1 (set md5check=fail) else (set md5check=pass)
if /i %md5check% EQU fail (support\sfk echo -spat \x20 \x20  [Yellow] Patched file already exists, but failed the MD5 check.) && (support\sfk echo -spat \x20 \x20  [Yellow] Deleting the file and redownloading/repatching...) &&  (del copy-to-device\%name%-patched.wad)
if /i %md5check% EQU pass (support\sfk echo -spat \x20 \x20  [Green] File is already patched and valid^^!) && (set %variable%=)
echo.
goto:setvariables

:notexistpatched
:: Patched WAD doesn't exist, download base WAD first
if not exist tmp mkdir tmp
if not exist tmp\%name%.wad goto:download

set md5check=
support\sfk md5 -quiet -verify %md5% tmp\%name%.wad
if errorlevel 1 set md5check=fail
IF "%md5check%"=="" (set md5check="exists") && (goto:pass)

support\sfk echo -spat \x20 \x20  [Yellow] This file already exists, but it failed the MD5 check.
support\sfk echo -spat \x20 \x20  [Yellow] The current file will be deleted and the file will be redownloaded.
echo.

set /a attempt=%attempt%+1
set existsbutinvalid=*
del tmp\%name%.wad >NUL
if exist titles\%titleid% rmdir /s /q titles\%titleid%
goto:startdownload

:download
:: Downloading base WAD
start /min/wait Support\nusd.exe %titleid% %titleversion% packwad
if exist titles\%titleid%\%titleversion%\%titleid%-NUS-v%titleversion%.wad move /y titles\%titleid%\%titleversion%\%titleid%-NUS-v%titleversion%.wad tmp\%name%.wad >NUL

if exist titles\%titleid% rd /s /q titles\%titleid%
if exist tmp\%name%.wad goto:checkdownload
support\sfk echo -spat \x20 \x20  [Yellow] The file is missing, retrying download...
echo.

set /a attempt=%attempt%+1
if exist tmp\%name%.wad del tmp\%name%.wad
goto:startdownload

:checkdownload
:: Check MD5 of the download
set md5check=
support\sfk md5 -quiet -verify %md5% tmp\%name%.wad
if errorlevel 1 set md5check=fail
IF "%md5check%"=="" (set md5check=pass) && (goto:pass)

support\sfk echo -spat \x20 \x20  [Yellow] The MD5 check failed.
support\sfk echo -spat \x20 \x20  [Yellow] The current file will be deleted and the file will be redownloaded.
echo.

set /a attempt=%attempt%+1
del tmp\%name%.wad >NUL
if exist titles\%titleid% rd /s /q titles\%titleid%
goto:startdownload

:pass
:: Base WAD already exists and passed the MD5 check or download of the base WAD finished
if /i %md5check% EQU "exists" (support\sfk echo -spat \x20 \x20  [Green] This file already exists and has passed the MD5 check^^!) else (support\sfk echo -spat \x20 \x20  [Green] Download finished^^!)
echo.

:patching
:: Patch base WADs
Support\sfk echo -spat \x20 \x20 [Magenta] Patching %namedl%...
if not exist copy-to-device mkdir copy-to-device

start /min/wait Support\xdelta3.exe -d -s tmp\%name%.wad Support\%name%.diff copy-to-device\%name%-patched.wad
if not exist copy-to-device\%name%-patched.wad goto:patchfailed

support\sfk echo -spat \x20 \x20  [Green] Patching done^^!
echo.

set %variable%=
goto:setvariables

:patchfailed
:: Patching of the base WAD failed
if /i "%attempt%" EQU "1" Support\sfk echo -spat \x20 \x20 [Red] Patching failed, skipping...
echo.
set /a failed=%failed%+1
set %variable%=
goto:setvariables

:failed
:: Download of the base WAD failed mutiple times
support\sfk echo -spat \x20 \x20  [Red] This file failed to download multiple times, skipping...
set /a failed=%failed%+1
set %variable%=
echo.
goto:setvariables

:alldownloadsfinished
:: All downloads finished
if exist titles rd /s /q titles
echo.
if /i %failed% EQU %nof% (support\sfk echo -spat \x20 \x20  [Red] All downloads failed, please check your connection!) && (goto:miniskip)
if /i %failed% GTR 0 (support\sfk echo -spat \x20 \x20  [Yellow] Finished, but with errors.) else (support\sfk echo -spat \x20 \x20  [Green] Everything finished^^!)
echo.
echo		You can find the patched file(s) in the "copy-to-device" folder.
echo		Install it/them with a WAD manager.
:miniskip
echo.
echo		Press any key to close this patcher.
pause >NUL
exit