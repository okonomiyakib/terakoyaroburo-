-- FireflyUI.lua
-- 他プレイヤーをクリックしてほたるを送る／受け取ったときの演出
-- 配置場所: StarterPlayerScripts

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse     = player:GetMouse()

local remotes     = ReplicatedStorage:WaitForChild("TerakoyaRemotes")
local sendFirefly = remotes:WaitForChild("SendFirefly")

-- クールダウン（連打防止）
local COOLDOWN     = 5  -- 秒
local lastSentTime = 0

-- ── 受け取ったときの通知UI ─────────────────────────────────

local notifGui = Instance.new("ScreenGui", playerGui)
notifGui.Name          = "FireflyNotif"
notifGui.ResetOnSpawn  = false

local notifLabel = Instance.new("TextLabel", notifGui)
notifLabel.Size              = UDim2.new(0, 260, 0, 36)
notifLabel.Position          = UDim2.new(0.5, -130, 0, 60)
notifLabel.BackgroundColor3  = Color3.fromRGB(200, 255, 150)
notifLabel.BackgroundTransparency = 1
notifLabel.BorderSizePixel   = 0
notifLabel.Text               = ""
notifLabel.Font               = Enum.Font.GothamMedium
notifLabel.TextSize           = 14
notifLabel.TextColor3         = Color3.fromRGB(255, 255, 220)
notifLabel.TextTransparency   = 1
notifLabel.TextStrokeTransparency = 0.5

local notifCorner = Instance.new("UICorner", notifLabel)
notifCorner.CornerRadius = UDim.new(0, 10)

-- ほたるを受け取ったとき
sendFirefly.OnClientEvent:Connect(function(senderName)
    notifLabel.Text = "🌿  " .. senderName .. " からほたるが届いた"

    -- フェードイン
    TweenService:Create(
        notifLabel,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        { TextTransparency = 0, BackgroundTransparency = 0.55 }
    ):Play()

    -- 2秒後にフェードアウト
    task.delay(2.5, function()
        TweenService:Create(
            notifLabel,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad),
            { TextTransparency = 1, BackgroundTransparency = 1 }
        ):Play()
    end)
end)

-- ── 他プレイヤーをクリックしてほたるを送る ─────────────────

mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if not target then return end

    -- クールダウンチェック
    local now = tick()
    if now - lastSentTime < COOLDOWN then return end

    -- クリックしたパーツのキャラクターを取得
    local targetChar = target:FindFirstAncestorOfClass("Model")
    if not targetChar then return end

    local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
    if not targetPlayer or targetPlayer == player then return end

    -- サーバーへ送信
    lastSentTime = now
    sendFirefly:FireServer(targetPlayer)
end)
