@echo off
cd /d "%~dp0"

echo Force checking all updates...
git add --all
git commit -m "Manual sync: %date% %time%"

echo Pushing to GitHub...
git push origin main

if %errorlevel% neq 0 (
    echo [Error] Upload failed!
) else (
    echo [Success] Data updated to GitHub Pages!
)

pause
