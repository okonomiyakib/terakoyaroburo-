-- FireflySystem.lua
-- 他プレイヤーにほたるを送るサーバースクリプト
-- 配置場所: ServerScriptService

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

-- RemoteEvent の準備
local remotes = ReplicatedStorage:WaitForChild("TerakoyaRemotes")

local sendFirefly = remotes:FindFirstChild("SendFirefly")
    or Instance.new("RemoteEvent", remotes)
sendFirefly.Name = "SendFirefly"

-- ほたる（光る小さなパーツ）を生成して飛ばす
local function spawnFirefly(from, to)
    -- 送り先キャラクターの位置
    local toChar = to.Character
    if not toChar then return end
    local toRoot = toChar:FindFirstChild("HumanoidRootPart")
    if not toRoot then return end

    local fromChar = from.Character
    if not fromChar then return end
    local fromRoot = fromChar:FindFirstChild("HumanoidRootPart")
    if not fromRoot then return end

    -- ほたる本体（小さい光る球）
    local firefly = Instance.new("Part")
    firefly.Shape       = Enum.PartType.Ball
    firefly.Size        = Vector3.new(0.3, 0.3, 0.3)
    firefly.Position    = fromRoot.Position + Vector3.new(0, 2, 0)
    firefly.Anchored    = true
    firefly.CanCollide  = false
    firefly.CastShadow  = false
    firefly.Material    = Enum.Material.Neon
    firefly.Color       = Color3.fromRGB(200, 255, 150)  -- 黄緑の発光
    firefly.Parent      = workspace

    -- ほんのり光るポイントライト
    local light = Instance.new("PointLight", firefly)
    light.Brightness = 2
    light.Range      = 6
    light.Color      = Color3.fromRGB(200, 255, 150)

    -- 目的地（受け取る人の頭上）
    local destination = toRoot.Position + Vector3.new(0, 2.5, 0)

    -- ゆっくりカーブして飛ぶ（中間点を経由）
    local midPoint = (firefly.Position + destination) / 2
        + Vector3.new(
            math.random(-3, 3),
            math.random(2, 5),   -- 少し上に弧を描く
            math.random(-3, 3)
        )

    -- 前半：送り主 → 中間点
    local tweenA = TweenService:Create(
        firefly,
        TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = midPoint }
    )
    -- 後半：中間点 → 目的地
    local tweenB = TweenService:Create(
        firefly,
        TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = destination }
    )

    tweenA:Play()
    tweenA.Completed:Connect(function()
        tweenB:Play()
    end)

    -- 到着後：受け取った人の周りでふわっと消える
    tweenB.Completed:Connect(function()
        -- 到着を受け取ったプレイヤーに通知（クライアントで演出を出す）
        sendFirefly:FireClient(to, from.DisplayName)

        -- 少し待ってフェードアウト
        task.wait(0.5)
        local tweenFade = TweenService:Create(
            firefly,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad),
            { Transparency = 1 }
        )
        tweenFade:Play()
        tweenFade.Completed:Connect(function()
            firefly:Destroy()
        end)
    end)
end

-- クライアントから「ほたるを送る」リクエストを受け取る
sendFirefly.OnServerEvent:Connect(function(sender, targetPlayer)
    -- バリデーション
    if not targetPlayer or not targetPlayer:IsA("Player") then return end
    if targetPlayer == sender then return end  -- 自分には送れない

    spawnFirefly(sender, targetPlayer)
end)
