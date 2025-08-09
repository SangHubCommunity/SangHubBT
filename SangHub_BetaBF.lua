--==[ SangHub BF Script - Part 1 ]==--

-- Anti AFK
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    pcall(function() v:Disable() end)
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInput = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Config / State
local StartTime = tick()
getgenv().AutoFarm = false
getgenv().SelectedWeapon = "None"
getgenv().FastAttack = false

-- Island Positions & LevelToMob for Sea 1
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

-- Utility
local function getBestForLevel()
    local lvl = 0
    pcall(function() lvl = LocalPlayer.Data.Level.Value end)
    local best
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
    t:Play()
    t.Completed:Wait()
end

local function sendClick()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(0,0,0,true,game,0)
        task.wait()
        VirtualInput:SendMouseButtonEvent(0,0,0,false,game,0)
    end)
end

local function findNearestMobByName(name)
    local closest, dist = nil, math.huge
    for _,m in pairs(workspace:FindFirstChild("Enemies") and workspace.Enemies:GetChildren() or {}) do
        if m:FindFirstChild("HumanoidRootPart") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and string.find(m.Name, name) then
            local d = (m.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; closest = m end
        end
    end
    return closest
end

local function createFloatingPlatform()
    if workspace:FindFirstChild("SangHub_FloatBlock") then return end
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
        workspace.SangHub_FloatBlock:Destroy()
    end
end

local function expandHitbox(m)
    for _,part in ipairs(m:GetChildren()) do
        if part:IsA("BasePart") then
            part.Size = Vector3.new(60,60,60)
            part.Transparency = 0.6
            part.CanCollide = false
            part.Material = Enum.Material.Neon
        end
    end
end

local function autoEquipSelected()
    if getgenv().SelectedWeapon == "Melee" then
        for _,v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == "Melee" or v.Name:lower():find("combat") or v.Name:lower():find("karate")) then
                LocalPlayer.Character.Humanoid:EquipTool(v) return
            end
        end
    elseif getgenv().SelectedWeapon == "Sword" then
        for _,v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and (v.ToolTip == "Sword" or v.Name:lower():find("katana") or v.Name:lower():find("sword") or v.Name:lower():find("blade")) then
                LocalPlayer.Character.Humanoid:EquipTool(v) return
            end
        end
    end
end
--==[ SangHub BF Script - Part 2 (GUI + Tabs + Status) ]==--

-- GUI base (dựa trên bản bạn chốt)
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "BloxFruit_TabGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Toggle Button (top-left)
local ToggleBtn = Instance.new("ImageButton", Gui)
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 12, 0, 12)
ToggleBtn.Image = "rbxassetid://76955883171909" -- your logo id
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
        -- only switch tabs; do NOT hide MainFrame
        for _,f in pairs(TabFrames) do f.Visible = false end
        frame.Visible = true
    end)
end

TabFrames["Status"].Visible = true

-- ===== STATUS TAB UI =====
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
StatusTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Two-column scrolls
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

-- helper to create line
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
    status.Text = "..."
    return f, tl, status
end

-- Boss lines
local b1f,b1l,b1s = makeStatusLine(left, "Shank tóc đỏ:")
local b2f,b2l,b2s = makeStatusLine(left, "Râu trắng:")
local b3f,b3l,b3s = makeStatusLine(left, "The Saw:")

-- Right side lines
local pcf, pcl, pcs = makeStatusLine(right, "Players in server:")
local ff, fl, fs = makeStatusLine(right, "FRUIT SPAWN / DROP:")
local tf, tlbl, tsLbl = makeStatusLine(right, "Script uptime:")
local mf, mll, ms = makeStatusLine(right, "Moon:")

-- Status update function (runs periodically)
local StartTime = tick()
local function updateStatus()
    -- players
    pcall(function()
        local count = #Players:GetPlayers()
        pcs.Text = tostring(count)
    end)

    -- boss detection (search workspace names)
    local foundShank, foundWhite, foundSaw = false,false,false
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("Folder") then
            local n = v.Name:lower()
            if n:find("shank") then foundShank = true end
            if n:find("whitebeard") or n:find("râu trắng") or n:find("white beard") then foundWhite = true end
            if n:find("saw") or n:find("the saw") then foundSaw = true end
        end
    end
    b1s.Text = foundShank and "✅" or "❌"
    b2s.Text = foundWhite and "✅" or "❌"
    b3s.Text = foundSaw and "✅" or "❌"

    -- fruit detection (tools in workspace containing "fruit")
    local fruitNames = {}
    for _,obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") and string.match(obj.Name:lower(),"fruit") then
            table.insert(fruitNames, obj.Name)
        end
    end
    if #fruitNames > 0 then fs.Text = table.concat(fruitNames, ", ") else fs.Text = "❌" end

    -- uptime
    local elapsed = math.floor(tick() - StartTime)
    local hrs = math.floor(elapsed / 3600); local mins = math.floor((elapsed % 3600)/60); local secs = elapsed % 60
    tsLbl.Text = string.format("%02d:%02d:%02d", hrs, mins, secs)

    -- moon detection (best-effort)
    local moonType = "Unknown"
    local moonObj = workspace:FindFirstChild("Moon") or ReplicatedStorage:FindFirstChild("Moon")
    if moonObj and moonObj.Name:lower():find("real") then
        moonType = "Real 🌘🌗🌖🌕"
    elseif moonObj and moonObj.Name:lower():find("fake") then
        moonType = "Fake 🌒🌓🌖🌑"
    else
        -- fallback: try searching terrain/lighting name markers
        if workspace:FindFirstChild("MoonSurface") then moonType = "Real 🌘🌗🌖🌕" end
    end
    ms.Text = moonType
