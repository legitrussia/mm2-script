local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

local AimbotEnabled = false -- Inicialmente desativado
local TeamCheck = false -- Se verdadeiro, o aimbot só irá travar em membros do time inimigo
local AimPart = "Head" -- Parte do corpo onde o aimbot irá travar
local Sensitivity = 0 -- Sensibilidade do aimbot

local function GetClosestPlayer()
    local MaximumDistance = math.huge
    local Target = nil
    
    coroutine.wrap(function()
        wait(20)
        MaximumDistance = math.huge -- Reseta a distância máxima
    end)()

    for _, v in next, Players:GetPlayers() do
        if v.Name ~= LocalPlayer.Name then
            if TeamCheck == true then
                if v.Team ~= LocalPlayer.Team then
                    if v.Character ~= nil then
                        if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                                local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart").Position)
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
                            local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart").Position)
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
    if Holding == true and AimbotEnabled == true then
        local ClosestPlayer = GetClosestPlayer()
        if ClosestPlayer then
            TweenService:Create(Camera, TweenInfo.new(Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, ClosestPlayer.Character[AimPart].Position)}):Play()
        end
    end
end)

-- Função para alternar o estado do aimbot
local function ToggleAimbot()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        print("Aimbot ativado")
    else
        print("Aimbot desativado")
    end
end

-- Exemplo de ativação/desativação do aimbot com uma tecla específica (F)
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.F then
        ToggleAimbot()
    end
end)
