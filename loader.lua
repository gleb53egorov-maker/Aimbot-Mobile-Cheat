-- Mobile AimBot Pro v1.0 - Best for Phone
-- Created by Kast13l

local MobileAimBot = {
    Version = "1.0 (Mobile Pro)",
    Creator = "Kast13l",
    Platform = "Mobile"
}

-- === АВТОМАТИЧЕСКОЕ ОПРЕДЕЛЕНИЕ ПЛАТФОРМЫ ===
local function IsMobile()
    local UIS = game:GetService("UserInputService")
    return UIS.TouchEnabled
end

if not IsMobile() then
    warn("[MobileAimBot] This script is optimized for mobile devices!")
end

-- === ПЛАВАЮЩАЯ КНОПКА ДЛЯ МОБИЛЬНЫХ ===
local function CreateMobileButton()
    local buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "MobileAimBotUI"
    buttonGui.Parent = game:GetService("CoreGui")
    
    -- Главная кнопка
    local mainButton = Instance.new("TextButton")
    mainButton.Size = UDim2.new(0, 70, 0, 70)
    mainButton.Position = UDim2.new(0, 20, 0.5, -35)
    mainButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    mainButton.Text = "🎯"
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.TextSize = 24
    mainButton.BorderSizePixel = 0
    mainButton.ZIndex = 10
    mainButton.Parent = buttonGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = mainButton
    
    -- Тень
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 3
    shadow.Parent = mainButton
    
    return buttonGui, mainButton
end

-- === КОНФИГУРАЦИЯ ДЛЯ МОБИЛЬНЫХ ===
local Config = {
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,
        Skeletons = false,
        HealthBar = true,
        Weapon = true
    },
    AimBot = {
        Enabled = true,
        AutoAim = false,  -- Авто-прицеливание без нажатия
        AimKey = "Touch", -- Для мобильных - касание
        AimFOV = 60,
        Smoothness = 0.5,
        Prediction = true,
        AimAt = "Head",   -- Head, Torso, HumanoidRootPart
        TriggerBot = false,
        SilentAim = false
    },
    Movement = {
        Speed = false,
        SpeedValue = 25,
        Bhop = false,
        JumpPower = 50
    },
    Visuals = {
        NoFog = true,
        FullBright = true,
        Crosshair = true
    }
}

