@echo off

echo        Assembling library modules.
echo.
\masm32\bin\ml /c /coff w.asm
\masm32\bin\lib *.obj /out:w.lib

dir w.*

@echo off
pause