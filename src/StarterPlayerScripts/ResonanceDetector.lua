-- StarterPlayerScripts/ResonanceDetector
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local RADIUS = 5  -- 反応する距離（スタッド）

-- 焚き火のパーツを取得
local campfire = workspace:WaitForChild("Campfire")
local fire = campfire:WaitForChild("Fire")
local light = campfire:WaitForChild("PointLight")

-- 通常状態 / 共鳴状態の値
local STATE = {
    normal    = { size = 3,  heat = 0,   brightness = 1.0, range = 12 },
    resonance = { size = 6,  heat = 0.5, brightness = 2.2, range = 20 },
}

local currentState = "normal"
local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function applyState(stateName)
    if currentState == stateName then return end
    currentState = stateName
    local s = STATE[stateName]

    TweenService:Create(fire, tweenInfo, {
        Size = s.size,
        Heat = s.heat,
    }):Play()

    TweenService:Create(light, tweenInfo, {
        Brightness = s.brightness,
        Range = s.range,
    }):Play()
end

-- つぶやきBillboardの近くにいるか毎フレーム判定
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local playerPos = root.Position
    local near = false

    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BillboardGui") then
            local adornee = part.Adornee
            if adornee and adornee ~= root then
                local dist = (adornee.Position - playerPos).Magnitude
                if dist <= RADIUS then
                    near = true
                    break
                end
            end
        end
    end

    applyState(near and "resonance" or "normal")
end)
