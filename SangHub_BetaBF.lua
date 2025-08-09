-- SangHub - Integrated GUI + AutoFarm (Part 2 integrated)
-- Raw .lua file: paste into executor
-- NOTE: This script tries to be robust but some checks (moon detection / boss names) depend on how the game represents them.
-- Use at your own risk. I focused on attaching auto-farm (level farm), select-weapon (melee/sword),
-- fast attack (rapid click option), floating platform, hitbox expand and basic quest / tween flow.

-- == Anti AFK ==
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    pcall(function() v:Disable() end)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ====== CONFIG / STATE ======
local StartTime = tick()
getgenv().AutoFarm = false
getgenv().SelectedWeapon = "None" -- "Melee" or "Sword"
getgenv().FastAttack = false
getgenv().AutoCollectFruit = false

-- ====== DATA: Island positions & level->mob mapping (Sea1 example) ======
local IslandPositions = {
    ["Bandit"] = CFrame.new(1060, 16, 1547),
    ["Monkey"] = CFrame.new(-1603, 65, 150),
    ["Gorilla"] = CFrame.new(-1337, 40, -30),
    ["Pirate"] = CFrame.new(-4870, 20, 4323),
    ["Brute"] = CFrame.new(-5020, 20, 4408),
    ["Desert Bandit"] = CFrame.new(932, 7, 4486),
    ["Desert Officer"] = CFrame.new(1572, 10, 4373),
    ["Snow Bandit"] = CFrame.new(1389, 87, -1297),
    ["Snowman"] = CFrame.new(1206, 144, -1326),
    ["Chief Petty Officer"] = CFrame.new(-4881, 20, 3914),
    ["Sky Bandit"] = CFrame.new(-4950, 295, -2886),
    ["Dark Master"] = CFrame.new(-5220, 430, -2272),
    ["Prisoner"] = CFrame.new(5100, 100, 4740),
    ["Dangerous Prisoner"] = CFrame.new(5200, 100, 4740),
    ["Toga Warrior"] = CFrame.new(-1790, 560, -2748),
    ["Gladiator"] = CFrame.new(-1295, 470, -3021),
    ["Military Soldier"] = CFrame.new(-5400, 90, 5800),
    ["Military Spy"] = CFrame.new(-5800, 90, 6000),
    ["Fishman Warrior"] = CFrame.new(60800, 20, 1500),
    ["Fishman Commando"] = CFrame.new(61000, 20, 1800),
    ["Wysper"] = CFrame.new(62000, 20, 1600),
    ["Magma Admiral"] = CFrame.new(-5000, 80, 8500),
    ["Arctic Warrior"] = CFrame.new(5600, 20, -6500),
    ["Snow Lurker"] = CFrame.new(5800, 30, -6700),
    ["Cyborg"] = CFrame.new(6200, 20, -7200)
}

local LevelToMob = {
    {LevelReq=1, Mob="Bandit", Quest="BanditQuest1"},
    {LevelReq=15, Mob="Monkey", Quest="JungleQuest"},
    {LevelReq=20, Mob="Gorilla", Quest="JungleQuest"},
    {LevelReq=30, Mob="Pirate", Quest="BuggyQuest1"},
    {LevelReq=40, Mob="Brute", Quest="BuggyQuest1"},
    {LevelReq=60, Mob="Desert Bandit", Quest="DesertQuest"},
    {LevelReq=75, Mob="Desert Officer", Quest="DesertQuest"},
    {LevelReq=90, Mob="Snow Bandit", Quest="SnowQuest"},
    {LevelReq=105, Mob="Snowman", Quest="SnowQuest"},
    {LevelReq=120, Mob="Chief Petty Officer", Quest="MarineQuest2"},
    {LevelReq=130, Mob="Sky Bandit", Quest="SkyQuest"},
    {LevelReq=145, Mob="Dark Master", Quest="SkyQuest"},
    {LevelReq=190, Mob="Prisoner", Quest="PrisonerQuest"},
    {LevelReq=210, Mob="Dangerous Prisoner", Quest="PrisonerQuest"},
    {LevelReq=250, Mob="Toga Warrior", Quest="ColosseumQuest"},
    {LevelReq=275, Mob="Gladiator", Quest="ColosseumQuest"},
    {LevelReq=300, Mob="Military Soldier", Quest="MagmaQuest"},
    {LevelReq=325, Mob="Military Spy", Quest="MagmaQuest"},
    {LevelReq=375, Mob="Fishman Warrior", Quest="FishmanQuest"},
    {LevelReq=400, Mob="Fishman Commando", Quest="FishmanQuest"},
    {LevelReq=450, Mob="Wysper", Quest="SkyExp1"},
    {LevelReq=475, Mob="Magma Admiral", Quest="SkyExp1"},
    {LevelReq=525, Mob="Arctic Warrior", Quest="FrostQuest"},
    {LevelReq=550, Mob="Snow Lurker", Quest="FrostQuest"},
    {LevelReq=625, Mob="Cyborg", Quest="CyborQuest"}
}

