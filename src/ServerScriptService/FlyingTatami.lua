-- FlyingTatami.lua（複数畳対応版）
-- 配置場所: ServerScriptService
-- Studio に "FlyingTatami" という名前の Part を置くだけで自動で動く

local RunService = game:GetService("RunService")

-- ── 焚き火を基準に位置を決める ────────────────────────────
local campfire  = workspace:FindFirstChild("Campfire")
local centerPos = campfire and campfire.Position or Vector3.new(0, 0, 0)

-- ── 各畳の配置位置（焚き火からの相対座標）────────────────
-- メインの輪（半径 6〜7.5 スタッド）の外に配置。
-- 「孤立」ではなく「そっと離れられる場所」として機能させる。
-- 焚き火は見える距離を維持しつつ、輪には属さない位置。
local POSITIONS = {
    centerPos + Vector3.new(-12, 0,  3),  -- 畳①: 左遠め（輪から自然に外れた逃げ場）
    centerPos + Vector3.new( 10, 0,  7),  -- 畳②: 右遠め（看板のさらに奥）
    centerPos + Vector3.new(  2, 0, -20), -- 畳③: 正面の奥（最も静かな一人席）
}

-- ── 共通設定（全畳で同じ挙動）────────────────────────────
local CONFIG = {
    MAX_HEIGHT = 8,    -- 最大浮上高さ（スタッド）
    RISE_LERP  = 0.8,  -- 上昇の滑らかさ
    SINK_LERP  = 0.4,  -- 降下の滑らかさ（ゆっくり戻る）
}

-- ── 畳1つ分のセットアップ ─────────────────────────────────
local function setupTatami(tatami, position)
    tatami.Position = position
    tatami.Anchored = true

    local OX = position.X
    local OY = position.Y
    local OZ = position.Z
    local SEAT_OFFSET = tatami.Size.Y / 2 + 0.05

    -- Seat を自動生成（畳ごとに独立）
    local seat = Instance.new("Seat")
    seat.Name         = tatami.Name .. "_Seat"
    seat.Size         = Vector3.new(tatami.Size.X * 0.9, 0.1, tatami.Size.Z * 0.9)
    seat.Transparency = 1
    seat.CanCollide   = false
    seat.Anchored     = true
    seat.CFrame       = CFrame.new(OX, OY + SEAT_OFFSET, OZ)
    seat.Parent       = workspace

    -- 状態（畳ごとに独立）
    local targetY  = OY
    local displayY = OY

    -- 乗り降り検知（Seat.Occupant で確実に検知）
    seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        targetY = seat.Occupant and (OY + CONFIG.MAX_HEIGHT) or OY
    end)

    -- 更新ループ（畳ごとに独立）
    RunService.Heartbeat:Connect(function(dt)
        local speed  = (targetY > displayY) and CONFIG.RISE_LERP or CONFIG.SINK_LERP
        local factor = 1 - math.exp(-speed * dt)
        displayY     = displayY + (targetY - displayY) * factor

        tatami.CFrame = CFrame.new(OX, displayY,               OZ)
        seat.CFrame   = CFrame.new(OX, displayY + SEAT_OFFSET, OZ)
    end)
end

-- ── ワークスペースの畳を収集して位置を割り当て ────────────
local tatamiList = {}
for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == "FlyingTatami" and obj:IsA("BasePart") then
        table.insert(tatamiList, obj)
    end
end

for i, tatami in ipairs(tatamiList) do
    if POSITIONS[i] then
        setupTatami(tatami, POSITIONS[i])
    else
        warn("POSITIONS[" .. i .. "] が未定義です。畳の数と POSITIONS の数を合わせてください。")
    end
end
