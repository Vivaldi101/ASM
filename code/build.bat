@echo off

IF NOT EXIST ..\build mkdir ..\build
pushd ..\build
del /Q/F/S *.* > nul

REM Assemble

ml64 -nologo -Zi -Cp -c ..\code\xor_main_asm.asm

cl -LD -MT -nologo -Gm- -GR- -EHa -O2 -Oi -Zi -FC -W4 -wd4127 -wd4706 -wd4100 -wd4996 -wd4505 ..\build\xor_main_asm.obj ..\code\xor_main.cpp /link -incremental:no -opt:ref /OUT:xor.dll /IMPLIB:xor_import.lib

cl -MT -nologo -Gm- -GR- -EHa -O2 -Oi -Zi -FC -W4 -wd4127 -wd4706 -wd4100 -wd4996 -wd4505 ..\code\main.cpp ..\build\xor_import.lib /link -incremental:no -opt:ref /OUT:xor.exe

popd