-- ====== UTILITIES ======
local function getBestForLevel()
    local lvl = 0
    pcall(function() lvl = LocalPlayer.Data.Level.Value end)
    local best = nil
    for _,d in ipairs(LevelToMob) do
        if lvl >= d.LevelReq then best = d end
    end
    return best
end

local function tweenTo(cf, speed)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    speed = speed or 250
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local dist = (hrp.Position - cf.Position).Magnitude
    local t = TweenService:Create(hrp, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cf})
    local ok,err = pcall(function() t:Play() end)
    if not ok then return end
    t.Completed:Wait()
end

local function sendClick()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(0,0,0,true,game,0)
        task.wait()
        VirtualInput:SendMouseButtonEvent(0,0,0,false,game,0)
    end)
end

-- finds nearest mob model by name (contains)
local function findNearestMobByName(name)
    local closest, dist = nil, math.huge
    for _,m in pairs(workspace:FindFirstChild("Enemies") and workspace.Enemies:GetChildren() or {}) do
        if m and m:FindFirstChild("HumanoidRootPart") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and string.find(m.Name, name) then
            local d = (m.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; closest = m end
        end
    end
    return closest
end

local function createFloatingPlatform()
    if workspace:FindFirstChild("SangHub_FloatBlock") then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local p = Instance.new("Part", workspace)
    p.Name = "SangHub_FloatBlock"
    p.Anchored = true
    p.CanCollide = true
    p.Size = Vector3.new(10,1,10)
    p.Transparency = 1
    p.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0,3.5,0)
end

local function removeFloatingPlatform()
    if workspace:FindFirstChild("SangHub_FloatBlock") then
        pcall(function() workspace.SangHub_FloatBlock:Destroy() end)
    end
end

local function expandHitbox(m)
    pcall(function()
        for _,part in ipairs(m:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = Vector3.new(60,60,60)
                part.Transparency = 0.6
                part.CanCollide = false
                part.Material = Enum.Material.Neon
            end
        end
    end)
end

local function autoEquipSelected()
    if not LocalPlayer.Character then return end
    -- if nothing selected -> skip
    if getgenv().SelectedWeapon == "Melee" then
        -- look for any Tool in backpack with ToolTip == "Melee" or name matches known styles
        for _,v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                if (v.ToolTip and v.ToolTip == "Melee") or string.find(v.Name:lower(),"combat") or string.find(v.Name:lower(),"karate") or string.find(v.Name:lower(),"death") then
                    pcall(function() LocalPlayer.Character.Humanoid:EquipTool(v) end)
                    return
                end
            end
        end
    elseif getgenv().SelectedWeapon == "Sword" then
        for _,v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                if (v.ToolTip and v.ToolTip == "Sword") or string.find(v.Name:lower(),"katana") or string.find(v.Name:lower(),"sword") or string.find(v.Name:lower(),"blade") then
                    pcall(function() LocalPlayer.Character.Humanoid:EquipTool(v) end)
                    return
                end
            end
        end
    end
end

-- Try remote quest start wrapper
local function startQuest(quest)
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest, 1)
    end)
end

