-- Script by @megoden111z
-- MILITARY FPV DRONE V10.3 (NO CRASHES, PERFECT COLLISION)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local isFlying = false
local isRebooting = false
local MenuOpen = false
local BoostActive = false
local NightVisionMode = 0 
local InvincibleTime = 0 

local Settings = {
    Tilt = 0, FOV = 105, MaxSpeed = 150, RotSpeed = 2.8, FlingPower = 300, DroneSound = true, MobileControls = true 
}

local DEADZONE = 0.15
local dronePart, droneHum, propellers = nil, nil, {}
local currentVelocity = Vector3.new(0,0,0)
local currentCFrame = CFrame.new()
local homePosition = Vector3.new(0,0,0)

local L_X, L_Y, R_X, R_Y = 0, 0, 0, 0
local touchInputs = { L_X = 0, L_Y = 0, R_X = 0, R_Y = 0 }
local Battery = 16.8
local FlightTime = 0

local MainGui, menuFrame, settingsFrame = nil, nil, nil
local hudElements, colorCorrection = {}, nil
local targetLockBox, lockSound = nil, nil
local mobileGui = nil

-- ===================== ЭФФЕКТЫ =====================
local function SpawnExplosion(pos)
    pcall(function()
        local exp = Instance.new("Explosion")
        exp.Position = pos 
        exp.BlastRadius = 20 
        exp.BlastPressure = 0 
        exp.DestroyJointRadiusPercent = 0 
        exp.Parent = workspace
        
        local smoke = Instance.new("Smoke") 
        smoke.Size = 5 
        smoke.Opacity = 0.8 
        smoke.RiseVelocity = 5 
        smoke.Parent = workspace 
        smoke.Position = pos
        
        task.delay(3, function() if smoke then smoke:Destroy() end end)
        
        local boom = Instance.new("Sound") 
        boom.SoundId = "rbxassetid://165970126" 
        boom.Volume = 10 
        boom.Parent = SoundService 
        boom:Play()
        
        task.delay(3, function() 
            if boom then boom:Destroy() end 
            if exp then exp:Destroy() end 
        end)
    end)
end

local function ShowCamStatus(text, color, duration)
    pcall(function()
        local gui = Instance.new("ScreenGui") 
        gui.Name = "CamStatus" 
        gui.ResetOnSpawn = false 
        gui.IgnoreGuiInset = true 
        gui.DisplayOrder = 9999 
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        
        local bg = Instance.new("Frame") 
        bg.Size = UDim2.new(1, 0, 1, 0) 
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
        bg.BorderSizePixel = 0 
        bg.ZIndex = 100 
        bg.Parent = gui
        
        local txt = Instance.new("TextLabel") 
        txt.Size = UDim2.new(1, 0, 0, 100) 
        txt.Position = UDim2.new(0, 0, 0.5, -50) 
        txt.BackgroundTransparency = 1 
        txt.Text = text 
        txt.TextColor3 = color 
        txt.Font = Enum.Font.GothamBlack 
        txt.TextSize = 60 
        txt.ZIndex = 101 
        txt.Parent = gui
        
        task.delay(duration, function() 
            if gui then gui:Destroy() end 
        end)
    end)
end

-- ===================== ВЫХОД ИЗ ДРОНА / КАМИКАДЗЕ =====================
local function ExitDrone()
    if not isFlying then return end
    isFlying = false 
    
    pcall(function()
        if dronePart then 
            SpawnExplosion(dronePart.Position) 
            dronePart:Destroy() 
            dronePart = nil 
        end
        if droneHum then droneHum:Stop() droneHum:Destroy() droneHum = nil end
        for _, p in pairs(propellers) do if p then p:Destroy() end end 
        propellers = {}
    end)
    
    pcall(function()
        for _, v in pairs(hudElements) do if v and v.Parent then v:Destroy() end end
        hudElements = {}
    end)
    
    if mobileGui then mobileGui.Enabled = false end
    if colorCorrection then colorCorrection:Destroy() colorCorrection = nil end
    if lockSound then lockSound:Destroy() lockSound = nil end

    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end)

    ShowCamStatus("CAMERA INACTIVE", Color3.fromRGB(255, 0, 0), 2.5)
    task.spawn(function()
        task.wait(2)
        ShowCamStatus("CAMERA ACTIVE", Color3.fromRGB(0, 255, 0), 1)
    end)
end

