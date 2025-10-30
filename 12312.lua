local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local S_T = game:GetService("TeleportService")
local S_H = game:GetService("HttpService")

-- Загрузка существующих ID
local File = pcall(function()
	AllIDs = S_H:JSONDecode(readfile("server-hop-temp.json"))
end)

if not File then
	table.insert(AllIDs, actualHour)
	pcall(function()
		writefile("server-hop-temp.json", S_H:JSONEncode(AllIDs))
	end)
end

local function TPReturner(placeId)
	local Site
	if foundAnything == "" then
		Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Desc&limit=100'))
	else
		Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Desc&limit=100&cursor=' .. foundAnything))
	end

	local servers = {}
	local cursor = Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor or nil
	foundAnything = cursor or ""

	-- Собираем все доступные сервера
	for _, v in pairs(Site.data) do
		if v.playing < v.maxPlayers and v.playing > 0 then -- Только неполные и не пустые
			table.insert(servers, {
				id = v.id,
				playing = v.playing,
				maxPlayers = v.maxPlayers
			})
		end
	end

	-- Сортируем по количеству игроков (по убыванию)
	table.sort(servers, function(a, b)
		return a.playing > b.playing
	end)

	-- Проверяем каждый сервер по приоритету (от самого полного)
	for _, server in ipairs(servers) do
		local ID = tostring(server.id)
		local Possible = true

		-- Проверка на уже использованные серверы
		for _, Existing in pairs(AllIDs) do
			if tonumber(actualHour) ~= tonumber(Existing) then
				-- Сброс файла раз в час
				pcall(function()
					delfile("server-hop-temp.json")
					AllIDs = { actualHour }
					writefile("server-hop-temp.json", S_H:JSONEncode(AllIDs))
				end)
				break
			elseif ID == tostring(Existing) then
				Possible = false
				break
			end
		end

		if Possible then
			table.insert(AllIDs, ID)
			pcall(function()
				writefile("server-hop-temp.json", S_H:JSONEncode(AllIDs))
			end)

			print("Хопим на сервер с " .. server.playing .. "/" .. server.maxPlayers .. " игроками (ID: " .. ID .. ")")
			S_T:TeleportToPlaceInstance(placeId, ID, game.Players.LocalPlayer)
			wait(4)
			return true
		end
	end

	return false
end

local module = {}

function module:Teleport(placeId)
	while task.wait(1) do
		pcall(function()
			if not TPReturner(placeId) and foundAnything ~= "" then
				TPReturner(placeId)
			end
		end)
	end
end

return module

