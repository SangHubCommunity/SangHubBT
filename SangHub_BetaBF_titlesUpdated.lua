-- Sang Hub GUI with Player ESP (blue) & Fruit ESP (yellow)
-- Paste to StarterPlayerScripts (LocalScript)

repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Helpers
local function new(class, props)
    local o = Instance.new(class)
    if props then
        for k, v in pairs(props) do o[k] = v end
    end
    pcall(function() if o:IsA("GuiObject") then o.AutoLocalize = false end end)
    return o
end

-- Config / Colors (kept from your chosen style)
local BLUE = Color3.fromRGB(0,140,255)
local YELLOW = Color3.fromRGB(235,190,60)
local TEXT_COLOR = Color3.fromRGB(230,230,230)
local BG_COLOR = Color3.fromRGB(30,30,30)
local TAB_COLOR = Color3.fromRGB(46,46,46)
local TAB_HIGHLIGHT = Color3.fromRGB(0,110,200)
local TOGGLE_ICON = "rbxassetid://92088814301938"
local GUI_W, GUI_H = 500, 350

-- Remove old gui if exists
pcall(function()
    local old = PlayerGui:FindFirstChild("Sang Hub GUI")
    if old then old:Destroy() end
end)

-- Root ScreenGui
local screenGui = new("ScreenGui", {
    Name = "Sang Hub GUI",
    Parent = PlayerGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Top-left toggle icon
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

-- Main window
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

-- Header (transparent)
local Header = new("Frame", {Parent = MainFrame, Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1})

-- TabScroll
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

-- Content area
local ContentFrame = new("Frame", {Parent = MainFrame, Size = UDim2.new(1, -10, 1, -60), Position = UDim2.new(0,5,0,55), BackgroundTransparency = 1})

-- Tabs
local tabNames = {"Status","Main","Item","Combat","Race & Gear","Shop & Mics"}
local tabButtons = {}
local tabPages = {}

local function highlightTab(idx)
    for i, b in ipairs(tabButtons) do
        local col = (i==idx) and TAB_HIGHLIGHT or TAB_COLOR
        TweenService:Create(b, TweenInfo.new(0.18), {BackgroundColor3 = col}):Play()
    end
end

local function switchTab(idx)
    for i, p in ipairs(tabPages) do p.Visible = (i==idx) end
    highlightTab(idx)
end

-- make tabs + pages
for i, name in ipairs(tabNames) do
    local tabBtn = new("TextButton", {
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
    tabBtn.AutoLocalize = false
    new("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0,6)})
    new("UIStroke", {Parent = tabBtn, Color = BLUE, Thickness = 1})
    table.insert(tabButtons, tabBtn)

    local page = new("ScrollingFrame", {
        Parent = ContentFrame,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 6
    })
    new("UIListLayout", {Parent = page, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
    -- add padding so content not flush to left
    new("UIPadding", {Parent = page, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,6)})
    table.insert(tabPages, page)

    tabBtn.MouseButton1Click:Connect(function() switchTab(i) end)
end

-- ensure canvas
RunService.Heartbeat:Wait()
local function updateCanvas()
    local total = 0
    for _, b in ipairs(tabButtons) do
        total = total + (b.AbsoluteSize.X + TabList.Padding.Offset)
    end
    TabScroll.CanvasSize = UDim2.new(0, math.max(total + 12, TabScroll.AbsoluteSize.X), 0, 0)
end
updateCanvas()
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- open first tab
switchTab(1)

-- Helper: create toggles used in various pages
local function createToggleStyle(parent, labelText, initialState, onToggle)
    local btn = new("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, -12, 0, 36),
        BackgroundColor3 = TAB_COLOR,
        BorderSizePixel = 0,
        Text = "FRUIT",
        AutoButtonColor = false
    })
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
    new("UIStroke", {Parent = btn, Color = BLUE, Thickness = 1})

    local label = new("TextLabel", {
        Parent = btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,0),
        Size = UDim2.new(1, -50, 1, 0),
        Text = labelText,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = TEXT_COLOR,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    label.AutoLocalize = false

    local circle = new("Frame", {
        Parent = btn,
        Size = UDim2.new(0,20,0,20),
        Position = UDim2.new(1, -28, 0.5, -10),
        BackgroundColor3 = (initialState and BLUE) or Color3.fromRGB(100,100,100)
    })
    new("UICorner", {Parent = circle, CornerRadius = UDim.new(1,0)})
    local stroke = new("UIStroke", {Parent = circle, Color = (initialState and BLUE) or Color3.fromRGB(150,150,150), Thickness = 1.6})

    local state = initialState or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        -- animate color change
        TweenService:Create(circle, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundColor3 = (state and BLUE) or Color3.fromRGB(100,100,100)}):Play()
        stroke.Color = (state and BLUE) or Color3.fromRGB(150,150,150)
        if onToggle then
            pcall(function() onToggle(state) end)
        end
    end)
    return btn, function() return state end
end

-- === Build Shop & Mics page content (right side ESP title + toggles) ===
local shopIndex = nil
for i,name in ipairs(tabNames) do if name == "Shop & Mics" then shopIndex = i break end end
if not shopIndex then shopIndex = #tabNames end
local shopPage = tabPages[shopIndex]

-- container frame inside page to allow horizontal split
local shopContainer = new("Frame", {Parent = shopPage, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
new("UIListLayout", {Parent = shopContainer, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})

local leftFrame = new("Frame", {Parent = shopContainer, Size = UDim2.new(0.5, -6, 1, 0), BackgroundTransparency = 1})
new("UIListLayout", {Parent = leftFrame, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
new("UIPadding", {Parent = leftFrame, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

local rightFrame = new("Frame", {Parent = shopContainer, Size = UDim2.new(0.5, -6, 1, 0), BackgroundTransparency = 1})
new("UIListLayout", {Parent = rightFrame, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
new("UIPadding", {Parent = rightFrame, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

-- Title "ESP" centered for right column
local espTitle = new("TextLabel", {
    Parent = rightFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,0,0,22),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = BLUE,
    TextXAlignment = Enum.TextXAlignment.Center
})

-- Setup getgenv flags default
pcall(function()
    if getgenv then
        getgenv().PlayerESP = getgenv().PlayerESP or false
        getgenv().FruitsESP = getgenv().FruitsESP or false
    end
end)

-- ESP storage
local playerESPs = {}   -- player -> BillboardGui
local fruitESPs = {}    -- instance -> BillboardGui

-- CAMERA reference
local camera = Workspace.CurrentCamera

-- Utility: has line-of-sight (no wall between camera and target)
local function hasLoS(targetPosition)
    local origin = camera.CFrame.Position
    local dir = (targetPosition - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true
    local res = Workspace:Raycast(origin, dir.Unit * math.min(dir.Magnitude, 10000), rayParams)
    if not res then return true end
    -- allow if hit part is descendant of targetPosition's parent (e.g., target's part)
    if res.Instance and (res.Instance:IsDescendantOf(targetPosition.Parent)) then
        return true
    end
    return false
end

-- Create/Remove player ESP
local function createPlayerESP(plr)
    if not plr or not plr.Character then return end
    local chr = plr.Character
    local root = chr:FindFirstChild("HumanoidRootPart") or chr:FindFirstChild("Humanoid") and chr.Humanoid.RootPart
    if not root then return end

    -- avoid duplicates
    if playerESPs[plr] and playerESPs[plr].Parent then return end

    local bg = Instance.new("BillboardGui")
    bg.Name = "SangPlayerESP"
    bg.Adornee = root
    bg.Size = UDim2.new(0,140,0,40)
    bg.StudsOffset = Vector3.new(0, 2.6, 0)
    bg.AlwaysOnTop = true
    bg.Parent = PlayerGui

    local frame = Instance.new("Frame", bg)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 0.35
    frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    local nameLabel = Instance.new("TextLabel", bg)
    nameLabel.Size = UDim2.new(1, -4, 0.5, -2)
    nameLabel.Position = UDim2.new(0,2,0,2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = BLUE
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = plr.Name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local distLabel = Instance.new("TextLabel", bg)
    distLabel.Size = UDim2.new(1, -4, 0.5, -2)
    distLabel.Position = UDim2.new(0,2,0.5,0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = TEXT_COLOR
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Text = ""
    distLabel.TextXAlignment = Enum.TextXAlignment.Left

    playerESPs[plr] = {gui = bg, nameLabel = nameLabel, distLabel = distLabel, root = root}
end

local function removePlayerESP(plr)
    local data = playerESPs[plr]
    if data and data.gui and data.gui.Parent then
        data.gui:Destroy()
    end
    playerESPs[plr] = nil
end

-- Fruit ESP creation/removal
local function createFruitESP(item)
    if not item or not item:IsA("Tool") then return end
    if fruitESPs[item] and fruitESPs[item].Parent then return end
    local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
    if not handle then return end

    local bg = Instance.new("BillboardGui")
    bg.Name = "SangFruitESP"
    bg.Adornee = handle
    bg.Size = UDim2.new(0,120,0,30)
    bg.StudsOffset = Vector3.new(0, 1.5, 0)
    bg.AlwaysOnTop = true
    bg.Parent = PlayerGui

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = YELLOW
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.Text = item.Name
    txt.TextScaled = false
    txt.TextWrapped = false
    txt.TextXAlignment = Enum.TextXAlignment.Center
    txt.TextYAlignment = Enum.TextYAlignment.Center

    fruitESPs[item] = bg
end

local function removeFruitESP(item)
    if fruitESPs[item] and fruitESPs[item].Parent then
        fruitESPs[item]:Destroy()
    end
    fruitESPs[item] = nil
end

-- Update loops
local playerConn = nil
local fruitConn = nil

-- Player ESP update loop
local function startPlayerESPLoop()
    if playerConn then return end
    playerConn = RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char and char.Parent then
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Humanoid") and char.Humanoid.RootPart
                    if root then
                        -- ensure gui exists
                        if getgenv().PlayerESP then
                            if not playerESPs[plr] then createPlayerESP(plr) end
                        else
                            if playerESPs[plr] then removePlayerESP(plr) end
                        end
                        -- update if exists
                        local data = playerESPs[plr]
                        if data and data.gui.Parent then
                            local camPos = Workspace.CurrentCamera.CFrame.Position
                            local dist = (root.Position - camPos).Magnitude
                            data.distLabel.Text = string.format("%.1f m", dist)
                            -- LOS check (no through walls)
                            local visible = hasLoS(root.Position)
                            data.gui.Enabled = visible
                        end
                    else
                        if playerESPs[plr] then removePlayerESP(plr) end
                    end
                else
                    if playerESPs[plr] then removePlayerESP(plr) end
                end
            end
        end
    end)
end

local function stopPlayerESPLoop()
    if playerConn then
        playerConn:Disconnect()
        playerConn = nil
    end
    for plr, _ in pairs(playerESPs) do removePlayerESP(plr) end
end

-- Fruit ESP update loop (scan workspace for Tools with "Fruit" in name)
local function startFruitESPLoop()
    if fruitConn then return end
    fruitConn = RunService.Heartbeat:Connect(function()
        if not getgenv().FruitsESP then
            -- remove all if off
            for it, _ in pairs(fruitESPs) do removeFruitESP(it) end
            return
        end
        -- scan tools in workspace (common places)
        local function scanContainer(c)
            for _, obj in ipairs(c:GetChildren()) do
                if obj:IsA("Tool") or obj:IsA("Accessory") or obj:IsA("Model") then
                    if string.find(obj.Name, "Fruit") or string.find(obj.Name, "fruit") then
                        -- create esp if not exist
                        if not fruitESPs[obj] then createFruitESP(obj) end
                    end
                end
            end
        end
        -- scan workspace root
        scanContainer(Workspace)
        -- scan descendants (to catch dropped fruit in other folders)
        for _, c in ipairs(Workspace:GetChildren()) do
            pcall(scanContainer, c)
        end
        -- cleanup invalid
        for it, gui in pairs(fruitESPs) do
            if not it or not it.Parent then removeFruitESP(it) end
        end
    end)
end

local function stopFruitESPLoop()
    if fruitConn then
        fruitConn:Disconnect()
        fruitConn = nil
    end
    for it, _ in pairs(fruitESPs) do removeFruitESP(it) end
end

-- Tie toggles to GUI buttons (create toggles in Shop & Mics right frame)
-- Find rightFrame used earlier
-- We created shopContainer with two frames earlier; we must locate rightFrame
-- Simpler: iterate tabPages and find the one named Shop & Mics by index shopIndex
local shopIndex = nil
for i,name in ipairs(tabNames) do if name == "Shop & Mics" then shopIndex = i break end end
local shopPage = tabPages[shopIndex]

-- Build container if not already (we used earlier to create space, but to be safe, build here)
local shopContainer2 = nil
for _, child in ipairs(shopPage:GetChildren()) do
    if child:IsA("Frame") and child.Size.X.Scale == 1 then
        shopContainer2 = child
        break
    end
end
-- if not exist, create simple left/right frames
if not shopContainer2 then
    shopContainer2 = new("Frame", {Parent = shopPage, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
    new("UIListLayout", {Parent = shopContainer2, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
end

-- find right frame inside container
local rightFrame = nil
for _, c in ipairs(shopContainer2:GetChildren()) do
    if c:IsA("Frame") and c.Size.X.Scale == 0.5 then
        if not rightFrame then rightFrame = c else rightFrame = rightFrame end
    end
end
-- if not found, create rightFrame now
if not rightFrame then
    rightFrame = new("Frame", {Parent = shopContainer2, Size = UDim2.new(0.5, -6, 1, 0), BackgroundTransparency = 1})
    new("UIListLayout", {Parent = rightFrame, FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
    new("UIPadding", {Parent = rightFrame, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})
end

-- add ESP title if missing
local function ensureEspTitle()
    for _, c in ipairs(rightFrame:GetChildren()) do
        if c:IsA("TextLabel") and c.Text == "ESP" then return end
    end
    new("TextLabel", {
        Parent = rightFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,22),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = BLUE,
        TextXAlignment = Enum.TextXAlignment.Center
    })
end
ensureEspTitle()

-- Create toggles and hook actions
local function addTogglesToRightFrame()
    -- remove any existing toggle buttons we might have created earlier to avoid duplicates
    for _, c in ipairs(rightFrame:GetChildren()) do
        if c:IsA("TextButton") and (c.Name == "SangToggle_PlayerESP" or c.Name == "SangToggle_FruitESP") then
            c:Destroy()
        end
    end

    -- Player ESP toggle
    local playerBtn, getPlayerState
    do
        playerBtn = new("TextButton", {
            Parent = rightFrame,
            Name = "SangToggle_PlayerESP",
            Size = UDim2.new(1, -12, 0, 36),
            BackgroundColor3 = TAB_COLOR,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        new("UICorner", {Parent = playerBtn, CornerRadius = UDim.new(0,6)})
        new("UIStroke", {Parent = playerBtn, Color = BLUE, Thickness = 1})

        new("TextLabel", {
            Parent = playerBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0,10,0,0),
            Size = UDim2.new(1, -50, 1, 0),
            Text = "Player ESP",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = TEXT_COLOR,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local circle = new("Frame", {Parent = playerBtn, Size = UDim2.new(0,20,0,20), Position = UDim2.new(1, -28, 0.5, -10), BackgroundColor3 = getgenv().PlayerESP and BLUE or Color3.fromRGB(100,100,100)})
        new("UICorner", {Parent = circle, CornerRadius = UDim.new(1,0)})
        local stroke = new("UIStroke", {Parent = circle, Color = getgenv().PlayerESP and BLUE or Color3.fromRGB(150,150,150), Thickness = 1.6})

        playerBtn.MouseButton1Click:Connect(function()
            local newS = not (getgenv().PlayerESP == true)
            getgenv().PlayerESP = newS
            TweenService:Create(circle, TweenInfo.new(0.18), {BackgroundColor3 = newS and BLUE or Color3.fromRGB(100,100,100)}):Play()
            stroke.Color = newS and BLUE or Color3.fromRGB(150,150,150)
            if newS then startPlayerESPLoop() else stopPlayerESPLoop() end
        end)
    end

    -- Fruit ESP toggle
    local fruitBtn
    do
        fruitBtn = new("TextButton", {
            Parent = rightFrame,
            Name = "SangToggle_FruitESP",
            Size = UDim2.new(1, -12, 0, 36),
            BackgroundColor3 = TAB_COLOR,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        new("UICorner", {Parent = fruitBtn, CornerRadius = UDim.new(0,6)})
        new("UIStroke", {Parent = fruitBtn, Color = BLUE, Thickness = 1})

        new("TextLabel", {
            Parent = fruitBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0,10,0,0),
            Size = UDim2.new(1, -50, 1, 0),
            Text = "Fruit ESP",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = TEXT_COLOR,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local circle = new("Frame", {Parent = fruitBtn, Size = UDim2.new(0,20,0,20), Position = UDim2.new(1, -28, 0.5, -10), BackgroundColor3 = getgenv().FruitsESP and YELLOW or Color3.fromRGB(100,100,100)})
        new("UICorner", {Parent = circle, CornerRadius = UDim.new(1,0)})
        local stroke = new("UIStroke", {Parent = circle, Color = getgenv().FruitsESP and YELLOW or Color3.fromRGB(150,150,150), Thickness = 1.6})

        fruitBtn.MouseButton1Click:Connect(function()
            local newS = not (getgenv().FruitsESP == true)
            getgenv().FruitsESP = newS
            TweenService:Create(circle, TweenInfo.new(0.18), {BackgroundColor3 = newS and YELLOW or Color3.fromRGB(100,100,100)}):Play()
            stroke.Color = newS and YELLOW or Color3.fromRGB(150,150,150)
            if newS then startFruitESPLoop() else stopFruitESPLoop() end
        end)
    end
end

addTogglesToRightFrame()

-- Ensure toggles match current getgenv state on load
if getgenv().PlayerESP then startPlayerESPLoop() end
if getgenv().FruitsESP then startFruitESPLoop() end

-- GUI show/hide behaviour (kept as before, animated)
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

-- Dragging (touch + mouse)
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

print("Sang Hub GUI loaded. PlayerESP & FruitESP toggles available.")
