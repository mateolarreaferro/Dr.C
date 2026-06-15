@echo off
REM Dr.C Terminal — double-click launcher (Windows)
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch-drc-terminal.ps1" %*
if errorlevel 1 pause
