-- BloxFruit Tab GUI (Status fix) - RAW .lua
-- Gồm: GUI toggle + TabScroll + Tab Status (boss, fruit, players, elapsed, moon)
-- Paste thẳng vào executor (KRNL/Flux/...) trong Blox Fruits

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local RS = RunService

local localPlayer = Players.LocalPlayer

-- Start time for elapsed counter
local START_TICK = tick()

-- ---------- GUI ----------
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "BloxFruit_TabGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Toggle Button (corner)
local ToggleBtn = Instance.new("ImageButton", Gui)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.Image = "rbxassetid://76955883171909"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.AutoButtonColor = true
local corner = Instance.new("UICorner", ToggleBtn); corner.CornerRadius = UDim.new(0,6)

-- Main Frame
local MainFrame = Instance.new("Frame", Gui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 360)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

-- Logo
local Logo = Instance.new("ImageLabel", MainFrame)
Logo.Size = UDim2.new(0,30,0,30)
Logo.Position = UDim2.new(0,10,0,5)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://76955883171909"

-- Tab scroll (top)
local TabScroll = Instance.new("ScrollingFrame", MainFrame)
TabScroll.Name = "TabScroll"
TabScroll.Size = UDim2.new(1, -40, 0, 40)
TabScroll.Position = UDim2.new(0, 40, 0, 5)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 2
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0,5)

-- Create tab frames container (content area)
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -20, 1, -50)
ContentContainer.Position = UDim2.new(0,10,0,45)
ContentContainer.BackgroundTransparency = 1

-- Tab names
local Tabs = {"Tab Status", "Tab General", "Quest & Item", "Race & Gear", "Tab Shop", "Tab Setting", "Mic"}
local TabFrames = {}

for i, tabName in ipairs(Tabs) do
    -- tab button
    local TabBtn = Instance.new("TextButton", TabScroll)
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.Text = tabName
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    TabBtn.AutoButtonColor = true
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,8)

    -- tab content (scrollable)
    local Content = Instance.new("ScrollingFrame", ContentContainer)
    Content.Name = tabName.."_Content"
    Content.Size = UDim2.new(1,0,1,0)
    Content.Position = UDim2.new(0,0,0,0)
    Content.BackgroundTransparency = 1
    Content.Visible = false
    Content.ScrollBarThickness = 6
    Content.CanvasSize = UDim2.new(0,0,0,0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", Content)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    TabFrames[tabName] = Content

    TabBtn.MouseButton1Click:Connect(function()
        -- show only this content (DO NOT toggle main visibility)
        for k,v in pairs(TabFrames) do v.Visible = false end
        Content.Visible = true
    end)
end

-- Default open
TabFrames["Tab Status"].Visible = true

-- Toggle animation show/hide
local isVisible = false
ToggleBtn.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    if isVisible then
        MainFrame.Size = UDim2.new(0,0,0,0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,580,0,360)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        delay(0.24, function() MainFrame.Visible = false MainFrame.Size = UDim2.new(0,580,0,360) end)
    end
end)

-- ---------- STATUS TAB CONTENT ----------
local StatusTab = TabFrames["Tab Status"]

-- Title centered
local Title = Instance.new("TextLabel", StatusTab)
Title.Size = UDim2.new(1, -40, 0, 36)
Title.Position = UDim2.new(0,20,0,6)
Title.BackgroundTransparency = 1
Title.Text = "STATUS"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Center

-- container layout (under title)
local statusContainer = Instance.new("Frame", StatusTab)
statusContainer.Size = UDim2.new(1, -40, 1, -56)
statusContainer.Position = UDim2.new(0,20,0,50)
statusContainer.BackgroundTransparency = 1
local statusLayout = Instance.new("UIListLayout", statusContainer)
statusLayout.Padding = UDim.new(0,8)
statusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statusContainer.AutomaticSize = Enum.AutomaticSize.Y

