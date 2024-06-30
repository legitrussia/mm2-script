local uilibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/cueshut/saves/main/criminality%20paste%20ui%20library'))()

-- // Window \\ --
local window = uilibrary.new('Shoot Scripts', 'leadmarker')

-- // Tabs \\ --
local aimbotTab = window.new_tab('rbxassetid://4483345998')
local espTab = window.new_tab('rbxassetid://4483345998')

-- // Sections \\ --
local aimbotSection = aimbotTab.new_section('Aimbot')
local espSection = espTab.new_section('ESP')

-- // Services and Variables \\ --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Holding = false
local MenuOpen = true

_G.AimbotEnabled = false
_G.TeamCheck = false -- Se definido como true, o script só travará sua mira nos membros da equipe inimiga.
_G.AimPart = "Head" -- Onde o script de aimbot vai travar.
_G.Sensitivity = 0 -- Quantos segundos leva para o script de aimbot travar oficialmente no alvo.
_G.FOV = 50 -- Campo de Visão (em graus)
_G.CircleRadius = 100 -- Raio do círculo de FOV
_G.FOVEnabled = false
_G.NameTagEnabled = false

local FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Color = Color3.new(1, 1, 1)
FOV_CIRCLE.Transparency = 0.7
FOV_CIRCLE.Filled = false
FOV_CIRCLE.Visible = false
FOV_CIRCLE.Thickness = 1

local function updateFOVCircle(radius)
    FOV_CIRCLE.Radius = radius
    print("FOV atualizado para:", radius)
end

local function toggleFOVCircle(enabled)
    FOV_CIRCLE.Visible = enabled
end

local function isInFOV(targetPosition)
    local ScreenPoint = Camera:WorldToScreenPoint(targetPosition)
    local MouseLocation = UserInputService:GetMouseLocation()
    local VectorDistance = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
    
    return VectorDistance <= _G.CircleRadius
end

local function GetClosestPlayer()
    local MaximumDistance = math.huge
    local Target = nil

    coroutine.wrap(function()
        wait(20)
        MaximumDistance = math.huge -- Redefine o MaximumDistance para que o Aimbot não o considere como uma variável muito pequena e pare de capturar jogadores...
    end)()

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and (not _G.TeamCheck or v.Team ~= LocalPlayer.Team) then
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local targetPosition = v.Character[_G.AimPart].Position
                local ScreenPoint = Camera:WorldToScreenPoint(targetPosition)
                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                
                -- Verificar se o jogador está dentro do FOV e calcular a distância 3D
                if isInFOV(targetPosition) then
                    local distance3D = (Camera.CFrame.Position - targetPosition).Magnitude
                    if distance3D < MaximumDistance then
                        Target = v
                        MaximumDistance = distance3D
                    end
                end
            end
        end
    end

    return Target
end

local function ToggleAimbot(enabled)
    _G.AimbotEnabled = enabled
    print("Aimbot ativado:", enabled)
end

local function destroyESP()
    -- Destrua todos os elementos de GUI com o nome 'ESP'
    for _, v in pairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
        if v.Name == 'ESP' then
            v:Destroy()
        end
    end
end

local function EnableESP()
    for i, v in pairs(Players:GetPlayers()) do
        if v.Name ~= Players.LocalPlayer.Name then
            espplr(v)
            v.CharacterAdded:Connect(function(a)
                wait(2)
                espplr(v)
            end)
        end
    end
    Players.PlayerAdded:Connect(function(a)
        a.CharacterAdded:Connect(function()
            wait(2)
            espplr(a)
        end)
    end)
end

local function esp(x, y, z, p)
    local af = createline()
    local ag = createline()
    local ah = createline()
    local ai = createline()
    local aj = createline()
    local ak = createline()
    local al = createline()
    local am = createline()
    coroutine.wrap(function()
        RunService.RenderStepped:Connect(function()
            local an = Camera.CFrame:pointToObjectSpace(x.Position)
            local ao = Camera.CFrame:pointToObjectSpace(y.Position)
            local ap = Camera.CFrame:pointToObjectSpace(z.Position)
            local aq = Camera.CFrame:pointToObjectSpace(p.Position)
            local ar = Camera.ViewportSize / 2
            an = Vector2.new(ar.X + an.X / an.Z * Camera.ViewportSize.X, ar.Y - an.Y / an.Z * Camera.ViewportSize.X)
            ao = Vector2.new(ar.X + ao.X / ao.Z * Camera.ViewportSize.X, ar.Y - ao.Y / ao.Z * Camera.ViewportSize.X)
            ap = Vector2.new(ar.X + ap.X / ap.Z * Camera.ViewportSize.X, ar.Y - ap.Y / ap.Z * Camera.ViewportSize.X)
            aq = Vector2.new(ar.X + aq.X / aq.Z * Camera.ViewportSize.X, ar.Y - aq.Y / aq.Z * Camera.ViewportSize.X)
            af.From = an
            af.To = ao
            ag.From = ao
            ag.To = ap
            ah.From = ap
            ah.To = aq
            ai.From = aq
            ai.To = an
            aj.From = an
            aj.To = ap
            ak.From = ao
            ak.To = aq
            al.From = an
            al.To = ap
            am.From = ao
            am.To = aq
        end)
    end)()
end

local function espplr(p)
    esp(
        p.Character.HumanoidRootPart.CFrame * CFrame.new(2, 3, -2).p,
        p.Character.HumanoidRootPart.CFrame * CFrame.new(-2, 3, -2).p,
        p.Character.HumanoidRootPart.CFrame * CFrame.new(2, -3, -2).p,
        p.Character.HumanoidRootPart.CFrame * CFrame.new(-2, -3, -2).p
    )
end

_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

local Holder = Instance.new("Folder", game.CoreGui)
Holder.Name = "ESP"

local Box = Instance.new("BoxHandleAdornment")
Box.Name = "nilBox"
Box.Size = Vector3.new(1, 2, 1)
Box.Color3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Box.Transparency = 0.7
Box.ZIndex = 0
Box.AlwaysOnTop = false
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Name = "nilNameTag"
NameTag.Enabled = false
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 1.8, 0)
local Tag = Instance.new("TextLabel", NameTag)
Tag.Name = "Tag"
Tag.BackgroundTransparency = 1
Tag.Position = UDim2.new(0, -50, 0, 0)
Tag.Size = UDim2.new(0, 300, 0, 20)
Tag.TextSize = 15
Tag.TextColor3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Tag.TextStrokeColor3 = Color3.new(0 / 255, 0 / 255, 0 / 255)
Tag.TextStrokeTransparency = 0.4
Tag.Text = "nil"
Tag.Font = Enum.Font.SourceSansBold
Tag.TextScaled = false

local LoadCharacter = function(v)
    repeat wait() until v.Character ~= nil
    v.Character:WaitForChild("Humanoid")
    local vHolder = Holder:FindFirstChild(v.Name)
    vHolder:ClearAllChildren()
    local b = Box:Clone()
    b.Name = v.Name .. "Box"
    b.Adornee = v.Character
    b.Parent = vHolder
    local t = NameTag:Clone()
    t.Name = v.Name .. "NameTag"
    t.Enabled = true
    t.Parent = vHolder
    t.Adornee = v.Character:WaitForChild("Head", 5)
    if not t.Adornee then
        return UnloadCharacter(v)
    end
    t.Tag.Text = v.Name
    b.Color3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)
    t.Tag.TextColor3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)
    local Update
    local UpdateNameTag = function()
        if not pcall(function()
            v.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            local maxh = math.floor(v.Character.Humanoid.MaxHealth)
            local h = math.floor(v.Character.Humanoid.Health)
        end) then
            Update:Disconnect()
        end
    end
    UpdateNameTag()
    Update = v.Character.Humanoid.Changed:Connect(UpdateNameTag)
end

local UnloadCharacter = function(v)
    local vHolder = Holder:FindFirstChild(v.Name)
    if vHolder and (vHolder:FindFirstChild(v.Name .. "Box") ~= nil or vHolder:FindFirstChild(v.Name .. "NameTag") ~= nil) then
        vHolder:ClearAllChildren()
    end
end

local LoadPlayer = function(v)
    local vHolder = Instance.new("Folder", Holder)
    vHolder.Name = v.Name
    v.CharacterAdded:Connect(function()
        pcall(LoadCharacter, v)
    end)
    v.CharacterRemoving:Connect(function()
        pcall(UnloadCharacter, v)
    end)
    v.Changed:Connect(function(prop)
        if prop == "TeamColor" then
            UnloadCharacter(v)
            wait()
            LoadCharacter(v)
        end
    end)
    LoadCharacter(v)
end

local UnloadPlayer = function(v)
    UnloadCharacter(v)
    local vHolder = Holder:FindFirstChild(v.Name)
    if vHolder then
        vHolder:Destroy()
    end
end

for i, v in pairs(game:GetService("Players"):GetPlayers()) do
    spawn(function() pcall(LoadPlayer, v) end)
end

game:GetService("Players").PlayerAdded:Connect(function(v)
    pcall(LoadPlayer, v)
end)

