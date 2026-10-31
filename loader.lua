if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local GamesHub = {
    [5041144419] = "https://raw.githubusercontent.com/poiuytr363636-prog/Scripts/refs/heads/main/Scp%20rolepaly.lua", -- 
}

local currentGameId  = game.GameId
local currentPlaceId = game.PlaceId

local scriptToLoad = GamesHub[currentGameId]

if not scriptToLoad or scriptToLoad == "" then
    print("ixa: game not supported (GameId: " .. tostring(currentGameId) .. ")")
    player:Kick("\n[ixa]\nGame not supported.\nGameId: " .. tostring(currentGameId))
    return
end

print("ixa: Game found! GameId: " .. tostring(currentGameId) .. " | PlaceId: " .. tostring(currentPlaceId))

local fetchSuccess, scriptText = pcall(function()
    return game:HttpGet(scriptToLoad)
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
