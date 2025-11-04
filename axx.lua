-- axx script for hood customs
-- written for hood customs

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://nn.api-minecraft.net/p/raw/pkdjtm5dpd'))()
local SaveManager = loadstring(game:HttpGet('https://nn.api-minecraft.net/p/raw/4yrufv213o'))()

local Window = Library:CreateWindow({
    Title = 'axx',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Aim = Window:AddTab('aim'),
    Visual = Window:AddTab('visual'),
    Settings = Window:AddTab('settings'),
}

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

-- Visual Tab
local VisualLeft = Tabs.Visual:AddLeftGroupbox('esp')
local VisualRight = Tabs.Visual:AddRightGroupbox('customization')

-- ESP Variables
local ESPObjects = {}
local ESPEnabled = false
local ESPBoxes = false
local ESPNames = false
local ESPDistance = false
local ESPHealth = false
local ESPTracers = false
local ESPChams = false

-- CSGO Style ESP Functions
local function createESP(player)
    if player == LocalPlayer then return end
    
    local espObject = {
        Player = player,
        BoxLines = {}, -- Store all 8 corner lines
        NameLabel = nil,
        DistanceLabel = nil,
        HealthBar = nil,
        HealthBarOutline = nil,
        Tracer = nil,
        Chams = {}
    }
    
    -- Get colors from Options if they exist (black and white only)
    local boxColor = Options.BoxColor and Options.BoxColor.Value or Color3.fromRGB(255, 255, 255)
    local nameColor = Options.NameColor and Options.NameColor.Value or Color3.fromRGB(255, 255, 255)
    local tracerColor = Options.TracerColor and Options.TracerColor.Value or Color3.fromRGB(255, 255, 255)
    local chamsColor = Options.ChamsColor and Options.ChamsColor.Value or Color3.fromRGB(255, 255, 255)
    local boxThickness = 1
    
    -- Create CSGO Style Corner Box (8 lines for 4 corners - 2 per corner)
    if ESPBoxes then
        for i = 1, 8 do
            local line = Drawing.new('Line')
            line.Visible = false
            line.Color = boxColor
            line.Thickness = boxThickness
            line.Transparency = 1
            table.insert(espObject.BoxLines, line)
        end
    end
    
    -- Create Name Label
    if ESPNames then
        espObject.NameLabel = Drawing.new('Text')
        espObject.NameLabel.Visible = false
        espObject.NameLabel.Text = player.Name
        espObject.NameLabel.Color = nameColor
        espObject.NameLabel.Size = 14
        espObject.NameLabel.Outline = true
        espObject.NameLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
        espObject.NameLabel.Center = false
    end
    
    -- Create Distance Label
    if ESPDistance then
        espObject.DistanceLabel = Drawing.new('Text')
        espObject.DistanceLabel.Visible = false
        espObject.DistanceLabel.Color = Color3.fromRGB(255, 255, 255)
        espObject.DistanceLabel.Size = 12
        espObject.DistanceLabel.Outline = true
        espObject.DistanceLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
        espObject.DistanceLabel.Center = false
    end
    
    -- Create Health Bar (CSGO style - left side, no text)
    if ESPHealth then
        espObject.HealthBarOutline = Drawing.new('Square')
        espObject.HealthBarOutline.Visible = false
        espObject.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
        espObject.HealthBarOutline.Thickness = 1
        espObject.HealthBarOutline.Transparency = 1
        espObject.HealthBarOutline.Filled = true
        
        espObject.HealthBar = Drawing.new('Square')
        espObject.HealthBar.Visible = false
        espObject.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        espObject.HealthBar.Thickness = 1
        espObject.HealthBar.Transparency = 1
        espObject.HealthBar.Filled = true
    end
    
    -- Create Tracer
    if ESPTracers then
        espObject.Tracer = Drawing.new('Line')
        espObject.Tracer.Visible = false
        espObject.Tracer.Color = tracerColor
        espObject.Tracer.Thickness = 1
        espObject.Tracer.Transparency = 1
    end
    
    ESPObjects[player] = espObject
end

local function removeESP(player)
    if ESPObjects[player] then
        local espObject = ESPObjects[player]
        
        for _, line in pairs(espObject.BoxLines) do
            line:Remove()
        end
        if espObject.NameLabel then espObject.NameLabel:Remove() end
        if espObject.DistanceLabel then espObject.DistanceLabel:Remove() end
        if espObject.HealthBar then espObject.HealthBar:Remove() end
        if espObject.HealthBarOutline then espObject.HealthBarOutline:Remove() end
        if espObject.Tracer then espObject.Tracer:Remove() end
        for _, cham in pairs(espObject.Chams) do
            cham:Destroy()
        end
        
        ESPObjects[player] = nil
    end
end

local function getBoundingBox(character)
    local parts = {}
    for _, part in pairs(character:GetChildren()) do
        if part:IsA('BasePart') and part.Name ~= 'HumanoidRootPart' then
            table.insert(parts, part)
        end
    end
    
    if #parts == 0 then return nil, nil end
    
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    
    for _, part in pairs(parts) do
        local cf = part.CFrame
        local size = part.Size
        local corners = {
            cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2).Position,
            cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2).Position,
            cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2).Position,
            cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2).Position,
            cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2).Position,
            cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2).Position,
            cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2).Position,
            cf * CFrame.new(size.X/2, size.Y/2, size.Z/2).Position,
        }
        
        for _, corner in pairs(corners) do
            local screenPos = Camera:WorldToViewportPoint(corner)
            if screenPos.Z > 0 then
                minX = math.min(minX, screenPos.X)
                maxX = math.max(maxX, screenPos.X)
                minY = math.min(minY, screenPos.Y)
                maxY = math.max(maxY, screenPos.Y)
            end
        end
    end
    
    if minX == math.huge then return nil, nil end
    
    local topLeft = Vector2.new(minX, minY)
    local bottomRight = Vector2.new(maxX, maxY)
    local size = bottomRight - topLeft
    
    return topLeft, size