-- === ЛУЧШИЙ ESP ДЛЯ МОБИЛЬНЫХ ===
local function InitializeProESP()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local runService = game:GetService("RunService")
    
    local espObjects = {}
    
    local function createESP(player)
        if player == localPlayer then return end
        
        espObjects[player] = {
            -- Основные элементы
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Health = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            Weapon = Drawing.new("Text"),
            
            -- Дополнительные элементы
            HealthBar = Drawing.new("Square"),
            HealthBarBg = Drawing.new("Square"),
            BoxFill = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            
            -- Скелет (опционально)
            HeadDot = Drawing.new("Circle"),
            Skeleton = {}
        }
        
        local esp = espObjects[player]
        
        -- Настройка стилей для лучшей видимости на мобильных
        esp.Box.Thickness = 2
        esp.Box.Filled = false
        
        esp.BoxFill.Thickness = 1
        esp.BoxFill.Filled = true
        esp.BoxFill.Transparency = 0.1
        
        esp.Name.Size = 16  -- Больше для мобильных
        esp.Name.Outline = true
        esp.Name.OutlineColor = Color3.new(0, 0, 0)
        
        esp.Health.Size = 14
        esp.Health.Outline = true
        esp.Health.OutlineColor = Color3.new(0, 0, 0)
        
        esp.Distance.Size = 12
        esp.Distance.Outline = true
        esp.Distance.OutlineColor = Color3.new(0, 0, 0)
        
        esp.Weapon.Size = 12
        esp.Weapon.Outline = true
        esp.Weapon.OutlineColor = Color3.new(0, 0, 0)
        
        esp.HealthBarBg.Filled = true
        esp.HealthBarBg.Color = Color3.new(0, 0, 0)
        
        esp.HealthBar.Filled = true
        
        esp.Tracer.Thickness = 2
        
        esp.HeadDot.Thickness = 2
        esp.HeadDot.Filled = true
        esp.HeadDot.NumSides = 12
    end
    
    local function getPlayerWeapon(player)
        if player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then
                return tool.Name
            end
            
            -- Поиск оружия в инвентаре
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local weapons = backpack:GetChildren()
                if #weapons > 0 then
                    return weapons[1].Name
                end
            end
        end
        return "No Weapon"
    end
    
    local function updateSkeleton(player, esp)
        if not Config.ESP.Skeletons then return end
        
        local character = player.Character
        if not character then return end
        
        local skeletonParts = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"},
            {"RightLowerLeg", "RightFoot"}
        }
        
        for i, bone in ipairs(skeletonParts) do
            if not esp.Skeleton[i] then
                esp.Skeleton[i] = Drawing.new("Line")
                esp.Skeleton[i].Thickness = 2
                esp.Skeleton[i].Color = Color3.new(1, 1, 0)
            end
            
            local part1 = character:FindFirstChild(bone[1])
            local part2 = character:FindFirstChild(bone[2])
            
            if part1 and part2 then
                local pos1, vis1 = camera:WorldToViewportPoint(part1.Position)
                local pos2, vis2 = camera:WorldToViewportPoint(part2.Position)
                
                if vis1 and vis2 then
                    esp.Skeleton[i].Visible = true
                    esp.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                    esp.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                else
                    esp.Skeleton[i].Visible = false
                end
            else
                esp.Skeleton[i].Visible = false
            end
        end
    end
    
    -- Оптимизированное обновление ESP
    local lastUpdate = 0
    runService.RenderStepped:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate < 0.05 then return end -- 20 FPS для оптимизации
        lastUpdate = currentTime
        
        for player, esp in pairs(espObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                
                if rootPart and humanoid and humanoid.Health > 0 and head then
                    local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                        local scale = math.clamp(1200 / distance, 0.3, 2.0)
                        
                        local boxHeight = 40 * scale
                        local boxWidth = 20 * scale
                        
                        -- Цвет по здоровью с плавными переходами
                        local health = humanoid.Health
                        local maxHealth = humanoid.MaxHealth
                        local healthPercent = health / maxHealth
                        
                        local color = Color3.new(1, 1, 1)
                        if healthPercent > 0.7 then
                            color = Color3.fromRGB(0, 255, 0)    -- Зеленый
                        elseif healthPercent > 0.4 then
                            color = Color3.fromRGB(255, 255, 0)  -- Желтый
                        elseif healthPercent > 0.2 then
                            color = Color3.fromRGB(255, 165, 0)  -- Оранжевый
                        else
                            color = Color3.fromRGB(255, 0, 0)    -- Красный
                        end
                        
                        -- Позиции элементов
                        local boxX = headPos.X - boxWidth / 2
                        local boxY = headPos.Y - boxHeight / 2
                        
                        -- Основной бокс
                        esp.Box.Visible = Config.ESP.Enabled and Config.ESP.Boxes
                        esp.Box.Color = color
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                        
                        -- Заполненный бокс
                        esp.BoxFill.Visible = Config.ESP.Enabled and Config.ESP.Boxes
                        esp.BoxFill.Color = color
                        esp.BoxFill.Position = Vector2.new(boxX, boxY)
                        esp.BoxFill.Size = Vector2.new(boxWidth, boxHeight)
                        
                        -- Имя игрока
                        esp.Name.Visible = Config.ESP.Enabled and Config.ESP.Names
                        esp.Name.Color = color
                        esp.Name.Position = Vector2.new(headPos.X, boxY - 25)
                        esp.Name.Text = player.Name
                        
                        -- Здоровье
                        esp.Health.Visible = Config.ESP.Enabled and Config.ESP.Health
                        esp.Health.Color = color
                        esp.Health.Position = Vector2.new(headPos.X, boxY + boxHeight + 5)
                        esp.Health.Text = "❤️ " .. math.floor(health)
                        
                        -- Дистанция
                        esp.Distance.Visible = Config.ESP.Enabled and Config.ESP.Distance
                        esp.Distance.Color = color
                        esp.Distance.Position = Vector2.new(headPos.X, boxY + boxHeight + 22)
                        esp.Distance.Text = math.floor(distance) .. "m"
                        
                        -- Оружие
                        esp.Weapon.Visible = Config.ESP.Enabled and Config.ESP.Weapon
                        esp.Weapon.Color = color
                        esp.Weapon.Position = Vector2.new(headPos.X, boxY + boxHeight + 39)
                        esp.Weapon.Text = "🔫 " .. getPlayerWeapon(player)
                        
                        -- Health Bar
                        if Config.ESP.HealthBar then
                            local barWidth = boxWidth
                            local barHeight = 4
                            local barX = boxX
                            local barY = boxY - 8
                            
                            esp.HealthBarBg.Visible = true
                            esp.HealthBarBg.Position = Vector2.new(barX, barY)
                            esp.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
                            
                            esp.HealthBar.Visible = true
                            esp.HealthBar.Color = color
                            esp.HealthBar.Position = Vector2.new(barX, barY)
                            esp.HealthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                        else
                            esp.HealthBarBg.Visible = false
                            esp.HealthBar.Visible = false
                        end
                        
                        -- Трассировка
                        if Config.ESP.Tracers then
                            esp.Tracer.Visible = true
                            esp.Tracer.Color = color
                            esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            esp.Tracer.To = Vector2.new(headPos.X, headPos.Y)
                        else
                            esp.Tracer.Visible = false
                        end
                        
                        -- Точка на голове
                        esp.HeadDot.Visible = Config.ESP.Enabled
                        esp.HeadDot.Color = color
                        esp.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                        esp.HeadDot.Radius = 3 * scale
                        
                        -- Скелет
                        updateSkeleton(player, esp)
                        
                    else
                        -- Скрываем все элементы если игрок не на экране
                        for name, drawing in pairs(esp) do
                            if name ~= "Skeleton" then
                                drawing.Visible = false
                            end
                        end
                        for _, bone in pairs(esp.Skeleton) do
                            bone.Visible = false
                        end
                    end
                else
                    for name, drawing in pairs(esp) do
                        if name ~= "Skeleton" then
                            drawing.Visible = false
                        end
                    end
                    for _, bone in pairs(esp.Skeleton) do
                        bone.Visible = false
                    end
                end
            else
                for name, drawing in pairs(esp) do
                    if name ~= "Skeleton" then
                        drawing.Visible = false
                    end
                end
                for _, bone in pairs(esp.Skeleton) do
                    bone.Visible = false
                end
            end
        end
    end)
    
    -- Инициализация ESP для всех игроков
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            createESP(player)
        end
    end
    
    players.PlayerAdded:Connect(createESP)
    players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            for name, drawing in pairs(espObjects[player]) do
                if name == "Skeleton" then
                    for _, bone in pairs(drawing) do
                        bone:Remove()
                    end
                else
                    drawing:Remove()
                end
            end
            espObjects[player] = nil
        end
    end)
