-- ServerScriptService/EmberManager
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThoughtEvent = ReplicatedStorage:WaitForChild("ThoughtEvent")
local EmberEvent = ReplicatedStorage:WaitForChild("EmberEvent")

local lastEmber = nil  -- { text, playerName }

-- つぶやきが流れるたびに残り火を更新
ThoughtEvent.OnServerEvent:Connect(function(player, text)
    lastEmber = {
        text = text,
        playerName = player.DisplayName,
    }
end)

-- 新しいプレイヤーが入ったとき、残り火を送る
game.Players.PlayerAdded:Connect(function(player)
    if lastEmber then
        player.CharacterAdded:Wait()
        task.wait(1)
        EmberEvent:FireClient(player, lastEmber.text)
    end
end)
