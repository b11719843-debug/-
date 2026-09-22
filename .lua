-- СКРИПТ ХАБ ЛООЛ🤣💪 by @megoden111
-- Full Build with Floating Button + Notification

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot = false, AimTeamCheck = true, AimPart = "Head",
    AimSmooth = 0.15, AimFOV = 150, WallCheck = false, FOVCircle = false,
    ESP = false, ESPTeamCheck = true, ESPBox = true, ESPName = true,
    ESPDist = true, ESPHealth = true, ESPTracer = false, ESPChams = false,
    ESPMaxDist = 2000,
    Hitbox = false, HitboxSize = 10, HitboxTeam = true,
    Speed = false, SpeedValue = 16,
    Jump = false, JumpValue = 50,
    Fly = false, FlySpeed = 50,
    Noclip = false, InfJump = false, BHop = false,
    Gravity = false, GravityValue = 196.2,
    Fullbright = false, NoFog = false,
    ThirdPerson = false, TPDist = 10,
    AntiAFK = false, AntiRagdoll = false
}

-- ===================== УТИЛИТЫ =====================
local function GetChar(plr)
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil end
    return char, hrp, hum
end

local function IsTeammate(plr, check)
    if not check then return false end
    if plr.Team == nil or LocalPlayer.Team == nil then return false end
    return plr.Team == LocalPlayer.Team
end

local function HasLOS(part)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    return workspace:Raycast(origin, dir, rp) == nil
end

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LOLHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ===================== УВЕДОМЛЕНИЕ О ЗАПУСКЕ =====================
local Notify = Instance.new("Frame")
Notify.Size = UDim2.new(0, 220, 0, 50)
Notify.Position = UDim2.new(0, 15, 1, -70)
Notify.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Notify.BackgroundTransparency = 0.1
Notify.BorderSizePixel = 0
Notify.ZIndex = 1000
Notify.Parent = ScreenGui

local NC = Instance.new("UICorner") NC.CornerRadius = UDim.new(0, 8) NC.Parent = Notify
local NS = Instance.new("UIStroke")
NS.Color = Color3.fromRGB(150, 100, 255)
NS.Thickness = 1.5
NS.Parent = Notify

local NotifyTitle = Instance.new("TextLabel")
NotifyTitle.Size = UDim2.new(1, -10, 0, 20)
NotifyTitle.Position = UDim2.new(0, 5, 0, 4)
NotifyTitle.BackgroundTransparency = 1
NotifyTitle.Text = "СКРИПТ ЗАПУЩЕН ✅"
NotifyTitle.TextColor3 = Color3.fromRGB(200, 170, 255)
NotifyTitle.TextSize = 14
NotifyTitle.Font = Enum.Font.GothamBold
NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
NotifyTitle.Parent = Notify

local NotifySub = Instance.new("TextLabel")
NotifySub.Size = UDim2.new(1, -10, 0, 18)
NotifySub.Position = UDim2.new(0, 5, 0, 24)
NotifySub.BackgroundTransparency = 1
NotifySub.Text = "by @megoden111"
NotifySub.TextColor3 = Color3.fromRGB(180, 180, 180)
NotifySub.TextSize = 11
NotifySub.Font = Enum.Font.Gotham
NotifySub.TextXAlignment = Enum.TextXAlignment.Left
NotifySub.Parent = Notify

task.spawn(function()
    task.wait(5)
    for i = 0, 10 do
        Notify.BackgroundTransparency = 0.1 + (i * 0.09)
        NotifyTitle.TextTransparency = i * 0.1
        NotifySub.TextTransparency = i * 0.1
        NS.Transparency = i * 0.1
        task.wait(0.05)
    end
    Notify:Destroy()
end)

-- ===================== ГЛАВНОЕ МЕНЮ =====================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.ZIndex = 500
Main.Parent = ScreenGui

local MC = Instance.new("UICorner") MC.CornerRadius = UDim.new(0, 10) MC.Parent = Main
local MS = Instance.new("UIStroke") MS.Color = Color3.fromRGB(150, 100, 255) MS.Thickness = 1.5 MS.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
Title.BorderSizePixel = 0
Title.Text = "СКРИПТ ХАБ ЛООЛ🤣💪"
Title.TextColor3 = Color3.fromRGB(200, 170, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 501
Title.Parent = Main

local TC = Instance.new("UICorner") TC.CornerRadius = UDim.new(0, 10) TC.Parent = Title

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, 0, 0, 16)
Sub.Position = UDim2.new(0, 0, 0, 40)
Sub.BackgroundTransparency = 1
Sub.Text = "by @megoden111"
Sub.TextColor3 = Color3.fromRGB(150, 150, 160)
Sub.TextSize = 11
Sub.Font = Enum.Font.Gotham
Sub.ZIndex = 501
Sub.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 502
CloseBtn.Parent = Title

