-- credit: @Poiuytr | main discord: @poiytr12345678

if not game:IsLoaded() then
	game.Loaded:Wait()
end

if game.GameId == 0 then
	local waitDeadline = os.clock() + 10
	while game.GameId == 0 and os.clock() < waitDeadline do
		task.wait(0.1)
	end
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function resetLoaderFlag()
	pcall(function()
		if typeof(getgenv) == "function" then
			getgenv().qwernLoaderLoaded = false
		end
	end)
end

do
	local ok, was = pcall(function()
		if typeof(getgenv) == "function" then
			local env = getgenv()
			local prev = env.qwernLoaderLoaded
			env.qwernLoaderLoaded = true
			return prev
		end
		return false
	end)
	if ok and was then
		return
	end
end

local GamesHub = {
	[71106427459865] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[128017425240405] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[10766954651] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/word%20game.lua",
	[3730079862] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/Examination.lua",
	[7623259179] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/null.lua",
}

local DISCORD_INVITE = "https://discord.gg/eSzBJJXqCJ"
local PROMO_INTERVAL = 30 * 60
local PROMO_VISIBLE_TIME = 25
local PROMO_STRINGS = {
	English = {
		Title = "Subscribe to our Discord",
		Hint = "Updates, scripts and support live there",
		Copy = "Copy",
		Done = "Done",
		Copied = "Link copied",
		Manual = "Copy it manually",
	},
	Russian = {
		Title = "Подпишись на Discord канал",
		Hint = "Там обновления, скрипты и поддержка",
		Copy = "Копировать",
		Done = "Готово",
		Copied = "Ссылка скопирована",
		Manual = "Скопируй вручную",
	},
}

local promoGui = nil
local promoFrame = nil
local promoParts = nil
local promoToken = 0
local promoCopied = false
local promoCopyFailed = false
local promoStopped = false

local function promoStrings()
	local language = "English"
	pcall(function()
		if type(InterfaceLanguage) == "string" then
			language = InterfaceLanguage
		elseif typeof(getgenv) == "function" and type(getgenv().InterfaceLanguage) == "string" then
			language = getgenv().InterfaceLanguage
		end
	end)
	return PROMO_STRINGS[language] or PROMO_STRINGS.English
end

local function copyPromoLink()
	local copied = false
	pcall(function()
		local fn = setclipboard or toclipboard or (typeof(syn) == "table" and syn.setclipboard)
		if type(fn) == "function" then
			fn(DISCORD_INVITE)
			copied = true
		end
	end)
	return copied
end

local function promoHolderParent()
	local env = (typeof(getgenv) == "function" and getgenv()) or nil
	local mainWindow = env and (env.__QwernHubWindow or env.__IxaHubWindow or env.__NULL_HUB_WINDOW)
	if mainWindow and mainWindow.Gui and typeof(mainWindow.Gui) == "Instance" and mainWindow.Gui.Parent then
		return mainWindow.Gui.Parent, mainWindow.Gui.DisplayOrder
	end
	local ok, hui = pcall(function()
		if typeof(gethui) == "function" then
			return gethui()
		end
	end)
	if ok and typeof(hui) == "Instance" then
		return hui, 10001
	end
	local coreOk, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if coreOk and coreGui then
		local canParent = pcall(function()
			local probe = Instance.new("Folder")
			probe.Parent = coreGui
			probe:Destroy()
		end)
		if canParent then
			return coreGui, 10001
		end
	end
	return nil, 10001
end

local function clearExternalPromos(parent)
	if not parent then
		return
	end
	pcall(function()
		for _, child in ipairs(parent:GetChildren()) do
			if child ~= promoGui and child:IsA("ScreenGui") then
				if child.Name == "QwernPromo" or child.Name == "IxaHubPromo" or child.Name == "HallowedReactorDiscordPromo" then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end)
end

local function promoHolder()
	if promoGui and promoGui.Parent then
		clearExternalPromos(promoGui.Parent)
		return promoGui
	end
	promoGui = nil
	local parent, order = promoHolderParent()
	local playerGui
	if not parent then
		playerGui = player:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			local waited = player:WaitForChild("PlayerGui", 10)
			playerGui = waited and waited:IsA("PlayerGui") and waited or player:FindFirstChildOfClass("PlayerGui")
		end
		parent = playerGui
	end
	if not parent then
		return nil
	end
	clearExternalPromos(parent)
	local gui = Instance.new("ScreenGui")
	gui.Name = "QwernPromo"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = math.max((order or 10001) + 1, 10002)
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function()
		if typeof(syn) == "table" and type(syn.protect_gui) == "function" then
			syn.protect_gui(gui)
		elseif typeof(protectgui) == "function" then
			protectgui(gui)
		end
	end)
	local inserted = pcall(function()
		gui.Parent = parent
	end)
	if not inserted or not gui.Parent then
		if playerGui == nil then
			playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10)
		end
		if not playerGui then
			gui:Destroy()
			return nil
		end
		clearExternalPromos(playerGui)
		gui.Parent = playerGui
	end
	promoGui = gui
	return gui
