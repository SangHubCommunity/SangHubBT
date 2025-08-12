--== PHẦN 1: GUI & TAB ==--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

-- Colors
local BLUE = Color3.fromRGB(0, 140, 255)
local TEXT_COLOR = Color3.fromRGB(230, 230, 230)
local BG_COLOR = Color3.fromRGB(30, 30, 30)
local TAB_COLOR = Color3.fromRGB(46, 46, 46)
local TAB_HIGHLIGHT = Color3.fromRGB(0, 110, 200)

-- ScreenGui
local ScreenGui = new("ScreenGui", {
    Parent = LocalPlayer:WaitForChild("PlayerGui"),
    ResetOnSpawn = false
})

-- Toggle Button
local ToggleBtn = new("ImageButton", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 0,
    BackgroundColor3 = BG_COLOR,
    Image = "rbxassetid://92088814301938"
})
new("UICorner", {Parent = ToggleBtn, CornerRadius = UDim.new(0, 8)})
new("UIStroke", {Parent = ToggleBtn, Color = BLUE, Thickness = 2})

-- Main Frame
local MainFrame = new("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 500, 0, 350),
    Position = UDim2.new(0.5, -250, 0.5, -175),
    BackgroundColor3 = BG_COLOR,
    BorderSizePixel = 0,
    ClipsDescendants = true
})
new("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
new("UIStroke", {Parent = MainFrame, Color = BLUE, Thickness = 2})

-- Header
local Header = new("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1
})

-- Tab Scroll
local TabScroll = new("ScrollingFrame", {
    Parent = Header,
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0, 5, 0, 0),
    BackgroundTransparency = 1,
    ScrollBarThickness = 6,
    ClipsDescendants = true,
    HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
    ScrollingDirection = Enum.ScrollingDirection.X,
    CanvasSize = UDim2.new(0,0,0,0)
})
local TabList = new("UIListLayout", {
    Parent = TabScroll,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0,8),
    HorizontalAlignment = Enum.HorizontalAlignment.Center
})

-- Content container
local ContentFrame = new("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, -10, 1, -60),
    Position = UDim2.new(0, 5, 0, 55),
    BackgroundTransparency = 1
})

-- Tabs setup
local tabNames = {"Status", "Main", "Item", "Combat", "Race & Gear", "Shop & Mics"}
local tabButtons, tabPages = {}, {}
local selectedTab = 1

local function highlightTab(index)
    for i, btn in ipairs(tabButtons) do
        local targetColor = (i == index) and TAB_HIGHLIGHT or TAB_COLOR
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    end
end

local function switchTab(index)
    selectedTab = index
    for i, page in ipairs(tabPages) do
        page.Visible = (i == index)
    end
    highlightTab(index)
end

