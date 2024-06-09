local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

local aimbotEnabled = false
local teamCheck = false -- Se definido como true, o script só bloqueará sua mira em membros do time inimigo.
local aimPart = "Head" -- Onde o script de aimbot bloqueará.
local sensitivity = 0 -- Quantos segundos o script de aimbot levará para travar oficialmente no aimpart do alvo.

local function GetClosestPlayer()
    local maximumDistance = math.huge
    local target = nil
  
    coroutine.wrap(function()
        wait(20)
        maximumDistance = math.huge -- Reseta a distância máxima para que o Aimbot não a considere como uma variável muito pequena e pare de capturar jogadores...
    end)()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if teamCheck then
                if player.Team ~= LocalPlayer.Team then
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                        local screenPoint = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                        local vectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                                
                        if vectorDistance < maximumDistance then
                            target = player
                            maximumDistance = vectorDistance
                        end
                    end
                end
            else
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local screenPoint = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                    local vectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                            
                    if vectorDistance < maximumDistance then
                        target = player
                        maximumDistance = vectorDistance
                    end
                end
            end
        end
    end

    return target
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and Holding then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer then
            TweenService:Create(Camera, TweenInfo.new(sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character[aimPart].Position)}):Play()
        end
    end
end)

-- Funções para ativar e desativar o aimbot
local function EnableAimbot()
    aimbotEnabled = true
end

local function DisableAimbot()
    aimbotEnabled = false
end
