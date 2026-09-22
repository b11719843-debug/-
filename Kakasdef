-- СКРИПТ ХАБ ЛООЛ🤣💪 by @megoden111
-- Custom GUI | No Libraries

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ===================== НАСТРОЙКИ =====================
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

-- ===================== ЛОГИКА =====================

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(200, 200, 200)
fovCircle.Filled = false

-- Aim Target
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

-- ESP Cache
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

-- ===================== MAIN LOOP =====================
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- FOV Circle
    fovCircle.Visible = Settings.FOVCircle
    if Settings.FOVCircle then
        fovCircle.Radius = Settings.AimFOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end

    -- Aimbot
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Settings.AimSmooth)
        end
    end

    -- Hitbox
    if Settings.Hitbox then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char, hrp = GetChar(plr)
                if char and not IsTeammate(plr, Settings.HitboxTeam) then
                    if not HitboxOrig[plr] then
                        HitboxOrig[plr] = {Size = hrp.Size, Trans = hrp.Transparency, Collide = hrp.CanCollide}
                    end
                    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hrp.Transparency = 0.5
                    hrp.CanCollide = false
                end
            end
        end
    else
        for plr, orig in pairs(HitboxOrig) do
            local char, hrp = GetChar(plr)
            if char and hrp then
                hrp.Size = orig.Size hrp.Transparency = orig.Trans hrp.CanCollide = orig.Collide
            end
            HitboxOrig[plr] = nil
        end
    end

    -- ESP
    if Settings.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            local char, hrp, hum = GetChar(plr)
            local valid = plr ~= LocalPlayer and char and myHRP and not IsTeammate(plr, Settings.ESPTeamCheck)
            if valid then
                local d = (myHRP.Position - hrp.Position).Magnitude
                if d <= Settings.ESPMaxDist then
                    local data = ESPData[plr] or CreateESP(plr)
                    if data then
                        local top = hrp.Position + Vector3.new(0,3,0)
                        local bot = hrp.Position - Vector3.new(0,3,0)
                        local tS, tOn = Camera:WorldToViewportPoint(top)
                        local bS, bOn = Camera:WorldToViewportPoint(bot)
                        if tOn and bOn then
                            local h = math.abs(tS.Y - bS.Y)
                            local w = h/2
                            local x = tS.X - w/2
                            local y = tS.Y

                            data.box.Visible = Settings.ESPBox
                            if Settings.ESPBox then
                                data.box.Position = Vector2.new(x, y)
                                data.box.Size = Vector2.new(w, h)
                            end

                            data.name.Visible = Settings.ESPName
                            if Settings.ESPName then
                                data.name.Position = Vector2.new(tS.X, y - 18)
                                data.name.Text = plr.Name
                            end

                            data.dist.Visible = Settings.ESPDist
                            if Settings.ESPDist then
                                data.dist.Position = Vector2.new(tS.X, y + h + 4)
                                data.dist.Text = string.format("[%d]", math.floor(d))
                            end

                            data.healthBg.Visible = Settings.ESPHealth
                            data.healthBar.Visible = Settings.ESPHealth
                            if Settings.ESPHealth then
                                local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                                local bx = x - 8
                                data.healthBg.Position = Vector2.new(bx, y) data.healthBg.Size = Vector2.new(4, h)
                                data.healthBar.Position = Vector2.new(bx, y + h*(1-hp)) data.healthBar.Size = Vector2.new(4, h*hp)
                                data.healthBar.Color = Color3.fromRGB(math.floor(255*(1-hp)), math.floor(255*hp), 0)
                            end

                            data.tracer.Visible = Settings.ESPTracer
                            if Settings.ESPTracer then
                                data.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                                data.tracer.To = Vector2.new(tS.X, y + h)
                            end

                            if Settings.ESPChams then
                                if not data.highlight then
                                    local hl = Instance.new("Highlight")
                                    hl.FillColor = Color3.fromRGB(255,0,0) hl.OutlineColor = Color3.fromRGB(255,255,255)
                                    hl.FillTransparency = 0.5 hl.OutlineTransparency = 0 hl.Adornee = char hl.Parent = char
                                    data.highlight = hl
                                end
                            else if data.highlight then data.highlight:Destroy() data.highlight = nil end end
                        else
                            data.box.Visible = false data.name.Visible = false data.dist.Visible = false
                            data.healthBg.Visible = false data.healthBar.Visible = false data.tracer.Visible = false
                        end
                    end
                else DestroyESP(plr) end
            else DestroyESP(plr) end
        end
    else
        if next(ESPData) ~= nil then for plr, _ in pairs(ESPData) do DestroyESP(plr) end end
    end

    -- Speed / Jump / Gravity
    if myChar then
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings.Speed then hum.WalkSpeed = Settings.SpeedValue end
            if Settings.Jump then hum.UseJumpPower = true hum.JumpPower = Settings.JumpValue end
            workspace.Gravity = Settings.Gravity and Settings.GravityValue or 196.2
        end
    end

    -- Noclip
    if Settings.Noclip and myChar then
        for _, part in pairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end

    -- Third Person
    LocalPlayer.CameraMaxZoomDistance = Settings.ThirdPerson and Settings.TPDist or 12.5
