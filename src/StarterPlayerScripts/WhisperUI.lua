-- WhisperUI.lua
-- つぶやき入力UIのクライアントスクリプト
-- 配置場所: StarterPlayerScripts

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvent が用意されるまで待つ
local remotes     = ReplicatedStorage:WaitForChild("TerakoyaRemotes")
local sendWhisper = remotes:WaitForChild("SendWhisper")

local MAX_CHARS = 40

-- ── UI を構築 ─────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "WhisperGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 入力欄のコンテナ（画面下中央）
local container = Instance.new("Frame", screenGui)
container.Size            = UDim2.new(0, 320, 0, 48)
container.Position        = UDim2.new(0.5, -160, 1, -80)
container.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
container.BackgroundTransparency = 0.3
container.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", container)
uiCorner.CornerRadius = UDim.new(0, 12)

-- プレースホルダーラベル（フォーカス時に消える）
local hint = Instance.new("TextLabel", container)
hint.Size              = UDim2.new(1, -16, 1, 0)
hint.Position          = UDim2.new(0, 12, 0, 0)
hint.BackgroundTransparency = 1
hint.Text              = "なんでも…"
hint.Font              = Enum.Font.GothamMedium
hint.TextSize          = 15
hint.TextColor3        = Color3.fromRGB(160, 140, 110)
hint.TextXAlignment    = Enum.TextXAlignment.Left
hint.TextTransparency  = 0.3

-- 実際の入力ボックス
local textBox = Instance.new("TextBox", container)
textBox.Size              = UDim2.new(1, -16, 1, 0)
textBox.Position          = UDim2.new(0, 12, 0, 0)
textBox.BackgroundTransparency = 1
textBox.Text              = ""
textBox.PlaceholderText   = ""
textBox.Font              = Enum.Font.GothamMedium
textBox.TextSize          = 15
textBox.TextColor3        = Color3.fromRGB(255, 245, 210)
textBox.TextXAlignment    = Enum.TextXAlignment.Left
textBox.ClearTextOnFocus  = false
textBox.MultiLine         = false

-- 文字数カウンター
local counter = Instance.new("TextLabel", container)
counter.Size              = UDim2.new(0, 40, 0, 20)
counter.Position          = UDim2.new(1, -44, 0, 14)
counter.BackgroundTransparency = 1
counter.Text              = tostring(MAX_CHARS)
counter.Font              = Enum.Font.GothamMedium
counter.TextSize          = 12
counter.TextColor3        = Color3.fromRGB(140, 120, 90)
counter.TextXAlignment    = Enum.TextXAlignment.Right
counter.Visible           = false

-- ── ふるまい ──────────────────────────────────────────────

-- フェードイン/アウトのヘルパー
local function setTransparency(frame, alpha, duration)
    TweenService:Create(
        frame,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad),
        { BackgroundTransparency = alpha }
    ):Play()
end

-- 文字数制限（MAX_CHARS 以上は入力させない）
textBox:GetPropertyChangedSignal("Text"):Connect(function()
    if #textBox.Text > MAX_CHARS then
        textBox.Text = textBox.Text:sub(1, MAX_CHARS)
    end
    local remaining = MAX_CHARS - #textBox.Text
    counter.Text = tostring(remaining)
    counter.TextColor3 = remaining <= 10
        and Color3.fromRGB(220, 100, 80)
        or  Color3.fromRGB(140, 120, 90)
end)

-- フォーカス時：ヒントを隠す・カウンターを出す
textBox.Focused:Connect(function()
    hint.Visible    = false
    counter.Visible = true
    setTransparency(container, 0.1, 0.2)
end)

-- フォーカスを外す（Enter / FocusLost）
textBox.FocusLost:Connect(function(enterPressed)
    local text = textBox.Text:match("^%s*(.-)%s*$")

    if enterPressed and #text > 0 then
        -- サーバーへ送信
        sendWhisper:FireServer(text)
    end

    -- UIをリセット
    textBox.Text    = ""
    hint.Visible    = true
    counter.Visible = false
    setTransparency(container, 0.3, 0.3)
end)

-- T キーで入力欄にフォーカス（オプション）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        textBox:CaptureFocus()
    end
end)