end

-- small loop: update every 1s (uptime) but boss check is cheap anyway
spawn(function()
    while task.wait(1) do
        pcall(updateStatus)
    end
end)

-- Toggle visibility with a zoom animation
local tweenService = game:GetService("TweenService")
ToggleBtn.MouseButton1Click:Connect(function()
    local show = not MainFrame.Visible
    if show then
        MainFrame.Scale = 0 -- not real property but we'll emulate: set initial small then tween size/position
        MainFrame.Size = UDim2.new(0,1,0,1)
        MainFrame.Visible = true
        local goal = {Size = UDim2.new(0,640,0,420)}
        local t = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        tweenService:Create(MainFrame, t, goal):Play()
    else
        local goal = {Size = UDim2.new(0,1,0,1)}
        local t = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        local tw = tweenService:Create(MainFrame, t, goal)
        tw:Play()
        tw.Completed:Wait()
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0,640,0,420)
    end
end)

-- End of Part 2
print("SangHub: Part 2 (GUI & Status) loaded")
--==[ SangHub BF Script - Part 3 (Tab General) ]==--

local GeneralTab = TabFrames["General"]

-- Panel Left = Auto Farm
local LeftPanel = Instance.new("Frame", GeneralTab)
LeftPanel.Size = UDim2.new(0.48, -6, 1, 0)
LeftPanel.Position = UDim2.new(0, 0, 0, 0)
LeftPanel.BackgroundTransparency = 1

local LeftScroll = Instance.new("ScrollingFrame", LeftPanel)
LeftScroll.Size = UDim2.new(1, 0, 1, 0)
LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftScroll.ScrollBarThickness = 5
LeftScroll.BackgroundTransparency = 1
local lLayout = Instance.new("UIListLayout", LeftScroll)
lLayout.Padding = UDim.new(0,8)

local AutoFarmTitle = Instance.new("TextLabel", LeftScroll)
AutoFarmTitle.Size = UDim2.new(1, 0, 0, 26)
AutoFarmTitle.Text = "Auto Farm"
AutoFarmTitle.TextColor3 = Color3.fromRGB(255,255,255)
AutoFarmTitle.BackgroundTransparency = 1
AutoFarmTitle.Font = Enum.Font.GothamBold
AutoFarmTitle.TextSize = 15
AutoFarmTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Auto farm button
local AutoFarmBtn = Instance.new("TextButton", LeftScroll)
AutoFarmBtn.Size = UDim2.new(1, 0, 0, 34)
AutoFarmBtn.Text = "Level Farm"
AutoFarmBtn.Font = Enum.Font.GothamBold
AutoFarmBtn.TextSize = 14
AutoFarmBtn.TextColor3 = Color3.fromRGB(255,255,255)
AutoFarmBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", AutoFarmBtn).CornerRadius = UDim.new(0,6)

local TickIcon = Instance.new("ImageLabel", AutoFarmBtn)
TickIcon.Size = UDim2.new(0, 20, 0, 20)
TickIcon.Position = UDim2.new(1, -26, 0.5, -10)
TickIcon.BackgroundTransparency = 1
TickIcon.Image = "" -- empty by default

local AutoFarmEnabled = false
AutoFarmBtn.MouseButton1Click:Connect(function()
    AutoFarmEnabled = not AutoFarmEnabled
    if AutoFarmEnabled then
        TickIcon.Image = "rbxassetid://6031094690" -- check mark
    else
        TickIcon.Image = ""
    end
    getgenv().AutoFarmEnabled = AutoFarmEnabled
end)

-- Panel Right = Setting Farm
local RightPanel = Instance.new("Frame", GeneralTab)
RightPanel.Size = UDim2.new(0.48, -6, 1, 0)
RightPanel.Position = UDim2.new(0.52, 0, 0, 0)
RightPanel.BackgroundTransparency = 1

local RightScroll = Instance.new("ScrollingFrame", RightPanel)
RightScroll.Size = UDim2.new(1, 0, 1, 0)
RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RightScroll.ScrollBarThickness = 5
RightScroll.BackgroundTransparency = 1
local rLayout = Instance.new("UIListLayout", RightScroll)
rLayout.Padding = UDim.new(0,8)

