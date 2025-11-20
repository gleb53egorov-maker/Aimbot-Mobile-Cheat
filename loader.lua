-- Ultimate AimBot & ESP v4.0
-- Enhanced by Kast13l

local AimBot = {
    Version = "4.0 (Ultimate)",
    Creator = "Kast13l"
}

-- === ПЛАВАЮЩАЯ КНОПКА ===
local function CreateFloatingButton()
    local buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "AimBotUI"
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

-- === КОНФИГУРАЦИЯ ===
local Config = {
    AimBot = {
        Enabled = true,
        TriggerKey = "MouseButton2",
        AimPart = "Head",
        Prediction = 0.13666,
        Smoothness = 0.03,
        FOV = 100,
        FOVVisible = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        TeamCheck = false,
        VisibleCheck = true
    },
    
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,
        HealthBar = true,
        Weapon = true,
        OutOfViewArrows = false,
        Chams = false
    },
    
    Visuals = {
        NoFog = true,
        FullBright = true,
        Crosshair = true
    }
}

-- === УЛУЧШЕННЫЙ ESP БЕЗ ОГРАНИЧЕНИЙ FPS ===
local function InitializeEnhancedESP()
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
            BoxFill = Drawing.new("Square"),
            Tracer = Drawing.new("Line")
        }
        
        local ESP = ESPObjects[Player]
        
        ESP.Box.Thickness = 2
        ESP.Box.Filled = false
        
        ESP.BoxFill.Thickness = 1
        ESP.BoxFill.Filled = true
        ESP.BoxFill.Transparency = 0.1
        
        ESP.Name.Size = 14
        ESP.Name.Outline = true
        ESP.Name.OutlineColor = Color3.new(0, 0, 0)
        
        ESP.Health.Size = 12
        ESP.Health.Outline = true
        ESP.Health.OutlineColor = Color3.new(0, 0, 0)
        
        ESP.Distance.Size = 12
        ESP.Distance.Outline = true
        ESP.Distance.OutlineColor = Color3.new(0, 0, 0)
        
        ESP.Weapon.Size = 12
        ESP.Weapon.Outline = true
        ESP.Weapon.OutlineColor = Color3.new(0, 0, 0)
        
        ESP.HealthBarBg.Filled = true
        ESP.HealthBarBg.Color = Color3.new(0, 0, 0)
        
        ESP.HealthBar.Filled = true
        
        ESP.Tracer.Thickness = 2
    end
    
    local function GetPlayerWeapon(Player)
        if Player.Character then
            local Tool = Player.Character:FindFirstChildOfClass("Tool")
            if Tool then
                return Tool.Name
            end
            
            local Backpack = Player:FindFirstChild("Backpack")
            if Backpack then
                local Weapons = Backpack:GetChildren()
                if #Weapons > 0 then
                    return Weapons[1].Name
                end
            end
        end
        return "No Weapon"
    end
    
    -- Без ограничений FPS - максимальная производительность
    RunService.RenderStepped:Connect(function()
        for Player, ESP in pairs(ESPObjects) do
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local RootPart = Player.Character.HumanoidRootPart
                local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                local Head = Player.Character:FindFirstChild("Head")
                
                if RootPart and Humanoid and Humanoid.Health > 0 and Head then
                    local HeadPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                    
                    if OnScreen then
                        local Distance = (RootPart.Position - Camera.CFrame.Position).Magnitude
                        local Scale = math.clamp(1200 / Distance, 0.3, 2.0)
                        
                        local BoxHeight = 40 * Scale
                        local BoxWidth = 20 * Scale
                        
                        local Health = Humanoid.Health
                        local MaxHealth = Humanoid.MaxHealth
                        local HealthPercent = Health / MaxHealth
                        
                        local Color = Color3.new(1, 1, 1)
                        if HealthPercent > 0.7 then
                            Color = Color3.fromRGB(0, 255, 0)
                        elseif HealthPercent > 0.4 then
                            Color = Color3.fromRGB(255, 255, 0)
                        elseif HealthPercent > 0.2 then
                            Color = Color3.fromRGB(255, 165, 0)
                        else
                            Color = Color3.fromRGB(255, 0, 0)
                        end
                        
                        local BoxX = HeadPos.X - BoxWidth / 2
                        local BoxY = HeadPos.Y - BoxHeight / 2
                        
                        -- Box ESP
                        ESP.Box.Visible = Config.ESP.Enabled and Config.ESP.Boxes
                        ESP.Box.Color = Color
                        ESP.Box.Position = Vector2.new(BoxX, BoxY)
                        ESP.Box.Size = Vector2.new(BoxWidth, BoxHeight)
                        
                        -- Box Fill
                        ESP.BoxFill.Visible = Config.ESP.Enabled and Config.ESP.Boxes
                        ESP.BoxFill.Color = Color
                        ESP.BoxFill.Position = Vector2.new(BoxX, BoxY)
                        ESP.BoxFill.Size = Vector2.new(BoxWidth, BoxHeight)
                        
                        -- Name
                        ESP.Name.Visible = Config.ESP.Enabled and Config.ESP.Names
                        ESP.Name.Color = Color
                        ESP.Name.Position = Vector2.new(HeadPos.X, BoxY - 20)
                        ESP.Name.Text = Player.Name
                        
                        -- Health
                        ESP.Health.Visible = Config.ESP.Enabled and Config.ESP.Health
                        ESP.Health.Color = Color
                        ESP.Health.Position = Vector2.new(HeadPos.X, BoxY + BoxHeight + 5)
                        ESP.Health.Text = "HP: " .. math.floor(Health)
                        
                        -- Distance
                        ESP.Distance.Visible = Config.ESP.Enabled and Config.ESP.Distance
                        ESP.Distance.Color = Color
                        ESP.Distance.Position = Vector2.new(HeadPos.X, BoxY + BoxHeight + 22)
                        ESP.Distance.Text = math.floor(Distance) .. "m"
                        
                        -- Weapon
                        ESP.Weapon.Visible = Config.ESP.Enabled and Config.ESP.Weapon
                        ESP.Weapon.Color = Color
                        ESP.Weapon.Position = Vector2.new(HeadPos.X, BoxY + BoxHeight + 39)
                        ESP.Weapon.Text = GetPlayerWeapon(Player)
                        
                        -- Health Bar
                        if Config.ESP.HealthBar then
                            local BarWidth = BoxWidth
                            local BarHeight = 4
                            local BarX = BoxX
                            local BarY = BoxY - 8
                            
                            ESP.HealthBarBg.Visible = true
                            ESP.HealthBarBg.Position = Vector2.new(BarX, BarY)
                            ESP.HealthBarBg.Size = Vector2.new(BarWidth, BarHeight)
                            
                            ESP.HealthBar.Visible = true
                            ESP.HealthBar.Color = Color
                            ESP.HealthBar.Position = Vector2.new(BarX, BarY)
                            ESP.HealthBar.Size = Vector2.new(BarWidth * HealthPercent, BarHeight)
                        else
                            ESP.HealthBarBg.Visible = false
                            ESP.HealthBar.Visible = false
                        end
                        
                        -- Tracer
                        if Config.ESP.Tracers then
                            ESP.Tracer.Visible = true
                            ESP.Tracer.Color = Color
                            ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            ESP.Tracer.To = Vector2.new(HeadPos.X, HeadPos.Y)
                        else
                            ESP.Tracer.Visible = false
                        end
                        
                    else
                        for _, Drawing in pairs(ESP) do
                            Drawing.Visible = false
                        end
                    end
                else
                    for _, Drawing in pairs(ESP) do
                        Drawing.Visible = false
                    end
                end
            else
                for _, Drawing in pairs(ESP) do
                    Drawing.Visible = false
                end
            end
        end
    end)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            CreateESP(Player)
        end
    end
    
    Players.PlayerAdded:Connect(CreateESP)
    Players.PlayerRemoving:Connect(function(Player)
        if ESPObjects[Player] then
            for _, Drawing in pairs(ESPObjects[Player]) do
                Drawing:Remove()
            end
            ESPObjects[Player] = nil
        end
    end)
