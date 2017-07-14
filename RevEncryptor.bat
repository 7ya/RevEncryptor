@echo off
if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1
if exist %1.obj del RevEncryptor.obj
if exist %1.exe del RevEncryptor.exe
\MASM32\BIN\Ml.exe /c /coff RevEncryptor.asm
if errorlevel 1 goto errasm
if not exist rsrc.obj goto nores
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS RevEncryptor.obj rsrc.obj
if errorlevel 1 goto errlink
dir RevEncryptor.*
goto TheEnd
:nores
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS RevEncryptor.obj
if errorlevel 1 goto errlink
dir RevEncryptor.*
goto TheEnd
:errlink
echo _
echo Link error
goto errexit
:errasm
echo _
echo Assembly Error
goto errexit
:TheEnd
RevEncryptor.exe
goto eeexit
:errexit
pause
:eeexit