end

local function updateESP()
    if not ESPEnabled then return end
    
    local cameraPos = Camera.CFrame.Position
    local screenSize = Camera.ViewportSize
    
    for player, espObject in pairs(ESPObjects) do
        local character = player.Character
        if not character then
            removeESP(player)
            continue
        end
        
        local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
            continue
        end
        
        local topLeft, size = getBoundingBox(character)
        
        if topLeft and size then
            local distance = (cameraPos - humanoidRootPart.Position).Magnitude
            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local healthPercent = math.clamp(health / maxHealth, 0, 1)
            
            -- Update CSGO Style Corner Box (8 lines for 4 corners)
            if ESPBoxes and #espObject.BoxLines == 8 then
                local cornerSize = 12
                local lines = espObject.BoxLines
                
                -- Top Left Corner (horizontal + vertical)
                lines[1].From = topLeft
                lines[1].To = topLeft + Vector2.new(cornerSize, 0)
                lines[1].Visible = true
                lines[2].From = topLeft
                lines[2].To = topLeft + Vector2.new(0, cornerSize)
                lines[2].Visible = true
                
                -- Top Right Corner (horizontal + vertical)
                lines[3].From = topLeft + Vector2.new(size.X, 0)
                lines[3].To = topLeft + Vector2.new(size.X - cornerSize, 0)
                lines[3].Visible = true
                lines[4].From = topLeft + Vector2.new(size.X, 0)
                lines[4].To = topLeft + Vector2.new(size.X, cornerSize)
                lines[4].Visible = true
                
                -- Bottom Left Corner (horizontal + vertical)
                lines[5].From = topLeft + Vector2.new(0, size.Y)
                lines[5].To = topLeft + Vector2.new(cornerSize, size.Y)
                lines[5].Visible = true
                lines[6].From = topLeft + Vector2.new(0, size.Y)
                lines[6].To = topLeft + Vector2.new(0, size.Y - cornerSize)
                lines[6].Visible = true
                
                -- Bottom Right Corner (horizontal + vertical)
                lines[7].From = topLeft + Vector2.new(size.X, size.Y)
                lines[7].To = topLeft + Vector2.new(size.X - cornerSize, size.Y)
                lines[7].Visible = true
                lines[8].From = topLeft + Vector2.new(size.X, size.Y)
                lines[8].To = topLeft + Vector2.new(size.X, size.Y - cornerSize)
                lines[8].Visible = true
            elseif #espObject.BoxLines > 0 then
                for _, line in pairs(espObject.BoxLines) do
                    line.Visible = false
                end
            end
            
            -- Update Name Label
            if espObject.NameLabel and ESPNames then
                espObject.NameLabel.Position = topLeft + Vector2.new(size.X / 2, -18)
                espObject.NameLabel.Center = true
                espObject.NameLabel.Visible = true
            elseif espObject.NameLabel then
                espObject.NameLabel.Visible = false
            end
            
            -- Update Distance Label
            if espObject.DistanceLabel and ESPDistance then
                espObject.DistanceLabel.Position = topLeft + Vector2.new(size.X / 2, size.Y + 2)
                espObject.DistanceLabel.Text = math.floor(distance) .. ' studs'
                espObject.DistanceLabel.Center = true
                espObject.DistanceLabel.Visible = true
            elseif espObject.DistanceLabel then
                espObject.DistanceLabel.Visible = false
            end
            
            -- Update Health Bar (CSGO style - left side)
            if espObject.HealthBar and ESPHealth then
                local barWidth = 3
                local barHeight = size.Y
                local barX = topLeft.X - 8
                local barY = topLeft.Y
                
                -- Health bar outline
                espObject.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight)
                espObject.HealthBarOutline.Position = Vector2.new(barX - 1, barY)
                espObject.HealthBarOutline.Visible = true
                
                -- Health bar (green to red based on health)
                local healthColor = Color3.fromRGB(
                    255 - (healthPercent * 255),
                    healthPercent * 255,
                    0
                )
                espObject.HealthBar.Color = healthColor
                espObject.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
                espObject.HealthBar.Position = Vector2.new(barX, barY + (barHeight * (1 - healthPercent)))
                espObject.HealthBar.Visible = true
            elseif espObject.HealthBar then
                espObject.HealthBar.Visible = false
                espObject.HealthBarOutline.Visible = false
            end
            
            -- Update Tracer
            if espObject.Tracer and ESPTracers then
                espObject.Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                espObject.Tracer.To = Vector2.new(topLeft.X + size.X / 2, topLeft.Y + size.Y)
                espObject.Tracer.Visible = true
            elseif espObject.Tracer then
                espObject.Tracer.Visible = false
            end
        else
            -- Hide all if off screen
            for _, line in pairs(espObject.BoxLines) do
                line.Visible = false
            end
            if espObject.NameLabel then espObject.NameLabel.Visible = false end
            if espObject.DistanceLabel then espObject.DistanceLabel.Visible = false end
            if espObject.HealthBar then espObject.HealthBar.Visible = false end
            if espObject.HealthBarOutline then espObject.HealthBarOutline.Visible = false end
            if espObject.Tracer then espObject.Tracer.Visible = false end
        end
    end
