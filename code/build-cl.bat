@echo off
setlocal enabledelayedexpansion

REM Path to vswhere
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

REM Check if vswhere exists
if not exist "!VSWHERE!" (
    echo ERROR: vswhere.exe not found in !VSWHERE!
    echo Please install Visual Studio or make sure vswhere.exe is available.
    exit /b 1
)

REM Use vswhere to find the latest VS installation with VC tools
for /f "usebackq tokens=*" %%i in (`"!VSWHERE!" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
    set "VSINSTALLDIR=%%i"
)

REM Check if we found a valid installation
if not defined VSINSTALLDIR (
    echo ERROR: Could not find a valid Visual Studio installation with VC++ tools.
    exit /b 1
)

REM Build path to vcvarsall.bat
set "VCVARSALL=!VSINSTALLDIR!\VC\Auxiliary\Build\vcvarsall.bat"

if not exist "!VCVARSALL!" (
    echo ERROR: vcvarsall.bat not found at !VCVARSALL!
    exit /b 1
)

echo Calling vcvarsall.bat from: !VCVARSALL!
call "!VCVARSALL!" x64

REM === Your Build Process ===

REM Create and clean build directory
if not exist ..\build mkdir ..\build
pushd ..\build
del /Q/F/S *.* > nul

REM Assemble
ml64 -nologo -Zi -Cp -c ..\code\xor.asm

REM Link the final .exe
cl -MT -nologo -Gm- -GR- -EHa -O2 -Oi -Zi -FC -W4 -wd4127 -wd4706 -wd4100 -wd4996 -wd4505 xor.obj ..\code\main.c /link -incremental:no -opt:ref /out:xor.exe

popd
endlocal