for i, name in ipairs(tabNames) do
    local btn = new("TextButton", {
        Parent = TabScroll,
        Size = UDim2.new(0, 90, 0, 42),
        BackgroundColor3 = TAB_COLOR,
        BorderSizePixel = 0,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = TEXT_COLOR,
        AutoButtonColor = false
    })
    btn.AutoLocalize = false
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})
    new("UIStroke", {Parent = btn, Color = BLUE, Thickness = 1})
    
    btn.MouseButton1Click:Connect(function()
        switchTab(i)
    end)
    
    local page = new("Frame", {
        Parent = ContentFrame,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    table.insert(tabButtons, btn)
    table.insert(tabPages, page)
end

local function updateCanvasSize()
    local total = 0
    for _, b in ipairs(tabButtons) do
        total = total + b.AbsoluteSize.X + TabList.Padding.Offset
    end
    TabScroll.CanvasSize = UDim2.new(0, total, 0, 0)
end
updateCanvasSize()
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

switchTab(1)
--== PHẦN 2: SHOP & MICS TAB LAYOUT + ESP ==--

-- Tìm index tab "Shop & Mics"
local shopIndex
for i, name in ipairs(tabNames) do
    if name == "Shop & Mics" then
        shopIndex = i
        break
    end
end

if shopIndex then
    local shopPage = tabPages[shopIndex]

    -- Chia đôi 2 bên
    local LeftFrame = new("Frame", {
        Parent = shopPage,
        Size = UDim2.new(0.5, -2, 1, 0),
        BackgroundTransparency = 1
    })
    local RightFrame = new("Frame", {
        Parent = shopPage,
        Size = UDim2.new(0.5, -2, 1, 0),
        Position = UDim2.new(0.5, 4, 0, 0),
        BackgroundTransparency = 1
    })

    -- Đường kẻ dọc
    local Divider = new("Frame", {
        Parent = shopPage,
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(0.5, -1, 0, 0),
        BackgroundColor3 = BLUE
    })

    -- Tiêu đề ESP
    local espTitle = new("TextLabel", {
        Parent = LeftFrame,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "ESP",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = BLUE
    })

    -- Toggle Player ESP
    local playerESPBtn = new("TextButton", {
        Parent = LeftFrame,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = TAB_COLOR,
        Text = "Player ESP",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = TEXT_COLOR
    })
    new("UICorner", {Parent = playerESPBtn, CornerRadius = UDim.new(0, 6)})
    new("UIStroke", {Parent = playerESPBtn, Color = BLUE, Thickness = 1})

    local playerESPEnabled = false
    playerESPBtn.MouseButton1Click:Connect(function()
        playerESPEnabled = not playerESPEnabled
        if playerESPEnabled then
            playerESPBtn.BackgroundColor3 = TAB_HIGHLIGHT
            -- Bật ESP Player
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local Billboard = Instance.new("BillboardGui", plr.Character.Head)
                    Billboard.Name = "PlayerESP"
                    Billboard.Size = UDim2.new(0, 200, 0, 50)
                    Billboard.AlwaysOnTop = true
                    Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    local NameLabel = Instance.new("TextLabel", Billboard)
                    NameLabel.Size = UDim2.new(1, 0, 1, 0)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Text = plr.Name
                    NameLabel.TextColor3 = BLUE
                    NameLabel.TextStrokeTransparency = 0
                    NameLabel.Font = Enum.Font.GothamBold
                    NameLabel.TextSize = 14
                end
            end
        else
            playerESPBtn.BackgroundColor3 = TAB_COLOR
            -- Tắt ESP Player
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("PlayerESP") then
                    plr.Character.Head.PlayerESP:Destroy()
                end
            end
        end
    end)

    -- Toggle Fruit ESP
    local fruitESPBtn = new("TextButton", {
        Parent = LeftFrame,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 0, 0, 64),
        BackgroundColor3 = TAB_COLOR,
        Text = "Fruit ESP",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = TEXT_COLOR
    })
    new("UICorner", {Parent = fruitESPBtn, CornerRadius = UDim.new(0, 6)})
    new("UIStroke", {Parent = fruitESPBtn, Color = BLUE, Thickness = 1})

    local fruitESPEnabled = false
    fruitESPBtn.MouseButton1Click:Connect(function()
        fruitESPEnabled = not fruitESPEnabled
        if fruitESPEnabled then
            fruitESPBtn.BackgroundColor3 = TAB_HIGHLIGHT
            -- Bật ESP Fruit
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                    local Billboard = Instance.new("BillboardGui", obj.Handle)
                    Billboard.Name = "FruitESP"
                    Billboard.Size = UDim2.new(0, 200, 0, 50)
                    Billboard.AlwaysOnTop = true
                    Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    local NameLabel = Instance.new("TextLabel", Billboard)
                    NameLabel.Size = UDim2.new(1, 0, 1, 0)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Text = obj.Name
                    NameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    NameLabel.TextStrokeTransparency = 0
                    NameLabel.Font = Enum.Font.GothamBold
                    NameLabel.TextSize = 14
                end
            end
        else
            fruitESPBtn.BackgroundColor3 = TAB_COLOR
            -- Tắt ESP Fruit
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Tool") and obj:FindFirstChild("Handle") and obj.Handle:FindFirstChild("FruitESP") then
                    obj.Handle.FruitESP:Destroy()
                end
            end
        end
    end)

    -- Tiêu đề Fruits bên phải
    local fruitTitle = new("TextLabel", {
        Parent = RightFrame,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "Fruits",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = BLUE
    })
end
--== PHẦN 3: HOP SERVER / REJOIN SERVER ==--

-- Sound Click
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://12221967"
clickSound.Volume = 2
clickSound.Parent = game:GetService("SoundService")

-- Hàm play sound
local function playClick()
    clickSound:Play()
end

if shopIndex then
    local shopPage = tabPages[shopIndex]
    local RightFrame = shopPage:FindFirstChildOfClass("Frame") -- Frame bên phải Fruits

    -- Tiêu đề HOP
    local hopTitle = new("TextLabel", {
        Parent = RightFrame,
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "HOP",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = BLUE
    })

    -- Nút Hop Server
    local hopServerBtn = new("TextButton", {
        Parent = RightFrame,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundColor3 = TAB_COLOR,
        Text = "Hop Server",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = TEXT_COLOR
    })
    new("UICorner", {Parent = hopServerBtn, CornerRadius = UDim.new(0, 6)})
    new("UIStroke", {Parent = hopServerBtn, Color = BLUE, Thickness = 1})

    hopServerBtn.MouseButton1Click:Connect(function()
        playClick()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local Servers = Http:JSONDecode(game:HttpGet(Api))
        for _,v in pairs(Servers.data) do
            if v.playing < v.maxPlayers then
                TPS:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
                break
            end
        end
    end)

    -- Nút Hop Server Low Player
    local hopLowBtn = new("TextButton", {
        Parent = RightFrame,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 0, 0, 92),
        BackgroundColor3 = TAB_COLOR,
        Text = "Hop Server Low Player",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = TEXT_COLOR
    })
    new("UICorner", {Parent = hopLowBtn, CornerRadius = UDim.new(0, 6)})
    new("UIStroke", {Parent = hopLowBtn, Color = BLUE, Thickness = 1})

    hopLowBtn.MouseButton1Click:Connect(function()
        playClick()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local Servers = Http:JSONDecode(game:HttpGet(Api))
        for _,v in pairs(Servers.data) do
            if v.playing <= 5 then
                TPS:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
                break
            end
        end
    end)

    -- Nút Rejoin Server
    local rejoinBtn = new("TextButton", {
        Parent = RightFrame,
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 0, 0, 128),
        BackgroundColor3 = TAB_COLOR,
        Text = "Rejoin Server",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = TEXT_COLOR
    })
    new("UICorner", {Parent = rejoinBtn, CornerRadius = UDim.new(0, 6)})
    new("UIStroke", {Parent = rejoinBtn, Color = BLUE, Thickness = 1})

    rejoinBtn.MouseButton1Click:Connect(function()
        playClick()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end
