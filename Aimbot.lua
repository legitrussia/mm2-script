local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false
local AimbotConnection = nil

_G.AimbotEnabled = false
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Sensitivity = 0

local function GetClosestPlayer()
    local MaximumDistance = math.huge
    local Target = nil
    
    coroutine.wrap(function()
        wait(20)
        MaximumDistance = math.huge
    end)()

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if _G.TeamCheck == true then
                if v.Team ~= LocalPlayer.Team then
                    local Character = v.Character
                    if Character and Character:FindFirstChild("HumanoidRootPart") then
                        local ScreenPoint = Camera:WorldToScreenPoint(Character.HumanoidRootPart.Position)
                        local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                        
                        if VectorDistance < MaximumDistance then
                            Target = v
                            MaximumDistance = VectorDistance
                        end
                    end
                end
            else
                local Character = v.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local ScreenPoint = Camera:WorldToScreenPoint(Character.HumanoidRootPart.Position)
                    local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                    
                    if VectorDistance < MaximumDistance then
                        Target = v
                        MaximumDistance = VectorDistance
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

local function ActivateAimbot()
    if not _G.AimbotEnabled then
        AimbotConnection = RunService.RenderStepped:Connect(function()
            if Holding == true and _G.AimbotEnabled == true then
                local ClosestPlayer = GetClosestPlayer()
                if ClosestPlayer then
                    TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, ClosestPlayer.Character[_G.AimPart].Position)}):Play()
                end
            end
        end)
    end
end

local function DeactivateAimbot()
    if _G.AimbotEnabled and AimbotConnection then
        AimbotConnection:Disconnect()
    end
end

-- Adicionando a checkbox no menu para ativar/desativar o aimbot
local Toggle1 = Tab1:NewToggle("Aimbot", false, function(value)
    _G.AimbotEnabled = value
    if value then
        ActivateAimbot()
    else
        DeactivateAimbot()
    end
end)
