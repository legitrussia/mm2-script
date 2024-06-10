local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

_G.AimbotEnabled = true
_G.TeamCheck = false -- Se definido como true, o script só travará sua mira nos membros da equipe inimiga.
_G.AimPart = "Head" -- Onde o script de aimbot vai travar.
_G.Sensitivity = 0 -- Quantos segundos leva para o script de aimbot travar oficialmente no alvo.
_G.CircleRadius = 100 -- Valor padrão para o raio do círculo de FOV

local Holding = false

local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil
  
    coroutine.wrap(function()
        wait(20)
        MaximumDistance = _G.CircleRadius -- Redefine o MaximumDistance para que o Aimbot não o considere como uma variável muito pequena e pare de capturar jogadores...
    end)()

    for _, v in next, Players:GetPlayers() do
        if v ~= LocalPlayer and (not _G.TeamCheck or v.Team ~= LocalPlayer.Team) then
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local ScreenPoint = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                                
                if VectorDistance < MaximumDistance then
                    Target = v
                    MaximumDistance = VectorDistance
                end
            end
        end
    end

    return Target
end

local function UpdateAimFOV(fov)
    _G.CircleRadius = fov
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Holding and _G.AimbotEnabled then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer then
            local aimPart = closestPlayer.Character[_G.AimPart]
            if aimPart then
                local aimPosition = Camera:WorldToScreenPoint(aimPart.Position)
                local mousePosition = UserInputService:GetMouseLocation()
                local distanceToTarget = (aimPosition - mousePosition).Magnitude
                if distanceToTarget <= _G.CircleRadius then
                    TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)}):Play()
                end
            end
        end
    end
end)

-- Atualiza o FOV do aimbot quando o valor do menu é alterado
_G.UpdateAimFOV = UpdateAimFOV

-- Puxa o valor do FOV atual do menu
_G.CircleRadius = 100 -- Valor padrão para o raio do círculo de FOV
UpdateAimFOV(_G.CircleRadius) -- Atualiza o FOV com o valor padrão

-- Ajuste para atualizar o FOV do aimbot quando o valor do menu for alterado
local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()
library.options.fovSlider.OnChange:Connect(function(value)
    _G.CircleRadius = value
    UpdateAimFOV(value)
end)
