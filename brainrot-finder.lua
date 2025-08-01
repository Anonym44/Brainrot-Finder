-- Brainrot Finder Pro - Advanced Roblox Pet Collection Game Scanner
-- Features: Real-time scanning, Discord notifications, server hopping, base scanning
-- Enhanced with better error handling, multiple game support, and advanced features
-- Version: 2.0
-- Created By Kurd <@893138460213403748>
-- Date: July 31, 2025

-- Load WindUI library with multiple fallback URLs and error handling
local ui
local uiLoaded = false
local windUIUrls = {
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua",
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/AlexR32/Roblox/main/BracketV3.lua"
}

for _, url in ipairs(windUIUrls) do
    local success, result = pcall(function()
        ui = loadstring(game:HttpGet(url))()
        return ui
    end)
    
    if success and ui then
        uiLoaded = true
        print("[Brainrot Finder] Successfully loaded WindUI from: " .. url)
        break
    else
        warn("[Brainrot Finder] Failed to load from " .. url .. ": " .. tostring(result))
    end
end

if not uiLoaded then
    -- Create basic notification system as fallback
    ui = {
        Notify = function(self, data)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = data.Title or "Brainrot Finder",
                Text = data.Content or "",
                Duration = data.Duration or 5
            })
        end,
        CreateWindow = function(self, data)
            error("WindUI failed to load. Please check your executor's HTTP capabilities.")
            return nil
        end
    }
    warn("Failed to load WindUI library. Using fallback notification system.")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚠️ UI Error",
        Text = "WindUI failed to load. Please restart your executor and try again.",
        Duration = 10
    })
    return
end

-- Service manager for easy access to Roblox services
local svc = setmetatable({}, {
    __index = function(t, k)
        local s = game:GetService(k)
        t[k] = s
        return s
    end
})

-- Configuration table storing all settings and state
local cfg = {
    -- Main scanner settings
    enabled = false,
    mutenabled = false,
    baseenabled = false,
    
    -- Discord webhook configuration
    webhook = "",
    
    -- Server hopping settings
    hoptime = 300, -- Default 5 minutes
    hopEnabled = true,
    maxHops = 10, -- Maximum hops per session
    hopCount = 0,
    
    -- Animal and mutation data
    brainrots = {},
    mutations = {"Gold", "Diamond", "Rainbow", "Candy", "Shiny", "Crystal", "Mystic", "Shadow", "Light", "Prismatic"},
    
    -- User selections
    selected = {
        brainrots = {},
        mutations = {}
    },
    
    -- Tracking found items to prevent spam
    found = {},
    foundBases = {},
    
    -- Active connections and tasks
    cons = {},
    
    -- Notification settings
    notifySound = true,
    notifyDuration = 8,
    
    -- Advanced settings
    scanDelay = 0.1,
    webhookRetries = 3,
    debugMode = false,
    
    -- Statistics
    stats = {
        scansPerformed = 0,
        brainrotsFound = 0,
        mutationsFound = 0,
        baseScansPerformed = 0,
        sessionStart = tick()
    },
    
    -- Cache management
    maxCacheSize = 1000,
    cacheCleanupInterval = 300 -- 5 minutes
}

-- Utility function to safely check if value exists in table
local function tableFind(tbl, value)
    for i, v in pairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

-- Cache cleanup function to prevent memory issues
local function cleanupCache()
    local currentTime = tick()
    local cleaned = 0
    
    -- Clean found animals cache
    for key, timestamp in pairs(cfg.found) do
        if currentTime - timestamp > cfg.cacheCleanupInterval then
            cfg.found[key] = nil
            cleaned = cleaned + 1
        end
    end
    
    -- Clean found bases cache
    for key, timestamp in pairs(cfg.foundBases) do
        if currentTime - timestamp > cfg.cacheCleanupInterval then
            cfg.foundBases[key] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cfg.debugMode and cleaned > 0 then
        print("[Brainrot Finder] Cleaned " .. cleaned .. " cached entries")
    end
end