end

-- === ЛУЧШИЙ AIMBOT ДЛЯ МОБИЛЬНЫХ ===
local function InitializeProAimBot()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local camera = workspace.CurrentCamera
    local runService = game:GetService("RunService")
    local userInputService = game:GetService("UserInputService")
    
    -- Визуальные элементы
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Color = Color3.new(1, 1, 1)
    fovCircle.Thickness = 2
    fovCircle.Filled = false
    fovCircle.NumSides = 64
    
    local targetDot = Drawing.new("Circle")
    targetDot.Visible = false
    targetDot.Color = Color3.new(1, 0, 0)
    targetDot.Thickness = 2
    targetDot.Filled = true
    targetDot.Radius = 3
    
    local crosshair = Drawing.new("Circle")
    crosshair.Visible = false
    crosshair.Color = Color3.new(1, 1, 1)
    crosshair.Thickness = 2
    crosshair.Filled = false
    crosshair.Radius = 6
    
    -- Утилиты
    local function findBestTarget()
        local bestTarget = nil
        local bestScore = 0
        local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
                
                if humanoid and humanoid.Health > 0 and head then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        local distance = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        
                        if distance <= Config.AimBot.AimFOV then
                            -- Система оценки целей
                            local score = 0
                            
                            -- Близость к центру экрана
                            score = score + (1 - distance / Config.AimBot.AimFOV) * 100
                            
                            -- Здоровье (предпочтение раненым целям)
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            score = score + (1 - healthPercent) * 50
                            
                            -- Дистанция (предпочтение ближним целям)
                            local worldDistance = (head.Position - camera.CFrame.Position).Magnitude
                            score = score + (1 - math.min(worldDistance / 100, 1)) * 30
                            
                            if score > bestScore then
                                bestScore = score
                                bestTarget = head
                            end
                        end
                    end
                end
            end
        end
        
        return bestTarget
    end
    
    local function smoothAim(targetPos, currentPos, smoothness)
        local delta = (targetPos - currentPos) * smoothness
        return currentPos + delta
    end
    
    -- Основной цикл аимбота
    runService.RenderStepped:Connect(function()
        -- Обновляем визуальные элементы
        fovCircle.Visible = Config.AimBot.Enabled
        fovCircle.Radius = Config.AimBot.AimFOV
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        
        crosshair.Visible = Config.Visuals.Crosshair
        crosshair.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        
        -- Логика аимбота
        if Config.AimBot.Enabled then
            local target = findBestTarget()
            
            if target then
                local screenPos = camera:WorldToViewportPoint(target.Position)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                
                -- Показываем индикатор цели
                targetDot.Visible = true
                targetDot.Position = targetPos
                
                -- Авто-прицеливание
                if Config.AimBot.AutoAim then
                    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local smoothedPos = smoothAim(targetPos, mousePos, Config.AimBot.Smoothness)
                    
                    -- Для мобильных эмулируем касание
                    if userInputService.TouchEnabled then
                        -- Мобильное прицеливание (упрощенное)
                        local delta = (targetPos - mousePos) * 0.1
                        -- Здесь может быть логика для мобильного управления
                    end
                end
                
                -- Триггербот
                if Config.AimBot.TriggerBot then
                    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local distance = (targetPos - mousePos).Magnitude
                    
                    if distance < 10 then  -- Маленький радиус для точности
                        -- Авто-стрельба
                        if localPlayer.Character then
                            local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                -- Эмуляция выстрела
                                local remote = tool:FindFirstChildOfClass("RemoteEvent")
                                if remote then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                end
            else
                targetDot.Visible = false
            end
        else
            targetDot.Visible = false
        end
    end)
    
    -- Обработка касаний для мобильных
    if userInputService.TouchEnabled then
        userInputService.TouchStarted:Connect(function(touch, gameProcessed)
            if gameProcessed then return end
            
            if Config.AimBot.Enabled and not Config.AimBot.AutoAim then
                local target = findBestTarget()
                if target then
                    -- Логика ручного прицеливания по касанию
                    -- (можно добавить специальную кнопку для прицеливания)
                end
            end
        end)
    end