-- Title Setting Farm
local SettingTitle = Instance.new("TextLabel", RightScroll)
SettingTitle.Size = UDim2.new(1, 0, 0, 26)
SettingTitle.Text = "Setting Farm"
SettingTitle.TextColor3 = Color3.fromRGB(255,255,255)
SettingTitle.BackgroundTransparency = 1
SettingTitle.Font = Enum.Font.GothamBold
SettingTitle.TextSize = 15
SettingTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Time server
local ServerTimeLbl = Instance.new("TextLabel", RightScroll)
ServerTimeLbl.Size = UDim2.new(1, 0, 0, 20)
ServerTimeLbl.BackgroundTransparency = 1
ServerTimeLbl.Font = Enum.Font.Gotham
ServerTimeLbl.TextSize = 13
ServerTimeLbl.TextColor3 = Color3.fromRGB(200,200,200)
ServerTimeLbl.TextXAlignment = Enum.TextXAlignment.Center

-- update time every second
spawn(function()
    while task.wait(1) do
        local t = os.date("!%H:%M:%S")
        ServerTimeLbl.Text = "Server Time: " .. t
    end
end)

-- Select Weapon button
local SelectedWeapon = "Nothing"
local DropDownBtn = Instance.new("TextButton", RightScroll)
DropDownBtn.Size = UDim2.new(1, 0, 0, 34)
DropDownBtn.Text = "Select Weapon: " .. SelectedWeapon
DropDownBtn.Font = Enum.Font.GothamBold
DropDownBtn.TextSize = 14
DropDownBtn.TextColor3 = Color3.fromRGB(255,255,255)
DropDownBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", DropDownBtn).CornerRadius = UDim.new(0,6)

-- Options frame
local WeaponOptions = Instance.new("Frame", DropDownBtn)
WeaponOptions.Size = UDim2.new(1, 0, 0, 90)
WeaponOptions.Position = UDim2.new(0, 0, 1, 0)
WeaponOptions.Visible = false
WeaponOptions.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", WeaponOptions).CornerRadius = UDim.new(0,6)

local ScrollList = Instance.new("ScrollingFrame", WeaponOptions)
ScrollList.Size = UDim2.new(1, 0, 1, 0)
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 60)
ScrollList.ScrollBarThickness = 4
ScrollList.BackgroundTransparency = 1
local slLayout = Instance.new("UIListLayout", ScrollList)
slLayout.Padding = UDim.new(0,4)

local Weapons = {"Melee","Sword"}
for _, name in ipairs(Weapons) do
    local btn = Instance.new("TextButton", ScrollList)
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        SelectedWeapon = name
        DropDownBtn.Text = "Select Weapon: " .. SelectedWeapon
        WeaponOptions.Visible = false
    end)
end

DropDownBtn.MouseButton1Click:Connect(function()
    WeaponOptions.Visible = not WeaponOptions.Visible
end)

-- Auto re-equip when farming
spawn(function()
    while task.wait(1) do
        if AutoFarmEnabled and SelectedWeapon ~= "Nothing" then
            pcall(function()
                local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if not tool or not tool.Name:lower():find(SelectedWeapon:lower()) then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EquipWeapon", SelectedWeapon)
                end
            end)
        end
    end
end)

-- Add panels to tab
LeftPanel.Parent = GeneralTab
RightPanel.Parent = GeneralTab

-- End of Part 3
print("SangHub: Part 3 (General tab) loaded")
--==[ SangHub BF Script - Part 4 (Auto Farm Logic) ]==--

-- Fast Attack function
local function fastAttack()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:Button1Down(Vector2.new(0,0))
    task.wait(0.05)
    vu:Button1Up(Vector2.new(0,0))
end

-- Fake platform
local function createPlatform()
    local part = Instance.new("Part")
    part.Size = Vector3.new(8,1,8)
    part.Anchored = true
    part.Transparency = 1
    part.CanCollide = true
    part.Parent = workspace
    return part
end

-- Farm function
local function farmTarget(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local hrp = target.HumanoidRootPart
    local platform = createPlatform()

    spawn(function()
        while AutoFarmEnabled and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
            pcall(function()
                -- Ghép 3 con: tìm thêm quái gần đó
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob ~= target and mob:FindFirstChild("HumanoidRootPart") then
                        if (mob.HumanoidRootPart.Position - hrp.Position).Magnitude < 50 then
                            mob.HumanoidRootPart.CFrame = hrp.CFrame
                        end
                    end
                end

                -- Đưa mình lên trên đầu quái
                local pos = hrp.Position + Vector3.new(0, target.HumanoidRootPart.Size.Y * 3, 0)
                platform.Position = Vector3.new(pos.X, pos.Y - 3, pos.Z)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)

                -- Fast attack
                fastAttack()
            end)
            task.wait(0.05)
        end
        platform:Destroy()
    end)
end

-- Main farm loop
spawn(function()
    while task.wait(0.2) do
        if AutoFarmEnabled and SelectedWeapon ~= "Nothing" then
            -- Tìm quái phù hợp Level hiện tại (bạn có thể dùng bảng BF_LevelFarm)
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    farmTarget(mob)
                    break
                end
            end
        end
    end
end)

print("SangHub: Part 4 (Auto Farm Logic) loaded")
