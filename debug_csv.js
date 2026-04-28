const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const iconv = require('iconv-lite');

const filePath = path.join('C:', 'Users', 'USER', 'Desktop', '發動結果', '外資成本發動區.csv');

function parseXQCSV(filePath) {
    const results = [];
    const buffer = fs.readFileSync(filePath);
    const fileContent = iconv.decode(buffer, 'big5');
    const lines = fileContent.split('\n');
    
    let fileDate = '';
    if (lines[1]) {
        const dateMatch = lines[1].match(/(\d{4}年\s*\d{1,2}月\s*\d{1,2}日)/);
        if (dateMatch) fileDate = dateMatch[0].replace(/\s+/g, '');
    }

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

parseXQCSV(filePath).then(data => {
    console.log('File Date:', data.fileDate);
    if (data.results.length > 0) {
        console.log('Headers found:', Object.keys(data.results[0]));
        console.log('First row sample:', data.results[0]);
    } else {
        console.log('No data found.');
    }
});
