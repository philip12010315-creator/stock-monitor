@echo off
cd /d "%~dp0"

echo [1/3] Force staging files...
git add index.html
git add data.json
git add .gitignore

echo [2/3] Committing changes...
git commit -m "Update data and index: %date% %time%"

echo [3/3] Pushing to GitHub...
git push origin main --force

if %errorlevel% neq 0 (
    echo [Error] Upload failed!
) else (
    echo [Success] Data updated to GitHub Pages!
)

pause
