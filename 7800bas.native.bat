@echo off
REM 7800basic compilation script - only use this if you're using native executables instead of the official wasm executables

setlocal

if X"%bas7800dir%"==X goto nobasic

echo Using bas7800dir=%bas7800dir%

REM --- Display tool versions ---
for /F "delims=" %%v in ("%bas7800dir%\7800basic.exe" -v 2^>nul') do set BASVER=%%v
echo   basic version: %BASVER%
for /F "delims=" %%v in ('"%bas7800dir%\dasm.exe" 2^>nul') do set DASMVER=%%v & goto dasmgotver
:dasmgotver
echo   dasm version: %DASMVER%


REM --- Source file check ---
if "%~1"=="" (
    echo ### ERROR: No source file specified.
    exit /b 1
)

if /i "%~1"=="-v" (
    REM Just version check
    exit /b 0
)

set srcfile=%~nx1
set srcbase=%~n1
set srcdir=%~dp1
if "%srcdir:~-1%"=="\" set srcdir=%srcdir:~0,-1%

echo.
echo Starting build of %srcfile%

REM --- Preprocess ---
"%bas7800dir%\7800preprocess.exe" <"%~f1" >"%~1.pre"
if errorlevel 1 goto basicerror

REM --- Compile ---
"%bas7800dir%\7800basic.exe" -i "%bas7800dir%" -b "%~f1" -p "%~1.pre"
if errorlevel 1 goto basicerror

del "%~1.pre"

REM --- Postprocess / Optimize ---
if /I "%2"=="-O" (
    "%bas7800dir%\7800postprocess.exe" -i "%bas7800dir%"  ^
    | "%bas7800dir%\7800optimize.exe" > "%~1.asm"
) else (
    "%bas7800dir%\7800postprocess.exe" -i "%bas7800dir%" > "%~1.asm"
)

REM --- Assembly Banksets, if applicable
if not exist banksetrom.asm goto nobankset1
    "%bas7800dir%\dasm.exe" "%bas7800dir%/includes/banksetskeleton.asm" -I"%bas7800dir%/includes" -f3 -l"banksetrom.list.txt" -s"banksetrom.symbol.txt" -p20 -o"banksetrom.bin"
    "%bas7800dir%\banksetsymbols.exe"
:nobankset1

REM --- Assemble final binary ---
  "%bas7800dir%\dasm.exe" "%~1.asm" -I. -I"%bas7800dir%\includes" -f3 -p20 -l"%~1.list.txt" -s"%~1.symbol.txt" -o"%~1.bin" | "%bas7800dir%\7800filter.exe"

  "%bas7800dir%\7800sign.exe" -w "%~1.bin"

REM --- Combine and cleanup Banksets, if applicable
if not exist banksetrom.asm goto nobankset2
  copy /b "%~f1.bin"+"banksetrom.bin" "%~f1.bin"
  del banksetrom.asm banksetrom.bin
:nobankset2

REM --- Header + CC2 ---
  "%bas7800dir%\7800header.exe" -o -f a78info.cfg "%~1.bin"

  "%bas7800dir%\7800makecc2.exe" "%~1.bin"

goto end

:basicerror
echo.
echo ### ERROR: 7800basic compilation failed.
exit /b 1

:nobasic
echo.
echo ### ERROR: bas7800dir not defined.
exit /b 1

:end
endlocal
exit /b 0