local CC = Instance.new("UICorner") CC.CornerRadius = UDim.new(0, 6) CC.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -60)
ScrollFrame.Position = UDim2.new(0, 0, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ZIndex = 501
ScrollFrame.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = ScrollFrame

local Pad = Instance.new("UIPadding")
Pad.PaddingTop = UDim.new(0, 8)
Pad.PaddingBottom = UDim.new(0, 8)
Pad.PaddingLeft = UDim.new(0, 10)
Pad.PaddingRight = UDim.new(0, 10)
Pad.Parent = ScrollFrame

local function CreateSection(text)
    local Sec = Instance.new("TextLabel")
    Sec.Size = UDim2.new(1, 0, 0, 22)
    Sec.BackgroundTransparency = 1
    Sec.Text = "— " .. text .. " —"
    Sec.TextColor3 = Color3.fromRGB(180, 140, 255)
    Sec.TextSize = 12
    Sec.Font = Enum.Font.GothamBold
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.ZIndex = 501
    Sec.Parent = ScrollFrame
end

local order = 0

local function CreateToggle(text, default, callback)
    order = order + 1
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = default and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(40, 40, 50)
    Btn.BorderSizePixel = 0
    Btn.Text = text .. ": " .. (default and "ON" or "OFF")
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.Gotham
    Btn.LayoutOrder = order
    Btn.ZIndex = 501
    Btn.Parent = ScrollFrame

    local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 6) C.Parent = Btn

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(40, 40, 50)
        Btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local function CreateSlider(text, minV, maxV, default, callback)
    order = order + 1
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Container.BorderSizePixel = 0
    Container.LayoutOrder = order
    Container.ZIndex = 501
    Container.Parent = ScrollFrame

    local CC2 = Instance.new("UICorner") CC2.CornerRadius = UDim.new(0, 6) CC2.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 5, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 502
    Label.Parent = Container

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 0, 26)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 502
    Bar.Parent = Container

    local BC = Instance.new("UICorner") BC.CornerRadius = UDim.new(1, 0) BC.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 503
    Fill.Parent = Bar

    local FC = Instance.new("UICorner") FC.CornerRadius = UDim.new(1, 0) FC.Parent = Fill

    local dragging = false
    local function Update(input)
        local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = minV + (maxV - minV) * rel
        val = math.floor(val * 100 + 0.5) / 100
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Label.Text = text .. ": " .. tostring(val)
        callback(val)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true Update(input)
        end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
end

local function CreateButton(text, callback)
    order = order + 1
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.LayoutOrder = order
    Btn.ZIndex = 501
    Btn.Parent = ScrollFrame

    local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 6) C.Parent = Btn
    Btn.MouseButton1Click:Connect(callback)
end

-- ===================== НАПОЛНЕНИЕ МЕНЮ =====================
CreateSection("Combat")
CreateToggle("Aimbot (ПКМ)", false, function(v) Settings.Aimbot = v end)
CreateToggle("Team Check", true, function(v) Settings.AimTeamCheck = v end)
CreateToggle("Wall Check", false, function(v) Settings.WallCheck = v end)
CreateToggle("FOV Circle", false, function(v) Settings.FOVCircle = v end)
CreateSlider("Aim FOV", 10, 500, 150, function(v) Settings.AimFOV = v end)
CreateSlider("Aim Smooth", 0, 100, 15, function(v) Settings.AimSmooth = v / 100 end)

CreateSection("Hitbox")
CreateToggle("Hitbox Expander", false, function(v) Settings.Hitbox = v end)
CreateSlider("Hitbox Size", 5, 50, 10, function(v) Settings.HitboxSize = v end)

CreateSection("Visuals")
CreateToggle("ESP", false, function(v) Settings.ESP = v end)
CreateToggle("Hide Teammates", true, function(v) Settings.ESPTeamCheck = v end)
CreateToggle("Box", true, function(v) Settings.ESPBox = v end)
CreateToggle("Name", true, function(v) Settings.ESPName = v end)
CreateToggle("Distance", true, function(v) Settings.ESPDist = v end)
CreateToggle("Health Bar", true, function(v) Settings.ESPHealth = v end)
CreateToggle("Tracer", false, function(v) Settings.ESPTracer = v end)
CreateToggle("Chams", false, function(v) Settings.ESPChams = v end)
CreateSlider("Max Distance", 100, 5000, 2000, function(v) Settings.ESPMaxDist = v end)
CreateToggle("Fullbright", false, function(v) Settings.Fullbright = v
    if v then
        Lighting.Brightness = 2 Lighting.ClockTime = 12
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = 1 Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    end
end)
CreateToggle("No Fog", false, function(v) Settings.NoFog = v
    if v then Lighting.FogEnd = 100000 Lighting.FogStart = 100000
    else Lighting.FogEnd = 100000 Lighting.FogStart = 0 end
end)
CreateToggle("Third Person", false, function(v) Settings.ThirdPerson = v end)
CreateSlider("TP Distance", 5, 50, 10, function(v) Settings.TPDist = v end)