end

local function refreshPromoToastTexts()
	if not promoParts then
		return
	end
	local strings = promoStrings()
	pcall(function()
		promoParts.title.Text = strings.Title
		if promoCopied then
			promoParts.copy.Text = strings.Done
			promoParts.hint.Text = strings.Copied .. ": " .. DISCORD_INVITE
			promoParts.hint.TextColor3 = Color3.fromRGB(170, 226, 178)
		elseif promoCopyFailed then
			promoParts.copy.Text = strings.Copy
			promoParts.hint.Text = strings.Manual .. ": " .. DISCORD_INVITE
			promoParts.hint.TextColor3 = Color3.fromRGB(232, 200, 140)
		else
			promoParts.copy.Text = strings.Copy
			promoParts.hint.Text = strings.Hint
			promoParts.hint.TextColor3 = Color3.fromRGB(170, 162, 175)
		end
	end)
end

local function buildPromoToast(gui)
	local strings = promoStrings()
	local toast = Instance.new("Frame")
	toast.Name = "DiscordPromo"
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.Position = UDim2.new(0.5, 0, 0, 14)
	toast.Size = UDim2.new(1, -24, 0, 0)
	toast.AutomaticSize = Enum.AutomaticSize.Y
	toast.BackgroundColor3 = Color3.fromRGB(27, 21, 30)
	toast.BackgroundTransparency = 0.04
	toast.BorderSizePixel = 0
	toast.ZIndex = 100
	toast.Parent = gui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(382, 1000)
	sizeConstraint.Parent = toast

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = toast

	local popScale = Instance.new("UIScale")
	popScale.Scale = 0.95
	popScale.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(232, 164, 205)
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = toast

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	padding.Parent = toast

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Left
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = toast

	local header = Instance.new("Frame")
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 22)
	header.LayoutOrder = 1
	header.Parent = toast

	local badge = Instance.new("TextLabel")
	badge.AnchorPoint = Vector2.new(0, 0.5)
	badge.Position = UDim2.new(0, 0, 0.5, 0)
	badge.Size = UDim2.fromOffset(62, 18)
	badge.BackgroundColor3 = Color3.fromRGB(232, 164, 205)
	badge.BackgroundTransparency = 0.82
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 9
	badge.TextColor3 = Color3.fromRGB(246, 218, 234)
	badge.Text = "DISCORD"
	badge.Parent = header

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 5)
	badgeCorner.Parent = badge

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(72, 0)
	title.Size = UDim2.new(1, -98, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextColor3 = Color3.fromRGB(242, 236, 244)
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Text = strings.Title
	title.Parent = header

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0.5)
	closeButton.Position = UDim2.new(1, 0, 0.5, 0)
	closeButton.Size = UDim2.fromOffset(20, 20)
	closeButton.BackgroundTransparency = 1
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 17
	closeButton.TextColor3 = Color3.fromRGB(150, 140, 152)
	closeButton.Text = "\195\151"
	closeButton.AutoButtonColor = false
	closeButton.ZIndex = 101
	closeButton.Parent = header

	local hint = Instance.new("TextLabel")
	hint.BackgroundTransparency = 1
	hint.Size = UDim2.new(1, 0, 0, 16)
	hint.Font = Enum.Font.Gotham
	hint.TextSize = 12
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.TextColor3 = Color3.fromRGB(170, 162, 175)
	hint.TextTruncate = Enum.TextTruncate.AtEnd
	hint.Text = strings.Hint
	hint.LayoutOrder = 2
	hint.Parent = toast

	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 32)
	row.LayoutOrder = 3
	row.Parent = toast

	local linkButton = Instance.new("TextButton")
	linkButton.Size = UDim2.new(1, -88, 1, 0)
	linkButton.BackgroundColor3 = Color3.fromRGB(43, 33, 45)
	linkButton.BackgroundTransparency = 0.15
	linkButton.AutoButtonColor = false
	linkButton.Font = Enum.Font.GothamMedium
	linkButton.TextSize = 12
	linkButton.TextColor3 = Color3.fromRGB(232, 180, 210)
	linkButton.TextXAlignment = Enum.TextXAlignment.Left
	linkButton.TextYAlignment = Enum.TextYAlignment.Center
	linkButton.TextTruncate = Enum.TextTruncate.AtEnd
	linkButton.Text = DISCORD_INVITE
	linkButton.ClipsDescendants = true
	linkButton.Parent = row

	local linkPadding = Instance.new("UIPadding")
	linkPadding.PaddingLeft = UDim.new(0, 10)
	linkPadding.PaddingRight = UDim.new(0, 10)
	linkPadding.Parent = linkButton

	local linkCorner = Instance.new("UICorner")
	linkCorner.CornerRadius = UDim.new(0, 8)
	linkCorner.Parent = linkButton

	local copyButton = Instance.new("TextButton")
	copyButton.AnchorPoint = Vector2.new(1, 0)
	copyButton.Position = UDim2.new(1, 0, 0, 0)
	copyButton.Size = UDim2.fromOffset(80, 32)
	copyButton.BackgroundColor3 = Color3.fromRGB(232, 164, 205)
	copyButton.AutoButtonColor = false
	copyButton.Font = Enum.Font.GothamBold
	copyButton.TextSize = 12
	copyButton.TextColor3 = Color3.fromRGB(32, 24, 32)
	copyButton.Text = strings.Copy
	copyButton.Parent = row

	local copyCorner = Instance.new("UICorner")
	copyCorner.CornerRadius = UDim.new(0, 8)
	copyCorner.Parent = copyButton

	return toast, {
		scale = popScale,
		title = title,
		hint = hint,
		link = linkButton,
		copy = copyButton,
		close = closeButton,
	}
