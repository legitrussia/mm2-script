local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Holding = false
local CurrentTween = nil
local MenuOpen = true

_G.AimbotEnabled = false
_G.TeamCheck = false -- Se definido como true, o script só travará sua mira nos membros da equipe inimiga.
_G.AimPart = "Head" -- Onde o script de aimbot vai travar.
_G.Sensitivity = 0.2 -- Quantos segundos leva para o script de aimbot travar oficialmente no alvo.
_G.FOV = 50 -- Campo de Visão (em graus)
_G.CircleRadius = 100 -- Raio do círculo de FOV
_G.FOVEnabled = false

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

local Main, tab

local function createMenu()
    Main = library:CreateWindow("Menu", "Crimson")

    tab = Main:CreateTab("Aimbot")
    local tab2 = Main:CreateTab("Esp")
    local tab3 = Main:CreateTab("Misc")

    tab:CreateCheckbox("Aimbot", function(state)
        ToggleAimbot(state)
    end)

    tab:CreateCheckbox("Fov View", function(state)
        toggleFOVCircle(state)
        _G.FOVEnabled = state
        print("FOV View ativado:", state)
    end)

    tab:CreateSlider("Smoothness", 1, 10, function(value)
        _G.Sensitivity = value / 10
        print("Smoothness set to:", value)
    end)

    tab:CreateDropdown("Aim Part", {"Head", "Neck", "Torso"}, function(selected)
        _G.AimPart = selected
        print("Aim Part set to:", selected)
    end)

    tab:CreateSlider("FOV", 0, 180, function(value)
        _G.FOV = value
        updateFOVCircle(value)
        print("FOV set to:", value)
    end)

    local ESP_ENABLED = false

    tab2:CreateCheckbox("Esp", function(state)
        if state then
            ESP_ENABLED = true
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/legitrussia/mm2-script/main/esp.lua"))()
            print("ESP ativado")
        else
            ESP_ENABLED = false
            -- Destrua todos os elementos de GUI com o nome 'ESP'
            for _, v in pairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
                if v.Name == 'ESP' then
                    v:Destroy()
                end
            end
            print("ESP desativado")
        end
    end)

    tab2:CreateDropdown("options", {"Box 2D", "Box 3D", "glow"}, function(a)
        print(a)
    end)

    tab:Show()

    -- Loop para atualizar o círculo FOV
    RunService.RenderStepped:Connect(function()
        if _G.FOVEnabled and FOV_CIRCLE.Visible then
            FOV_CIRCLE.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        end
    end)
end

createMenu()

local function toggleMenu()
    if MenuOpen then
        Main:Hide()
    else
        Main:Show()
    end
    MenuOpen = not MenuOpen
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    elseif Input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
        if CurrentTween then
            CurrentTween:Cancel()
            CurrentTween = nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Holding and _G.AimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            local aimPartPosition = target.Character[_G.AimPart].Position
            if isInFOV(aimPartPosition) then
                if CurrentTween then
                    CurrentTween:Cancel()
                end
                CurrentTween = TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, aimPartPosition)})
                CurrentTween:Play()
            end
        end
    elseif CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
end)
