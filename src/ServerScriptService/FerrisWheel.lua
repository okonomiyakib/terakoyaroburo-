-- FerrisWheel.lua
-- 遠景用観覧車（背景専用・軽量設計）
-- 配置場所: ServerScriptService
--
-- 合計パーツ数: 約 37（回転 32 + 固定 5）
-- 毎フレームの CFrame 更新は回転パーツ 32 個のみ。処理負荷は極めて軽い。

local RunService = game:GetService("RunService")

-- ── 設定（ここだけ触れば調整できる）──────────────────────
local campfire    = workspace:FindFirstChild("Campfire")
local campfirePos = campfire and campfire.Position or Vector3.new(0, 0, 0)

local OFFSET       = Vector3.new(200, 0, -120)  -- 焚き火から約230スタッド先・左寄り
local WHEEL_RADIUS = 15     -- 車輪半径（遠距離に合わせてやや縮小）
local HUB_HEIGHT   = 18     -- 地面から車輪中心までの高さ（接地感を出す）
local RIM_COUNT    = 16     -- リムのセグメント数
local SPOKE_COUNT  = 8      -- スポーク本数
local ROT_SPEED    = math.rad(0.8)  -- 回転速度: 約 0.8°/秒 = 450秒で1周（気づくか気づかないかレベル）

-- 色（全体的に抑えめ、背景に溶け込む）
local C_RIM     = Color3.fromRGB(88,  92, 100)   -- リム: 暗い鉄青色
local C_SPOKE   = Color3.fromRGB(70,  72,  78)   -- スポーク
local C_GONDOLA = Color3.fromRGB(168, 152, 128)  -- ゴンドラ: くすんだ暖色
local C_HUB     = Color3.fromRGB(75,  78,  85)   -- ハブ・軸
local C_SUPPORT = Color3.fromRGB(62,  65,  70)   -- 支柱: 最も暗い

-- ── 車輪の向き（焚き火へ車輪面を向ける）──────────────────
-- 車輪は XY 平面に展開される。Y 軸回転で焚き火方向に正対させる。
local groundBase   = campfirePos + OFFSET
local towardFire   = campfirePos - groundBase          -- 焚き火へのベクトル
local yAngle       = math.atan2(towardFire.X, towardFire.Z)
local wheelCenter  = groundBase + Vector3.new(0, HUB_HEIGHT, 0)

-- 車輪の基準 CFrame（原点 = 車輪中心、Z 軸 = 焚き火方向）
local wheelBaseCF  = CFrame.new(wheelCenter) * CFrame.Angles(0, yAngle, 0)

-- ── ヘルパー ──────────────────────────────────────────────
local ferrisModel = Instance.new("Model")
ferrisModel.Name   = "FerrisWheel"
ferrisModel.Parent = workspace

local function makePart(size, color)
    local p          = Instance.new("Part")
    p.Size           = size
    p.Color          = color
    p.Material       = Enum.Material.SmoothPlastic
    p.Anchored       = true
    p.CanCollide     = false
    p.CastShadow     = false
    p.Parent         = ferrisModel
    return p
end

-- 回転パーツ一覧: { part, localCF }
-- localCF = wheelBaseCF からの相対 CFrame（車輪ローカル座標）
local rotating = {}

local function addRotating(part, localCF)
    part.CFrame = wheelBaseCF * localCF  -- 初期位置を設定
    table.insert(rotating, { part = part, localCF = localCF })
end

-- ── 車輪：リム（16 セグメント）──────────────────────────
local segAngle = (2 * math.pi) / RIM_COUNT
-- 隣セグメントとの隙間をなくすため segLen を少し長めに
local segLen   = 2 * WHEEL_RADIUS * math.sin(segAngle / 2) + 0.3

