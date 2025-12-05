local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local playerName = LocalPlayer.Name


local CodeEvent = ReplicatedStorage.Shared.Packages.Knit.Services.CodeService.RF.RedeemCode
local codes = {
    "400K!",
    "PEAK!"
}
for _, code in ipairs(codes) do
    CodeEvent:InvokeServer(code)
    task.wait(0)
end


task.wait(3)


local RaceEvent = ReplicatedStorage.Shared.Packages.Knit.Services.RaceService.RF.Reroll

task.spawn(function()
    while true do
        -- Ролл
        RaceEvent:InvokeServer()
        
        task.wait(0.5)
        
        local livingPlayer = workspace.Living:FindFirstChild(playerName)
        if livingPlayer then
            local raceFolder = livingPlayer:FindFirstChild("RaceFolder")
            if raceFolder then
                local angel = raceFolder:FindFirstChild("Angel")
                local demon = raceFolder:FindFirstChild("Demon")
                if angel or demon then
                    break 
                end
            end
        end
    end
    print("Успешно получили Angel или Demon!")
end)