-- Helper: create a labeled status row
local function createRow(name, default)
    local row = Instance.new("Frame", statusContainer)
    row.Size = UDim2.new(1, -20, 0, 28)
    row.BackgroundTransparency = 1

    local lblName = Instance.new("TextLabel", row)
    lblName.Size = UDim2.new(0.55, 0, 1, 0)
    lblName.Position = UDim2.new(0,0,0,0)
    lblName.BackgroundTransparency = 1
    lblName.Font = Enum.Font.GothamBold
    lblName.TextSize = 14
    lblName.TextXAlignment = Enum.TextXAlignment.Left
    lblName.TextColor3 = Color3.fromRGB(200,200,200)
    lblName.Text = name

    local lblVal = Instance.new("TextLabel", row)
    lblVal.Size = UDim2.new(0.45, 0, 1, 0)
    lblVal.Position = UDim2.new(0.55, 0, 0, 0)
    lblVal.BackgroundTransparency = 1
    lblVal.Font = Enum.Font.Gotham
    lblVal.TextSize = 14
    lblVal.TextXAlignment = Enum.TextXAlignment.Right
    lblVal.TextColor3 = Color3.fromRGB(255,255,255)
    lblVal.Text = default or "—"

    return {Frame = row, NameLabel = lblName, ValueLabel = lblVal}
end

-- Create status rows:
local statusPlayers = createRow("Players in server:", "0")
local statusBossShank = createRow("Shank (Red Hair):", "❌")
local statusBossWhitebeard = createRow("Whitebeard:", "❌")
local statusBossSaw = createRow("The Saw:", "❌")
local statusFruits = createRow("FRUIT SPAWN / DROP:", "❌")
local statusTime = createRow("Script elapsed:", "0s")
local statusMoon = createRow("Moon:", "❓")
local statusCheck = createRow("Status:", "Checking")

-- ---------- Logic: detection helpers ----------
-- Boss patterns (lowercase)
local BossPatterns = {
    Shank = {"shank", "shanks"}, -- adjust as needed
    Whitebeard = {"whitebeard", "white beard", "white-beard"},
    TheSaw = {"the saw", "saw"}
}

local function findInWorkspaceByPatterns(patterns)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and obj.Name then
            local nm = tostring(obj.Name):lower()
            for _, pat in ipairs(patterns) do
                if nm:find(pat:lower()) then
                    return true, obj
                end
            end
        end
    end
    return false, nil
end

-- Boss check
local function checkBossSpawn()
    -- return booleans for each key
    local shank = findInWorkspaceByPatterns(BossPatterns.Shank)
    local wb = findInWorkspaceByPatterns(BossPatterns.Whitebeard)
    local saw = findInWorkspaceByPatterns(BossPatterns.TheSaw)
    return shank, wb, saw
end

-- Fruit detection
local function detectFruits()
    local fruits = {}
    local seen = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local nm = tostring(obj.Name)
            local nmLower = nm:lower()
            local tip = (""):lower()
            pcall(function() if obj.ToolTip then tip = tostring(obj.ToolTip):lower() end end)
            if nmLower:find("fruit") or tip:find("blox") or nmLower:match("^%w+%-?%w*%-?fruit") or nm:match("%w+%-?%w*%-?Fruit") then
                if not seen[nm] then table.insert(fruits, nm); seen[nm] = true end
            end
        end
    end

    -- Also check for parts/objects named with "Fruit" (rare)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nm = tostring(obj.Name):lower()
            if nm:find("fruit") and not seen[nm] then
                table.insert(fruits, obj.Name); seen[obj.Name] = true
            end
        end
    end

    return fruits
end

-- Moon detection (best-effort heuristics)
local function detectMoon()
    -- try ReplicatedStorage or workspace lookups
    local lowerFound = nil

    -- 1) check ReplicatedStorage for "Moon" or "World"
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        for _,v in pairs(rs:GetDescendants()) do
            if type(v.Name) == "string" and v.Name:lower():find("moon") then
                lowerFound = v.Name:lower()
                return
            end
        end
    end)

    -- 2) check workspace names (parts/models)
    if not lowerFound then
        for _,v in pairs(workspace:GetDescendants()) do
            if type(v.Name) == "string" and v.Name:lower():find("moon") then
                lowerFound = v.Name:lower()
                break
            end
        end
    end

    -- 3) fallback: check Lighting / sky texture
    if not lowerFound then
        pcall(function()
            local lighting = game:GetService("Lighting")
            for _,v in pairs(lighting:GetDescendants()) do
                if type(v.Name) == "string" and v.Name:lower():find("moon") then
                    lowerFound = v.Name:lower()
                    break
                end
            end
        end)
    end

    -- Decide real/fake/unknown
    if lowerFound then
        if lowerFound:find("real") then return "real" end
        if lowerFound:find("fake") then return "fake" end
        -- heuristic: presence of "moon" but no real/fake -> unknown
        return "unknown"
    end

    -- Final fallback: try checking ReplicatedStorage "ClientGlobal" patterns (best-effort)
    -- If nothing found, return nil
    return nil
