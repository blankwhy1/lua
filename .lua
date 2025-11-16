--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local p  = Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")
local g  = pg:WaitForChild("hud").safezone.DailyShop
local l  = p:WaitForChild("leaderstats"):WaitForChild("C$")
local b  = ReplicatedStorage.packages.Net["RE/DailyShop/Purchase"]
local r  = ReplicatedStorage.packages.Net["RE/DailyShop/Refresh"]

local t        = {"Exalted Relic","Mutation Totem"}
local MIN_CASH = 10000000

-- ========================================
-- 1. УДАЛЕНИЕ QUESTCOMPASS
-- ========================================
pcall(function()
    local hud = pg:FindFirstChild("hud")
    if hud then
        local safezone = hud:FindFirstChild("safezone")
        if safezone then
            local qc = safezone:FindFirstChild("questCompass")
            if qc then qc:Destroy() end
        end
    end
end)

-- ========================================
-- 2. МГНОВЕННЫЙ ТРЕЙД
-- ========================================
local function updateTradePrompts()
    for _,pl in Players:GetPlayers() do
        if pl.Character and pl.Character:FindFirstChild("Torso") then
            local trade = pl.Character.Torso:FindFirstChild("TradeOffer")
            if trade and trade:IsA("ProximityPrompt") then
                trade.HoldDuration = 0
            end
        end
    end
end
updateTradePrompts()
task.spawn(function()
    while true do
        updateTradePrompts()
        task.wait(5)
    end
end)

local function instantTradeAll()
    for _,pl in Players:GetPlayers() do
        if pl ~= p and pl.Character and pl.Character:FindFirstChild("Torso") then
            local trade = pl.Character.Torso:FindFirstChild("TradeOffer")
            if trade and trade:IsA("ProximityPrompt") then
                task.spawn(function()
                    trade:InputHoldBegin()
                    trade:InputHoldEnd()
                end)
            end
        end
    end
end
UserInputService.InputBegan:Connect(function(inp,gp)
    if not gp and inp.KeyCode == Enum.KeyCode.Zero then
        instantTradeAll()
    end
end)

-- ========================================
-- 3. АВТОПОКУПКА
-- ========================================
local function canAfford() return l.Value >= MIN_CASH end

local function buy(id)
    local item = g.List:FindFirstChild(id)
    if item and item:FindFirstChild("SoldOut") and item.SoldOut.Visible then return end
    if canAfford() then b:FireServer(id) end
end

local function ref()
    local c = g:FindFirstChild("RefreshC$")
    if c and c:FindFirstChild("Rerolls") then
        if tonumber(c.Rerolls.Text) > 0 then
            r:FireServer()
            task.wait(0.5)
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        local list = g:FindFirstChild("List")
        if not list then task.wait(); continue end

        local bought = false
        for _,f in list:GetChildren() do
            if f:IsA("Frame") and f:FindFirstChild("Label") and f:FindFirstChild("SoldOut") then
                if not f.SoldOut.Visible then
                    local n = f.Label.Text
                    for _,v in t do
                        if n:find(v) then
                            buy(f.Name)
                            bought = true
                            task.wait(0.1)
                            break
                        end
                    end
                end
            end
            if bought then break end
        end

        if not bought then
            if not ref() then break end
        end
    end
end)

-- ========================================
-- 4. ПАНЕЛЬ ТЕЛЕПОРТА (РАСШИРЯЕТСЯ ВНИЗ ПО КНОПКАМ)
-- ========================================
local G2L = {}

G2L["1"] = Instance.new("ScreenGui", pg)
G2L["1"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling

G2L["3"] = Instance.new("Frame", G2L["1"])
G2L["3"].BackgroundColor3 = Color3.fromRGB(43, 43, 43)
G2L["3"].Size = UDim2.new(0, 131, 0, 0) -- начальная высота 0
G2L["3"].Position = UDim2.new(0.00388, 0, 0.37626, 0)
G2L["3"].Name = "Do33o54mfdkk4"
G2L["3"].AutomaticSize = Enum.AutomaticSize.Y -- автоматически расширяется по содержимому

Instance.new("UICorner", G2L["3"])
local stroke1 = Instance.new("UIStroke", G2L["3"])
stroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke1.Thickness = 2

local layout = Instance.new("UIListLayout", G2L["3"])
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local padding = Instance.new("UIPadding", G2L["3"])
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)

local function createBtn(name, text, pos)
    local btn = Instance.new("TextButton", G2L["3"])
    btn.Name = name
    btn.Text = text
    btn.Size = UDim2.new(0, 123, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.LayoutOrder = #G2L["3"]:GetChildren() -- порядок

    Instance.new("UICorner", btn)
    local stroke = Instance.new("UIStroke", btn)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 2

    btn.MouseButton1Click:Connect(function()
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local goal = {CFrame = CFrame.new(pos)}
            local tw = TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
            tw:Play()
        end
    end)
end

-- Добавляем кнопки — GUI автоматически растягивается вниз
createBtn("ForsakenButton",  "Forsaken Veil", Vector3.new(-2171.70, -11217.64, 7058.35))
createBtn("MoosewoodButton", "Moosewood",     Vector3.new(412.90, 153.09, 252.21))
createBtn("CrystalButton",   "Crystal Cove",  Vector3.new(1376.14, -603.57, 2336.71))
createBtn("RoRedButton",     "Ro-Red",        Vector3.new(-1922.00, 262.82, 116.65))
createBtn("Luminescent",     "Luminescent",   Vector3.new(-1007.8, -337.4, -4288.3))
createBtn("Sunstone",     "Sunstone",   Vector3.new(-937.3, 131.6, -1105))



return G2L["1"]
