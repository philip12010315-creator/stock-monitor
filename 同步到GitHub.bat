@echo off
title 外資成本監控 - 同步到 GitHub
cd /d "%~dp0"

echo 正在準備上傳最新資料...
git add index.html data.json
git commit -m "Update stock data: %date% %time%"
echo 正在推送到 GitHub...
git push origin main

if %errorlevel% neq 0 (
    echo [錯誤] 上傳失敗！請檢查是否已安裝 Git 且已設定好 GitHub 倉庫。
) else (
    echo [成功] 資料已更新至 GitHub Pages！
)

pause