game:GetService("Players").PlayerRemoving:Connect(function(v)
    pcall(UnloadPlayer, v)
end)

game:GetService("Players").LocalPlayer.NameDisplayDistance = 0

if _G.Reantheajfdfjdgs then
    return
end

-- // Aimbot Sector \\ --
local aimbotSector = aimbotSection.new_sector('Aimbot', 'Left')

aimbotSector.element('Toggle', 'Aimbot', false, function(state)
    ToggleAimbot(state.Toggle)
end)

aimbotSector.element('Toggle', 'Team Check', false, function(state)
    _G.TeamCheck = state.Toggle
    print("Team Check ativado:", state.Toggle)
end)

aimbotSector.element('Toggle', 'FOV', false, function(state)
    _G.FOVEnabled = state.Toggle
    toggleFOVCircle(state.Toggle)
    print("FOV ativado:", state.Toggle)
end)

aimbotSector.element('Slider', 'Smoothness', {default = {min = 1, max = 10, default = 1}}, function(value)
    _G.Sensitivity = value.Slider / 10
    print("Smoothness set to:", value.Slider)
end)

aimbotSector.element('Dropdown', 'Aim Part', {options = {"Head", "Neck", "Torso"}}, function(selected)
    _G.AimPart = selected.Dropdown
    print("Aim Part set to:", selected.Dropdown)
end)

aimbotSector.element('Slider', 'FOV', {default = {min = 0, max = 180, default = 50}}, function(value)
    _G.FOV = value.Slider
    updateFOVCircle(value.Slider)
    print("FOV set to:", value.Slider)
end)

-- // ESP Sector \\ --
local espSector = espSection.new_sector('ESP', 'Left')

local ESP_ENABLED = false
local ESP_TYPE = ""

espSector.element('Toggle', 'ESP', false, function(state)
    ESP_ENABLED = state.Toggle
    if ESP_ENABLED then
        if ESP_TYPE == "" then
            print("Selecione uma opção de ESP antes de ativar.")
            ESP_ENABLED = false
            return
        end
        destroyESP()
        if ESP_TYPE == "Box 2D" then
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/legitrussia/mm2-script/main/esp%202d.lua"))()
        elseif ESP_TYPE == "Box 3D" then
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/legitrussia/mm2-script/main/esp%203d.lua"))()
        elseif ESP_TYPE == "Glow" then
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/yourusername/yourrepo/main/espglow.lua"))()
        end
        print("ESP ativado:", ESP_TYPE)
    else
        destroyESP()
        print("ESP desativado")
    end
end)

espSector.element('Dropdown', 'ESP Options', {options = {"Box 2D", "Box 3D", "Glow"}}, function(option)
    destroyESP() -- Destrua o ESP ativo antes de ativar o novo
    ESP_TYPE = option.Dropdown
    if ESP_ENABLED then
        if ESP_TYPE == "Box 2D" then
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/legitrussia/mm2-script/main/esp%202d.lua"))()
        elseif ESP_TYPE == "Box 3D" then
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/legitrussia/mm2-script/main/esp%203d.lua"))()
        elseif ESP_TYPE == "Glow" then
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/yourusername/yourrepo/main/espglow.lua"))()
        end
        print("ESP ativado:", ESP_TYPE)
    end
end)

espSector.element('Toggle', 'Name Tag', false, function(state)
    _G.NameTagEnabled = state.Toggle
    if _G.NameTagEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            LoadPlayer(v)
        end
        Players.PlayerAdded:Connect(function(v)
            LoadPlayer(v)
        end)
        Players.PlayerRemoving:Connect(function(v)
            UnloadPlayer(v)
        end)
    else
        Holder:ClearAllChildren()
    end
    print("Name Tag ativado:", state.Toggle)
end)

RunService.RenderStepped:Connect(function()
    if _G.FOVEnabled and FOV_CIRCLE.Visible then
        FOV_CIRCLE.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    end
end)

local function toggleMenu()
    if MenuOpen then
        window:Hide()
    else
        window:Show()
    end
    MenuOpen = not MenuOpen
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    elseif Input.KeyCode == Enum.KeyCode.ç then
        toggleMenu()
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Holding and _G.AimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            local aimPartPosition = target.Character[_G.AimPart].Position
            if isInFOV(aimPartPosition) then
                local direction = (aimPartPosition - Camera.CFrame.Position).Unit
                local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)

                if _G.Sensitivity > 0 then
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, _G.Sensitivity)
                else
                    Camera.CFrame = targetCFrame
                end
            end
        end
    end
end)
