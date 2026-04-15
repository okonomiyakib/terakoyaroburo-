-- WhisperSystem.lua
-- つぶやきを受け取り、全員の空間に浮かばせて60秒で消すサーバースクリプト
-- 配置場所: ServerScriptService

local Players         = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService    = game:GetService("TweenService")

-- RemoteEvent を ReplicatedStorage に作成（なければ自動生成）
local remotes = ReplicatedStorage:FindFirstChild("TerakoyaRemotes")
    or Instance.new("Folder", ReplicatedStorage)
remotes.Name = "TerakoyaRemotes"

local sendWhisper = remotes:FindFirstChild("SendWhisper")
    or Instance.new("RemoteEvent", remotes)
sendWhisper.Name = "SendWhisper"

-- つぶやきが浮かぶ高さ（地面からのオフセット）
local FLOAT_HEIGHT   = 3.5
-- 最大文字数（クライアント側でも制限するが念のためサーバーでも確認）
local MAX_CHARS      = 40
-- 表示時間（秒）
local DISPLAY_TIME   = 60
-- フェードイン・フェードアウトの時間
local FADE_DURATION  = 1.5

-- BillboardGui（空間に浮かぶ文字）を作る
local function createBillboard(text, position)
    local part = Instance.new("Part")
    part.Anchored      = true
    part.CanCollide    = false
    part.Transparency  = 1
    part.Size          = Vector3.new(1, 1, 1)
    part.Position      = position + Vector3.new(0, FLOAT_HEIGHT, 0)
    part.Parent        = workspace

    local billboard = Instance.new("BillboardGui", part)
    billboard.AlwaysOnTop = false
    billboard.Size        = UDim2.new(0, 300, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 0, 0)

    local label = Instance.new("TextLabel", billboard)
    label.Size            = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text            = text
    label.Font            = Enum.Font.GothamMedium
    label.TextSize        = 16
    label.TextColor3      = Color3.fromRGB(255, 245, 210)  -- 暖色・ろうそくの光
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.6
    label.TextWrapped     = true
    label.TextTransparency = 1  -- 最初は透明（フェードインする）

    -- フェードイン
    local tweenIn = TweenService:Create(
        label,
        TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { TextTransparency = 0 }
    )
    tweenIn:Play()

    -- ゆっくり上に漂わせる
    local tweenFloat = TweenService:Create(
        part,
        TweenInfo.new(DISPLAY_TIME, Enum.EasingStyle.Linear),
        { Position = part.Position + Vector3.new(0, 2, 0) }
    )
    tweenFloat:Play()

    -- 表示時間が来たらフェードアウトして削除
    task.delay(DISPLAY_TIME - FADE_DURATION, function()
        if not label.Parent then return end
        local tweenOut = TweenService:Create(
            label,
            TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { TextTransparency = 1 }
        )
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            part:Destroy()
        end)
    end)
end

-- クライアントからつぶやきを受け取る
sendWhisper.OnServerEvent:Connect(function(player, text)
    -- バリデーション
    if type(text) ~= "string" then return end
    text = text:match("^%s*(.-)%s*$")  -- trim
    if #text == 0 or #text > MAX_CHARS then return end

    -- 送信者のキャラクター位置を取得
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    createBillboard(text, rootPart.Position)
end)
