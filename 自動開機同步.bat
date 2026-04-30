@echo off
cd /d "%~dp0"
echo ========================================
echo        [GitHub] 自動同步更新中...
echo ========================================

:: 先檢查是否有未提交的變動，避免 pull 失敗
git add .
git commit -m "Auto-sync before pull: %date% %time%" >nul 2>&1

:: 抓取最新資料
echo [1/2] 正在從雲端抓取最新進度...
git pull origin main --rebase

if %errorlevel% neq 0 (
    echo [錯誤] 同步失敗！可能是網路問題或檔案衝突。
    pause
) else (
    echo [成功] 檔案已更新至最新狀態。
    timeout /t 3
)
