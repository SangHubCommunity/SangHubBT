
-- SangHub_BetaBF_Final.lua
-- GUI chỉnh sửa theo yêu cầu:
-- - Tab Shop & Mics chia đôi thành 2 Frame
-- - Đường kẻ dọc phân chia 2 bên
-- - Tiêu đề bên trái: ESP, tiêu đề bên phải: FRUIT
-- - Hai toggle giữ nguyên, mỗi toggle click sẽ phát âm thanh ID 12221967

-- Tải Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Hàm tạo Instance nhanh
local function NewInstance(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- Frame chính của tab Shop & Mics
local ShopMicsFrame = NewInstance("Frame", {
    Name = "ShopMicsFrame",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1
})

-- Frame trái
local LeftFrame = NewInstance("Frame", {
    Parent = ShopMicsFrame,
    Size = UDim2.new(0.5, -1, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1
})
-- Tiêu đề ESP
local EspLabel = NewInstance("TextLabel", {
    Parent = LeftFrame,
    Text = "ESP",
    Size = UDim2.new(1, 0, 0, 30),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 16
})

-- Frame phải
local RightFrame = NewInstance("Frame", {
    Parent = ShopMicsFrame,
    Size = UDim2.new(0.5, -1, 1, 0),
    Position = UDim2.new(0.5, 1, 0, 0),
    BackgroundTransparency = 1
})
-- Tiêu đề FRUIT
local FruitLabel = NewInstance("TextLabel", {
    Parent = RightFrame,
    Text = "FRUIT",
    Size = UDim2.new(1, 0, 0, 30),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 16
})

-- Đường kẻ dọc
local Divider = NewInstance("Frame", {
    Parent = ShopMicsFrame,
    Size = UDim2.new(0, 2, 1, 0),
    Position = UDim2.new(0.5, -1, 0, 0),
    BackgroundColor3 = Color3.fromRGB(0, 140, 255),
    BorderSizePixel = 0
})

-- Tạo toggle
local function CreateToggle(parent, name)
    local toggle = NewInstance("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, 35),
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(46, 46, 46),
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    -- Âm thanh click
    local sound = NewInstance("Sound", {
        Parent = toggle,
        SoundId = "rbxassetid://12221967"
    })
    toggle.MouseButton1Click:Connect(function()
        sound:Play()
        print(name .. " toggled!")
    end)
    return toggle
end

-- Tạo toggle mẫu
CreateToggle(LeftFrame, "Player ESP")
CreateToggle(RightFrame, "Fruit ESP")
