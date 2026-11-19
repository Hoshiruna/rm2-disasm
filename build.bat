@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "assembler=ca65.exe"
set "linker=ld65.exe"
if not "%~1"=="" (
    set "assembler=%~f1\ca65.exe"
    set "linker=%~f1\ld65.exe"
)

set "projectDir=%~dp0"
set "sourceDir=%projectDir%src"
set "buildDir=%projectDir%build"
set "workDir=%buildDir%\rom-%RANDOM%-%RANDOM%"
mkdir "%workDir%" || exit /b 1

set "result=1"
pushd "%workDir%" || goto :cleanup

"%assembler%" -o header.o "%sourceDir%\header.asm" || goto :leave_workdir
set "objects=header.o"
for %%B in (00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F) do (
    call :assemble_bank %%B || goto :leave_workdir
)

"%linker%" -C "%projectDir%nes.cfg" -o rockman2.nes %objects% || goto :leave_workdir
move /Y rockman2.nes "%buildDir%\rockman2.nes" >nul || goto :leave_workdir
echo Built "%buildDir%\rockman2.nes"
set "result=0"

:leave_workdir
popd

:cleanup
if exist "%workDir%\*.o" del /Q "%workDir%\*.o"
if exist "%workDir%\rockman2.nes" del /Q "%workDir%\rockman2.nes"
rmdir "%workDir%"
if "%result%"=="1" echo ROM build failed. 1>&2
exit /b %result%

:assemble_bank
"%assembler%" -o bank%~1.o "%sourceDir%\bank%~1.asm" || exit /b 1
set "objects=%objects% bank%~1.o"
exit /b 0