local function FlingTarget(targetChar)
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    if not root or not dronePart then return end
    SpawnExplosion(root.Position)
    
    pcall(function()
        local bv = Instance.new("BodyVelocity") 
        bv.Velocity = (root.Position - dronePart.Position).Unit * Settings.FlingPower + Vector3.new(0, Settings.FlingPower * 1.5, 0) 
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
        bv.Parent = root
        local bav = Instance.new("BodyAngularVelocity") 
        bav.AngularVelocity = Vector3.new(math.random(-150, 150), math.random(-150, 150), math.random(-150, 150)) 
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
        bav.Parent = root
        task.delay(0.2, function() 
            if bv then bv:Destroy() end 
            if bav then bav:Destroy() end 
        end)
    end)
    
    task.spawn(ExitDrone)
end

-- ===================== СПАВН =====================
local function SpawnDrone()
    if isFlying or isRebooting or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    isFlying = true
    dronePart = Instance.new("Part") 
    dronePart.Size = Vector3.new(1, 1, 1) 
    dronePart.Transparency = 1 
    dronePart.CanCollide = false 
    dronePart.Anchored = true 
    local spawnCF = root.CFrame * CFrame.new(0, 3, -6)
    dronePart.CFrame = spawnCF 
    dronePart.Parent = workspace
    
    currentCFrame = spawnCF 
    homePosition = root.Position 
    currentVelocity = Vector3.new(0, 0, 0)
    Battery = 16.8 
    FlightTime = 0 
    InvincibleTime = 4 
    
    if Settings.DroneSound then
        droneHum = Instance.new("Sound") 
        droneHum.SoundId = "rbxassetid://9120386261" 
        droneHum.Looped = true 
        droneHum.Volume = 1 
        droneHum.Parent = dronePart 
        droneHum:Play()
    end
    
    CreateHUD()
    CreatePropellers()
    
    if mobileGui and Settings.MobileControls then mobileGui.Enabled = true end
    ShowCamStatus("CAMERA ACTIVE", Color3.fromRGB(0, 255, 0), 1.5)
end