end

-- ESP Toggles
VisualLeft:AddToggle('ESPEnabled', {
    Text = 'esp enabled',
    Default = false,
    Tooltip = 'enable/disable esp',
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            for player, _ in pairs(ESPObjects) do
                removeESP(player)
            end
        end
    end
})

VisualLeft:AddToggle('ESPBoxes', {
    Text = 'box esp',
    Default = true,
    Tooltip = 'show box around players',
    Callback = function(Value)
        ESPBoxes = Value
        -- Create boxes for existing ESP objects if toggled on
        if Value then
            for player, espObject in pairs(ESPObjects) do
                if #espObject.BoxLines == 0 and player.Character then
                    local boxColor = Options.BoxColor and Options.BoxColor.Value or Color3.fromRGB(255, 255, 255)
                    local boxThickness = 1
                    for i = 1, 8 do
                        local line = Drawing.new('Line')
                        line.Visible = false
                        line.Color = boxColor
                        line.Thickness = boxThickness
                        line.Transparency = 1
                        table.insert(espObject.BoxLines, line)
                    end
                end
            end
        end
    end
})

VisualLeft:AddToggle('ESPNames', {
    Text = 'name esp',
    Default = true,
    Tooltip = 'show player names',
    Callback = function(Value)
        ESPNames = Value
    end
})

