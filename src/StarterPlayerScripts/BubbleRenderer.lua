-- StarterPlayerScripts/BubbleRenderer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThoughtEvent = ReplicatedStorage:WaitForChild("ThoughtEvent")
local Config = require(ReplicatedStorage:WaitForChild("ThoughtConfig"))

local function createBubble(player, text)
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- BillboardGui（キャラの頭上に浮かせる）
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 210, 0, 64)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = false
    billboard.Adornee = root
    billboard.Parent = root

    -- 背景
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(28, 26, 22)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    -- テキスト
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, -10)
    label.Position = UDim2.new(0, 8, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(238, 230, 210)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- フェードアウト
    local waitTime = Config.DISPLAY_TIME - Config.FADE_TIME
    local fadeInfo = TweenInfo.new(Config.FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    task.delay(waitTime, function()
        if not billboard.Parent then return end
        TweenService:Create(frame, fadeInfo, { BackgroundTransparency = 1 }):Play()
        local labelFade = TweenService:Create(label, fadeInfo, { TextTransparency = 1 })
        labelFade:Play()
        labelFade.Completed:Connect(function()
            billboard:Destroy()
        end)
    end)
end

ThoughtEvent.OnClientEvent:Connect(createBubble)
