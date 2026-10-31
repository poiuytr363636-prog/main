if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local GamesHub = {
	[1742264997] = {
		"https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/Scp%20rolepaly.lua",
	},
	[71106427459865] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[128017425240405] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[10766954651] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
}

local currentGameId = game.GameId
local currentPlaceId = game.PlaceId

local function toList(entry)
	if type(entry) == "string" then
		return { { Name = "Free", Url = entry } }
	end
	if type(entry) ~= "table" then
		return nil
	end
	local list = {}
	for index, item in ipairs(entry) do
		if type(item) == "string" then
			table.insert(list, { Name = "Free " .. index, Url = item })
		elseif type(item) == "table" and type(item.Url) == "string" then
			table.insert(list, { Name = item.Name or ("Free " .. index), Url = item.Url })
		end
	end
	if #list == 0 then
		return nil
	end
	return list
end

local function pick(list)
	if #list == 1 then
		return list[1]
	end

	local holder
	pcall(function()
		if typeof(gethui) == "function" then
			holder = gethui()
		end
	end)
	if typeof(holder) ~= "Instance" then
		holder = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10)
	end
	if not holder then
		return nil
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "ixaPick"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 9999
	gui.Parent = holder

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(300, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = Color3.fromRGB(24, 20, 27)
	panel.BorderSizePixel = 0
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = panel

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 14)
	pad.PaddingBottom = UDim.new(0, 14)
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	pad.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = panel

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.fromRGB(242, 236, 244)
	label.Text = "ixa: выбери скрипт"
	label.LayoutOrder = 1
	label.Parent = panel

	local chosen = nil
	local function finish(mode)
		if chosen ~= nil then
			return
		end
		chosen = mode or false
		pcall(function()
			gui:Destroy()
		end)
	end

	for index, mode in ipairs(list) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, 36)
		button.BackgroundColor3 = Color3.fromRGB(35, 29, 37)
		button.AutoButtonColor = false
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 12
		button.TextColor3 = Color3.fromRGB(238, 232, 240)
		button.Text = mode.Name
		button.LayoutOrder = 10 + index
		button.Parent = panel

		local bcorner = Instance.new("UICorner")
		bcorner.CornerRadius = UDim.new(0, 8)
		bcorner.Parent = button

		button.MouseButton1Click:Connect(function()
			finish(mode)
		end)
	end

	while chosen == nil do
		task.wait(0.05)
	end

	pcall(function()
		gui:Destroy()
	end)

	if chosen == false then
		return nil
	end
	return chosen
end

local list = toList(GamesHub[currentGameId])

if not list then
	print("ixa: game not supported (GameId: " .. tostring(currentGameId) .. ")")
	player:Kick("\n[ixa]\nGame not supported.\nGameId: " .. tostring(currentGameId))
	return
end

print("ixa: Game found! GameId: " .. tostring(currentGameId) .. " | PlaceId: " .. tostring(currentPlaceId))

local mode = pick(list)

if not mode then
	print("ixa: no script selected")
	return
end

print("ixa: loading " .. mode.Name)

local fetchSuccess, scriptText = pcall(function()
	return game:HttpGet(mode.Url)
end)

if not fetchSuccess or type(scriptText) ~= "string" or #scriptText == 0 then
	print("ixa: fetch error: " .. tostring(scriptText))
	player:Kick("\n[ixa]\nNetwork Error!\nCould not fetch the script.")
	return
end

if scriptText:sub(1, 1) == "{" then
	print("ixa: API error response: " .. scriptText)
	player:Kick("\n[ixa]\nScript not found on server!\n" .. scriptText)
	return
end

local compiledScript, compileError = loadstring(scriptText)

if not compiledScript then
	print("ixa: compile error: " .. tostring(compileError))
	player:Kick("\n[ixa]\nCompilation Error!\n" .. tostring(compileError))
	return
end

print("ixa: Executing script...")
local execSuccess, execError = pcall(compiledScript)

if not execSuccess then
	print("ixa: runtime error: " .. tostring(execError))
	player:Kick("\n[ixa]\nRuntime Error!\n" .. tostring(execError))
end
