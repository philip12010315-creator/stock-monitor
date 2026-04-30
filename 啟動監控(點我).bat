@echo off
cd /d "%~dp0"
echo 正在啟動背景監控程序...
powershell -ExecutionPolicy Bypass -File "啟動背景監控推送.ps1"
pause
