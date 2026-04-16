-- ServerScriptService/TimeOfDay
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- 時間帯の定義
local TIMES = {
    morning = {
        ClockTime      = 6.5,
        Ambient        = Color3.fromRGB(180, 190, 210),
        OutdoorAmbient = Color3.fromRGB(160, 175, 200),
        Brightness     = 1.2,
        FogColor       = Color3.fromRGB(200, 210, 225),
        FogEnd         = 800,
    },
    afternoon = {
        ClockTime      = 14,
        Ambient        = Color3.fromRGB(210, 200, 180),
        OutdoorAmbient = Color3.fromRGB(200, 195, 170),
        Brightness     = 2.0,
        FogColor       = Color3.fromRGB(220, 215, 200),
        FogEnd         = 1200,
    },
    evening = {
        ClockTime      = 18,
        Ambient        = Color3.fromRGB(180, 120, 80),
        OutdoorAmbient = Color3.fromRGB(160, 100, 60),
        Brightness     = 1.0,
        FogColor       = Color3.fromRGB(200, 140, 100),
        FogEnd         = 600,
    },
    night = {
        ClockTime      = 21,
        Ambient        = Color3.fromRGB(30, 35, 60),
        OutdoorAmbient = Color3.fromRGB(20, 25, 50),
        Brightness     = 0.3,
        FogColor       = Color3.fromRGB(20, 25, 50),
        FogEnd         = 400,
    },
}

local function getTimeOfDay()
    local hour = tonumber(os.date("%H"))
    if     hour >= 20 or hour < 6  then return TIMES.night
    elseif hour >= 17              then return TIMES.evening
    elseif hour >= 12              then return TIMES.afternoon
    else                                return TIMES.morning
    end
end

local function applyTime(t)
    local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    TweenService:Create(Lighting, tweenInfo, {
        ClockTime      = t.ClockTime,
        Ambient        = t.Ambient,
        OutdoorAmbient = t.OutdoorAmbient,
        Brightness     = t.Brightness,
        FogColor       = t.FogColor,
        FogEnd         = t.FogEnd,
    }):Play()
end

-- 起動時に即適用
applyTime(getTimeOfDay())

-- 5分ごとに再チェック
while true do
    task.wait(300)
    applyTime(getTimeOfDay())
end