-- Try remote open fruit stock wrapper
local function openFruitStock()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits")
    end)
end

-- ====== GUI (based on your provided base) ======
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "BloxFruit_TabGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Toggle Button (top-left square rounded with your logo id)
local ToggleBtn = Instance.new("ImageButton", Gui)
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 12, 0, 12)
ToggleBtn.Image = "rbxassetid://76955883171909"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
ToggleBtn.AutoButtonColor = true
ToggleBtn.Name = "SangHubToggle"
local tCorner = Instance.new("UICorner", ToggleBtn); tCorner.CornerRadius = UDim.new(0,8)

-- Main Frame
local MainFrame = Instance.new("Frame", Gui)
MainFrame.Size = UDim2.new(0, 640, 0, 420)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Name = "MainFrame"
local mCorner = Instance.new("UICorner", MainFrame); mCorner.CornerRadius = UDim.new(0,10)

-- Logo
local Logo = Instance.new("ImageLabel", MainFrame)
Logo.Size = UDim2.new(0, 34, 0, 34)
Logo.Position = UDim2.new(0, 12, 0, 8)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://76955883171909"

-- Tab strip (scrollable)
local TabScroll = Instance.new("ScrollingFrame", MainFrame)
TabScroll.Size = UDim2.new(1, -60, 0, 44)
TabScroll.Position = UDim2.new(0, 56, 0, 8)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 6
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
local tabLayout = Instance.new("UIListLayout", TabScroll)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,6)

-- Content container
local ContentHolder = Instance.new("Frame", MainFrame)
ContentHolder.Size = UDim2.new(1, -20, 1, -70)
ContentHolder.Position = UDim2.new(0, 10, 0, 60)
ContentHolder.BackgroundTransparency = 1

local Tabs = {"Status","General","Quest & Item","Race & Gear","Shop","Setting","Mic"}
local TabFrames = {}

for i, name in ipairs(Tabs) do
    local btn = Instance.new("TextButton", TabScroll)
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local frame = Instance.new("Frame", ContentHolder)
    frame.Size = UDim2.new(1,0,1,0)
    frame.Position = UDim2.new(0,0,0,0)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    TabFrames[name] = frame

    btn.MouseButton1Click:Connect(function()
        -- do not toggle visibility of mainframe here (user reported). Just switch tabs.
        for _,f in pairs(TabFrames) do f.Visible = false end
        frame.Visible = true
    end)
end

TabFrames["Status"].Visible = true

-- ========== STATUS TAB =============
local StatusTab = TabFrames["Status"]

-- Title centered
local StatusTitle = Instance.new("TextLabel", StatusTab)
StatusTitle.Size = UDim2.new(1,0,0,40)
StatusTitle.Position = UDim2.new(0,0,0,0)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextSize = 20
StatusTitle.TextColor3 = Color3.fromRGB(255,255,255)
StatusTitle.Text = "Status Checking"
StatusTitle.TextScaled = false
StatusTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Two-column area (left/right) scrollables
local left = Instance.new("ScrollingFrame", StatusTab)
left.Size = UDim2.new(0.5, -10, 1, -50)
left.Position = UDim2.new(0,5,0,45)
left.BackgroundTransparency = 1
left.ScrollBarThickness = 6
local leftLayout = Instance.new("UIListLayout", left)
leftLayout.Padding = UDim.new(0,6)

local right = Instance.new("ScrollingFrame", StatusTab)
right.Size = UDim2.new(0.5, -10, 1, -50)
right.Position = UDim2.new(0.5, 5, 0, 45)
right.BackgroundTransparency = 1
right.ScrollBarThickness = 6
local rightLayout = Instance.new("UIListLayout", right)
rightLayout.Padding = UDim.new(0,6)

