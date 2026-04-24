// === XQ 選股腳本：外資成本溢價篩選 (4% - 10%) ===
// 邏輯：篩選出股價落在「外資成本」1.04 倍至 1.10 倍之間的股票

variable: fCost(0);

// 1. 讀取 XQ 系統內建的「外資成本」
fCost = GetField("外資成本", "D");

// 2. 判斷條件：成本的 1.04 倍 <= 收盤價 <= 成本的 1.10 倍
if fCost > 0 then
begin
    if close >= fCost * 1.04 and close <= fCost * 1.10 then
    begin
        ret = 1; // 觸發選股
    end;
end;

// 3. 在選股結果中顯示資訊
outputfield(1, fCost, 2, "外資成本");
outputfield(2, close, 2, "目前股價");
outputfield(3, (close/fCost - 1) * 100, 2, "溢價率(%)");