-- ===================== HUD =====================
function CreateHUD()
    for _, v in pairs(hudElements) do if v and v.Parent then v:Destroy() end end
    hudElements = {}
    local GREEN = Color3.fromRGB(170, 255, 170) 
    local FONT = Enum.Font.Code

    local function CreateText(pos, size, text, align)
        local t = Instance.new("TextLabel") 
        t.Size = size 
        t.Position = pos 
        t.BackgroundTransparency = 1 
        t.Text = text or "" 
        t.TextColor3 = GREEN 
        t.Font = FONT 
        t.TextSize = 16 
        t.TextXAlignment = align or Enum.TextXAlignment.Left 
        t.TextStrokeTransparency = 0 
        t.TextStrokeColor3 = Color3.new(0,0,0) 
        t.Parent = MainGui 
        table.insert(hudElements, t) 
        return t
    end

    hudElements.batt = CreateText(UDim2.new(0, 20, 0, 20), UDim2.new(0, 100, 0, 20), "BAT 16.8V")
    hudElements.time = CreateText(UDim2.new(0, 20, 0, 40), UDim2.new(0, 100, 0, 20), "T 00:00")
    hudElements.alt = CreateText(UDim2.new(1, -120, 0, 20), UDim2.new(0, 100, 0, 20), "ALT 0m", Enum.TextXAlignment.Right)
    hudElements.gps = CreateText(UDim2.new(1, -120, 0, 40), UDim2.new(0, 100, 0, 20), "SAT 12", Enum.TextXAlignment.Right)

    local crosshair = Instance.new("Frame") 
    crosshair.Size = UDim2.new(0, 40, 0, 40) 
    crosshair.Position = UDim2.new(0.5, -20, 0.5, -20) 
    crosshair.BackgroundTransparency = 1 
    crosshair.Parent = MainGui 
    table.insert(hudElements, crosshair)
    
    local chCenter = Instance.new("Frame") 
    chCenter.Size = UDim2.new(0, 2, 0, 2) 
    chCenter.Position = UDim2.new(0.5, -1, 0.5, -1) 
    chCenter.BackgroundColor3 = GREEN 
    chCenter.Parent = crosshair
    
    local function createArm(size, pos) 
        local a = Instance.new("Frame") 
        a.Size = size 
        a.Position = pos 
        a.BackgroundColor3 = GREEN 
        a.Parent = crosshair 
    end
    createArm(UDim2.new(0, 10, 0, 1), UDim2.new(0, 0, 0.5, 0)) 
    createArm(UDim2.new(0, 10, 0, 1), UDim2.new(1, -10, 0.5, 0)) 
    createArm(UDim2.new(0, 1, 0, 10), UDim2.new(0.5, 0, 0, 0)) 
    createArm(UDim2.new(0, 1, 0, 10), UDim2.new(0.5, 0, 1, -10))

    hudElements.horizon = Instance.new("Frame") 
    hudElements.horizon.Size = UDim2.new(0, 200, 0, 100) 
    hudElements.horizon.Position = UDim2.new(0.5, -100, 0.5, -50) 
    hudElements.horizon.BackgroundTransparency = 1 
    hudElements.horizon.Parent = MainGui 
    table.insert(hudElements, hudElements.horizon)
    
    local hLine = Instance.new("Frame") 
    hLine.Size = UDim2.new(1, 0, 0, 1) 
    hLine.Position = UDim2.new(0, 0, 0.5, 0) 
    hLine.BackgroundColor3 = GREEN 
    hLine.BackgroundTransparency = 0.5 
    hLine.Parent = hudElements.horizon

    hudElements.compass = Instance.new("Frame") 
    hudElements.compass.Size = UDim2.new(0, 300, 0, 30) 
    hudElements.compass.Position = UDim2.new(0.5, -150, 1, -50) 
    hudElements.compass.BackgroundTransparency = 1 
    hudElements.compass.ClipsDescendants = true 
    hudElements.compass.Parent = MainGui 
    table.insert(hudElements, hudElements.compass)
    
    hudElements.compassTxt = CreateText(UDim2.new(0.5, -400, 0, 0), UDim2.new(0, 800, 0, 30), "W - - N - - E - - S - - W", Enum.TextXAlignment.Center) 
    hudElements.compassTxt.Parent = hudElements.compass

    hudElements.spd = CreateText(UDim2.new(0, 20, 1, -40), UDim2.new(0, 100, 0, 30), "SPD 0 km/h")
    
    targetLockBox = Instance.new("Frame") 
    targetLockBox.Size = UDim2.new(0, 50, 0, 50) 
    targetLockBox.BackgroundTransparency = 1 
    targetLockBox.BorderSizePixel = 0 
    targetLockBox.Visible = false 
    targetLockBox.Parent = MainGui 
    table.insert(hudElements, targetLockBox)
    
    local tlStroke = Instance.new("UIStroke") 
    tlStroke.Color = Color3.fromRGB(255, 0, 0) 
    tlStroke.Thickness = 2 
    tlStroke.Parent = targetLockBox

    hudElements.imgLeft = Instance.new("ImageLabel") 
    hudElements.imgLeft.Size = UDim2.new(0, 100, 0, 100) 
    hudElements.imgLeft.Position = UDim2.new(0, 20, 0.5, -50) 
    hudElements.imgLeft.BackgroundTransparency = 1 
    hudElements.imgLeft.Image = "rbxassetid://16212514372" 
    hudElements.imgLeft.Parent = MainGui 
    table.insert(hudElements, hudElements.imgLeft)
    
    hudElements.imgRight = Instance.new("ImageLabel") 
    hudElements.imgRight.Size = UDim2.new(0, 100, 0, 100) 
    hudElements.imgRight.Position = UDim2.new(1, -120, 0.5, -50) 
    hudElements.imgRight.BackgroundTransparency = 1 
    hudElements.imgRight.Image = "rbxassetid://13884220412" 
    hudElements.imgRight.Parent = MainGui 
    table.insert(hudElements, hudElements.imgRight)

    local nose = Instance.new("Frame") 
    nose.Size = UDim2.new(0, 200, 0, 120) 
    nose.Position = UDim2.new(0.5, -100, 1, -90) 
    nose.BackgroundColor3 = Color3.fromRGB(240, 240, 240) 
    nose.BorderSizePixel = 0 
    nose.ZIndex = 5 
    nose.Parent = MainGui 
    table.insert(hudElements, nose)
    
    local noseCorner = Instance.new("UICorner") 
    noseCorner.CornerRadius = UDim.new(0.5, 0) 
    noseCorner.Parent = nose
    
    local noseStroke = Instance.new("UIStroke") 
    noseStroke.Color = Color3.fromRGB(50, 50, 50) 
    noseStroke.Thickness = 3 
    noseStroke.Parent = nose
    
    local function addBand(y, h) 
        local b = Instance.new("Frame") 
        b.Size = UDim2.new(1, 0, 0, h) 
        b.Position = UDim2.new(0, 0, 0, y) 
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
        b.BorderSizePixel = 0 
        b.ZIndex = 6 
        b.Parent = nose 
    end
    addBand(20, 15) 
    addBand(50, 25) 
    addBand(80, 20)

    colorCorrection = Instance.new("ColorCorrectionEffect") 
    colorCorrection.Parent = Lighting
    
    lockSound = Instance.new("Sound") 
    lockSound.SoundId = "rbxassetid://131961136" 
    lockSound.Volume = 0 
    lockSound.Looped = true 
    lockSound.Parent = MainGui 
    lockSound:Play()