-- Boss indicators (Shank, Whitebeard, The Saw)
local function makeStatusLine(parent, title)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 28)
    f.BackgroundTransparency = 1
    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(0.7, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.Font = Enum.Font.Gotham
    tl.TextColor3 = Color3.fromRGB(220,220,220)
    tl.TextXAlignment = Enum.TextXAlignment.Left
    local status = Instance.new("TextLabel", f)
    status.Size = UDim2.new(0.3, -6, 1, 0)
    status.Position = UDim2.new(0.7, 6, 0, 0)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamBold
    status.TextSize = 14
    status.TextXAlignment = Enum.TextXAlignment.Right
    return f, tl, status
end

local bossShankF, bossShankL, bossShankStatus = makeStatusLine(left, "Shank tóc đỏ:")
local bossWhiteF, bossWhiteL, bossWhiteStatus = makeStatusLine(left, "Râu trắng:")
local bossSawF, bossSawL, bossSawStatus = makeStatusLine(left, "The Saw:")

local playersCountLabelF, playersCountLabel, playersCountStatus = makeStatusLine(right, "Players in server:")
local fruitSpawnF, fruitSpawnL, fruitSpawnStatus = makeStatusLine(right, "FRUIT SPAWN / DROP:")

local timeLabelF, timeLabel, timeStatus = makeStatusLine(right, "Script uptime:")

local moonLabelF, moonLabel, moonStatus = makeStatusLine(right, "Moon:")

-- Status updater
local function updateStatus()
    -- players
    pcall(function()
        local count = #Players:GetPlayers()
        playersCountStatus.Text = tostring(count)
    end)

    -- boss detection heuristics (search workspace for models containing keywords)
    local foundShank, foundWhite, foundSaw = false,false,false
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("Folder") then
            local n = v.Name:lower()
            if n:find("shank") or n:find("shank tóc") or n:find("shank") then foundShank = true end
            if n:find("whitebeard") or n:find("white beard") or n:find("râu trắng") then foundWhite = true end
            if n:find("saw") or n:find("the saw") then foundSaw = true end
        end
    end
    bossShankStatus.Text = foundShank and "✅" or "❌"
    bossWhiteStatus.Text = foundWhite and "✅" or "❌"
    bossSawStatus.Text = foundSaw and "✅" or "❌"

    -- fruit spawn detection - list names of tools named Fruit
    local fruitNames = {}
    for _,obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and string.match(obj.Name:lower(),"fruit") then
            table.insert(fruitNames, obj.Name)
        end
    end
    if #fruitNames > 0 then
        fruitSpawnStatus.Text = table.concat(fruitNames, ", ")
    else
        fruitSpawnStatus.Text = "❌"
    end

    -- uptime
    local elapsed = math.floor(tick() - StartTime)
    local hrs = math.floor(elapsed / 3600); local mins = math.floor((elapsed % 3600)/60); local secs = elapsed % 60
    timeStatus.Text = string.format("%02d:%02d:%02d", hrs, mins, secs)

    -- moon detection heuristic (best-effort)
    local moonType = "Unknown"
    -- try common places: workspace:FindFirstChild("Moon") or ReplicatedStorage:FindFirstChild("Moon")
    local moonObj = workspace:FindFirstChild("Moon") or ReplicatedStorage:FindFirstChild("Moon")
    if moonObj and moonObj.Name:lower():find("real") then
        moonType = "Real 🌘🌗🌖🌕"
    elseif moonObj and moonObj.Name:lower():find("fake") then
        moonType = "Fake 🌒🌓🌖🌑"
    else
        moonType = "Unknown"
    end
    moonStatus.Text = moonType
end

-- update every 120s for boss check and every 1s for uptime
spawn(function()
    while task.wait(1) do
        pcall(updateStatus)
    end
end)

-- ========== GENERAL TAB (left/right panels) ==========
local GeneralTab = TabFrames["General"]

-- Left panel = Auto Farm controls (panel styled similar to your request)
local LeftPanel = Instance.new("Frame", GeneralTab)
LeftPanel.Size = UDim2.new(0.5, -10, 1, 0)
LeftPanel.Position = UDim2.new(0, 0, 0, 0)
LeftPanel.BackgroundTransparency = 1

local LeftScroll = Instance.new("ScrollingFrame", LeftPanel)
LeftScroll.Size = UDim2.new(1,1,1,0)
LeftScroll.CanvasSize = UDim2.new(0,0,0,400)
LeftScroll.ScrollBarThickness = 6
LeftScroll.BackgroundTransparency = 1
local LeftList = Instance.new("UIListLayout", LeftScroll); LeftList.Padding = UDim.new(0,8)

-- Right panel = Settings / select weapon
local RightPanel = Instance.new("Frame", GeneralTab)
RightPanel.Size = UDim2.new(0.5, -10, 1, 0)
RightPanel.Position = UDim2.new(0.5, 10, 0, 0)
RightPanel.BackgroundTransparency = 1

local RightScroll = Instance.new("ScrollingFrame", RightPanel)
RightScroll.Size = UDim2.new(1,1,1,0)
RightScroll.CanvasSize = UDim2.new(0,0,0,400)
RightScroll.ScrollBarThickness = 6
RightScroll.BackgroundTransparency = 1
local RightList = Instance.new("UIListLayout", RightScroll); RightList.Padding = UDim.new(0,8)

-- Helper: small section title
local function sectionTitle(parent, text)
    local t = Instance.new("TextLabel", parent)
    t.Size = UDim2.new(1, -12, 0, 28)
    t.BackgroundTransparency = 1
    t.Text = text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextColor3 = Color3.fromRGB(220,220,220)
    t.TextXAlignment = Enum.TextXAlignment.Left
    return t
end

sectionTitle(LeftScroll, "Auto Farm")
-- Level Farm toggle (rectangle + circle)
local levelFrame = Instance.new("Frame", LeftScroll)
levelFrame.Size = UDim2.new(1, -12, 0, 60)
levelFrame.BackgroundTransparency = 1

local lvlLabel = Instance.new("TextLabel", levelFrame)
lvlLabel.Size = UDim2.new(0.7,0,1,0)
lvlLabel.BackgroundTransparency = 1
lvlLabel.Text = "Level Farm"
lvlLabel.Font = Enum.Font.Gotham
lvlLabel.TextSize = 16
lvlLabel.TextColor3 = Color3.new(1,1,1)
lvlLabel.TextXAlignment = Enum.TextXAlignment.Left

local circle = Instance.new("ImageLabel", levelFrame)
circle.Size = UDim2.new(0,34,0,34)
circle.Position = UDim2.new(0.78,0,0.14,0)
circle.BackgroundTransparency = 1
circle.Image = "rbxassetid://6031094664" -- empty circle
local cCorner = Instance.new("UICorner", circle); cCorner.CornerRadius = UDim.new(0,18)

local lvlToggle = false
local lvlBtn = Instance.new("TextButton", levelFrame)
lvlBtn.Size = UDim2.new(0.2, -8, 0.9, 0)
lvlBtn.Position = UDim2.new(0.78, 0, 0.05, 0)
lvlBtn.Text = ""
lvlBtn.BackgroundTransparency = 1
lvlBtn.AutoButtonColor = true
lvlBtn.MouseButton1Click:Connect(function()
    lvlToggle = not lvlToggle
    circle.Image = lvlToggle and "rbxassetid://6031094690" or "rbxassetid://6031094664"
    getgenv().AutoFarm = lvlToggle
    -- start auto farm loop is handled below
end)

-- Right panel: select weapon (only Melee / Sword)
sectionTitle(RightScroll, "Setting Farming")
local selFrame = Instance.new("Frame", RightScroll)
selFrame.Size = UDim2.new(1, -12, 0, 80)
selFrame.BackgroundTransparency = 1

local selLabel = Instance.new("TextLabel", selFrame)
selLabel.Size = UDim2.new(1, 0, 0, 24)
selLabel.Position = UDim2.new(0,0,0,0)
selLabel.BackgroundTransparency = 1
selLabel.Text = "Select Weapon: Nothing"
selLabel.Font = Enum.Font.Gotham
selLabel.TextSize = 14
selLabel.TextColor3 = Color3.new(1,1,1)
selLabel.TextXAlignment = Enum.TextXAlignment.Left

local selButtons = Instance.new("Frame", selFrame)
selButtons.Size = UDim2.new(1,0,0,44)
selButtons.Position = UDim2.new(0,0,0,28)
selButtons.BackgroundTransparency = 1

local meleeBtn = Instance.new("TextButton", selButtons)
meleeBtn.Size = UDim2.new(0.48, -6, 1, 0)
meleeBtn.Position = UDim2.new(0,0,0,0)
meleeBtn.Text = "Melee 🥋"
meleeBtn.Font = Enum.Font.GothamBold
meleeBtn.TextSize = 14
meleeBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
meleeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", meleeBtn).CornerRadius = UDim.new(0,6)

local swordBtn = Instance.new("TextButton", selButtons)
swordBtn.Size = UDim2.new(0.48, -6, 1, 0)
swordBtn.Position = UDim2.new(0.52, 0, 0, 0)
swordBtn.Text = "Sword ⚔️"
swordBtn.Font = Enum.Font.GothamBold
swordBtn.TextSize = 14
swordBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
swordBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", swordBtn).CornerRadius = UDim.new(0,6)

meleeBtn.MouseButton1Click:Connect(function()
    getgenv().SelectedWeapon = "Melee"
    selLabel.Text = "Select Weapon: Melee"
end)
swordBtn.MouseButton1Click:Connect(function()
    getgenv().SelectedWeapon = "Sword"
    selLabel.Text = "Select Weapon: Sword"
end)

-- Fast Attack toggle
local fastFrame = Instance.new("Frame", RightScroll)
fastFrame.Size = UDim2.new(1, -12, 0, 44)
fastFrame.BackgroundTransparency = 1
local fastLabel = Instance.new("TextLabel", fastFrame)
fastLabel.Size = UDim2.new(0.7,0,1,0)
fastLabel.BackgroundTransparency = 1
fastLabel.Text = "Fast Attack"
fastLabel.Font = Enum.Font.Gotham
fastLabel.TextColor3 = Color3.new(1,1,1)
fastLabel.TextSize = 14
fastLabel.TextXAlignment = Enum.TextXAlignment.Left

local fastCircle = Instance.new("ImageLabel", fastFrame)
fastCircle.Size = UDim2.new(0,34,0,34)
fastCircle.Position = UDim2.new(0.78,0,0.1,0)
fastCircle.BackgroundTransparency = 1
fastCircle.Image = "rbxassetid://6031094664"
local fastBtn = Instance.new("TextButton", fastFrame)
fastBtn.Size = UDim2.new(0.2, -8, 0.9, 0)
fastBtn.Position = UDim2.new(0.78, 0, 0.05, 0)
fastBtn.BackgroundTransparency = 1
fastBtn.AutoButtonColor = true
local fastToggle = false
fastBtn.MouseButton1Click:Connect(function()
    fastToggle = not fastToggle
    fastCircle.Image = fastToggle and "rbxassetid://6031094690" or "rbxassetid://6031094664"
    getgenv().FastAttack = fastToggle
end)

-- Auto collect fruit toggle (small)
local collectFrame = Instance.new("Frame", LeftScroll)
collectFrame.Size = UDim2.new(1,-12,0,44)
collectFrame.BackgroundTransparency = 1
local collectLabel = Instance.new("TextLabel", collectFrame)
collectLabel.Size = UDim2.new(0.7,0,1,0)
collectLabel.BackgroundTransparency = 1
collectLabel.Text = "Auto Collect Fruit"
collectLabel.Font = Enum.Font.Gotham
collectLabel.TextColor3 = Color3.new(1,1,1)
collectLabel.TextSize = 14
collectLabel.TextXAlignment = Enum.TextXAlignment.Left
local collectCircle = Instance.new("ImageLabel", collectFrame)
collectCircle.Size = UDim2.new(0,34,0,34)
collectCircle.Position = UDim2.new(0.78,0,0.1,0)
collectCircle.BackgroundTransparency = 1
collectCircle.Image = "rbxassetid://6031094664"
local collectBtn = Instance.new("TextButton", collectFrame)
collectBtn.Size = UDim2.new(0.2,-8,0.9,0)
collectBtn.Position = UDim2.new(0.78,0,0.05,0)
collectBtn.BackgroundTransparency = 1
local collectToggle = false
collectBtn.MouseButton1Click:Connect(function()
    collectToggle = not collectToggle
    collectCircle.Image = collectToggle and "rbxassetid://6031094690" or "rbxassetid://6031094664"
    getgenv().AutoCollectFruit = collectToggle
end)

-- Toggle mainframe show/hide with scale animation
local mainVisible = false
ToggleBtn.MouseButton1Click:Connect(function()
    mainVisible = not mainVisible
    if mainVisible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {Size = UDim2.new(0,640,0,420)}):Play()
    else
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Sine), {Size = UDim2.new(0,0,0,0)})
        t:Play()
        t.Completed:Wait()
        MainFrame.Visible = false
    end
