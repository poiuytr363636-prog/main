-- credit: @Poiuytr | main discord: @poiytr12345678

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

do
	local ok, was = pcall(function()
		if typeof(getgenv) == "function" then
			local env = getgenv()
			local prev = env.ixaLoaderLoaded
			env.ixaLoaderLoaded = true
			return prev
		end
		return false
	end)
	if ok and was then
		return
	end
end

local GamesHub = {
	[1742264997] = {
		"https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/Scp%20rolepaly.lua",
	},
	[71106427459865] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[128017425240405] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[10766954651] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[3730079862] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/Examination.lua",
	[7623259179] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/null.lua",
}

local currentGameId = game.GameId
local currentPlaceId = game.PlaceId

local entry = GamesHub[currentGameId] or GamesHub[currentPlaceId]

local function toList(value)
	if type(value) == "string" then
		return { { Name = "Free", Url = value } }
	end
	if type(value) ~= "table" then
		return nil
	end
	local list = {}
	for index, item in ipairs(value) do
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

local function getHolder()
	local holder
	pcall(function()
		if typeof(gethui) == "function" then
			holder = gethui()
		end
	end)
	if typeof(holder) ~= "Instance" then
		holder = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10)
	end
	return holder
end

local function showError(text)
	warn("[ixa] " .. tostring(text))

	local holder = getHolder()
	if not holder then
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "ixaError"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 10001
	gui.Parent = holder

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(360, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = Color3.fromRGB(30, 22, 26)
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

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 18)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 120, 130)
	title.Text = "[ixa] error"
	title.LayoutOrder = 1
	title.Parent = panel

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextColor3 = Color3.fromRGB(242, 236, 244)
	label.Text = tostring(text)
	label.LayoutOrder = 2
	label.Parent = panel

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(1, 0, 0, 32)
	close.BackgroundColor3 = Color3.fromRGB(45, 36, 48)
	close.AutoButtonColor = true
	close.Font = Enum.Font.GothamBold
	close.TextSize = 13
	close.TextColor3 = Color3.fromRGB(238, 232, 240)
	close.Text = "OK"
	close.LayoutOrder = 3
	close.Parent = panel

	local ccorner = Instance.new("UICorner")
	ccorner.CornerRadius = UDim.new(0, 8)
	ccorner.Parent = close

	local function destroy()
		pcall(function()
			gui:Destroy()
		end)
	end

	close.MouseButton1Click:Connect(destroy)

	pcall(function()
		task.delay(12, destroy)
	end)
end

local function httpGet(url)
	local lastError = "unknown"

	local ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(res) == "string" and #res > 0 then
		return res
	end
	if ok then
		lastError = "HttpGet returned an empty response"
	else
		lastError = tostring(res)
	end

	local fn = nil
	if typeof(request) == "function" then
		fn = request
	elseif typeof(http_request) == "function" then
		fn = http_request
	elseif typeof(syn) == "table" and typeof(syn.request) == "function" then
		fn = syn.request
	end

	if fn then
		local ok2, out = pcall(fn, { Url = url, Method = "GET" })
		if ok2 then
			if type(out) == "table" and type(out.Body) == "string" and #out.Body > 0 then
				return out.Body
			elseif type(out) == "string" and #out > 0 then
				return out
			end
			lastError = "request returned an empty response"
		else
			lastError = tostring(out)
		end
	end

	return nil, lastError
end

local function pick(list)
	if #list == 1 then
		return list[1]
	end

	local holder = getHolder()
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
	label.Text = "ixa: select a script"
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

	local cancel = Instance.new("TextButton")
	cancel.Size = UDim2.new(1, 0, 0, 28)
	cancel.BackgroundColor3 = Color3.fromRGB(28, 24, 31)
	cancel.AutoButtonColor = true
	cancel.Font = Enum.Font.GothamMedium
	cancel.TextSize = 11
	cancel.TextColor3 = Color3.fromRGB(160, 152, 165)
	cancel.Text = "Cancel"
	cancel.LayoutOrder = 900
	cancel.Parent = panel

	local kcorner = Instance.new("UICorner")
	kcorner.CornerRadius = UDim.new(0, 8)
	kcorner.Parent = cancel

	cancel.MouseButton1Click:Connect(function()
		finish(nil)
	end)

	local credit = Instance.new("TextLabel")
	credit.Size = UDim2.new(1, 0, 0, 14)
	credit.BackgroundTransparency = 1
	credit.Font = Enum.Font.Gotham
	credit.TextSize = 10
	credit.TextWrapped = true
	credit.TextColor3 = Color3.fromRGB(130, 124, 136)
	credit.Text = "loader by @Poiuytr · discord @poiytr12345678"
	credit.LayoutOrder = 901
	credit.Parent = panel

	while chosen == nil and gui.Parent do
		task.wait(0.05)
	end

	pcall(function()
		gui:Destroy()
	end)

	if chosen == nil or chosen == false then
		return nil
	end
	return chosen
end

local list = toList(entry)

if not list then
	print("ixa: no support for this game (GameId: " .. tostring(currentGameId) .. " | PlaceId: " .. tostring(currentPlaceId) .. ")")
	showError("No support for this game.")
	return
end

print("ixa: Game found! GameId: " .. tostring(currentGameId) .. " | PlaceId: " .. tostring(currentPlaceId))

local mode = pick(list)

if not mode then
	print("ixa: no script selected")
	return
end

print("ixa: loading " .. mode.Name)

local scriptText, fetchError = httpGet(mode.Url)

if not scriptText then
	print("ixa: fetch error: " .. tostring(fetchError))
	showError("Failed to download the script:\n" .. tostring(fetchError) .. "\n\n" .. mode.Url)
	return
end

scriptText = scriptText:gsub("^\239\187\191", "")
local trimmed = scriptText:match("^%s*(.-)%s*$") or scriptText

if trimmed:sub(1, 1) == "{" then
	print("ixa: API error response: " .. trimmed:sub(1, 300))
	showError("Server returned JSON instead of a script:\n" .. trimmed:sub(1, 300))
	return
end

local head = trimmed:lower()
if head:sub(1, 14) == "404: not found" then
	print("ixa: 404 not found: " .. mode.Url)
	showError("File not found on GitHub (404):\n" .. mode.Url)
	return
end
if head:sub(1, 15) == "<!doctype html" or head:sub(1, 6) == "<html>" then
	print("ixa: html response: " .. mode.Url)
	showError("Server returned HTML instead of a script:\n" .. mode.Url)
	return
end

local loaderFn = nil
if typeof(loadstring) == "function" then
	loaderFn = loadstring
elseif typeof(load) == "function" then
	loaderFn = function(src)
		return load(src, "@" .. mode.Url)
	end
end

if not loaderFn then
	print("ixa: loadstring unavailable")
	showError("loadstring is not available in this executor")
	return
end

local compiledScript, compileError = loaderFn(scriptText)

if not compiledScript then
	print("ixa: compile error: " .. tostring(compileError))
	showError("Compilation error:\n" .. tostring(compileError))
	return
end

print("ixa: Executing script...")

local execSuccess, execError
if typeof(debug) == "table" and typeof(debug.traceback) == "function" then
	execSuccess, execError = xpcall(compiledScript, debug.traceback)
else
	execSuccess, execError = pcall(compiledScript)
end

if not execSuccess then
	print("ixa: runtime error: " .. tostring(execError))
	showError("Runtime error:\n" .. tostring(execError))
end