end

-- === МОБИЛЬНЫЙ ИНТЕРФЕЙС ===
local function CreateMobileInterface()
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "MobileAimBotMenu"
    mainGui.Parent = game:GetService("CoreGui")
    mainGui.Enabled = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 80, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Заголовок
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎯 Mobile AimBot Pro"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Контент
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    contentFrame.Parent = mainFrame
    
    -- Функция создания переключателя
    local function CreateToggle(parent, name, configCategory, configKey, yPosition)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -20, 0, 35)
        toggleFrame.Position = UDim2.new(0, 10, 0, yPosition)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 25)
        toggle.Position = UDim2.new(0.7, 0, 0.5, -12)
        toggle.BackgroundColor3 = Config[configCategory][configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 80)
        toggle.Text = ""
        toggle.BorderSizePixel = 0
        toggle.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 12)
        toggleCorner.Parent = toggle
        
        local toggleIndicator = Instance.new("Frame")
        toggleIndicator.Size = UDim2.new(0, 21, 0, 21)
        toggleIndicator.Position = UDim2.new(0, Config[configCategory][configKey] and 27 or 2, 0.5, -10)
        toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleIndicator.BorderSizePixel = 0
        toggleIndicator.Parent = toggle
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = toggleIndicator
        
        toggle.MouseButton1Click:Connect(function()
            Config[configCategory][configKey] = not Config[configCategory][configKey]
            toggle.BackgroundColor3 = Config[configCategory][configKey] and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 80)
            
            toggleIndicator:TweenPosition(
                UDim2.new(0, Config[configCategory][configKey] and 27 or 2, 0.5, -10),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.15,
                true
            )
        end)
        
        return toggleFrame
    end
    
    -- Добавляем элементы управления
    local yPosition = 15
    
    -- ESP настройки
    CreateToggle(contentFrame, "📱 ESP Enabled", "ESP", "Enabled", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "🟦 Boxes", "ESP", "Boxes", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "👤 Names", "ESP", "Names", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "❤️ Health", "ESP", "Health", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "📏 Distance", "ESP", "Distance", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "🔫 Weapon", "ESP", "Weapon", yPosition); yPosition = yPosition + 40
    
    -- AimBot настройки
    CreateToggle(contentFrame, "🎯 AimBot", "AimBot", "Enabled", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "🤖 Auto Aim", "AimBot", "AutoAim", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "🔫 TriggerBot", "AimBot", "TriggerBot", yPosition); yPosition = yPosition + 40
    
    -- Визуальные настройки
    CreateToggle(contentFrame, "🌫️ No Fog", "Visuals", "NoFog", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "💡 Full Bright", "Visuals", "FullBright", yPosition); yPosition = yPosition + 40
    CreateToggle(contentFrame, "🎯 Crosshair", "Visuals", "Crosshair", yPosition); yPosition = yPosition + 40
    
    -- Обработчики кнопок
    closeBtn.MouseButton1Click:Connect(function()
        mainGui.Enabled = false
    end)
    
    return mainGui