end

local function showPromoToast()
	if promoStopped then
		return false
	end
	local gui = promoHolder()
	if not gui then
		return false
	end
	if promoFrame then
		promoParts = nil
		pcall(function()
			promoFrame:Destroy()
		end)
		promoFrame = nil
	end
	promoToken = promoToken + 1
	local token = promoToken
	promoCopied = false
	promoCopyFailed = false
	local toast, parts = buildPromoToast(gui)
	promoFrame = toast
	promoParts = parts
	local TweenService = game:GetService("TweenService")

	local function hideToast()
		if promoToken ~= token or not toast.Parent then
			return
		end
		promoToken = promoToken + 1
		if promoFrame == toast then
			promoFrame = nil
			promoParts = nil
		end
		pcall(function()
			if parts.scale then
				TweenService:Create(parts.scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Scale = 0.9,
				}):Play()
			end
			TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0, -6),
			}):Play()
		end)
		task.delay(0.24, function()
			pcall(function()
				if toast.Parent then
					toast:Destroy()
				end
			end)
		end)
	end

	local function handleCopy()
		promoCopied = copyPromoLink()
		promoCopyFailed = not promoCopied
		refreshPromoToastTexts()
		local copiedNow = promoCopied
		task.delay(2.5, function()
			if not copiedNow or promoToken ~= token or not toast.Parent then
				return
			end
			promoCopied = false
			promoCopyFailed = false
			refreshPromoToastTexts()
		end)
		if not copiedNow then
			task.delay(3, function()
				if promoToken ~= token or not toast.Parent then
					return
				end
				promoCopyFailed = false
				refreshPromoToastTexts()
			end)
		end
	end

	parts.copy.MouseButton1Click:Connect(handleCopy)
	parts.link.MouseButton1Click:Connect(handleCopy)
	parts.close.MouseButton1Click:Connect(hideToast)
	parts.copy.MouseEnter:Connect(function()
		pcall(function()
			parts.copy.BackgroundColor3 = Color3.fromRGB(246, 190, 222)
		end)
	end)
	parts.copy.MouseLeave:Connect(function()
		pcall(function()
			parts.copy.BackgroundColor3 = Color3.fromRGB(232, 164, 205)
		end)
	end)
	parts.link.MouseEnter:Connect(function()
		pcall(function()
			parts.link.BackgroundTransparency = 0.02
		end)
	end)
	parts.link.MouseLeave:Connect(function()
		pcall(function()
			parts.link.BackgroundTransparency = 0.15
		end)
	end)
	pcall(function()
		if parts.scale then
			TweenService:Create(parts.scale, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Scale = 1,
			}):Play()
		end
	end)
	task.delay(PROMO_VISIBLE_TIME, hideToast)
	return true
end

local function stopPromo()
	promoStopped = true
	promoToken = promoToken + 1
	pcall(function()
		if promoFrame then
			promoFrame:Destroy()
		end
		if promoGui then
			promoGui:Destroy()
		end
	end)
	promoFrame, promoGui, promoParts = nil, nil, nil
