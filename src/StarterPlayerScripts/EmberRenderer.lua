-- StarterPlayerScripts/EmberRenderer
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmberEvent = ReplicatedStorage:WaitForChild("EmberEvent")

local player = Players.LocalPlayer

EmberEvent.OnClientEvent:Connect(function(text)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    -- 空間に漂う（頭上ではなく場に浮かぶ）
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1, 1, 1)
    part.CFrame = CFrame.new(root.Position + Vector3.new(0, 3, -5))
    part.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 220, 0, 64)
    billboard.Adornee = part
    billboard.AlwaysOnTop = false
    billboard.Parent = part

    -- 背景（通常より透明 = 薄く残っている表現）
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(28, 26, 22)
    frame.BackgroundTransparency = 0.65
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0.7, 0)
    label.Position = UDim2.new(0, 8, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(238, 230, 210)
    label.TextTransparency = 0.45
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -16, 0.3, 0)
    subLabel.Position = UDim2.new(0, 8, 0.7, 0)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "— さっきの残り火"
    subLabel.TextColor3 = Color3.fromRGB(180, 160, 120)
    subLabel.TextTransparency = 0.5
    subLabel.TextSize = 10
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = frame

    -- 新しいつぶやきが来たら自然に消える
    local connection
    connection = ReplicatedStorage:WaitForChild("ThoughtEvent").OnClientEvent:Connect(function()
        connection:Disconnect()
        local fadeInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(frame, fadeInfo, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(label, fadeInfo, { TextTransparency = 1 }):Play()
        local sub = TweenService:Create(subLabel, fadeInfo, { TextTransparency = 1 })
        sub:Play()
        sub.Completed:Connect(function()
            part:Destroy()
        end)
    end)
end)
