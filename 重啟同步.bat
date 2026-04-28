@echo off
cd /d "%~dp0"

echo [1/3] Clearing Git cache...
git rm -r --cached . >nul 2>&1

echo [2/3] Re-adding all files...
git add .
git commit -m "Complete rebuild: %date% %time%"

echo [3/3] Force pushing to GitHub...
git push origin main --force

echo.
echo All done! Please check the website in 1-2 minutes.
pause