CreateSection("Movement")
CreateToggle("Speed Hack", false, function(v) Settings.Speed = v end)
CreateSlider("Speed Value", 16, 300, 16, function(v) Settings.SpeedValue = v end)
CreateToggle("Jump Power", false, function(v) Settings.Jump = v end)
CreateSlider("Jump Value", 50, 500, 50, function(v) Settings.JumpValue = v end)
CreateToggle("Infinite Jump", false, function(v) Settings.InfJump = v end)
CreateToggle("Bunny Hop", false, function(v) Settings.BHop = v end)
CreateToggle("Fly", false, function(v) Settings.Fly = v end)
CreateSlider("Fly Speed", 10, 300, 50, function(v) Settings.FlySpeed = v end)
CreateToggle("Noclip", false, function(v) Settings.Noclip = v end)
CreateToggle("Low Gravity", false, function(v) Settings.Gravity = v end)
CreateSlider("Gravity Value", 10, 196, 196, function(v) Settings.GravityValue = v end)

CreateSection("Misc")
CreateToggle("Anti AFK", false, function(v) Settings.AntiAFK = v end)
CreateToggle("Anti Ragdoll", false, function(v) Settings.AntiRagdoll = v end)
CreateButton("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- ===================== ПЛАВАЮЩАЯ КНОПКА =====================
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Size = UDim2.new(0, 65, 0, 65)
FloatingBtn.Position = UDim2.new(0, 20, 0.5, -32)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
FloatingBtn.BackgroundTransparency = 0.1
FloatingBtn.BorderSizePixel = 0
FloatingBtn.Text = "LOL"
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.TextSize = 18
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.AutoButtonColor = false
FloatingBtn.Active = true
FloatingBtn.ZIndex = 1000
FloatingBtn.Parent = ScreenGui

local FBC = Instance.new("UICorner")
FBC.CornerRadius = UDim.new(1, 0)
FBC.Parent = FloatingBtn

local FBStroke = Instance.new("UIStroke")
FBStroke.Color = Color3.fromRGB(220, 200, 255)
FBStroke.Thickness = 2.5
FBStroke.Parent = FloatingBtn

local isDragging = false
local dragStart, startPos

FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = FloatingBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatingBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

FloatingBtn.MouseButton1Click:Connect(function()
    if not isDragging then
        Main.Visible = not Main.Visible
        FloatingBtn.Text = Main.Visible and "X" or "LOL"
        FloatingBtn.BackgroundColor3 = Main.Visible
            and Color3.fromRGB(200, 50, 50)
            or Color3.fromRGB(150, 100, 255)
    end
end)

-- ===================== БИНД K =====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        Main.Visible = not Main.Visible
        FloatingBtn.Text = Main.Visible and "X" or "LOL"
        FloatingBtn.BackgroundColor3 = Main.Visible
            and Color3.fromRGB(200, 50, 50)
            or Color3.fromRGB(150, 100, 255)
    end
end)

-- ===================== ЛОГИКА =====================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(200, 200, 200)
fovCircle.Filled = false

local function GetTarget()
    local closest, shortest = nil, Settings.AimFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not IsTeammate(plr, Settings.AimTeamCheck) then
            local char, hrp = GetChar(plr)
            if char then
                local part = char:FindFirstChild(Settings.AimPart) or hrp
                if Settings.WallCheck and not HasLOS(part) then continue end
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                    if d < shortest then shortest = d closest = part end
                end
            end
        end
    end
    return closest
end

local ESPData = {}
local function CreateESP(plr)
    local data = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        dist = Drawing.new("Text"),
        healthBg = Drawing.new("Square"),
        healthBar = Drawing.new("Square"),
        tracer = Drawing.new("Line"),
        highlight = nil
    }
    data.box.Thickness = 1 data.box.Filled = false data.box.Color = Color3.fromRGB(255,0,0) data.box.Transparency = 1
    data.name.Size = 14 data.name.Center = true data.name.Outline = true data.name.Color = Color3.fromRGB(255,255,255)
    data.dist.Size = 13 data.dist.Center = true data.dist.Outline = true data.dist.Color = Color3.fromRGB(200,200,200)
    data.healthBg.Filled = true data.healthBg.Color = Color3.fromRGB(40,40,40)
    data.healthBar.Filled = true data.healthBar.Color = Color3.fromRGB(0,255,0)
    data.tracer.Thickness = 1 data.tracer.Color = Color3.fromRGB(255,0,0)
    ESPData[plr] = data
end

local function DestroyESP(plr)
    local data = ESPData[plr]
    if not data then return end
    for _, v in pairs(data) do
        if typeof(v) == "userdata" then pcall(function() v:Remove() end)
        elseif typeof(v) == "Instance" then pcall(function() v:Destroy() end) end
    end
    ESPData[plr] = nil
end

local HitboxOrig = {}

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    fovCircle.Visible = Settings.FOVCircle
    if Settings.FOVCircle then
        fovCircle.Radius = Settings.AimFOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end

    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFr
