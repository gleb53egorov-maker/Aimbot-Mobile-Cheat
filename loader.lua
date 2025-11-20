-- Universal AimBot & ESP v5.0
-- Based on borgeszxz universal aim-esp
-- Enhanced by Kast13l

local UniversalCheat = {
    Version = "5.0 (Universal)",
    Creator = "Kast13l"
}

-- === ПЛАВАЮЩАЯ КНОПКА ===
local function CreateFloatingButton()
    local buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "UniversalCheatUI"
    buttonGui.Parent = game:GetService("CoreGui")
    
    local mainButton = Instance.new("TextButton")
    mainButton.Size = UDim2.new(0, 60, 0, 60)
    mainButton.Position = UDim2.new(0, 20, 0.5, -30)
    mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    mainButton.Text = "🎯"
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.TextSize = 20
    mainButton.BorderSizePixel = 0
    mainButton.ZIndex = 10
    mainButton.Parent = buttonGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = mainButton
    
    return buttonGui, mainButton
end

-- === КОНФИГУРАЦИЯ НА ОСНОВЕ BORGESZXZ ===
local Config = {
    AimBot = {
        Enabled = true,
        Key = "MouseButton2",
        Part = "Head",
        Prediction = 0.165,
        Smoothness = 0.1,
        FOV = 80,
        ShowFOV = true,
        TeamCheck = false,
        WallCheck = true,
        AutoShoot = false,
        ShootDelay = 0.1
    },
    
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        Tracer = false,
        HealthBar = true,
        Weapon = true,
        Chams = false,
        Outline = true
    },
    
    Visuals = {
        NoFog = true,
        FullBright = true,
        Crosshair = true
    },
    
    Misc = {
        Speed = false,
        SpeedValue = 25,
        JumpPower = false,
        JumpValue = 50,
        AntiAFK = true
    }
}

