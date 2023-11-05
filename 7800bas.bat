@echo off
if X"%bas7800dir%" == X goto nobasic
:tryanyway
7800preprocess.exe <"%~f1" >"%~1.pre"
7800basic.exe -i "%bas7800dir%" -b "%~1" -p "%~1.pre"
if errorlevel 1 goto basicerror
del "%1.pre" 
if X%2 == X-O goto optimize
7800postprocess -i "%bas7800dir%" > "%~f1.asm"
goto nooptimize
:optimize
7800postprocess -i "%bas7800dir%" | 7800optimize >"%~f1.asm"
:nooptimize

if not exist banksetrom.asm goto nobankset1
  dasm "%bas7800dir%"/includes/banksetskeleton.asm  -I"%bas7800dir%"/includes -f3 -l"banksetrom.list.txt" -s"banksetrom.symbol.txt" -p20 -o"banksetrom.bin" | 7800filter
  banksetsymbols
:nobankset1

dasm "%~f1.asm" -I"%bas7800dir%"/includes -f3 -p20 -l"%~f1.list.txt" -o"%~f1.bin" | 7800filter
7800sign -w "%~f1.bin"
if not exist banksetrom.asm goto nobankset2
  copy /b "%~f1.bin"+"banksetrom.bin" "%~f1.bin"
  del banksetrom.asm banksetrom.bin
:nobankset2
7800header -o -f a78info.cfg "%~f1.bin"
7800makecc2 "%~f1.bin"
goto end

:nobasic
echo bas7800dir environment variable not set.
if not exist C:\7800basic\NUL goto basicerror
echo Using hardcoded C:\7800basic directory
SET bas7800dir=C:\7800basic
SET PATH=%PATH%;C:\7800basic
goto tryanyway

:basicerror
echo Compilation failed.

:end
