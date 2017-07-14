@echo off

echo        Assembling library modules.
echo.
\masm32\bin\ml /c /coff enc_dec.asm
\masm32\bin\lib *.obj /out:enc_dec.lib

dir enc_dec.*

@echo off
pause