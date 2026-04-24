@echo off
title 外資成本發動監控系統 - 遠端模式
cd /d "%~dp0"

echo [1/2] 正在啟動後端伺服器...
start cmd /k "node server.js"

echo [2/2] 正在建立遠端通道...
echo ----------------------------------------------------
echo 請稍候，正在取得遠端網址...
echo ----------------------------------------------------

npx localtunnel --port 3000

pause
