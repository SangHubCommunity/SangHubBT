-- SangHub_BetaBF_FINAL.lua
-- Full script: GUI (Sang Hub) + Player ESP (name) + Fruit ESP (from provided source) + HOP buttons (Hop, Hop Low, Rejoin)
-- Click sound id: 12221967, Toggle icon id: 92088814301938
-- Paste as LocalScript in StarterPlayerScripts or PlayerGui

repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Helper
local function new(class, props)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k] = v end end
    pcall(function() if o:IsA("GuiObject") then o.AutoLocalize = false end end)
    return o
end

-- Config colors / ids
local BLUE = Color3.fromRGB(0,140,255)
local YELLOW = Color3.fromRGB(235,190,60)
local TEXT_COLOR = Color3.fromRGB(230,230,230) -- default text color for toggles
local WHITE = Color3.fromRGB(255,255,255) -- explicit white used for hop buttons per request
local BG_COLOR = Color3.fromRGB(30,30,30)
local TAB_COLOR = Color3.fromRGB(46,46,46)
local TAB_HIGHLIGHT = Color3.fromRGB(0,110,200)
local TOGGLE_ICON = "rbxassetid://92088814301938"
local CLICK_SOUND_ID = "rbxassetid://12221967"
local GUI_W, GUI_H = 500, 350

-- Cleanup old gui
pcall(function()
    local old = PlayerGui:FindFirstChild("Sang Hub GUI")
    if old then old:Destroy() end
end)

