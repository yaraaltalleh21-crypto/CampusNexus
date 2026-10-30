@echo off
title Campus360 Local Web Server
echo ========================================================
echo   Campus360 - Smart University Facilities Management
echo   Starting local server at http://localhost:3000 ...
echo ========================================================
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0start-server.ps1"
pause
