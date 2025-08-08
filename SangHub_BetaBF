local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "BloxFruit_TabGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Toggle Button (Top Left)
local ToggleBtn = Instance.new("ImageButton", Gui)
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.Image = "rbxassetid://76955883171909"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- Main Frame
local MainFrame = Instance.new("Frame", Gui)
MainFrame.Size = UDim2.new(0, 580, 0, 360)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Tabs Bar
local TabScroll = Instance.new("ScrollingFrame", MainFrame)
TabScroll.Size = UDim2.new(1, -40, 0, 40)
TabScroll.Position = UDim2.new(0, 40, 0, 5)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 2
TabScroll.CanvasSize = UDim2.new(0, 800, 0, 0)
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)

local Tabs = {
    "Tab Status", "Tab General", "Quest & Item",
    "Race & Gear", "Tab Shop", "Tab Setting", "Mic"
}
local TabFrames = {}

for _, tabName in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton", TabScroll)
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.Text = tabName
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    local Content = Instance.new("Frame", MainFrame)
    Content.Size = UDim2.new(1, -20, 1, -50)
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Content.Visible = false
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)

    local Scroll = Instance.new("ScrollingFrame", Content)
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    Scroll.ScrollBarThickness = 4
    Scroll.BackgroundTransparency = 1

    TabFrames[tabName] = Scroll

    TabBtn.MouseButton1Click:Connect(function()
        for _, f in pairs(TabFrames) do f.Parent.Parent.Visible = false end
        Content.Visible = true
    end)
end
TabFrames["Tab Status"].Parent.Parent.Visible = true

-- Toggle Show GUI
local toggle = false
ToggleBtn.MouseButton1Click:Connect(function()
    toggle = not toggle
    MainFrame.Visible = toggle
end)

-- ======= Tab Status Functions ========
local function StatusLine(parent, name)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Text = name .. ": Checking..."
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    return label
end

local StatusFrame = TabFrames["Tab Status"]
local shanksLbl = StatusLine(StatusFrame, "Shanks")
local wbLbl = StatusLine(StatusFrame, "Whitebeard")
local sawLbl = StatusLine(StatusFrame, "The Saw")
local moonLbl = StatusLine(StatusFrame, "Moon Phase")
local timeLbl = StatusLine(StatusFrame, "Play Time")
local fruitLbl = StatusLine(StatusFrame, "Fruit Drop")

local seconds = 0
game:GetService("RunService").RenderStepped:Connect(function(dt)
    if MainFrame.Visible then
        seconds += dt
        local m = math.floor(seconds / 60)
        local s = math.floor(seconds % 60)
        timeLbl.Text = "Play Time: " .. string.format("%02d:%02d", m, s)
    end
end)

while true do
    task.wait(120)
    local bosses = workspace.Enemies:GetChildren()
    shanksLbl.Text = "Shanks: ❌"
    wbLbl.Text = "Whitebeard: ❌"
    sawLbl.Text = "The Saw: ❌"
    for _, b in ipairs(bosses) do
        local n = b.Name:lower()
        if string.find(n, "shank") then shanksLbl.Text = "Shanks: ✅" end
        if string.find(n, "white") then wbLbl.Text = "Whitebeard: ✅" end
        if string.find(n, "saw") then sawLbl.Text = "The Saw: ✅" end
    end

    local moon = game.Lighting:GetMoonPhase()
    local emoji = {
        ["New"] = "🌑", ["WaxingCrescent"] = "🌒",
        ["FirstQuarter"] = "🌓", ["WaxingGibbous"] = "🌔",
        ["Full"] = "🌕", ["WaningGibbous"] = "🌖",
        ["LastQuarter"] = "🌗", ["WaningCrescent"] = "🌘"
    }
    moonLbl.Text = "Moon Phase: " .. (emoji[moon] or "❌")

    local fruit = workspace:FindFirstChild("Fruit")
    fruitLbl.Text = "Fruit Drop: " .. (fruit and fruit.Name or "❌")
end
-- === Tab General UI ===
local GeneralTab = TabFrames["Tab General"]

-- Left Panel
local LeftScroll = Instance.new("ScrollingFrame", GeneralTab)
LeftScroll.Size = UDim2.new(0.5, -10, 1, 0)
LeftScroll.Position = UDim2.new(0, 0, 0, 0)
LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 200)
LeftScroll.ScrollBarThickness = 4
LeftScroll.BackgroundTransparency = 1
local LeftLayout = Instance.new("UIListLayout", LeftScroll)
LeftLayout.Padding = UDim.new(0, 8)