VisualLeft:AddToggle('ESPDistance', {
    Text = 'distance esp',
    Default = true,
    Tooltip = 'show distance to players',
    Callback = function(Value)
        ESPDistance = Value
    end
})

VisualLeft:AddToggle('ESPHealth', {
    Text = 'health esp',
    Default = true,
    Tooltip = 'show player health',
    Callback = function(Value)
        ESPHealth = Value
    end
})

VisualLeft:AddToggle('ESPTracers', {
    Text = 'tracers',
    Default = false,
    Tooltip = 'show line from center of screen to player',
    Callback = function(Value)
        ESPTracers = Value
        -- Create tracers for existing ESP objects if toggled on
        if Value then
            for player, espObject in pairs(ESPObjects) do
                if not espObject.Tracer and player.Character then
                    local tracerColor = Options.TracerColor and Options.TracerColor.Value or Color3.fromRGB(255, 255, 255)
                    espObject.Tracer = Drawing.new('Line')
                    espObject.Tracer.Visible = false
                    espObject.Tracer.Color = tracerColor
                    espObject.Tracer.Thickness = 1
                    espObject.Tracer.Transparency = 1
                end
            end
        end
    end
})

VisualLeft:AddToggle('ESPChams', {
    Text = 'chams',
    Default = false,
    Tooltip = 'highlight player parts',
    Callback = function(Value)
        ESPChams = Value
        -- Update chams for all existing players
        for player, espObject in pairs(ESPObjects) do
            if Value then
                -- Add chams
                if player.Character then
                    local chamsColor = Options.ChamsColor and Options.ChamsColor.Value or Color3.fromRGB(255, 255, 255)
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA('BasePart') and part.Name ~= 'HumanoidRootPart' then
                            local highlight = Instance.new('Highlight')
                            highlight.Adornee = part
                            highlight.FillColor = chamsColor
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.OutlineTransparency = 0
                            highlight.Parent = part
                            table.insert(espObject.Chams, highlight)
                        end
                    end
                end
            else
                -- Remove chams
                for _, cham in pairs(espObject.Chams) do
                    cham:Destroy()
                end
                espObject.Chams = {}
            end
        end
    end
})

-- ESP Customization
VisualRight:AddLabel('box color'):AddColorPicker('BoxColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'box color',
    Callback = function(Value)
        for _, espObject in pairs(ESPObjects) do
            for _, line in pairs(espObject.BoxLines) do
                line.Color = Value
            end
        end
    end
})

VisualRight:AddLabel('name color'):AddColorPicker('NameColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'name color',
    Callback = function(Value)
        for _, espObject in pairs(ESPObjects) do
            if espObject.NameLabel then
                espObject.NameLabel.Color = Value
            end
        end
    end
})

VisualRight:AddLabel('tracer color'):AddColorPicker('TracerColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'tracer color',
    Callback = function(Value)
        for _, espObject in pairs(ESPObjects) do
            if espObject.Tracer then
                espObject.Tracer.Color = Value
            end
        end
    end
})

VisualRight:AddLabel('chams color'):AddColorPicker('ChamsColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'chams color',
    Callback = function(Value)
        for _, espObject in pairs(ESPObjects) do
            for _, cham in pairs(espObject.Chams) do
                cham.FillColor = Value
            end
        end
    end
})


-- Visual Features (Neverlose style)
local VisualFeatures = Tabs.Visual:AddRightGroupbox('visual features')

local Lighting = game:GetService('Lighting')
local originalColorShiftTop = Lighting.ColorShift_Top
local originalColorShiftBottom = Lighting.ColorShift_Bottom

-- Ambience Changer
local ambienceConnection = nil
VisualFeatures:AddToggle('AmbienceEnabled', {
    Text = 'ambience changer',
    Default = false,
    Tooltip = 'change world ambience colors',
    Callback = function(Value)
        if Value then
            if not ambienceConnection then
                ambienceConnection = RunService.Heartbeat:Connect(function()
                    if Toggles.AmbienceEnabled.Value then
                        Lighting.ColorShift_Top = Options.AmbienceTop.Value
                        Lighting.ColorShift_Bottom = Options.AmbienceBottom.Value
                    else
                        ambienceConnection:Disconnect()
                        ambienceConnection = nil
                    end
                end)
            end
        else
            if ambienceConnection then
                ambienceConnection:Disconnect()
                ambienceConnection = nil
            end
            Lighting.ColorShift_Top = originalColorShiftTop
            Lighting.ColorShift_Bottom = originalColorShiftBottom
        end
    end
})

VisualFeatures:AddLabel('ambience top'):AddColorPicker('AmbienceTop', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'ambience top color'
})

VisualFeatures:AddLabel('ambience bottom'):AddColorPicker('AmbienceBottom', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'ambience bottom color'
})

-- Self Forcefield (Material Changer)
local forcefieldParts = {}
local lastCharacter = nil
VisualFeatures:AddToggle('ForcefieldEnabled', {
    Text = 'self forcefield',
    Default = false,
    Tooltip = 'change material of your character parts',
    Callback = function(Value)
        if not Value then
            -- Restore original materials
            for part, originalMaterial in pairs(forcefieldParts) do
                if part and part.Parent then
                    part.Material = originalMaterial
                end
            end
            forcefieldParts = {}
            lastCharacter = nil
        end
    end
})

VisualFeatures:AddDropdown('ForcefieldMaterial', {
    Values = {'Plastic', 'SmoothPlastic', 'Neon', 'Glass', 'Metal', 'ForceField', 'Diamond'},
    Default = 1,
    Text = 'forcefield material',
    Tooltip = 'material for forcefield'
})

-- Update forcefield for character parts
task.spawn(function()
    while true do
        if Toggles.ForcefieldEnabled.Value then
            local character = LocalPlayer.Character
            if character and character ~= lastCharacter then
                -- Character respawned, clear old parts
                forcefieldParts = {}
                lastCharacter = character
            end
            
            if character then
                local material = Enum.Material[Options.ForcefieldMaterial.Value]
                
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA('BasePart') and part.Name ~= 'HumanoidRootPart' then
                        if not forcefieldParts[part] then
                            forcefieldParts[part] = part.Material
                        end
                        part.Material = material
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Animation Player
local animationTrack = nil
VisualFeatures:AddToggle('AnimationEnabled', {
    Text = 'animation player',
    Default = false,
    Tooltip = 'play animations on your character (client side only)',
    Callback = function(Value)
        if not Value then
            if animationTrack then
                animationTrack:Stop()
                animationTrack = nil
            end
        end
    end
})

VisualFeatures:AddInput('AnimationId', {
    Default = '',
    Numeric = false,
    Finished = false,
    Text = 'animation id',
    Tooltip = 'roblox animation id',
    Placeholder = 'enter animation id',
    Callback = function(Value)
        if Toggles.AnimationEnabled.Value and Value and Value ~= '' then
            local animId = tonumber(Value)
            if animId and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
                local animator = humanoid:FindFirstChildOfClass('Animator')
                if not animator then
                    animator = Instance.new('Animator')
                    animator.Parent = humanoid
                end
                
                if animationTrack then
                    animationTrack:Stop()
                end
                
                local animation = Instance.new('Animation')
                animation.AnimationId = 'rbxassetid://' .. animId
                animationTrack = animator:LoadAnimation(animation)
                animationTrack:Play()
            end
        end
    end
})

Options.AnimationId:OnChanged(function()
    if Toggles.AnimationEnabled.Value and Options.AnimationId.Value and Options.AnimationId.Value ~= '' then
        local animId = tonumber(Options.AnimationId.Value)
        if animId and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
            local animator = humanoid:FindFirstChildOfClass('Animator')
            if not animator then
                animator = Instance.new('Animator')
                animator.Parent = humanoid
            end
            
            if animationTrack then
                animationTrack:Stop()
            end
            
            local animation = Instance.new('Animation')
            animation.AnimationId = 'rbxassetid://' .. animId
            animationTrack = animator:LoadAnimation(animation)
            animationTrack:Play()
        end
    end
end)

-- Aim Tab
local AimLeft = Tabs.Aim:AddLeftGroupbox('aimbot')
local AimRight = Tabs.Aim:AddRightGroupbox('settings')

-- Aim Variables
local CamlockEnabled = false
local AimTarget = nil
local FOV = 100
local Smoothness = 0.5
local TargetPart = 'Head'

-- Get closest player to crosshair
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = FOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then continue end
        
        local targetPart = character:FindFirstChild(TargetPart)
        if not targetPart then continue end
        
        local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(vector.X, vector.Y) - screenCenter).Magnitude
        
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = player
        end
    end
    
    return closestPlayer
end


-- Camlock
local camlockConnection = nil

local function lockOntoPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        AimTarget = targetPlayer
        if not camlockConnection then
            camlockConnection = RunService.Heartbeat:Connect(function()
                if not CamlockEnabled or not AimTarget then
                    if camlockConnection then
                        camlockConnection:Disconnect()
                        camlockConnection = nil
                    end
                    return
                end
                
                if AimTarget.Character then
                    local targetPart = AimTarget.Character:FindFirstChild(TargetPart)
                    if targetPart then
                        local currentCFrame = Camera.CFrame
                        local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPart.Position)
                        Camera.CFrame = currentCFrame:Lerp(targetCFrame, Smoothness)
                    end
                else
                    AimTarget = nil
                end
            end)
        end
    end
end

local function startCamlock()
    if CamlockEnabled and not AimTarget then
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            lockOntoPlayer(closestPlayer)
        end
    elseif CamlockEnabled and AimTarget then
        -- Already locked onto a player, just start the connection if not already running
        if not camlockConnection then
            camlockConnection = RunService.Heartbeat:Connect(function()
                if not CamlockEnabled or not AimTarget then
                    if camlockConnection then
                        camlockConnection:Disconnect()
                        camlockConnection = nil
                    end
                    return
                end
                
                if AimTarget.Character then
                    local targetPart = AimTarget.Character:FindFirstChild(TargetPart)
                    if targetPart then
                        local currentCFrame = Camera.CFrame
                        local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPart.Position)
                        Camera.CFrame = currentCFrame:Lerp(targetCFrame, Smoothness)
                    end
                else
                    AimTarget = nil
                end
            end)
        end
    end
end

-- Aim Toggles
local CamlockToggle = AimLeft:AddToggle('CamlockEnabled', {
    Text = 'camlock',
    Default = false,
    Tooltip = 'lock camera to target',
    Callback = function(Value)
        CamlockEnabled = Value
        if Value then
            -- If we have a target, start camlock
            if AimTarget then
                startCamlock()
            end
        else
            -- Disable camlock
            if camlockConnection then
                camlockConnection:Disconnect()
                camlockConnection = nil
            end
            AimTarget = nil -- Clear target when disabled
        end
    end
})

-- Keybind to lock/unlock (toggle)
CamlockToggle:AddKeyPicker('LockKeybind', {
    Default = 'E',
    Mode = 'Toggle',
    Text = 'lock/unlock to closest player',
    NoUI = false
})

