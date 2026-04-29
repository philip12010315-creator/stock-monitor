const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const chokidar = require('chokidar');
const iconv = require('iconv-lite');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// 設定監控的路徑 (使用相對於本目錄的上一層，精確對應到你的 OneDrive 桌面)
const WATCH_PATH = path.join(__dirname, '..', '發動結果');

// 確保路徑存在
if (!fs.existsSync(WATCH_PATH)) {
    fs.mkdirSync(WATCH_PATH, { recursive: true });
}

app.use(express.static(__dirname));

function parseXQCSV(filePath) {
    const results = [];
    
    // 使用 iconv-lite 讀取 Big5 編碼
    const buffer = fs.readFileSync(filePath);
    const fileContent = iconv.decode(buffer, 'big5');
    
    const lines = fileContent.split('\n');
    
    // 從第二行解析資料日期 (例如: 資料日期: 2024年 4月 27日)
    let fileDate = '';
    if (lines[1]) {
        const dateMatch = lines[1].match(/(\d{4}年\s*\d{1,2}月\s*\d{1,2}日)/);
        if (dateMatch) fileDate = dateMatch[0].replace(/\s+/g, ''); // 去除多餘空格
    }

    // 跳過前三行描述，從第 4 行開始 (index 3)
    const csvContent = lines.slice(3).join('\n');

    return new Promise((resolve) => {
        const stream = require('stream');
        const bufferStream = new stream.PassThrough();
        bufferStream.end(csvContent);

        bufferStream
            .pipe(csv())
            .on('data', (data) => results.push(data))
            .on('end', () => {
                resolve({ results, fileDate });
            });
    });
}

async function broadcastUpdate() {
    const files = fs.readdirSync(WATCH_PATH).filter(f => f.endsWith('.csv'));
    if (files.length === 0) return;

    // 取得最新修改的檔案
    const latestFile = files.map(f => ({
        name: f,
        time: fs.statSync(path.join(WATCH_PATH, f)).mtime.getTime()
    })).sort((a, b) => b.time - a.time)[0].name;

    const filePath = path.join(WATCH_PATH, latestFile);
    console.log(`讀取最新檔案: ${latestFile}`);

    try {
        const { results, fileDate } = await parseXQCSV(filePath);
        
        // 儲存為靜態檔案（供 GitHub Pages 使用）
        // 為了相容性，我們存入一個包含日期與數據的物件
        const output = { date: fileDate, stocks: results };
        fs.writeFileSync(path.join(__dirname, 'data.json'), JSON.stringify(output, null, 2));
        
        const payload = JSON.stringify({ 
            type: 'UPDATE', 
            data: results, 
            filename: latestFile, 
            fileDate: fileDate 
        });
        wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(payload);
            }
        });
    } catch (err) {
        console.error('解析失敗:', err);
    }

    // 自動同步到 GitHub (針對 GitHub Pages 環境)
    const { exec } = require('child_process');
    const syncScript = path.join(__dirname, '同步到GitHub.bat');
    
    console.log('正在自動同步到 GitHub...');
    exec(`"${syncScript}"`, (error, stdout, stderr) => {
        if (error) {
            console.error(`同步失敗: ${error.message}`);
            return;
        }
        console.log('同步成功！網站已更新。');
    });
}

// 監控資料夾變動
chokidar.watch(WATCH_PATH).on('all', (event, path) => {
    if (event === 'add' || event === 'change') {
        console.log(`檔案變動: ${path}`);
        broadcastUpdate();
    }
});

wss.on('connection', (ws) => {
    console.log('前端已連線');
    broadcastUpdate(); // 連線時立即推送一次數據
});

const PORT = 3000;
server.listen(PORT, () => {
    const os = require('os');
    const interfaces = os.networkInterfaces();
    console.log(`\n================================================`);
    console.log(`儀表板伺服器已啟動！`);
    console.log(`本機存取: http://localhost:${PORT}`);
    
    for (const devName in interfaces) {
        const iface = interfaces[devName];
        for (let i = 0; i < iface.length; i++) {
            const alias = iface[i];
            if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal) {
                console.log(`區域網路存取 (同Wi-Fi): http://${alias.address}:${PORT}`);
            }
        }
    }
    console.log(`================================================\n`);
});