end

function CreatePropellers()
    propellers = {}
    for i = 1, 4 do
        local p = Instance.new("Part") 
        p.Name = "Propeller_" .. i 
        p.Size = Vector3.new(0.1, 2, 0.1) 
        p.Transparency = 0.5 
        p.CanCollide = false 
        p.Anchored = true 
        p.Material = Enum.Material.Neon 
        p.Color = Color3.fromRGB(50, 50, 50) 
        p.Parent = workspace
        table.insert(propellers, p)
    end
end

-- ===================== МОБИЛЬНЫЕ КРЕСТОВИНЫ =====================
local function CreateMobileControls()
    if mobileGui then mobileGui:Destroy() end
    mobileGui = Instance.new("ScreenGui") 
    mobileGui.Name = "MobileUI" 
    mobileGui.ResetOnSpawn = false 
    mobileGui.DisplayOrder = 998 
    mobileGui.Parent = MainGui 
    mobileGui.Enabled = false 

    local function setupDpad(isLeft)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 160, 0, 160)
        container.Position = isLeft and UDim2.new(0, 20, 1, -180) or UDim2.new(1, -180, 1, -180)
        container.BackgroundTransparency = 1
        container.Parent = mobileGui

        local btnUp = Instance.new("TextButton") 
        btnUp.Size = UDim2.new(0, 50, 0, 50) 
        btnUp.Position = UDim2.new(0.5, -25, 0, 0) 
        btnUp.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
        btnUp.BackgroundTransparency = 0.5 
        btnUp.Text = "^" 
        btnUp.TextColor3 = Color3.fromRGB(0, 255, 100) 
        btnUp.TextSize = 30 
        btnUp.Font = Enum.Font.GothamBold 
        btnUp.Parent = container
        local cU = Instance.new("UICorner") cU.CornerRadius = UDim.new(0, 8) cU.Parent = btnUp

        local btnDown = Instance.new("TextButton") 
        btnDown.Size = UDim2.new(0, 50, 0, 50) 
        btnDown.Position = UDim2.new(0.5, -25, 1, -50) 
        btnDown.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
        btnDown.BackgroundTransparency = 0.5 
        btnDown.Text = "v" 
        btnDown.TextColor3 = Color3.fromRGB(0, 255, 100) 
        btnDown.TextSize = 30 
        btnDown.Font = Enum.Font.GothamBold 
        btnDown.Parent = container
        local cD = Instance.new("UICorner") cD.CornerRadius = UDim.new(0, 8) cD.Parent = btnDown

        local btnLeft = Instance.new("TextButton") 
        btnLeft.Size = UDim2.new(0, 50, 0, 50) 
        btnLeft.Position = UDim2.new(0, 0, 0.5, -25) 
        btnLeft.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
        btnLeft.BackgroundTransparency = 0.5 
        btnLeft.Text = "<" 
        btnLeft.TextColor3 = Color3.fromRGB(0, 255, 100) 
        btnLeft.TextSize = 30 
        btnLeft.Font = Enum.Font.GothamBold 
        btnLeft.Parent = container
        local cL = Instance.new("UICorner") cL.CornerRadius = UDim.new(0, 8) cL.Parent = btnLeft

        local btnRight = Instance.new("TextButton") 
        btnRight.Size = UDim2.new(0, 50, 0, 50) 
        btnRight.Position = UDim2.new(1, -50, 0.5, -25) 
        btnRight.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
        btnRight.BackgroundTransparency = 0.5 
        btnRight.Text = ">" 
        btnRight.TextColor3 = Color3.fromRGB(0, 255, 100) 
        btnRight.TextSize = 30 
        btnRight.Font = Enum.Font.GothamBold 
        btnRight.Parent = container
        local cR = Instance.new("UICorner") cR.CornerRadius = UDim.new(0, 8) cR.Parent = btnRight

        local center = Instance.new("Frame") 
        center.Size = UDim2.new(0, 40, 0, 40) 
        center.Position = UDim2.new(0.5, -20, 0.5, -20) 
        center.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
        center.BackgroundTransparency = 0.8 
        center.Parent = container
        local cC = Instance.new("UICorner") cC.CornerRadius = UDim.new(1, 0) cC.Parent = center

        btnUp.MouseButton1Down:Connect(function() if isLeft then touchInputs.L_Y = 1 else touchInputs.R_Y = 1 end end)
        btnUp.MouseButton1Up:Connect(function() if isLeft then touchInputs.L_Y = 0 else touchInputs.R_Y = 0 end end)
        btnUp.MouseLeave:Connect(function() if isLeft then touchInputs.L_Y = 0 else touchInputs.R_Y = 0 end end)

        btnDown.MouseButton1Down:Connect(function() if isLeft then touchInputs.L_Y = -1 else touchInputs.R_Y = -1 end end)
        btnDown.MouseButton1Up:Connect(function() if isLeft then touchInputs.L_Y = 0 else touchInputs.R_Y = 0 end end)
        btnDown.MouseLeave:Connect(function() if isLeft then touchInputs.L_Y = 0 else touchInputs.R_Y = 0 end end)

        btnLeft.MouseButton1Down:Connect(function() if isLeft then touchInputs.L_X = -1 else touchInputs.R_X = -1 end end)
        btnLeft.MouseButton1Up:Connect(function() if isLeft then touchInputs.L_X = 0 else touchInputs.R_X = 0 end end)
        btnLeft.MouseLeave:Connect(function() if isLeft then touchInputs.L_X = 0 else touchInputs.R_X = 0 end end)

        btnRight.MouseButton1Down:Connect(function() if isLeft then touchInputs.L_X = 1 else touchInputs.R_X = 1 end end)
        btnRight.MouseButton1Up:Connect(function() if isLeft then touchInputs.L_X = 0 else touchInputs.R_X = 0 end end)
        btnRight.MouseLeave:Connect(function() if isLeft then touchInputs.L_X = 0 else touchInputs.R_X = 0 end end)
    end

    setupDpad(true)
    setupDpad(false)
