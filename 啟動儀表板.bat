@echo off
title 外資成本發動監控系統 - 啟動中
cd /d "%~dp0"

echo 正在檢查 Node.js 環境...
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [錯誤] 找不到 Node.js，請先安裝 Node.js！
    echo 下載地址: https://nodejs.org/
    pause
    exit
)

if not exist "node_modules" (
    echo 偵測到第一次執行，正在安裝必要套件...
    call npm install
)

echo 正在啟動伺服器...
start http://localhost:3000
node server.js

pause
