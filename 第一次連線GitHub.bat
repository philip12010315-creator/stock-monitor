@echo off
cd /d "%~dp0"

echo Setting identity...
git config user.email "philip@example.com"
git config user.name "philip"

echo Initializing...
if not exist ".git" (
    git init
)
git remote add origin https://github.com/philip12010315-creator/stock-monitor.git 2>nul

echo Adding files (excluding node_modules)...
git add .
git commit -m "initial commit"

echo Pushing to GitHub (Please login in the popup window)...
git branch -M main
git push -u origin main --force

echo Done!
pause