Options.LockKeybind:OnClick(function()
    if AimTarget then
        -- Unlock if we have a target
        AimTarget = nil
        if camlockConnection then
            camlockConnection:Disconnect()
            camlockConnection = nil
        end
        if CamlockEnabled then
            Toggles.CamlockEnabled:SetValue(false)
        end
    else
        -- Lock onto closest player
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            AimTarget = closestPlayer
            if not CamlockEnabled then
                Toggles.CamlockEnabled:SetValue(true)
            else
                startCamlock()
            end
        end
    end
end)


-- Aim Settings
AimRight:AddSlider('FOVSlider', {
    Text = 'fov',
    Default = 100,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        FOV = Value
    end
})

AimRight:AddSlider('SmoothnessSlider', {
    Text = 'smoothness',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        Smoothness = Value
    end
})

AimRight:AddDropdown('TargetPartDropdown', {
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'},
    Default = 1,
    Text = 'target part',
    Tooltip = 'part to aim at',
    Callback = function(Value)
        TargetPart = Value
    end
})

-- FOV Circle (create before color picker)
local FOVCircleEnabled = false
local FOVCircle = Drawing.new('Circle')
FOVCircle.Visible = false
FOVCircle.Radius = FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

AimRight:AddLabel('fov circle'):AddColorPicker('FOVCircleColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'fov circle color',
    Callback = function(Value)
        if FOVCircle then
            FOVCircle.Color = Value
        end
    end
})

AimRight:AddToggle('FOVCircleEnabled', {
    Text = 'show fov circle',
    Default = false,
    Tooltip = 'display fov circle',
    Callback = function(Value)
        FOVCircleEnabled = Value
        FOVCircle.Visible = Value
    end
})

-- Update FOV Circle
task.spawn(function()
    while true do
        if FOVCircleEnabled then
            FOVCircle.Radius = FOV
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
        task.wait()
    end
end)

-- Player added/removed handlers
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        task.wait(1) -- Wait for character to load
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Initialize ESP for existing players
task.spawn(function()
    task.wait(2)
    for _, player in pairs(Players:GetPlayers()) do
        if ESPEnabled and player ~= LocalPlayer then
            createESP(player)
        end
    end
end)

-- ESP Update Loop
task.spawn(function()
    while true do
        if ESPEnabled then
            -- Create ESP for players that don't have it
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not ESPObjects[player] then
                    if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
                        createESP(player)
                    end
                end
            end
            updateESP()
        end
        task.wait()
    end
end)

-- UI Settings
local MenuGroup = Tabs.Settings:AddLeftGroupbox('menu')

MenuGroup:AddButton('unload', function() Library:Unload() end)
MenuGroup:AddLabel('menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'LockKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('axx')
SaveManager:SetFolder('axx/hood-customs')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs.Settings)

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs.Settings)

-- Set default theme to black and white after theme manager is set up
task.spawn(function()
    task.wait(0.5) -- Wait for theme manager to initialize
    if Options.BackgroundColor and Options.MainColor and Options.AccentColor then
        Options.BackgroundColor:SetValueRGB(Color3.fromRGB(20, 20, 20))
        Options.MainColor:SetValueRGB(Color3.fromRGB(255, 255, 255))
        Options.AccentColor:SetValueRGB(Color3.fromRGB(255, 255, 255))
        Options.OutlineColor:SetValueRGB(Color3.fromRGB(0, 0, 0))
        Options.FontColor:SetValueRGB(Color3.fromRGB(255, 255, 255))
        ThemeManager:ThemeUpdate()
    end
end)

SaveManager:LoadAutoloadConfig()

-- Watermark
Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    
    Library:SetWatermark(('axx | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library.KeybindFrame.Visible = true

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    
    -- Clean up ESP
    for player, _ in pairs(ESPObjects) do
        removeESP(player)
    end
    
    -- Clean up camlock
    if camlockConnection then
        camlockConnection:Disconnect()
    end
    
    -- Clean up FOV circle
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    print('unloaded!')
    Library.Unloaded = true
end)