end)

-- Make content scrollable for all tab frames (simple)
for _,f in pairs(TabFrames) do
    local scr = Instance.new("ScrollingFrame", f)
    scr.Size = UDim2.new(1,0,1,0)
    scr.BackgroundTransparency = 1
    scr.ScrollBarThickness = 6
    scr.Visible = false -- hide the extra scroll frame; we already placed content frames manually for Status & General
    scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
end

-- ====== AUTO FARM LOGIC (INTEGRATED) ======
local function goToIslandForData(d)
    if not d then return end
    if IslandPositions[d.Mob] then
        pcall(function() tweenTo(IslandPositions[d.Mob]); task.wait(0.6) end)
    end
end

local function performFarmOnce(data)
    if not data then return end
    -- ensure quest
    pcall(function()
        -- If player already has quest visible skip, otherwise go to NPC and start
        -- Attempt to find quest NPC by name (Quest strings used earlier may not correspond to NPC model names, so this is best-effort)
        -- We'll call StartQuest directly (may require being near NPC in some servers)
        startQuest(data.Quest)
    end)

    -- attempt to get mobs and fight
    while getgenv().AutoFarm do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then break end
        local mob = findNearestMobByName(data.Mob)
        if mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            -- bring mob up, expand hitbox, create platform, equip
            createFloatingPlatform()
            pcall(expandHitbox, mob)
            pcall(function()
                -- move above mob
                tweenTo(mob.HumanoidRootPart.CFrame + Vector3.new(0,15,0), 400)
            end)
            -- equip
            pcall(autoEquipSelected)
            -- fight until mob dead or stop
            repeat
                if getgenv().FastAttack then
                    -- faster clicks
                    for i=1,3 do sendClick() end
                else
                    sendClick()
                end
                task.wait(0.06)
            until not mob.Parent or not getgenv().AutoFarm or (mob:FindFirstChild("Humanoid") and mob.Humanoid.Health <= 0)
            task.wait(0.2)
        else
            -- no mob found, break to allow loop to request quest / wait for spawn
            break
        end
        task.wait(0.5)
    end
end

-- farm loop: tries to find best mob for current level and run performFarmOnce
spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm then
            pcall(function()
                local data = getBestForLevel()
                if not data then return end
                goToIslandForData(data)
                task.wait(1)
                -- ensure auto-equip before starting
                pcall(autoEquipSelected)
                -- start fighting loop
                performFarmOnce(data)
                -- small wait to prevent tight loop; quest re-evaluation will occur
                task.wait(1)
            end)
        else
            removeFloatingPlatform()
            task.wait(1)
        end
    end
end)

-- auto collect fruit loop
spawn(function()
    while task.wait(5) do
        if getgenv().AutoCollectFruit then
            pcall(function()
                for _,obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Tool") and obj:FindFirstChild("Handle") and string.match(obj.Name:lower(),"fruit") then
                        pcall(function()
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Handle, 0)
                            task.wait(0.05)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Handle, 1)
                        end)
                    end
                end
            end)
        end
    end
end)

-- Auto re-equip if tool lost while farming
spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm then
            if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                pcall(autoEquipSelected)
            end
        end
    end
end)

-- Final log
print("✅ SangHub (Part2) GUI+AutoFarm loaded.")