end

local function moonEmojiFor(kind)
    if not kind then return "❓" end
    if kind == "real" then return "🌘🌗🌖🌕 (Real Moon)" end
    if kind == "fake" then return "🌒🌓🌖🌑 (Fake Moon)" end
    if kind == "unknown" then return "🌙 (Unknown type)" end
    return "❓"
end

-- Format time elapsed
local function formatElapsed(secs)
    local s = math.floor(secs % 60)
    local m = math.floor((secs/60) % 60)
    local h = math.floor(secs/3600)
    if h > 0 then
        return string.format("%02dh %02dm %02ds", h, m, s)
    elseif m > 0 then
        return string.format("%02dm %02ds", m, s)
    else
        return string.format("%02ds", s)
    end
end

-- ---------- Update loops ----------
-- Frequent update: players & elapsed (every 1s)
spawn(function()
    while true do
        pcall(function()
            -- players count
            local count = #Players:GetPlayers()
            statusPlayers.ValueLabel.Text = tostring(count)

            -- elapsed
            local elapsed = tick() - START_TICK
            statusTime.ValueLabel.Text = formatElapsed(elapsed)
        end)
        task.wait(1)
    end
end)

-- Periodic update: boss & fruits & moon every 120s (2 minutes)
spawn(function()
    while true do
        pcall(function()
            -- Bosses
            local s1, s2, s3 = checkBossSpawn()
            statusBossShank.ValueLabel.Text = s1 and "✅" or "❌"
            statusBossWhitebeard.ValueLabel.Text = s2 and "✅" or "❌"
            statusBossSaw.ValueLabel.Text = s3 and "✅" or "❌"

            -- Fruits
            local fruits = detectFruits()
            if fruits and #fruits > 0 then
                local short = table.concat(fruits, ", ")
                if #short > 120 then short = short:sub(1,120) .. "..." end
                statusFruits.ValueLabel.Text = short
            else
                statusFruits.ValueLabel.Text = "❌"
            end

            -- Moon
            local moonKind = detectMoon()
            statusMoon.ValueLabel.Text = moonEmojiFor(moonKind)

            -- status checking text (last-check time)
            statusCheck.ValueLabel.Text = "Checked at: "..os.date("%H:%M:%S")
        end)
        task.wait(120) -- 2 minutes
    end
end)

-- Also run an initial immediate update for better UX
pcall(function()
    local s1,s2,s3 = checkBossSpawn()
    statusBossShank.ValueLabel.Text = s1 and "✅" or "❌"
    statusBossWhitebeard.ValueLabel.Text = s2 and "✅" or "❌"
    statusBossSaw.ValueLabel.Text = s3 and "✅" or "❌"
    local fruits = detectFruits()
    statusFruits.ValueLabel.Text = (#fruits>0) and table.concat(fruits,", ") or "❌"
    statusMoon.ValueLabel.Text = moonEmojiFor(detectMoon())
    statusPlayers.ValueLabel.Text = tostring(#Players:GetPlayers())
    statusTime.ValueLabel.Text = formatElapsed(tick()-START_TICK)
    statusCheck.ValueLabel.Text = "Checked at: "..os.date("%H:%M:%S")
end)

-- Keep ContentContainer scrollable visible region adjusted (optional)
StatusTab.CanvasSize = UDim2.new(0,0,0,0)
StatusTab.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Done
print("✅ Status tab upgraded — checks: bosses, fruits, players, elapsed time, moon. Updating every 2 minutes.")
