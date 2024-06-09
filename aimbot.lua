local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

_G.AimbotEnabled = true
_G.TeamCheck = false -- Se definido como true, o script só travará sua mira nos membros da equipe inimiga.
_G.AimPart = "Head" -- Onde o script de aimbot vai travar.
_G.Sensitivity = 0 -- Quantos segundos leva para o script de aimbot travar oficialmente no alvo.

local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil
  
    coroutine.wrap(function()
        wait(20)
        MaximumDistance = _G.CircleRadius -- Redefine o MaximumDistance para que o Aimbot não o considere como uma variável muito pequena e pare de capturar jogadores...
    end)()

    for _, v in next, Players:GetPlayers() do
        if v.Name ~= LocalPlayer.Name then
            if _G.TeamCheck == true then
                if v.Team ~= LocalPlayer.Team then
                    if v.Character ~= nil then
                        if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                                local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                                
                                if VectorDistance < MaximumDistance then
                                    Target = v
                                    MaximumDistance = VectorDistance
                                end
                            end
                        end
                    end
                end
            else
                if v.Character ~= nil then
                    if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                        if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                            local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                            local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                            
                            if VectorDistance < MaximumDistance then
                                Target = v
                                MaximumDistance = VectorDistance
                            end
                        end
                    end
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
    if Holding == true and _G.AimbotEnabled == true then
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
local menuFOV = _G.CircleRadius
UpdateAimFOV(menuFOV)