-- Enhanced function to retrieve all available brainrots from the game
local function getBrainrots()
    cfg.brainrots = {}
    
    -- Primary paths for different game structures
    local searchPaths = {
        {svc.ReplicatedStorage, "Models", "Animals"},
        {svc.ReplicatedStorage, "Data", "Pets"},
        {svc.ReplicatedStorage, "Assets", "Animals"},
        {svc.ReplicatedStorage, "Config", "Pets"},
        {svc.ReplicatedStorage, "Pets"},
        {svc.ReplicatedStorage, "Animals"},
        {svc.Workspace, "Pets"},
        {svc.Workspace, "Animals"},
        {svc.Workspace, "Game", "Animals"},
        {svc.StarterGui, "Assets", "Pets"}
    }
    
    -- Search through all possible paths
    for _, pathInfo in pairs(searchPaths) do
        local current = pathInfo[1]
        
        -- Navigate through the path
        for i = 2, #pathInfo do
            if current then
                current = current:FindFirstChild(pathInfo[i])
            end
        end
        
        -- If we found a valid container, extract animal names
        if current then
            for _, v in pairs(current:GetChildren()) do
                if v:IsA("Model") or v:IsA("Folder") then
                    local name = v.Name
                    if name and name ~= "" and not tableFind(cfg.brainrots, name) then
                        table.insert(cfg.brainrots, name)
                    end
                elseif v:IsA("StringValue") or v:IsA("ObjectValue") then
                    local name = v.Value
                    if name and name ~= "" and not tableFind(cfg.brainrots, name) then
                        table.insert(cfg.brainrots, tostring(name))
                    end
                end
            end
        end
    end
    
    -- Try to get animals from RemoteEvents/Functions (some games store data differently)
    local remotes = svc.ReplicatedStorage:FindFirstChild("Remotes") or svc.ReplicatedStorage:FindFirstChild("Events")
    if remotes then
        local getAnimalsRemote = remotes:FindFirstChild("GetAnimals") or remotes:FindFirstChild("GetPets")
        if getAnimalsRemote and getAnimalsRemote:IsA("RemoteFunction") then
            local success, result = pcall(function()
                return getAnimalsRemote:InvokeServer()
            end)
            
            if success and type(result) == "table" then
                for _, animalData in pairs(result) do
                    local name = animalData.Name or animalData.name or animalData.id
                    if name and not tableFind(cfg.brainrots, name) then
                        table.insert(cfg.brainrots, tostring(name))
                    end
                end
            end
        end
    end
    
    -- Remove common non-animal entries
    local excludeList = {"Base", "Spawn", "Effect", "GUI", "Sound", "Light", "Part", "Attachment"}
    local filtered = {}
    
    for _, name in pairs(cfg.brainrots) do
        local shouldInclude = true
        for _, exclude in pairs(excludeList) do
            if string.find(string.lower(name), string.lower(exclude)) then
                shouldInclude = false
                break
            end
        end
        if shouldInclude then
            table.insert(filtered, name)
        end
    end
    
    cfg.brainrots = filtered
    
    -- Sort alphabetically for better UX
    table.sort(cfg.brainrots)
    
    if cfg.debugMode then
        print("[Brainrot Finder] Found " .. #cfg.brainrots .. " brainrots")
        if #cfg.brainrots > 0 then
            print("Sample animals: " .. table.concat({cfg.brainrots[1], cfg.brainrots[math.min(5, #cfg.brainrots)]}, ", "))
        end
    end
    
    return cfg.brainrots
end

-- Enhanced Discord webhook function with retry logic and rich embeds
local function sendHook(title, desc, color, embedData)
    if cfg.webhook == "" then return end
    
    color = color or 0x00ff00 -- Default green color
    
    spawn(function()
        local retries = 0
        local success = false
        
        while retries < cfg.webhookRetries and not success do
            local embedContent = {
                title = title,
                description = desc,
                color = color,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
                footer = {
                    text = "Brainrot Finder Pro | " .. os.date("%H:%M:%S"),
                    icon_url = "https://cdn.discordapp.com/emojis/1234567890123456789.png" -- Optional icon
                },
                fields = {}
            }
            
            -- Add custom fields if provided
            if embedData then
                if embedData.thumbnail then
                    embedContent.thumbnail = {url = embedData.thumbnail}
                end
                if embedData.fields then
                    embedContent.fields = embedData.fields
                end
                if embedData.author then
                    embedContent.author = embedData.author
                end
            end
            
            -- Add server ID field prominently
            table.insert(embedContent.fields, {
                name = "🎯 Server ID zum Beitreten",
                value = "```" .. game.JobId .. "```\nKopieren Sie diese ID und fügen Sie sie in Roblox ein!",
                inline = false
            })
            
            -- Add statistics field
            table.insert(embedContent.fields, {
                name = "📊 Session Stats",
                value = string.format("Scans: %d | Found: %d | Uptime: %ds", 
                    cfg.stats.scansPerformed, 
                    cfg.stats.brainrotsFound + cfg.stats.mutationsFound,
                    math.floor(tick() - cfg.stats.sessionStart)
                ),
                inline = true
            })
            
            local ok, response = pcall(function()
                return request({
                    Url = cfg.webhook,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = svc.HttpService:JSONEncode({
                        username = "Brainrot Finder Pro",
                        avatar_url = "https://cdn.discordapp.com/emojis/1234567890123456789.png", -- Optional avatar
                        embeds = {embedContent}
                    })
                })
            end)
            
            if ok and response and response.StatusCode >= 200 and response.StatusCode < 300 then
                success = true
                if cfg.debugMode then
                    print("[Brainrot Finder] Webhook sent successfully (Status: " .. response.StatusCode .. ")")
                end
            else
                retries = retries + 1
                if cfg.debugMode then
                    local errorMsg = response and ("Status: " .. response.StatusCode) or "Network error"
                    print("[Brainrot Finder] Webhook failed (" .. errorMsg .. "), retry " .. retries .. "/" .. cfg.webhookRetries)
                end
                wait(math.min(retries * 2, 10)) -- Exponential backoff with max 10s
            end
        end
        
        if not success then
            ui:Notify({
                Title = "⚠️ Webhook Error",
                Content = "Failed to send Discord notification after " .. cfg.webhookRetries .. " attempts. Check your webhook URL.",
                Duration = 5
            })
        end
    end)
end

-- Test webhook function
local function testWebhook()
    if cfg.webhook == "" then
        ui:Notify({
            Title = "⚠️ No Webhook",
            Content = "Please enter a Discord webhook URL first!",
            Duration = 3
        })
        return
    end
    
    local testEmbed = {
        fields = {
            {name = "🔧 Test Status", value = "Connection successful!", inline = true},
            {name = "🎯 Scanner Status", value = cfg.enabled and "Active" or "Inactive", inline = true}
        }
    }
    
    sendHook("🧪 Test Notification", "Brainrot Finder Pro is working correctly!", 0x00ff00, testEmbed)
    
    ui:Notify({
        Title = "📡 Test Sent",
        Content = "Check your Discord channel for the test message!",
        Duration = 3
    })
end

-- Enhanced server hopping function with better server selection and rate limiting
local function hop()
    -- Check hop limits
    if cfg.hopCount >= cfg.maxHops then
        ui:Notify({
            Title = "🔄 Hop Limit Reached",
            Content = "Maximum hops (" .. cfg.maxHops .. ") reached for this session",
            Duration = 5
        })
        return
    end
    
    if cfg.debugMode then
        print("[Brainrot Finder] Attempting to server hop... (Hop " .. (cfg.hopCount + 1) .. "/" .. cfg.maxHops .. ")")
    end
    
    local servers = {}
    local ok, data = pcall(function()
        return request({
            Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100",
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/WinInet"
            }
        }).Body
    end)
    
    if ok then
        local decoded, body = pcall(svc.HttpService.JSONDecode, svc.HttpService, data)
        if decoded and body.data then
            for _, server in pairs(body.data) do
                -- Enhanced server filtering
                local playerRatio = server.playing / server.maxPlayers
                local isGoodServer = server.playing < server.maxPlayers and 
                                   server.id ~= game.JobId and 
                                   server.playing >= 1 and -- At least 1 player
                                   playerRatio < 0.85 and -- Not too crowded
                                   playerRatio > 0.1 -- Not too empty
                
                if isGoodServer then
                    table.insert(servers, {
                        id = server.id,
                        players = server.playing,
                        maxPlayers = server.maxPlayers,
                        ping = server.ping or 0
                    })
                end
            end
            
            -- Sort servers by player count (prefer medium population)
            table.sort(servers, function(a, b)
                local aRatio = a.players / a.maxPlayers
                local bRatio = b.players / b.maxPlayers
                -- Prefer servers with 20-60% capacity
                local aScore = math.abs(0.4 - aRatio)
                local bScore = math.abs(0.4 - bRatio)
                return aScore < bScore
            end)
        end
    end
    
    if #servers > 0 then
        local targetServer = servers[1] -- Use best server instead of random
        cfg.hopCount = cfg.hopCount + 1
        
        if cfg.debugMode then
            print(string.format("[Brainrot Finder] Hopping to server: %s (%d/%d players)", 
                targetServer.id, targetServer.players, targetServer.maxPlayers))
        end
        
        local hopEmbed = {
            fields = {
                {name = "🎯 Target Server", value = string.sub(targetServer.id, 1, 12) .. "...", inline = true},
                {name = "👥 Players", value = targetServer.players .. "/" .. targetServer.maxPlayers, inline = true},
                {name = "🔄 Hop Count", value = cfg.hopCount .. "/" .. cfg.maxHops, inline = true}
            }
        }
        
        sendHook("🔄 Server Hop", "Moving to a new server for better scanning opportunities!", 0xffaa00, hopEmbed)
        
        ui:Notify({
            Title = "🔄 Server Hopping",
            Content = "Moving to server with " .. targetServer.players .. " players...",
            Duration = 3
        })
        
        wait(1) -- Brief delay before teleport
        svc.TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, svc.Players.LocalPlayer)
    else
        if cfg.debugMode then
            print("[Brainrot Finder] No suitable servers found for hopping")
        end
        
        ui:Notify({
            Title = "⚠️ No Servers",
            Content = "No suitable servers found for hopping",
            Duration = 5
        })
    end
end

-- Enhanced main scanning function for moving animals
local function scan()
    if not cfg.enabled then return end
    
    cfg.stats.scansPerformed = cfg.stats.scansPerformed + 1
    
    -- Multiple possible locations for animals in different games
    local animalContainers = {
        svc.Workspace:FindFirstChild("MovingAnimals"),
        svc.Workspace:FindFirstChild("Pets"),
        svc.Workspace:FindFirstChild("Animals"),
        svc.Workspace:FindFirstChild("SpawnedPets"),
        svc.Workspace:FindFirstChild("ActiveAnimals"),
        svc.Workspace:FindFirstChild("Game") and svc.Workspace.Game:FindFirstChild("Animals"),
        svc.Workspace:FindFirstChild("World") and svc.Workspace.World:FindFirstChild("Pets")
    }
    
    local foundAnimal = false
    
    for _, container in pairs(animalContainers) do
        if container then
            foundAnimal = true
            
            for _, model in pairs(container:GetChildren()) do
                if model:IsA("Model") then
                    -- Multiple ways to get animal name and mutation
                    local idx = model:GetAttribute("Index") or 
                               model:GetAttribute("Name") or 
                               model:GetAttribute("PetName") or 
                               model:GetAttribute("AnimalName") or
                               model.Name
                    
                    local mut = model:GetAttribute("Mutation") or 
                               model:GetAttribute("Rarity") or
                               model:GetAttribute("Type") or
                               model:GetAttribute("Special")
                    
                    -- Check for name in StringValues or GUI elements
                    if not idx or idx == "" then
                        local possibleNames = {
                            model:FindFirstChild("NameTag"),
                            model:FindFirstChild("DisplayName"),
                            model:FindFirstChild("PetName"),
                            model:FindFirstChild("AnimalName"),
                            model:FindFirstChild("Name", true) -- Recursive search
                        }
                        
                        for _, nameObj in pairs(possibleNames) do
                            if nameObj then
                                if nameObj:IsA("StringValue") then
                                    idx = nameObj.Value
                                elseif nameObj:IsA("TextLabel") then
                                    idx = nameObj.Text
                                elseif nameObj:GetAttribute("Text") then
                                    idx = nameObj:GetAttribute("Text")
                                end
                                if idx and idx ~= "" then break end
                            end
                        end
                    end
                    
                    -- Check for mutation in various ways
                    if not mut or mut == "" then
                        local possibleMuts = {
                            model:FindFirstChild("Mutation"),
                            model:FindFirstChild("Rarity"),
                            model:FindFirstChild("Type"),
                            model:FindFirstChild("Special")
                        }
                        
                        for _, mutObj in pairs(possibleMuts) do
                            if mutObj then
                                if mutObj:IsA("StringValue") then
                                    mut = mutObj.Value
                                elseif mutObj:IsA("TextLabel") then
                                    mut = mutObj.Text
                                elseif mutObj:GetAttribute("Text") then
                                    mut = mutObj:GetAttribute("Text")
                                end
                                if mut and mut ~= "" then break end
                            end
                        end
                    end
                    
                    if idx and idx ~= "" then
                        local key = tostring(model:GetDebugId()) .. "_" .. tostring(idx)
                        local currentTime = tick()
                        
                        -- Use timestamp-based caching to allow re-detection after some time
                        if not cfg.found[key] or (currentTime - cfg.found[key]) > 60 then -- Re-allow after 1 minute
                            local notify, info = false, {title = "", desc = "", color = 0x00ff00, embedData = {}}
                            
                            -- Check for brainrot matches (case-insensitive, partial matching)
                            for _, brainrot in pairs(cfg.selected.brainrots) do
                                local idxLower = string.lower(tostring(idx))
                                local brainrotLower = string.lower(tostring(brainrot))
                                
                                if idxLower == brainrotLower or string.find(idxLower, brainrotLower) then
                                    notify = true
                                    cfg.stats.brainrotsFound = cfg.stats.brainrotsFound + 1
                                    info.title = "🎯 BRAINROT FOUND!"
                                    info.desc = "**🔥 RARE ANIMAL DETECTED! 🔥**\n**Animal:** " .. tostring(idx) .. "\n\n**🎯 Server ID:** `" .. game.JobId .. "`\n📋 *Kopieren Sie die Server-ID oben und fügen Sie sie in Roblox ein, um diesem Server beizutreten!*"
                                    info.color = 0xff0000 -- Red for brainrot
                                    
                                    info.embedData.fields = {
                                        {name = "🎯 Animal Name", value = tostring(idx), inline = true},
                                        {name = "📍 Location", value = container.Name, inline = true}
                                    }
                                    
                                    if mut and mut ~= "" then
                                        info.desc = info.desc .. "\n**✨ Mutation:** " .. tostring(mut)
                                        info.color = 0xff6600 -- Orange for brainrot with mutation
                                        table.insert(info.embedData.fields, {name = "✨ Mutation", value = tostring(mut), inline = true})
                                    end
                                    break
                                end
                            end
                            
                            -- Check for mutation matches if not already notified
                            if not notify and cfg.mutenabled and mut and mut ~= "" then
                                for _, mutation in pairs(cfg.selected.mutations) do
                                    local mutLower = string.lower(tostring(mut))
                                    local mutationLower = string.lower(tostring(mutation))
                                    
                                    if mutLower == mutationLower or string.find(mutLower, mutationLower) then
                                        notify = true
                                        cfg.stats.mutationsFound = cfg.stats.mutationsFound + 1
                                        info.title = "✨ MUTATION FOUND!"
                                        info.desc = "**⚡ SPECIAL MUTATION DETECTED! ⚡**\n**Animal:** " .. tostring(idx) .. "\n**Mutation:** " .. tostring(mut) .. "\n\n**🎯 Server ID:** `" .. game.JobId .. "`\n📋 *Kopieren Sie die Server-ID oben und fügen Sie sie in Roblox ein, um diesem Server beizutreten!*"
                                        info.color = 0x9900ff -- Purple for mutation
                                        
                                        info.embedData.fields = {
                                            {name = "🐾 Animal", value = tostring(idx), inline = true},
                                            {name = "✨ Mutation", value = tostring(mut), inline = true},
                                            {name = "📍 Location", value = container.Name, inline = true}
                                        }
                                        break
                                    end
                                end
                            end
                            
                            if notify then
                                cfg.found[key] = currentTime
                                
                                -- Add position information if available
                                if model.PrimaryPart then
                                    local pos = model.PrimaryPart.Position
                                    table.insert(info.embedData.fields, {
                                        name = "📍 Position", 
                                        value = string.format("(%.0f, %.0f, %.0f)", pos.X, pos.Y, pos.Z), 
                                        inline = true
                                    })
                                end
                                
                                sendHook(info.title, info.desc, info.color, info.embedData)
                                
                                ui:Notify({
                                    Title = info.title,
                                    Content = info.desc:gsub("%*%*", ""):gsub("\n", " • "),
                                    Duration = cfg.notifyDuration
                                })
                                
                                -- Enhanced notification sound
                                if cfg.notifySound then
                                    spawn(function()
                                        pcall(function()
                                            local sound = Instance.new("Sound")
                                            sound.SoundId = notify and cfg.stats.brainrotsFound > cfg.stats.mutationsFound 
                                                and "rbxassetid://131961136" -- Epic sound for brainrots
                                                or "rbxasset://sounds/electronicpingshort.wav" -- Standard sound for mutations
                                            sound.Volume = 0.7
                                            sound.Parent = svc.SoundService
                                            sound:Play()
                                            sound.Ended:Connect(function()
                                                sound:Destroy()
                                            end)
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Debug info for scanning
    if cfg.debugMode and cfg.stats.scansPerformed % 100 == 0 then
        print(string.format("[Brainrot Finder] Performed %d scans, found %d total items", 
            cfg.stats.scansPerformed, cfg.stats.brainrotsFound + cfg.stats.mutationsFound))
    end
    
    wait(cfg.scanDelay) -- Prevent excessive CPU usage
end

-- Enhanced base scanning function
local function scanBase()
    if not cfg.baseenabled then return end
    
    local plots = svc.Workspace:FindFirstChild("Plots") or 
                  svc.Workspace:FindFirstChild("Bases") or
                  svc.Workspace:FindFirstChild("Houses")
    
    if not plots then return end
    
    for _, plot in pairs(plots:GetChildren()) do
        if plot:IsA("Model") then
            local owner = ""
            
            -- Multiple ways to get plot owner
            local plotSign = plot:FindFirstChild("PlotSign") or 
                           plot:FindFirstChild("Sign") or
                           plot:FindFirstChild("OwnerSign")
            
            if plotSign then
                if plotSign:FindFirstChild("SurfaceGui") then
                    local frame = plotSign.SurfaceGui:FindFirstChild("Frame")
                    if frame and frame:FindFirstChild("TextLabel") then
                        owner = frame.TextLabel.Text
                    end
                elseif plotSign:FindFirstChild("BillboardGui") then
                    local frame = plotSign.BillboardGui:FindFirstChild("Frame")
                    if frame and frame:FindFirstChild("TextLabel") then
                        owner = frame.TextLabel.Text
                    end
                end
            end
            
            -- Alternative owner detection
            if owner == "" then
                local ownerValue = plot:FindFirstChild("Owner") or plot:GetAttribute("Owner")
                if ownerValue then
                    owner = tostring(ownerValue.Value or ownerValue)
                end
            end
            
            if owner ~= "" and owner ~= svc.Players.LocalPlayer.Name then
                local podiums = plot:FindFirstChild("AnimalPodiums") or 
                              plot:FindFirstChild("Displays") or
                              plot:FindFirstChild("Showcases")
                
                if podiums then
                    for _, podium in pairs(podiums:GetChildren()) do
                        if podium:IsA("Model") then
                            local base = podium:FindFirstChild("Base") or podium:FindFirstChild("Stand")
                            
                            if base then
                                local spawn = base:FindFirstChild("Spawn") or base:FindFirstChild("Display")
                                
                                if spawn and spawn:FindFirstChild("Attachment") then
                                    local overhead = spawn.Attachment:FindFirstChild("AnimalOverhead") or
                                                   spawn.Attachment:FindFirstChild("PetDisplay")
                                    
                                    if overhead then
                                        local displayName = overhead:FindFirstChild("DisplayName") or
                                                          overhead:FindFirstChild("Name")
                                        local mutation = overhead:FindFirstChild("Mutation") or
                                                       overhead:FindFirstChild("Rarity")
                                        
                                        if displayName and displayName.Text ~= "" then
                                            local key = plot.Name .. "_" .. podium.Name .. "_" .. displayName.Text
                                            
                                            if not cfg.foundBases[key] then
                                                local notify, info = false, {title = "", desc = "", color = 0x00ff00}
                                                local brainrotName = displayName.Text
                                                local mutText = mutation and mutation.Text or ""
                                                
                                                -- Check for brainrot matches in bases
                                                for _, brainrot in pairs(cfg.selected.brainrots) do
                                                    if string.lower(brainrotName) == string.lower(brainrot) or
                                                       string.find(string.lower(brainrotName), string.lower(brainrot)) then
                                                        notify = true
                                                        info.title = "🏠 Base Brainrot Found!"
                                                        info.desc = "**Owner:** " .. owner .. "\n**Animal:** " .. brainrot
                                                        info.color = 0xff0000 -- Red for base brainrot
                                                        
                                                        if mutText ~= "" then
                                                            info.desc = info.desc .. "\n**Mutation:** " .. mutText
                                                            info.color = 0xff3300 -- Darker red for base brainrot with mutation
                                                        end
                                                        break
                                                    end
                                                end
                                                
                                                -- Check for mutation matches in bases
                                                if not notify and cfg.mutenabled and mutText ~= "" then
                                                    for _, mut in pairs(cfg.selected.mutations) do
                                                        if string.lower(mutText) == string.lower(mut) or
                                                           string.find(string.lower(mutText), string.lower(mut)) then
                                                            notify = true
                                                            info.title = "🏠 Base Mutation Found!"
                                                            info.desc = "**Owner:** " .. owner .. "\n**Animal:** " .. brainrotName .. "\n**Mutation:** " .. mut
                                                            info.color = 0x6600ff -- Darker purple for base mutation
                                                            break
                                                        end
                                                    end
                                                end
                                                
                                                if notify then
                                                    cfg.foundBases[key] = true
                                                    
                                                    -- Add additional info
                                                    info.desc = info.desc .. "\n**Server:** " .. game.JobId
                                                    info.desc = info.desc .. "\n**Time:** " .. os.date("%X")
                                                    
                                                    sendHook(info.title, info.desc, info.color)
                                                    ui:Notify({
                                                        Title = info.title,
                                                        Content = info.desc:gsub("%*%*", ""):gsub("\n", " "),
                                                        Duration = cfg.notifyDuration
                                                    })
                                                    
                                                    -- Play notification sound
                                                    if cfg.notifySound then
                                                        spawn(function()
                                                            pcall(function()
                                                                local sound = Instance.new("Sound")
                                                                sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                                                                sound.Volume = 0.5
                                                                sound.Parent = svc.SoundService
                                                                sound:Play()
                                                                sound.Ended:Connect(function()
                                                                    sound:Destroy()
                                                                end)
                                                            end)
                                                        end)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Main scanner toggle function
local function toggle(state)
    cfg.enabled = state
    
    if state then
        -- Start main scanning
        cfg.cons.scan = svc.RunService.Heartbeat:Connect(function()
            scan()
            wait(cfg.scanDelay)
        end)
        
        -- Start auto-hop if enabled
        if cfg.hopEnabled then
            cfg.cons.hop = task.spawn(function()
                while cfg.enabled do
                    task.wait(cfg.hoptime)
                    if cfg.enabled then
                        hop()
                    end
                end
            end)
        end
        
        ui:Notify({
            Title = "Scanner Started",
            Content = "Brainrot scanner is now active",
            Duration = 3
        })
    else
        -- Stop all scanning
        if cfg.cons.scan then
            cfg.cons.scan:Disconnect()
        end
        if cfg.cons.hop then
            task.cancel(cfg.cons.hop)
        end
        
        ui:Notify({
            Title = "Scanner Stopped",
            Content = "Brainrot scanner has been disabled",
            Duration = 3
        })
    end
end

-- Base scanner toggle function
local function toggleBase(state)
    cfg.baseenabled = state
    
    if state then
        cfg.cons.basescan = svc.RunService.Heartbeat:Connect(function()
            scanBase()
            wait(cfg.scanDelay)
        end)
        
        ui:Notify({
            Title = "Base Scanner Started",
            Content = "Base brainrot scanner is now active",
            Duration = 3
        })
    else
        if cfg.cons.basescan then
            cfg.cons.basescan:Disconnect()
        end
        
        ui:Notify({
            Title = "Base Scanner Stopped",
            Content = "Base brainrot scanner has been disabled",
            Duration = 3
        })
    end
end

-- Clear found cache function
local function clearFoundCache()
    cfg.found = {}
    cfg.foundBases = {}
    ui:Notify({
        Title = "Cache Cleared",
        Content = "Found items cache has been cleared",
        Duration = 3
    })
end

-- Initialize brainrots list
getBrainrots()

-- Create main UI window
local win = ui:CreateWindow({
    Title = "🎯 Brainrot Finder Pro",
    Icon = "search",
    Folder = "BrainrotFinder",
    Size = UDim2.fromOffset(580, 480),
    Theme = "Dark"
})

-- Create main sections
local scanner = win:Section({Title = "Scanner", Opened = true})
local base = win:Section({Title = "Base Scanner", Opened = false})
local settings = win:Section({Title = "Settings", Opened = false})

-- Create tabs
local main = scanner:Tab({Title = "Moving Animals", Icon = "target"})
local baseTab = base:Tab({Title = "Player Bases", Icon = "home"})
local opts = settings:Tab({Title = "Configuration", Icon = "settings"})
local advanced = settings:Tab({Title = "Advanced", Icon = "cpu"})

-- Main scanner tab controls
main:Button({
    Title = "🔄 Refresh Animals",
    Description = "Reload the list of available animals",
    Callback = function()
        getBrainrots()
        brainrotDrop:Refresh(cfg.brainrots)
        baseBrainrotDrop:Refresh(cfg.brainrots)
        ui:Notify({
            Title = "Animals Refreshed",
            Content = "Found " .. #cfg.brainrots .. " animals",
            Duration = 3
        })
    end
})

main:Button({
    Title = "🚀 Server Hop",
    Description = "Manually hop to a new server",
    Callback = hop
})

main:Button({
    Title = "🧪 Test Webhook",
    Description = "Send a test notification to Discord",
    Callback = function()
        sendHook("Test Notification", "Webhook is working correctly! ✅", 0x00ff00)
    end
})

-- Base scanner tab controls
baseTab:Button({
    Title = "🧪 Test Webhook",
    Description = "Send a test notification to Discord",
    Callback = function()
        sendHook("Base Scanner Test", "Base scanner webhook is working correctly! 🏠✅", 0x00ff00)
    end
})

baseTab:Button({
    Title = "🧹 Clear Cache",
    Description = "Clear found items cache to allow re-notifications",
    Callback = clearFoundCache
})

-- Configuration Manager
local cfgmgr = win.ConfigManager
local config = cfgmgr:CreateConfig("brainrot_finder")

-- Webhook input (shared between main and base)
local webhookInput = main:Input({
    Title = "Discord Webhook URL",
    Description = "Enter your Discord webhook URL for notifications",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v)
        cfg.webhook = v
    end
})

-- Brainrot selection dropdown
local brainrotDrop = main:Dropdown({
    Title = "Target Brainrots",
    Description = "Select which animals to scan for",
    Values = cfg.brainrots,
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        cfg.selected.brainrots = v
    end
})

-- Mutation selection dropdown
local mutationDrop = main:Dropdown({
    Title = "Target Mutations",
    Description = "Select which mutations to scan for",
    Values = cfg.mutations,
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        cfg.selected.mutations = v
    end
})

-- Main scanner toggle
local scannerToggle = main:Toggle({
    Title = "🎯 Animal Scanner",
    Description = "Enable/disable scanning for moving animals",
    Callback = toggle
})

-- Mutation scanner toggle
local mutationToggle = main:Toggle({
    Title = "✨ Mutation Scanner",
    Description = "Enable/disable mutation detection",
    Callback = function(v)
        cfg.mutenabled = v
    end
})

-- Base scanner controls
local baseWebhook = baseTab:Input({
    Title = "Discord Webhook URL",
    Description = "Enter your Discord webhook URL (same as main scanner)",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v)
        cfg.webhook = v
        -- Sync with main webhook (removed SetValue call to fix error)
    end
})

local baseBrainrotDrop = baseTab:Dropdown({
    Title = "Target Brainrots",
    Description = "Select which animals to scan for in bases",
    Values = cfg.brainrots,
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        cfg.selected.brainrots = v
        -- Sync with main dropdown (removed SetValue call to fix error)
    end
})

local baseMutationDrop = baseTab:Dropdown({
    Title = "Target Mutations",
    Description = "Select which mutations to scan for in bases",
    Values = cfg.mutations,
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        cfg.selected.mutations = v
        -- Sync with main dropdown (removed SetValue call to fix error)
    end
})

local baseScannerToggle = baseTab:Toggle({
    Title = "🏠 Base Scanner",
    Description = "Enable/disable scanning player bases",
    Callback = toggleBase
})

local baseMutationToggle = baseTab:Toggle({
    Title = "✨ Base Mutation Scanner",
    Description = "Enable/disable mutation detection in bases",
    Callback = function(v)
        cfg.mutenabled = v
        -- Sync with main toggle (removed SetValue call to fix error)
    end
})

-- Settings tab controls
local hopSlider = opts:Slider({
    Title = "Server Hop Interval",
    Description = "Time between automatic server hops (seconds)",
    Value = {Min = 60, Max = 600, Default = 300},
    Callback = function(v)
        cfg.hoptime = v
    end
})

local hopToggle = opts:Toggle({
    Title = "🚀 Auto Server Hop",
    Description = "Automatically hop servers at set intervals",
    Default = true,
    Callback = function(v)
        cfg.hopEnabled = v
    end
})

local soundToggle = opts:Toggle({
    Title = "🔊 Notification Sound",
    Description = "Play sound when rare items are found",
    Default = true,
    Callback = function(v)
        cfg.notifySound = v
    end
})

local notifyDurationSlider = opts:Slider({
    Title = "Notification Duration",
    Description = "How long notifications stay visible (seconds)",
    Value = {Min = 3, Max = 15, Default = 8},
    Callback = function(v)
        cfg.notifyDuration = v
    end
})

-- Advanced settings
local scanDelaySlider = advanced:Slider({
    Title = "Scan Delay",
    Description = "Delay between scan cycles (seconds)",
    Value = {Min = 0.05, Max = 1, Default = 0.1},
    Callback = function(v)
        cfg.scanDelay = v
    end
})

local webhookRetriesSlider = advanced:Slider({
    Title = "Webhook Retries",
    Description = "Number of retry attempts for failed webhooks",
    Value = {Min = 1, Max = 5, Default = 3},
    Callback = function(v)
        cfg.webhookRetries = v
    end
})

local debugToggle = advanced:Toggle({
    Title = "🐛 Debug Mode",
    Description = "Enable debug logging to console",
    Callback = function(v)
        cfg.debugMode = v
    end
})

-- Register all components with config manager
config:Register("webhook", webhookInput)
config:Register("brainrots", brainrotDrop)
config:Register("mutations", mutationDrop)
config:Register("scanner", scannerToggle)
config:Register("mutationenabled", mutationToggle)
config:Register("basewebhook", baseWebhook)
config:Register("basebrainrots", baseBrainrotDrop)
config:Register("basemutations", baseMutationDrop)
config:Register("basescanner", baseScannerToggle)
config:Register("basemutationenabled", baseMutationToggle)
config:Register("hopinterval", hopSlider)
config:Register("autohop", hopToggle)
config:Register("notifysound", soundToggle)
config:Register("notifyduration", notifyDurationSlider)
config:Register("scandelay", scanDelaySlider)
config:Register("webhookretries", webhookRetriesSlider)
config:Register("debugmode", debugToggle)

-- Configuration save/load buttons
opts:Button({
    Title = "💾 Save Configuration",
    Description = "Save current settings to file",
    Callback = function()
        config:Save()
        ui:Notify({
            Title = "Config Saved",
            Content = "Configuration has been saved successfully",
            Duration = 3
        })
    end
})

opts:Button({
    Title = "📁 Load Configuration",
    Description = "Load settings from file",
    Callback = function()
        config:Load()
        ui:Notify({
            Title = "Config Loaded",
            Content = "Configuration has been loaded successfully",
            Duration = 3
        })
    end
})

-- Advanced control buttons
advanced:Button({
    Title = "🗑️ Clear All Cache",
    Description = "Clear all cached data and reset found items",
    Callback = function()
        cfg.found = {}
        cfg.foundBases = {}
        ui:Notify({
            Title = "All Cache Cleared",
            Content = "All cached data has been cleared",
            Duration = 3
        })
    end
})

advanced:Button({
    Title = "📊 Show Statistics",
    Description = "Display scanning statistics",
    Callback = function()
        local stats = string.format(
            "Found Items: %d\nFound Base Items: %d\nSelected Brainrots: %d\nSelected Mutations: %d",
            table.length(cfg.found),
            table.length(cfg.foundBases),
            #cfg.selected.brainrots,
            #cfg.selected.mutations
        )
        
        ui:Notify({
            Title = "Scanner Statistics",
            Content = stats,
            Duration = 8
        })
    end
})

-- Cleanup function when window closes
win:OnClose(function()
    -- Disconnect all connections and cancel all tasks
    for _, con in pairs(cfg.cons) do
        if typeof(con) == "RBXScriptConnection" then
            con:Disconnect()
        elseif typeof(con) == "thread" then
            task.cancel(con)
        end
    end
    
    -- Send final notification
    if cfg.webhook ~= "" then
        sendHook("Scanner Closed", "Brainrot Finder has been closed", 0xff0000)
    end
    
    if cfg.debugMode then
        print("[Brainrot Finder] Script closed and cleaned up")
    end
end)

-- Helper function for table length
function table.length(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Initial welcome notification
ui:Notify({
    Title = "🎯 Brainrot Finder Pro",
    Content = "Script loaded successfully! Configure your settings and start scanning.",
    Duration = 5
})

-- Auto-load configuration if it exists
spawn(function()
    wait(2) -- Wait for UI to fully load
    pcall(function()
        config:Load()
    end)
end)

print("[Brainrot Finder] Loaded successfully!")
print("[Brainrot Finder] Found " .. #cfg.brainrots .. " available animals")
print("[Brainrot Finder] Configure your webhook and start scanning!")