-- === УНИВЕРСАЛЬНЫЙ ESP ===
local function InitializeUniversalESP()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    
    local ESPObjects = {}
    
    local function CreateESP(Player)
        if Player == LocalPlayer then return end
        
        ESPObjects[Player] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Health = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            Weapon = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthBarBg = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            BoxOutline = Drawing.new("Square")
        }
        
        local ESP = ESPObjects[Player]
        
        -- Basic settings
        ESP.Box.Thickness = 2
        ESP.Box.Filled = false
        
        ESP.BoxOutline.Thickness = 4
        ESP.BoxOutline.Filled = false
        ESP.BoxOutline.Transparency = 0.5
        
        ESP.Name.Size = 14
        ESP.Name.Outline = true
        
        ESP.Health.Size = 12
        ESP.Health.Outline = true
        
        ESP.Distance.Size = 12
        ESP.Distance.Outline = true
        
        ESP.Weapon.Size = 12
        ESP.Weapon.Outline = true
        
        ESP.HealthBarBg.Filled = true
        ESP.HealthBarBg.Color = Color3.new(0, 0, 0)
        
        ESP.HealthBar.Filled = true
        
        ESP.Tracer.Thickness = 1
    end
    
    local function GetWeapon(Player)
        if Player.Character then
            -- Check equipped tool
            local Tool = Player.Character:FindFirstChildOfClass("Tool")
            if Tool then return Tool.Name end
            
            -- Check backpack
            local Backpack = Player:FindFirstChild("Backpack")
            if Backpack then
                for _, Item in pairs(Backpack:GetChildren()) do
                    if Item:IsA("Tool") then
                        return Item.Name
                    end
                end
            end
        end
        return "Fists"
    end
    
    local function IsVisible(Part)
        if not Config.AimBot.WallCheck then return true end
        
        local Char = LocalPlayer.Character
        if not Char then return false end
        
        local Head = Char:FindFirstChild("Head")
        if not Head then return false end
        
        local Origin = Head.Position
        local Direction = (Part.Position - Origin).Unit
        local RayParams = RaycastParams.new()
        RayParams.FilterDescendantsInstances = {Char, Part.Parent}
        RayParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local Result = workspace:Raycast(Origin, Direction * 1000, RayParams)
        return Result and Result.Instance:IsDescendantOf(Part.Parent)
    end
    
    -- High-performance ESP without FPS limits
    RunService.RenderStepped:Connect(function()
        for Player, ESP in pairs(ESPObjects) do
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local Root = Player.Character.HumanoidRootPart
                local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
                local Head = Player.Character:FindFirstChild("Head")
                
                if Root and Hum and Hum.Health > 0 and Head then
                    local HeadPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                    
                    if OnScreen then
                        local Dist = (Root.Position - Camera.CFrame.Position).Magnitude
                        local Scale = math.clamp(1000 / Dist, 0.4, 1.8)
                        
                        local Height = 35 * Scale
                        local Width = 18 * Scale
                        
                        -- Health-based coloring
                        local HP = Hum.Health
                        local MaxHP = Hum.MaxHealth
                        local HPPerc = HP / MaxHP
                        
                        local Color = Color3.new(1, 1, 1)
                        if HPPerc > 0.6 then
                            Color = Color3.fromRGB(0, 255, 0)
                        elseif HPPerc > 0.3 then
                            Color = Color3.fromRGB(255, 255, 0)
                        else
                            Color = Color3.fromRGB(255, 0, 0)
                        end
                        
                        local X = HeadPos.X - Width / 2
                        local Y = HeadPos.Y - Height / 2
                        
                        -- Box ESP
                        ESP.Box.Visible = Config.ESP.Enabled and Config.ESP.Box
                        ESP.Box.Color = Color
                        ESP.Box.Position = Vector2.new(X, Y)
                        ESP.Box.Size = Vector2.new(Width, Height)
                        
                        -- Box Outline
                        ESP.BoxOutline.Visible = Config.ESP.Enabled and Config.ESP.Box and Config.ESP.Outline
                        ESP.BoxOutline.Color = Color3.new(0, 0, 0)
                        ESP.BoxOutline.Position = Vector2.new(X, Y)
                        ESP.BoxOutline.Size = Vector2.new(Width, Height)
                        
                        -- Name
                        ESP.Name.Visible = Config.ESP.Enabled and Config.ESP.Name
                        ESP.Name.Color = Color
                        ESP.Name.Position = Vector2.new(HeadPos.X, Y - 18)
                        ESP.Name.Text = Player.Name
                        
                        -- Health
                        ESP.Health.Visible = Config.ESP.Enabled and Config.ESP.Health
                        ESP.Health.Color = Color
                        ESP.Health.Position = Vector2.new(HeadPos.X, Y + Height + 3)
                        ESP.Health.Text = "HP: " .. math.floor(HP)
                        
                        -- Distance
                        ESP.Distance.Visible = Config.ESP.Enabled and Config.ESP.Distance
                        ESP.Distance.Color = Color
                        ESP.Distance.Position = Vector2.new(HeadPos.X, Y + Height + 18)
                        ESP.Distance.Text = math.floor(Dist) .. "m"
                        
                        -- Weapon
                        ESP.Weapon.Visible = Config.ESP.Enabled and Config.ESP.Weapon
                        ESP.Weapon.Color = Color
                        ESP.Weapon.Position = Vector2.new(HeadPos.X, Y + Height + 33)
                        ESP.Weapon.Text = GetWeapon(Player)
                        
                        -- Health Bar
                        if Config.ESP.HealthBar then
                            local BarW = Width
                            local BarH = 3
                            local BarX = X
                            local BarY = Y - 6
                            
                            ESP.HealthBarBg.Visible = true
                            ESP.HealthBarBg.Position = Vector2.new(BarX, BarY)
                            ESP.HealthBarBg.Size = Vector2.new(BarW, BarH)
                            
                            ESP.HealthBar.Visible = true
                            ESP.HealthBar.Color = Color
                            ESP.HealthBar.Position = Vector2.new(BarX, BarY)
                            ESP.HealthBar.Size = Vector2.new(BarW * HPPerc, BarH)
                        else
                            ESP.HealthBarBg.Visible = false
                            ESP.HealthBar.Visible = false
                        end
                        
                        -- Tracer
                        if Config.ESP.Tracer then
                            ESP.Tracer.Visible = true
                            ESP.Tracer.Color = Color
                            ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            ESP.Tracer.To = Vector2.new(HeadPos.X, HeadPos.Y)
                        else
                            ESP.Tracer.Visible = false
                        end
                        
                    else
                        for _, Draw in pairs(ESP) do
                            Draw.Visible = false
                        end
                    end
                else
                    for _, Draw in pairs(ESP) do
                        Draw.Visible = false
                    end
                end
            else
                for _, Draw in pairs(ESP) do
                    Draw.Visible = false
                end
            end
        end
    end)
    
    -- Initialize players
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            CreateESP(Player)
        end
    end
    
    Players.PlayerAdded:Connect(CreateESP)
    Players.PlayerRemoving:Connect(function(Player)
        if ESPObjects[Player] then
            for _, Draw in pairs(ESPObjects[Player]) do
                Draw:Remove()
            end
            ESPObjects[Player] = nil
        end
    end)
end

