-- ServerScriptService/ThoughtManager
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThoughtEvent = ReplicatedStorage:WaitForChild("ThoughtEvent")
local Config = require(ReplicatedStorage:WaitForChild("ThoughtConfig"))

local cooldowns = {}

ThoughtEvent.OnServerEvent:Connect(function(player, text)
    -- 型チェック
    if type(text) ~= "string" then return end

    -- サニタイズ
    text = text:sub(1, Config.MAX_CHARS)
    text = text:gsub("%c", ""):match("^%s*(.-)%s*$")  -- 制御文字除去 + trim
    if #text == 0 then return end

    -- クールダウン
    local now = tick()
    if cooldowns[player] and now - cooldowns[player] < Config.COOLDOWN then return end
    cooldowns[player] = now

    -- 全クライアントへ配信
    ThoughtEvent:FireAllClients(player, text)
end)

game.Players.PlayerRemoving:Connect(function(player)
    cooldowns[player] = nil
end)