end

-- ===================== МЕНЮ И КНОПКИ =====================
local function CreateMainMenu()
    if MainGui then MainGui:Destroy() end
    MainGui = Instance.new("ScreenGui") 
    MainGui.Name = "MainGui" 
    MainGui.ResetOnSpawn = false 
    MainGui.IgnoreGuiInset = true 
    MainGui.DisplayOrder = 999 
    MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local function createUIButton(text, yPos, color, func)
        local btn = Instance.new("TextButton") 
        btn.Size = UDim2.new(0, 60, 0, 60) 
        btn.Position = UDim2.new(0, 20, 0, yPos) 
        btn.BackgroundColor3 = color or Color3.fromRGB(20, 40, 20) 
        btn.BackgroundTransparency = 0.3 
        btn.Text = text 
        btn.TextColor3 = Color3.fromRGB(0, 255, 100) 
        btn.Font = Enum.Font.GothamBold 
        btn.TextSize = 12 
        btn.Parent = MainGui 
        btn.ZIndex = 100
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1,0) c.Parent = btn
        local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(0, 255, 100) s.Thickness = 2 s.Parent = btn
        btn.MouseButton1Click:Connect(func)
        return btn
    end

    local menuBtn = createUIButton("MENU", 20, Color3.fromRGB(20, 40, 20), function()
        if menuFrame then menuFrame.Visible = not menuFrame.Visible if settingsFrame then settingsFrame.Visible = false end end
    end)
    menuBtn.Name = "MenuUI"

    local spawnBtn = createUIButton("SPAWN", 90, Color3.fromRGB(0, 120, 0), function()
        if not isFlying and not isRebooting then SpawnDrone() end
    end)
    spawnBtn.Name = "SpawnBtn"

    local boostBtn = createUIButton("BOOST", 160, Color3.fromRGB(20, 40, 20), function() end)
    boostBtn.MouseButton1Down:Connect(function() BoostActive = true end)
    boostBtn.MouseButton1Up:Connect(function() BoostActive = false end)
    boostBtn.MouseLeave:Connect(function() BoostActive = false end)
    
    local nvBtn = createUIButton("NV", 230, Color3.fromRGB(20, 40, 20), function()
        NightVisionMode = (NightVisionMode + 1) % 3
        if colorCorrection then
            if NightVisionMode == 0 then colorCorrection.TintColor = Color3.new(1,1,1) colorCorrection.Contrast = 0 c