-- Right Panel
local RightScroll = Instance.new("ScrollingFrame", GeneralTab)
RightScroll.Size = UDim2.new(0.5, -10, 1, 0)
RightScroll.Position = UDim2.new(0.5, 10, 0, 0)
RightScroll.CanvasSize = UDim2.new(0, 0, 0, 200)
RightScroll.ScrollBarThickness = 4
RightScroll.BackgroundTransparency = 1
local RightLayout = Instance.new("UIListLayout", RightScroll)
RightLayout.Padding = UDim.new(0, 8)

-- Toggle Function
local function createToggleButton(parent, title, callback)
	local Frame = Instance.new("Frame", parent)
	Frame.Size = UDim2.new(1, -10, 0, 40)
	Frame.BackgroundTransparency = 1

	local TextLabel = Instance.new("TextLabel", Frame)
	TextLabel.Size = UDim2.new(0.8, 0, 1, 0)
	TextLabel.Text = title
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Status = Instance.new("ImageLabel", Frame)
	Status.Size = UDim2.new(0, 24, 0, 24)
	Status.Position = UDim2.new(0.9, 0, 0.5, -12)
	Status.BackgroundTransparency = 1
	Status.Image = "rbxassetid://6031094664" -- Empty

	local Toggle = false
	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Toggle = not Toggle
			Status.Image = Toggle and "rbxassetid://6031094690" or "rbxassetid://6031094664"
			if callback then callback(Toggle) end
		end
	end)
end

-- Auto Farm Level Toggle (Left Panel)
createToggleButton(LeftScroll, "Auto Farm Level", function(state)
	getgenv().AutoFarmEnabled = state
end)

-- Right Panel Title
local Title = Instance.new("TextLabel", RightScroll)
Title.Size = UDim2.new(1, -10, 0, 30)
Title.Text = "Setting Farming"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Center

-- Weapon Selector (Right Panel)
local SelectedWeapon = "Nothing"

local DropDownBtn = Instance.new("TextButton", RightScroll)
DropDownBtn.Size = UDim2.new(1, -10, 0, 40)
DropDownBtn.Text = "Select Weapon: " .. SelectedWeapon
DropDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropDownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DropDownBtn.Font = Enum.Font.GothamBold
DropDownBtn.TextSize = 13
Instance.new("UICorner", DropDownBtn).CornerRadius = UDim.new(0, 8)

local WeaponOptions = Instance.new("Frame", DropDownBtn)
WeaponOptions.Size = UDim2.new(1, 0, 0, 100)
WeaponOptions.Position = UDim2.new(0, 0, 1, 0)
WeaponOptions.Visible = false
WeaponOptions.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", WeaponOptions).CornerRadius = UDim.new(0, 8)

local ScrollList = Instance.new("ScrollingFrame", WeaponOptions)
ScrollList.Size = UDim2.new(1, 0, 1, 0)
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 100)
ScrollList.ScrollBarThickness = 3
ScrollList.BackgroundTransparency = 1

local ListLayout = Instance.new("UIListLayout", ScrollList)
ListLayout.Padding = UDim.new(0, 3)

-- Weapon Choices (only 2)
local choices = { "Melee", "Sword" }
for _, weapon in ipairs(choices) do
	local btn = Instance.new("TextButton", ScrollList)
	btn.Size = UDim2.new(1, -10, 0, 28)
	btn.Text = weapon
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		SelectedWeapon = weapon
		DropDownBtn.Text = "Select Weapon: " .. SelectedWeapon
		WeaponOptions.Visible = false

		-- Auto Equip (chỉ ví dụ, cần sửa logic tùy loại vũ khí)
		local function autoEquip()
			local Backpack = game.Players.LocalPlayer.Backpack
			for _, item in ipairs(Backpack:GetChildren()) do
				if SelectedWeapon == "Melee" and item:IsA("Tool") and item.ToolTip == "Melee" then
					game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EquipWeapon", item.Name)
					break
				elseif SelectedWeapon == "Sword" and item:IsA("Tool") and item.ToolTip == "Sword" then
					game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EquipWeapon", item.Name)
					break
				end
			end
		end

		pcall(autoEquip)
	end)
end

DropDownBtn.MouseButton1Click:Connect(function()
	WeaponOptions.Visible = not WeaponOptions.Visible
end)
