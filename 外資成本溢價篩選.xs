// === XQ 選股腳本：外資成本發動區 + 連續買超 2 天 + 大盤資訊 ===
variable: fCost(0), fNetBuy(0), marketClose(0);

// 1. 讀取數據
fCost = GetField("外資成本", "D");
fNetBuy = GetField("外資買賣超", "D");
marketClose = GetSymbolField("TSE.TW", "收盤價", "D");

// 2. 定義條件
// 條件一：股價在發動區 (1.04 ~ 1.10 倍)
condition1 = (close >= fCost * 1.04 and close <= fCost * 1.10);

// 條件二：外資連續買超至少 2 天 (今天 > 0 且 昨天 > 0)
condition2 = (fNetBuy > 0 and fNetBuy[1] > 0);

// 3. 同時滿足則觸發
if fCost > 0 and condition1 and condition2 then
begin
    ret = 1;
end;

// 輸出欄位
outputfield(1, fCost, 2, "外資成本");
outputfield(2, close, 2, "目前股價");
outputfield(3, (close/fCost - 1) * 100, 2, "溢價率(%)");
outputfield(4, fNetBuy, 0, "今日外資買超");
outputfield(5, fNetBuy[1], 0, "昨日外資買超");
outputfield(6, marketClose, 2, "大盤收盤價");