end

-- === AIMBOT НА ОСНОВЕ EXUNYS V3 ===
local function InitializeAimBot()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    -- FOV Circle
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Config.AimBot.FOVVisible
    FOVCircle.Color = Config.AimBot.FOVColor
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Config.AimBot.FOV
    
    -- Crosshair
    local Crosshair = Drawing.new("Circle")
    Crosshair.Visible = Config.Visuals.Crosshair
    Crosshair.Color = Color3.new(1, 1, 1)
    Crosshair.Thickness = 2
    Crosshair.Filled = false
    Crosshair.Radius = 5
    
    local function FindClosestTarget()
        local ClosestTarget = nil
        local ShortestDistance = Config.AimBot.FOV
        local MousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                local AimPart = Player.Character:FindFirstChild(Config.AimBot.AimPart)
                
                if Humanoid and Humanoid.Health > 0 and AimPart then
                    -- Team check
                    if Config.AimBot.TeamCheck then
                        if LocalPlayer.Team and Player.Team and LocalPlayer.Team == Player.Team then
                            continue
                        end
                    end
                    
                    -- Visible check
                    if Config.AimBot.VisibleCheck then
                        local Character = LocalPlayer.Character
                        if Character then
                            local Head = Character:FindFirstChild("Head")
                            if Head then
                                local Origin = Head.Position
                                local Direction = (AimPart.Position - Origin).Unit
                                local RaycastParams = RaycastParams.new()
                                RaycastParams.FilterDescendantsInstances = {Character, AimPart.Parent}
                                RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                
                                local RaycastResult = workspace:Raycast(Origin, Direction * 1000, RaycastParams)
                                if RaycastResult and not RaycastResult.Instance:IsDescendantOf(AimPart.Parent) then
                                    continue
                                end
                            end
                        end
                    end
                    
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(AimPart.Position)
                    
                    if OnScreen then
                        local Distance = (MousePos - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                        
                        if Distance < ShortestDistance then
                            ShortestDistance = Distance
                            ClosestTarget = AimPart
                        end
                    end
                end
            end
        end
        
        return ClosestTarget
    end
    
    RunService.RenderStepped:Connect(function()
        -- Update FOV Circle
        FOVCircle.Visible = Config.AimBot.FOVVisible
        FOVCircle.Radius = Config.AimBot.FOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        -- Update Crosshair
        Crosshair.Visible = Config.Visuals.Crosshair
        Crosshair.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        -- AimBot Logic
        if Config.AimBot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType[Config.AimBot.TriggerKey]) then
            local Target = FindClosestTarget()
            if Target then
                local ScreenPos = Camera:WorldToViewportPoint(Target.Position)
                
                -- Prediction
                local RootPart = Target.Parent:FindFirstChild("HumanoidRootPart")
                if RootPart and Config.AimBot.Prediction > 0 then
                    local Velocity = RootPart.Velocity
                    ScreenPos = Camera:WorldToViewportPoint(Target.Position + Velocity * Config.AimBot.Prediction)
                end
                
                local TargetPos = Vector2.new(ScreenPos.X, ScreenPos.Y)
                local MousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                
                local Delta = (TargetPos - MousePos) * Config.AimBot.Smoothness
                mousemoverel(Delta.X, Delta.Y)
            end
        end
    end)