end

pcall(function()
	if typeof(getgenv) == "function" then
		local env = getgenv()
		if type(env.__QwernStopPromo) == "function" then
			pcall(env.__QwernStopPromo)
		end
		if type(env.__IxaHubStopPromo) == "function" then
			pcall(env.__IxaHubStopPromo)
		end
		env.__QwernStopPromo = stopPromo
	end
end)

task.spawn(function()
	task.wait(1)
	while not promoStopped do
		local ok, shown = pcall(showPromoToast)
		if not ok then
			warn("[Qwern] Discord toast error: " .. tostring(shown))
		end
		shown = ok and shown
		if not shown then
			task.wait(2)
		else
			local waited = 0
			while waited < PROMO_INTERVAL do
				if promoStopped then
					return
				end
				if promoGui and promoGui.Parent then
					clearExternalPromos(promoGui.Parent)
				end
				task.wait(1)
				waited = waited + 1
			end
		end
	end
end)

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
	warn("[Qwern] " .. tostring(text))

	local holder = getHolder()
	if not holder then
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "QwernError"
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
	title.Text = "[Qwern] error"
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
	gui.Name = "QwernPick"
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
	label.Text = "Qwern: select a script"
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
	resetLoaderFlag()
	print("Qwern: no support for this game (GameId: " .. tostring(currentGameId) .. " | PlaceId: " .. tostring(currentPlaceId) .. ")")
	showError("No support for this game.")
	return
end

print("Qwern: Game found! GameId: " .. tostring(currentGameId) .. " | PlaceId: " .. tostring(currentPlaceId))

local mode = pick(list)

if not mode then
	resetLoaderFlag()
	print("Qwern: no script selected")
	return
end

print("Qwern: loading " .. mode.Name)

local scriptText, fetchError = httpGet(mode.Url)

if not scriptText then
	resetLoaderFlag()
	print("Qwern: fetch error: " .. tostring(fetchError))
	showError("Failed to download the script:\n" .. tostring(fetchError) .. "\n\n" .. mode.Url)
	return
end

scriptText = scriptText:gsub("^\239\187\191", "")
local trimmed = scriptText:match("^%s*(.-)%s*$") or scriptText

if trimmed:sub(1, 1) == "{" then
	resetLoaderFlag()
	print("Qwern: API error response: " .. trimmed:sub(1, 300))
	showError("Server returned JSON instead of a script:\n" .. trimmed:sub(1, 300))
	return
end

local head = trimmed:lower()
if head:sub(1, 14) == "404: not found" then
	resetLoaderFlag()
	print("Qwern: 404 not found: " .. mode.Url)
	showError("File not found on GitHub (404):\n" .. mode.Url)
	return
end
if head:sub(1, 15) == "<!doctype html" or head:sub(1, 6) == "<html>" then
	resetLoaderFlag()
	print("Qwern: html response: " .. mode.Url)
	showError("Server returned HTML instead of a script:\n" .. mode.Url)
	return
end

scriptText = scriptText:gsub("https://discord%.gg/BpfKcTbap2", DISCORD_INVITE)

local loaderFn = nil
if typeof(loadstring) == "function" then
	loaderFn = loadstring
elseif typeof(load) == "function" then
	loaderFn = function(src)
		return load(src, "@" .. mode.Url)
	end
end

if not loaderFn then
	resetLoaderFlag()
	print("Qwern: loadstring unavailable")
	showError("loadstring is not available in this executor")
	return
end

local compiledScript, compileError = loaderFn(scriptText)

if not compiledScript then
	resetLoaderFlag()
	print("Qwern: compile error: " .. tostring(compileError))
	showError("Compilation error:\n" .. tostring(compileError))
	return
end

print("Qwern: Executing script...")

local execSuccess, execError
if typeof(debug) == "table" and typeof(debug.traceback) == "function" then
	execSuccess, execError = xpcall(compiledScript, debug.traceback)
else
	execSuccess, execError = pcall(compiledScript)
end

pcall(function()
	if typeof(getgenv) == "function" then
		local env = getgenv()
		if type(env.__IxaHubStopPromo) == "function" then
			pcall(env.__IxaHubStopPromo)
			env.__IxaHubStopPromo = nil
		end
		env.__QwernStopPromo = stopPromo
	end
end)

if not execSuccess then
	resetLoaderFlag()
	print("Qwern: runtime error: " .. tostring(execError))
	showError("Runtime error:\n" .. tostring(execError))
end