-- ScreenGui
local screenGui = new("ScreenGui", {Name = "Sang Hub GUI", Parent = PlayerGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

-- Click sound under ScreenGui
local clickSound = new("Sound", {Parent = screenGui, SoundId = CLICK_SOUND_ID, Volume = 1})

-- Toggle ImageButton top-left
local ToggleBtn = new("ImageButton", {
    Parent = screenGui,
    Size = UDim2.new(0,50,0,50),
    Position = UDim2.new(0,10,0,10),
    BackgroundColor3 = BG_COLOR,
    Image = TOGGLE_ICON,
    AutoButtonColor = false
})
new("UICorner", {Parent = ToggleBtn, CornerRadius = UDim.new(0,8)})
new("UIStroke", {Parent = ToggleBtn, Color = BLUE, Thickness = 2})

-- Main Frame
local MainFrame = new("Frame", {
    Parent = screenGui,
    Size = UDim2.fromOffset(GUI_W, GUI_H),
    Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2),
    BackgroundColor3 = BG_COLOR,
    BorderSizePixel = 0,
    ClipsDescendants = true
})
new("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0,8)})
new("UIStroke", {Parent = MainFrame, Color = BLUE, Thickness = 2})

-- Header and Tabs
local Header = new("Frame", {Parent = MainFrame, Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1})
local TabScroll = new("ScrollingFrame", {
    Parent = Header,
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0,5,0,0),
    BackgroundTransparency = 1,
    ScrollBarThickness = 6,
    ClipsDescendants = true,
    HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
    ScrollingDirection = Enum.ScrollingDirection.X
})
local TabList = new("UIListLayout", {Parent = TabScroll, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentFrame = new("Frame", {Parent = MainFrame, Size = UDim2.new(1, -10, 1, -60), Position = UDim2.new(0,5,0,55), BackgroundTransparency = 1})

local tabNames = {"Status","Main","Item","Combat","Race & Gear","Shop & Mics"}
local tabButtons, tabPages = {}, {}

local function highlightTab(idx)
    for i,b in ipairs(tabButtons) do
        local col = (i==idx) and TAB_HIGHLIGHT or TAB_COLOR
        TweenService:Create(b, TweenInfo.new(0.18), {BackgroundColor3 = col}):Play()
    end
end
local function switchTab(idx)
    for i,p in ipairs(tabPages) do p.Visible = (i==idx) end
    highlightTab(idx)
end

-- Build tabs/pages
for i,name in ipairs(tabNames) do
    local btn = new("TextButton", {
        Parent = TabScroll,
        Size = UDim2.new(0,90,0,42),
        BackgroundColor3 = TAB_COLOR,
        BorderSizePixel = 0,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = TEXT_COLOR,
        AutoButtonColor = false
    })
    btn.AutoLocalize = false
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
    new("UIStroke", {Parent = btn, Color = BLUE, Thickness = 1})
    table.insert(tabButtons, btn)

    local page = new("ScrollingFrame", {Parent = ContentFrame, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 6})
    new("UIListLayout", {Parent = page, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
    new("UIPadding", {Parent = page, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,6)})
    table.insert(tabPages, page)

    btn.MouseButton1Click:Connect(function() switchTab(i) end)
end

RunService.Heartbeat:Wait()
local function updateCanvas()
    local total = 0
    for _,b in ipairs(tabButtons) do total = total + (b.AbsoluteSize.X + TabList.Padding.Offset) end
    TabScroll.CanvasSize = UDim2.new(0, math.max(total + 12, TabScroll.AbsoluteSize.X), 0, 0)
end
updateCanvas()
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
switchTab(1)

-- ========== Get_Fruit mapping (source) ==========
local function Get_Fruit(Fruit)
  if Fruit == "Rocket Fruit" then
    return "Rocket-Rocket"
  elseif Fruit == "Spin Fruit" then
    return "Spin-Spin"
  elseif Fruit == "Chop Fruit" then
    return "Chop-Chop"
  elseif Fruit == "Spring Fruit" then
    return "Spring-Spring"
  elseif Fruit == "Bomb Fruit" then
    return "Bomb-Bomb"
  elseif Fruit == "Smoke Fruit" then
    return "Smoke-Smoke"
  elseif Fruit == "Spike Fruit" then
    return "Spike-Spike"
  elseif Fruit == "Flame Fruit" then
    return "Flame-Flame"
  elseif Fruit == "Falcon Fruit" then
    return "Falcon-Falcon"
  elseif Fruit == "Ice Fruit" then
    return "Ice-Ice"
  elseif Fruit == "Sand Fruit" then
    return "Sand-Sand"
  elseif Fruit == "Dark Fruit" then
    return "Dark-Dark"
  elseif Fruit == "Ghost Fruit" then
    return "Ghost-Ghost"
  elseif Fruit == "Diamond Fruit" then
    return "Diamond-Diamond"
  elseif Fruit == "Light Fruit" then
    return "Light-Light"
  elseif Fruit == "Rubber Fruit" then
    return "Rubber-Rubber"
  elseif Fruit == "Barrier Fruit" then
    return "Barrier-Barrier"
  elseif Fruit == "Magma Fruit" then
    return "Magma-Magma"
  elseif Fruit == "Quake Fruit" then
    return "Quake-Quake"
  elseif Fruit == "Buddha Fruit" then
    return "Buddha-Buddha"
  elseif Fruit == "Love Fruit" then
    return "Love-Love"
  elseif Fruit == "Spider Fruit" then
    return "Spider-Spider"
  elseif Fruit == "Sound Fruit" then
    return "Sound-Sound"
  elseif Fruit == "Phoenix Fruit" then
    return "Phoenix-Phoenix"
  elseif Fruit == "Portal Fruit" then
    return "Portal-Portal"
  elseif Fruit == "Rumble Fruit" then
    return "Rumble-Rumble"
  elseif Fruit == "Pain Fruit" then
    return "Pain-Pain"
  elseif Fruit == "Blizzard Fruit" then
    return "Blizzard-Blizzard"
  elseif Fruit == "Gravity Fruit" then
    return "Gravity-Gravity"
  elseif Fruit == "Mammoth Fruit" then
    return "Mammoth-Mammoth"
  elseif Fruit == "T-Rex Fruit" then
    return "T-Rex-T-Rex"
  elseif Fruit == "Dough Fruit" then
    return "Dough-Dough"
  elseif Fruit == "Shadow Fruit" then
    return "Shadow-Shadow"
  elseif Fruit == "Venom Fruit" then
    return "Venom-Venom"
  elseif Fruit == "Control Fruit" then
    return "Control-Control"
  elseif Fruit == "Spirit Fruit" then
    return "Spirit-Spirit"
  elseif Fruit == "Dragon Fruit" then
    return "Dragon-Dragon"
  elseif Fruit == "Leopard Fruit" then
    return "Leopard-Leopard"
  elseif Fruit == "Kitsune Fruit" then
    return "Kitsune-Kitsune"
  end
end

-- ========== Player ESP (name) ==========
local playerESPs = {} -- [player] = {gui,label,root}
local playerConn = nil
local function createPlayerNameESP(plr)
    if not plr or not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChildWhichIsA("BasePart")
    if not root then return end
    if playerESPs[plr] then return end

    local bg = Instance.new("BillboardGui")
    bg.Name = "Sang_PlayerESP"
    bg.Adornee = root
    bg.Size = UDim2.new(0,160,0,32)
    bg.StudsOffset = Vector3.new(0,2.6,0)
    bg.AlwaysOnTop = true
    bg.Parent = PlayerGui

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.TextColor3 = BLUE
    txt.TextStrokeTransparency = 0.6
    txt.TextXAlignment = Enum.TextXAlignment.Center
    txt.Text = plr.Name

    playerESPs[plr] = {gui = bg, label = txt, root = root}
end

local function removePlayerESP(plr)
    if playerESPs[plr] and playerESPs[plr].gui and playerESPs[plr].gui.Parent then playerESPs[plr].gui:Destroy() end
    playerESPs[plr] = nil
end

local function startPlayerESP()
    if playerConn then return end
    playerConn = RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if plr.Character and plr.Character.Parent then
                    createPlayerNameESP(plr)
                    local data = playerESPs[plr]
                    if data and data.root and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                        local dist = (data.root.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                        data.label.Text = string.format("%s | %.0f", plr.Name, dist)
                    end
                else
                    removePlayerESP(plr)
                end
            end
        end
        for p,_ in pairs(playerESPs) do if not Players:FindFirstChild(p.Name) then removePlayerESP(p) end end
    end)
end

local function stopPlayerESP()
    if playerConn then playerConn:Disconnect(); playerConn = nil end
    for p,_ in pairs(playerESPs) do removePlayerESP(p) end
end

-- ========== Fruit ESP (from source) ==========
local fruitESPs = {} -- [instance] = gui
local fruitConn = nil

local function createFruitESP(item)
    if not item then return end
    if fruitESPs[item] then return end
    local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
    if not handle then return end
    local bg = Instance.new("BillboardGui")
    bg.Name = "Sang_FruitESP"
    bg.Adornee = handle
    bg.Size = UDim2.new(0,120,0,26)
    bg.StudsOffset = Vector3.new(0,1.5,0)
    bg.AlwaysOnTop = true
    bg.Parent = PlayerGui

    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1,0,1,0)
    tl.BackgroundTransparency = 1
    tl.Text = item.Name
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 14
    tl.TextColor3 = Color3.fromRGB(255,100,100)
    tl.TextStrokeTransparency = 0.6
    tl.TextXAlignment = Enum.TextXAlignment.Center

    fruitESPs[item] = bg
end

local function removeFruitESP(item)
    if fruitESPs[item] and fruitESPs[item].Parent then fruitESPs[item]:Destroy() end
    fruitESPs[item] = nil
end

local function startFruitESP()
    if fruitConn then return end
    fruitConn = RunService.Heartbeat:Connect(function()
        if not getgenv().FruitsESP then
            for it,_ in pairs(fruitESPs) do removeFruitESP(it) end
            return
        end
        local function scan(c)
            for _, obj in ipairs(c:GetChildren()) do
                if (obj:IsA("Tool") or obj:IsA("Model")) and (string.find(obj.Name, "Fruit") or string.find(obj.Name, "fruit")) then
                    if not fruitESPs[obj] then createFruitESP(obj) end
                end
            end
        end
        scan(Workspace)
        for _,c in ipairs(Workspace:GetChildren()) do pcall(scan, c) end
        for it,_ in pairs(fruitESPs) do if not it or not it.Parent then removeFruitESP(it) end end
    end)
end

local function stopFruitESP()
    if fruitConn then fruitConn:Disconnect(); fruitConn = nil end
    for it,_ in pairs(fruitESPs) do removeFruitESP(it) end
end

-- ========== Shop & Mics (split layout) ==========
local shopIndex = nil
for i,name in ipairs(tabNames) do if name == "Shop & Mics" then shopIndex = i break end end
local shopPage = tabPages[shopIndex]

local shopContainer = new("Frame", {Parent = shopPage, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
new("UIPadding", {Parent = shopContainer, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,6)})
local leftFrame = new("Frame", {Parent = shopContainer, Size = UDim2.new(0.5, -6, 1, 0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
local rightFrame = new("Frame", {Parent = shopContainer, Size = UDim2.new(0.5, -6, 1, 0), Position = UDim2.new(0.5, 6, 0, 0), BackgroundTransparency = 1})

new("UIListLayout", {Parent = leftFrame, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
new("UIPadding", {Parent = leftFrame, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})
new("UIListLayout", {Parent = rightFrame, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
new("UIPadding", {Parent = rightFrame, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

local divider = new("Frame", {Parent = shopContainer, Size = UDim2.new(0,2,1,0), Position = UDim2.new(0.5, -1, 0, 0), BackgroundColor3 = BLUE, BorderSizePixel = 0})

-- Titles (left ESP, right FRUIT)
local leftTitle = new("TextLabel", {Parent = leftFrame, Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "ESP", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = BLUE, TextXAlignment = Enum.TextXAlignment.Center})
local rightTitle = new("TextLabel", {Parent = rightFrame, Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = "FRUIT", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = BLUE, TextXAlignment = Enum.TextXAlignment.Center})

-- spacers
new("Frame", {Parent = leftFrame, Size = UDim2.new(1,0,0,6), BackgroundTransparency = 1})
new("Frame", {Parent = rightFrame, Size = UDim2.new(1,0,0,6), BackgroundTransparency = 1})

-- Toggle factory
local function createToggle(parent, text, colorOn, globalName, onChange)
    local btn = new("TextButton", {Parent = parent, Size = UDim2.new(1, -12, 0, 36), BackgroundColor3 = TAB_COLOR, BorderSizePixel = 0, Text = "", AutoButtonColor = false})
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
    new("UIStroke", {Parent = btn, Color = BLUE, Thickness = 1})

    local label = new("TextLabel", {Parent = btn, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1, -50, 1, 0), Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = TEXT_COLOR, TextXAlignment = Enum.TextXAlignment.Left})
    label.AutoLocalize = false

    local circle = new("Frame", {Parent = btn, Size = UDim2.new(0,20,0,20), Position = UDim2.new(1, -28, 0.5, -10), BackgroundColor3 = Color3.fromRGB(100,100,100)})
    new("UICorner", {Parent = circle, CornerRadius = UDim.new(1,0)})
    local stroke = new("UIStroke", {Parent = circle, Color = Color3.fromRGB(150,150,150), Thickness = 1.6})

    if globalName then pcall(function() getgenv()[globalName] = getgenv()[globalName] or false end) end

    btn.MouseButton1Click:Connect(function()
        pcall(function() clickSound:Play() end)
        local newState = not (getgenv()[globalName] == true)
        if globalName then pcall(function() getgenv()[globalName] = newState end) end
        TweenService:Create(circle, TweenInfo.new(0.18), {BackgroundColor3 = newState and colorOn or Color3.fromRGB(100,100,100)}):Play()
        stroke.Color = newState and colorOn or Color3.fromRGB(150,150,150)
        if onChange then pcall(onChange, newState) end
    end)

    return btn
end

-- Left: Player ESP & Fruit ESP toggles
createToggle(leftFrame, "Player ESP", BLUE, "PlayerESP", function(state) if state then startPlayerESP() else stopPlayerESP() end end)
createToggle(leftFrame, "Fruit ESP", YELLOW, "FruitsESP", function(state) if state then startFruitESP() else stopFruitESP() end end)

-- HOP title (match ESP color per request)
local hopTitle = new("TextLabel", {Parent = leftFrame, Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Text = "HOP", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = BLUE, TextXAlignment = Enum.TextXAlignment.Center})
new("Frame", {Parent = leftFrame, Size = UDim2.new(1,0,0,6), BackgroundTransparency = 1})

-- Action button factory (textColor optional)
local function createActionButton(parent, text, onClick, textColor)
    local btn = new("TextButton", {Parent = parent, Size = UDim2.new(1, -12, 0, 36), BackgroundColor3 = TAB_COLOR, BorderSizePixel = 0, Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = (textColor or TEXT_COLOR)})
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
    new("UIStroke", {Parent = btn, Color = BLUE, Thickness = 1})
    btn.AutoLocalize = false
    btn.MouseButton1Click:Connect(function()
        pcall(function() clickSound:Play() end)
        pcall(onClick)
    end)
    return btn
end

-- Hop functions (same place)
local function hopToAnyServer()
    -- play already called by click handler
    local placeId = game.PlaceId
    local ok, body = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
    end)
    if not ok or not body then return end
    local parsed = nil
    pcall(function() parsed = HttpService:JSONDecode(body) end)
    if not parsed or not parsed.data then return end
    for _, s in ipairs(parsed.data) do
        if s.id and s.id ~= game.JobId then
            pcall(function() TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer) end)
            return
        end
    end
end

local function hopToLowestServer()
    local placeId = game.PlaceId
    local ok, body = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
    end)
    if not ok or not body then return end
    local parsed = nil
    pcall(function() parsed = HttpService:JSONDecode(body) end)
    if not parsed or not parsed.data then return end
    local lowest = math.huge local chosen = nil
    for _, s in ipairs(parsed.data) do
        if s.id and s.id ~= game.JobId and type(s.playing) == "number" then
            if s.playing < lowest then lowest = s.playing; chosen = s.id end
        end
    end
    if chosen then pcall(function() TeleportService:TeleportToPlaceInstance(placeId, chosen, LocalPlayer) end) end
end

local function rejoinCurrent()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end

-- Create Hop action buttons with WHITE text (match ESP button font color)
createActionButton(leftFrame, "Hop Server", hopToAnyServer, WHITE)
createActionButton(leftFrame, "Hop Server Low Player", hopToLowestServer, WHITE)
createActionButton(leftFrame, "Rejoin Server", rejoinCurrent, WHITE)

-- RightFrame reserved (title FRUIT shown but empty content)
-- Ensure getgenv defaults
pcall(function()
    if getgenv then
        getgenv().PlayerESP = getgenv().PlayerESP or false
        getgenv().FruitsESP = getgenv().FruitsESP or false
    end
end)

if getgenv().PlayerESP then startPlayerESP() end
if getgenv().FruitsESP then startFruitESP() end

-- Show/hide main GUI (zoom effect)
local visible = true
ToggleBtn.MouseButton1Click:Connect(function()
    visible = not visible
    if visible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, GUI_W, 0, GUI_H)}):Play()
    else
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        tw:Play(); tw.Completed:Wait()
        MainFrame.Visible = false
    end
end)

-- Dragging support (mouse & touch)
do
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

print("SangHub_BetaBF_FINAL loaded. Player ESP + Fruit ESP + HOP buttons ready.")