end

-- === ВИЗУАЛЬНЫЕ УЛУЧШЕНИЯ ===
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

-- === ИНТЕРФЕЙС ===
local function CreateInterface()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "AimBotInterface"
    MainGui.Parent = game:GetService("CoreGui")
    MainGui.Enabled = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0, 80, 0.5, -200)
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
    Title.Text = "🎯 Ultimate AimBot v4.0"
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
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 6
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    ContentFrame.Parent = MainFrame
    
    local function CreateToggle(Parent, Name, ConfigCategory, ConfigKey, YPosition)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
        ToggleFrame.Position = UDim2.new(0, 10, 0, YPosition)
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
        Toggle.BackgroundColor3 = Config[ConfigCategory][ConfigKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 80)
        Toggle.Text = ""
        Toggle.BorderSizePixel = 0
        Toggle.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 11)
        ToggleCorner.Parent = Toggle
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
        ToggleIndicator.Position = UDim2.new(0, Config[ConfigCategory][ConfigKey] and 25 or 2, 0.5, -9)
        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = Toggle
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ToggleIndicator
        
        Toggle.MouseButton1Click:Connect(function()
            Config[ConfigCategory][ConfigKey] = not Config[ConfigCategory][ConfigKey]
            Toggle.BackgroundColor3 = Config[ConfigCategory][ConfigKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 80)
            
            ToggleIndicator:TweenPosition(
                UDim2.new(0, Config[ConfigCategory][ConfigKey] and 25 or 2, 0.5, -9),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.15,
                true
            )
        end)
        
        return ToggleFrame
    end
    
    -- Add toggles
    local YPosition = 15
    
    -- AimBot
    CreateToggle(ContentFrame, "🎯 AimBot Enabled", "AimBot", "Enabled", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "👁️ FOV Circle", "AimBot", "FOVVisible", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "👥 Team Check", "AimBot", "TeamCheck", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "🔍 Visible Check", "AimBot", "VisibleCheck", YPosition); YPosition = YPosition + 35
    
    -- ESP
    CreateToggle(ContentFrame, "📱 ESP Enabled", "ESP", "Enabled", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "🟦 Boxes", "ESP", "Boxes", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "👤 Names", "ESP", "Names", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "❤️ Health", "ESP", "Health", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "📏 Distance", "ESP", "Distance", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "🔫 Weapon", "ESP", "Weapon", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "📊 Health Bar", "ESP", "HealthBar", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "📈 Tracers", "ESP", "Tracers", YPosition); YPosition = YPosition + 35
    
    -- Visuals
    CreateToggle(ContentFrame, "🌫️ No Fog", "Visuals", "NoFog", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "💡 Full Bright", "Visuals", "FullBright", YPosition); YPosition = YPosition + 35
    CreateToggle(ContentFrame, "🎯 Crosshair", "Visuals", "Crosshair", YPosition); YPosition = YPosition + 35
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainGui.Enabled = false
    end)
    
    return MainGui
end

-- === ОСНОВНАЯ ФУНКЦИЯ ===
local function Main()
    print("╔══════════════════════════════╗")
    print("║      Ultimate AimBot v4.0    ║")
    print("║        Enhanced ESP          ║")
    print("║       No FPS Limits          ║")
    print("╚══════════════════════════════╝")
    
    -- Create interface
    local FloatingButton, MainButton = CreateFloatingButton()
    local MainUI = CreateInterface()
    
    -- Button handler
    MainButton.MouseButton1Click:Connect(function()
        MainUI.Enabled = not MainUI.Enabled
    end)
    
    -- Initialize features
    InitializeEnhancedESP()
    InitializeAimBot()
    InitializeVisuals()
    
    print("[UltimateAimBot] 🎯 Enhanced ESP & AimBot loaded!")
    print("[UltimateAimBot] 🚀 No FPS limits - Maximum performance")
    print("[UltimateAimBot] 👆 Click the blue button to open menu")
end

-- Start
Main()
