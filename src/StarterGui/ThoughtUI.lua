-- StarterGui/ThoughtUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThoughtEvent = ReplicatedStorage:WaitForChild("ThoughtEvent")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- トグルボタン（画面下中央）
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 36)
toggleBtn.Position = UDim2.new(0.5, -60, 1, -58)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 38, 34)
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "なんとなく"
toggleBtn.TextColor3 = Color3.fromRGB(210, 200, 180)
toggleBtn.TextSize = 13
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 18)

-- 入力パネル
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 290, 0, 78)
panel.Position = UDim2.new(0.5, -145, 1, -148)
panel.BackgroundColor3 = Color3.fromRGB(28, 26, 22)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -80, 1, -18)
textBox.Position = UDim2.new(0, 10, 0, 9)
textBox.BackgroundTransparency = 1
textBox.PlaceholderText = "いまおもってること..."
textBox.PlaceholderColor3 = Color3.fromRGB(110, 105, 90)
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(238, 230, 210)
textBox.TextSize = 13
textBox.Font = Enum.Font.Gotham
textBox.ClearTextOnFocus = false
textBox.TextWrapped = true
textBox.Parent = panel

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, 58, 0, 36)
sendBtn.Position = UDim2.new(1, -68, 0.5, -18)
sendBtn.BackgroundColor3 = Color3.fromRGB(160, 140, 100)
sendBtn.BorderSizePixel = 0
sendBtn.Text = "流す"
sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.TextSize = 13
sendBtn.Font = Enum.Font.GothamBold
sendBtn.Parent = panel
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 10)

-- ロジック
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then textBox:CaptureFocus() end
end)

local function submit()
    local text = textBox.Text:match("^%s*(.-)%s*$")
    if #text == 0 then return end
    ThoughtEvent:FireServer(text)
    textBox.Text = ""
    panel.Visible = false
end

sendBtn.MouseButton1Click:Connect(submit)
textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then submit() end
end)