-- === УНИВЕРСАЛЬНЫЙ AIMBOT ===
local function InitializeUniversalAimBot()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    
    -- Visuals
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Config.AimBot.ShowFOV
    FOVCircle.Color = Color3.new(1, 1, 1)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
    
    local Crosshair = Drawing.new("Circle")
    Crosshair.Visible = Config.Visuals.Crosshair
    Crosshair.Color = Color3.new(1, 1, 1)
    Crosshair.Thickness = 2
    Crosshair.Filled = false
    Crosshair.Radius = 4
    
    local TargetDot = Drawing.new("Circle")
    TargetDot.Visible = false
    TargetDot.Color = Color3.new(1, 0, 0)
    TargetDot.Thickness = 2
    TargetDot.Filled = true
    TargetDot.Radius = 2
    
    local function FindTarget()
        local BestTarget = nil
        local ClosestDist = Config.AimBot.FOV
        local MousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                -- Team check
                if Config.AimBot.TeamCheck then
                    if LocalPlayer.Team and Player.Team and LocalPlayer.Team == Player.Team then
                        continue
                    end
                end
                
                local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
                local Part = Player.Character:FindFirstChild(Config.AimBot.Part)
                
                if Hum and Hum.Health > 0 and Part then
                    -- Wall check
                    if Config.AimBot.WallCheck and not IsVisible(Part) then
                        continue
                    end
                    
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    
                    if OnScreen then
                        local Dist = (MousePos - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                        
                        if Dist < ClosestDist then
                            ClosestDist = Dist
                            BestTarget = Part
                        end
                    end
                end
            end
        end
        
        return BestTarget
    end
    
    local LastShot = 0
    
    RunService.RenderStepped:Connect(function()
        -- Update visuals
        FOVCircle.Visible = Config.AimBot.ShowFOV
        FOVCircle.Radius = Config.AimBot.FOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        Crosshair.Visible = Config.Visuals.Crosshair
        Crosshair.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        -- AimBot logic
        if Config.AimBot.Enabled and UIS:IsMouseButtonPressed(Enum.UserInputType[Config.AimBot.Key]) then
            local Target = FindTarget()
            
            if Target then
                local ScreenPos = Camera:WorldToViewportPoint(Target.Position)
                
                -- Prediction
                local Root = Target.Parent:FindFirstChild("HumanoidRootPart")
                if Root and Config.AimBot.Prediction > 0 then
                    local Vel = Root.Velocity
                    ScreenPos = Camera:WorldToViewportPoint(Target.Position + (Vel * Config.AimBot.Prediction))
                end
                
                local TargetPos = Vector2.new(ScreenPos.X, ScreenPos.Y)
                local MousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                
                -- Show target dot
                TargetDot.Visible = true
                TargetDot.Position = TargetPos
                
                -- Smooth aiming
                local Delta = (TargetPos - MousePos) * Config.AimBot.Smoothness
                mousemoverel(Delta.X, Delta.Y)
                
                -- Auto shoot
                if Config.AimBot.AutoShoot then
                    local CurrentTime = tick()
                    if CurrentTime - LastShot >= Config.AimBot.ShootDelay then
                        mouse1press()
                        wait(0.05)
                        mouse1release()
                        LastShot = CurrentTime
                    end
                end
            else
                TargetDot.Visible = false
            end
        else
            TargetDot.Visible = false
        end
    end)
end

-- === ВИЗУАЛЬНЫЕ ФУНКЦИИ ===
local function InitializeVisuals()
    local RunService = game:GetService("RunService")
    
    RunService.Heartbeat:Connect(function()
        if Config.Visuals.NoFog then
            game:GetService("Lighting").FogEnd = 1000000
        end
        
        if Config.Visuals.FullBright then
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").Brightness = 2
        end
    end)
end

-- === ФУНКЦИИ ДВИЖЕНИЯ ===
local function InitializeMovement()
    local Player = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")
    
    RunService.Heartbeat:Connect(function()
        if Player.Character then
            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if Hum then
                -- Speed hack
                if Config.Misc.Speed then
                    Hum.WalkSpeed = Config.Misc.SpeedValue
                else
                    Hum.WalkSpeed = 16
                end
                
                -- Jump power
                if Config.Misc.JumpPower then
                    Hum.JumpPower = Config.Misc.JumpValue
                end
            end
        end
    end)
end

-- === ANTI-AFK ===
local function InitializeAntiAFK()
    local VirtualInput = game:GetService("VirtualInputManager")
    
    while true do
        if Config.Misc.AntiAFK then
            VirtualInput:SendKeyEvent(true, "Space", false, game)
            wait(0.1)
            VirtualInput:SendKeyEvent(false, "Space", false, game)
        end
        wait(30)
    end
end

-- === ИНТЕРФЕЙС ===
local function CreateInterface()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "UniversalCheatInterface"
    MainGui.Parent = game:GetService("CoreGui")
    MainGui.Enabled = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 450)
    MainFrame.Position = UDim2.new(0, 80, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MainGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🎯 Universal Cheat v5.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Parent = Header
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, -40)
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 6
    Content.CanvasSize = UDim2.new(0, 0, 0, 700)
    Content.Parent = MainFrame
    
    local function CreateToggle(Parent, Name, Category, Key, YPos)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
        ToggleFrame.Position = UDim2.new(0, 10, 0, YPos)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = Parent
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.fromRGB(220, 220, 220)
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 45, 0, 22)
        Toggle.Position = UDim2.new(0.7, 0, 0.5, -11)
        Toggle.BackgroundColor3 = Config[Category][Key] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 80)
        Toggle.Text = ""
        Toggle.BorderSizePixel = 0
        Toggle.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 11)
        ToggleCorner.Parent = Toggle
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 18, 0, 18)
        Indicator.Position = UDim2.new(0, Config[Category][Key] and 25 or 2, 0.5, -9)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.BorderSizePixel = 0
        Indicator.Parent = Toggle
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = Indicator
        
        Toggle.MouseButton1Click:Connect(function()
            Config[Category][Key] = not Config[Category][Key]
            Toggle.BackgroundColor3 = Config[Category][Key] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 80)
            
            Indicator:TweenPosition(
                UDim2.new(0, Config[Category][Key] and 25 or 2, 0.5, -9),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.15,
                true
            )
        end)
        
        return ToggleFrame
    end
    
    local YPos = 15
    
    -- AimBot
    CreateToggle(Content, "🎯 AimBot", "AimBot", "Enabled", YPos); YPos = YPos + 35
    CreateToggle(Content, "👁️ Show FOV", "AimBot", "ShowFOV", YPos); YPos = YPos + 35
    CreateToggle(Content, "👥 Team Check", "AimBot", "TeamCheck", YPos); YPos = YPos + 35
    CreateToggle(Content, "🧱 Wall Check", "AimBot", "WallCheck", YPos); YPos = YPos + 35
    CreateToggle(Content, "🔫 Auto Shoot", "AimBot", "AutoShoot", YPos); YPos = YPos + 35
    
    -- ESP
    CreateToggle(Content, "📱 ESP", "ESP", "Enabled", YPos); YPos = YPos + 35
    CreateToggle(Content, "🟦 Box", "ESP", "Box", YPos); YPos = YPos + 35
    CreateToggle(Content, "👤 Name", "ESP", "Name", YPos); YPos = YPos + 35
    CreateToggle(Content, "❤️ Health", "ESP", "Health", YPos); YPos = YPos + 35
    CreateToggle(Content, "📏 Distance", "ESP", "Distance", YPos); YPos = YPos + 35
    CreateToggle(Content, "🔫 Weapon", "ESP", "Weapon", YPos); YPos = YPos + 35
    CreateToggle(Content, "📊 Health Bar", "ESP", "HealthBar", YPos); YPos = YPos + 35
    CreateToggle(Content, "📈 Tracer", "ESP", "Tracer", YPos); YPos = YPos + 35
    CreateToggle(Content, "🔲 Outline", "ESP", "Outline", YPos); YPos = YPos + 35
    
    -- Visuals
    CreateToggle(Content, "🌫️ No Fog", "Visuals", "NoFog", YPos); YPos = YPos + 35
    CreateToggle(Content, "💡 Full Bright", "Visuals", "FullBright", YPos); YPos = YPos + 35
    CreateToggle(Content, "🎯 Crosshair", "Visuals", "Crosshair", YPos); YPos = YPos + 35
    
    -- Misc
    CreateToggle(Content, "🏃 Speed", "Misc", "Speed", YPos); YPos = YPos + 35
    CreateToggle(Content, "🦘 Jump Power", "Misc", "JumpPower", YPos); YPos = YPos + 35
    CreateToggle(Content, "⏰ Anti-AFK", "Misc", "AntiAFK", YPos); YPos = YPos + 35
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainGui.Enabled = false
    end)
    
    return MainGui
end

-- === ОСНОВНАЯ ФУНКЦИЯ ===
local function Main()
    print("╔══════════════════════════════╗")
    print("║     Universal Cheat v5.0     ║")
    print("║    Based on borgeszxz        ║")
    print("║    Enhanced by Kast13l       ║")
    print("╚══════════════════════════════╝")
    
    -- Create interface
    local FloatingButton, MainButton = CreateFloatingButton()
    local MainUI = CreateInterface()
    
    -- Button handler
    MainButton.MouseButton1Click:Connect(function()
        MainUI.Enabled = not MainUI.Enabled
    end)
    
    -- Initialize features
    InitializeUniversalESP()
    InitializeUniversalAimBot()
    InitializeVisuals()
    InitializeMovement()
    coroutine.wrap(InitializeAntiAFK)()
    
    print("[UniversalCheat] 🎯 Universal ESP & AimBot loaded!")
    print("[UniversalCheat] 🚀 No FPS limits - Maximum performance")
    print("[UniversalCheat] 👆 Click the blue button to open menu")
end

-- Start
Main()
