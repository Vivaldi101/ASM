@echo off

IF NOT EXIST ..\build mkdir ..\build
pushd ..\build
del /Q/F/S *.* > nul

REM Assemble

ml64 -nologo -Zi -Cp -c ..\code\xor.asm

REM Link the final .exe

cl -MT -nologo -Gm- -GR- -EHa -Od -Oi -Zi -FC -W4 -wd4127 -wd4706 -wd4100 -wd4996 -wd4505 ..\build\xor.obj ..\code\main.cpp /link -incremental:no -opt:ref /out:xor.exe

popd