end

-- === ОСНОВНАЯ ФУНКЦИЯ ===
local function Main()
    print("╔══════════════════════════════╗")
    print("║     Mobile AimBot Pro        ║")
    print("║      Created by Kast13l      ║")
    print("║     Optimized for Phone      ║")
    print("╚══════════════════════════════╝")
    
    -- Создаем интерфейс
    local floatingButton, mainButton = CreateMobileButton()
    local mainUI = CreateMobileInterface()
    
    -- Обработчик плавающей кнопки
    mainButton.MouseButton1Click:Connect(function()
        mainUI.Enabled = not mainUI.Enabled
    end)
    
    -- Инициализация функций
    InitializeProESP()
    InitializeProAimBot()
    
    -- Визуальные улучшения
    local function ApplyVisualEnhancements()
        game:GetService("RunService").Heartbeat:Connect(function()
            if Config.Visuals.NoFog then
                game:GetService("Lighting").FogEnd = 1000000
            end
            
            if Config.Visuals.FullBright then
                game:GetService("Lighting").GlobalShadows = false
            end
        end)
    end
    
    ApplyVisualEnhancements()
    
    print("[MobileAimBot] 🎯 Best ESP & AimBot loaded!")
    print("[MobileAimBot] 📱 Optimized for mobile devices")
    print("[MobileAimBot] 👆 Click the blue button to open menu")
    print("[MobileAimBot] 🎮 Features: Pro ESP, Smart AimBot, Visuals")
end

-- Запуск
Main()
