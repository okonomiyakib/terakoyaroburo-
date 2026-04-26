-- CampfireSit.lua
-- 焚き火に近づいたとき「座る / 立つ」を切り替えるサーバースクリプト
-- 配置場所: ServerScriptService

local Players = game:GetService("Players")

-- 焚き火パーツを取得（Studio で Part 名を "Campfire" にしておく）
local campfire = workspace:WaitForChild("Campfire")
local prompt   = campfire:WaitForChild("ProximityPrompt")

-- 現在座っているプレイヤーを記録
local sittingPlayers = {}

-- 座席の位置（焚き火を中心に、ゆるい弧状・5席）
-- 完全な円ではなく C 字型に配置。
-- 距離を 6〜7.5 スタッドに広げ、圧迫感を減らす。
-- 隣の席と正面で向き合わないよう、各席の角度を少しずつずらしている。
local SEAT_CFRAMES = {
    CFrame.new(-6,   0,  2.5),  -- ①: 左・やや手前
    CFrame.new(-5,   0, -4.5),  -- ②: 左・斜め奥
    CFrame.new( 0,   0, -7.5),  -- ③: 正面奥（最も遠い）
    CFrame.new( 5,   0, -5),    -- ④: 右・斜め奥
    CFrame.new( 6.5, 0,  1.5),  -- ⑤: 右・やや手前
}

-- 空いている座席を返す（簡易: 今はランダムに割り当て）
local function getFreeSeat()
    local used = {}
    for _, cf in pairs(sittingPlayers) do
        used[tostring(cf)] = true
    end
    for _, cf in ipairs(SEAT_CFRAMES) do
        if not used[tostring(cf)] then
            return cf
        end
    end
    return SEAT_CFRAMES[1] -- 満席なら先頭（上書き）
end

prompt.Triggered:Connect(function(player)
    local character = player.Character
    if not character then return end

    local humanoid    = character:FindFirstChildOfClass("Humanoid")
    local rootPart    = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if sittingPlayers[player] then
        -- ── 立ち上がる ──────────────────────────────
        humanoid.Sit    = false
        sittingPlayers[player] = nil
        prompt.ActionText = "座る"
    else
        -- ── 座る ────────────────────────────────────
        local seatCF = getFreeSeat()

        -- 焚き火の絶対座標 + オフセットへ移動
        local targetCF = campfire.CFrame * seatCF

        -- 少し高さを足してキャラを配置（地面にめり込まない）
        rootPart.CFrame = targetCF + Vector3.new(0, 2, 0)

        -- 焚き火の方向を向かせる
        humanoid:MoveTo(rootPart.Position)
        task.wait(0.05)
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, campfire.Position)

        humanoid.Sit    = true
        sittingPlayers[player] = seatCF
        prompt.ActionText = "立つ"
    end
end)

-- プレイヤーが退出したら状態をクリア
Players.PlayerRemoving:Connect(function(player)
    sittingPlayers[player] = nil
end)
