@echo off
for /f "delims=" %%i in ('"C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe" --get-id') do set CID=%%i
echo %CID%