for i = 0, RIM_COUNT - 1 do
    local a   = i * segAngle
    -- 円周上の位置（車輪ローカル XY 平面内）
    local lx  = math.cos(a) * WHEEL_RADIUS
    local ly  = math.sin(a) * WHEEL_RADIUS
    -- 接線方向に向けるため Z 軸まわりに (a + 90°) 回転
    local lcf = CFrame.new(lx, ly, 0) * CFrame.Angles(0, 0, a + math.pi / 2)
    addRotating(makePart(Vector3.new(segLen, 1.2, 1.2), C_RIM), lcf)
end

-- ── 車輪：スポーク（8 本）────────────────────────────────
local spokeLen = WHEEL_RADIUS - 1  -- ハブと重ならないよう 1 スタッド短く

for i = 0, SPOKE_COUNT - 1 do
    local a   = i * (2 * math.pi / SPOKE_COUNT)
    local lx  = math.cos(a) * (spokeLen / 2)
    local ly  = math.sin(a) * (spokeLen / 2)
    local lcf = CFrame.new(lx, ly, 0) * CFrame.Angles(0, 0, a + math.pi / 2)
    addRotating(makePart(Vector3.new(0.5, spokeLen, 0.5), C_SPOKE), lcf)
end

-- ── 車輪：ゴンドラ（8 個、スポーク先端）────────────────
for i = 0, SPOKE_COUNT - 1 do
    local a   = i * (2 * math.pi / SPOKE_COUNT)
    local lx  = math.cos(a) * WHEEL_RADIUS
    local ly  = math.sin(a) * WHEEL_RADIUS
    local lcf = CFrame.new(lx, ly, 0)
    addRotating(makePart(Vector3.new(1.8, 1.8, 1.8), C_GONDOLA), lcf)
end

-- ── 中心ハブ（固定・回転しない）──────────────────────────
local hub    = makePart(Vector3.new(2.8, 2.8, 2.0), C_HUB)
hub.Shape    = Enum.PartType.Ball
hub.CFrame   = wheelBaseCF

-- 車軸（奥行き方向に少し伸ばして"軸らしさ"を出す）
local axle   = makePart(Vector3.new(1.0, 1.0, 4.0), C_HUB)
axle.CFrame  = wheelBaseCF

-- ── 支柱（固定・2 本 + 横梁）────────────────────────────
-- 支柱は車輪ローカルの左右（X 方向）に 6 スタッドずつ開く
local legSpread = 6
local legH      = HUB_HEIGHT + 2  -- 地面から車輪中心よりわずかに高い

-- 支柱の基準 CFrame（支柱中央高さ）
local legBaseCF = CFrame.new(groundBase + Vector3.new(0, legH / 2, 0))
                  * CFrame.Angles(0, yAngle, 0)

-- 左脚（わずかに外側へ傾ける）
local legL    = makePart(Vector3.new(1.5, legH * 1.05, 1.5), C_SUPPORT)
legL.CFrame   = legBaseCF * CFrame.new(-legSpread / 2, 0, 0)
                * CFrame.Angles(0, 0, math.rad(5))

-- 右脚
local legR    = makePart(Vector3.new(1.5, legH * 1.05, 1.5), C_SUPPORT)
legR.CFrame   = legBaseCF * CFrame.new( legSpread / 2, 0, 0)
                * CFrame.Angles(0, 0, math.rad(-5))

-- 横梁（脚の中間をつなぐ）
local crossH  = HUB_HEIGHT * 0.55
local beamCF  = CFrame.new(groundBase + Vector3.new(0, crossH, 0))
                * CFrame.Angles(0, yAngle, 0)
local beam    = makePart(Vector3.new(legSpread + 3, 1.0, 1.0), C_SUPPORT)
beam.CFrame   = beamCF

-- ── 回転ループ ────────────────────────────────────────────
local totalAngle = 0

RunService.Heartbeat:Connect(function(dt)
    totalAngle = (totalAngle + ROT_SPEED * dt) % (2 * math.pi)
    local rotCF = CFrame.Angles(0, 0, totalAngle)

    for _, entry in ipairs(rotating) do
        entry.part.CFrame = wheelBaseCF * rotCF * entry.localCF
    end
end)