end)

-- Inf Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- BHop
RunService.Heartbeat:Connect(function()
    if Settings.BHop and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly
local flyConn, bodyVel, bodyGyro
local function StopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVel then bodyVel:Destroy() bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

RunService.RenderStepped:Connect(function()
    if Settings.Fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and not bodyVel then
            bodyVel = Instance.new("BodyVelocity") bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9) bodyVel.Parent = hrp
            bodyGyro = Instance.new("BodyGyro") bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9) bodyGyro.P = 9e4 bodyGyro.Parent = hrp
            flyConn = RunService.Heartbeat:Connect(function()
                if not Settings.Fly then StopFly() return end
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                bodyVel.Velocity = move * Settings.FlySpeed
                bodyGyro.CFrame = Camera.CFrame
            end)
        end
    elseif not Settings.Fly then StopFly() end
end)

-- Anti Ragdoll
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, new)
        if Settings.AntiRagdoll and new == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

-- Cleanup
Players.PlayerRemoving:Connect(function(plr) DestroyESP(plr) HitboxOrig[plr] = nil end)

-- ===================== МЕНЮ =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LOLHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главный фрейм
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 10)
MC.Parent = Main

local MS = Instance.new("UIStroke")
MS.Color = Color3.fromRGB(150, 100, 255)
MS.Thickness = 1.5
MS.Parent = Main

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
Title.BorderSizePixel = 0
Title.Text = "СКРИПТ ХАБ ЛООЛ🤣💪"
Title.TextColor3 = Color3.fromRGB(200, 170, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 10)
TC.Parent = Title

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, 0, 0, 16)
Sub.Position = UDim2.new(0, 0, 0, 40)
Sub.BackgroundTransparency = 1
Sub.Text = "by @megoden111"
Sub.TextColor3 = Color3.fromRGB(150, 150, 160)
Sub.TextSize = 11
Sub.Font = Enum.Font.Gotham
Sub.Parent = Main

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 6)
CC.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Скроллинг для содержимого
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -60)
ScrollFrame.Position = UDim2.new(0, 0, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

-- Функции создания элементов
local function CreateSection(text)
    local Sec = Instance.new("TextLabel")
    Sec.Size = UDim2.new(1, 0, 0, 22)
    Sec.BackgroundTransparency = 1
    Sec.Text = "— " .. text .. " —"
    Sec.TextColor3 = Color3.fromRGB(180, 140, 255)
    Sec.TextSize = 12
    Sec.Font = Enum.Font.GothamBold
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.LayoutOrder = 1
    Sec.Parent = ScrollFrame
end

local toggleOrder = 0

local function CreateToggle(text, default, callback)
    toggleOrder = toggleOrder + 1
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = default and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(40, 40, 50)
    Btn.BorderSizePixel = 0
    Btn.Text = text .. ": " .. (default and "ON" or "OFF")
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.Gotham
    Btn.LayoutOrder = toggleOrder + 100
    Btn.Parent = ScrollFrame

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Btn

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(40, 40, 50)
        Btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local function CreateSlider(text, minV, maxV, default, callback)
    toggleOrder = toggleOrder + 1
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Container.BorderSizePixel = 0
    Container.LayoutOrder = toggleOrder + 100
    Container.Parent = ScrollFrame

    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 6)
    CC.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 5, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 0, 26)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Bar.BorderSizePixel = 0
    Bar.Parent = Container

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(1, 0)
    FC.Parent = Fill

    local dragging = false
    local function Update(input)
        local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = minV + (maxV - minV) * rel
        val = math.floor(val * 100 + 0.5) / 100
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Label.Text = t
